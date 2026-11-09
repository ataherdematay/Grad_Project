package com.bitadilat.auth;

import com.bitadilat.auth.dto.AuthResponse;
import com.bitadilat.auth.dto.LoginRequest;
import com.bitadilat.auth.dto.RegisterRequest;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.Hashing;
import com.bitadilat.common.PhoneNumbers;
import com.bitadilat.common.security.JwtService;
import com.bitadilat.user.AccountService;
import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import com.bitadilat.user.UserStatus;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Kayıt, giriş, refresh döndürme ve çıkış. Hata atan yöntemlerde {@code noRollbackFor = ApiException}
 * kullanılır: başarısız deneme kaydı ve reuse sonrası aile iptali geri alınmamalıdır.
 */
@Slf4j
@Service
public class AuthService {

    static final int MAX_FAILED_LOGINS = 5;
    static final Duration LOGIN_WINDOW = Duration.ofMinutes(15);
    static final Duration REFRESH_TTL = Duration.ofDays(30);

    private final UserRepository users;
    private final RefreshTokenRepository refreshTokens;
    private final LoginAttemptRepository attempts;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final AccountService accounts;
    private final SecureRandom random = new SecureRandom();
    private final String dummyHash;

    public AuthService(UserRepository users, RefreshTokenRepository refreshTokens, LoginAttemptRepository attempts,
                       PasswordEncoder encoder, JwtService jwt, AccountService accounts) {
        this.users = users;
        this.refreshTokens = refreshTokens;
        this.attempts = attempts;
        this.encoder = encoder;
        this.jwt = jwt;
        this.accounts = accounts;
        this.dummyHash = encoder.encode("zamanlama-esitleme-" + UUID.randomUUID());
    }

    // ─── Kayıt ──────────────────────────────────────────────────────────────

    /**
     * {@code wantsPro} yalnızca niyet bildirir; usta profili bu dalgada oluşturulmaz (başvuru ayrı uç noktada),
     * {@code lastMode} CUSTOMER kalır.
     */
    @Transactional
    public AuthResponse register(RegisterRequest r, String userAgent) {
        String email = r.email().trim();
        String phone = PhoneNumbers.normalize(r.phone());
        if (phone == null) {
            throw ApiException.validation("phone", "Telefon, geçerli bir Türkiye cep numarası olmalı (05xx ...).");
        }
        if (users.existsByEmailIgnoreCase(email)) {
            throw emailTaken();
        }
        if (users.existsByPhone(phone)) {
            throw phoneTaken();
        }
        Instant now = Instant.now();
        User user = new User();
        user.setFullName(r.fullName().trim());
        user.setEmail(email);
        user.setPhone(phone);
        user.setPasswordHash(encoder.encode(r.password()));
        user.setKvkkAcceptedAt(now);
        user.setTermsAcceptedAt(now);
        try {
            user = users.saveAndFlush(user);
        } catch (DataIntegrityViolationException e) {
            // Eşzamanlı kayıt yarışı: veritabanı benzersizlik kısıtı son sözü söyler.
            throw conflictFor(e);
        }
        return issueSession(user, UUID.randomUUID(), userAgent);
    }

