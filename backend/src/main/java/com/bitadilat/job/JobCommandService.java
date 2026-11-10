package com.bitadilat.job;

import com.bitadilat.common.ApiException;
import com.bitadilat.job.JobStateMachine.Trigger;
import com.bitadilat.job.dto.JobBodies;
import com.bitadilat.job.dto.JobDetail;
import com.bitadilat.media.MediaPurpose;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.offer.OfferStatus;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.request.CancelReason;
import com.bitadilat.request.RequestStatus;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * İş komutları: randevu önerileri, usta aşamaları, teslim onayı ve iptal. Her komut işi {@code FOR UPDATE} ile
 * kilitler (kilit sırası: iş, emanet, talep), geçişi {@link JobFlow} üzerinden yapar ve {@code job_events}'e yazar.
 * Katılımcı olmayan 404; yanlış rolün çağırdığı usta/müşteri uç noktası 403 FORBIDDEN; yanlış durum 409 ILLEGAL_STATE.
 */
@Service
public class JobCommandService {

    static final Duration MIN_SLOT = Duration.ofHours(1);
    static final Duration MAX_SLOT = Duration.ofHours(12);
    static final Duration MAX_LEAD = Duration.ofDays(30);
    /** Usta iptalinde yeniden açılan talep en az bu kadar daha teklif almaya devam eder. */
    static final Duration REOPENED_LIFETIME = Duration.ofDays(7);

    private record Locked(Job job, ActorRole role) {
    }

    private final JobRepository jobs;
    private final AppointmentProposalRepository proposals;
    private final JobFlow flow;
    private final JobEvents events;
    private final JobQueryService views;
    private final JobSettlement settlement;
    private final EscrowService escrow;
    private final ServiceRequestRepository requests;
    private final OfferRepository offers;
    private final NotificationService notifications;
    private final MediaService media;
    private final org.springframework.jdbc.core.JdbcTemplate jdbc;

    public JobCommandService(JobRepository jobs, AppointmentProposalRepository proposals, JobFlow flow,
                             JobEvents events, JobQueryService views, JobSettlement settlement, EscrowService escrow,
                             ServiceRequestRepository requests, OfferRepository offers,
                             NotificationService notifications, MediaService media,
                             org.springframework.jdbc.core.JdbcTemplate jdbc) {
        this.jobs = jobs;
        this.proposals = proposals;
        this.flow = flow;
        this.events = events;
        this.views = views;
        this.settlement = settlement;
        this.escrow = escrow;
        this.requests = requests;
        this.offers = offers;
        this.notifications = notifications;
        this.media = media;
        this.jdbc = jdbc;
    }

    // ─── Randevu ────────────────────────────────────────────────────────────

    @Transactional
    public JobDetail propose(UUID userId, UUID jobId, JobBodies.ProposeSlot body) {
        Locked l = lock(userId, jobId);
        Job job = l.job();
        Instant now = Instant.now();
        validateSlot(body.slotFrom(), body.slotTo(), now);
        requireAppointmentPhase(job);

        // Kısmi benzersiz indeks yüzünden eski öneri, yenisi eklenmeden önce kapatılıp yazılmalıdır.
        proposals.findByJobIdAndStatus(jobId, ProposalStatus.PENDING).ifPresent(old -> {
            old.setStatus(old.getProposedBy() == l.role() ? ProposalStatus.SUPERSEDED : ProposalStatus.REJECTED);
            proposals.saveAndFlush(old);
        });
        AppointmentProposal p = new AppointmentProposal();
        p.setJobId(jobId);
        p.setProposedBy(l.role());
        p.setSlotFrom(body.slotFrom());
        p.setSlotTo(body.slotTo());
        proposals.saveAndFlush(p);
        events.record(jobId, userId, l.role(), EventType.APPOINTMENT_PROPOSED, null, null,
                body.slotFrom() + "/" + body.slotTo(), null, now);
        touch(job);
        notifyOther(job, l.role(), NotificationService.APPOINTMENT_PROPOSED,
                Map.of("jobId", jobId.toString(), "publicCode", code(job), "slotFrom", body.slotFrom().toString(),
                        "slotTo", body.slotTo().toString()));
        return views.detail(job, l.role(), userId);
    }

