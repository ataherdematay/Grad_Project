package com.bitadilat.pro;

import com.bitadilat.common.ApiException;
import com.bitadilat.common.Paging;
import com.bitadilat.media.MediaService;
import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.offer.OfferService;
import com.bitadilat.offer.OfferStatus;
import com.bitadilat.pro.dto.FeedItem;
import com.bitadilat.pro.dto.FeedList;
import com.bitadilat.pro.dto.ProRequestDetail;
import com.bitadilat.request.RequestParts;
import com.bitadilat.request.RequestService;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import com.bitadilat.request.Urgency;
import com.bitadilat.request.dto.RequestSummary;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Ustanın talep akışı ve talep ayrıntısı. Adres hiçbir zaman ilçe + mahalleden ayrıntılı verilmez. */
@Service
public class ProFeedService {

    private final ProAccess access;
    private final ProCategoryRepository proCategories;
    private final ProDistrictRepository proDistricts;
    private final ServiceRequestRepository requests;
    private final OfferRepository offers;
    private final OfferService offerService;
    private final RequestService requestService;
    private final RequestParts parts;
    private final MediaService media;

    public ProFeedService(ProAccess access, ProCategoryRepository proCategories, ProDistrictRepository proDistricts,
                          ServiceRequestRepository requests, OfferRepository offers, OfferService offerService,
                          RequestService requestService, RequestParts parts, MediaService media) {
        this.access = access;
        this.proCategories = proCategories;
        this.proDistricts = proDistricts;
        this.requests = requests;
        this.offers = offers;
        this.offerService = offerService;
        this.requestService = requestService;
        this.parts = parts;
        this.media = media;
    }

    @Transactional(readOnly = true)
    public FeedList feed(UUID proId, String urgencyRaw, String cursor, Integer limit) {
        ProProfile pro = access.requireApproved(proId);
        Urgency urgency = null;
        if (urgencyRaw != null && !urgencyRaw.isBlank()) {
            try {
                urgency = Urgency.valueOf(urgencyRaw.trim());
            } catch (IllegalArgumentException e) {
                throw ApiException.validation("urgency", "urgency URGENT veya PLANNED olmalı.");
            }
        }
        if (pro.getAvailability() == Availability.ON_BREAK) {
            return new FeedList(List.of(), true, null);
        }
        List<String> cats = proCategories.findByProId(proId).stream().map(ProCategory::getCategoryId).toList();
        List<Integer> dists = proDistricts.findByProId(proId).stream().map(ProDistrict::getDistrictId).toList();
        if (cats.isEmpty() || dists.isEmpty()) {
            return new FeedList(List.of(), false, null);
        }
        Instant now = Instant.now();
        final Urgency filter = urgency;
        List<ServiceRequest> matching = requests.feed(now, proId, cats, dists).stream()
                .filter(r -> filter == null || r.getUrgency() == filter).toList();
        Paging.Slice<ServiceRequest> page = Paging.slice(matching, cursor, limit);
        return new FeedList(items(proId, page.items(), now), false, page.nextCursor());
    }

    @Transactional(readOnly = true)
    public ProRequestDetail detail(UUID proId, UUID requestId) {
        access.requireApproved(proId);
        ServiceRequest r = requests.findById(requestId).orElseThrow(() -> ApiException.notFound("Talep bulunamadı."));
        Instant now = Instant.now();
        // ROLE_SCREEN_MAP: talep ayrıntısı ve fotoğrafları yalnız OPEN iken eşleşen onaylı ustalara. Bekleyen teklifi
        // olan usta (sonradan ilçe/kategori değiştirse de) talep açıkken görmeye devam eder; talep kapanınca kimse.
        boolean hasPending = !r.getCustomerId().equals(proId) && offerService.pendingOf(proId, requestId, now).isPresent();
        boolean visible = r.isOpenAt(now) && (access.matches(proId, r) || hasPending);
        if (!visible) {
            throw ApiException.notFound("Talep bulunamadı.");
        }
        FeedItem f = items(proId, List.of(r), now).get(0);
        var myOffer = offerService.pendingOf(proId, requestId, now).map(offerService::proView).orElse(null);
        return new ProRequestDetail(f.id(), f.publicCode(), f.title(), f.categoryId(), f.urgency(), f.districtName(),
                f.neighborhood(), f.createdAt(), f.preferredFrom(), f.preferredTo(), f.photoCount(), f.offerCount(),
                f.myOfferId(), r.getDescription(), media.refs(parts.photoIds(requestId)), parts.answers(requestId),
                myOffer);
    }

    private List<FeedItem> items(UUID proId, List<ServiceRequest> list, Instant now) {
        if (list.isEmpty()) {
            return List.of();
        }
        List<UUID> ids = list.stream().map(ServiceRequest::getId).toList();
        Map<UUID, RequestSummary> summaries = requestService.summaries(list, now).stream()
                .collect(Collectors.toMap(RequestSummary::id, s -> s));
        Map<UUID, Integer> photos = parts.photoCounts(ids);
        Map<UUID, UUID> mine = new HashMap<>();
        for (Offer o : offers.findByProIdAndRequestIdIn(proId, ids)) {
            if (o.getStatus() == OfferStatus.PENDING && o.getValidUntil().isAfter(now)) {
                mine.put(o.getRequestId(), o.getId());
            }
        }
        return list.stream().map(r -> {
            RequestSummary s = summaries.get(r.getId());
            return new FeedItem(r.getId(), r.getPublicCode(), r.getTitle(), r.getCategoryId(), r.getUrgency(),
                    s.districtName(), r.getNeighborhood(), r.getCreatedAt(), r.getPreferredFrom(), r.getPreferredTo(),
                    photos.getOrDefault(r.getId(), 0), s.offerCount(), mine.get(r.getId()));
        }).toList();
    }
}
