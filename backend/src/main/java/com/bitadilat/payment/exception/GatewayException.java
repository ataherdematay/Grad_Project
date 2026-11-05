package com.bitadilat.payment.exception;

import lombok.Getter;

/** Craftgate çağrısı başarısız oldu. Mesaj kullanıcıya gösterilebilir, teknik ayrıntı loglanır. */
@Getter
public class GatewayException extends RuntimeException {

    private final boolean connectionProblem;

    public GatewayException(String message, boolean connectionProblem) {
        super(message);
        this.connectionProblem = connectionProblem;
    }
}