    @Transactional
    public JobDetail acceptProposal(UUID userId, UUID jobId, UUID proposalId) {
        Locked l = lock(userId, jobId);
        Job job = l.job();
        Instant now = Instant.now();
        AppointmentProposal p = proposals.findByIdAndJobId(proposalId, jobId)
                .orElseThrow(() -> ApiException.notFound("Öneri bulunamadı."));
        requireAppointmentPhase(job);
        if (p.getStatus() != ProposalStatus.PENDING) {
            throw ApiException.illegalState("Öneri artık bekleyen durumda değil.");
        }
        if (p.getProposedBy() == l.role()) {
            throw ApiException.illegalState("Kendi önerinizi kabul edemezsiniz.");
        }
        p.setStatus(ProposalStatus.ACCEPTED);
        proposals.saveAndFlush(p);
        job.setScheduledFrom(p.getSlotFrom());
        job.setScheduledTo(p.getSlotTo());
        events.record(jobId, userId, l.role(), EventType.APPOINTMENT_ACCEPTED, null, null,
                p.getSlotFrom() + "/" + p.getSlotTo(), null, now);
        if (job.getStatus() == JobStatus.AWAITING_APPOINTMENT) {
            flow.move(job, Trigger.ACCEPT_APPOINTMENT, userId, l.role(), null, now);
        } else {
            touch(job); // SCHEDULED iken yalnızca yeniden planlama
        }
        notifications.notify(otherParty(job, l.role()), NotificationService.APPOINTMENT_ACCEPTED,
                Map.of("jobId", jobId.toString(), "publicCode", code(job), "slotFrom", p.getSlotFrom().toString(),
                        "slotTo", p.getSlotTo().toString()),
                route(job, l.role() == ActorRole.CUSTOMER ? ActorRole.PRO : ActorRole.CUSTOMER));
        return views.detail(job, l.role(), userId);
    }

    // ─── Usta aşamaları ─────────────────────────────────────────────────────

    @Transactional
    public JobDetail arrived(UUID userId, UUID jobId) {
        return stage(userId, jobId, Trigger.ARRIVE, "ARRIVED");
    }

    @Transactional
    public JobDetail start(UUID userId, UUID jobId) {
        return stage(userId, jobId, Trigger.START, "IN_PROGRESS");
    }

    private JobDetail stage(UUID userId, UUID jobId, Trigger trigger, String stage) {
        Locked l = lock(userId, jobId);
        requireRole(l, ActorRole.PRO);
        Job job = l.job();
        flow.move(job, trigger, userId, ActorRole.PRO, null, Instant.now());
        if (trigger == Trigger.ARRIVE) {
            closePendingProposal(jobId);
        }
        notifyCustomerStage(job, stage);
        return views.detail(job, ActorRole.PRO, userId);
    }

    @Transactional
    public JobDetail finish(UUID userId, UUID jobId, JobBodies.Finish body) {
        Locked l = lock(userId, jobId);
        requireRole(l, ActorRole.PRO);
        Job job = l.job();
        Instant now = Instant.now();
        String note = body.note().trim();
        if (note.length() < 10 || note.length() > 1000) {
            throw ApiException.validation("note", "note 10-1000 karakter olmalı.");
        }
        List<UUID> photos = distinct(body.photoIds());
        JobStateMachine.target(job.getStatus(), Trigger.FINISH); // geçersiz durumda medyayı sorgulamadan 409
        media.requireAttachable(userId, photos, MediaPurpose.JOB_PHOTO, "photoIds", MediaService.Reuse.NONE);
        flow.move(job, Trigger.FINISH, userId, ActorRole.PRO, note, now);
        for (UUID photo : photos) {
            events.record(jobId, userId, ActorRole.PRO, EventType.PHOTO, null, null, null, photo, now);
        }
        notifications.notify(job.getCustomerId(), NotificationService.WORK_FINISHED,
                Map.of("jobId", jobId.toString(), "publicCode", code(job),
                        "autoCompleteAt", job.getAutoCompleteAt().toString()),
                route(job, ActorRole.CUSTOMER));
        return views.detail(job, ActorRole.PRO, userId);
    }

