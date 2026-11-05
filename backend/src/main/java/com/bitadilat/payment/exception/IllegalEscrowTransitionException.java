package com.bitadilat.payment.exception;

import com.bitadilat.payment.domain.EscrowStatus;

public class IllegalEscrowTransitionException extends RuntimeException {

    private final EscrowStatus current;

    public EscrowStatus getCurrent() {
        return current;
    }

    public IllegalEscrowTransitionException(EscrowStatus current) {
        super("Bu işlem ödemenin mevcut durumunda yapılamaz.");
        this.current = current;
    }
}
