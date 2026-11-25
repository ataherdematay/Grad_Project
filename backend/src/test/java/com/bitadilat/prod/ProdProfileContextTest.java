package com.bitadilat.prod;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.auth.EmailSender;
import com.bitadilat.auth.LoggingEmailSender;
import com.bitadilat.auth.SmtpEmailSender;
import com.bitadilat.dev.DevDataService;
import com.bitadilat.dev.DevResetController;
import com.bitadilat.dev.DevSeeder;
import com.bitadilat.payment.TestDatabaseConfig;
import com.bitadilat.payment.config.PreviewWebConfig;
import com.bitadilat.payment.controller.PaymentController;
import com.bitadilat.user.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

/**
 * prod profilini sahte ortam değerleriyle gerçekten açar; dev yardımcılarının bulunmadığını doğrular.
 * src/test/resources/application.properties ana dosyayı gölgelediği (ve prototip API'yi açtığı) için bağlam,
 * gerçek src/main/resources dosyalarıyla kurulur; yalnızca ortam değişkeni karşılıkları burada verilir.
 */
@SpringBootTest(properties = {
        "spring.config.location=file:src/main/resources/",
        "spring.flyway.clean-disabled=false",
        "bitadilat.jobs.expiry-interval=PT24H",
        "bitadilat.jobs.autocomplete-interval=PT24H",
        "bitadilat.jobs.payment-sweep-interval=PT24H",
        "CRAFTGATE_API_KEY=test-api-key",
        "CRAFTGATE_SECRET_KEY=test-secret-key",
        "DB_URL=${TEST_DB_URL:jdbc:postgresql://localhost:5432/bitadilat_test}",
        "DB_USER=${TEST_DB_USER:${USER}}",
        "DB_PASSWORD=${TEST_DB_PASSWORD:}",
        "BITADILAT_BIND=127.0.0.1",
        "APP_PUBLIC_BASE_URL=https://api.example.test",
        "JWT_SECRET=prod-test-jwt-secret-0123456789abcdef-0123456789",
        "ADDRESS_KEY=3HQaIRhGZ/HKzRvfo/figgtQosgoaA3T1GKbbBEEn5o=",
        "MEDIA_SIGNING_KEY=prod-test-media-signing-key-0123456789abcdef",
        "MEDIA_DIR=${java.io.tmpdir}/bitadilat-prod-test-media",
        "BITADILAT_CORS_ORIGINS=https://admin.example.test",
        "CRAFTGATE_CALLBACK_KEY=test-callback-key",
        "spring.mail.host=smtp.example.test",
        "BITADILAT_MAIL_FROM=no-reply@example.test",
        "BITADILAT_ADMIN_EMAIL=root@prodctx.test",
        "BITADILAT_ADMIN_PASSWORD=Prod-Admin-2026-xyz1"
})
@ActiveProfiles("prod")
@Import(TestDatabaseConfig.class)
@AutoConfigureMockMvc
class ProdProfileContextTest {

    @Autowired ApplicationContext ctx;
    @Autowired MockMvc mvc;
    @Autowired UserRepository users;

    @Test
    void devBeansAreAbsentAndSmtpSenderIsUsed() {
        for (Class<?> type : new Class<?>[] {DevSeeder.class, DevDataService.class,
                DevResetController.class, com.bitadilat.dev.DevProfileGuard.class, LoggingEmailSender.class,
                PreviewWebConfig.class, PaymentController.class}) {
            assertThat(ctx.getBeanNamesForType(type)).as(type.getSimpleName()).isEmpty();
        }
        // Paket içi DevJobSeeder dahil, com.bitadilat.dev paketinden hiçbir bean yok.
        for (String name : ctx.getBeanDefinitionNames()) {
            Class<?> type = ctx.getType(name);
            assertThat(type == null ? "" : type.getName()).as(name).doesNotStartWith("com.bitadilat.dev.");
        }
        assertThat(ctx.getBean(EmailSender.class)).isInstanceOf(SmtpEmailSender.class);
        assertThat(ctx.getBeanNamesForType(org.springdoc.webmvc.api.OpenApiWebMvcResource.class)).isEmpty();
    }

    @Test
    void realProdConfigIsLoadedAndErrorsCarryNoDetails() {
        var env = ctx.getEnvironment();
        assertThat(env.getProperty("server.address")).isEqualTo("127.0.0.1"); // BITADILAT_BIND
        assertThat(env.getProperty("bitadilat.prototype-api.enabled")).isNull();
        assertThat(env.getProperty("springdoc.api-docs.enabled")).isEqualTo("false");
        assertThat(env.getProperty("server.error.include-message")).isEqualTo("never");
        assertThat(env.getProperty("server.error.include-stacktrace")).isEqualTo("never");
        assertThat(env.getProperty("server.error.include-binding-errors")).isEqualTo("never");
        assertThat(env.getProperty("bitadilat.cors.allowed-origins")).isEqualTo("https://admin.example.test");
    }

    @Test
    void devEndpointsAndApiDocsAreNotServed() throws Exception {
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNotFound());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/v3/api-docs"))
                .andExpect(status().isNotFound());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/swagger-ui/index.html"))
                .andExpect(status().isNotFound());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/preview/index.html"))
                .andExpect(status().isNotFound());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/api/offers"))
                .andExpect(status().isNotFound());
    }

    @Test
    void adminIsBootstrappedFromEnv() {
        var admin = users.findByEmailIgnoreCase("root@prodctx.test").orElseThrow();
        assertThat(admin.isAdmin()).isTrue();
    }
}