    // ─── Giriş ──────────────────────────────────────────────────────────────

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse login(LoginRequest r, String ip, String userAgent) {
        String identifier = r.identifier().trim();
        boolean byEmail = identifier.contains("@");
        String phone = byEmail ? null : PhoneNumbers.normalize(identifier);
        Optional<User> found = byEmail ? users.findByEmailIgnoreCase(identifier)
                : (phone != null ? users.findByPhone(phone) : Optional.empty());
        // Sayaç anahtarı: hesap bulunduysa hesabın kendisi (e-posta, telefon ve tüm yazımlar tek sayaç),
        // bulunamadıysa normalleştirilmiş tanımlayıcı.
        String key = found.map(u -> "user:" + u.getId())
                .orElse("id:" + (phone != null ? phone : identifier.toLowerCase(Locale.ROOT)));
        String hash = Hashing.sha256Hex(key);

        attempts.lockIdentifier(hash);
        long failures = attempts.countByIdentifierHashAndSuccessFalseAndCreatedAtAfter(
                hash, Instant.now().minus(LOGIN_WINDOW));
        if (failures >= MAX_FAILED_LOGINS) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "TOO_MANY_ATTEMPTS",
                    "Çok fazla başarısız deneme. Bir süre sonra tekrar dene.");
        }

        // Kullanıcı yoksa da hash karşılaştırması yapılır: yanıt süresi hesap varlığını sızdırmasın.
        boolean passwordOk = encoder.matches(r.password(), found.map(User::getPasswordHash).orElse(dummyHash));
        User user = found.filter(u -> passwordOk && u.getStatus() != UserStatus.DELETED).orElse(null);
        if (user == null) {
            record(hash, ip, false);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "BAD_CREDENTIALS", "E-posta/telefon veya şifre hatalı.");
        }
        if (user.getStatus() == UserStatus.SUSPENDED) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "ACCOUNT_SUSPENDED", "Hesap askıya alınmış.");
        }
        attempts.clearFailures(hash);
        record(hash, ip, true);
        return issueSession(user, UUID.randomUUID(), userAgent);
    }

    private void record(String hash, String ip, boolean success) {
        LoginAttempt a = new LoginAttempt();
        a.setIdentifierHash(hash);
        a.setIp(ip);
        a.setSuccess(success);
        attempts.save(a);
    }

    // ─── Refresh döndürme ───────────────────────────────────────────────────

    @Transactional(noRollbackFor = ApiException.class)
    public AuthResponse refresh(String rawToken, String userAgent) {
        Instant now = Instant.now();
        RefreshToken current = refreshTokens.findByTokenHash(Hashing.sha256Hex(rawToken))
                .orElseThrow(() -> ApiException.unauthenticated("Refresh token geçersiz."));
        if (current.getRevokedAt() != null) {
            // Reuse tespiti: iptal edilmiş/eski token tekrar geldi, tüm aile iptal.
            refreshTokens.revokeFamily(current.getFamilyId(), now);
            log.warn("Refresh token yeniden kullanıldı, aile iptal edildi. aile={}", current.getFamilyId());
            throw ApiException.unauthenticated("Refresh token geçersiz.");
        }
        if (current.getExpiresAt().isBefore(now)) {
            // TOKEN_EXPIRED yalnızca access token içindir (istemci onu görünce yeniler); burada yeniden giriş gerekir.
            throw ApiException.unauthenticated("Refresh token'ın süresi doldu.");
        }
        User user = users.findById(current.getUserId())
                .orElseThrow(() -> ApiException.unauthenticated("Refresh token geçersiz."));
        if (user.getStatus() == UserStatus.DELETED) {
            refreshTokens.revokeFamily(current.getFamilyId(), now);
            throw ApiException.unauthenticated("Refresh token geçersiz.");
        }
        if (user.getStatus() == UserStatus.SUSPENDED) {
            refreshTokens.revokeFamily(current.getFamilyId(), now);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "ACCOUNT_SUSPENDED", "Hesap askıya alınmış.");
        }
        AuthResponse response = issueSession(user, current.getFamilyId(), userAgent);
        RefreshToken next = refreshTokens.findByTokenHash(Hashing.sha256Hex(response.refreshToken())).orElseThrow();
        current.setRevokedAt(now);
        current.setReplacedBy(next.getId());
        refreshTokens.save(current);
        return response;
    }

    @Transactional
    public void logout(String rawToken) {
        refreshTokens.findByTokenHash(Hashing.sha256Hex(rawToken))
                .ifPresent(t -> refreshTokens.revokeFamily(t.getFamilyId(), Instant.now()));
    }

    // ─── Ortak ──────────────────────────────────────────────────────────────

    private AuthResponse issueSession(User user, UUID familyId, String userAgent) {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        String raw = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        RefreshToken token = new RefreshToken();
        token.setUserId(user.getId());
        token.setTokenHash(Hashing.sha256Hex(raw));
        token.setFamilyId(familyId);
        token.setExpiresAt(Instant.now().plus(REFRESH_TTL));
        token.setUserAgent(userAgent == null ? null : userAgent.substring(0, Math.min(255, userAgent.length())));
        refreshTokens.saveAndFlush(token);
        return new AuthResponse(jwt.issueAccessToken(user.getId()), raw,
                (int) JwtService.ACCESS_TTL.toSeconds(), accounts.toMe(user));
    }

    /**
     * Eşzamanlı kayıt yarışında hangi benzersizlik kısıtının çiğnendiğini bulur. Hibernate mesajı SQL'i de içerdiği
     * için ("insert into users (..., phone, ...)") sütun adına değil kısıt adına bakılır.
     */
    static ApiException conflictFor(DataIntegrityViolationException e) {
        String message = e.getMostSpecificCause().getMessage();
        return message != null && message.contains("users_phone_key") ? phoneTaken() : emailTaken();
    }

    private static ApiException emailTaken() {
        return new ApiException(HttpStatus.CONFLICT, "EMAIL_TAKEN", "Bu e-posta ile kayıtlı bir hesap var.", "email");
    }

    private static ApiException phoneTaken() {
        return new ApiException(HttpStatus.CONFLICT, "PHONE_TAKEN", "Bu telefon ile kayıtlı bir hesap var.", "phone");
    }
}
