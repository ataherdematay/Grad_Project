package com.bitadilat.offer;

import com.bitadilat.common.ApiException;
import com.bitadilat.common.Money;
import com.bitadilat.common.Paging;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.offer.dto.CreateOfferBody;
import com.bitadilat.offer.dto.DeclineBody;
import com.bitadilat.offer.dto.OfferDetail;
import com.bitadilat.offer.dto.OfferItemIn;
import com.bitadilat.offer.dto.OfferItemView;
import com.bitadilat.offer.dto.OfferList;
import com.bitadilat.offer.dto.OfferSummary;
import com.bitadilat.offer.dto.ProCard;
import com.bitadilat.offer.dto.ProOfferList;
import com.bitadilat.offer.dto.ProOfferSummary;
import com.bitadilat.pro.Availability;
import com.bitadilat.pro.ProAccess;
import com.bitadilat.pro.ProProfile;
import com.bitadilat.pro.ProProfileRepository;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.request.CancelReason;
import com.bitadilat.request.RequestService;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Teklif işlemleri: müşteri tarafı (liste, ayrıntı, reddet) ve usta tarafı (ver, geri çek, listele). */
@Service
public class OfferService {

    private static final Pattern IDEMPOTENCY_KEY = Pattern.compile("^[A-Za-z0-9._:-]{1,64}$");
    private static final Set<Integer> WARRANTIES = Set.of(0, 3, 6, 12);
    private static final Duration MIN_WINDOW = Duration.ofHours(1);
    private static final Duration MAX_WINDOW = Duration.ofHours(12);
    private static final Duration MAX_LEAD = Duration.ofDays(14);
    private static final Duration MAX_VALIDITY = Duration.ofHours(72);

    private final OfferRepository offers;
    private final OfferItemRepository items;
    private final ServiceRequestRepository requests;
    private final RequestService requestService;
    private final ProProfileRepository profiles;
    private final UserRepository users;
    private final ProAccess proAccess;
    private final NotificationService notifications;
    private final JdbcTemplate jdbc;

    @jakarta.persistence.PersistenceContext
    private jakarta.persistence.EntityManager em;

    public OfferService(OfferRepository offers, OfferItemRepository items, ServiceRequestRepository requests,
                        RequestService requestService, ProProfileRepository profiles, UserRepository users,
                        ProAccess proAccess, NotificationService notifications, JdbcTemplate jdbc) {
        this.offers = offers;
        this.items = items;
        this.requests = requests;
        this.requestService = requestService;
        this.profiles = profiles;
        this.users = users;
        this.proAccess = proAccess;
        this.notifications = notifications;
        this.jdbc = jdbc;
    }

    // ─── Müşteri ────────────────────────────────────────────────────────────

    /** Talebin PENDING teklifleri + reddedilen sayısı. Yalnız talep sahibi; aksi 404. */
    @Transactional(readOnly = true)
    public OfferList listForRequest(UUID customerId, UUID requestId, String sort, BigDecimal maxPrice,
                                    BigDecimal minRating, String cursor, Integer limit) {
        String order = sort == null || sort.isBlank() ? "recommended" : sort;
        if (!Set.of("recommended", "price", "rating", "arrival").contains(order)) {
            throw ApiException.validation("sort", "sort recommended, price, rating veya arrival olmalı.");
        }
        ServiceRequest r = requests.findByIdAndCustomerId(requestId, customerId)
                .orElseThrow(() -> ApiException.notFound("Talep bulunamadı."));
        Instant now = Instant.now();
        long declined = offers.countByRequestIdAndStatus(requestId, OfferStatus.DECLINED);
        List<Offer> pending = r.isOpenAt(now)
                ? offers.findByRequestIdAndStatus(requestId, OfferStatus.PENDING).stream()
                        .filter(o -> o.getValidUntil().isAfter(now)).toList()
                : List.of();
        Map<UUID, ProCard> cards = cards(pending.stream().map(Offer::getProId).toList());
        List<Offer> filtered = pending.stream()
                .filter(o -> maxPrice == null || o.getTotalAmount().compareTo(maxPrice) <= 0)
                .filter(o -> {
                    if (minRating == null) {
                        return true;
                    }
                    BigDecimal avg = cards.get(o.getProId()).ratingAvg();
                    return avg != null && avg.compareTo(minRating) >= 0;
                })
                .sorted(comparator(order, cards))
                .toList();
        Paging.Slice<Offer> page = Paging.slice(filtered, cursor, limit);
        return new OfferList(page.items().stream().map(o -> summary(o, cards.get(o.getProId()), true)).toList(),
                declined, page.nextCursor());
    }

