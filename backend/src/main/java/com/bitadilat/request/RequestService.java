package com.bitadilat.request;

import com.bitadilat.catalog.Category;
import com.bitadilat.catalog.CategoryRepository;
import com.bitadilat.catalog.District;
import com.bitadilat.catalog.DistrictRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.Money;
import com.bitadilat.common.Paging;
import com.bitadilat.media.MediaPurpose;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.offer.OfferLifecycle;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.request.dto.AnswerDto;
import com.bitadilat.request.dto.CancelRequestBody;
import com.bitadilat.request.dto.CreateRequestBody;
import com.bitadilat.request.dto.RequestDetail;
import com.bitadilat.request.dto.RequestList;
import com.bitadilat.request.dto.RequestSummary;
import com.bitadilat.request.dto.UpdateRequestBody;
import com.bitadilat.user.AddressService;
import com.bitadilat.user.dto.AddressView;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Müşteri tarafı talep işlemleri ve talep görünümleri. Durum değiştiren her işlem talebi FOR UPDATE ile kilitler. */
@Service
public class RequestService {

    static final Duration LIFETIME = Duration.ofDays(7);
    static final Duration PLANNED_HORIZON = Duration.ofDays(30);

    private final ServiceRequestRepository requests;
    private final RequestParts parts;
    private final QuestionCatalog questions;
    private final MatchingService matching;
    private final MediaService media;
    private final AddressService addresses;
    private final CategoryRepository categories;
    private final DistrictRepository districts;
    private final OfferRepository offers;
    private final OfferLifecycle offerLifecycle;
    private final NotificationService notifications;

    public RequestService(ServiceRequestRepository requests, RequestParts parts, QuestionCatalog questions,
                          MatchingService matching, MediaService media, AddressService addresses,
                          CategoryRepository categories, DistrictRepository districts, OfferRepository offers,
                          OfferLifecycle offerLifecycle, NotificationService notifications) {
        this.requests = requests;
        this.parts = parts;
        this.questions = questions;
        this.matching = matching;
        this.media = media;
        this.addresses = addresses;
        this.categories = categories;
        this.districts = districts;
        this.offers = offers;
        this.offerLifecycle = offerLifecycle;
        this.notifications = notifications;
    }

    // ─── Müşteri uç noktaları ───────────────────────────────────────────────

    @Transactional
    public RequestDetail create(UUID userId, CreateRequestBody b) {
        Instant now = Instant.now();
        requireCategory(b.categoryId());
        Instant from = null;
        Instant to = null;
        if (b.urgency() == Urgency.PLANNED) {
            validatePlanned(b.preferredFrom(), b.preferredTo(), now);
            from = b.preferredFrom();
            to = b.preferredTo();
        }
        AddressView address = addresses.get(userId, b.addressId()); // başkasının adresi: 404
        List<UUID> photoIds = distinct(b.photoIds());
        media.requireAttachable(userId, photoIds, MediaPurpose.REQUEST_PHOTO, "photoIds", MediaService.Reuse.NONE);
        Map<String, String> answers = questions.validate(b.categoryId(), b.answers());

        ServiceRequest r = new ServiceRequest();
        r.setPublicCode(parts.nextPublicCode());
        r.setCustomerId(userId);
        r.setCategoryId(b.categoryId());
        r.setUrgency(b.urgency());
        r.setPreferredFrom(from);
        r.setPreferredTo(to);
        r.setTitle(text("title", b.title(), 5, 150));
        r.setDescription(text("description", b.description(), 20, 2000));
        r.setDistrictId(address.districtId());
        r.setNeighborhood(address.neighborhood());
        r.setAddressId(address.id());
        r.setExpiresAt(now.plus(LIFETIME));
        List<UUID> matched = matching.matchedProIds(r.getCategoryId(), r.getDistrictId(), userId);
        r.setMatchedProCount(matched.size());
        r = requests.saveAndFlush(r);
        parts.replacePhotos(r.getId(), photoIds);
        parts.replaceAnswers(r.getId(), answers);

        for (UUID proId : matched) {
            notifications.notify(proId, NotificationService.NEW_MATCHING_REQUEST,
                    Map.of("requestId", r.getId().toString(), "publicCode", r.getPublicCode(),
                            "title", r.getTitle(), "districtName", address.districtName()),
                    "/p/requests/" + r.getId());
        }
        return detail(r, true, now);
    }

