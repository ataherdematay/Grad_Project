package com.bitadilat.auth;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/** Yalnızca geliştirme/test: e-posta göndermez, kodu loga yazar. {@code prod} profilinde bean yoktur. */
@Slf4j
@Component
@Profile("!prod")
public class LoggingEmailSender implements EmailSender {

    @Override
    public void sendPasswordResetCode(String toEmail, String code) {
        log.info("[DEV] Şifre sıfırlama kodu to={} code={}", toEmail, code);
    }

    @Override
    public void sendEmailChangeCode(String toEmail, String code) {
        log.info("[DEV] E-posta değişikliği kodu to={} code={}", toEmail, code);
    }

    @Override
    public void sendEmailChangedNotice(String oldEmail) {
        log.info("[DEV] E-posta değişti bilgisi to={}", oldEmail);
    }
}
