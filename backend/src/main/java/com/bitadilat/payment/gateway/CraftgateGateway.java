package com.bitadilat.payment.gateway;

import com.bitadilat.payment.exception.GatewayException;
import io.craftgate.Craftgate;
import io.craftgate.exception.CraftgateException;
import io.craftgate.model.Currency;
import io.craftgate.model.PaymentGroup;
import io.craftgate.model.PaymentPhase;
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
                        .build()));
        requireRefundAccepted(response.getStatus(), paymentId);
        log.info("Tam iade yapıldı. paymentId={} refundId={} type={} amount={}",
                paymentId, response.getId(), response.getRefundType(), response.getRefundPrice());
    }

    @Override
    public void refundPartially(Long paymentId, BigDecimal amount, String conversationId) {
        PaymentResponse payment = call("retrieve", () -> craftgate.payment().retrievePayment(paymentId));
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
                        .build()));
        requireRefundAccepted(response.getStatus(), paymentId);
        log.info("Kısmi iade yapıldı. paymentId={} transactionId={} amount={}",
                paymentId, transactionId, response.getRefundPrice());
    }

    private static void requireRefundAccepted(RefundStatus status, Long paymentId) {
        if (status == RefundStatus.FAILURE) {
            log.warn("Craftgate iadeyi reddetti. paymentId={}", paymentId);
            throw new GatewayException("İade işlemi tamamlanamadı. Lütfen tekrar deneyin.", false);
        }
    }

    private static GatewayPayment toGatewayPayment(PaymentResponse response) {
        Status status = switch (response.getPaymentStatus()) {
            case SUCCESS -> Status.SUCCESS;
            case FAILURE -> Status.FAILURE;
            default -> Status.IN_PROGRESS;
        };
        String errorGroup = response.getPaymentError() == null ? null : response.getPaymentError().getErrorGroup();
        return new GatewayPayment(
                response.getId(), status, response.getPaidPrice(), response.getConversationId(), errorGroup);
    }

    private static <T> T call(String operation, Supplier<T> sdkCall) {
        try {
            return sdkCall.get();
        } catch (CraftgateException e) {
            // SDK bağlantı hatalarını "0" koduyla bildirir; bu durumda işlemin sonucu bilinmiyor demektir.
            boolean connectionProblem = SDK_GENERAL_ERROR_CODE.equals(e.getErrorCode());
            log.warn("Craftgate hatası. operation={} errorGroup={} errorCode={} description={} providerCode={}",
                    operation, e.getErrorGroup(), e.getErrorCode(), e.getErrorDescription(), e.getProviderErrorCode());
            throw new GatewayException(PaymentErrorMessages.forGroup(e.getErrorGroup()), connectionProblem);
        }
    }
}
