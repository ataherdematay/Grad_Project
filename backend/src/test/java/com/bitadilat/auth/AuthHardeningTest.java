package com.bitadilat.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.PlainJWT;
import com.nimbusds.jwt.SignedJWT;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;

/** Denetimde bulunan güvenlik açıklarının regresyon testleri. */
class AuthHardeningTest extends ApiTestBase {

    private static final String LOGIN = "/api/v1/auth/login";
    private static final String REFRESH = "/api/v1/auth/refresh";
    private static final String TEST_SECRET = "test-only-jwt-secret-0123456789abcdef-0123456789";

    // ─── Giriş sınırlaması ──────────────────────────────────────────────────

    @Test
    void emailAndPhoneShareOneFailureCounter() throws Exception {
        Account a = register();
        for (int i = 0; i < 3; i++) {
            call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email(), "password", "Yanlis123"))
                    .andExpect(status().isUnauthorized());
        }
        for (int i = 0; i < 2; i++) {
            call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.phone(), "password", "Yanlis123"))
                    .andExpect(status().isUnauthorized());
        }
        // 5 hata farklı yazımlarla dağıtıldı; yeni bir yazım sayacı sıfırlamaz.
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", "+90" + a.phone().substring(1).replace(" ", ""),
                        "password", PASSWORD))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("TOO_MANY_ATTEMPTS"));
        call(HttpMethod.POST, LOGIN, null, Map.of("identifier", a.email().toUpperCase(), "password", PASSWORD))
                .andExpect(status().isTooManyRequests());
    }

    @Test
    void parallelWrongPasswordsCannotExceedTheLimit() throws Exception {
        Account a = register();
        int parallel = 16;
        List<Integer> statuses = runInParallel(parallel, () -> call(HttpMethod.POST, LOGIN, null,
                Map.of("identifier", a.email(), "password", "Yanlis123")).andReturn().getResponse().getStatus());

        long badCredentials = statuses.stream().filter(s -> s == 401).count();
        long throttled = statuses.stream().filter(s -> s == 429).count();
        assertThat(badCredentials).as("BCrypt'e ulaşan deneme sayısı").isEqualTo(5);
        assertThat(throttled).isEqualTo(parallel - 5);
    }

    // ─── Refresh yarışı ve süresi ───────────────────────────────────────────

    @Test
    void parallelRefreshWithSameTokenYieldsAtMostOneSession() throws Exception {
        Account a = register();
        List<Integer> statuses = runInParallel(6, () -> call(HttpMethod.POST, REFRESH, null,
                Map.of("refreshToken", a.refresh())).andReturn().getResponse().getStatus());

        assertThat(statuses.stream().filter(s -> s == 200).count()).isLessThanOrEqualTo(1);
        // Tekrar kullanım tespit edildi: ailede geçerli token kalmadı.
        assertThat(jdbc.queryForObject(
                "select count(*) from refresh_tokens where user_id = ?::uuid and revoked_at is null",
                Long.class, a.id())).isZero();
    }

    @Test
    void expiredRefreshTokenIsUnauthenticatedNotTokenExpired() throws Exception {
        Account a = register();
        jdbc.update("update refresh_tokens set expires_at = now() - interval '1 minute' where user_id = ?::uuid",
                a.id());
        // TOKEN_EXPIRED istemciye "yenile" der; yenileme ucunun kendisi bunu dönerse istemci döngüye girer.
        call(HttpMethod.POST, REFRESH, null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
    }

    // ─── JWT doğrulama ──────────────────────────────────────────────────────

    private static JWTClaimsSet claims(String subject, String issuer) {
        Instant now = Instant.now();
        return new JWTClaimsSet.Builder().subject(subject).issuer(issuer).issueTime(Date.from(now))
                .expirationTime(Date.from(now.plus(Duration.ofMinutes(10)))).jwtID(UUID.randomUUID().toString())
                .build();
    }

    private static String sign(JWSAlgorithm alg, String secret, JWTClaimsSet claims) throws Exception {
        SignedJWT jwt = new SignedJWT(new JWSHeader(alg), claims);
        jwt.sign(new MACSigner(secret.getBytes(StandardCharsets.UTF_8)));
        return jwt.serialize();
    }

    private static String hmacToken(String alg, String jcaName, String secret, JWTClaimsSet claims) throws Exception {
        java.util.Base64.Encoder b64 = java.util.Base64.getUrlEncoder().withoutPadding();
        String signingInput = b64.encodeToString(("{\"alg\":\"" + alg + "\",\"typ\":\"JWT\"}")
                .getBytes(StandardCharsets.UTF_8)) + "." + b64.encodeToString(claims.toString()
                .getBytes(StandardCharsets.UTF_8));
        javax.crypto.Mac mac = javax.crypto.Mac.getInstance(jcaName);
        mac.init(new javax.crypto.spec.SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), jcaName));
        return signingInput + "." + b64.encodeToString(mac.doFinal(signingInput.getBytes(StandardCharsets.US_ASCII)));
    }

    @Test
    void unsignedAlgNoneTokenIsRejected() throws Exception {
        Account a = register();
        String none = new PlainJWT(claims(a.id(), "bitadilat")).serialize();
        call(HttpMethod.GET, "/api/v1/me", none, null)
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
    }

    @Test
    void onlyHs256WithOurSecretAndIssuerIsAccepted() throws Exception {
        Account a = register();
        // Kontrol: aynı sır, HS256, doğru issuer geçer (testin kendisi doğru kurulmuş mu?).
        call(HttpMethod.GET, "/api/v1/me", sign(JWSAlgorithm.HS256, TEST_SECRET, claims(a.id(), "bitadilat")), null)
                .andExpect(status().isOk());
        call(HttpMethod.GET, "/api/v1/me", hmacToken("HS256", "HmacSHA256", TEST_SECRET, claims(a.id(), "bitadilat")),
                null).andExpect(status().isOk());

        String otherSecret = sign(JWSAlgorithm.HS256, "baska-bir-sir-0123456789abcdef-0123456789", claims(a.id(),
                "bitadilat"));
        // Algoritma karışıklığı: sunucunun kendi sırrıyla ama HS512 imzalı token.
        String hs512SameKey = hmacToken("HS512", "HmacSHA512", TEST_SECRET, claims(a.id(), "bitadilat"));
        String wrongIssuer = sign(JWSAlgorithm.HS256, TEST_SECRET, claims(a.id(), "baskasi"));
        for (String token : new String[] {otherSecret, hs512SameKey, wrongIssuer}) {
            call(HttpMethod.GET, "/api/v1/me", token, null)
                    .andExpect(status().isUnauthorized())
                    .andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
        }
    }

    // ─── Şifre sıfırlama kaba kuvvet ────────────────────────────────────────

    @Test
    void forgotIssuesAtMostFiveCodesPerHour() throws Exception {
        Account a = register();
        for (int i = 0; i < 8; i++) {
            call(HttpMethod.POST, "/api/v1/auth/password/forgot", null, Map.of("email", a.email()))
                    .andExpect(status().isAccepted());
        }
        // Sınırsız yeni kod, kod başına 5 denemeyle 6 haneli alanı taramayı mümkün kılardı.
        assertThat(emails.sentTo(a.email())).isEqualTo(PasswordResetService.MAX_CODES_PER_WINDOW);
        assertThat(jdbc.queryForObject("select count(*) from password_reset_codes where user_id = ?::uuid",
                Long.class, a.id())).isEqualTo((long) PasswordResetService.MAX_CODES_PER_WINDOW);
        // Son geçerli kod hâlâ çalışır.
        call(HttpMethod.POST, "/api/v1/auth/password/reset", null,
                Map.of("email", a.email(), "code", emails.codeFor(a.email()), "newPassword", "YeniParola9"))
                .andExpect(status().isNoContent());
    }

    // ─── Prototip ve hata biçimi ────────────────────────────────────────────

    @Test
    void prototypeScreensCanStillBeFramedBySameOrigin() throws Exception {
        // preview/index.html ekranları aynı origin'den iframe ile açar; DENY prototipi boş bırakır.
        mvc.perform(get("/preview/index.html"))
                .andExpect(status().isOk())
                .andExpect(header().string("X-Frame-Options", "SAMEORIGIN"));
    }

    @Test
    void malformedJsonOnV1IsValidationFailed() throws Exception {
        mvc.perform(post(LOGIN).contentType(MediaType.APPLICATION_JSON).content("{bozuk"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
    }

    @Test
    void registrationRaceMapsConstraintToTheRightField() {
        var emailRace = new org.springframework.dao.DataIntegrityViolationException(
                "could not execute statement [ERROR: duplicate key value violates unique constraint "
                        + "\"ux_users_email_lower\"] [insert into users (email,full_name,phone) values (?,?,?)]");
        var phoneRace = new org.springframework.dao.DataIntegrityViolationException(
                "could not execute statement [ERROR: duplicate key value violates unique constraint "
                        + "\"users_phone_key\"] [insert into users (email,full_name,phone) values (?,?,?)]");
        assertThat(AuthService.conflictFor(emailRace).getCode()).isEqualTo("EMAIL_TAKEN");
        assertThat(AuthService.conflictFor(phoneRace).getCode()).isEqualTo("PHONE_TAKEN");
    }

    // ─── Yardımcı ───────────────────────────────────────────────────────────

    private static List<Integer> runInParallel(int n, Callable<Integer> task) throws Exception {
        ExecutorService pool = Executors.newFixedThreadPool(n);
        CountDownLatch start = new CountDownLatch(1);
        try {
            List<Future<Integer>> futures = new ArrayList<>();
            for (int i = 0; i < n; i++) {
                futures.add(pool.submit(() -> {
                    start.await();
                    return task.call();
                }));
            }
            start.countDown();
            List<Integer> out = new ArrayList<>();
            for (Future<Integer> f : futures) {
                out.add(f.get());
            }
            return out;
        } finally {
            pool.shutdownNow();
        }
    }
}
