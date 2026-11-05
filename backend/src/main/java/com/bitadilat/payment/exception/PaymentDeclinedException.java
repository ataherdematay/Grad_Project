package com.bitadilat.payment.exception;

import lombok.Getter;

/** Craftgate ödemeyi 3DS'e geçmeden reddetti. Kayıt FAILED olarak saklanmıştır. */
@Getter
public class PaymentDeclinedException extends RuntimeException {

    private final String ref;

    public PaymentDeclinedException(String ref, String message) {
        super(message);
        this.ref = ref;
    }
}
