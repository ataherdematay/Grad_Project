package com.bitadilat.auth;

import static org.assertj.core.api.Assertions.assertThat;

import com.sun.net.httpserver.HttpServer;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.jupiter.api.Test;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

class ProdEmailSenderTest {

    private final ObjectMapper json = new ObjectMapper();

    @Test
    void skipsCleanlyWhenApiKeyIsBlank() {
        ProdEmailSender sender = new ProdEmailSender(json, "", "BiTadilat <noreply@bitadilat.test>",
                "http://127.0.0.1:9/emails");
        sender.sendPasswordResetCode("user@example.test", "123456");
    }

    @Test
    void postsResetCodeToConfiguredEndpointWhenApiKeyIsSet() throws Exception {
        AtomicReference<String> authHeader = new AtomicReference<>();
        AtomicReference<String> requestBody = new AtomicReference<>();

        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/emails", exchange -> {
            authHeader.set(exchange.getRequestHeaders().getFirst("Authorization"));
            requestBody.set(new String(exchange.getRequestBody().readAllBytes(), StandardCharsets.UTF_8));
            byte[] resp = "{\"id\":\"email-1\"}".getBytes(StandardCharsets.UTF_8);
            exchange.sendResponseHeaders(200, resp.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(resp);
            }
        });
        server.start();
        try {
            String url = "http://127.0.0.1:" + server.getAddress().getPort() + "/emails";
            ProdEmailSender sender = new ProdEmailSender(json, "re_test_key_123",
                    "BiTadilat <noreply@bitadilat.test>", url);
            sender.sendPasswordResetCode("ali@bitadilat.test", "654321");

            assertThat(authHeader.get()).isEqualTo("Bearer re_test_key_123");
            JsonNode parsed = json.readTree(requestBody.get());
            assertThat(parsed.get("to").get(0).asString()).isEqualTo("ali@bitadilat.test");
            assertThat(parsed.get("text").asString()).contains("654321");
        } finally {
            server.stop(0);
        }
    }
}
