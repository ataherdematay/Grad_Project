package com.bitadilat.user;

import com.bitadilat.auth.EmailSender;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.Hashing;
import com.bitadilat.user.dto.Me;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Doğrulamalı e-posta değişikliği. Kullanıcı şifresini ve yeni adresi verir; yeni adrese 6 haneli kod gider (15 dk, 5
 * hatalı denemede geçersiz, saatte en çok 5 kod). Kod doğrulanmadan {@code users.email} değişmez. Değişince eski
 * adrese bilgi e-postası gider. Telefon değişikliği yoktur (SMS sağlayıcısı yok; telefon salt okunur).
 */
@Slf4j
@Service
public class EmailChangeService {

    static final Duration CODE_TTL = Duration.ofMinutes(15);
    static final int MAX_ATTEMPTS = 5;
    static final int MAX_CODES_PER_WINDOW = 5;
    static final Duration CODE_WINDOW = Duration.ofHours(1);

    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final EmailSender emailSender;
    private final JdbcTemplate jdbc;
    private final AccountService accounts;
    private final SecureRandom random = new SecureRandom();

    public EmailChangeService(UserRepository users, PasswordEncoder encoder, EmailSender emailSender,
                              JdbcTemplate jdbc, AccountService accounts) {
        this.users = users;
        this.encoder = encoder;
        this.emailSender = emailSender;
        this.jdbc = jdbc;
        this.accounts = accounts;
    }

    @Transactional
    public void request(UUID userId, String rawEmail, String password) {
        User user = users.findById(userId).orElseThrow(() -> ApiException.unauthenticated("Kullanıcı bulunamadı."));
        if (!encoder.matches(password, user.getPasswordHash())) {
            throw ApiException.validation("password", "Şifre yanlış.");
        }
        String email = rawEmail.trim();
        if (email.equalsIgnoreCase(user.getEmail())) {
            throw ApiException.validation("newEmail", "Yeni e-posta mevcut adresinle aynı.");
        }
        if (users.existsByEmailIgnoreCase(email)) {
            throw emailTaken();
        }
        Instant now = Instant.now();
        Integer recent = jdbc.queryForObject(
                "select count(*) from email_change_codes where user_id = ? and created_at > ?", Integer.class,
                userId, Timestamp.from(now.minus(CODE_WINDOW)));
        if (recent != null && recent >= MAX_CODES_PER_WINDOW) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "TOO_MANY_ATTEMPTS",
                    "Çok fazla kod istendi. Bir saat sonra tekrar dene.");
        }
        jdbc.update("update email_change_codes set used_at = ? where user_id = ? and used_at is null",
                Timestamp.from(now), userId);
        String code = String.format("%06d", random.nextInt(1_000_000));
        jdbc.update("insert into email_change_codes (user_id, new_email, code_hash, expires_at) values (?, ?, ?, ?)",
                userId, email, hash(userId, email, code), Timestamp.from(now.plus(CODE_TTL)));
        try {
            emailSender.sendEmailChangeCode(email, code);
        } catch (RuntimeException e) {
            // Kod kayıtlı kalır; kullanıcı yeniden isteyebilir. Kod loga yazılmaz.
            log.error("E-posta değişikliği kodu gönderilemedi: {}", e.getClass().getSimpleName());
        }
    }

    @Transactional(noRollbackFor = ApiException.class)
    public Me confirm(UUID userId, String code) {
        User user = users.findById(userId).orElseThrow(() -> ApiException.unauthenticated("Kullanıcı bulunamadı."));
        Instant now = Instant.now();
        List<Pending> rows = jdbc.query("""
                select id, new_email, code_hash, attempts, expires_at from email_change_codes
                where user_id = ? and used_at is null order by created_at desc limit 1 for update""",
                (rs, i) -> new Pending(rs.getObject("id", UUID.class), rs.getString("new_email"),
                        rs.getString("code_hash"), rs.getInt("attempts"), rs.getTimestamp("expires_at").toInstant()),
                userId);
        Pending row = rows.stream().findFirst().orElseThrow(EmailChangeService::invalid);
        if (row.expiresAt().isBefore(now) || row.attempts() >= MAX_ATTEMPTS) {
            throw invalid();
        }
        boolean match = MessageDigest.isEqual(row.codeHash().getBytes(StandardCharsets.UTF_8),
                hash(userId, row.newEmail(), code.trim()).getBytes(StandardCharsets.UTF_8));
        if (!match) {
            jdbc.update("update email_change_codes set attempts = attempts + 1 where id = ?", row.id());
            throw invalid();
        }
        jdbc.update("update email_change_codes set used_at = ? where id = ?", Timestamp.from(now), row.id());
        if (users.existsByEmailIgnoreCase(row.newEmail())) {
            throw emailTaken();
        }
        String old = user.getEmail();
        user.setEmail(row.newEmail());
        try {
            users.saveAndFlush(user);
        } catch (DataIntegrityViolationException e) {
            throw emailTaken();
        }
        try {
            emailSender.sendEmailChangedNotice(old);
        } catch (RuntimeException e) {
            log.error("E-posta değişikliği bilgi e-postası gönderilemedi: {}", e.getClass().getSimpleName());
        }
        return accounts.toMe(user);
    }

    private record Pending(UUID id, String newEmail, String codeHash, int attempts, Instant expiresAt) {
    }

    private static String hash(UUID userId, String email, String code) {
        return Hashing.sha256Hex(userId + ":" + email.toLowerCase(Locale.ROOT) + ":" + code);
    }

    private static ApiException invalid() {
        return ApiException.validation("code", "Kod geçersiz veya süresi dolmuş.");
    }

    private static ApiException emailTaken() {
        return new ApiException(HttpStatus.CONFLICT, "EMAIL_TAKEN", "Bu e-posta ile kayıtlı bir hesap var.",
                "newEmail");
    }
}
