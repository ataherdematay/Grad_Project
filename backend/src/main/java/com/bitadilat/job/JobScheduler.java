package com.bitadilat.job;

import com.bitadilat.notification.NotificationService;
import com.bitadilat.request.ServiceRequestRepository;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * 48 saatlik otomatik tamamlama (5 dk'da bir). WORK_FINISHED olup {@code auto_complete_at} geçmiş ve açık şikayeti
 * olmayan iş, müşteri onayıyla birebir aynı yoldan COMPLETED yapılır (eylemi yapan SYSTEM). Müşteriye 24. saatte
 * (otomatik tamamlamadan 24 saat önce) tek seferlik hatırlatma gider.
 *
 * <p>Her iş kendi işleminde {@code FOR UPDATE SKIP LOCKED} ile alınır ve kilit altında durumu yeniden kontrol edilir:
 * paralel çalışan örnekler veya kullanıcı işlemleri birbirini beklemez, tekrar çalıştırma aynı işi ikinci kez yapmaz.
 */
@Slf4j
@Component
public class JobScheduler {

    private static final int BATCH = 500;
    static final Duration REMINDER_BEFORE = Duration.ofHours(24);

    public record Result(int completed, int reminded) {
    }

    private final JdbcTemplate jdbc;
    private final TransactionTemplate tx;
    private final JobRepository jobs;
    private final JobSettlement settlement;
    private final NotificationService notifications;
    private final ServiceRequestRepository requests;

    public JobScheduler(JdbcTemplate jdbc, TransactionTemplate tx, JobRepository jobs, JobSettlement settlement,
                        NotificationService notifications, ServiceRequestRepository requests) {
        this.jdbc = jdbc;
        this.tx = tx;
        this.jobs = jobs;
        this.settlement = settlement;
        this.notifications = notifications;
        this.requests = requests;
    }

    @Scheduled(fixedDelayString = "${bitadilat.jobs.autocomplete-interval:PT5M}",
            initialDelayString = "${bitadilat.jobs.autocomplete-interval:PT5M}")
    public void scheduled() {
        try {
            Result r = run(Instant.now());
            if (r.completed() + r.reminded() > 0) {
                log.info("Otomatik tamamlama: {} iş tamamlandı, {} hatırlatma gönderildi.", r.completed(), r.reminded());
            }
        } catch (RuntimeException e) {
            log.error("Otomatik tamamlama işi başarısız", e);
        }
    }

    public Result run(Instant now) {
        int completed = 0;
        for (UUID id : dueForCompletion(now)) {
            try {
                if (Boolean.TRUE.equals(tx.execute(s -> complete(id, now)))) {
                    completed++;
                }
            } catch (RuntimeException e) {
                log.error("İş otomatik tamamlanamadı. jobId={}", id, e);
            }
        }
        int reminded = 0;
        for (UUID id : dueForReminder(now)) {
            try {
                if (Boolean.TRUE.equals(tx.execute(s -> remind(id, now)))) {
                    reminded++;
                }
            } catch (RuntimeException e) {
                log.error("Hatırlatma gönderilemedi. jobId={}", id, e);
            }
        }
        return new Result(completed, reminded);
    }

    private List<UUID> dueForCompletion(Instant now) {
        return jdbc.queryForList("""
                select j.id from jobs j
                where j.status = 'WORK_FINISHED' and j.auto_complete_at <= ?
                  and not exists (select 1 from complaints c where c.job_id = j.id and c.status in ('OPEN', 'IN_REVIEW'))
                order by j.auto_complete_at limit ?""", UUID.class, Timestamp.from(now), BATCH);
    }

    private List<UUID> dueForReminder(Instant now) {
        return jdbc.queryForList("""
                select id from jobs
                where status = 'WORK_FINISHED' and auto_complete_reminded_at is null
                  and auto_complete_at > ? and auto_complete_at <= ?
                order by auto_complete_at limit ?""", UUID.class, Timestamp.from(now),
                Timestamp.from(now.plus(REMINDER_BEFORE)), BATCH);
    }

    private boolean complete(UUID id, Instant now) {
        List<UUID> locked = jdbc.queryForList("""
                select j.id from jobs j
                where j.id = ? and j.status = 'WORK_FINISHED' and j.auto_complete_at <= ?
                  and not exists (select 1 from complaints c where c.job_id = j.id and c.status in ('OPEN', 'IN_REVIEW'))
                for update of j skip locked""", UUID.class, id, Timestamp.from(now));
        if (locked.isEmpty()) {
            return false; // başka örnek aldı, müşteri onayladı veya şikayet açıldı
        }
        Job job = jobs.findById(id).orElseThrow();
        settlement.complete(job, null, ActorRole.SYSTEM, now);
        return true;
    }

    private boolean remind(UUID id, Instant now) {
        List<UUID> locked = jdbc.queryForList("""
                select id from jobs
                where id = ? and status = 'WORK_FINISHED' and auto_complete_reminded_at is null
                  and auto_complete_at > ? for update skip locked""", UUID.class, id, Timestamp.from(now));
        if (locked.isEmpty()) {
            return false;
        }
        Job job = jobs.findById(id).orElseThrow();
        String code = requests.findById(job.getRequestId()).map(r -> r.getPublicCode()).orElse("");
        notifications.notify(job.getCustomerId(), NotificationService.AUTO_COMPLETE_REMINDER,
                Map.of("jobId", id.toString(), "publicCode", code, "autoCompleteAt", job.getAutoCompleteAt().toString()),
                "/c/jobs/" + id);
        job.setAutoCompleteRemindedAt(now);
        jobs.saveAndFlush(job);
        return true;
    }
}
