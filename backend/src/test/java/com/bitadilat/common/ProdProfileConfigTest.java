package com.bitadilat.common;

import static org.assertj.core.api.Assertions.assertThat;

import com.bitadilat.auth.LoggingEmailSender;
import com.bitadilat.common.security.SecurityConfig;
import com.bitadilat.dev.DevDataService;
import com.bitadilat.dev.DevResetController;
import com.bitadilat.dev.DevSeeder;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.Profile;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.cors.CorsConfigurationSource;

/**
 * prod profilinin sabit sır, açık OpenAPI, dev seeder veya yerel CORS deseni taşımadığını dosya ve anotasyon
 * düzeyinde doğrular (prod bağlamı gerçek EmailSender olmadan açılmadığı için bağlam kurulmaz).
 */
class ProdProfileConfigTest {

    private static Properties load(String name) throws Exception {
        Properties p = new Properties();
        try (InputStream in = Files.newInputStream(Path.of("src/main/resources", name))) {
            p.load(new java.io.InputStreamReader(in, java.nio.charset.StandardCharsets.UTF_8));
        }
        return p;
    }

    @Test
    void prodAndBaseHaveNoDefaultSecretsAndNoOpenApi() throws Exception {
        for (String file : new String[] {"application.properties", "application-prod.properties"}) {
            Properties p = load(file);
            assertThat(p.getProperty("bitadilat.jwt.secret")).as(file).isEqualTo("${JWT_SECRET}");
            assertThat(p.getProperty("bitadilat.crypto.address-key")).as(file).isEqualTo("${ADDRESS_KEY}");
            assertThat(p.getProperty("bitadilat.cors.allowed-origins")).as(file).isEqualTo("${CORS_ALLOWED_ORIGINS:}");
            assertThat(p.getProperty("springdoc.api-docs.enabled")).as(file).isEqualTo("false");
            assertThat(p.getProperty("springdoc.swagger-ui.enabled")).as(file).isEqualTo("false");
        }
    }

    @Test
    void mediaSigningKeyAndDirHaveNoDefaultInBaseAndProd() throws Exception {
        for (String file : new String[] {"application.properties", "application-prod.properties"}) {
            Properties p = load(file);
            assertThat(p.getProperty("bitadilat.media.signing-key")).as(file).isEqualTo("${MEDIA_SIGNING_KEY}");
            assertThat(p.getProperty("bitadilat.media.dir")).as(file).isEqualTo("${MEDIA_DIR}");
        }
        assertThat(load("application-dev.properties").getProperty("bitadilat.media.signing-key"))
                .startsWith("${MEDIA_SIGNING_KEY:");
        org.assertj.core.api.Assertions.assertThatThrownBy(
                () -> new com.bitadilat.media.MediaSigner("kisa-anahtar")).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void devOnlyBeansAreDevOnly() {
        for (Class<?> type : new Class<?>[] {DevDataService.class, DevSeeder.class, DevResetController.class}) {
            assertThat(type.getAnnotation(Profile.class).value()).as(type.getSimpleName()).containsExactly("dev");
        }
        assertThat(LoggingEmailSender.class.getAnnotation(Profile.class).value()).containsExactly("!prod");
    }

    @Test
    void emptyCorsSettingRegistersNoCorsConfiguration() throws Exception {
        var method = SecurityConfig.class.getDeclaredMethod("corsConfigurationSource", String.class);
        method.setAccessible(true);
        CorsConfigurationSource source = (CorsConfigurationSource) method.invoke(new SecurityConfig(), "");
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/v1/auth/login");
        request.addHeader("Origin", "http://localhost:5173");
        assertThat(source.getCorsConfiguration(request)).isNull();
    }

    /**
     * prod'da admin web origin'i tanımlıyken: 3DS banka yolları CORS dışıdır (yanıta izin başlığı da eklenmez),
     * /api/v1 ve eski /api/payments/3ds/init yalnız tanımlı origin'e açıktır, kimlik bilgili izin yoktur.
     */
    @Test
    void prodCorsExemptsOnlyBankPathsAndKeepsApiRestricted() throws Exception {
        var method = SecurityConfig.class.getDeclaredMethod("corsConfigurationSource", String.class);
        method.setAccessible(true);
        CorsConfigurationSource source =
                (CorsConfigurationSource) method.invoke(new SecurityConfig(), "https://admin.bitadilat.com");
        String bank = "https://sandbox-api.craftgate.io";

        assertThat(source.getCorsConfiguration(request("POST", "/api/payments/3ds/callback", bank))).isNull();
        assertThat(source.getCorsConfiguration(request("GET", "/api/payments/3ds/done", bank))).isNull();

        for (String path : new String[] {"/api/v1/auth/login", "/api/v1/payments/3ds/init",
                "/api/payments/3ds/init", "/api/payments/3ds/callback/x", "/api/payments/3ds/callbackx"}) {
            var config = source.getCorsConfiguration(request("POST", path, bank));
            assertThat(config).as(path).isNotNull();
            assertThat(config.checkOrigin(bank)).as(path).isNull();
            assertThat(config.checkOrigin("https://kotu.example")).as(path).isNull();
            assertThat(config.checkOrigin("https://admin.bitadilat.com")).as(path).isEqualTo("https://admin.bitadilat.com");
            assertThat(config.getAllowCredentials()).as(path).isNotEqualTo(Boolean.TRUE);
        }
    }

    private static MockHttpServletRequest request(String method, String path, String origin) {
        MockHttpServletRequest request = new MockHttpServletRequest(method, path);
        request.addHeader("Origin", origin);
        return request;
    }
}