    @Transactional
    public RequestDetail update(UUID userId, UUID id, UpdateRequestBody b) {
        Instant now = Instant.now();
        ServiceRequest r = lockOwned(userId, id);
        if (!r.isOpenAt(now)) {
            throw ApiException.illegalState("Yalnızca açık talep düzenlenebilir.");
        }
        boolean categoryChanged = false;
        if (b.categoryId() != null && !b.categoryId().equals(r.getCategoryId())) {
            requireCategory(b.categoryId());
            r.setCategoryId(b.categoryId());
            categoryChanged = true;
        }
        Urgency urgency = b.urgency() != null ? b.urgency() : r.getUrgency();
        boolean urgencyChanged = urgency != r.getUrgency();
        if (urgency == Urgency.URGENT) {
            r.setPreferredFrom(null);
            r.setPreferredTo(null);
        } else if (urgencyChanged || b.preferredFrom() != null || b.preferredTo() != null) {
            Instant from = b.preferredFrom() != null ? b.preferredFrom() : (urgencyChanged ? null : r.getPreferredFrom());
            Instant to = b.preferredTo() != null ? b.preferredTo() : (urgencyChanged ? null : r.getPreferredTo());
            validatePlanned(from, to, now);
            r.setPreferredFrom(from);
            r.setPreferredTo(to);
        }
        r.setUrgency(urgency);
        if (b.title() != null) {
            r.setTitle(text("title", b.title(), 5, 150));
        }
        if (b.description() != null) {
            r.setDescription(text("description", b.description(), 20, 2000));
        }
        if (b.addressId() != null) {
            AddressView a = addresses.get(userId, b.addressId());
            r.setAddressId(a.id());
            r.setDistrictId(a.districtId());
            r.setNeighborhood(a.neighborhood());
        }
        if (b.photoIds() != null) {
            List<UUID> photoIds = distinct(b.photoIds());
            media.requireAttachable(userId, photoIds, MediaPurpose.REQUEST_PHOTO, "photoIds",
                    new MediaService.Reuse(r.getId(), null));
            parts.replacePhotos(r.getId(), photoIds);
        }
        if (b.answers() != null) {
            parts.replaceAnswers(r.getId(), questions.validate(r.getCategoryId(), b.answers()));
        } else if (categoryChanged) {
            parts.replaceAnswers(r.getId(), Map.of()); // eski kategorinin cevapları yenisine uymaz
        }
        // Düzenleme mevcut teklifleri geçersiz kılar.
        offerLifecycle.expirePendingOf(r.getId());
        r.setMatchedProCount(matching.matchedProIds(r.getCategoryId(), r.getDistrictId(), userId).size());
        r = requests.saveAndFlush(r);
        return detail(r, true, now);
    }

    @Transactional
    public RequestDetail cancel(UUID userId, UUID id, CancelRequestBody b) {
        Instant now = Instant.now();
        ServiceRequest r = lockOwned(userId, id);
        if (!r.isOpenAt(now)) {
            throw ApiException.illegalState("Yalnızca açık talep iptal edilebilir.");
        }
        cancelLocked(r, b.reason(), b.note());
        return detail(r, true, now);
    }

    /** Kilitli talebi iptal eder ve PENDING tekliflerini EXPIRED yapar. OfferService (reddedip kapatma) da kullanır. */
    @Transactional
    public void cancelLocked(ServiceRequest r, CancelReason reason, String note) {
        r.moveTo(RequestStatus.CANCELLED);
        r.setCancelReason(reason);
        r.setCancelNote(note == null || note.isBlank() ? null : note.trim());
        offerLifecycle.expirePendingOf(r.getId());
        requests.saveAndFlush(r);
    }

    @Transactional(readOnly = true)
    public RequestDetail get(UUID userId, UUID id) {
        ServiceRequest r = requests.findByIdAndCustomerId(id, userId)
                .orElseThrow(() -> ApiException.notFound("Talep bulunamadı."));
        return detail(r, true, Instant.now());
    }

    @Transactional(readOnly = true)
    public RequestList list(UUID userId, String scope, String cursor, Integer limit) {
        boolean active;
        if ("active".equals(scope)) {
            active = true;
        } else if ("past".equals(scope)) {
            active = false;
        } else {
            throw ApiException.validation("scope", "scope active veya past olmalı.");
        }
        Instant now = Instant.now();
        List<ServiceRequest> mine = requests.findByCustomerIdOrderByCreatedAtDescIdDesc(userId).stream()
                .filter(r -> {
                    RequestStatus s = r.effectiveStatus(now);
                    boolean isActive = s == RequestStatus.OPEN || s == RequestStatus.ASSIGNED;
                    return isActive == active;
                }).toList();
        Paging.Slice<ServiceRequest> page = Paging.slice(mine, cursor, limit);
        return new RequestList(summaries(page.items(), now), page.nextCursor());
    }

    // ─── Ortak yardımcılar (offer ve pro paketleri de kullanır) ──────────────

