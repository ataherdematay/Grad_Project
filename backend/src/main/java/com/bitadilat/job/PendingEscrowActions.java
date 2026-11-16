package com.bitadilat.job;

import com.bitadilat.notification.NotificationService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowPendingAction;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.request.ServiceRequestRepository;
import java.time.Instant;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Kaydedilmiş para hareketi niyetlerini (outbox, {@code escrow_payment.pending_action}) Craftgate'te yürütür: iş
 * iptalinin tam iadesi (REFUND) ve Craftgate'e sorulamadığı için bekleyen ustaya aktarım (RELEASE). İptal komutu
 * işlemi kesinleştikten hemen sonra bir kez çağırır; başarısızlık ve çökmeler ödeme toplayıcısının yeniden denemesiyle
 * kapanır. Her çağrı kendi işlemindedir ve satırı {@code SKIP LOCKED} ile alır: aynı niyet aynı anda iki kez
 * yürütülmez, tekrar çağrı zararsızdır (iade öncesi Craftgate'e iade edilmiş tutar sorulur).
 */
@Slf4j
@Component
public class PendingEscrowActions {

    private final EscrowPaymentRepository repository;
    private final EscrowService escrow;
    private final NotificationService notifications;
    private final JobRepository jobs;
    private final ServiceRequestRepository requests;

    public PendingEscrowActions(EscrowPaymentRepository repository, EscrowService escrow,
                                NotificationService notifications, JobRepository jobs,
                                ServiceRequestRepository requests) {
        this.repository = repository;
        this.escrow = escrow;
        this.notifications = notifications;
        this.jobs = jobs;
        this.requests = requests;
    }

    /** Niyeti bir kez dener. Satır kilitliyse, niyet yoksa, elle incelemedeyse veya bekleme süresi dolmadıysa dokunmaz. */
    @Transactional
    public void process(String ref, Instant now) {
        EscrowPayment p = repository.findForUpdateSkipLocked(ref).orElse(null);
        if (p == null || p.getPendingAction() == null || p.needsReview()
                || (p.getStatus() != EscrowStatus.LOCKED && p.getStatus() != EscrowStatus.DISPUTED)
                // Şikayetteki emanet ustaya kendiliğinden aktarılmaz; kararı admin verir.
                || (p.getPendingAction() == EscrowPendingAction.RELEASE && p.getStatus() != EscrowStatus.LOCKED)
                || p.getRefundAttempts() >= EscrowPayment.MAX_REFUND_ATTEMPTS
                || (p.getNextRefundAttemptAt() != null && p.getNextRefundAttemptAt().isAfter(now))) {
            return;
        }
        switch (p.getPendingAction()) {
            case REFUND -> escrow.refundPending(p, now);
            case RELEASE -> {
                if (escrow.releaseChecked(p, now) == EscrowService.ReleaseOutcome.RELEASED) {
                    notifyPayout(p);
                }
            }
        }
    }

    private void notifyPayout(EscrowPayment p) {
        if (p.getJobId() == null) {
            return;
        }
        jobs.findById(p.getJobId()).ifPresent(job -> {
            String code = requests.findById(job.getRequestId()).map(r -> r.getPublicCode()).orElse("");
            notifications.notify(job.getProId(), NotificationService.PAYOUT_RELEASED,
                    Map.of("jobId", job.getId().toString(), "publicCode", code,
                            "amount", p.getProPayout().toPlainString()),
                    "/p/earnings");
            log.info("Bekleyen ustaya aktarım yapıldı. ref={}", p.getRef());
        });
    }
}
