package com.bitadilat.payment.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Tutar bilerek yok: tutarı sunucu teklif üzerinden belirler. */
public record InitPaymentRequest(
        @NotBlank @Size(max = 64) String offerId,
        @NotBlank @Size(max = 64) String attemptKey,
        String cardHolderName,
        String cardNumber,
        String expireMonth,
        String expireYear,
        String cvc) {

    @Override
    public String toString() {
        return "InitPaymentRequest[offerId=" + offerId + ", attemptKey=" + attemptKey + ", kart=gizli]";
    }
}
