package com.bitadilat.payment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import com.bitadilat.payment.controller.PaymentController;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;
import org.junit.jupiter.api.Test;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

/**
 * Prod davranışı: prototip uç noktaları (ayar kapalı) 404 döner; banka dönüşü ve APP bitiş sayfası her profilde açık
 * kalır; v1 ödeme uç noktaları kimlik ister. (Prod profili sır ve gerçek e-posta göndericisi gerektirdiği için burada
 * yalnızca prod'un taşıdığı ayar durumu simüle edilir.)
 */
@SpringBootTest(properties = "bitadilat.prototype-api.enabled=false")
class PrototypeApiDisabledTest extends ApiTestBase {

    @MockitoBean
    private com.bitadilat.payment.gateway.PaymentGateway gateway;

    @Test
    void legacyEndpointsAre404WhenPrototypeApiIsOff() throws Exception {
        mvc.perform(get("/api/offers/OFFER-BD-88412")).andExpect(status().isNotFound());
        mvc.perform(post("/api/payments/3ds/init").contentType("application/json").content("{}"))
                .andExpect(status().isNotFound());
        mvc.perform(get("/api/payments/some-ref")).andExpect(status().isNotFound());
        mvc.perform(post("/api/payments/some-ref/release")).andExpect(status().isNotFound());
        mvc.perform(post("/api/payments/some-ref/refund").contentType("application/json").content("{\"type\":\"FULL\"}"))
                .andExpect(status().isNotFound());
    }

    @Test
    void callbackAndDoneStayOpenInEveryProfile() throws Exception {
        // Bilinmeyen ödeme için callback hata sayfası verir (404 değil); done sayfası kimliksiz açılır.
        mvc.perform(post("/api/payments/3ds/callback").param("status", "SUCCESS").param("conversationId", "yok"))
                .andExpect(status().isOk());
        mvc.perform(get("/api/payments/3ds/done").param("ref", "x")).andExpect(status().isOk());
    }

    @Test
    void v1PaymentEndpointsStayAndRequireAuthentication() throws Exception {
        mvc.perform(post("/api/v1/payments/3ds/init").contentType("application/json").content("{}"))
                .andExpect(status().isUnauthorized());
        mvc.perform(get("/api/v1/payments/x")).andExpect(status().isUnauthorized());
        Account a = register();
        call(org.springframework.http.HttpMethod.GET, "/api/v1/payments/x", a.access(), null)
                .andExpect(status().isNotFound());
    }

    @Test
    void settingsAreOffOutsideDev() throws Exception {
        ConditionalOnProperty condition = PaymentController.class.getAnnotation(ConditionalOnProperty.class);
        assertThat(condition.name()).containsExactly("bitadilat.prototype-api.enabled");
        assertThat(condition.havingValue()).isEqualTo("true");
        assertThat(load("application.properties").getProperty("bitadilat.prototype-api.enabled")).isNull();
        assertThat(load("application-prod.properties").getProperty("bitadilat.prototype-api.enabled")).isNull();
        assertThat(load("application-dev.properties").getProperty("bitadilat.prototype-api.enabled")).isEqualTo("true");
        // Callback ve done denetleyicisi koşulsuzdur.
        assertThat(com.bitadilat.payment.controller.ThreeDsCallbackController.class
                .getAnnotation(ConditionalOnProperty.class)).isNull();
        assertThat(com.bitadilat.payment.controller.PaymentV1Controller.class
                .getAnnotation(ConditionalOnProperty.class)).isNull();
    }

    private static Properties load(String name) throws Exception {
        Properties p = new Properties();
        try (InputStream in = Files.newInputStream(Path.of("src/main/resources", name))) {
            p.load(new java.io.InputStreamReader(in, StandardCharsets.UTF_8));
        }
        return p;
    }
}
