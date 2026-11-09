package com.bitadilat.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import java.time.Duration;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class AuthFlowTest extends ApiTestBase {

    private static final String LOGIN = "/api/v1/auth/login";
    private static final String REFRESH = "/api/v1/auth/refresh";

    // ─── Kayıt ──────────────────────────────────────────────────────────────

    @Test
    void registerReturnsTokensAndMe() throws Exception {
        String email = uniqueEmail();
        call(HttpMethod.POST, "/api/v1/auth/register", null, registerBody(email, uniquePhone()))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.accessExpiresIn").value(900))
                .andExpect(jsonPath("$.user.email").value(email))
                .andExpect(jsonPath("$.user.locale").value("tr"))
                .andExpect(jsonPath("$.user.lastMode").value("CUSTOMER"))
                .andExpect(jsonPath("$.user.isAdmin").value(false))
                .andExpect(jsonPath("$.user.status").value("ACTIVE"))
                .andExpect(jsonPath("$.user.pro").doesNotExist());
    }

    @Test
    void wantsProCreatesNoProProfile() throws Exception {
        Map<String, Object> req = new HashMap<>(registerBody(uniqueEmail(), uniquePhone()));
        req.put("wantsPro", true);
        JsonNode r = body(call(HttpMethod.POST, "/api/v1/auth/register", null, req).andExpect(status().isCreated()));
        String id = r.get("user").get("id").asString();

        assertThat(r.get("user").get("lastMode").asString()).isEqualTo("CUSTOMER");
        assertThat(r.get("user").get("pro").isNull()).isTrue();
        assertThat(jdbc.queryForObject("select count(*) from pro_profiles where user_id = ?::uuid", Long.class, id))
                .isZero();
    }

    @Test
    void registerNormalizesPhoneToE164() throws Exception {
        Account a = register();
        assertThat(jdbc.queryForObject("select phone from users where id = ?::uuid", String.class, a.id()))
                .matches("\\+90532\\d{7}");
    }

    @Test
    void duplicateEmailAndPhoneAreRejected() throws Exception {
        Account a = register();

        call(HttpMethod.POST, "/api/v1/auth/register", null,
                registerBody(a.email().toUpperCase(), uniquePhone()))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("EMAIL_TAKEN"));

        // Aynı numara farklı yazımla (+90 ...) da çakışır.
        String international = "+90 " + a.phone().substring(1).replace(" ", "");
        call(HttpMethod.POST, "/api/v1/auth/register", null, registerBody(uniqueEmail(), international))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("PHONE_TAKEN"));
    }

    @Test
    void validationErrorsNameTheField() throws Exception {
        assertField(Map.of("password", "abcdefgh"), "password");      // rakam yok
        assertField(Map.of("password", "12345678"), "password");      // harf yok
        assertField(Map.of("password", "Ab1"), "password");           // kısa
        assertField(Map.of("email", "bozuk"), "email");
        assertField(Map.of("phone", "0212 555 55 55"), "phone");     // cep değil
        assertField(Map.of("phone", "123"), "phone");
        assertField(Map.of("fullName", " "), "fullName");
        assertField(Map.of("kvkkAccepted", false), "kvkkAccepted");
        assertField(Map.of("termsAccepted", false), "termsAccepted");
    }

    private void assertField(Map<String, Object> override, String field) throws Exception {
        Map<String, Object> req = new HashMap<>(registerBody(uniqueEmail(), uniquePhone()));
        req.putAll(override);
        call(HttpMethod.POST, "/api/v1/auth/register", null, req)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.field").value(field));
    }

    // ─── Giriş ──────────────────────────────────────────────────────────────

    @Test
    void loginWorksWithEmailAndWithEveryPhoneSpelling() throws Exception {
        Account a = register();
        String digits = a.phone().replace(" ", "");           // 0532xxxxxxx
        String[] identifiers = {a.email(), a.email().toUpperCase(), a.phone(), digits,
                digits.substring(1), "+9" + digits, "+90 " + digits.substring(1, 4) + " " + digits.substring(4)};
        for (String identifier : identifiers) {
            call(HttpMethod.POST, LOGIN, null, Map.of("identifier", identifier, "password", PASSWORD))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.user.id").value(a.id()))
                    .andExpect(jsonPath("$.accessExpiresIn").value(900));
        }
    }

    @Test
    void wrongPasswordAndUnknownUserGiveSameError() throws Exception {
        Account a = register();
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", "Yanlis123"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("BAD_CREDENTIALS"));
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", "yok@example.test", "password", PASSWORD))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("BAD_CREDENTIALS"));
    }

    @Test
    void sixthFailedAttemptIsThrottledEvenWithCorrectPassword() throws Exception {
        Account a = register();
        for (int i = 0; i < 5; i++) {
            call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", "Yanlis123"))
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.code").value("BAD_CREDENTIALS"));
        }
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("TOO_MANY_ATTEMPTS"));
    }

    @Test
    void successfulLoginResetsFailureCount() throws Exception {
        Account a = register();
        for (int i = 0; i < 4; i++) {
            call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", "Yanlis123"))
                    .andExpect(status().isUnauthorized());
        }
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isOk());
        for (int i = 0; i < 4; i++) {
            call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", "Yanlis123"))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Test
    void suspendedAccountCannotLogin() throws Exception {
        Account a = register();
        jdbc.update("update users set status = 'SUSPENDED' where id = ?::uuid", a.id());

        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("ACCOUNT_SUSPENDED"));
        // Süresi dolmamış access token de reddedilir.
        call(HttpMethod.GET, "/api/v1/me", a.access(), null)
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("ACCOUNT_SUSPENDED"));
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("ACCOUNT_SUSPENDED"));
    }

    // ─── Refresh döndürme ───────────────────────────────────────────────────

    @Test
    void refreshRotatesAndStoresOnlyHash() throws Exception {
        Account a = register();
        JsonNode next = body(call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.user.id").value(a.id())));

        assertThat(next.get("refreshToken").asString()).isNotEqualTo(a.refresh());
        assertThat(next.get("accessToken").asString()).isNotBlank();
        // Düz token veritabanında yok, yalnızca SHA-256 özeti var; aynı aile korunur.
        assertThat(jdbc.queryForObject("select count(*) from refresh_tokens where token_hash in (?, ?)",
                Long.class, a.refresh(), next.get("refreshToken").asString())).isZero();
        assertThat(jdbc.queryForObject(
                "select count(distinct family_id) from refresh_tokens where user_id = ?::uuid", Long.class, a.id()))
                .isEqualTo(1L);
    }

    @Test
    void reusingOldRefreshTokenRevokesWholeFamily() throws Exception {
        Account a = register();
        JsonNode second = body(call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isOk()));
        String secondToken = second.get("refreshToken").asString();

        // Çalınmış/eski token tekrar kullanılıyor.
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));

        // Meşru sahibin güncel token'ı da artık geçersiz: tüm aile iptal.
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", secondToken))
                .andExpect(status().isUnauthorized());
        assertThat(jdbc.queryForObject(
                "select count(*) from refresh_tokens where user_id = ?::uuid and revoked_at is null",
                Long.class, a.id())).isZero();
    }

    @Test
    void logoutRevokesFamilyAndIsIdempotent() throws Exception {
        Account a = register();
        call(HttpMethod.POST, "/api/v1/auth/logout", null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isNoContent());
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized());
        call(HttpMethod.POST, "/api/v1/auth/logout", null, Map.of("refreshToken", "bilinmeyen-token"))
                .andExpect(status().isNoContent());
    }

    @Test
    void unknownRefreshTokenIsRejected() throws Exception {
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", "yok"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
    }

    // ─── Şifre sıfırlama ────────────────────────────────────────────────────

    @Test
    void forgotAlwaysAcceptedAndOnlySendsForKnownAccounts() throws Exception {
        Account a = register();
        String unknown = uniqueEmail();

        call(HttpMethod.POST, "/api/v1/auth/password/forgot", null, Map.of("email", unknown))
                .andExpect(status().isAccepted());
        call(HttpMethod.POST, "/api/v1/auth/password/forgot", null, Map.of("email", a.email()))
                .andExpect(status().isAccepted());

        assertThat(emails.sentTo(unknown)).isZero();
        assertThat(emails.codeFor(a.email())).matches("\\d{6}");
        // Kod veritabanında düz saklanmaz.
        assertThat(jdbc.queryForObject("select count(*) from password_reset_codes where code_hash = ?",
                Long.class, emails.codeFor(a.email()))).isZero();
    }

    @Test
    void resetFlowChangesPasswordAndEndsSessions() throws Exception {
        Account a = register();
        call(HttpMethod.POST, "/api/v1/auth/password/forgot", null, Map.of("email", a.email()))
                .andExpect(status().isAccepted());
        String code = emails.codeFor(a.email());
        String newPassword = "YeniParola9";

        // Yanlış kod ve zayıf şifre reddedilir.
        String wrong = code.equals("000000") ? "111111" : "000000";
        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", wrong, "newPassword", newPassword))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.field").value("code"));
        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", code, "newPassword", "zayif"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("newPassword"));

        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", code, "newPassword", newPassword))
                .andExpect(status().isNoContent());

        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", newPassword))
                .andExpect(status().isOk());
        // Eski oturum kapandı.
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized());
        // Kod tek kullanımlık.
        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", code, "newPassword", "BaskaParola7"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void fiveWrongAttemptsInvalidateTheCode() throws Exception {
        Account a = register();
        call(HttpMethod.POST, "/api/v1/auth/password/forgot", null, Map.of("email", a.email()))
                .andExpect(status().isAccepted());
        String code = emails.codeFor(a.email());
        String wrong = code.equals("000000") ? "111111" : "000000";

        for (int i = 0; i < 5; i++) {
            call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                    Map.of("email", a.email(), "code", wrong, "newPassword", "YeniParola9"))
                    .andExpect(status().isBadRequest());
        }
        // Doğru kod bile artık geçmez.
        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", code, "newPassword", "YeniParola9"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("code"));
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isOk());
    }

    @Test
    void expiredCodeIsRejected() throws Exception {
        Account a = register();
        call(HttpMethod.POST, "/api/v1/auth/password/forgot", null, Map.of("email", a.email()))
                .andExpect(status().isAccepted());
        jdbc.update("update password_reset_codes set expires_at = now() - interval '1 minute' where user_id = ?::uuid",
                a.id());

        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", emails.codeFor(a.email()), "newPassword", "YeniParola9"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("code"));
    }

    @Test
    void resetForUnknownEmailLooksLikeWrongCode() throws Exception {
        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", uniqueEmail(), "code", "123456", "newPassword", "YeniParola9"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("code"));
    }

    // ─── Güvenlik zinciri ───────────────────────────────────────────────────

    @Test
    void protectedEndpointWithoutTokenReturnsJson401() throws Exception {
        mvc.perform(get("/api/v1/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(header().string("Content-Type", org.hamcrest.Matchers.containsString("application/json")))
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"))
                .andExpect(jsonPath("$.message").isNotEmpty());
    }

    @Test
    void garbageTokenReturnsUnauthenticated() throws Exception {
        call(HttpMethod.GET, "/api/v1/me", "bu.bir.token.degil", null)
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
    }

    @Test
    void expiredAccessTokenReturnsTokenExpired() throws Exception {
        Account a = register();
        String expired = jwt.issueAccessToken(UUID.fromString(a.id()), Instant.now().minus(Duration.ofHours(1)));
        call(HttpMethod.GET, "/api/v1/me", expired, null)
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("TOKEN_EXPIRED"));
    }

    @Test
    void tokenSignedWithOtherSecretIsRejected() throws Exception {
        Account a = register();
        // Gerçek token'ın imzasını bozarak başka sırla imzalanmış gibi davran.
        String token = a.access();
        String tampered = token.substring(0, token.length() - 4) + (token.endsWith("AAAA") ? "BBBB" : "AAAA");
        call(HttpMethod.GET, "/api/v1/me", tampered, null)
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
    }

    @Test
    void staleBearerHeaderOnPublicEndpointDoesNotBreakIt() throws Exception {
        Account a = register();
        String expired = jwt.issueAccessToken(UUID.fromString(a.id()), Instant.now().minus(Duration.ofHours(1)));
        call(HttpMethod.GET, "/api/v1/categories", expired, null).andExpect(status().isOk());
        call(HttpMethod.POST, LOGIN, expired, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isOk());
    }

    @Test
    void prototypeEndpointsStayPublic() throws Exception {
        mvc.perform(get("/api/offers/OFFER-BD-88412"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalAmount").exists());
    }

    @Test
    void corsPreflightAllowsLocalOriginsOnly() throws Exception {
        mvc.perform(options(LOGIN)
                        .header("Origin", "http://localhost:5173")
                        .header("Access-Control-Request-Method", "POST")
                        .header("Access-Control-Request-Headers", "authorization,content-type"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));
        mvc.perform(options(LOGIN)
                        .header("Origin", "https://kotu.example")
                        .header("Access-Control-Request-Method", "POST"))
                .andExpect(status().isForbidden());
    }
}
