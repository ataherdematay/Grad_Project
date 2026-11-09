package com.bitadilat.common;

import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

/**
 * Çok büyük yükleme çerçeve sınırına takılırsa sözleşmedeki hata dönülür: 400 VALIDATION_FAILED, alan {@code file}.
 * Genel işleyiciden önce çalışsın diye en yüksek öncelikte.
 */
@RestControllerAdvice
@Order(Ordered.HIGHEST_PRECEDENCE)
public class UploadErrorAdvice {

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<Map<String, Object>> tooLarge(MaxUploadSizeExceededException e) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("code", "VALIDATION_FAILED");
        body.put("message", "Dosya çok büyük.");
        body.put("field", "file");
        return ResponseEntity.badRequest().body(body);
    }
}
