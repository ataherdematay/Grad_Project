package com.bitadilat.common;

import java.util.Arrays;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Yalnızca prod: dev'de serbest olan ayarların prod'da güvenli olduğunu açılışta doğrular; değilse uygulama açılmaz.
 * JWT sırrı, adres anahtarı ve medya anahtarı kendi sınıflarında (uzunluk/biçim) doğrulanır; veritabanı değerleri
 * varsayılansızdır.
 */
@Slf4j
@Component
@Profile("prod")
public class ProdConfigValidator {

    public ProdConfigValidator(@Value("${bitadilat.cors.allowed-origins:}") String corsOrigins,
                               @Value("${craftgate.callback-key:}") String callbackKey,
                               @Value("${bitadilat.public-base-url:}") String publicBaseUrl) {
        validate(corsOrigins, callbackKey, publicBaseUrl);
        if (corsOrigins.isBlank()) {
            log.warn("BITADILAT_CORS_ORIGINS boş: tarayıcıdan (admin web) çapraz origin isteği kabul edilmez.");
        }
    }

    static void validate(String corsOrigins, String callbackKey, String publicBaseUrl) {
        if (callbackKey == null || callbackKey.isBlank()) {
            throw new IllegalStateException("prod profilinde CRAFTGATE_CALLBACK_KEY zorunludur.");
        }
        if (publicBaseUrl == null || publicBaseUrl.isBlank()) {
            throw new IllegalStateException("prod profilinde APP_PUBLIC_BASE_URL zorunludur.");
        }
        boolean wildcard = Arrays.stream(corsOrigins.split(",")).map(String::trim).anyMatch(o -> o.contains("*"));
        if (wildcard) {
            throw new IllegalStateException(
                    "prod profilinde BITADILAT_CORS_ORIGINS joker (*) içeremez; tam origin adreslerini yazın.");
        }
    }
}
