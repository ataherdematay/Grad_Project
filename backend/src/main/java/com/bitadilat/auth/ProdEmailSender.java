package com.bitadilat.auth;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import tools.jackson.databind.ObjectMapper;

/**
 * Canlı ({@code prod}) ortam için e-posta gönderici. Ücretsiz PaaS sağlayıcıları (Render, Railway, Fly.io) giden SMTP
 * (25/587) portlarını engellediği için HTTPS üzerinden Resend REST API ({@code https://api.resend.com/emails})
 * kullanılır. {@code RESEND_API_KEY} henüz tanımlanmamışsa uygulama yine açılır, gönderim sırasında uyarı loglanır.
 */
@Slf4j
@Component
@Profile("prod")
public class ProdEmailSender implements EmailSender {

    private final HttpClient http;
    private final ObjectMapper json;
    private final String apiKey;
    private final String fromAddress;
    private final URI endpoint;

    public ProdEmailSender(
            ObjectMapper json,
            @Value("${bitadilat.mail.resend-api-key:}") String apiKey,
            @Value("${bitadilat.mail.from:BiTadilat <onboarding@resend.dev>}") String fromAddress,
            @Value("${bitadilat.mail.resend-url:https://api.resend.com/emails}") String resendUrl) {
        this.http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
        this.json = json;
        this.apiKey = apiKey == null ? "" : apiKey.trim();
        this.fromAddress = fromAddress;
        this.endpoint = URI.create(resendUrl);
        if (this.apiKey.isEmpty()) {
            log.warn("RESEND_API_KEY tanımlı değil: prod ortamında şifre sıfırlama e-postaları gönderilmeyecek.");
        }
    }

    @Override
    public void sendPasswordResetCode(String toEmail, String code) {
        if (apiKey.isEmpty()) {
            log.warn("RESEND_API_KEY eksik olduğu için şifre sıfırlama e-postası gönderilemedi. to={}", toEmail);
            return;
        }
        try {
            String payload = json.writeValueAsString(Map.of(
                    "from", fromAddress,
                    "to", List.of(toEmail),
                    "subject", "BiTadilat Şifre Sıfırlama Kodunuz",
                    "text", "BiTadilat şifre sıfırlama kodunuz: " + code + "\nBu kod 10 dakika boyunca geçerlidir."));
            HttpRequest request = HttpRequest.newBuilder(endpoint)
                    .timeout(Duration.ofSeconds(10))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();
            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 200 && response.statusCode() < 300) {
                log.info("Şifre sıfırlama e-postası gönderildi. to={} status={}", toEmail, response.statusCode());
            } else {
                log.error("E-posta servisi hata döndü. to={} status={}", toEmail, response.statusCode());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Şifre sıfırlama e-postası gönderilirken kesinti oluştu. to={}", toEmail, e);
        } catch (Exception e) {
            log.error("Şifre sıfırlama e-postası gönderilemedi. to={}", toEmail, e);
        }
    }
}
