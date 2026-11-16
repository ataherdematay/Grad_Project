package com.bitadilat.payment.gateway;

import com.bitadilat.payment.exception.GatewayException;
import io.craftgate.Craftgate;
import io.craftgate.exception.CraftgateException;
import io.craftgate.model.Currency;
import io.craftgate.model.PaymentGroup;
import io.craftgate.model.PaymentPhase;
import io.craftgate.model.PaymentRefundStatus;
import io.craftgate.model.PaymentStatus;
import io.craftgate.model.RefundDestinationType;
import io.craftgate.model.RefundStatus;
import io.craftgate.request.CompleteThreeDSPaymentRequest;
import io.craftgate.request.InitThreeDSPaymentRequest;
import io.craftgate.request.RefundPaymentRequest;
import io.craftgate.request.RefundPaymentTransactionRequest;
import io.craftgate.request.dto.Card;
import io.craftgate.request.dto.PaymentItem;
import io.craftgate.response.InitThreeDSPaymentResponse;
import io.craftgate.response.PaymentRefundResponse;
import io.craftgate.response.PaymentResponse;
import io.craftgate.response.ReportingPaymentRefundResponse;
import io.craftgate.response.ReportingPaymentResponse;
import io.craftgate.response.ReportingPaymentTransactionRefundListResponse;
import io.craftgate.response.ReportingPaymentTransactionRefundResponse;
import io.craftgate.response.dto.ReportingPaymentTransaction;
import io.craftgate.response.PaymentTransactionRefundResponse;
import io.craftgate.response.dto.PaymentTransaction;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class CraftgateGateway implements PaymentGateway {

    private static final String SDK_GENERAL_ERROR_CODE = "0";
    static final String REFUND_FAILED =
            "İade Craftgate'te tamamlanamadı. Lütfen biraz sonra tekrar deneyin; sorun sürerse ödeme kaydını inceleyin.";
    static final String REFUND_STATUS_UNKNOWN =
            "Craftgate'teki iade durumu okunamadı; para hareketi yapılmadı. Lütfen biraz sonra tekrar deneyin.";

    private final Craftgate craftgate;
    private final String callbackKey;

    public CraftgateGateway(Craftgate craftgate, @Value("${craftgate.callback-key}") String callbackKey) {
        this.craftgate = craftgate;
        this.callbackKey = callbackKey;
    }

    @Override
    public ThreeDsSession init3ds(ThreeDsRequest request) {
        CardDetails details = request.card();
        Card card = Card.builder()
                .cardHolderName(details.holderName())
                .cardNumber(details.number())
                .expireMonth(details.expireMonth())
                .expireYear(details.expireYear())
                .cvc(details.cvc())
                .build();

        // Craftgate kısmi iadeyi kalem bazında yapar; tek kalem, %50 iadeyi doğrudan mümkün kılar.
        PaymentItem item = PaymentItem.builder()
                .name(request.itemName())
                .price(request.amount())
                .externalId(request.externalId())
                .build();

        InitThreeDSPaymentRequest init = InitThreeDSPaymentRequest.builder()
                .price(request.amount())
                .paidPrice(request.amount())
                .walletPrice(BigDecimal.ZERO)
                .installment(1)
                .conversationId(request.conversationId())
                .externalId(request.externalId())
                .currency(Currency.TRY)
                .paymentGroup(PaymentGroup.LISTING_OR_SUBSCRIPTION)
                .paymentPhase(PaymentPhase.AUTH)
                .callbackUrl(request.callbackUrl())
                .items(List.of(item))
                .card(card)
                .build();

        InitThreeDSPaymentResponse response = call("init3ds", () -> craftgate.payment().init3DSPayment(init));
        log.info("3DS başlatıldı. paymentId={} externalId={} status={}",
                response.getPaymentId(), request.externalId(), response.getPaymentStatus());
        return new ThreeDsSession(response.getPaymentId(), response.getDecodedHtmlContent(), response.getRedirectUrl());
    }

    @Override
    public GatewayPayment complete3ds(Long paymentId) {
        PaymentResponse response = call("complete3ds", () -> craftgate.payment().complete3DSPayment(
                CompleteThreeDSPaymentRequest.builder().paymentId(paymentId).build()));
        return toGatewayPayment(response);
    }

    @Override
    public GatewayPayment retrieve(Long paymentId) {
        return toGatewayPayment(call("retrieve", () -> craftgate.payment().retrievePayment(paymentId)));
    }

    @Override
    public RefundState refundState(Long paymentId) {
        ReportingPaymentResponse report = call("refundState",
                () -> craftgate.paymentReporting().retrievePayment(paymentId), REFUND_STATUS_UNKNOWN);
        if (report.getRefundStatus() == PaymentRefundStatus.FULLY_REFUNDED) {
            return RefundState.FULLY_REFUNDED;
        }
        List<ReportingPaymentRefundResponse> refunds = report.getRefunds() == null ? List.of() : report.getRefunds();
        if (refunds.stream().anyMatch(r -> r.getStatus() == RefundStatus.WAITING)) {
            return RefundState.REFUND_PENDING;
        }
        if (report.getRefundStatus() == PaymentRefundStatus.PARTIAL_REFUNDED
                || refunds.stream().anyMatch(r -> r.getStatus() == RefundStatus.SUCCESS)) {
            // Başarılı iade kaydı var ama toplam durum "tam iade" değil: tam iade gönderilmez.
            return RefundState.PARTIALLY_REFUNDED;
        }
        return RefundState.NOT_REFUNDED;
    }

    @Override
    public BigDecimal refundedTotal(Long paymentId) {
        ReportingPaymentResponse report = call("refundedTotal",
                () -> craftgate.paymentReporting().retrievePayment(paymentId), REFUND_STATUS_UNKNOWN);
        BigDecimal total = BigDecimal.ZERO;
        List<ReportingPaymentRefundResponse> refunds = report.getRefunds() == null ? List.of() : report.getRefunds();
        for (ReportingPaymentRefundResponse r : refunds) {
            total = total.add(count(r.getStatus(), r.getRefundPrice(), paymentId));
        }
        List<ReportingPaymentTransaction> transactions =
                report.getPaymentTransactions() == null ? List.of() : report.getPaymentTransactions();
        for (ReportingPaymentTransaction t : transactions) {
            ReportingPaymentTransactionRefundListResponse list = call("refundedTotal",
                    () -> craftgate.paymentReporting().retrievePaymentTransactionRefunds(paymentId, t.getId()),
                    REFUND_STATUS_UNKNOWN);
            for (ReportingPaymentTransactionRefundResponse r : list.getItems()) {
                total = total.add(count(r.getStatus(), r.getRefundPrice(), paymentId));
            }
        }
        return total;
    }

    private static BigDecimal count(RefundStatus status, BigDecimal price, Long paymentId) {
        if (status == RefundStatus.WAITING) {
            log.warn("Craftgate'te sonuç bekleyen iade var. paymentId={}", paymentId);
            throw new GatewayException("Önceki iade isteği sonuç bekliyor. Lütfen biraz sonra tekrar deneyin.", true);
        }
        return status == RefundStatus.SUCCESS && price != null ? price : BigDecimal.ZERO;
    }

    @Override
    public boolean isCallbackAuthentic(Map<String, String> params) {
        if (callbackKey == null || callbackKey.isBlank()) {
            return true;
        }
        return craftgate.payment().is3DSecureCallbackVerified(callbackKey, params);
    }

    @Override
    public void refundFully(Long paymentId, String conversationId) {
        PaymentRefundResponse response = call("refundFully", () -> craftgate.payment().refundPayment(
                RefundPaymentRequest.builder()
                        .paymentId(paymentId)
                        .conversationId(conversationId)
                        .refundDestinationType(RefundDestinationType.PROVIDER)
                        .build()), REFUND_FAILED);
        requireRefundAccepted(response.getStatus(), paymentId);
        log.info("Tam iade yapıldı. paymentId={} refundId={} type={} status={} amount={}",
                paymentId, response.getId(), response.getRefundType(), response.getStatus(),
                money(response.getRefundPrice()));
    }

    @Override
    public void refundPartially(Long paymentId, BigDecimal amount, String conversationId) {
        PaymentResponse payment = call("retrieve", () -> craftgate.payment().retrievePayment(paymentId),
                REFUND_FAILED);
        List<PaymentTransaction> transactions = payment.getPaymentTransactions();
        if (transactions == null || transactions.size() != 1) {
            log.error("Kısmi iade için tek kalem bekleniyordu. paymentId={}", paymentId);
            throw new GatewayException("İade yapılacak ödeme kalemi bulunamadı.", false);
        }
        Long transactionId = transactions.get(0).getId();

        PaymentTransactionRefundResponse response = call("refundPartially",
                () -> craftgate.payment().refundPaymentTransaction(RefundPaymentTransactionRequest.builder()
                        .paymentTransactionId(transactionId)
                        .refundPrice(amount)
                        .conversationId(conversationId)
                        .refundDestinationType(RefundDestinationType.PROVIDER)
                        .build()), REFUND_FAILED);
        requireRefundAccepted(response.getStatus(), paymentId);
        log.info("Kısmi iade yapıldı. paymentId={} transactionId={} refundId={} status={} amount={}",
                paymentId, transactionId, response.getId(), response.getStatus(), money(response.getRefundPrice()));
    }

    private static void requireRefundAccepted(RefundStatus status, Long paymentId) {
        if (status == RefundStatus.FAILURE) {
            log.warn("Craftgate iadeyi reddetti. paymentId={}", paymentId);
            throw new GatewayException(REFUND_FAILED, false);
        }
    }

    private static String money(BigDecimal value) {
        return value == null ? null : value.setScale(2, java.math.RoundingMode.HALF_UP).toPlainString();
    }

    private static GatewayPayment toGatewayPayment(PaymentResponse response) {
        // WAITING: tamamlama gönderildi, banka sonucu bekleniyor; para çekilmiş olabilir (IN_PROGRESS değil).
        PaymentStatus raw = response.getPaymentStatus();
        Status status = raw == null ? Status.PROCESSING : switch (raw) {
            case SUCCESS -> Status.SUCCESS;
            case FAILURE -> Status.FAILURE;
            case INIT_THREEDS -> Status.IN_PROGRESS;
            case CALLBACK_THREEDS -> Status.THREEDS_CALLBACK;
            default -> Status.PROCESSING;
        };
        String errorGroup = response.getPaymentError() == null ? null : response.getPaymentError().getErrorGroup();
        return new GatewayPayment(
                response.getId(), status, response.getPaidPrice(), response.getConversationId(), errorGroup);
    }

    private static <T> T call(String operation, Supplier<T> sdkCall) {
        return call(operation, sdkCall, null);
    }

    /**
     * {@code message} verilirse kullanıcıya o gösterilir (iade ve iade sorgusu): kart ödemesi hata metni ("farklı bir kart
     * deneyin") iade hatasında yanıltıcıdır. Verilmezse Craftgate hata grubu kart ödemesi mesajına çevrilir.
     */
    private static <T> T call(String operation, Supplier<T> sdkCall, String message) {
        try {
            return sdkCall.get();
        } catch (CraftgateException e) {
            // SDK bağlantı hatalarını "0" koduyla bildirir; bu durumda işlemin sonucu bilinmiyor demektir.
            boolean connectionProblem = SDK_GENERAL_ERROR_CODE.equals(e.getErrorCode());
            log.warn("Craftgate hatası. operation={} errorGroup={} errorCode={} description={} providerCode={}",
                    operation, e.getErrorGroup(), e.getErrorCode(), e.getErrorDescription(), e.getProviderErrorCode());
            throw new GatewayException(message != null ? message : PaymentErrorMessages.forGroup(e.getErrorGroup()),
                    connectionProblem);
        }
    }
}