    private static Comparator<Offer> comparator(String sort, Map<UUID, ProCard> cards) {
        Comparator<BigDecimal> ratingDesc = Comparator.nullsLast(Comparator.<BigDecimal>reverseOrder());
        Comparator<Offer> byRating = Comparator.comparing(o -> cards.get(o.getProId()).ratingAvg(), ratingDesc);
        Comparator<Offer> byPrice = Comparator.comparing(Offer::getTotalAmount);
        Comparator<Offer> primary = switch (sort) {
            case "price" -> byPrice;
            case "rating" -> byRating.thenComparing(byPrice);
            case "arrival" -> Comparator.comparing(Offer::getArrivalFrom).thenComparing(byPrice);
            default -> byRating.thenComparing(byPrice);
        };
        return primary.thenComparing(Offer::getCreatedAt).thenComparing(Offer::getId);
    }

    /** Talep sahibi müşteri veya teklifi veren usta; aksi 404. */
    @Transactional(readOnly = true)
    public OfferDetail get(UUID userId, UUID offerId) {
        Offer o = offers.findById(offerId).orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        ServiceRequest r = requests.findById(o.getRequestId()).orElseThrow();
        boolean customer = r.getCustomerId().equals(userId);
        boolean pro = o.getProId().equals(userId);
        if (!customer && !pro) {
            throw ApiException.notFound("Teklif bulunamadı.");
        }
        return detail(o, pro, Instant.now(), r.isOpenAt(Instant.now()));
    }

    @Transactional
    public OfferDetail decline(UUID customerId, UUID offerId, DeclineBody body) {
        UUID requestId = offers.requestIdOf(offerId).orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        ServiceRequest r = requestService.lockOwned(customerId, requestId); // 404 sahibi değilse
        Offer o = offers.findById(offerId).orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        Instant now = Instant.now();
        boolean open = r.isOpenAt(now);
        requireLive(o, now, open);
        boolean keepOpen = Boolean.TRUE.equals(body.keepRequestOpen());
        if (!keepOpen && body.reason() != DeclineReason.NOT_NEEDED && body.reason() != DeclineReason.OTHER) {
            throw ApiException.validation("reason", "Talep kapatılacaksa gerekçe NOT_NEEDED veya OTHER olmalı.");
        }
        o.moveTo(OfferStatus.DECLINED);
        o.setDeclineReason(body.reason());
        o.setDeclineNote(body.note() == null || body.note().isBlank() ? null : body.note().trim());
        offers.saveAndFlush(o);
        if (!keepOpen) {
            requestService.cancelLocked(r, body.reason() == DeclineReason.NOT_NEEDED
                    ? CancelReason.PLANS_CHANGED : CancelReason.OTHER, body.note());
        }
        notifications.notify(o.getProId(), NotificationService.OFFER_DECLINED,
                Map.of("offerId", o.getId().toString(), "requestId", r.getId().toString(),
                        "publicCode", r.getPublicCode(), "reason", body.reason().name()),
                "/p/offers");
        return detail(o, false, now, r.isOpenAt(now));
    }

    // ─── Usta ───────────────────────────────────────────────────────────────

