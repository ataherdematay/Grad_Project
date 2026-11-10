package com.bitadilat.job;

import com.bitadilat.notification.NotificationService;
import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.offer.OfferStatus;
import com.bitadilat.request.RequestStatus;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Teklif kabulü ve iş açılışı. Banka dönüşünün (ödeme LOCKED) kendi işleminde çağrılır: talep satırı
 * {@code FOR UPDATE} ile kilitlenir, talep hâlâ OPEN ve teklif hâlâ PENDING (süresi dolmamış) ise tek işlemde
 * teklif ACCEPTED, diğerleri SUPERSEDED, talep ASSIGNED ve iş AWAITING_APPOINTMENT olur.
 */
@Component
public class JobOpening {

    public static final String REQUEST_ALREADY_ASSIGNED = "REQUEST_ALREADY_ASSIGNED";
    public static final String OFFER_EXPIRED = "OFFER_EXPIRED";

    /** Başarıysa {@code job} dolu; değilse {@code errorCode} REQUEST_ALREADY_ASSIGNED veya OFFER_EXPIRED. */
    public record Result(Job job, String errorCode) {
        public boolean opened() {
            return job != null;
        }
    }

    private final ServiceRequestRepository requests;
    private final OfferRepository offers;
    private final JobRepository jobs;
    private final JobEvents events;
    private final NotificationService notifications;

    public JobOpening(ServiceRequestRepository requests, OfferRepository offers, JobRepository jobs, JobEvents events,
                      NotificationService notifications) {
        this.requests = requests;
        this.offers = offers;
        this.jobs = jobs;
        this.events = events;
        this.notifications = notifications;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public Result open(UUID requestId, UUID offerId, UUID customerId) {
        Instant now = Instant.now();
        Optional<ServiceRequest> locked = requests.lockById(requestId);
        if (locked.isEmpty() || !locked.get().getCustomerId().equals(customerId)) {
            return new Result(null, OFFER_EXPIRED);
        }
        ServiceRequest request = locked.get();
        Optional<Offer> found = offers.findById(offerId).filter(o -> o.getRequestId().equals(requestId));
        if (found.isEmpty()) {
            return new Result(null, OFFER_EXPIRED);
        }
        Offer offer = found.get();
        if (request.getStatus() == RequestStatus.ASSIGNED || offer.getStatus() == OfferStatus.SUPERSEDED
                || offer.getStatus() == OfferStatus.ACCEPTED) {
            return new Result(null, REQUEST_ALREADY_ASSIGNED);
        }
        if (!request.isOpenAt(now) || offer.getStatus() != OfferStatus.PENDING
                || !offer.getValidUntil().isAfter(now)) {
            return new Result(null, OFFER_EXPIRED);
        }

        offer.moveTo(OfferStatus.ACCEPTED);
        offers.saveAndFlush(offer);
        List<Offer> others = offers.findByRequestIdAndStatus(requestId, OfferStatus.PENDING);
        for (Offer other : others) {
            other.moveTo(OfferStatus.SUPERSEDED);
            offers.save(other);
            notifications.notify(other.getProId(), NotificationService.OFFER_SUPERSEDED,
                    Map.of("offerId", other.getId().toString(), "requestId", requestId.toString(),
                            "publicCode", request.getPublicCode()),
                    "/p/offers");
        }
        offers.flush();
        request.moveTo(RequestStatus.ASSIGNED);
        requests.saveAndFlush(request);

        Job job = new Job();
        job.setRequestId(requestId);
        job.setOfferId(offerId);
        job.setCustomerId(customerId);
        job.setProId(offer.getProId());
        job = jobs.saveAndFlush(job);
        events.record(job.getId(), customerId, ActorRole.CUSTOMER, EventType.STATUS_CHANGED, null,
                JobStatus.AWAITING_APPOINTMENT, null, null, now);

        notifications.notify(offer.getProId(), NotificationService.OFFER_ACCEPTED,
                Map.of("offerId", offerId.toString(), "jobId", job.getId().toString(),
                        "requestId", requestId.toString(), "publicCode", request.getPublicCode(),
                        "totalAmount", offer.getTotalAmount().toPlainString()),
                "/p/jobs/" + job.getId());
        return new Result(job, null);
    }
}
