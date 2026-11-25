package com.bitadilat.media;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.sun.net.httpserver.HttpServer;
import java.io.OutputStream;
import java.io.UncheckedIOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class SupabaseMediaStorageTest {

    private static final String SERVICE_KEY = "sb_service_role_test_secret_key_12345";
    private static final String BUCKET = "bitadilat-media";
    private static final byte[] JPEG_BYTES = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 1, 2, 3, 4};
    private static final byte[] PDF_BYTES = "%PDF-1.4\npro-tax-certificate".getBytes(StandardCharsets.US_ASCII);

    private HttpServer server;
    private String baseUrl;
    private final Map<String, byte[]> bucketObjects = new ConcurrentHashMap<>();
    private final Map<String, String> objectContentTypes = new ConcurrentHashMap<>();
    private final AtomicReference<String> lastAuthHeader = new AtomicReference<>();
    private final AtomicReference<String> lastApiKeyHeader = new AtomicReference<>();
    private final AtomicReference<String> lastUpsertHeader = new AtomicReference<>();
    private volatile boolean simulateServerError = false;
    private volatile boolean simulateSupabase400NotFound = false;

    @BeforeEach
    void startFakeSupabaseStorage() throws Exception {
        bucketObjects.clear();
        objectContentTypes.clear();
        simulateServerError = false;
        simulateSupabase400NotFound = false;

        server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/storage/v1/object/" + BUCKET + "/", exchange -> {
            lastAuthHeader.set(exchange.getRequestHeaders().getFirst("Authorization"));
            lastApiKeyHeader.set(exchange.getRequestHeaders().getFirst("apikey"));
            lastUpsertHeader.set(exchange.getRequestHeaders().getFirst("x-upsert"));

            if (simulateServerError) {
                byte[] err = "{\"error\":\"InternalError\"}".getBytes(StandardCharsets.UTF_8);
                exchange.sendResponseHeaders(500, err.length);
                try (OutputStream os = exchange.getResponseBody()) {
                    os.write(err);
                }
                return;
            }

            String prefix = "/storage/v1/object/" + BUCKET + "/";
            String key = exchange.getRequestURI().getPath().substring(prefix.length());
            String method = exchange.getRequestMethod();

            if ("POST".equals(method) || "PUT".equals(method)) {
                byte[] body = exchange.getRequestBody().readAllBytes();
                bucketObjects.put(key, body);
                objectContentTypes.put(key, exchange.getRequestHeaders().getFirst("Content-Type"));
                byte[] ok = ("{\"Key\":\"" + BUCKET + "/" + key + "\"}").getBytes(StandardCharsets.UTF_8);
                exchange.sendResponseHeaders(200, ok.length);
                try (OutputStream os = exchange.getResponseBody()) {
                    os.write(ok);
                }
            } else if ("GET".equals(method)) {
                byte[] data = bucketObjects.get(key);
                if (data == null) {
                    int code = simulateSupabase400NotFound ? 400 : 404;
                    byte[] nf = "{\"statusCode\":\"404\",\"error\":\"not_found\"}".getBytes(StandardCharsets.UTF_8);
                    exchange.sendResponseHeaders(code, nf.length);
                    try (OutputStream os = exchange.getResponseBody()) {
                        os.write(nf);
                    }
                    return;
                }
                exchange.sendResponseHeaders(200, data.length);
                try (OutputStream os = exchange.getResponseBody()) {
                    os.write(data);
                }
            } else if ("DELETE".equals(method)) {
                bucketObjects.remove(key);
                objectContentTypes.remove(key);
                byte[] ok = "{\"message\":\"Successfully deleted\"}".getBytes(StandardCharsets.UTF_8);
                exchange.sendResponseHeaders(200, ok.length);
                try (OutputStream os = exchange.getResponseBody()) {
                    os.write(ok);
                }
            }
        });
        server.start();
        baseUrl = "http://127.0.0.1:" + server.getAddress().getPort();
    }

    @AfterEach
    void stopServer() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    void storesLoadsAndDeletesJobPhotosAndProDocumentsInSupabaseStorage() {
        SupabaseMediaStorage storage = new SupabaseMediaStorage(baseUrl, SERVICE_KEY, BUCKET);

        // 1. Job / Request Photo (JPEG)
        String photoKey = "d290f1ee-6c54-4b01-90e6-d701748f0851.jpg";
        storage.store(photoKey, JPEG_BYTES);

        assertThat(lastAuthHeader.get()).isEqualTo("Bearer " + SERVICE_KEY);
        assertThat(lastApiKeyHeader.get()).isEqualTo(SERVICE_KEY);
        assertThat(lastUpsertHeader.get()).isEqualTo("true");
        assertThat(objectContentTypes.get(photoKey)).isEqualTo("image/jpeg");
        assertThat(storage.load(photoKey)).contains(JPEG_BYTES);

        // 2. Pro Verification Document (PDF)
        String docKey = "f47ac10b-58cc-4372-a567-0e02b2c3d479.pdf";
        storage.store(docKey, PDF_BYTES);
        assertThat(objectContentTypes.get(docKey)).isEqualTo("application/pdf");
        assertThat(storage.load(docKey)).contains(PDF_BYTES);

        // 3. Delete & verify removal
        storage.delete(photoKey);
        assertThat(storage.load(photoKey)).isEmpty();

        // 4. Supabase Storage 400 (not_found) is also treated as Optional.empty()
        simulateSupabase400NotFound = true;
        assertThat(storage.load("non-existent-id.jpg")).isEmpty();
    }

    @Test
    void rejectsMissingConfigurationAndPathTraversalKeys() {
        assertThatThrownBy(() -> new SupabaseMediaStorage("", SERVICE_KEY, BUCKET))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("SUPABASE_URL");

        assertThatThrownBy(() -> new SupabaseMediaStorage(baseUrl, "   ", BUCKET))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("SUPABASE_SERVICE_ROLE_KEY");

        assertThatThrownBy(() -> new SupabaseMediaStorage(baseUrl, SERVICE_KEY, "../bad-bucket"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("SUPABASE_STORAGE_BUCKET");

        SupabaseMediaStorage storage = new SupabaseMediaStorage(baseUrl, SERVICE_KEY, BUCKET);
        for (String unsafeKey : new String[] {"", " ", "../secret.pdf", "a/b.jpg", "a\\b.jpg", ".."}) {
            assertThatThrownBy(() -> storage.store(unsafeKey, JPEG_BYTES))
                    .isInstanceOf(IllegalArgumentException.class);
            assertThatThrownBy(() -> storage.load(unsafeKey))
                    .isInstanceOf(IllegalArgumentException.class);
            assertThatThrownBy(() -> storage.delete(unsafeKey))
                    .isInstanceOf(IllegalArgumentException.class);
        }
    }

    @Test
    void propagatesServerFailuresAsUncheckedIOException() {
        SupabaseMediaStorage storage = new SupabaseMediaStorage(baseUrl, SERVICE_KEY, BUCKET);
        simulateServerError = true;

        assertThatThrownBy(() -> storage.store("photo.jpg", JPEG_BYTES))
                .isInstanceOf(UncheckedIOException.class);
        assertThatThrownBy(() -> storage.load("photo.jpg"))
                .isInstanceOf(UncheckedIOException.class);
        assertThatThrownBy(() -> storage.delete("photo.jpg"))
                .isInstanceOf(UncheckedIOException.class);
    }
}
