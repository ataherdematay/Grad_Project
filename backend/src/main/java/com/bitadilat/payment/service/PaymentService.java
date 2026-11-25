package com.bitadilat.payment.service;

import com.bitadilat.common.ApiException;
import com.bitadilat.job.EscrowNotifications;
import com.bitadilat.job.JobOpening;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.offer.OfferStatus;
import com.bitadilat.payment.domain.EscrowChannel;
import com.bitadilat.payment.domain.EscrowEventType;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowProvider;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.domain.Offer;
import com.bitadilat.payment.dto.AppInitResponse;
import com.bitadilat.payment.dto.InitPaymentRequest;
import com.bitadilat.payment.dto.InitPaymentResponse;
import com.bitadilat.payment.dto.PaymentResult;
import com.bitadilat.payment.dto.PaymentView;
import com.bitadilat.payment.dto.RefundRequest;
import com.bitadilat.payment.exception.DuplicateAttemptException;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.exception.PaymentDeclinedException;
import com.bitadilat.payment.gateway.PaymentErrorMessages;
import com.bitadilat.payment.gateway.PaymentGateway;
import com.bitadilat.payment.gateway.PaymentGateway.CardDetails;
import com.bitadilat.payment.gateway.PaymentGateway.GatewayPayment;
import com.bitadilat.payment.gateway.PaymentGateway.Status;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import java.time.Instant;
import java.time.YearMonth;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * Ödeme akışı ve güvence havuzu kuralları.
 *
 * Temel kural: callback parametreleri yalnızca bir işarettir. Ödemenin başarılı olduğuna, Craftgate
 * API'sinden dönen yanıta bakılarak karar verilir. Böylece sahte bir POST kaydı LOCKED yapamaz.
 *
 * <p>İki kanal vardır: PROTOTYPE (eski HTML prototipi, statik teklif, iş açmaz) ve APP (mobil uygulama; teklif
 * sunucudan okunur, kabul callback'in kendi işleminde yapılır).
 */
@Slf4j
@Service
public class PaymentService {

    static final String UNVERIFIED_MESSAGE =
            "Ödeme sonucu doğrulanamadı. Kartınızı kontrol etmeden tekrar denemeyin; gerekirse destekle görüşün.";

    private static final String CALLBACK_PATH = "/api/payments/3ds/callback";
    private static final String BANK_DECLINED_MESSAGE =
            "3D Secure doğrulaması tamamlanamadı. Şifreyi kontrol edip tekrar deneyin veya farklı bir kart kullanın.";
    static final String ALREADY_ASSIGNED_MESSAGE =
            "Bu talep için başka bir teklif az önce kabul edildi. Ödemeniz tamamen iade edilecektir.";
    static final String OFFER_EXPIRED_MESSAGE = "Teklifin süresi doldu. Ödemeniz tamamen iade edilecektir.";
    static final String THREEDS_ABANDONED_MESSAGE = "Ödeme tamamlanmadı. Kartınızdan ücret alınmadı; yeniden deneyebilirsiniz.";
    static final String REFUND_PENDING_SUFFIX = " İade şu an yapılamadı; otomatik olarak yeniden denenecek.";
    /**
     * 3DS'i bitmemiş ödeme ancak bu süreden sonra terk edilmiş sayılır. Bu süre boyunca talep başına tek INITIALIZED
     * kuralı yeni denemeyi 409 PAYMENT_IN_PROGRESS ile bekletir; buna karşılık geç gelen banka başarısı normal yoldan
     * işlenir.
     */
    public static final java.time.Duration ABANDON_AFTER = java.time.Duration.ofHours(2);
    /**
     * Müşteri aynı talep için yeni ödeme başlattığında eski INITIALIZED deneme bu süreden eskiyse Craftgate'e sorulur;
     * Craftgate 3DS'in bankada hiç bitmediğini (INIT_THREEDS) söylerse eski deneme hemen terk edilmiş sayılır.
     */
    public static final java.time.Duration RETRY_ABANDON_AFTER = java.time.Duration.ofMinutes(10);

    private final EscrowPaymentRepository repository;
    private final PaymentGateway gateway;
    private final OfferCatalog offers;
    private final String callbackUrl;
    private final OfferRepository offerRepository;
    private final ServiceRequestRepository requestRepository;
    private final JobOpening jobOpening;
    private final EscrowService escrow;
    private final TransactionTemplate tx;
    private final EscrowNotifications escrowNotifications;
    private final EscrowEvents events;

    public PaymentService(
            EscrowPaymentRepository repository,
            PaymentGateway gateway,
            OfferCatalog offers,
            @Value("${bitadilat.public-base-url}") String publicBaseUrl,
            OfferRepository offerRepository,
            ServiceRequestRepository requestRepository,
            JobOpening jobOpening,
            EscrowService escrow,
            TransactionTemplate tx,
            EscrowNotifications escrowNotifications,
            EscrowEvents events) {
        this.events = events;
        this.tx = tx;
        this.escrowNotifications = escrowNotifications;
        this.repository = repository;
        this.gateway = gateway;
        this.offers = offers;
        this.callbackUrl = publicBaseUrl.replaceAll("/+$", "") + CALLBACK_PATH;
        this.offerRepository = offerRepository;
        this.requestRepository = requestRepository;
        this.jobOpening = jobOpening;
        this.escrow = escrow;
    }

    /** Sonuç sayfasının kullanıcıyı nereye göndereceğini belirler. ref bilinmiyorsa null olur. */
    public record CallbackOutcome(String ref, boolean locked, EscrowChannel channel) {
        public CallbackOutcome(String ref, boolean locked) {
            this(ref, locked, EscrowChannel.PROTOTYPE);
        }
    }

    // ─── Prototip kanalı (yalnızca dev'de uç noktası vardır) ─────────────────

    public InitPaymentResponse init3ds(InitPaymentRequest request) {
        Offer offer = offers.require(request.offerId());
        CardDetails card = CardValidator.normalize(
                new CardDetails(request.cardHolderName(), request.cardNumber(), request.expireMonth(),
                        request.expireYear(), request.cvc()),
                YearMonth.now());

        if (repository.existsByAttemptKey(request.attemptKey())) {
            throw new DuplicateAttemptException();
        }
        EscrowPayment payment = repository.save(EscrowPayment.start(
                offer, request.attemptKey(), card.number().substring(card.number().length() - 4)));

        PaymentGateway.ThreeDsSession session;
        try {
            session = gateway.init3ds(new PaymentGateway.ThreeDsRequest(
                    payment.getTotalAmount(),
                    payment.getConversationId(),
                    payment.getRef(),
                    "BiTadilat hizmet bedeli #" + offer.jobRef(),
                    callbackUrl,
                    card));
        } catch (GatewayException e) {
            payment.fail(e.getMessage());
            repository.save(payment);
            throw new PaymentDeclinedException(payment.getRef(), e.getMessage());
        }

        payment.attachCraftgatePayment(session.paymentId());
        repository.save(payment);
        return new InitPaymentResponse(payment.getRef(), session.htmlContent(), session.redirectUrl());
    }

    // ─── Uygulama kanalı ────────────────────────────────────────────────────

    /**
     * Müşterinin teklif için 3DS ödemesini başlatır. Tutar her zaman sunucudaki tekliften gelir. Ön koşullar:
     * talep çağıranındır (değilse 404), talep OPEN, teklif PENDING ve süresi dolmamış (aksi 409), talepte başka
     * INITIALIZED ödeme yok (409 PAYMENT_IN_PROGRESS). Kayıt bilerek işlemsiz kaydedilir: banka çağrısı sürerken
     * satır başkalarına görünür ve kısmi benzersiz indeks yarışı kapatır.
     */
    public AppInitResponse initApp(UUID customerId, InitPaymentRequest request) {
        UUID offerId = parseUuid(request.offerId());
        UUID attemptKey;
        try {
            attemptKey = UUID.fromString(request.attemptKey().trim());
        } catch (IllegalArgumentException e) {
            throw ApiException.validation("attemptKey", "attemptKey UUID olmalı.");
        }
        com.bitadilat.offer.Offer offer = offerRepository.findById(offerId)
                .orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        ServiceRequest r = requestRepository.findById(offer.getRequestId())
                .orElseThrow(() -> ApiException.notFound("Teklif bulunamadı."));
        if (!r.getCustomerId().equals(customerId)) {
            throw ApiException.notFound("Teklif bulunamadı.");
        }
        Instant now = Instant.now();
        if (!r.isOpenAt(now)) {
            throw ApiException.illegalState("Talep ödeme almıyor.");
        }
        if (offer.getStatus() == OfferStatus.EXPIRED
                || (offer.getStatus() == OfferStatus.PENDING && !offer.getValidUntil().isAfter(now))) {
            throw new ApiException(HttpStatus.CONFLICT, "OFFER_EXPIRED", "Teklifin süresi dolmuş.");
        }
        if (offer.getStatus() != OfferStatus.PENDING) {
            throw ApiException.illegalState("Teklif bekleyen durumda değil.");
        }

        CardDetails card = CardValidator.normalize(
                new CardDetails(request.cardHolderName(), request.cardNumber(), request.expireMonth(),
                        request.expireYear(), request.cvc()),
                YearMonth.now());

        String key = attemptKey.toString();
        if (repository.existsByAttemptKey(key)) {
            throw new DuplicateAttemptException();
        }
        if (repository.existsByRequestIdAndStatus(r.getId(), EscrowStatus.INITIALIZED)
                && !Boolean.TRUE.equals(tx.execute(st -> abandonUnfinishedAttempts(r.getId(), now)))) {
            throw inProgress();
        }
        EscrowPayment payment;
        try {
            EscrowPayment started = EscrowPayment.startApp(offer.getId(), r.getPublicCode(),
                    offer.getTotalAmount(), r.getId(), customerId, offer.getProId(), key,
                    card.number().substring(card.number().length() - 4), EscrowProvider.CRAFTGATE);
            started.attachCardBrand(EscrowPayment.brandOf(card.number()));
            payment = repository.saveAndFlush(started);
            events.record(payment, EscrowEventType.PAYMENT_INITIALIZED, payment.getTotalAmount(), "CUSTOMER");
        } catch (DataIntegrityViolationException e) {
            // ux_escrow_one_initialized_per_request (yarış) veya aynı attemptKey'in eşzamanlı kullanımı.
            if (repository.existsByAttemptKey(key)) {
                throw new DuplicateAttemptException();
            }
            throw inProgress();
        }

        PaymentGateway.ThreeDsSession session;
        try {
            session = gateway.init3ds(new PaymentGateway.ThreeDsRequest(
                    payment.getTotalAmount(),
                    payment.getConversationId(),
                    payment.getRef(),
                    "BiTadilat hizmet bedeli #" + r.getPublicCode(),
                    callbackUrl,
                    card));
        } catch (GatewayException e) {
            // Banka sayfası istemciye ulaşmadı: 3DS başlamadı, para çekilemez; kayıt kapanır ve talep serbest kalır.
            payment.fail(e.getMessage());
            repository.save(payment);
            events.record(payment, EscrowEventType.FAILED, null, "SYSTEM", payment.getErrorCode());
            if (e.isConnectionProblem()) {
                throw e; // Craftgate'e ulaşılamadı: kart reddi değil, 502 GATEWAY_ERROR (sözleşme)
            }
            throw new PaymentDeclinedException(payment.getRef(), e.getMessage());
        }
        payment.attachCraftgatePayment(session.paymentId());
        repository.save(payment);
        events.record(payment, EscrowEventType.THREEDS_STARTED, null, "CUSTOMER");
        return new AppInitResponse(payment.getRef(), session.htmlContent());
    }

    /**
     * Uygulama kanalı ödeme sonucu. Yalnızca ödemeyi yapan müşteri, atanmış usta ve admin görür; diğerleri 404.
     * Kart bilgisi (son 4 hane) yalnızca müşteriye gösterilir.
     */
    @Transactional(readOnly = true)
    public PaymentResult result(UUID viewerId, boolean admin, String ref) {
        EscrowPayment p = repository.findById(ref)
                .filter(x -> x.getChannel() == EscrowChannel.APP)
                .orElseThrow(PaymentService::notFound);
        boolean customer = viewerId.equals(p.getCustomerId());
        boolean pro = viewerId.equals(p.getProId()) && p.getJobId() != null;
        if (!customer && !pro && !admin) {
            throw notFound();
        }
        return new PaymentResult(p.getRef(), p.getStatus(), UUID.fromString(p.getOfferId()), p.getRequestId(),
                p.getJobId(), p.getTotalAmount(), customer || admin ? p.getCardLast4() : null, p.getErrorCode(),
                p.getErrorMessage(), p.isResultUncertain() || p.getStatus() == EscrowStatus.INITIALIZED);
    }

    // ─── Banka dönüşü ───────────────────────────────────────────────────────

    /**
     * Callback adresi herkese açıktır, gelen değerlere doğrudan güvenilmez. İmzası bozuk veya kayıtla
     * eşleşmeyen bir istek kaydı değiştirmez.
     */
    @Transactional
    public CallbackOutcome handleCallback(Map<String, String> params) {
        if (!gateway.isCallbackAuthentic(params)) {
            log.warn("3DS callback imzası geçersiz. paymentId={}", safeLong(params.get("paymentId")));
            return new CallbackOutcome(null, false);
        }

        // Bankada iptal edilen ödemenin callback'inde paymentId boş gelir, conversationId dolu gelir.
        String conversationId = params.get("conversationId");
        EscrowPayment payment = conversationId == null || conversationId.isBlank()
                ? null
                : repository.findByConversationIdForUpdate(conversationId).orElse(null);
        if (payment == null) {
            log.warn("3DS callback bilinmeyen ödeme için geldi. paymentId={}", safeLong(params.get("paymentId")));
            return new CallbackOutcome(null, false);
        }
        Long sentPaymentId = safeLong(params.get("paymentId"));
        if (sentPaymentId != null && !sentPaymentId.equals(payment.getCraftgatePaymentId())) {
            log.warn("3DS callback ödeme numarası kayıtla uyuşmuyor. ref={}", payment.getRef());
            return new CallbackOutcome(null, false);
        }

        // Terk edilmiş sayılan ödemeye geç banka başarısı: para çekilmiş olabilir.
        if (payment.isAbandoned() && "SUCCESS".equalsIgnoreCase(params.get("status"))) {
            handleLateSuccess(payment);
            return outcomeOf(payment);
        }

        // Tekrarlanan callback: ilk sonuç geçerlidir, ödeme yeniden tamamlanmaz.
        if (payment.getStatus() != EscrowStatus.INITIALIZED) {
            return outcomeOf(payment);
        }

        if (!"SUCCESS".equalsIgnoreCase(params.get("status"))) {
            settleBankFailure(payment);
        } else {
            boolean needsComplete = "WAITING".equalsIgnoreCase(params.get("completeStatus"));
            Long paymentId = payment.getCraftgatePaymentId();
            GatewayPayment result = needsComplete ? completeOrRetrieve(paymentId) : retrieveOrNull(paymentId);
            applyResult(payment, result);
        }
        acceptIfLocked(payment);
        return outcomeOf(payment);
    }

    /**
     * Zamanlayıcı: callback hiç gelmemiş (kullanıcı WebView'i kapattı) veya işlenememiş (iş açılışı hata verdi)
     * eski INITIALIZED ödemeyi Craftgate'teki gerçek duruma göre kapatır. Belirsizse dokunmaz.
     */
    @Transactional
    public void reconcileStale(String ref) {
        reconcileStale(ref, Instant.now());
    }

    /**
     * Craftgate 3DS'i hâlâ sürüyor (INIT_THREEDS / CALLBACK_THREEDS) diyorsa kayıt ancak {@link #ABANDON_AFTER} dolunca
     * terk edilmiş sayılır: geç bir banka başarısı bu süre içinde normal yoldan işlenir. Kesin başarısızlık (FAILURE)
     * hemen kapatılır.
     */
    @Transactional
    public void reconcileStale(String ref, Instant now) {
        // SKIP LOCKED: gerçek callback satırı tutuyorsa beklemeden geçilir; sonraki tur sonucu görür.
        EscrowPayment payment = repository.findForUpdateSkipLocked(ref).orElse(null);
        if (payment == null || payment.getStatus() != EscrowStatus.INITIALIZED
                || payment.getChannel() != EscrowChannel.APP) {
            return;
        }
        if (payment.getCraftgatePaymentId() == null) {
            payment.fail("Ödeme oturumu açılamadı.");
            events.record(payment, EscrowEventType.FAILED, null, "SYSTEM", payment.getErrorCode());
            return;
        }
        GatewayPayment actual = retrieveOrNull(payment.getCraftgatePaymentId());
        if (actual != null && actual.status().threeDsUnfinished()) {
            if (payment.getCreatedAt().plus(ABANDON_AFTER).isAfter(now)) {
                // Banka sonucu hâlâ gelebilir: kapatılmaz, sonraki turda yeniden sorulur.
                log.debug("3DS hâlâ sürüyor, terk süresi dolmadı. ref={}", ref);
                return;
            }
            // Uzun süredir 3DS bitmedi: kullanıcı bankada vazgeçti. complete3ds hiç çağrılmadığı için para çekilmez.
            // PROCESSING (WAITING) burada kapatılmaz: banka sonucu bekleniyor, para çekilmiş olabilir. Yine de geç bir
            // başarı gelirse handleCallback onu yarış iadesi yoluna sokar.
            log.info("Terk edilmiş 3DS ödemesi kapatıldı. ref={}", ref);
            payment.abandon(THREEDS_ABANDONED_MESSAGE);
            events.record(payment, EscrowEventType.FAILED, null, "SYSTEM", payment.getErrorCode());
            return;
        }
        applyResult(payment, actual); // null (Craftgate yanıt vermedi): kayıt değişmez
        acceptIfLocked(payment);
    }

    /**
     * Yeni deneme isteği: talepteki INITIALIZED denemeler müşterinin kapattığı banka sayfası yüzünden 2 saat
     * ({@link #ABANDON_AFTER}) beklemesin. Her eski deneme satır kilidiyle ({@code SKIP LOCKED}) yeniden okunur ve
     * Craftgate'e eşzamanlı sorulur. Yalnızca deneme {@link #RETRY_ABANDON_AFTER}'dan eskiyse ve Craftgate 3DS'in
     * bankada hiç bitmediğini (INIT_THREEDS) söylüyorsa FAILED + THREEDS_ABANDONED olur: complete3ds hiç çağrılmadığı
     * için para çekilmemiştir. CALLBACK_THREEDS (banka dönüşü yolda olabilir), WAITING, başarı, yanıtsız Craftgate,
     * kilitli satır (callback ya da zamanlayıcı işliyor) veya genç deneme: false, yani 409 PAYMENT_IN_PROGRESS. Terk
     * edilen denemeye sonradan başarı gelirse {@link #handleLateSuccess} onu kabul ya da yarış iadesi yoluna sokar.
     */
    private boolean abandonUnfinishedAttempts(UUID requestId, Instant now) {
        for (String ref : repository.findRefsByRequestIdAndStatus(requestId, EscrowStatus.INITIALIZED)) {
            EscrowPayment old = repository.findForUpdateSkipLocked(ref).orElse(null);
            if (old == null) {
                return false; // banka dönüşü veya zamanlayıcı bu denemeyi şu an işliyor
            }
            if (old.getStatus() != EscrowStatus.INITIALIZED) {
                continue; // arada kapandı
            }
            if (old.getCreatedAt().plus(RETRY_ABANDON_AFTER).isAfter(now) || old.getCraftgatePaymentId() == null) {
                return false;
            }
            GatewayPayment actual = retrieveOrNull(old.getCraftgatePaymentId());
            if (actual == null || actual.status() != Status.IN_PROGRESS) {
                log.info("Yeni deneme bekletildi: önceki 3DS denemesi Craftgate'te {} durumunda. ref={}",
                        actual == null ? "bilinmiyor" : actual.status(), ref);
                return false;
            }
            log.info("Müşteri yeniden denedi; bankada bitmemiş önceki 3DS denemesi terk edildi. ref={}", ref);
            old.abandon(THREEDS_ABANDONED_MESSAGE);
            repository.saveAndFlush(old);
            events.record(old, EscrowEventType.FAILED, null, "SYSTEM", old.getErrorCode());
        }
        return true;
    }

    /** Zamanlayıcı: iade edilememiş öksüz (iş açılmamış) LOCKED ödemenin iadesini yeniden dener. */
    @Transactional
    public void retryOrphanRefund(String ref, Instant now) {
        EscrowPayment payment = repository.findForUpdateSkipLocked(ref).orElse(null);
        if (payment == null || payment.getStatus() != EscrowStatus.LOCKED || payment.getJobId() != null
                || payment.getChannel() != EscrowChannel.APP || payment.getErrorCode() == null
                || payment.needsRefundReview() || payment.getRefundAttempts() >= EscrowPayment.MAX_REFUND_ATTEMPTS
                || (payment.getNextRefundAttemptAt() != null && payment.getNextRefundAttemptAt().isAfter(now))) {
            return;
        }
        String reason = payment.getErrorCode();
        try {
            // İade Craftgate'te yapılmış ama yanıt bize ulaşmamış olabilir: önce sor, yapılmışsa yalnızca defteri düzelt.
            PaymentGateway.RefundState refunded = payment.isSeed() || payment.getCraftgatePaymentId() == null
                    ? PaymentGateway.RefundState.NOT_REFUNDED
                    : gateway.refundState(payment.getCraftgatePaymentId());
            if (refunded == PaymentGateway.RefundState.FULLY_REFUNDED) {
                log.warn("Ödeme Craftgate'te zaten iade edilmiş, yeniden iade gönderilmedi. ref={}", ref);
                escrow.recordRefundAlreadyDone(payment, "SYSTEM");
            } else if (refunded == PaymentGateway.RefundState.PARTIALLY_REFUNDED) {
                // Tam iade, kısmen iade edilmiş ödemede tutarı ve defteri bozar: elle incelenir.
                log.error("Öksüz ödeme Craftgate'te kısmen iade edilmiş, tam iade gönderilmedi; elle incelenmeli. "
                        + "ref={} paymentId={}", ref, payment.getCraftgatePaymentId());
                payment.sendToRefundReview(now);
                repository.saveAndFlush(payment);
                events.record(payment, EscrowEventType.REVIEW_REQUIRED, null, "SYSTEM", payment.getErrorCode());
                return;
            } else if (refunded == PaymentGateway.RefundState.REFUND_PENDING) {
                // Önceki iade isteği Craftgate'te sonuç bekliyor: ikinci iade gönderilmez, sonraki turda yeniden sorulur.
                throw new GatewayException("İade sonucu bekleniyor.", false);
            } else {
                escrow.refundFully(payment);
            }
            payment.clearUncertain();
            payment.markError(reason, messageFor(reason));
            repository.saveAndFlush(payment);
            // Gecikmeli iade tamamlandı: müşteri ödeme sonucunu bir daha açmadan öğrenir.
            escrowNotifications.refundCompleted(payment);
        } catch (GatewayException e) {
            if (payment.recordRefundFailure(now)) {
                events.record(payment, EscrowEventType.REVIEW_REQUIRED, null, "SYSTEM", payment.getErrorCode());
                log.error("Öksüz ödemenin iadesi {} denemede yapılamadı, elle incelenmeli. ref={} paymentId={}",
                        payment.getRefundAttempts(), ref, payment.getCraftgatePaymentId());
            } else {
                log.warn("Öksüz ödemenin iadesi yeniden başarısız. ref={} deneme={}", ref, payment.getRefundAttempts());
            }
            repository.saveAndFlush(payment);
        }
    }

    // ─── Prototip uç noktaları ──────────────────────────────────────────────

    @Transactional(readOnly = true)
    public PaymentView get(String ref) {
        return view(requirePrototype(repository.findById(ref).orElseThrow(PaymentService::notFound)));
    }

    @Transactional
    public PaymentView release(String ref) {
        EscrowPayment payment = lockRow(ref);
        payment.release();
        log.info("Güvence havuzu serbest bırakıldı. ref={} usta={} komisyon={}",
                ref, payment.getProPayout(), payment.getCommission());
        return view(payment);
    }

    @Transactional
    public PaymentView dispute(String ref) {
        EscrowPayment payment = lockRow(ref);
        payment.dispute();
        log.info("Güvence havuzu donduruldu. ref={}", ref);
        return view(payment);
    }

    @Transactional
    public PaymentView refund(String ref, RefundRequest.Type type) {
        EscrowPayment payment = lockRow(ref);
        if (type == RefundRequest.Type.FULL) {
            payment.requireRefundable();
            gateway.refundFully(payment.getCraftgatePaymentId(), payment.getConversationId());
            payment.refundFully();
        } else {
            payment.requireSplittable();
            gateway.refundPartially(
                    payment.getCraftgatePaymentId(), payment.splitRefundAmount(), payment.getConversationId());
            payment.settleSplit();
        }
        return view(payment);
    }

    // ─── İç yardımcılar ─────────────────────────────────────────────────────

    /** Ödeme LOCKED ise (uygulama kanalı) teklifi kabul edip iş açar; açamazsa tam iade eder. */
    private void acceptIfLocked(EscrowPayment payment) {
        if (payment.getStatus() != EscrowStatus.LOCKED || payment.getChannel() != EscrowChannel.APP
                || payment.getJobId() != null) {
            return;
        }
        JobOpening.Result r = jobOpening.open(payment.getRequestId(), UUID.fromString(payment.getOfferId()),
                payment.getCustomerId());
        if (r.opened()) {
            payment.attachJob(r.job().getId());
            repository.saveAndFlush(payment);
            return;
        }
        String code = r.errorCode();
        log.info("Teklif kabul edilemedi, ödeme iade ediliyor. ref={} neden={}", payment.getRef(), code);
        try {
            escrow.refundFully(payment);
            payment.markError(code, messageFor(code));
        } catch (GatewayException e) {
            // Para kartta kaldı. Kayıt LOCKED + işsiz + hata kodlu kalır; zamanlayıcı iadeyi yeniden dener.
            log.error("Otomatik iade başarısız, el ile veya zamanlayıcı ile iade gerekir. ref={}", payment.getRef());
            payment.markError(code, messageFor(code) + REFUND_PENDING_SUFFIX);
            payment.markUncertain();
            payment.recordRefundFailure(Instant.now());
        }
        repository.saveAndFlush(payment);
    }

    /**
     * Terk edilmiş (FAILED + THREEDS_ABANDONED) ödemeye geç banka başarısı geldi. Ödeme bizim tarafımızdan tamamlanmaz
     * (complete3ds çağrılmaz: müşteriye "ücret alınmadı" denmişti); yalnızca Craftgate'e sorulur. Craftgate ödemeyi
     * tutar ve conversationId uyumlu başarılı görüyorsa para çekilmiştir: kayıt LOCKED olur ve normal banka dönüşü yolundan
     * geçer (talep hâlâ açıksa teklif kabul edilir, değilse yarış iadesi; iade başarısızsa öksüz iade yeniden denemesi).
     * Craftgate başarı görmüyorsa (ör. hâlâ CALLBACK_THREEDS) kayıt değişmez.
     */
    private void handleLateSuccess(EscrowPayment payment) {
        GatewayPayment actual = retrieveOrNull(payment.getCraftgatePaymentId());
        if (actual == null || actual.status() != Status.SUCCESS) {
            log.warn("Terk edilmiş ödemeye geç başarı callback'i geldi ama Craftgate başarı görmüyor; değişiklik yok. ref={}",
                    payment.getRef());
            return;
        }
        boolean amountMatches = actual.paidPrice() != null
                && actual.paidPrice().compareTo(payment.getTotalAmount()) == 0;
        boolean conversationMatches = Objects.equals(actual.conversationId(), payment.getConversationId());
        if (!amountMatches || !conversationMatches) {
            log.error("Terk edilmiş ödemenin geç başarısı kayıtla uyuşmuyor, elle incelenmeli. ref={} paymentId={}",
                    payment.getRef(), actual.paymentId());
            return;
        }
        log.warn("Terk edilmiş ödeme Craftgate'te başarılı: para çekilmiş, normal banka dönüşü yolu işleniyor. ref={}",
                payment.getRef());
        payment.lockLateSuccess();
        repository.saveAndFlush(payment);
        events.record(payment, EscrowEventType.PAYMENT_LOCKED, payment.getTotalAmount(), "SYSTEM", "LATE_SUCCESS");
        acceptIfLocked(payment);
    }

    private static String messageFor(String code) {
        return JobOpening.REQUEST_ALREADY_ASSIGNED.equals(code) ? ALREADY_ASSIGNED_MESSAGE : OFFER_EXPIRED_MESSAGE;
    }

    private void settleBankFailure(EscrowPayment payment) {
        GatewayPayment actual = retrieveOrNull(payment.getCraftgatePaymentId());
        if (actual != null && actual.status() == Status.SUCCESS) {
            // Banka ret bildirdi ama Craftgate ödemeyi başarılı görüyor: gerçek durum geçerlidir.
            applyResult(payment, actual);
            return;
        }
        String group = actual == null ? null : actual.errorGroup();
        payment.fail(group == null ? BANK_DECLINED_MESSAGE : PaymentErrorMessages.forGroup(group));
        events.record(payment, EscrowEventType.FAILED, null, "SYSTEM", payment.getErrorCode());
    }

    private GatewayPayment completeOrRetrieve(Long paymentId) {
        try {
            return gateway.complete3ds(paymentId);
        } catch (GatewayException e) {
            // Tamamlama hata verdiyse paranın durumu ancak Craftgate'e sorularak öğrenilebilir.
            GatewayPayment actual = retrieveOrNull(paymentId);
            if (actual != null && actual.status().threeDsUnfinished() && !e.isConnectionProblem()) {
                return new GatewayPayment(paymentId, Status.FAILURE, null, actual.conversationId(), actual.errorGroup());
            }
            return actual;
        }
    }

    private GatewayPayment retrieveOrNull(Long paymentId) {
        try {
            return gateway.retrieve(paymentId);
        } catch (GatewayException e) {
            return null;
        }
    }

    /** result null veya sürüyor ise kayıt INITIALIZED kalır: para durumu bilinmeden sonuç yazılmaz. */
    private void applyResult(EscrowPayment payment, GatewayPayment result) {
        if (result == null || result.status().threeDsUnfinished() || result.status() == Status.PROCESSING) {
            log.warn("3DS sonucu kesinleşmedi, kayıt değiştirilmedi. ref={}", payment.getRef());
            return;
        }
        if (result.status() == Status.FAILURE) {
            payment.fail(PaymentErrorMessages.forGroup(result.errorGroup()));
            events.record(payment, EscrowEventType.FAILED, null, "SYSTEM", payment.getErrorCode());
            return;
        }
        boolean amountMatches = result.paidPrice() != null
                && result.paidPrice().compareTo(payment.getTotalAmount()) == 0;
        boolean conversationMatches = Objects.equals(result.conversationId(), payment.getConversationId());
        if (!amountMatches || !conversationMatches) {
            log.error("Craftgate yanıtı kayıtla uyuşmuyor, elle incelenmeli. ref={} paymentId={} tutarUyumlu={} conversationUyumlu={}",
                    payment.getRef(), result.paymentId(), amountMatches, conversationMatches);
            payment.failUnverified(UNVERIFIED_MESSAGE);
            events.record(payment, EscrowEventType.FAILED, null, "SYSTEM", payment.getErrorCode());
            return;
        }
        payment.lock();
        events.record(payment, EscrowEventType.PAYMENT_LOCKED, payment.getTotalAmount(), "SYSTEM");
    }

    private static CallbackOutcome outcomeOf(EscrowPayment payment) {
        return new CallbackOutcome(payment.getRef(), payment.getStatus() != EscrowStatus.INITIALIZED
                && payment.getStatus() != EscrowStatus.FAILED, payment.getChannel());
    }

    /** Prototip uç noktaları uygulama kanalı kayıtlarına dokunamaz (404): iş ve defter tutarlılığı korunur. */
    private EscrowPayment lockRow(String ref) {
        return requirePrototype(repository.findForUpdate(ref).orElseThrow(PaymentService::notFound));
    }

    private static EscrowPayment requirePrototype(EscrowPayment payment) {
        if (payment.getChannel() != EscrowChannel.PROTOTYPE) {
            throw notFound();
        }
        return payment;
    }

    private PaymentView view(EscrowPayment payment) {
        return PaymentView.from(payment, offers.require(payment.getOfferId()).proName());
    }

    private static ApiException inProgress() {
        return new ApiException(HttpStatus.CONFLICT, "PAYMENT_IN_PROGRESS",
                "Bu talep için devam eden bir ödeme var.");
    }

    private static UUID parseUuid(String value) {
        try {
            return UUID.fromString(value.trim());
        } catch (IllegalArgumentException e) {
            throw ApiException.notFound("Teklif bulunamadı.");
        }
    }

    private static NoSuchElementException notFound() {
        return new NoSuchElementException("Ödeme kaydı bulunamadı.");
    }

    private static Long safeLong(String value) {
        try {
            return value == null ? null : Long.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
