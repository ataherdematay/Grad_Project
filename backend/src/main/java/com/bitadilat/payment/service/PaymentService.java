package com.bitadilat.payment.service;

import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.domain.Offer;
import com.bitadilat.payment.dto.InitPaymentRequest;
import com.bitadilat.payment.dto.InitPaymentResponse;
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
import java.time.YearMonth;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Objects;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Ödeme akışı ve güvence havuzu kuralları.
 *
 * Temel kural: callback parametreleri yalnızca bir işarettir. Ödemenin başarılı olduğuna, Craftgate
 * API'sinden dönen yanıta bakılarak karar verilir. Böylece sahte bir POST kaydı LOCKED yapamaz.
 */
@Slf4j
@Service
public class PaymentService {

    static final String UNVERIFIED_MESSAGE =
            "Ödeme sonucu doğrulanamadı. Kartınızı kontrol etmeden tekrar denemeyin; gerekirse destekle görüşün.";

    private static final String CALLBACK_PATH = "/api/payments/3ds/callback";
    private static final String BANK_DECLINED_MESSAGE =
            "3D Secure doğrulaması tamamlanamadı. Şifreyi kontrol edip tekrar deneyin veya farklı bir kart kullanın.";

    private final EscrowPaymentRepository repository;
    private final PaymentGateway gateway;
    private final OfferCatalog offers;
    private final String callbackUrl;

    public PaymentService(
            EscrowPaymentRepository repository,
            PaymentGateway gateway,
            OfferCatalog offers,
            @Value("${bitadilat.public-base-url}") String publicBaseUrl) {
        this.repository = repository;
        this.gateway = gateway;
        this.offers = offers;
        this.callbackUrl = publicBaseUrl.replaceAll("/+$", "") + CALLBACK_PATH;
    }

    /** Sonuç sayfasının kullanıcıyı nereye göndereceğini belirler. ref bilinmiyorsa null olur. */
    public record CallbackOutcome(String ref, boolean locked) {
    }

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

        // Tekrarlanan callback: ilk sonuç geçerlidir, ödeme yeniden tamamlanmaz.
        if (payment.getStatus() != EscrowStatus.INITIALIZED) {
            return outcomeOf(payment);
        }

        if (!"SUCCESS".equalsIgnoreCase(params.get("status"))) {
            settleBankFailure(payment);
            return outcomeOf(payment);
        }

        boolean needsComplete = "WAITING".equalsIgnoreCase(params.get("completeStatus"));
        Long paymentId = payment.getCraftgatePaymentId();
        GatewayPayment result = needsComplete ? completeOrRetrieve(paymentId) : retrieveOrNull(paymentId);
        applyResult(payment, result);
        return outcomeOf(payment);
    }

    @Transactional(readOnly = true)
    public PaymentView get(String ref) {
        return view(repository.findById(ref).orElseThrow(PaymentService::notFound));
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

    private void settleBankFailure(EscrowPayment payment) {
        GatewayPayment actual = retrieveOrNull(payment.getCraftgatePaymentId());
        if (actual != null && actual.status() == Status.SUCCESS) {
            // Banka ret bildirdi ama Craftgate ödemeyi başarılı görüyor: gerçek durum geçerlidir.
            applyResult(payment, actual);
            return;
        }
        String group = actual == null ? null : actual.errorGroup();
        payment.fail(group == null ? BANK_DECLINED_MESSAGE : PaymentErrorMessages.forGroup(group));
    }

    private GatewayPayment completeOrRetrieve(Long paymentId) {
        try {
            return gateway.complete3ds(paymentId);
        } catch (GatewayException e) {
            // Tamamlama hata verdiyse paranın durumu ancak Craftgate'e sorularak öğrenilebilir.
            GatewayPayment actual = retrieveOrNull(paymentId);
            if (actual != null && actual.status() == Status.IN_PROGRESS && !e.isConnectionProblem()) {
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
        if (result == null || result.status() == Status.IN_PROGRESS) {
            log.warn("3DS sonucu kesinleşmedi, kayıt değiştirilmedi. ref={}", payment.getRef());
            return;
        }
        if (result.status() == Status.FAILURE) {
            payment.fail(PaymentErrorMessages.forGroup(result.errorGroup()));
            return;
        }
        boolean amountMatches = result.paidPrice() != null
                && result.paidPrice().compareTo(payment.getTotalAmount()) == 0;
        boolean conversationMatches = Objects.equals(result.conversationId(), payment.getConversationId());
        if (!amountMatches || !conversationMatches) {
            log.error("Craftgate yanıtı kayıtla uyuşmuyor, elle incelenmeli. ref={} paymentId={} tutarUyumlu={} conversationUyumlu={}",
                    payment.getRef(), result.paymentId(), amountMatches, conversationMatches);
            payment.failUnverified(UNVERIFIED_MESSAGE);
            return;
        }
        payment.lock();
    }

    private static CallbackOutcome outcomeOf(EscrowPayment payment) {
        return new CallbackOutcome(payment.getRef(), payment.getStatus() != EscrowStatus.INITIALIZED
                && payment.getStatus() != EscrowStatus.FAILED);
    }

    private EscrowPayment lockRow(String ref) {
        return repository.findForUpdate(ref).orElseThrow(PaymentService::notFound);
    }

    private PaymentView view(EscrowPayment payment) {
        return PaymentView.from(payment, offers.require(payment.getOfferId()).proName());
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
