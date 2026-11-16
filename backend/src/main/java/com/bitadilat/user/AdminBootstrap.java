package com.bitadilat.user;

import com.bitadilat.common.ValidPassword;
import java.nio.charset.StandardCharsets;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Yalnızca prod: hiç admin yoksa BITADILAT_ADMIN_EMAIL ve BITADILAT_ADMIN_PASSWORD ile ilk admini oluşturur.
 * Tekrar çalıştırılabilir (admin varsa hiçbir şey yapmaz). Şifre hiçbir yerde loga yazılmaz.
 * Ayar yoksa veya geçersizse ERROR loglar ve uygulama çalışmaya devam eder.
 */
@Slf4j
@Component
@Profile("prod")
public class AdminBootstrap implements ApplicationRunner {

    static final int MIN_PASSWORD_LENGTH = 12;

    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final String email;
    private final String password;

    public AdminBootstrap(UserRepository users, PasswordEncoder encoder,
                          @Value("${bitadilat.admin.email:}") String email,
                          @Value("${bitadilat.admin.password:}") String password) {
        this.users = users;
        this.encoder = encoder;
        this.email = email == null ? "" : email.trim();
        this.password = password == null ? "" : password;
    }

    @Override
    public void run(ApplicationArguments args) {
        ensureAdmin();
    }

    /** @return true yalnızca bu çağrıda admin oluşturulduysa. */
    public boolean ensureAdmin() {
        if (users.existsByAdminTrue()) {
            log.info("Admin hesabı mevcut; bootstrap atlandı.");
            return false;
        }
        if (email.isEmpty() || password.isEmpty()) {
            log.error("Sistemde admin hesabı yok ve BITADILAT_ADMIN_EMAIL / BITADILAT_ADMIN_PASSWORD tanımlı değil. "
                    + "Admin paneline kimse giremez; bu değişkenleri verip yeniden başlatın.");
            return false;
        }
        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            log.error("BITADILAT_ADMIN_EMAIL geçerli bir e-posta adresi değil; admin oluşturulmadı.");
            return false;
        }
        if (!isStrong(password)) {
            log.error("BITADILAT_ADMIN_PASSWORD zayıf (en az {} karakter, harf ve rakam içermeli, en çok 72 bayt); "
                    + "admin oluşturulmadı.", MIN_PASSWORD_LENGTH);
            return false;
        }
        if (users.existsByEmailIgnoreCase(email)) {
            log.error("BITADILAT_ADMIN_EMAIL ile kayıtlı mevcut bir kullanıcı var; yetki yükseltilmedi, "
                    + "admin oluşturulmadı.");
            return false;
        }
        User admin = new User();
        admin.setFullName("Administrator");
        admin.setEmail(email);
        admin.setPasswordHash(encoder.encode(password));
        admin.setAdmin(true);
        users.save(admin);
        log.info("İlk admin hesabı oluşturuldu: {}", email);
        return true;
    }

    static boolean isStrong(String value) {
        return value.length() >= MIN_PASSWORD_LENGTH
                && value.getBytes(StandardCharsets.UTF_8).length <= 72
                && ValidPassword.PasswordRules.isValid(value);
    }
}
