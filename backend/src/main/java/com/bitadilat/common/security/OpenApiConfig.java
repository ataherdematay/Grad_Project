package com.bitadilat.common.security;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger UI (/swagger-ui/index.html) üzerinde Bearer JWT "Authorize" butonunu ve
 * hazır demo hesap bilgilerini yapılandırır.
 */
@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "bearerAuth";

    @Bean
    public OpenAPI bitadilatOpenApi() {
        String description = """
                **BiTadilat — Ev Tadilat & Tamirat Hizmet Pazaryeri API (Spring Boot 4.1 + PostgreSQL + Craftgate Escrow)**

                ### Hazır Demo Hesapları (`POST /api/v1/auth/login` — Ortak Şifre: `Demo1234!`)
                - **Müşteri:** `ali@bitadilat.test` / `Demo1234!`
                - **Onaylı Usta:** `mehmet@bitadilat.test` / `Demo1234!` (*Mavi Hat Tesisat*)
                - **Onay Bekleyen Usta:** `hasan@bitadilat.test` / `Demo1234!` (*Yıldız Elektrik — PENDING_REVIEW*)
                - **Yönetici (Admin):** `admin@bitadilat.test` / `Demo1234!`

                ### Swagger Üzerinden Nasıl Test Edilir?
                1. `POST /api/v1/auth/login` uç noktasından giriş yapıp dönen `accessToken` değerini kopyalayın.
                2. Sağ üstteki **Authorize** butonuna tıklayıp token'ı yapıştırın.
                3. Tüm korumalı uç noktaları (`/api/v1/requests`, `/api/v1/jobs`, `/api/v1/admin/**`, `/api/v1/notifications`) canlı veritabanı üzerinde deneyebilirsiniz.
                """;

        return new OpenAPI()
                .info(new Info()
                        .title("BiTadilat REST API (v1)")
                        .version("1.0.0")
                        .description(description)
                        .contact(new Contact().name("BiTadilat Ekibi — Işık Üniversitesi Bitirme Projesi")))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("POST /api/v1/auth/login yanıtındaki accessToken değerini girin.")));
    }
}
