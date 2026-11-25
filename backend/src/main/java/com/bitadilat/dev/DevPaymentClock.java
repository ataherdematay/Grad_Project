package com.bitadilat.dev;

import com.bitadilat.common.ApiException;
import com.bitadilat.job.JobScheduler;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.dto.PaymentDemoDtos.FastForwardResult;
import com.bitadilat.payment.service.PaymentTimelineService;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * İşin {@code auto_complete_at} zamanını şimdiye çeker ve otomatik tamamlamayı hemen çalıştırır. Aktarım normal
 * yoldan gider ({@code JobScheduler -> JobSettlement -> EscrowService.releaseChecked}): Craftgate'te iade kontrolü,
 * {@code PAYOUT_NEEDS_REVIEW} ve bekleyen aktarım (outbox) güvenceleri aynen geçerlidir; hiçbiri atlanmaz.
 */
@Slf4j
@Service
@Profile("dev")
public class DevPaymentClock {

    private final JdbcTemplate jdbc;
    private final JobScheduler scheduler;
    private final EscrowPaymentRepository escrows;

    public DevPaymentClock(JdbcTemplate jdbc, JobScheduler scheduler, EscrowPaymentRepository escrows) {
        this.jdbc = jdbc;
        this.scheduler = scheduler;
        this.escrows = escrows;
    }

    public FastForwardResult fastForward(UUID userId, boolean admin, UUID jobId) {
        List<Map<String, Object>> rows = jdbc.queryForList(
                "select customer_id, pro_id, status from jobs where id = ?", jobId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        Map<String, Object> job = rows.get(0);
        if (!admin && !userId.equals(job.get("customer_id")) && !userId.equals(job.get("pro_id"))) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        if (!"WORK_FINISHED".equals(job.get("status"))) {
            throw ApiException.illegalState("Demo saati yalnızca teslim edilmiş (WORK_FINISHED) işte kullanılabilir.");
        }
        Integer open = jdbc.queryForObject(
                "select count(*) from complaints where job_id = ? and status in ('OPEN', 'IN_REVIEW')", Integer.class,
                jobId);
        if (open != null && open > 0) {
            throw ApiException.illegalState("Açık şikayeti olan işte otomatik aktarım yapılmaz.");
        }
        Instant now = Instant.now();
        jdbc.update("update jobs set auto_complete_at = ? where id = ?", Timestamp.from(now.minusSeconds(1)), jobId);
        boolean completed = scheduler.completeOne(jobId, now);
        log.info("Demo saati: otomatik tamamlama tetiklendi. jobId={} tamamlandı={}", jobId, completed);
        String status = jdbc.queryForObject("select status from jobs where id = ?", String.class, jobId);
        EscrowPayment p = escrows.findByJobId(jobId)
                .orElseThrow(() -> ApiException.notFound("Bu işin ödeme kaydı bulunamadı."));
        return new FastForwardResult(jobId, status, p.getStatus(), PaymentTimelineService.locationOf(p.getStatus()),
                p.getStatus() == EscrowStatus.RELEASED_TO_PRO, p.getPendingAction(), p.getErrorCode());
    }
}
