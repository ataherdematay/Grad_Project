package com.bitadilat.payment.exception;

import lombok.Getter;

/** Mesajlar kart verisi içermez, kullanıcıya olduğu gibi gösterilebilir. */
@Getter
public class InvalidCardException extends RuntimeException {

    private final String field;

    public InvalidCardException(String field, String message) {
        super(message);
        this.field = field;
    }
}
