package com.bitadilat.payment.exception;

public class DuplicateAttemptException extends RuntimeException {

    public DuplicateAttemptException() {
        super("Bu ödeme denemesi zaten başlatıldı.");
    }
}
