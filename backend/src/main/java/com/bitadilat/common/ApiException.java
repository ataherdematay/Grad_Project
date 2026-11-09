package com.bitadilat.common;

import lombok.Getter;
import org.springframework.http.HttpStatus;

/**
 * Uygulama hatası: HTTP durumu, makine okur {@code code}, geliştiriciye yönelik {@code message} ve
 * isteğe bağlı {@code field}. GlobalExceptionHandler bunu {code, message, field?} biçiminde yazar.
 */
@Getter
public class ApiException extends RuntimeException {

    private final HttpStatus status;
    private final String code;
    private final String field;

    public ApiException(HttpStatus status, String code, String message) {
        this(status, code, message, null);
    }

    public ApiException(HttpStatus status, String code, String message, String field) {
        super(message);
        this.status = status;
        this.code = code;
        this.field = field;
    }

    public static ApiException validation(String field, String message) {
        return new ApiException(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", message, field);
    }

    public static ApiException notFound(String message) {
        return new ApiException(HttpStatus.NOT_FOUND, "NOT_FOUND", message);
    }

    public static ApiException illegalState(String message) {
        return new ApiException(HttpStatus.CONFLICT, "ILLEGAL_STATE", message);
    }

    public static ApiException unauthenticated(String message) {
        return new ApiException(HttpStatus.UNAUTHORIZED, "UNAUTHENTICATED", message);
    }
}
