package com.bitadilat.common.security;

import org.springframework.security.core.AuthenticationException;

/** Geçerli token'ı olan ama askıya alınmış hesap. 401 ACCOUNT_SUSPENDED olarak yazılır. */
public class AccountSuspendedException extends AuthenticationException {

    public AccountSuspendedException() {
        super("Hesap askıya alınmış.");
    }
}
