package com.bitadilat.job;

import com.bitadilat.common.ApiException;
import com.bitadilat.job.JobStateMachine.Trigger;
import com.bitadilat.job.dto.ComplaintView;
import com.bitadilat.job.dto.JobBodies;
import com.bitadilat.job.dto.JobDetail;
import com.bitadilat.media.MediaPurpose;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.request.ServiceRequestRepository;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Müşteri geri bildirimi: değerlendirme (COMPLETED işte, bir kez) ve şikayet (iş ve emanet DISPUTED olur). */
@Service
public class JobFeedbackService {

    static final Set<String> TAGS = Set.of("ON_TIME", "CLEAN_WORK", "FAIR_PRICE", "GOOD_COMMUNICATION", "POLITE");

    private final JobRepository jobs;
    private final JobFlow flow;
    private final JobEvents events;
    private final JobQueryService views;
    private final EscrowService escrow;
    private final ServiceRequestRepository requests;
    private final NotificationService notifications;
    private final MediaService media;
    private final JdbcTemplate jdbc;

    public JobFeedbackService(JobRepository jobs, JobFlow flow, JobEvents events, JobQueryService views,
                              EscrowService escrow, ServiceRequestRepository requests,
                              NotificationService notifications, MediaService media, JdbcTemplate jdbc) {
        this.jobs = jobs;
        this.flow = flow;
        this.events = events;
        this.views = views;
        this.escrow = escrow;
        this.requests = requests;
        this.notifications = notifications;
        this.media = media;
        this.jdbc = jdbc;
    }

    // ─── Değerlendirme ──────────────────────────────────────────────────────

    @Transactional
    public JobDetail review(UUID userId, UUID jobId, JobBodies.Review b) {
        Job job = lockCustomerJob(userId, jobId);
        List<String> tags = b.tags() == null ? List.of() : b.tags().stream().distinct().toList();
        for (String tag : tags) {
            if (!TAGS.contains(tag)) {
                throw ApiException.validation("tags", "Geçersiz etiket.");
            }
        }
        String comment = b.comment() == null || b.comment().isBlank() ? null : b.comment().trim();
        if (comment != null && comment.length() > 1000) {
            throw ApiException.validation("comment", "comment en fazla 1000 karakter olmalı.");
        }
        if (job.getStatus() != JobStatus.COMPLETED) {
            throw ApiException.illegalState("Yalnızca tamamlanmış iş değerlendirilebilir.");
        }
        Integer existing = jdbc.queryForObject("select count(*) from reviews where job_id = ?", Integer.class, jobId);
        if (existing != null && existing > 0) {
            throw ApiException.illegalState("Bu iş zaten değerlendirildi.");
        }
        // Ustanın profil satırı kilitlenir: eşzamanlı iki değerlendirme ortalamayı birbirinin üzerine yazamaz.
        jdbc.queryForObject("select user_id from pro_profiles where user_id = ? for update", UUID.class,
                job.getProId());
        try {
            jdbc.update("""
                    insert into reviews (job_id, customer_id, pro_id, rating, tags, comment, is_anonymous)
                    values (?, ?, ?, ?, ?::text[], ?, ?)""",
                    jobId, userId, job.getProId(), b.rating(), "{" + String.join(",", tags) + "}", comment,
                    Boolean.TRUE.equals(b.anonymous()));
        } catch (DuplicateKeyException e) {
            throw ApiException.illegalState("Bu iş zaten değerlendirildi.");
        }
        jdbc.update("""
                update pro_profiles set
                  rating_avg = (select round(avg(rating)::numeric, 2) from reviews where pro_id = ?),
                  rating_count = (select count(*) from reviews where pro_id = ?),
                  version = version + 1
                where user_id = ?""", job.getProId(), job.getProId(), job.getProId());
        return views.detail(job, ActorRole.CUSTOMER, userId);
    }

    // ─── Şikayet ────────────────────────────────────────────────────────────