    @Transactional
    public JobDetail addEvent(UUID userId, UUID jobId, JobBodies.AddEvent body) {
        Locked l = lock(userId, jobId);
        requireRole(l, ActorRole.PRO);
        Job job = l.job();
        Instant now = Instant.now();
        String note = body.note() == null || body.note().isBlank() ? null : body.note().trim();
        List<UUID> photos = distinct(body.photoIds());
        if (note == null && photos.isEmpty()) {
            throw ApiException.validation("note", "Not veya fotoğraf gerekli.");
        }
        if (note != null && note.length() > 1000) {
            throw ApiException.validation("note", "note en fazla 1000 karakter olmalı.");
        }
        if (job.getStatus() != JobStatus.ARRIVED && job.getStatus() != JobStatus.IN_PROGRESS) {
            throw ApiException.illegalState("İş " + job.getStatus() + " durumunda not eklenemez.");
        }
        media.requireAttachable(userId, photos, MediaPurpose.JOB_PHOTO, "photoIds", MediaService.Reuse.NONE);
        if (note != null) {
            events.record(jobId, userId, ActorRole.PRO, EventType.NOTE, null, null, note, null, now);
        }
        for (UUID photo : photos) {
            events.record(jobId, userId, ActorRole.PRO, EventType.PHOTO, null, null, null, photo, now);
        }
        touch(job);
        notifyCustomerStage(job, note != null ? "NOTE" : "PHOTO");
        return views.detail(job, ActorRole.PRO, userId);
    }

    // ─── Teslim onayı ───────────────────────────────────────────────────────

    @Transactional
    public JobDetail confirm(UUID userId, UUID jobId) {
        Locked l = lock(userId, jobId);
        requireRole(l, ActorRole.CUSTOMER);
        settlement.complete(l.job(), userId, ActorRole.CUSTOMER, Instant.now());
        return views.detail(l.job(), ActorRole.CUSTOMER, userId);
    }

    // ─── İptal ──────────────────────────────────────────────────────────────

    /**
     * İptal: tam iade + iş CANCELLED. Müşteri iptalinde talep CANCELLED; usta iptalinde talep yeniden OPEN, kabul edilen
     * teklif WITHDRAWN, süresi dolmamış SUPERSEDED teklifler PENDING ve ustanın iptal sayacı artar. İade (Craftgate)
     * en sonda yapılır; başarısız olursa 502 döner ve işlem tümüyle geri alınır.
     */
    @Transactional
    public JobDetail cancel(UUID userId, UUID jobId, JobBodies.Cancel body) {
        Locked l = lock(userId, jobId);
        Job job = l.job();
        Instant now = Instant.now();
        if (!body.reason().allowedFor(l.role())) {
            throw ApiException.validation("reason", "Bu gerekçe " + l.role() + " için geçerli değil.");
        }
        JobStateMachine.target(job.getStatus(), Trigger.CANCEL);
        String note = body.note() == null || body.note().isBlank() ? null : body.note().trim();

        EscrowPayment payment = escrow.lockForJob(jobId); // iş, ardından emanet
        payment.requireRefundable();
        ServiceRequest request = requests.lockById(job.getRequestId()).orElseThrow(); // sonra talep

        flow.move(job, Trigger.CANCEL, userId, l.role(), body.reason().name() + (note == null ? "" : ": " + note), now);
        job.setCancelledBy(l.role());
        job.setCancelReason(body.reason().name());
        job.setCancelNote(note);
        jobs.saveAndFlush(job);
        closePendingProposal(jobId);

        if (l.role() == ActorRole.CUSTOMER) {
            request.moveTo(RequestStatus.CANCELLED);
            request.setCancelReason(customerCancelReason(body.reason()));
            request.setCancelNote(note);
        } else {
            reopenRequest(request, job, now);
            jdbc.update("update pro_profiles set cancellation_count = cancellation_count + 1, version = version + 1 "
                    + "where user_id = ?", job.getProId());
        }
        requests.saveAndFlush(request);

        escrow.refundFully(payment); // Craftgate hatası burada GatewayException: her şey geri alınır (502)

        notifyOther(job, l.role(), NotificationService.JOB_CANCELLED,
                Map.of("jobId", jobId.toString(), "publicCode", request.getPublicCode(),
                        "cancelledBy", l.role().name(), "reason", body.reason().name()));
        return views.detail(job, l.role(), userId);
    }

