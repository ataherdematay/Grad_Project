package com.bitadilat.payment.gateway;

import java.math.BigDecimal;
import java.util.Map;

/**
 * Ödeme sağlayıcısıyla konuşulan tek nokta. Servis katmanı Craftgate SDK tiplerini görmez, bu
 * sayede iş kuralları sağlayıcı olmadan test edilebilir. Hatalarda GatewayException fırlatır.
 */
public interface PaymentGateway {

    record CardDetails(String holderName, String number, String expireMonth, String expireYear, String cvc) {
        /** Kayıtlara veya loga yanlışlıkla kart bilgisi düşmesini önler. */
        @Override
        public String toString() {
            return "CardDetails[gizli]";
        }
    }

    record ThreeDsRequest(
            BigDecimal amount,
            String conversationId,
            String externalId,
            String itemName,
            String callbackUrl,
            CardDetails card) {
        @Override
        public String toString() {
            return "ThreeDsRequest[externalId=" + externalId + "]";
        }
    }

    record ThreeDsSession(Long paymentId, String htmlContent, String redirectUrl) {
    }

    /** Ödemenin Craftgate'teki gerçek hali. Karar her zaman bu değerlere göre verilir. */
    record GatewayPayment(
            Long paymentId,
            Status status,
            BigDecimal paidPrice,
            String conversationId,
            String errorGroup) {
    }

    enum Status {
        SUCCESS,
        FAILURE,
        /** 3DS henüz bitmedi (INIT_THREEDS, CALLBACK_THREEDS, WAITING). */
        IN_PROGRESS
    }

    ThreeDsSession init3ds(ThreeDsRequest request);

    GatewayPayment complete3ds(Long paymentId);

    GatewayPayment retrieve(Long paymentId);

    /** Callback imzası. Callback anahtarı tanımlı değilse doğrulama yapılamaz ve true döner. */
    boolean isCallbackAuthentic(Map<String, String> params);

    void refundFully(Long paymentId, String conversationId);

    void refundPartially(Long paymentId, BigDecimal amount, String conversationId);
}
