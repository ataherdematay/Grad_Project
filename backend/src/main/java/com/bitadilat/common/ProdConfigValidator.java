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
                               @Value("${bitadilat.public-base-url:}") String publicBaseUrl,
                               @Value("${bitadilat.media.storage:local}") String mediaStorage,
                               @Value("${bitadilat.media.dir:}") String mediaDir,
                               @Value("${craftgate.api-key:}") String craftgateApiKey) {
        validate(corsOrigins, callbackKey, publicBaseUrl, mediaStorage, mediaDir, craftgateApiKey);
        if (corsOrigins.isBlank()) {
            log.warn("BITADILAT_CORS_ORIGINS boş: tarayıcıdan (admin web) çapraz origin isteği kabul edilmez.");
        }
    }

    /** Sahte (yerel demo) ödeme kipini açan CRAFTGATE_API_KEY öneki; prod'da yasaktır. */
    public static final String DEMO_API_KEY_PREFIX = "sandbox-demo";

    static void validate(String corsOrigins, String callbackKey, String publicBaseUrl, String mediaStorage,
                         String mediaDir, String craftgateApiKey) {
        if (craftgateApiKey != null && craftgateApiKey.trim().toLowerCase().startsWith(DEMO_API_KEY_PREFIX)) {
            throw new IllegalStateException(
                    "prod profilinde sahte ödeme kipi (CRAFTGATE_API_KEY 'sandbox-demo' ile başlıyor) kullanılamaz.");
        }
        boolean local = mediaStorage == null || mediaStorage.isBlank() || "local".equalsIgnoreCase(mediaStorage.trim());
        if (local && (mediaDir == null || mediaDir.isBlank())) {
            throw new IllegalStateException(
                    "prod profilinde MEDIA_STORAGE=local iken MEDIA_DIR zorunludur (supabase için gerekmez).");
        }
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