    /** Talebi kilitleyip sahibini doğrular; yoksa veya başkasınınsa 404. */
    @Transactional
    public ServiceRequest lockOwned(UUID userId, UUID id) {
        ServiceRequest r = requests.lockById(id).orElseThrow(() -> ApiException.notFound("Talep bulunamadı."));
        if (!r.getCustomerId().equals(userId)) {
            throw ApiException.notFound("Talep bulunamadı.");
        }
        return r;
    }

    public String districtName(Integer districtId) {
        return districts.findById(districtId).map(District::getName).orElse("");
    }

    public List<RequestSummary> summaries(List<ServiceRequest> list, Instant now) {
        if (list.isEmpty()) {
            return List.of();
        }
        Map<UUID, Object[]> stats = new HashMap<>();
        for (Object[] row : offers.pendingStats(list.stream().map(ServiceRequest::getId).toList(), now)) {
            stats.put((UUID) row[0], row);
        }
        Map<Integer, String> names = districts.findAll().stream()
                .collect(Collectors.toMap(District::getId, District::getName, (x, y) -> x));
        return list.stream().map(r -> summary(r, now, stats.get(r.getId()), names.get(r.getDistrictId()))).toList();
    }

    private RequestSummary summary(ServiceRequest r, Instant now, Object[] stat, String districtName) {
        RequestStatus status = r.effectiveStatus(now);
        boolean counts = stat != null && status == RequestStatus.OPEN;
        return new RequestSummary(r.getId(), r.getPublicCode(), r.getTitle(), r.getCategoryId(), r.getUrgency(),
                status, districtName, r.getNeighborhood(), r.getCreatedAt(), r.getExpiresAt(),
                counts ? ((Long) stat[1]).intValue() : 0,
                counts ? Money.of((BigDecimal) stat[2]) : null,
                counts ? Money.of((BigDecimal) stat[3]) : null);
    }

    /** Tam ayrıntı. {@code owner} değilse tam adres ve kapı notu null. İmzalı fotoğraf adresleri burada üretilir. */
    @Transactional(readOnly = true)
    public RequestDetail detail(ServiceRequest r, boolean owner, Instant now) {
        RequestSummary s = summaries(List.of(r), now).get(0);
        String line = null;
        String door = null;
        if (owner && r.getAddressId() != null) {
            var view = addresses.findView(r.getCustomerId(), r.getAddressId());
            if (view.isPresent()) {
                line = view.get().lineFull();
                door = view.get().doorNote();
            }
        }
        List<AnswerDto> answers = parts.answers(r.getId());
        return new RequestDetail(s.id(), s.publicCode(), s.title(), s.categoryId(), s.urgency(), s.status(),
                s.districtName(), s.neighborhood(), s.createdAt(), s.expiresAt(), s.offerCount(), s.minOfferTotal(),
                s.maxOfferTotal(), r.getDescription(), r.getPreferredFrom(), r.getPreferredTo(),
                media.refs(parts.photoIds(r.getId())), answers, r.getMatchedProCount(), MatchingService.FACTORS,
                new RequestDetail.Address(s.districtName(), r.getNeighborhood(), line, door));
    }

    // ─── Doğrulamalar ───────────────────────────────────────────────────────

    private void requireCategory(String categoryId) {
        if (!categories.findById(categoryId).map(Category::isActive).orElse(false)) {
            throw ApiException.validation("categoryId", "Kategori bulunamadı.");
        }
    }

    private static void validatePlanned(Instant from, Instant to, Instant now) {
        if (from == null) {
            throw ApiException.validation("preferredFrom", "Planlı talepte başlangıç zamanı gerekli.");
        }
        if (to == null) {
            throw ApiException.validation("preferredTo", "Planlı talepte bitiş zamanı gerekli.");
        }
        if (!from.isAfter(now)) {
            throw ApiException.validation("preferredFrom", "Başlangıç gelecekte olmalı.");
        }
        if (!to.isAfter(from)) {
            throw ApiException.validation("preferredTo", "Bitiş başlangıçtan sonra olmalı.");
        }
        Instant limit = now.plus(PLANNED_HORIZON);
        if (from.isAfter(limit)) {
            throw ApiException.validation("preferredFrom", "Başlangıç en fazla 30 gün sonra olabilir.");
        }
        if (to.isAfter(limit)) {
            throw ApiException.validation("preferredTo", "Bitiş en fazla 30 gün sonra olabilir.");
        }
    }

    /** Uzunluk kuralı kırpılmış metne uygulanır (boşlukla doldurulmuş kısa metin geçmez). */
    private static String text(String field, String value, int min, int max) {
        String t = value.trim();
        if (t.length() < min || t.length() > max) {
            throw ApiException.validation(field, field + " " + min + "-" + max + " karakter olmalı.");
        }
        return t;
    }

    private static List<UUID> distinct(List<UUID> ids) {
        return ids == null ? List.of() : ids.stream().distinct().toList();
    }
}
