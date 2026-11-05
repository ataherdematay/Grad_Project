package com.bitadilat.payment.gateway;

import java.util.HashMap;
import java.util.Map;

/**
 * Craftgate hata grubunu müşterinin anlayacağı Türkçe mesaja çevirir (craftgate projesinden
 * uyarlandı). Çalıntı kart veya sahtekârlık şüphesi gibi nedenler bilerek açıklanmaz; kart
 * deneyen birine ipucu vermemek için müşteri bankasına yönlendirilir.
 */
public final class PaymentErrorMessages {

    private static final String FALLBACK =
            "Ödeme tamamlanamadı. Lütfen farklı bir kart deneyin veya bankanızla görüşün.";
    private static final String ASK_YOUR_BANK =
            "Bankanız bu ödemeyi onaylamadı. Lütfen bankanızla görüşün veya farklı bir kart deneyin.";
    private static final String TRY_ANOTHER_CARD =
            "Bu kart bu ödeme için kullanılamıyor. Lütfen farklı bir kart deneyin.";
    private static final String TRY_AGAIN =
            "Bankaya şu anda ulaşılamıyor. Lütfen biraz sonra tekrar deneyin.";

    private static final Map<String, String> BY_GROUP = new HashMap<>();

    static {
        BY_GROUP.put("NOT_SUFFICIENT_FUNDS", "Kartınızın bakiyesi bu ödeme için yetersiz. Lütfen farklı bir kart deneyin.");
        BY_GROUP.put("EXCEEDS_WITHDRAWAL_AMOUNT_LIMIT", "Bu ödeme kartınızın harcama limitini aşıyor. Lütfen farklı bir kart deneyin.");

        BY_GROUP.put("EXPIRED_CARD", "Kartınızın süresi dolmuş. Son kullanma tarihini kontrol edin veya farklı bir kart deneyin.");
        BY_GROUP.put("INVALID_EXPIRE_YEAR_MONTH", "Son kullanma tarihi hatalı görünüyor. Lütfen ay ve yılı kontrol edin.");
        BY_GROUP.put("INVALID_CARD_NUMBER", "Kart numarası hatalı görünüyor. Lütfen kontrol edip tekrar deneyin.");
        BY_GROUP.put("BIN_NOT_FOUND", "Bu kart numarası tanınmadı. Lütfen kontrol edip tekrar deneyin.");
        BY_GROUP.put("NO_SUCH_ISSUER", "Bu kartın bankasına ulaşılamadı. Lütfen farklı bir kart deneyin.");
        BY_GROUP.put("INVALID_CVC2", "Güvenlik kodu (CVC) hatalı. Lütfen kartın arkasındaki kodu kontrol edin.");
        BY_GROUP.put("INVALID_CVC2_LENGTH", "Güvenlik kodunun (CVC) hane sayısı hatalı.");
        BY_GROUP.put("CVC_REQUIRED", "Bu kart için güvenlik kodu (CVC) gereklidir.");
        BY_GROUP.put("CVC2_MAX_ATTEMPT", "Güvenlik kodu çok kez hatalı girildi. Lütfen bankanızla görüşün.");

        for (String group : new String[] {"DO_NOT_HONOUR", "DECLINED", "FRAUD_SUSPECT", "LOST_CARD", "STOLEN_CARD",
                "PICKUP_CARD", "BLOCKED_CARD", "RESTRICTED_CARD", "REFER_TO_CARD_ISSUER",
                "EXCEEDS_ALLOWABLE_PIN_TRIES", "INVALID_PIN"}) {
            BY_GROUP.put(group, ASK_YOUR_BANK);
        }

        for (String group : new String[] {"CARD_NOT_PERMITTED", "NOT_PERMITTED_TO_CARDHOLDER",
                "NOT_PERMITTED_TO_FOREIGN_CARD", "INVALID_CARD_TYPE"}) {
            BY_GROUP.put(group, TRY_ANOTHER_CARD);
        }
        BY_GROUP.put("RESTRICTED_BY_LAW", "Bu kart internet alışverişine kapalı. Lütfen bankanızla görüşün veya farklı bir kart deneyin.");

        BY_GROUP.put("COMMUNICATION_OR_SYSTEM_ERROR", TRY_AGAIN);
        BY_GROUP.put("ISSUER_OR_SWITCH_INOPERATIVE", TRY_AGAIN);
        BY_GROUP.put("REQUEST_TIMEOUT", "Banka zamanında yanıt vermedi. Lütfen biraz sonra tekrar deneyin.");
        BY_GROUP.put("NO_RESPONSE", "Ödeme tamamlanamadı. Lütfen biraz sonra tekrar deneyin.");
        BY_GROUP.put("TOO_MANY_REQUESTS", "Kısa sürede çok fazla deneme yapıldı. Lütfen biraz bekleyip tekrar deneyin.");
    }

    private PaymentErrorMessages() {
    }

    public static String forGroup(String errorGroup) {
        if (errorGroup == null || errorGroup.isEmpty()) {
            return FALLBACK;
        }
        return BY_GROUP.getOrDefault(errorGroup, FALLBACK);
    }
}
