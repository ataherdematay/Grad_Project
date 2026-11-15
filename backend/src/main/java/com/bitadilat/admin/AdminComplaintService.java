package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.ChatMessage;
import com.bitadilat.admin.AdminDtos.ComplaintDetail;
import com.bitadilat.admin.AdminDtos.ComplaintItem;
import com.bitadilat.admin.AdminDtos.ComplaintList;
import com.bitadilat.admin.AdminDtos.DecisionBody;
import com.bitadilat.admin.AdminDtos.JobInfo;
import com.bitadilat.admin.AdminDtos.Party;
import com.bitadilat.admin.AdminDtos.PaymentInfo;
import com.bitadilat.admin.AdminDtos.ProParty;
import com.bitadilat.common.ApiException;
import com.bitadilat.job.ActorRole;
import com.bitadilat.job.ComplaintReason;
import com.bitadilat.job.Job;
import com.bitadilat.job.JobEvents;
import com.bitadilat.job.JobFeedbackService;
import com.bitadilat.job.JobFlow;
import com.bitadilat.job.JobRepository;
import com.bitadilat.job.JobStateMachine;
import com.bitadilat.job.JobStateMachine.Trigger;
import com.bitadilat.job.dto.ComplaintView;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.offer.OfferService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.request.CancelReason;
import com.bitadilat.request.RequestService;
import com.bitadilat.request.RequestStatus;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Şikayet inceleme ve karar. Karar, para ve iş geçişlerini mevcut yollardan yapar ({@link EscrowService},
 * {@link JobFlow}); yeni bir geçiş yolu açmaz.
 *
 * <p>Kilit sırası projedeki kuralla aynıdır: iş, (şikayet satırı), emanet, talep. Şikayet satırı iş kilidinden sonra
 * kilitlenir; eşzamanlı iki karar sıraya girer ve ikincisi durumu "karara bağlanmış" görüp 409 alır. Craftgate çağrısı
 * (iade) tüm veritabanı yazımlarından sonra, işlem kesinleşmeden hemen önce yapılır: gateway hatası (502) tüm
 * değişikliği geri alır, para hareketi gerçekleşmişse veritabanı yazımı artık başarısız olamayacak durumdadır.
 */
@Service
public class AdminComplaintService {

    static final String FULL_REFUND = "FULL_REFUND";
    static final String SPLIT_50_50 = "SPLIT_50_50";
    static final String RELEASE_TO_PRO = "RELEASE_TO_PRO";

    private final JdbcTemplate jdbc;
    private final JobRepository jobs;
    private final JobFlow flow;
    private final JobEvents events;
    private final JobFeedbackService feedback;
    private final EscrowService escrow;
    private final EscrowPaymentRepository escrows;
    private final ServiceRequestRepository requests;
    private final RequestService requestService;
    private final OfferService offerService;
    private final MediaService media;
    private final NotificationService notifications;
    private final AdminAudit audit;

    public AdminComplaintService(JdbcTemplate jdbc, JobRepository jobs, JobFlow flow, JobEvents events,
                                 JobFeedbackService feedback, EscrowService escrow, EscrowPaymentRepository escrows,
                                 ServiceRequestRepository requests, RequestService requestService,
                                 OfferService offerService, MediaService media, NotificationService notifications,
                                 AdminAudit audit) {
        this.jdbc = jdbc;
        this.jobs = jobs;
        this.flow = flow;
        this.events = events;
        this.feedback = feedback;
        this.escrow = escrow;
        this.escrows = escrows;
        this.requests = requests;
        this.requestService = requestService;
        this.offerService = offerService;
        this.media = media;
        this.notifications = notifications;
        this.audit = audit;
    }

