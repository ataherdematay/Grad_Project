package com.bitadilat.payment.exception;

import com.bitadilat.common.ApiException;
import jakarta.servlet.http.HttpServletRequest;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.NoSuchElementException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

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

    /** Kimlik, hesap, katalog ve geliştirme uç noktalarının hataları: {code, message, field?}. */
    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String, Object>> api(ApiException e) {
        Map<String, Object> body = body(e.getCode(), e.getMessage());
        if (e.getField() != null) {
            body.put("field", e.getField());
        }
        return ResponseEntity.status(e.getStatus()).body(body);
    }

    /**
     * Doğrulama hatası: VALIDATION_FAILED + ilk hatalı alan. Girilen değer yanıta yazılmaz. Ödeme uç noktaları
     * eski davranışını (BAD_REQUEST) korur.
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> invalid(MethodArgumentNotValidException e, HttpServletRequest request) {
        boolean legacyPaymentApi = e.getParameter().getContainingClass().getPackageName().startsWith("com.bitadilat.payment")
                && !request.getRequestURI().startsWith("/api/v1/");
        if (legacyPaymentApi) {
            return ResponseEntity.badRequest().body(body("BAD_REQUEST", BAD_REQUEST));
        }
        FieldError first = e.getBindingResult().getFieldErrors().stream().findFirst().orElse(null);
        String message = first != null && first.getDefaultMessage() != null ? first.getDefaultMessage() : BAD_REQUEST;
        Map<String, Object> body = body("VALIDATION_FAILED", message);
        if (first != null) {
            body.put("field", first.getField());
        }
        return ResponseEntity.badRequest().body(body);
    }

    /** Okunamayan gövde. v1 sözleşmesinde 400 kodu VALIDATION_FAILED'dır; eski uç noktalar BAD_REQUEST'te kalır. */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Map<String, Object>> unreadable(HttpMessageNotReadableException e,
                                                          HttpServletRequest request) {
        String code = request.getRequestURI().startsWith("/api/v1/") ? "VALIDATION_FAILED" : "BAD_REQUEST";
        return ResponseEntity.badRequest().body(body(code, BAD_REQUEST));
    }

    /**
     * Yol veya sorgu parametresi türüne uymuyor (ör. UUID beklenen yerde "abc"). Yol kimliğinde kayıt "yok" sayılır
     * (404, varlık sızdırılmaz); diğer parametrelerde 400 + alan adı. Önceden genel işleyiciye düşüp 500 dönüyordu.
     */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<Map<String, Object>> typeMismatch(MethodArgumentTypeMismatchException e) {
        if (e.getParameter().hasParameterAnnotation(org.springframework.web.bind.annotation.PathVariable.class)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body("NOT_FOUND", "Kayıt bulunamadı."));
        }
        Map<String, Object> body = body("VALIDATION_FAILED", BAD_REQUEST);
        body.put("field", e.getName());
        return ResponseEntity.badRequest().body(body);
    }

    /**
     * Eşzamanlı iki işlem aynı satırı değiştirmeye çalıştı (sürüm çakışması). Kullanıcı açısından durum az önce
     * değişmiştir: 409 ILLEGAL_STATE, istemci yenileyip tekrar dener.
     */
    @ExceptionHandler({org.springframework.orm.ObjectOptimisticLockingFailureException.class,
            jakarta.persistence.OptimisticLockException.class})
    public ResponseEntity<Map<String, Object>> optimisticLock(Exception e) {
        log.info("İyimser kilit çakışması: {}", e.getClass().getSimpleName());
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(body("ILLEGAL_STATE", "Kayıt az önce başka bir işlemle değişti. Yenileyip tekrar deneyin."));
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
