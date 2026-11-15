package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.ActionView;
import com.bitadilat.admin.AdminDtos.ApplicationDetail;
import com.bitadilat.admin.AdminDtos.ApplicationList;
import com.bitadilat.admin.AdminDtos.ApplicationSummary;
import com.bitadilat.admin.AdminDtos.DocumentView;
import com.bitadilat.common.ApiException;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.pro.DocumentStatus;
import com.bitadilat.pro.DocumentType;
import com.bitadilat.pro.ProDocument;
import com.bitadilat.pro.ProDocumentRepository;
import com.bitadilat.pro.ProProfile;
import com.bitadilat.pro.ProProfileRepository;
import com.bitadilat.pro.ReviewStatus;
import java.time.Instant;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Usta başvurusu incelemesi. Karar yalnızca {@code PENDING_REVIEW} başvurusuna verilir (başka durum 409); profil satırı
 * kilitlenir, böylece aynı başvuruya eşzamanlı iki karar tek sonuç üretir. Her karar: profil + belge durumu +
 * {@code admin_actions} + usta bildirimi aynı işlemde.
 */
@Service
public class AdminApplicationService {

    private static final String SUMMARY_SQL = """
            select p.user_id, u.full_name, u.email, u.phone, p.business_name, p.review_status, p.created_at,
                   coalesce((select max(d.created_at) from pro_documents d where d.pro_id = p.user_id), p.created_at)
                       as submitted_at,
                   (select count(*) from pro_documents d where d.pro_id = p.user_id) as document_count
            from pro_profiles p join users u on u.id = p.user_id""";

    private final JdbcTemplate jdbc;
    private final ProProfileRepository profiles;
    private final ProDocumentRepository documents;
    private final MediaService media;
    private final NotificationService notifications;
    private final AdminAudit audit;

    public AdminApplicationService(JdbcTemplate jdbc, ProProfileRepository profiles, ProDocumentRepository documents,
                                   MediaService media, NotificationService notifications, AdminAudit audit) {
        this.jdbc = jdbc;
        this.profiles = profiles;
        this.documents = documents;
        this.media = media;
        this.notifications = notifications;
        this.audit = audit;
    }