    @Transactional
    public OfferDetail create(UUID proId, UUID requestId, CreateOfferBody b, String idempotencyKey) {
        ProProfile pro = proAccess.requireApproved(proId);
        String key = normalizeKey(idempotencyKey);
        Optional<OfferDetail> replay = replay(proId, requestId, key);
        if (replay.isPresent()) {
            return replay.get();
        }
        Instant now = Instant.now();
        List<OfferItemIn> lines = b.items() == null ? List.of() : b.items();
        validate(b, lines, now);

        ServiceRequest r = requests.lockById(requestId).orElseThrow(() -> ApiException.notFound("Talep bulunamadı."));
        replay = replay(proId, requestId, key); // kilidi beklerken aynı anahtarla gelen eşzamanlı istek
        if (replay.isPresent()) {
            return replay.get();
        }
        if (!proAccess.matches(proId, r)) {
            throw ApiException.notFound("Talep bulunamadı.");
        }
        if (!r.isOpenAt(now)) {
            throw ApiException.illegalState("Talep teklif almıyor.");
        }
        if (pro.getAvailability() != Availability.ACTIVE) {
            throw ApiException.illegalState("Mola modundayken teklif verilemez.");
        }
        Optional<Offer> existing = offers.findByRequestIdAndProIdAndStatus(requestId, proId, OfferStatus.PENDING);
        if (existing.isPresent()) {
            Offer prev = existing.get();
            if (prev.getValidUntil().isAfter(now)) {
                throw new ApiException(HttpStatus.CONFLICT, "ALREADY_OFFERED",
                        "Bu talebe zaten bekleyen bir teklifin var.");
            }
            // Okuma anında zaten EXPIRED sayılan teklif zamanlayıcıyı beklemeden kapatılır (talep kilitli);
            // yoksa kısmi benzersiz indeks yeni teklifi engeller.
            prev.moveTo(OfferStatus.EXPIRED);
            offers.saveAndFlush(prev);
        }

        Offer o = new Offer();
        o.setPublicCode(String.format("T-%05d", jdbc.queryForObject("select nextval('offer_code_seq')", Long.class)));
        o.setRequestId(requestId);
        o.setProId(proId);
        o.setLaborAmount(Money.of(b.laborAmount()));
        o.setMaterialsAmount(Money.of(b.materialsAmount()));
        o.setTotalAmount(Money.of(b.laborAmount().add(b.materialsAmount())));
        o.setArrivalFrom(b.arrivalFrom());
        o.setArrivalTo(b.arrivalTo());
        o.setWarrantyMonths(b.warrantyMonths());
        o.setNote(b.note() == null || b.note().isBlank() ? null : b.note().trim());
        Instant cap = now.plus(MAX_VALIDITY);
        o.setValidUntil(b.arrivalTo().isBefore(cap) ? b.arrivalTo() : cap);
        o.setIdempotencyKey(key);
        try {
            o = offers.saveAndFlush(o);
        } catch (DataIntegrityViolationException e) {
            throw new ApiException(HttpStatus.CONFLICT, "ALREADY_OFFERED", "Bu talebe zaten bekleyen bir teklifin var.");
        }
        int order = 0;
        List<OfferItem> saved = new ArrayList<>();
        for (OfferItemIn in : lines) {
            OfferItem it = new OfferItem();
            it.setOfferId(o.getId());
            it.setKind(in.kind());
            it.setDescription(in.description().trim());
            it.setQuantity(in.quantity().setScale(2, java.math.RoundingMode.HALF_UP));
            it.setUnitPrice(Money.of(in.unitPrice()));
            it.setSortOrder(order++);
            saved.add(it);
        }
        items.saveAll(saved);
        items.flush();
        em.refresh(o); // yanıt, veritabanının sakladığı (mikrosaniye) değerlerle aynı olsun: tekrar istekte birebir aynı JSON

        notifications.notify(r.getCustomerId(), NotificationService.OFFER_RECEIVED,
                Map.of("offerId", o.getId().toString(), "requestId", r.getId().toString(),
                        "publicCode", r.getPublicCode(), "proName", pro.getBusinessName(),
                        "totalAmount", o.getTotalAmount().toPlainString()),
                "/c/requests/" + r.getId() + "/offers");
        return detail(o, true, now, true);
    }

    private Optional<OfferDetail> replay(UUID proId, UUID requestId, String key) {
        if (key == null) {
            return Optional.empty();
        }
        Optional<Offer> existing = offers.findByProIdAndIdempotencyKey(proId, key);
        if (existing.isEmpty()) {
            return Optional.empty();
        }
        if (!existing.get().getRequestId().equals(requestId)) {
            throw new ApiException(HttpStatus.CONFLICT, "DUPLICATE_ATTEMPT",
                    "Idempotency-Key başka bir istekte kullanılmış.");
        }
        Instant now = Instant.now();
        boolean open = requests.findById(requestId).map(x -> x.isOpenAt(now)).orElse(false);
        return Optional.of(detail(existing.get(), true, now, open));
    }

    private static String normalizeKey(String key) {
        if (key == null || key.isBlank()) {
            return null;
        }
        String k = key.trim();
        if (!IDEMPOTENCY_KEY.matcher(k).matches()) {
            throw ApiException.validation("Idempotency-Key", "Idempotency-Key geçersiz.");
        }
        return k;
    }

