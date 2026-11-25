package com.bitadilat.job;

import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowPendingAction;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.service.EscrowService;
import java.time.Instant;
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
    private final EscrowNotifications notifications;

    public PendingEscrowActions(EscrowPaymentRepository repository, EscrowService escrow,
                                EscrowNotifications notifications) {
        this.repository = repository;
        this.escrow = escrow;
        this.notifications = notifications;
    }

    /**
     * Ödeme toplayıcısının yeniden denemesi. Satır kilitliyse, niyet yoksa, elle incelemedeyse veya bekleme süresi
     * dolmadıysa dokunmaz. Tamamlanan hareket gecikmeli sayılır: iade için {@code REFUND_COMPLETED}, aktarım için
     * {@code PAYOUT_RELEASED} + {@code PAYOUT_COMPLETED} gider.
     */
    @Transactional
    public void process(String ref, Instant now) {
        run(ref, now, true);
    }

    /**
     * İptal işlemi kesinleştikten hemen sonraki ilk iade denemesi. Başarılıysa ek bildirim gitmez: {@code JOB_CANCELLED}
     * iade tutarını zaten bildirir.
     */
    @Transactional
    public void processAfterCommit(String ref, Instant now) {
        run(ref, now, false);
    }

    private void run(String ref, Instant now, boolean delayed) {
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
            case REFUND -> {
                if (escrow.refundPending(p, now) && delayed) {
                    notifications.refundCompleted(p);
                }
            }
            case RELEASE -> {
                if (escrow.releaseChecked(p, now) == EscrowService.ReleaseOutcome.RELEASED) {
                    notifications.payoutCompleted(p);
                    log.info("Bekleyen ustaya aktarım yapıldı. ref={}", p.getRef());
                }
            }
        }
    }
}
