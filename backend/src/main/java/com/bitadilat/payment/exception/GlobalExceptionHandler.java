package com.bitadilat.payment.exception;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.NoSuchElementException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Tüm API hatalarını tek biçimde döner. Doğrulama ve okuma hatalarında gelen değerler yanıta ve
 * loga yazılmaz, çünkü istek gövdesinde kart bilgisi bulunur.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final String BAD_REQUEST = "Gönderilen bilgiler eksik veya geçersiz.";
    private static final String UNEXPECTED = "İşlem sırasında beklenmedik bir hata oluştu. Lütfen tekrar deneyin.";

    @ExceptionHandler(InvalidCardException.class)
    public ResponseEntity<Map<String, Object>> invalidCard(InvalidCardException e) {
        Map<String, Object> body = body("INVALID_CARD", e.getMessage());
        body.put("field", e.getField());
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(PaymentDeclinedException.class)
    public ResponseEntity<Map<String, Object>> declined(PaymentDeclinedException e) {
        Map<String, Object> body = body("PAYMENT_DECLINED", e.getMessage());
        body.put("ref", e.getRef());
        return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(body);
    }

    @ExceptionHandler(GatewayException.class)
    public ResponseEntity<Map<String, Object>> gateway(GatewayException e) {
        return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(body("GATEWAY_ERROR", e.getMessage()));
    }

    @ExceptionHandler(IllegalEscrowTransitionException.class)
    public ResponseEntity<Map<String, Object>> illegalTransition(IllegalEscrowTransitionException e) {
        Map<String, Object> body = body("ILLEGAL_STATE", e.getMessage());
        body.put("status", e.getCurrent());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(body);
    }

    @ExceptionHandler(DuplicateAttemptException.class)
    public ResponseEntity<Map<String, Object>> duplicate(DuplicateAttemptException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(body("DUPLICATE_ATTEMPT", e.getMessage()));
    }

    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<Map<String, Object>> notFound(NoSuchElementException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body("NOT_FOUND", e.getMessage()));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> unreadable(HttpMessageNotReadableException e) {
        return ResponseEntity.badRequest().body(body("BAD_REQUEST", BAD_REQUEST));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> unexpected(Exception e) {
        if (e instanceof ErrorResponse framework) {
            HttpStatusCode status = framework.getStatusCode();
            return ResponseEntity.status(status).body(body("BAD_REQUEST", BAD_REQUEST));
        }
        log.error("Beklenmedik hata: {}", e.getClass().getName(), e);
        return ResponseEntity.internalServerError().body(body("INTERNAL_ERROR", UNEXPECTED));
    }

    private static Map<String, Object> body(String code, String message) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("code", code);
        body.put("message", message);
        return body;
    }
}