    // ─── Liste ve ayrıntı ───────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public ComplaintList list(String status) {
        List<String> statuses = status == null || status.isBlank() ? List.of("OPEN", "IN_REVIEW") : List.of(status.trim());
        if (statuses.size() == 1 && !List.of("OPEN", "IN_REVIEW", "RESOLVED", "DISMISSED").contains(statuses.get(0))) {
            throw ApiException.validation("status", "status geçersiz.");
        }
        String marks = String.join(",", java.util.Collections.nCopies(statuses.size(), "?"));
        List<ComplaintItem> items = jdbc.query("""
                select c.id, c.public_code, c.job_id, r.public_code as job_code, c.reason, c.status, cu.full_name,
                       p.business_name, coalesce(e.total_amount, o.total_amount) as amount, c.created_at
                from complaints c
                join jobs j on j.id = c.job_id
                join service_requests r on r.id = j.request_id
                join offers o on o.id = j.offer_id
                join users cu on cu.id = c.customer_id
                join pro_profiles p on p.user_id = c.pro_id
                left join escrow_payment e on e.job_id = j.id
                where c.status in (""" + marks + ") order by c.created_at asc, c.id asc",
                (rs, i) -> new ComplaintItem(rs.getObject("id", UUID.class), rs.getString("public_code"),
                        rs.getObject("job_id", UUID.class), rs.getString("job_code"),
                        ComplaintReason.valueOf(rs.getString("reason")), rs.getString("status"),
                        rs.getString("full_name"), rs.getString("business_name"), rs.getBigDecimal("amount"),
                        rs.getTimestamp("created_at").toInstant()), statuses.toArray());
        return new ComplaintList(items);
    }

    @Transactional(readOnly = true)
    public ComplaintDetail detail(UUID adminId, UUID complaintId) {
        return buildDetail(adminId, complaintId);
    }

    /** OPEN → IN_REVIEW. */
    @Transactional
    public ComplaintDetail review(UUID adminId, UUID complaintId) {
        String status = lockComplaintStatus(complaintId);
        if (!"OPEN".equals(status)) {
            throw ApiException.illegalState("Şikayet " + status + " durumunda; yalnızca OPEN şikayet incelemeye alınır.");
        }
        jdbc.update("update complaints set status = 'IN_REVIEW', updated_at = now() where id = ?", complaintId);
        audit.record(adminId, "REVIEW_COMPLAINT", AdminAudit.COMPLAINT, complaintId, null);
        return buildDetail(adminId, complaintId);
    }

    // ─── Karar ──────────────────────────────────────────────────────────────

    @Transactional
    public void decide(UUID adminId, UUID complaintId, DecisionBody body) {
        if (body.decision() == null) {
            throw ApiException.validation("decision", "decision gerekli.");
        }
        String decision = body.decision().trim();
        if (!List.of(FULL_REFUND, SPLIT_50_50, RELEASE_TO_PRO).contains(decision)) {
            throw ApiException.validation("decision", "decision FULL_REFUND, SPLIT_50_50 veya RELEASE_TO_PRO olmalı.");
        }
        String note = AdminAudit.requiredNote(body.note(), 10, 2000);
        boolean warnPro = Boolean.TRUE.equals(body.warnPro());
        boolean suspendPro = Boolean.TRUE.equals(body.suspendPro());

        Map<String, Object> row = jdbc.queryForList(
                "select job_id, customer_id, pro_id, public_code from complaints where id = ?", complaintId)
                .stream().findFirst().orElseThrow(() -> ApiException.notFound("Şikayet bulunamadı."));
        UUID jobId = (UUID) row.get("job_id");
        UUID customerId = (UUID) row.get("customer_id");
        UUID proId = (UUID) row.get("pro_id");
        String complaintCode = (String) row.get("public_code");

        Job job = jobs.lockById(jobId).orElseThrow(() -> ApiException.notFound("İş bulunamadı."));
        String status = lockComplaintStatus(complaintId);
        if (!"OPEN".equals(status) && !"IN_REVIEW".equals(status)) {
            throw ApiException.illegalState("Şikayet zaten karara bağlanmış (" + status + ").");
        }
        Trigger trigger = switch (decision) {
            case FULL_REFUND -> Trigger.ADMIN_CANCEL;
            case SPLIT_50_50 -> Trigger.ADMIN_RESOLVE;
            default -> Trigger.ADMIN_COMPLETE;
        };
        JobStateMachine.target(job.getStatus(), trigger); // iş DISPUTED değilse 409, hiçbir şeye dokunmadan

        EscrowPayment payment = escrow.lockForJob(jobId);
        if (SPLIT_50_50.equals(decision)) {
            payment.requireSplittable();
        } else {
            payment.requireRefundable();
        }
        ServiceRequest request = requests.lockById(job.getRequestId()).orElseThrow();

        // Tutarlar durum değişmeden önce hesaplanır: bildirimde ve testlerde gerçek para sonucu görünür.
        BigDecimal total = payment.getTotalAmount();
        BigDecimal customerAmount;
        BigDecimal proAmount;
        switch (decision) {
            case FULL_REFUND -> {
                customerAmount = total;
                proAmount = BigDecimal.ZERO;
            }
            case SPLIT_50_50 -> {
                customerAmount = payment.splitRefundAmount();
                proAmount = total.subtract(customerAmount);
            }
            default -> {
                customerAmount = BigDecimal.ZERO;
                proAmount = payment.getProPayout();
            }
        }

        Instant now = Instant.now();
        flow.move(job, trigger, adminId, ActorRole.ADMIN, note, now);
        switch (decision) {
            case FULL_REFUND -> {
                job.setCancelledBy(ActorRole.ADMIN);
                job.setCancelReason("COMPLAINT_FULL_REFUND");
                job.setCancelNote(note.length() > 500 ? note.substring(0, 500) : note);
                jobs.saveAndFlush(job);
                request.moveTo(RequestStatus.CANCELLED);
                request.setCancelReason(CancelReason.OTHER);
                requests.saveAndFlush(request);
            }
            case RELEASE_TO_PRO -> jdbc.update("update pro_profiles set completed_jobs = completed_jobs + 1, "
                    + "version = version + 1 where user_id = ?", proId);
            default -> {
            }
        }
        jdbc.update("""
                update complaints set status = ?, decision = ?, decision_note = ?, decided_by = ?, decided_at = ?,
                    warn_pro = ?, suspend_pro = ?, updated_at = ? where id = ?""",
                RELEASE_TO_PRO.equals(decision) ? "DISMISSED" : "RESOLVED", decision, note, adminId,
                java.sql.Timestamp.from(now), warnPro, suspendPro, java.sql.Timestamp.from(now), complaintId);
        audit.record(adminId, "DECIDE_COMPLAINT", AdminAudit.COMPLAINT, complaintId, decision + ": " + note);
        if (warnPro) {
            jdbc.update("update pro_profiles set warning_count = warning_count + 1, version = version + 1 "
                    + "where user_id = ?", proId);
            audit.record(adminId, "WARN_PRO", AdminAudit.PRO_PROFILE, proId, note);
        }
        if (suspendPro) {
            suspendProProfile(adminId, proId, note);
        }

        notifications.notify(customerId, NotificationService.COMPLAINT_DECIDED,
                decidedParams(complaintId, complaintCode, jobId, decision, customerAmount),
                "/c/complaints/" + complaintId);
        notifications.notify(proId, NotificationService.COMPLAINT_DECIDED,
                decidedParams(complaintId, complaintCode, jobId, decision, proAmount), "/p/jobs/" + jobId);

        // Para hareketi en sonda: GatewayException tüm işlemi geri alır (502), emanet ve iş değişmez.
        switch (decision) {
            case FULL_REFUND -> escrow.refundFully(payment);
            case SPLIT_50_50 -> escrow.settleSplit(payment);
            default -> escrow.release(payment);
        }
        // Ayrıntı burada kurulmaz: para hareketi gerçekleştikten sonra salt okuma bir hata (ör. imzalı URL)
        // işlemi geri alıp parayı defterden düşürmesin. Denetleyici ayrıntıyı işlem kesinleştikten sonra okur.
    }

    private static Map<String, Object> decidedParams(UUID complaintId, String code, UUID jobId, String decision,
                                                     BigDecimal amount) {
        Map<String, Object> params = new LinkedHashMap<>();
        params.put("complaintCode", code);
        params.put("decision", decision);
        params.put("amount", amount.setScale(2, RoundingMode.HALF_UP).toPlainString());
        params.put("complaintId", complaintId.toString());
        params.put("jobId", jobId.toString());
        return params;
    }

    /** Usta profili SUSPENDED olur, bekleyen teklifleri WITHDRAWN olur. Kullanıcı hesabına dokunulmaz. */
    private void suspendProProfile(UUID adminId, UUID proId, String note) {
        jdbc.update("update pro_profiles set review_status = 'SUSPENDED', review_note = ?, updated_at = now(), "
                + "version = version + 1 where user_id = ? and review_status <> 'SUSPENDED'", note, proId);
        jdbc.update("update offers set status = 'WITHDRAWN', updated_at = now(), version = version + 1 "
                + "where pro_id = ? and status = 'PENDING'", proId);
        audit.record(adminId, "SUSPEND_PRO", AdminAudit.PRO_PROFILE, proId, note);
    }

    private String lockComplaintStatus(UUID complaintId) {
        List<String> rows = jdbc.queryForList("select status from complaints where id = ? for update", String.class,
                complaintId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Şikayet bulunamadı.");
        }
        return rows.get(0);
    }

    // ─── Ayrıntı ────────────────────────────────────────────────────────────

    private ComplaintDetail buildDetail(UUID adminId, UUID complaintId) {
        ComplaintView c = feedback.get(adminId, true, complaintId);
        Map<String, Object> row = jdbc.queryForMap(
                "select customer_id, pro_id, warn_pro, suspend_pro from complaints where id = ?", complaintId);
        UUID customerId = (UUID) row.get("customer_id");
        UUID proId = (UUID) row.get("pro_id");
        Job job = jobs.findById(c.jobId()).orElseThrow();
        ServiceRequest request = requests.findById(job.getRequestId()).orElseThrow();

        JobInfo jobInfo = new JobInfo(job.getId(), request.getPublicCode(), request.getTitle(), job.getStatus(),
                job.getStatusBeforeDispute(), events.timeline(job.getId()),
                offerService.forJob(job.getOfferId(), true), requestService.districtName(request.getDistrictId()));
        PaymentInfo payment = escrows.findByJobId(job.getId())
                .map(p -> new PaymentInfo(p.getRef(), p.getStatus(), p.getProvider(), p.getTotalAmount(),
                        p.getCommission(), p.getProPayout(), p.getRefundedAmount()))
                .orElse(null);

        List<ChatMessage> messages = new ArrayList<>();
        jdbc.query("select id, sender_id, body, media_id, created_at from messages where job_id = ? order by id",
                rs -> {
                    UUID mediaId = rs.getObject("media_id", UUID.class);
                    messages.add(new ChatMessage(rs.getLong("id"),
                            customerId.equals(rs.getObject("sender_id", UUID.class)) ? "CUSTOMER" : "PRO",
                            rs.getString("body"), mediaId == null ? null : media.ref(mediaId),
                            rs.getTimestamp("created_at").toInstant()));
                }, job.getId());

        Party customer = new Party(customerId,
                jdbc.queryForObject("select full_name from users where id = ?", String.class, customerId));
        ProParty pro = jdbc.queryForObject("""
                select p.business_name, u.full_name, p.warning_count, p.cancellation_count
                from pro_profiles p join users u on u.id = p.user_id where p.user_id = ?""",
                (rs, i) -> new ProParty(proId, rs.getString("business_name"), rs.getString("full_name"),
                        rs.getInt("warning_count"), rs.getInt("cancellation_count")), proId);

        return new ComplaintDetail(c.id(), c.publicCode(), c.jobId(), c.reason(), c.description(), c.evidence(),
                c.status(), c.decision(), c.decisionNote(), c.createdAt(), c.decidedAt(),
                c.refundAmount(), c.proAmount(), Boolean.TRUE.equals(row.get("warn_pro")), Boolean.TRUE.equals(row.get("suspend_pro")), jobInfo,
                payment, messages, customer, pro);
    }
}
