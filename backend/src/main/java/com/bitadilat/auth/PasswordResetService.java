package com.bitadilat.auth;

import com.bitadilat.common.ApiException;
import com.bitadilat.common.Hashing;
import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import com.bitadilat.user.UserStatus;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 6 haneli kod, 15 dakika geçerli, 5 hatalı denemede geçersiz. Hesap başına saatte en fazla 5 kod üretilir:
 * aksi halde her yeni kodla 5 deneme daha kazanılır ve 10^6'lık alan sınırsız taranabilir (ayrıca e-posta bombası).
 */
@Slf4j
@Service
public class PasswordResetService {

    static final Duration CODE_TTL = Duration.ofMinutes(15);
    static final int MAX_ATTEMPTS = 5;
    static final int MAX_CODES_PER_WINDOW = 5;
    static final Duration CODE_WINDOW = Duration.ofHours(1);

    private final UserRepository users;
    private final PasswordResetCodeRepository codes;
    private final RefreshTokenRepository refreshTokens;
    private final PasswordEncoder encoder;
    private final EmailSender emailSender;
    private final SecureRandom random = new SecureRandom();

    public PasswordResetService(UserRepository users, PasswordResetCodeRepository codes,
                                RefreshTokenRepository refreshTokens, PasswordEncoder encoder,
                                EmailSender emailSender) {
        this.users = users;
        this.codes = codes;
        this.refreshTokens = refreshTokens;
        this.encoder = encoder;
        this.emailSender = emailSender;
    }

    /** Hesap var mı yok mu belli etmez; çağıran her zaman 202 döner. */
    @Transactional
    public void forgot(String email) {
        users.findByEmailIgnoreCase(email.trim())
                .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .ifPresent(this::issueCode);
    }

    private void issueCode(User user) {
        Instant now = Instant.now();
        if (codes.countByUserIdAndCreatedAtAfter(user.getId(), now.minus(CODE_WINDOW)) >= MAX_CODES_PER_WINDOW) {
            // Yanıt yine 202; sınır aşımı dışarıdan görünmez.
            log.warn("Şifre sıfırlama kodu sınırı aşıldı. kullanıcı={}", user.getId());
            return;
        }
        codes.invalidateAll(user.getId(), now);
        String code = String.format("%06d", random.nextInt(1_000_000));
        PasswordResetCode row = new PasswordResetCode();
        row.setUserId(user.getId());
        row.setCodeHash(hash(user, code));
        row.setExpiresAt(now.plus(CODE_TTL));
        codes.save(row);
        try {
            emailSender.sendPasswordResetCode(user.getEmail(), code);
        } catch (RuntimeException e) {
            // Gönderim hatası yanıtı değiştirmemeli (hesap varlığı sızar).
            log.error("Şifre sıfırlama e-postası gönderilemedi: {}", e.getClass().getSimpleName());
        }
    }

    @Transactional(noRollbackFor = ApiException.class)
    public void reset(String email, String code, String newPassword) {
        User user = users.findByEmailIgnoreCase(email.trim())
                .filter(u -> u.getStatus() == UserStatus.ACTIVE)
                .orElseThrow(PasswordResetService::invalid);
        Instant now = Instant.now();
        PasswordResetCode row = codes.findFirstByUserIdAndUsedAtIsNullOrderByCreatedAtDesc(user.getId())
                .orElseThrow(PasswordResetService::invalid);
        if (row.getExpiresAt().isBefore(now) || row.getAttempts() >= MAX_ATTEMPTS) {
            throw invalid();
        }
        boolean match = MessageDigest.isEqual(
                row.getCodeHash().getBytes(StandardCharsets.UTF_8),
                hash(user, code).getBytes(StandardCharsets.UTF_8));
        if (!match) {
            row.setAttempts(row.getAttempts() + 1);
            codes.save(row);
            throw invalid();
        }
        row.setUsedAt(now);
        codes.save(row);
        user.setPasswordHash(encoder.encode(newPassword));
        users.save(user);
        refreshTokens.revokeAllForUser(user.getId(), now);
    }

    private static String hash(User user, String code) {
        return Hashing.sha256Hex(user.getId() + ":" + code);
    }

    private static ApiException invalid() {
        return ApiException.validation("code", "Kod geçersiz veya süresi dolmuş.");
    }
}
