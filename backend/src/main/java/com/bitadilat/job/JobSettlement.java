package com.bitadilat.job;

import com.bitadilat.job.JobStateMachine.Trigger;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.request.ServiceRequestRepository;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Teslimin onaylanması: müşteri onayı ve 48 saatlik otomatik tamamlama aynı yoldan geçer. İş COMPLETED, emanet
 * RELEASED_TO_PRO olur, PAYOUT ve COMMISSION defter satırları yazılır, ustanın tamamlanan iş sayısı artar ve usta
 * bilgilendirilir.
 */
@Component
public class JobSettlement {

    private final EscrowService escrow;
    private final JobFlow flow;
    private final NotificationService notifications;
    private final ServiceRequestRepository requests;
    private final JdbcTemplate jdbc;

    public JobSettlement(EscrowService escrow, JobFlow flow, NotificationService notifications,
                         ServiceRequestRepository requests, JdbcTemplate jdbc) {
        this.escrow = escrow;
        this.flow = flow;
        this.notifications = notifications;
        this.requests = requests;
        this.jdbc = jdbc;
    }

    /** Çağıran işi kilitlemiş olmalı. İş WORK_FINISHED değilse 409 ILLEGAL_STATE. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void complete(Job job, UUID actorId, ActorRole actorRole, Instant now) {
        JobStateMachine.target(job.getStatus(), Trigger.CONFIRM); // emanete dokunmadan önce geçişi doğrula
        EscrowPayment payment = escrow.lockForJob(job.getId());
        flow.move(job, Trigger.CONFIRM, actorId, actorRole, null, now);
        escrow.release(payment);
        // Atomik artış: aynı ustanın başka bir işi aynı anda tamamlansa bile sürüm çakışması olmaz.
        jdbc.update("update pro_profiles set completed_jobs = completed_jobs + 1, version = version + 1 "
                + "where user_id = ?", job.getProId());
        String code = requests.findById(job.getRequestId()).map(r -> r.getPublicCode()).orElse("");
        notifications.notify(job.getProId(), NotificationService.PAYOUT_RELEASED,
                Map.of("jobId", job.getId().toString(), "publicCode", code,
                        "amount", payment.getProPayout().toPlainString()),
                "/p/earnings");
    }
}