    private void reopenRequest(ServiceRequest request, Job job, Instant now) {
        request.moveTo(RequestStatus.OPEN);
        Instant minimum = now.plus(REOPENED_LIFETIME);
        if (request.getExpiresAt().isBefore(minimum)) {
            request.setExpiresAt(minimum);
        }
        Offer accepted = offers.findById(job.getOfferId()).orElseThrow();
        accepted.moveTo(OfferStatus.WITHDRAWN);
        offers.saveAndFlush(accepted);
        // Kabul anında SUPERSEDED yapılan teklifler süresi dolmadıysa geri döner (ustanın yeni PENDING teklifi yoksa).
        for (Offer o : offers.findByRequestIdAndStatus(request.getId(), OfferStatus.SUPERSEDED)) {
            boolean stillValid = o.getValidUntil().isAfter(now);
            boolean hasPending = offers.findByRequestIdAndProIdAndStatus(request.getId(), o.getProId(),
                    OfferStatus.PENDING).isPresent();
            if (stillValid && !hasPending) {
                o.moveTo(OfferStatus.PENDING);
                offers.saveAndFlush(o);
            }
        }
    }

    private static CancelReason customerCancelReason(JobCancelReason reason) {
        return switch (reason) {
            case PLANS_CHANGED -> CancelReason.PLANS_CHANGED;
            case SOLVED -> CancelReason.SOLVED;
            default -> CancelReason.OTHER;
        };
    }

    // ─── Ortak ──────────────────────────────────────────────────────────────

    private Locked lock(UUID userId, UUID jobId) {
        Job job = jobs.lockById(jobId).orElseThrow(() -> ApiException.notFound("İş bulunamadı."));
        ActorRole role = JobQueryService.roleOf(job, userId);
        if (role == null) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        return new Locked(job, role);
    }

    private static void requireRole(Locked l, ActorRole required) {
        if (l.role() != required) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bu işlem " + required + " içindir.");
        }
    }

    private static void requireAppointmentPhase(Job job) {
        if (job.getStatus() != JobStatus.AWAITING_APPOINTMENT && job.getStatus() != JobStatus.SCHEDULED) {
            throw ApiException.illegalState("İş " + job.getStatus() + " durumunda randevu değiştirilemez.");
        }
    }

    private static void validateSlot(Instant from, Instant to, Instant now) {
        if (!from.isAfter(now)) {
            throw ApiException.validation("slotFrom", "Başlangıç gelecekte olmalı.");
        }
        Duration window = Duration.between(from, to);
        if (window.compareTo(MIN_SLOT) < 0 || window.compareTo(MAX_SLOT) > 0) {
            throw ApiException.validation("slotTo", "Aralık 1 ile 12 saat arasında olmalı.");
        }
        if (to.isAfter(now.plus(MAX_LEAD))) {
            throw ApiException.validation("slotTo", "Randevu en fazla 30 gün sonra olabilir.");
        }
    }

    private void closePendingProposal(UUID jobId) {
        proposals.findByJobIdAndStatus(jobId, ProposalStatus.PENDING).ifPresent(p -> {
            p.setStatus(ProposalStatus.REJECTED);
            proposals.saveAndFlush(p);
        });
    }

    /** İş satırı değişmese de "son hareket" zamanı güncellensin (liste sırası). */
    private void touch(Job job) {
        job.setUpdatedAt(Instant.now());
        jobs.saveAndFlush(job);
    }

    private void notifyCustomerStage(Job job, String stage) {
        notifications.notify(job.getCustomerId(), NotificationService.JOB_STAGE_UPDATED,
                Map.of("jobId", job.getId().toString(), "publicCode", code(job), "stage", stage),
                route(job, ActorRole.CUSTOMER));
    }

    private void notifyOther(Job job, ActorRole actor, String type, Map<String, Object> params) {
        ActorRole target = actor == ActorRole.CUSTOMER ? ActorRole.PRO : ActorRole.CUSTOMER;
        notifications.notify(otherParty(job, actor), type, params, route(job, target));
    }

    private static UUID otherParty(Job job, ActorRole actor) {
        return actor == ActorRole.CUSTOMER ? job.getProId() : job.getCustomerId();
    }

    private static String route(Job job, ActorRole recipient) {
        return (recipient == ActorRole.CUSTOMER ? "/c/jobs/" : "/p/jobs/") + job.getId();
    }

    private String code(Job job) {
        return requests.findById(job.getRequestId()).map(ServiceRequest::getPublicCode).orElse("");
    }

    private static List<UUID> distinct(List<UUID> ids) {
        return ids == null ? List.of() : ids.stream().distinct().toList();
    }
}
