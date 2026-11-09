package com.bitadilat.request;

import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferLifecycle;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.offer.OfferStatus;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Süre dolumu zamanlayıcısı (5 dk): süresi geçen OPEN talepler EXPIRED (PENDING teklifleri de EXPIRED), süresi geçen
 * PENDING teklifler EXPIRED. Satırlar {@code FOR UPDATE SKIP LOCKED} ile alınır; paralel çalışan örnekler veya
 * kullanıcı işlemleri birbirini beklemez. Durum geçişleri yine durum sınıfları üzerinden yapılır.
 */
@Slf4j
@Component
public class ExpiryJob {

    private static final int BATCH = 100;

    public record Result(int requests, int offers) {
    }

    private final JdbcTemplate jdbc;
    private final TransactionTemplate tx;
    private final ServiceRequestRepository requests;
    private final OfferRepository offers;
    private final OfferLifecycle lifecycle;

    public ExpiryJob(JdbcTemplate jdbc, TransactionTemplate tx, ServiceRequestRepository requests,
                     OfferRepository offers, OfferLifecycle lifecycle) {
        this.jdbc = jdbc;
        this.tx = tx;
        this.requests = requests;
        this.offers = offers;
        this.lifecycle = lifecycle;
    }

    @Scheduled(fixedDelayString = "${bitadilat.jobs.expiry-interval:PT5M}",
            initialDelayString = "${bitadilat.jobs.expiry-interval:PT5M}")
    public void scheduled() {
        try {
            Result r = run(Instant.now());
            if (r.requests() + r.offers() > 0) {
                log.info("Süre dolumu: {} talep, {} teklif EXPIRED yapıldı.", r.requests(), r.offers());
            }
        } catch (RuntimeException e) {
            log.error("Süre dolumu işi başarısız", e);
        }
    }

    public Result run(Instant now) {
        int reqCount = 0;
        int offerCount = 0;
        Integer n;
        while ((n = tx.execute(s -> expireRequests(now))) != null && n > 0) {
            reqCount += n;
        }
        while ((n = tx.execute(s -> expireOffers(now))) != null && n > 0) {
            offerCount += n;
        }
        return new Result(reqCount, offerCount);
    }

    private int expireRequests(Instant now) {
        List<UUID> ids = jdbc.queryForList("""
                select id from service_requests where status = 'OPEN' and expires_at <= ?
                order by expires_at limit ? for update skip locked""", UUID.class, java.sql.Timestamp.from(now), BATCH);
        for (UUID id : ids) {
            ServiceRequest r = requests.findById(id).orElseThrow();
            r.moveTo(RequestStatus.EXPIRED);
            lifecycle.expirePendingOf(id);
            requests.save(r);
        }
        requests.flush();
        return ids.size();
    }

    private int expireOffers(Instant now) {
        // Talep satırı da kilitlenir: kullanıcı işlemleri (iptal, düzenleme, ret, geri çekme, teklif verme) önce talebi
        // kilitler; o sırada zamanlayıcı aynı teklife dokunursa kullanıcı işleminin güncellemesi sürüm çakışmasına düşer.
        List<UUID> ids = jdbc.queryForList("""
                select o.id from offers o join service_requests r on r.id = o.request_id
                where o.status = 'PENDING' and o.valid_until <= ?
                order by o.valid_until limit ? for update of o, r skip locked""",
                UUID.class, java.sql.Timestamp.from(now), BATCH);
        for (UUID id : ids) {
            Offer o = offers.findById(id).orElseThrow();
            o.moveTo(OfferStatus.EXPIRED);
            offers.save(o);
        }
        offers.flush();
        return ids.size();
    }
}
