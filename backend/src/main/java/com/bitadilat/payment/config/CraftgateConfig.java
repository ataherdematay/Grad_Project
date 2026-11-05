package com.bitadilat.payment.config;

import io.craftgate.Craftgate;
import java.net.URI;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Craftgate SDK istemcisi. Bu servis yalnızca sandbox için tasarlandı (kart verisi backend'den
 * geçiyor, gerçek kimlik doğrulama yok), bu yüzden başka bir adresle uygulama hiç başlamaz.
 */
@Slf4j
@Configuration
public class CraftgateConfig {

    @Bean
    public Craftgate craftgateClient(
            @Value("${craftgate.api-key}") String apiKey,
            @Value("${craftgate.secret-key}") String secretKey,
            @Value("${craftgate.base-url}") String baseUrl,
            @Value("${craftgate.callback-key}") String callbackKey) {
        requireSandbox(baseUrl);
        if (apiKey.isBlank() || secretKey.isBlank()) {
            throw new IllegalStateException(
                    "CRAFTGATE_API_KEY ve CRAFTGATE_SECRET_KEY ortam değişkenleri tanımlı olmalı.");
        }
        if (callbackKey.isBlank()) {
            log.warn("CRAFTGATE_CALLBACK_KEY tanımlı değil: callback hash kontrolü yapılmayacak. "
                    + "Ödeme sonucu yine Craftgate API'sinden doğrulanır.");
        }
        return new Craftgate(apiKey, secretKey, baseUrl);
    }

    static void requireSandbox(String baseUrl) {
        String host = URI.create(baseUrl).getHost();
        if (host == null || !host.startsWith("sandbox-")) {
            throw new IllegalStateException(
                    "Bu servis yalnızca Craftgate sandbox ile çalışır. Geçersiz CRAFTGATE_BASE_URL: " + baseUrl);
        }
    }
}
