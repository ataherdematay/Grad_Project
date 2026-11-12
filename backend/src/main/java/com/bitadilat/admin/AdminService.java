package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.AdminActionItem;
import com.bitadilat.admin.AdminDtos.AdminActionList;
import com.bitadilat.admin.AdminDtos.AdminChatMessage;
import com.bitadilat.admin.AdminDtos.AdminComplaintDetail;
import com.bitadilat.admin.AdminDtos.AdminComplaintList;
import com.bitadilat.admin.AdminDtos.AdminComplaintSummary;
import com.bitadilat.admin.AdminDtos.AdminPaymentItem;
import com.bitadilat.admin.AdminDtos.AdminPaymentList;
import com.bitadilat.admin.AdminDtos.AdminUserItem;
import com.bitadilat.admin.AdminDtos.AdminUserList;
import com.bitadilat.admin.AdminDtos.ComplaintDecisionBody;
import com.bitadilat.admin.AdminDtos.DisputedEscrowSummary;
import com.bitadilat.admin.AdminDtos.DisputedJobSummary;
import com.bitadilat.admin.AdminDtos.LedgerEntryView;
import com.bitadilat.admin.AdminDtos.PartyCustomer;
import com.bitadilat.admin.AdminDtos.PartyPro;
import com.bitadilat.admin.AdminDtos.ProApplicationItem;
import com.bitadilat.admin.AdminDtos.ProApplicationList;
import com.bitadilat.auth.RefreshTokenRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.Paging;
import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.job.ActorRole;
import com.bitadilat.job.ComplaintReason;
import com.bitadilat.job.Job;
import com.bitadilat.job.JobEvents;
import com.bitadilat.job.JobFlow;
import com.bitadilat.job.JobRepository;
import com.bitadilat.job.JobStateMachine.Trigger;
import com.bitadilat.job.JobStatus;
import com.bitadilat.job.dto.ComplaintView;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.pro.Availability;
import com.bitadilat.pro.DocumentStatus;
import com.bitadilat.pro.ProCategory;
import com.bitadilat.pro.ProCategoryRepository;
import com.bitadilat.pro.ProDistrict;
import com.bitadilat.pro.ProDistrictRepository;
import com.bitadilat.pro.ProDocument;
import com.bitadilat.pro.ProDocumentRepository;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.pro.dto.ApplicationView;
import com.bitadilat.user.UserMode;
import com.bitadilat.user.UserStatus;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Yönetici işlemleri (API_V1.md §Admin ve STATE_MACHINES.md §1, §5, §6): usta başvurusu onay/ret/belge talebi,
 * şikayet inceleme ve hakem kararı (FULL_REFUND, SPLIT_50_50, RELEASE_TO_PRO), hesap askıya alma / aktifleştirme,
 * emanet defteri ve denetim kayıtları (admin_actions).
 */
@Service
public class AdminService {

    private static final Set<String> VALID_COMPLAINT_STATUSES =
            Set.of("OPEN", "IN_REVIEW", "RESOLVED", "DISMISSED");

    private final JdbcTemplate jdbc;
    private final JobRepository jobs;
    private final JobFlow jobFlow;
    private final JobEvents jobEvents;
    private final EscrowService escrowService;
    private final ProCategoryRepository proCategories;
    private final ProDistrictRepository proDistricts;
    private final ProDocumentRepository proDocuments;
    private final RefreshTokenRepository refreshTokens;
    private final MediaService media;
    private final NotificationService notifications;

    public AdminService(JdbcTemplate jdbc, JobRepository jobs, JobFlow jobFlow, JobEvents jobEvents,
                        EscrowService escrowService, ProCategoryRepository proCategories,
                        ProDistrictRepository proDistricts, ProDocumentRepository proDocuments,
                        RefreshTokenRepository refreshTokens, MediaService media,
                        NotificationService notifications) {
        this.jdbc = jdbc;
        this.jobs = jobs;
        this.jobFlow = jobFlow;
        this.jobEvents = jobEvents;
        this.escrowService = escrowService;
        this.proCategories = proCategories;
        this.proDistricts = proDistricts;
        this.proDocuments = proDocuments;
        this.refreshTokens = refreshTokens;
        this.media = media;
        this.notifications = notifications;
    }