    @Transactional
    public ComplaintView complain(UUID userId, UUID jobId, JobBodies.Complaint b) {
        Job job = lockCustomerJob(userId, jobId);
        Instant now = Instant.now();
        String description = b.description().trim();
        if (description.length() < 20 || description.length() > 2000) {
            throw ApiException.validation("description", "description 20-2000 karakter olmalı.");
        }
        List<UUID> evidence = b.evidenceIds() == null ? List.of() : b.evidenceIds().stream().distinct().toList();
        JobStateMachine.target(job.getStatus(), Trigger.COMPLAIN); // SCHEDULED, ARRIVED, IN_PROGRESS, WORK_FINISHED
        media.requireAttachable(userId, evidence, MediaPurpose.COMPLAINT, "evidenceIds", MediaService.Reuse.NONE);

        EscrowPayment payment = escrow.lockForJob(jobId);
        escrow.dispute(payment);
        flow.move(job, Trigger.COMPLAIN, userId, ActorRole.CUSTOMER, b.reason().name(), now);

        String code = String.format("SK-%04d", jdbc.queryForObject("select nextval('complaint_code_seq')", Long.class));
        UUID complaintId = jdbc.queryForObject("""
                insert into complaints (public_code, job_id, customer_id, pro_id, reason, description)
                values (?, ?, ?, ?, ?, ?) returning id""", UUID.class, code, jobId, userId, job.getProId(),
                b.reason().name(), description);
        for (UUID mediaId : evidence) {
            jdbc.update("insert into complaint_evidence (complaint_id, media_id) values (?, ?)", complaintId, mediaId);
        }
        // Bekleyen randevu önerisi varsa kapanır.
        jdbc.update("update appointment_proposals set status = 'REJECTED' where job_id = ? and status = 'PENDING'",
                jobId);

        String publicCode = requests.findById(job.getRequestId()).map(r -> r.getPublicCode()).orElse("");
        Map<String, Object> params = Map.of("jobId", jobId.toString(), "complaintId", complaintId.toString(),
                "complaintCode", code, "publicCode", publicCode, "reason", b.reason().name());
        notifications.notify(job.getProId(), NotificationService.COMPLAINT_OPENED, params, "/p/jobs/" + jobId);
        for (UUID admin : jdbc.queryForList("select id from users where is_admin and status = 'ACTIVE'", UUID.class)) {
            notifications.notify(admin, NotificationService.COMPLAINT_OPENED, params, "/complaints/" + complaintId);
        }
        return complaint(complaintId);
    }

    /** Katılımcılar (müşteri, usta) ve admin görür; diğerleri 404. */
    @Transactional(readOnly = true)
    public ComplaintView get(UUID userId, boolean admin, UUID complaintId) {
        List<UUID> parties = jdbc.query("select customer_id, pro_id from complaints where id = ?",
                (rs, i) -> rs.getObject(1, UUID.class), complaintId);
        if (parties.isEmpty()) {
            throw ApiException.notFound("Şikayet bulunamadı.");
        }
        Boolean participant = jdbc.queryForObject(
                "select customer_id = ? or pro_id = ? from complaints where id = ?", Boolean.class, userId, userId,
                complaintId);
        if (!admin && !Boolean.TRUE.equals(participant)) {
            throw ApiException.notFound("Şikayet bulunamadı.");
        }
        return complaint(complaintId);
    }

    private ComplaintView complaint(UUID id) {
        List<UUID> evidence = jdbc.queryForList(
                "select media_id from complaint_evidence where complaint_id = ? order by media_id", UUID.class, id);
        return jdbc.queryForObject("""
                select id, public_code, job_id, reason, description, status, decision, decision_note, created_at,
                       decided_at
                from complaints where id = ?""", (rs, i) -> new ComplaintView(rs.getObject("id", UUID.class),
                rs.getString("public_code"), rs.getObject("job_id", UUID.class),
                ComplaintReason.valueOf(rs.getString("reason")), rs.getString("description"),
                media.refs(evidence), rs.getString("status"), rs.getString("decision"),
                rs.getString("decision_note"), rs.getTimestamp("created_at").toInstant(),
                rs.getTimestamp("decided_at") == null ? null : rs.getTimestamp("decided_at").toInstant()), id);
    }

    private Job lockCustomerJob(UUID userId, UUID jobId) {
        Job job = jobs.lockById(jobId).orElseThrow(() -> ApiException.notFound("İş bulunamadı."));
        ActorRole role = JobQueryService.roleOf(job, userId);
        if (role == null) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        if (role != ActorRole.CUSTOMER) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bu işlem müşteri içindir.");
        }
        return job;
    }
}
