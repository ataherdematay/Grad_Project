package com.bitadilat.job;

import com.bitadilat.notification.NotificationService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.request.ServiceRequestRepository;
import java.util.HashMap;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * Gecikmeli para hareketi tamamlandığında giden bildirimler (API_V1 "Follow-up contract"): ödeme toplayıcısının
 * yeniden denemesi veya admin incelemesi sonunda iade ya da ustaya aktarım yapıldığında taraflara haber verilir.
 * İptal anındaki ilk deneme başarılıysa bu bildirimler gönderilmez ({@code JOB_CANCELLED} tutarı zaten söyler).
 * Çağıranın işlemine katılır.
 */
@Component
public class EscrowNotifications {

    private final NotificationService notifications;
    private final JobRepository jobs;
    private final ServiceRequestRepository requests;

    public EscrowNotifications(NotificationService notifications, JobRepository jobs,
                               ServiceRequestRepository requests) {
        this.notifications = notifications;
        this.jobs = jobs;
        this.requests = requests;
    }

    /** Gecikmeli iade tamamlandı: müşteriye ve (iş varsa) ustaya {@code REFUND_COMPLETED}. */
    public void refundCompleted(EscrowPayment p) {
        Job job = p.getJobId() == null ? null : jobs.findById(p.getJobId()).orElse(null);
        Map<String, Object> params = new HashMap<>();
        params.put("ref", p.getRef());
        params.put("amount", p.getRefundedAmount().toPlainString());
        params.put("publicCode", publicCode(job, p));
        if (job == null) {
            if (p.getCustomerId() != null) {
                notifications.notify(p.getCustomerId(), NotificationService.REFUND_COMPLETED, params,
                        "/c/payments/" + p.getRef() + "/result");
            }
            return;
        }
        params.put("jobId", job.getId().toString());
        notifications.notify(job.getCustomerId(), NotificationService.REFUND_COMPLETED, params,
                "/c/jobs/" + job.getId());
        notifications.notify(job.getProId(), NotificationService.REFUND_COMPLETED, params, "/p/jobs/" + job.getId());
    }

    /** Gecikmeli ustaya aktarım yapıldı: ustaya {@code PAYOUT_RELEASED}, müşteriye {@code PAYOUT_COMPLETED}. */
    public void payoutCompleted(EscrowPayment p) {
        if (p.getJobId() == null) {
            return;
        }
        jobs.findById(p.getJobId()).ifPresent(job -> {
            String code = publicCode(job, p);
            notifications.notify(job.getProId(), NotificationService.PAYOUT_RELEASED,
                    Map.of("jobId", job.getId().toString(), "publicCode", code,
                            "amount", p.getProPayout().toPlainString()),
                    "/p/earnings");
            notifications.notify(job.getCustomerId(), NotificationService.PAYOUT_COMPLETED,
                    Map.of("jobId", job.getId().toString(), "publicCode", code), "/c/jobs/" + job.getId());
        });
    }

    private String publicCode(Job job, EscrowPayment p) {
        if (job == null) {
            return p.getJobRef();
        }
        return requests.findById(job.getRequestId()).map(r -> r.getPublicCode()).orElse(p.getJobRef());
    }
}