    public static void requireAdmin(AuthPrincipal principal) {
        if (principal == null || !principal.admin()) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bu işlem yalnızca yönetici içindir.");
        }
    }

    // ─── 1. Usta başvuruları (UC12 / SCR-19) ────────────────────────────────

    @Transactional(readOnly = true)
    public ProApplicationList listApplications(AuthPrincipal principal, String status, String cursor, Integer limit) {
        requireAdmin(principal);
        if (status != null && !status.isBlank()) {
            try {
                ReviewStatus.valueOf(status.trim());
            } catch (IllegalArgumentException e) {
                throw ApiException.validation("status", "Geçersiz başvuru durumu: " + status);
            }
        }
        List<UUID> proIds = (status == null || status.isBlank())
                ? jdbc.queryForList("select user_id from pro_profiles order by updated_at desc, user_id", UUID.class)
                : jdbc.queryForList(
                        "select user_id from pro_profiles where review_status = ? order by updated_at desc, user_id",
                        UUID.class, status.trim());
        Paging.Slice<UUID> page = Paging.slice(proIds, cursor, limit);
        return new ProApplicationList(page.items().stream().map(this::applicationItem).toList(), page.nextCursor());
    }

    @Transactional
    public ProApplicationItem approveApplication(AuthPrincipal principal, UUID proId) {
        requireAdmin(principal);
        Instant now = Instant.now();
        ReviewStatus current = lockProProfile(proId);
        if (!EnumSet.of(ReviewStatus.PENDING_REVIEW, ReviewStatus.NEEDS_DOCUMENTS, ReviewStatus.SUSPENDED)
                .contains(current)) {
            throw ApiException.illegalState("Başvuru " + current + " durumunda onaylanamaz.");
        }
        jdbc.update("""
                update pro_profiles set
                  review_status = 'APPROVED',
                  review_note = null,
                  approved_at = coalesce(approved_at, ?),
                  updated_at = ?,
                  version = version + 1
                where user_id = ?""", Timestamp.from(now), Timestamp.from(now), proId);
        jdbc.update("""
                update pro_documents set
                  status = 'ACCEPTED',
                  reviewed_by = ?,
                  reviewed_at = ?
                where pro_id = ?""", principal.userId(), Timestamp.from(now), proId);
        jdbc.update("update users set status = 'ACTIVE', updated_at = ? where id = ? and status = 'SUSPENDED'",
                Timestamp.from(now), proId);

        recordAdminAction(principal.userId(), "PRO_APPROVE", "PRO_PROFILE", proId.toString(), null, now);
        notifications.notify(proId, NotificationService.PRO_APPLICATION_APPROVED, Map.of("proId", proId.toString()),
                "/p/profile");
        return applicationItem(proId);
    }

    @Transactional
    public ProApplicationItem rejectApplication(AuthPrincipal principal, UUID proId, String rawReason) {
        requireAdmin(principal);
        String reason = requireTrimmed(rawReason, "reason", 5, 500);
        Instant now = Instant.now();
        ReviewStatus current = lockProProfile(proId);
        if (!EnumSet.of(ReviewStatus.PENDING_REVIEW, ReviewStatus.NEEDS_DOCUMENTS).contains(current)) {
            throw ApiException.illegalState("Başvuru " + current + " durumunda reddedilemez.");
        }
        jdbc.update("""
                update pro_profiles set
                  review_status = 'REJECTED',
                  review_note = ?,
                  updated_at = ?,
                  version = version + 1
                where user_id = ?""", reason, Timestamp.from(now), proId);
        jdbc.update("""
                update pro_documents set
                  status = 'REJECTED',
                  reviewed_by = ?,
                  reviewed_at = ?
                where pro_id = ? and status = 'PENDING'""", principal.userId(), Timestamp.from(now), proId);

        recordAdminAction(principal.userId(), "PRO_REJECT", "PRO_PROFILE", proId.toString(), reason, now);
        notifications.notify(proId, NotificationService.PRO_APPLICATION_REJECTED,
                Map.of("proId", proId.toString(), "reason", reason), "/p/application");
        return applicationItem(proId);
    }

    @Transactional
    public ProApplicationItem requestDocuments(AuthPrincipal principal, UUID proId, String rawNote) {
        requireAdmin(principal);
        String note = requireTrimmed(rawNote, "note", 5, 500);
        Instant now = Instant.now();
        ReviewStatus current = lockProProfile(proId);
        if (current != ReviewStatus.PENDING_REVIEW) {
            throw ApiException.illegalState("Yalnızca PENDING_REVIEW başvurudan ek belge istenebilir.");
        }
        jdbc.update("""
                update pro_profiles set
                  review_status = 'NEEDS_DOCUMENTS',
                  review_note = ?,
                  updated_at = ?,
                  version = version + 1
                where user_id = ?""", note, Timestamp.from(now), proId);

        recordAdminAction(principal.userId(), "PRO_REQUEST_DOCUMENTS", "PRO_PROFILE", proId.toString(), note, now);
        notifications.notify(proId, NotificationService.PRO_DOCUMENTS_REQUESTED,
                Map.of("proId", proId.toString(), "note", note), "/p/application");
        return applicationItem(proId);
    }

    // ─── 2. Şikayetler ve hakem kararları (UC13 / SCR-20 / STATE_MACHINES §5) ─

    @Transactional(readOnly = true)
    public AdminComplaintList listComplaints(AuthPrincipal principal, String status, String cursor, Integer limit) {
        requireAdmin(principal);
        if (status != null && !status.isBlank() && !VALID_COMPLAINT_STATUSES.contains(status.trim())) {
            throw ApiException.validation("status", "Geçersiz şikayet durumu: " + status);
        }
        String sql = """
                select c.id, c.public_code, c.job_id, r.public_code as request_public_code,
                       c.customer_id, cu.full_name as customer_name,
                       c.pro_id, p.business_name as pro_business_name,
                       c.reason, c.description, c.status, c.decision, c.decision_note,
                       c.warn_pro, c.suspend_pro, c.created_at, c.decided_at
                from complaints c
                join jobs j on j.id = c.job_id
                join service_requests r on r.id = j.request_id
                join users cu on cu.id = c.customer_id
                join pro_profiles p on p.user_id = c.pro_id
                """ + (status == null || status.isBlank() ? "" : " where c.status = ? ")
                + " order by c.created_at desc, c.id desc";

        List<AdminComplaintSummary> all = (status == null || status.isBlank())
                ? jdbc.query(sql, (rs, i) -> mapComplaintSummary(rs))
                : jdbc.query(sql, (rs, i) -> mapComplaintSummary(rs), status.trim());
        Paging.Slice<AdminComplaintSummary> page = Paging.slice(all, cursor, limit);
        return new AdminComplaintList(page.items(), page.nextCursor());
    }

    @Transactional(readOnly = true)
    public AdminComplaintDetail getComplaintDetail(AuthPrincipal principal, UUID complaintId) {
        requireAdmin(principal);
        return buildComplaintDetail(complaintId);
    }

    @Transactional
    public AdminComplaintDetail markComplaintInReview(AuthPrincipal principal, UUID complaintId) {
        requireAdmin(principal);
        Instant now = Instant.now();
        List<String> rows = jdbc.query(
                "select status from complaints where id = ? for update",
                (rs, i) -> rs.getString("status"), complaintId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Şikayet bulunamadı.");
        }
        String current = rows.get(0);
        if (!"OPEN".equals(current)) {
            throw ApiException.illegalState("Yalnızca OPEN durumundaki şikayet incelemeye alınabilir (mevcut: " + current + ").");
        }
        jdbc.update("update complaints set status = 'IN_REVIEW', updated_at = ? where id = ?",
                Timestamp.from(now), complaintId);
        recordAdminAction(principal.userId(), "COMPLAINT_REVIEW", "COMPLAINT", complaintId.toString(), null, now);
        return buildComplaintDetail(complaintId);
    }

    @Transactional
    public AdminComplaintDetail decideComplaint(AuthPrincipal principal, UUID complaintId, ComplaintDecisionBody body) {
        requireAdmin(principal);
        String note = requireTrimmed(body.decisionNote(), "decisionNote", 10, 1000);
        Instant now = Instant.now();

        List<Map<String, Object>> compRows = jdbc.queryForList(
                "select job_id, customer_id, pro_id, public_code, status from complaints where id = ?",
                complaintId);
        if (compRows.isEmpty()) {
            throw ApiException.notFound("Şikayet bulunamadı.");
        }
        UUID jobId = (UUID) compRows.get(0).get("job_id");

        // Kilit sırası (Wave 3 standardı): iş -> emanet -> şikayet
        Job job = jobs.lockById(jobId).orElseThrow(() -> ApiException.notFound("İş bulunamadı."));
        EscrowPayment payment = escrowService.lockForJob(jobId);
        String complaintStatus = jdbc.queryForObject(
                "select status from complaints where id = ? for update", String.class, complaintId);

        if (!"OPEN".equals(complaintStatus) && !"IN_REVIEW".equals(complaintStatus)) {
            throw ApiException.illegalState("Şikayet zaten karara bağlanmış: " + complaintStatus);
        }
        if (job.getStatus() != JobStatus.DISPUTED) {
            throw ApiException.illegalState("İş DISPUTED durumunda değil: " + job.getStatus());
        }

        String finalComplaintStatus;
        switch (body.decision()) {
            case "FULL_REFUND" -> {
                escrowService.refundFully(payment);
                job.setCancelledBy(ActorRole.ADMIN);
                job.setCancelReason("COMPLAINT_FULL_REFUND");
                job.setCancelNote(note);
                jobFlow.move(job, Trigger.ADMIN_CANCEL, principal.userId(), ActorRole.ADMIN, note, now);
                finalComplaintStatus = "RESOLVED";
            }
            case "SPLIT_50_50" -> {
                escrowService.settleSplit(payment);
                jobFlow.move(job, Trigger.ADMIN_RESOLVE, principal.userId(), ActorRole.ADMIN, note, now);
                finalComplaintStatus = "RESOLVED";
            }
            case "RELEASE_TO_PRO" -> {
                escrowService.release(payment);
                jobFlow.move(job, Trigger.ADMIN_COMPLETE, principal.userId(), ActorRole.ADMIN, note, now);
                jdbc.update("update pro_profiles set completed_jobs = completed_jobs + 1, version = version + 1 where user_id = ?",
                        job.getProId());
                finalComplaintStatus = "DISMISSED";
            }
            default -> throw ApiException.validation("decision", "Geçersiz karar: " + body.decision());
        }

        boolean warn = Boolean.TRUE.equals(body.warnPro());
        boolean suspend = Boolean.TRUE.equals(body.suspendPro());
        if (warn) {
            jdbc.update("update pro_profiles set warning_count = warning_count + 1, version = version + 1 where user_id = ?",
                    job.getProId());
        }
        if (suspend) {
            suspendUserInternal(principal.userId(), job.getProId(), "Şikayet kararı (" + compRows.get(0).get("public_code") + "): " + note, now);
        }

        jdbc.update("""
                update complaints set
                  status = ?,
                  decision = ?,
                  decision_note = ?,
                  decided_by = ?,
                  decided_at = ?,
                  warn_pro = ?,
                  suspend_pro = ?,
                  updated_at = ?
                where id = ?""",
                finalComplaintStatus, body.decision(), note, principal.userId(), Timestamp.from(now),
                warn, suspend, Timestamp.from(now), complaintId);

        recordAdminAction(principal.userId(), "COMPLAINT_DECISION_" + body.decision(), "COMPLAINT",
                complaintId.toString(), note, now);

        String complaintCode = (String) compRows.get(0).get("public_code");
        Map<String, Object> notifParams = Map.of(
                "complaintId", complaintId.toString(),
                "complaintCode", complaintCode,
                "jobId", jobId.toString(),
                "decision", body.decision(),
                "decisionNote", note);
        notifications.notify(job.getCustomerId(), NotificationService.COMPLAINT_DECIDED, notifParams,
                "/jobs/" + jobId);
        notifications.notify(job.getProId(), NotificationService.COMPLAINT_DECIDED, notifParams,
                "/p/jobs/" + jobId);

        return buildComplaintDetail(complaintId);
    }

    // ─── 3. Kullanıcı ve usta hesap yönetimi (SCR-21 / STATE_MACHINES §1) ──

    @Transactional(readOnly = true)
    public AdminUserList listUsers(AuthPrincipal principal, String q, String role, String status, String district,
                                   String cursor, Integer limit) {
        requireAdmin(principal);
        List<AdminUserItem> all = jdbc.query("""
                select u.id, u.full_name, u.email, u.phone, u.status, u.last_mode, u.is_admin, u.created_at,
                       p.business_name, p.review_status, p.availability,
                       coalesce(p.warning_count, 0) as warning_count,
                       coalesce(p.cancellation_count, 0) as cancellation_count
                from users u
                left join pro_profiles p on p.user_id = u.id
                order by u.created_at desc, u.id""",
                (rs, i) -> {
                    String rev = rs.getString("review_status");
                    String avail = rs.getString("availability");
                    return new AdminUserItem(
                            rs.getObject("id", UUID.class),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            UserStatus.valueOf(rs.getString("status")),
                            UserMode.valueOf(rs.getString("last_mode")),
                            rs.getBoolean("is_admin"),
                            rs.getString("business_name"),
                            rev == null ? null : ReviewStatus.valueOf(rev),
                            avail == null ? null : Availability.valueOf(avail),
                            rs.getInt("warning_count"),
                            rs.getInt("cancellation_count"),
                            rs.getTimestamp("created_at").toInstant());
                });

        List<AdminUserItem> filtered = all.stream().filter(u -> {
            if (q != null && !q.isBlank()) {
                String needle = q.trim().toLowerCase();
                boolean match = u.fullName().toLowerCase().contains(needle)
                        || u.email().toLowerCase().contains(needle)
                        || (u.phone() != null && u.phone().toLowerCase().contains(needle))
                        || (u.businessName() != null && u.businessName().toLowerCase().contains(needle));
                if (!match) {
                    return false;
                }
            }
            if (role != null && !role.isBlank()) {
                String r = role.trim().toUpperCase();
                if ("ADMIN".equals(r) && !u.isAdmin()) return false;
                if ("PRO".equals(r) && u.proReviewStatus() == null) return false;
                if ("CUSTOMER".equals(r) && (u.isAdmin() || u.proReviewStatus() != null)) return false;
            }
            if (status != null && !status.isBlank() && !u.status().name().equalsIgnoreCase(status.trim())) {
                return false;
            }
            if (district != null && !district.isBlank()) {
                Integer count = jdbc.queryForObject("""
                        select count(*) from pro_districts pd
                        join districts d on d.id = pd.district_id
                        where pd.pro_id = ? and (lower(d.name) = lower(?) or d.id::text = ?)""",
                        Integer.class, u.id(), district.trim(), district.trim());
                if (count == null || count == 0) {
                    return false;
                }
            }
            return true;
        }).toList();

        Paging.Slice<AdminUserItem> page = Paging.slice(filtered, cursor, limit);
        return new AdminUserList(page.items(), page.nextCursor());
    }

    @Transactional
    public AdminUserItem suspendUser(AuthPrincipal principal, UUID targetUserId, String rawReason) {
        requireAdmin(principal);
        String reason = requireTrimmed(rawReason, "reason", 5, 500);
        Instant now = Instant.now();
        suspendUserInternal(principal.userId(), targetUserId, reason, now);
        return getUserItem(targetUserId);
    }

    @Transactional
    public AdminUserItem reactivateUser(AuthPrincipal principal, UUID targetUserId, String rawNote) {
        requireAdmin(principal);
        String note = rawNote == null || rawNote.isBlank() ? null : rawNote.trim();
        Instant now = Instant.now();
        List<Map<String, Object>> rows = jdbc.queryForList(
                "select status from users where id = ? for update", targetUserId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Kullanıcı bulunamadı.");
        }
        String current = (String) rows.get(0).get("status");
        if (!"SUSPENDED".equals(current)) {
            throw ApiException.illegalState("Yalnızca SUSPENDED durumundaki hesap yeniden aktifleştirilebilir (mevcut: " + current + ").");
        }
        jdbc.update("update users set status = 'ACTIVE', updated_at = ? where id = ?",
                Timestamp.from(now), targetUserId);
        // Daha önce onaylanmış usta ise APPROVED durumuna geri döner (STATE_MACHINES.md §1: APPROVED -> SUSPENDED -> APPROVED)
        jdbc.update("""
                update pro_profiles set
                  review_status = case when approved_at is not null then 'APPROVED' else 'PENDING_REVIEW' end,
                  updated_at = ?,
                  version = version + 1
                where user_id = ? and review_status = 'SUSPENDED'""",
                Timestamp.from(now), targetUserId);

        recordAdminAction(principal.userId(), "USER_REACTIVATE", "USER", targetUserId.toString(), note, now);
        notifications.notify(targetUserId, NotificationService.ACCOUNT_REACTIVATED,
                Map.of("userId", targetUserId.toString()), "/");
        return getUserItem(targetUserId);
    }

    // ─── 4. Emanet defteri ve denetim kayıtları ─────────────────────────────

    @Transactional(readOnly = true)
    public AdminPaymentList listPayments(AuthPrincipal principal, String status, String cursor, Integer limit) {
        requireAdmin(principal);
        if (status != null && !status.isBlank()) {
            try {
                EscrowStatus.valueOf(status.trim());
            } catch (IllegalArgumentException e) {
                throw ApiException.validation("status", "Geçersiz emanet durumu: " + status);
            }
        }
        String sql = """
                select e.ref, e.job_ref, e.request_id, e.job_id, e.customer_id, cu.full_name as customer_name,
                       e.pro_id, p.business_name as pro_business_name, e.status, e.channel, e.provider,
                       e.total_amount, e.commission, e.pro_payout, e.refunded_amount,
                       e.error_code, e.result_uncertain, e.created_at, e.locked_at, e.released_at, e.refunded_at
                from escrow_payment e
                left join users cu on cu.id = e.customer_id
                left join pro_profiles p on p.user_id = e.pro_id
                """ + (status == null || status.isBlank() ? "" : " where e.status = ? ")
                + " order by e.created_at desc, e.ref";

        List<AdminPaymentItem> all = (status == null || status.isBlank())
                ? jdbc.query(sql, (rs, i) -> mapPaymentItem(rs))
                : jdbc.query(sql, (rs, i) -> mapPaymentItem(rs), status.trim());
        Paging.Slice<AdminPaymentItem> page = Paging.slice(all, cursor, limit);
        return new AdminPaymentList(page.items(), page.nextCursor());
    }

    @Transactional(readOnly = true)
    public AdminActionList listActions(AuthPrincipal principal, String targetType, String targetId,
                                       String cursor, Integer limit) {
        requireAdmin(principal);
        List<AdminActionItem> all = jdbc.query("""
                select a.id, a.admin_id, u.email as admin_email, a.action, a.target_type, a.target_id, a.note, a.created_at
                from admin_actions a
                join users u on u.id = a.admin_id
                order by a.created_at desc, a.id desc""",
                (rs, i) -> new AdminActionItem(
                        rs.getObject("id", UUID.class),
                        rs.getObject("admin_id", UUID.class),
                        rs.getString("admin_email"),
                        rs.getString("action"),
                        rs.getString("target_type"),
                        rs.getString("target_id"),
                        rs.getString("note"),
                        rs.getTimestamp("created_at").toInstant()));
        List<AdminActionItem> filtered = all.stream().filter(a -> {
            if (targetType != null && !targetType.isBlank() && !a.targetType().equalsIgnoreCase(targetType.trim())) {
                return false;
            }
            return targetId == null || targetId.isBlank() || a.targetId().equals(targetId.trim());
        }).toList();
        Paging.Slice<AdminActionItem> page = Paging.slice(filtered, cursor, limit);
        return new AdminActionList(page.items(), page.nextCursor());
    }

    // ─── İç yardımcılar ─────────────────────────────────────────────────────

    private void suspendUserInternal(UUID adminId, UUID targetUserId, String reason, Instant now) {
        if (adminId.equals(targetUserId)) {
            throw ApiException.illegalState("Yönetici kendi hesabını askıya alamaz.");
        }
        List<Map<String, Object>> rows = jdbc.queryForList(
                "select status, is_admin from users where id = ? for update", targetUserId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Kullanıcı bulunamadı.");
        }
        if (Boolean.TRUE.equals(rows.get(0).get("is_admin"))) {
            throw ApiException.illegalState("Yönetici hesabı askıya alınamaz.");
        }
        String current = (String) rows.get(0).get("status");
        if (!"ACTIVE".equals(current)) {
            throw ApiException.illegalState("Yalnızca ACTIVE durumundaki hesap askıya alınabilir (mevcut: " + current + ").");
        }
        jdbc.update("update users set status = 'SUSPENDED', updated_at = ? where id = ?",
                Timestamp.from(now), targetUserId);
        jdbc.update("""
                update pro_profiles set
                  review_status = 'SUSPENDED',
                  review_note = ?,
                  updated_at = ?,
                  version = version + 1
                where user_id = ?""", reason, Timestamp.from(now), targetUserId);
        // STATE_MACHINES.md §1 ve §3: usta askıya alınınca açık (PENDING) teklifler WITHDRAWN olur.
        jdbc.update("""
                update offers set status = 'WITHDRAWN', updated_at = ?, version = version + 1
                where pro_id = ? and status = 'PENDING'""", Timestamp.from(now), targetUserId);
        refreshTokens.revokeAllForUser(targetUserId, now);

        recordAdminAction(adminId, "USER_SUSPEND", "USER", targetUserId.toString(), reason, now);
        notifications.notify(targetUserId, NotificationService.ACCOUNT_SUSPENDED,
                Map.of("userId", targetUserId.toString(), "reason", reason), "/");
    }

    private ReviewStatus lockProProfile(UUID proId) {
        List<String> rows = jdbc.query(
                "select review_status from pro_profiles where user_id = ? for update",
                (rs, i) -> rs.getString("review_status"), proId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Usta başvurusu bulunamadı.");
        }
        return ReviewStatus.valueOf(rows.get(0));
    }

    private ProApplicationItem applicationItem(UUID proId) {
        List<ProDocument> docs = proDocuments.findByProIdOrderByCreatedAtAsc(proId);
        List<String> cats = proCategories.findByProId(proId).stream()
                .map(ProCategory::getCategoryId).sorted().toList();
        List<Integer> dists = proDistricts.findByProId(proId).stream()
                .map(ProDistrict::getDistrictId).sorted().toList();
        return jdbc.queryForObject("""
                select u.full_name, u.email, u.phone, p.business_name, p.bio, p.experience_years,
                       p.review_status, p.review_note, p.created_at, p.approved_at
                from pro_profiles p
                join users u on u.id = p.user_id
                where p.user_id = ?""",
                (rs, i) -> {
                    Instant created = rs.getTimestamp("created_at").toInstant();
                    Instant submitted = docs.stream().map(ProDocument::getCreatedAt)
                            .max(Comparator.naturalOrder()).orElse(created);
                    Timestamp appTs = rs.getTimestamp("approved_at");
                    return new ProApplicationItem(
                            proId,
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            rs.getString("business_name"),
                            rs.getString("bio"),
                            rs.getInt("experience_years"),
                            ReviewStatus.valueOf(rs.getString("review_status")),
                            rs.getString("review_note"),
                            cats,
                            dists,
                            docs.stream().map(d -> new ApplicationView.Doc(
                                    d.getId(), d.getType(), d.getStatus(), media.ref(d.getMediaId()))).toList(),
                            submitted,
                            appTs == null ? null : appTs.toInstant());
                }, proId);
    }

    private AdminComplaintDetail buildComplaintDetail(UUID complaintId) {
        List<UUID> evidenceIds = jdbc.queryForList(
                "select media_id from complaint_evidence where complaint_id = ? order by media_id",
                UUID.class, complaintId);

        List<Map<String, Object>> rows = jdbc.queryForList("""
                select c.id, c.public_code, c.job_id, c.customer_id, c.pro_id, c.reason, c.description,
                       c.status, c.decision, c.decision_note, c.warn_pro, c.suspend_pro, c.created_at, c.decided_at
                from complaints c where c.id = ?""", complaintId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Şikayet bulunamadı.");
        }
        Map<String, Object> c = rows.get(0);
        UUID jobId = (UUID) c.get("job_id");
        UUID customerId = (UUID) c.get("customer_id");
        UUID proId = (UUID) c.get("pro_id");
        Timestamp decidedTs = (Timestamp) c.get("decided_at");

        ComplaintView complaintView = new ComplaintView(
                complaintId,
                (String) c.get("public_code"),
                jobId,
                ComplaintReason.valueOf((String) c.get("reason")),
                (String) c.get("description"),
                media.refs(evidenceIds),
                (String) c.get("status"),
                (String) c.get("decision"),
                (String) c.get("decision_note"),
                ((Timestamp) c.get("created_at")).toInstant(),
                decidedTs == null ? null : decidedTs.toInstant());

        PartyCustomer customer = jdbc.queryForObject(
                "select id, full_name, email, phone from users where id = ?",
                (rs, i) -> new PartyCustomer(rs.getObject("id", UUID.class), rs.getString("full_name"),
                        rs.getString("email"), rs.getString("phone")),
                customerId);

        PartyPro pro = jdbc.queryForObject("""
                select u.id, u.full_name, p.business_name, u.email, u.phone, p.review_status,
                       p.warning_count, p.cancellation_count
                from users u join pro_profiles p on p.user_id = u.id where u.id = ?""",
                (rs, i) -> new PartyPro(rs.getObject("id", UUID.class), rs.getString("full_name"),
                        rs.getString("business_name"), rs.getString("email"), rs.getString("phone"),
                        ReviewStatus.valueOf(rs.getString("review_status")),
                        rs.getInt("warning_count"), rs.getInt("cancellation_count")),
                proId);

        DisputedJobSummary jobSummary = jdbc.queryForObject("""
                select j.id, r.public_code, r.title, r.category_id, j.status, j.status_before_dispute,
                       j.scheduled_from, j.scheduled_to, j.arrived_at, j.started_at, j.finished_at, o.total_amount
                from jobs j
                join service_requests r on r.id = j.request_id
                join offers o on o.id = j.offer_id
                where j.id = ?""",
                (rs, i) -> {
                    String before = rs.getString("status_before_dispute");
                    return new DisputedJobSummary(
                            rs.getObject("id", UUID.class),
                            rs.getString("public_code"),
                            rs.getString("title"),
                            rs.getString("category_id"),
                            JobStatus.valueOf(rs.getString("status")),
                            before == null ? null : JobStatus.valueOf(before),
                            toInstant(rs.getTimestamp("scheduled_from")),
                            toInstant(rs.getTimestamp("scheduled_to")),
                            toInstant(rs.getTimestamp("arrived_at")),
                            toInstant(rs.getTimestamp("started_at")),
                            toInstant(rs.getTimestamp("finished_at")),
                            rs.getBigDecimal("total_amount"));
                }, jobId);

        DisputedEscrowSummary paymentSummary = jdbc.queryForObject("""
                select ref, status, total_amount, refunded_amount, commission, pro_payout
                from escrow_payment where job_id = ?""",
                (rs, i) -> new DisputedEscrowSummary(
                        rs.getString("ref"),
                        EscrowStatus.valueOf(rs.getString("status")),
                        rs.getBigDecimal("total_amount"),
                        rs.getBigDecimal("refunded_amount"),
                        rs.getBigDecimal("commission"),
                        rs.getBigDecimal("pro_payout")),
                jobId);

        List<AdminChatMessage> chatMessages = jdbc.query("""
                select id, sender_id, body, media_id, created_at
                from messages where job_id = ? order by id asc""",
                (rs, i) -> {
                    UUID senderId = rs.getObject("sender_id", UUID.class);
                    UUID mediaId = rs.getObject("media_id", UUID.class);
                    String role = senderId.equals(customerId) ? "CUSTOMER" : "PRO";
                    return new AdminChatMessage(
                            rs.getLong("id"),
                            role,
                            senderId,
                            rs.getString("body"),
                            mediaId == null ? null : media.ref(mediaId),
                            rs.getTimestamp("created_at").toInstant());
                }, jobId);

        return new AdminComplaintDetail(
                complaintView,
                customer,
                pro,
                jobSummary,
                paymentSummary,
                jobEvents.timeline(jobId),
                chatMessages,
                Boolean.TRUE.equals(c.get("warn_pro")),
                Boolean.TRUE.equals(c.get("suspend_pro")));
    }

    private AdminUserItem getUserItem(UUID userId) {
        return jdbc.queryForObject("""
                select u.id, u.full_name, u.email, u.phone, u.status, u.last_mode, u.is_admin, u.created_at,
                       p.business_name, p.review_status, p.availability,
                       coalesce(p.warning_count, 0) as warning_count,
                       coalesce(p.cancellation_count, 0) as cancellation_count
                from users u
                left join pro_profiles p on p.user_id = u.id
                where u.id = ?""",
                (rs, i) -> {
                    String rev = rs.getString("review_status");
                    String avail = rs.getString("availability");
                    return new AdminUserItem(
                            rs.getObject("id", UUID.class),
                            rs.getString("full_name"),
                            rs.getString("email"),
                            rs.getString("phone"),
                            UserStatus.valueOf(rs.getString("status")),
                            UserMode.valueOf(rs.getString("last_mode")),
                            rs.getBoolean("is_admin"),
                            rs.getString("business_name"),
                            rev == null ? null : ReviewStatus.valueOf(rev),
                            avail == null ? null : Availability.valueOf(avail),
                            rs.getInt("warning_count"),
                            rs.getInt("cancellation_count"),
                            rs.getTimestamp("created_at").toInstant());
                }, userId);
    }

    private AdminComplaintSummary mapComplaintSummary(java.sql.ResultSet rs) throws java.sql.SQLException {
        return new AdminComplaintSummary(
                rs.getObject("id", UUID.class),
                rs.getString("public_code"),
                rs.getObject("job_id", UUID.class),
                rs.getString("request_public_code"),
                rs.getObject("customer_id", UUID.class),
                rs.getString("customer_name"),
                rs.getObject("pro_id", UUID.class),
                rs.getString("pro_business_name"),
                ComplaintReason.valueOf(rs.getString("reason")),
                rs.getString("description"),
                rs.getString("status"),
                rs.getString("decision"),
                rs.getString("decision_note"),
                rs.getBoolean("warn_pro"),
                rs.getBoolean("suspend_pro"),
                rs.getTimestamp("created_at").toInstant(),
                toInstant(rs.getTimestamp("decided_at")));
    }

    private AdminPaymentItem mapPaymentItem(java.sql.ResultSet rs) throws java.sql.SQLException {
        String ref = rs.getString("ref");
        List<LedgerEntryView> ledger = jdbc.query("""
                select id, kind, amount, created_at
                from payout_ledger where payment_ref = ? order by created_at asc, id""",
                (lrs, j) -> new LedgerEntryView(
                        lrs.getObject("id", UUID.class),
                        lrs.getString("kind"),
                        lrs.getBigDecimal("amount"),
                        lrs.getTimestamp("created_at").toInstant()),
                ref);
        return new AdminPaymentItem(
                ref,
                rs.getString("job_ref"),
                rs.getObject("request_id", UUID.class),
                rs.getObject("job_id", UUID.class),
                rs.getObject("customer_id", UUID.class),
                rs.getString("customer_name"),
                rs.getObject("pro_id", UUID.class),
                rs.getString("pro_business_name"),
                EscrowStatus.valueOf(rs.getString("status")),
                rs.getString("channel"),
                rs.getString("provider"),
                rs.getBigDecimal("total_amount"),
                rs.getBigDecimal("commission"),
                rs.getBigDecimal("pro_payout"),
                rs.getBigDecimal("refunded_amount"),
                rs.getString("error_code"),
                rs.getBoolean("result_uncertain"),
                rs.getTimestamp("created_at").toInstant(),
                toInstant(rs.getTimestamp("locked_at")),
                toInstant(rs.getTimestamp("released_at")),
                toInstant(rs.getTimestamp("refunded_at")),
                ledger);
    }

    private void recordAdminAction(UUID adminId, String action, String targetType, String targetId,
                                   String note, Instant now) {
        jdbc.update("""
                insert into admin_actions (admin_id, action, target_type, target_id, note, created_at)
                values (?, ?, ?, ?, ?, ?)""",
                adminId, action, targetType, targetId, note, Timestamp.from(now));
    }

    private static String requireTrimmed(String raw, String field, int min, int max) {
        if (raw == null) {
            throw ApiException.validation(field, field + " zorunlu.");
        }
        String t = raw.trim();
        if (t.length() < min || t.length() > max) {
            throw ApiException.validation(field, field + " " + min + "-" + max + " karakter olmalı.");
        }
        return t;
    }

    private static Instant toInstant(Timestamp ts) {
        return ts == null ? null : ts.toInstant();
    }
}
