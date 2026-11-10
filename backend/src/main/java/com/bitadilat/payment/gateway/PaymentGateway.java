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
        /** 3DS henüz bitmedi, tamamlama yapılmadı (INIT_THREEDS, CALLBACK_THREEDS): para çekilmedi. */
        IN_PROGRESS,
        /** Banka sonucu bekleniyor (WAITING) veya durum bilinmiyor: para çekilmiş olabilir, kayıt kapatılmaz. */
        PROCESSING
    }

    ThreeDsSession init3ds(ThreeDsRequest request);

    GatewayPayment complete3ds(Long paymentId);

    GatewayPayment retrieve(Long paymentId);

    /** Ödemenin Craftgate'teki iade durumu. İade denemeden önce sorulur: iade zaten yapıldıysa tekrar gönderilmez. */
    RefundState refundState(Long paymentId);

    enum RefundState {
        NOT_REFUNDED,
        /** Kısmi iade yapılmış (ör. elle): tam iade gönderilmez, kayıt elle incelenir. */
        PARTIALLY_REFUNDED,
        /** Bir iade isteği Craftgate'te sonuç bekliyor: yeni iade gönderilmez, sonra yeniden sorulur. */
        REFUND_PENDING,
        FULLY_REFUNDED
    }

    /** Callback imzası. Callback anahtarı tanımlı değilse doğrulama yapılamaz ve true döner. */
    boolean isCallbackAuthentic(Map<String, String> params);

    void refundFully(Long paymentId, String conversationId);

    void refundPartially(Long paymentId, BigDecimal amount, String conversationId);
}