    /** offers.total_amount numeric(12,2) üst sınırı. */
    private static final BigDecimal MAX_TOTAL = new BigDecimal("9999999999.99");

    private static void validate(CreateOfferBody b, List<OfferItemIn> lines, Instant now) {
        if (b.laborAmount().add(b.materialsAmount()).compareTo(MAX_TOTAL) > 0) {
            throw ApiException.validation("materialsAmount", "Toplam tutar çok büyük.");
        }
        if (!WARRANTIES.contains(b.warrantyMonths())) {
            throw ApiException.validation("warrantyMonths", "Garanti 0, 3, 6 veya 12 ay olmalı.");
        }
        if (!b.arrivalFrom().isAfter(now)) {
            throw ApiException.validation("arrivalFrom", "Varış başlangıcı gelecekte olmalı.");
        }
        if (b.arrivalFrom().isAfter(now.plus(MAX_LEAD))) {
            throw ApiException.validation("arrivalFrom", "Varış en fazla 14 gün sonra olabilir.");
        }
        Duration window = Duration.between(b.arrivalFrom(), b.arrivalTo());
        if (window.compareTo(MIN_WINDOW) < 0 || window.compareTo(MAX_WINDOW) > 0) {
            throw ApiException.validation("arrivalTo", "Varış aralığı 1 ile 12 saat arasında olmalı.");
        }
        if (!lines.isEmpty()) {
            BigDecimal labor = BigDecimal.ZERO;
            BigDecimal material = BigDecimal.ZERO;
            for (OfferItemIn in : lines) {
                BigDecimal line = in.quantity().multiply(in.unitPrice()).setScale(2, java.math.RoundingMode.HALF_UP);
                if (in.kind() == ItemKind.LABOR) {
                    labor = labor.add(line);
                } else {
                    material = material.add(line);
                }
            }
            if (labor.compareTo(b.laborAmount()) != 0 || material.compareTo(b.materialsAmount()) != 0) {
                throw ApiException.validation("items", "Kalem toplamları işçilik ve malzeme tutarlarıyla eşleşmiyor.");
            }
        }
    }

    @Transactional
    public OfferDetail withdraw(UUID proId, UUID offerId) {
        proAccess.requireApproved(proId);
        UUID requestId = offers.requestIdOf(offerId).orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        ServiceRequest r = requests.lockById(requestId).orElseThrow();
        Offer o = offers.findById(offerId).filter(x -> x.getProId().equals(proId))
                .orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        Instant now = Instant.now();
        requireLive(o, now, r.isOpenAt(now));
        o.moveTo(OfferStatus.WITHDRAWN);
        offers.saveAndFlush(o);
        return detail(o, true, now, r.isOpenAt(now));
    }

    @Transactional(readOnly = true)
    public ProOfferList listForPro(UUID proId, String status, String cursor, Integer limit) {
        proAccess.requireApproved(proId);
        OfferStatus wanted = null;
        if (status != null && !status.isBlank()) {
            try {
                wanted = OfferStatus.valueOf(status.trim());
            } catch (IllegalArgumentException e) {
                throw ApiException.validation("status", "Geçersiz teklif durumu.");
            }
        }
        Instant now = Instant.now();
        List<Offer> mine = offers.findByProIdOrderByCreatedAtDescIdDesc(proId);
        Map<UUID, ServiceRequest> reqs = requests.findAllById(mine.stream().map(Offer::getRequestId).distinct().toList())
                .stream().collect(Collectors.toMap(ServiceRequest::getId, x -> x));
        final OfferStatus filter = wanted;
        List<Offer> matching = mine.stream()
                .filter(o -> filter == null
                        || o.effectiveStatus(now, reqs.get(o.getRequestId()).isOpenAt(now)) == filter)
                .toList();
        Paging.Slice<Offer> page = Paging.slice(matching, cursor, limit);
        Map<UUID, ProCard> cards = cards(List.of(proId));
        Map<Integer, String> districtNames = new HashMap<>();
        List<ProOfferSummary> out = page.items().stream().map(o -> {
            ServiceRequest r = reqs.get(o.getRequestId());
            OfferSummary s = summary(o, cards.get(proId), r.isOpenAt(now), now);
            String dn = districtNames.computeIfAbsent(r.getDistrictId(), requestService::districtName);
            return new ProOfferSummary(s.id(), s.publicCode(), s.requestId(), s.status(), s.pro(), s.laborAmount(),
                    s.materialsAmount(), s.totalAmount(), s.arrivalFrom(), s.arrivalTo(), s.warrantyMonths(),
                    s.note(), s.validUntil(), s.createdAt(),
                    new ProOfferSummary.Req(r.getId(), r.getPublicCode(), r.getTitle(), dn));
        }).toList();
        return new ProOfferList(out, page.nextCursor());
    }

