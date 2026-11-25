package com.bitadilat.media;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Optional;
import java.util.regex.Pattern;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Bulut nesne deposu (Supabase Storage REST API). {@code bitadilat.media.storage=supabase} (env {@code MEDIA_STORAGE=supabase})
 * seçildiğinde etkinleşir; iş/talep fotoğrafları, sohbet görselleri, şikayet kanıtları ve usta doğrulama belgeleri (PDF/JPEG/PNG)
 * yerel disk yerine özel (private) Supabase Storage bucket'ında saklanır.
 *
 * <p>İstemciler Supabase Storage'a doğrudan erişmez: yükleme ve HMAC imzalı erişim kontrolü {@link MediaService} üzerinden
 * yürütülür; backend ise {@code SUPABASE_SERVICE_ROLE_KEY} ile nesne deposuna bağlanır.
 */
@Slf4j
@Component
@ConditionalOnProperty(name = "bitadilat.media.storage", havingValue = "supabase")
public class SupabaseMediaStorage implements MediaStorage {

    private static final Pattern SAFE_BUCKET = Pattern.compile("^[a-zA-Z0-9._-]{1,100}$");
    private static final Pattern SAFE_KEY = Pattern.compile("^[a-zA-Z0-9._-]{1,200}$");
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(15);

    private final HttpClient http;
    private final String baseUrl;
    private final String serviceKey;
    private final String bucket;

    public SupabaseMediaStorage(
            @Value("${bitadilat.media.supabase.url:${SUPABASE_URL:}}") String supabaseUrl,
            @Value("${bitadilat.media.supabase.service-key:${SUPABASE_SERVICE_ROLE_KEY:}}") String serviceKey,
            @Value("${bitadilat.media.supabase.bucket:${SUPABASE_STORAGE_BUCKET:bitadilat-media}}") String bucket) {
        if (supabaseUrl == null || supabaseUrl.isBlank()) {
            throw new IllegalStateException("MEDIA_STORAGE=supabase iken SUPABASE_URL zorunludur.");
        }
        String trimmedUrl = supabaseUrl.trim().replaceAll("/+$", "");
        URI parsed = URI.create(trimmedUrl);
        if (parsed.getScheme() == null || (!"https".equalsIgnoreCase(parsed.getScheme())
                && !"http".equalsIgnoreCase(parsed.getScheme())) || parsed.getHost() == null) {
            throw new IllegalStateException("Geçersiz SUPABASE_URL: " + supabaseUrl);
        }
        if (serviceKey == null || serviceKey.isBlank()) {
            throw new IllegalStateException("MEDIA_STORAGE=supabase iken SUPABASE_SERVICE_ROLE_KEY zorunludur.");
        }
        if (bucket == null || !SAFE_BUCKET.matcher(bucket.trim()).matches()) {
            throw new IllegalStateException("Geçersiz SUPABASE_STORAGE_BUCKET: " + bucket);
        }
        this.http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
        this.baseUrl = trimmedUrl;
        this.serviceKey = serviceKey.trim();
        this.bucket = bucket.trim();
    }

    private URI objectUri(String key) {
        if (key == null || !SAFE_KEY.matcher(key).matches() || key.contains("..")) {
            throw new IllegalArgumentException("Geçersiz depolama anahtarı.");
        }
        String encodedKey = URLEncoder.encode(key, StandardCharsets.UTF_8).replace("+", "%20");
        return URI.create(baseUrl + "/storage/v1/object/" + bucket + "/" + encodedKey);
    }

    private HttpRequest.Builder authorized(URI uri) {
        return HttpRequest.newBuilder(uri)
                .timeout(REQUEST_TIMEOUT)
                .header("Authorization", "Bearer " + serviceKey)
                .header("apikey", serviceKey);
    }

    @Override
    public void store(String key, byte[] content) {
        if (content == null) {
            throw new IllegalArgumentException("Dosya içeriği boş olamaz.");
        }
        URI uri = objectUri(key);
        String contentType = FileTypes.detect(content);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        HttpRequest req = authorized(uri)
                .header("Content-Type", contentType)
                .header("x-upsert", "true")
                .POST(HttpRequest.BodyPublishers.ofByteArray(content))
                .build();
        try {
            HttpResponse<String> res = http.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (res.statusCode() < 200 || res.statusCode() >= 300) {
                log.error("Supabase Storage yazma hatası. key={} status={}", key, res.statusCode());
                throw new UncheckedIOException(new IOException(
                        "Supabase Storage dosya yazılamadı (HTTP " + res.statusCode() + ")"));
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new UncheckedIOException("Supabase Storage yazma işlemi kesildi", new IOException(e));
        } catch (IOException e) {
            throw new UncheckedIOException("Supabase Storage dosya yazılamadı", e);
        }
    }

    @Override
    public Optional<byte[]> load(String key) {
        URI uri = objectUri(key);
        HttpRequest req = authorized(uri).GET().build();
        try {
            HttpResponse<byte[]> res = http.send(req, HttpResponse.BodyHandlers.ofByteArray());
            if (res.statusCode() == 200) {
                return Optional.of(res.body());
            }
            // Supabase Storage nesne bulunamadığında 404 veya 400 ({"statusCode":"404","error":"not_found"}) döner.
            if (res.statusCode() == 404 || res.statusCode() == 400) {
                return Optional.empty();
            }
            log.error("Supabase Storage okuma hatası. key={} status={}", key, res.statusCode());
            throw new UncheckedIOException(new IOException(
                    "Supabase Storage dosya okunamadı (HTTP " + res.statusCode() + ")"));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new UncheckedIOException("Supabase Storage okuma işlemi kesildi", new IOException(e));
        } catch (IOException e) {
            throw new UncheckedIOException("Supabase Storage dosya okunamadı", e);
        }
    }

    @Override
    public void delete(String key) {
        URI uri = objectUri(key);
        HttpRequest req = authorized(uri).DELETE().build();
        try {
            HttpResponse<String> res = http.send(req, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if ((res.statusCode() >= 200 && res.statusCode() < 300)
                    || res.statusCode() == 404 || res.statusCode() == 400) {
                return;
            }
            log.error("Supabase Storage silme hatası. key={} status={}", key, res.statusCode());
            throw new UncheckedIOException(new IOException(
                    "Supabase Storage dosya silinemedi (HTTP " + res.statusCode() + ")"));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new UncheckedIOException("Supabase Storage silme işlemi kesildi", new IOException(e));
        } catch (IOException e) {
            throw new UncheckedIOException("Supabase Storage dosya silinemedi", e);
        }
    }
}
