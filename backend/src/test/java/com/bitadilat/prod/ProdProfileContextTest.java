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

/** prod profilini sahte ortam değerleriyle gerçekten açar; dev yardımcılarının bulunmadığını doğrular. */
@SpringBootTest(properties = {
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
        "BITADILAT_ADMIN_PASSWORD=Prod-Admin-2026-xyz1",
        "bitadilat.prototype-api.enabled=false"
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
                DevResetController.class, LoggingEmailSender.class, PreviewWebConfig.class,
                PaymentController.class}) {
            assertThat(ctx.getBeanNamesForType(type)).as(type.getSimpleName()).isEmpty();
        }
        assertThat(ctx.getBean(EmailSender.class)).isInstanceOf(SmtpEmailSender.class);
        assertThat(ctx.getBeanNamesForType(org.springdoc.webmvc.api.OpenApiWebMvcResource.class)).isEmpty();
    }

    @Test
    void devEndpointsAndApiDocsAreNotServed() throws Exception {
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNotFound());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/v3/api-docs"))
                .andExpect(status().isNotFound());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/swagger-ui/index.html"))
                .andExpect(status().isNotFound());
    }

    @Test
    void adminIsBootstrappedFromEnv() {
        var admin = users.findByEmailIgnoreCase("root@prodctx.test").orElseThrow();
        assertThat(admin.isAdmin()).isTrue();
    }
}