    /** Ustanın o talepteki bekleyen (ve süresi dolmamış) teklifi. Çağıran erişimi önceden doğrulamış olmalı. */
    @Transactional(readOnly = true)
    public Optional<Offer> pendingOf(UUID proId, UUID requestId, Instant now) {
        return offers.findByRequestIdAndProIdAndStatus(requestId, proId, OfferStatus.PENDING)
                .filter(o -> o.getValidUntil().isAfter(now));
    }

    @Transactional(readOnly = true)
    public OfferDetail proView(Offer o) {
        Instant now = Instant.now();
        boolean open = requests.findById(o.getRequestId()).map(r -> r.isOpenAt(now)).orElse(false);
        return detail(o, true, now, open);
    }

    // ─── Görünüm ────────────────────────────────────────────────────────────

    private void requireLive(Offer o, Instant now, boolean requestOpen) {
        if (o.effectiveStatus(now, requestOpen) == OfferStatus.EXPIRED) {
            throw new ApiException(HttpStatus.CONFLICT, "OFFER_EXPIRED", "Teklifin süresi dolmuş.");
        }
        if (o.getStatus() != OfferStatus.PENDING) {
            throw ApiException.illegalState("Teklif bekleyen durumda değil.");
        }
    }

    private OfferSummary summary(Offer o, ProCard card, boolean requestOpen) {
        return summary(o, card, requestOpen, Instant.now());
    }

    private OfferSummary summary(Offer o, ProCard card, boolean requestOpen, Instant now) {
        return new OfferSummary(o.getId(), o.getPublicCode(), o.getRequestId(), o.effectiveStatus(now, requestOpen),
                card, o.getLaborAmount(), o.getMaterialsAmount(), o.getTotalAmount(), o.getArrivalFrom(),
                o.getArrivalTo(), o.getWarrantyMonths(), o.getNote(), o.getValidUntil(), o.getCreatedAt());
    }

    /** {@code viewerIsPro}: hizmet bedeli ve net kazanç yalnız teklifi veren ustaya dolu. */
    OfferDetail detail(Offer o, boolean viewerIsPro, Instant now, boolean requestOpen) {
        ProCard card = cards(List.of(o.getProId())).get(o.getProId());
        List<OfferItemView> views = items.findByOfferIdInOrderBySortOrderAsc(List.of(o.getId())).stream()
                .map(i -> new OfferItemView(i.getKind(), i.getDescription(), i.getQuantity(), i.getUnitPrice(),
                        i.lineTotal()))
                .toList();
        BigDecimal fee = null;
        BigDecimal net = null;
        if (viewerIsPro) {
            fee = Money.of(o.getTotalAmount().multiply(Money.FEE_RATE));
            net = Money.of(o.getTotalAmount().subtract(fee));
        }
        return new OfferDetail(o.getId(), o.getPublicCode(), o.getRequestId(), o.effectiveStatus(now, requestOpen),
                card, o.getLaborAmount(), o.getMaterialsAmount(), o.getTotalAmount(), o.getArrivalFrom(),
                o.getArrivalTo(), o.getWarrantyMonths(), o.getNote(), o.getValidUntil(), o.getCreatedAt(), views,
                fee, net, o.getDeclineReason());
    }

    private Map<UUID, ProCard> cards(List<UUID> proIds) {
        List<UUID> ids = proIds.stream().distinct().toList();
        Map<UUID, User> names = users.findAllById(ids).stream().collect(Collectors.toMap(User::getId, u -> u));
        Map<UUID, ProCard> out = new HashMap<>();
        for (ProProfile p : profiles.findAllById(ids)) {
            User u = names.get(p.getUserId());
            out.put(p.getUserId(), new ProCard(p.getUserId(), p.getBusinessName(), u == null ? "" : u.getFullName(),
                    p.getRatingAvg(), p.getRatingCount(), p.getCompletedJobs(),
                    p.getReviewStatus() == ReviewStatus.APPROVED));
        }
        return out;
    }
}