    @Transactional(readOnly = true)
    public ApplicationList list(String status, String q) {
        ReviewStatus wanted = status == null || status.isBlank() ? ReviewStatus.PENDING_REVIEW
                : AdminAudit.parseEnum(ReviewStatus.class, status, "status");
        List<Object> args = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SUMMARY_SQL).append(" where p.review_status = ?");
        args.add(wanted.name());
        if (q != null && !q.isBlank()) {
            sql.append(" and (u.full_name ilike ? escape '\\' or p.business_name ilike ? escape '\\'"
                    + " or u.email ilike ? escape '\\' or u.phone ilike ? escape '\\')");
            String like = AdminAudit.likePattern(q);
            args.add(like);
            args.add(like);
            args.add(like);
            args.add(AdminAudit.likePattern(q.replaceAll("\\s+", "")));
        }
        sql.append(" order by submitted_at asc, p.user_id asc");
        List<ApplicationSummary> items = jdbc.query(sql.toString(), (rs, i) -> summary(rs), args.toArray());
        return new ApplicationList(items);
    }

    @Transactional(readOnly = true)
    public ApplicationDetail detail(UUID proId) {
        return buildDetail(proId);
    }

    @Transactional
    public ApplicationDetail approve(UUID adminId, UUID proId, String rawNote) {
        String note = AdminAudit.optionalNote(rawNote, 1000);
        ProProfile p = lockPending(proId);
        Instant now = Instant.now();
        p.setReviewStatus(ReviewStatus.APPROVED);
        p.setReviewNote(note);
        p.setApprovedAt(now);
        profiles.saveAndFlush(p);
        for (ProDocument d : documents.findByProId(proId)) {
            d.setStatus(DocumentStatus.ACCEPTED);
            d.setReviewedBy(adminId);
            d.setReviewedAt(now);
            documents.save(d);
        }
        documents.flush();
        audit.record(adminId, "APPROVE_APPLICATION", AdminAudit.PRO_PROFILE, proId, note);
        notifications.notify(proId, NotificationService.PRO_APPROVED, Map.of(), "/p/feed");
        return buildDetail(proId);
    }

    @Transactional
    public ApplicationDetail reject(UUID adminId, UUID proId, String rawNote) {
        String note = AdminAudit.requiredNote(rawNote, 10, 1000);
        ProProfile p = lockPending(proId);
        p.setReviewStatus(ReviewStatus.REJECTED);
        p.setReviewNote(note);
        profiles.saveAndFlush(p);
        audit.record(adminId, "REJECT_APPLICATION", AdminAudit.PRO_PROFILE, proId, note);
        notifications.notify(proId, NotificationService.PRO_REJECTED, Map.of("note", note), "/p/application");
        return buildDetail(proId);
    }

    /**
     * Eksik belge iste. Listelenen türlerin belgeleri {@code REJECTED} olur; başvuruda o türde belge yoksa 400
     * (ustanın yeniden yükleyeceği bir kayıt olmaz). Listede olmayan belgelere dokunulmaz.
     */
    @Transactional
    public ApplicationDetail requestDocuments(UUID adminId, UUID proId, String rawNote,
                                              List<DocumentType> requestedTypes) {
        String note = AdminAudit.requiredNote(rawNote, 10, 1000);
        if (requestedTypes == null || requestedTypes.isEmpty() || requestedTypes.stream().anyMatch(t -> t == null)) {
            throw ApiException.validation("documentTypes", "En az bir belge türü seçilmeli.");
        }
        Set<DocumentType> types = EnumSet.copyOf(requestedTypes);
        ProProfile p = lockPending(proId);
        List<ProDocument> docs = documents.findByProId(proId);
        Set<DocumentType> present = EnumSet.noneOf(DocumentType.class);
        docs.forEach(d -> present.add(d.getType()));
        if (!present.containsAll(types)) {
            throw ApiException.validation("documentTypes", "Başvuruda olmayan bir belge türü seçildi.");
        }
        Instant now = Instant.now();
        for (ProDocument d : docs) {
            if (types.contains(d.getType())) {
                d.setStatus(DocumentStatus.REJECTED);
                d.setReviewedBy(adminId);
                d.setReviewedAt(now);
                documents.save(d);
            }
        }
        documents.flush();
        p.setReviewStatus(ReviewStatus.NEEDS_DOCUMENTS);
        p.setReviewNote(note);
        profiles.saveAndFlush(p);
        audit.record(adminId, "REQUEST_DOCUMENTS", AdminAudit.PRO_PROFILE, proId, note);
        notifications.notify(proId, NotificationService.PRO_NEEDS_DOCUMENTS, Map.of("note", note), "/p/application");
        return buildDetail(proId);
    }

    // ─── Yardımcılar ────────────────────────────────────────────────────────

    private ProProfile lockPending(UUID proId) {
        ProProfile p = profiles.lockById(proId).orElseThrow(() -> ApiException.notFound("Başvuru bulunamadı."));
        if (p.getReviewStatus() != ReviewStatus.PENDING_REVIEW) {
            throw ApiException.illegalState("Başvuru " + p.getReviewStatus() + " durumunda; yalnızca PENDING_REVIEW "
                    + "başvurusu karara bağlanır.");
        }
        return p;
    }

    private ApplicationDetail buildDetail(UUID proId) {
        List<ApplicationDetail> rows = jdbc.query(SUMMARY_SQL + " where p.user_id = ?", (rs, i) -> {
            ApplicationSummary s = summary(rs);
            ProProfile p = profiles.findById(proId).orElseThrow();
            return new ApplicationDetail(s.proId(), s.fullName(), s.businessName(), s.categoryIds(),
                    s.districtNames(), s.submittedAt(), s.reviewStatus(), s.documentCount(),
                    rs.getString("email"), rs.getString("phone"), p.getBio(), p.getExperienceYears(),
                    p.getReviewNote(), documentViews(proId), history(proId));
        }, proId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("Başvuru bulunamadı.");
        }
        return rows.get(0);
    }

    private ApplicationSummary summary(java.sql.ResultSet rs) throws java.sql.SQLException {
        UUID proId = rs.getObject("user_id", UUID.class);
        List<String> categories = jdbc.queryForList(
                "select category_id from pro_categories where pro_id = ? order by category_id", String.class, proId);
        List<String> districts = jdbc.queryForList("""
                select d.name from pro_districts pd join districts d on d.id = pd.district_id
                where pd.pro_id = ? order by d.name""", String.class, proId);
        return new ApplicationSummary(proId, rs.getString("full_name"), rs.getString("business_name"), categories,
                districts, rs.getTimestamp("submitted_at").toInstant(),
                ReviewStatus.valueOf(rs.getString("review_status")), rs.getInt("document_count"));
    }

    private List<DocumentView> documentViews(UUID proId) {
        return documents.findByProIdOrderByCreatedAtAsc(proId).stream()
                .map(d -> new DocumentView(d.getId(), d.getType(), d.getStatus(), media.ref(d.getMediaId())))
                .toList();
    }

    /** Bu ustaya ait tüm admin eylemleri (başvuru kararları, şikayetten gelen uyarı/askı), yeniden eskiye. */
    private List<ActionView> history(UUID proId) {
        return jdbc.query("""
                select a.id, a.action, a.note, a.created_at, u.full_name
                from admin_actions a join users u on u.id = a.admin_id
                where a.target_type = ? and a.target_id = ?
                order by a.created_at desc, a.id desc""", (rs, i) -> new ActionView(rs.getObject("id", UUID.class),
                rs.getString("action"), rs.getString("note"), rs.getString("full_name"),
                rs.getTimestamp("created_at").toInstant()), AdminAudit.PRO_PROFILE, proId.toString());
    }
}
