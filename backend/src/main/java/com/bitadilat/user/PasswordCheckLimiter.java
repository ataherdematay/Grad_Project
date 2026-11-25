package com.bitadilat.user;

import com.bitadilat.auth.LoginAttempt;
import com.bitadilat.auth.LoginAttemptRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.Hashing;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Oturum açıkken mevcut şifreyi soran uç noktalar ({@code /me/email}, {@code /me/password}) için hatalı deneme sınırı.
 * Kullanıcı ve uç nokta başına 15 dakikada {@value #MAX_FAILURES} hatalı şifreden sonra o uç nokta 429
 * {@code TOO_MANY_ATTEMPTS} döner; doğru şifre sayacı sıfırlar. Sayaç {@code login_attempts} tablosunda, anahtarın
 * SHA-256 özetiyle tutulur (girişteki sayaçtan ayrı anahtar). Çağıran işlem {@code noRollbackFor = ApiException}
 * olmalıdır, yoksa hatalı deneme kaydı geri alınır.
 */
@Component
public class PasswordCheckLimiter {

    static final int MAX_FAILURES = 5;
    static final Duration WINDOW = Duration.ofMinutes(15);

    /** Sınırlanan uç nokta; sayaçlar birbirinden bağımsızdır. */
    public enum Scope { EMAIL_CHANGE, PASSWORD_CHANGE }

    private final LoginAttemptRepository attempts;
    private final PasswordEncoder encoder;

    public PasswordCheckLimiter(LoginAttemptRepository attempts, PasswordEncoder encoder) {
        this.attempts = attempts;
        this.encoder = encoder;
    }

    /**
     * Şifreyi doğrular. Sınır doluysa şifreye bakmadan 429; yanlışsa hatalı deneme yazılır ve {@code field} alanıyla
     * 400; doğruysa sayaç sıfırlanır.
     */
    public void verify(UUID userId, Scope scope, String rawPassword, String passwordHash, String field,
                       String wrongMessage) {
        String hash = Hashing.sha256Hex("me-" + scope.name() + ":" + userId);
        attempts.lockIdentifier(hash);
        long failures = attempts.countByIdentifierHashAndSuccessFalseAndCreatedAtAfter(
                hash, Instant.now().minus(WINDOW));
        if (failures >= MAX_FAILURES) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "TOO_MANY_ATTEMPTS",
                    "Çok fazla hatalı şifre. 15 dakika sonra tekrar dene.");
        }
        if (rawPassword == null || !encoder.matches(rawPassword, passwordHash)) {
            LoginAttempt a = new LoginAttempt();
            a.setIdentifierHash(hash);
            a.setSuccess(false);
            attempts.save(a);
            throw ApiException.validation(field, wrongMessage);
        }
        if (failures > 0) {
            attempts.clearFailures(hash);
        }
    }
}
