package com.bitadilat.payment.service;

import com.bitadilat.payment.domain.EscrowPayment;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Para durumu belirsiz kalmış uygulama ödemelerini toparlar (5 dk'da bir):
 * <ul>
 *   <li>30 dakikadan eski INITIALIZED kayıtlar (kullanıcı WebView'i kapattı veya callback işlenemedi): Craftgate'e
 *       sorulur: başarılıysa teklif kabul edilir (yarışta iade), başarısız veya hâlâ 3DS'te ise FAILED olur
 *       (talep serbest kalır). Craftgate yanıt vermezse dokunulmaz.</li>
 *   <li>İadesi yapılamamış öksüz LOCKED kayıtlar (iş açılmadı, hata kodu var): önce Craftgate'e iade durumu sorulur,
 *       artan aralıkla en fazla 8 deneme yapılır, sonra REFUND_NEEDS_REVIEW olur.</li>
 * </ul>
 * Her kayıt kendi işleminde ve satır kilidi altında ele alınır; tekrar çalışma zararsızdır.
 */
@Slf4j
@Component
public class PaymentSweeper {

    static final Duration STALE_AFTER = Duration.ofMinutes(30);
    private static final int BATCH = 100;

    private final JdbcTemplate jdbc;
    private final PaymentService payments;

    public PaymentSweeper(JdbcTemplate jdbc, PaymentService payments) {
        this.jdbc = jdbc;
        this.payments = payments;
    }

    @Scheduled(fixedDelayString = "${bitadilat.jobs.payment-sweep-interval:PT5M}",
            initialDelayString = "${bitadilat.jobs.payment-sweep-interval:PT5M}")
    public void scheduled() {
        try {
            run(Instant.now());
        } catch (RuntimeException e) {
            log.error("Ödeme toparlama işi başarısız", e);
        }
    }

    public void run(Instant now) {
        List<String> stale = jdbc.queryForList("""
                select ref from escrow_payment
                where status = 'INITIALIZED' and channel = 'APP' and created_at <= ?
                order by created_at limit ?""", String.class, Timestamp.from(now.minus(STALE_AFTER)), BATCH);
        for (String ref : stale) {
            try {
                payments.reconcileStale(ref);
            } catch (RuntimeException e) {
                log.error("Eski ödeme toparlanamadı. ref={}", ref, e);
            }
        }
        List<String> orphans = jdbc.queryForList("""
                select ref from escrow_payment
                where status = 'LOCKED' and channel = 'APP' and job_id is null and error_code is not null
                  and error_code <> 'REFUND_NEEDS_REVIEW' and refund_attempts < ?
                  and (next_refund_attempt_at is null or next_refund_attempt_at <= ?)
                order by coalesce(next_refund_attempt_at, created_at) limit ?""", String.class,
                EscrowPayment.MAX_REFUND_ATTEMPTS, Timestamp.from(now), BATCH);
        for (String ref : orphans) {
            try {
                payments.retryOrphanRefund(ref, now);
            } catch (RuntimeException e) {
                log.error("Öksüz ödemenin iadesi denenemedi. ref={}", ref, e);
            }
        }
    }
}
