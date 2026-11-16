package com.bitadilat.auth;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

/**
 * Yalnızca prod: SMTP ile gönderir. Ayarlar yalnızca ortamdan gelir (SPRING_MAIL_HOST/PORT/USERNAME/PASSWORD,
 * BITADILAT_MAIL_FROM). Eksikse uygulama açılışta durur; kod loga yazılmaz.
 */
@Slf4j
@Component
@Profile("prod")
public class SmtpEmailSender implements EmailSender {

    static final String NOT_CONFIGURED =
            "prod profilinde e-posta ayarı eksik: SPRING_MAIL_HOST ve BITADILAT_MAIL_FROM tanımlı olmalı "
                    + "(gerekirse SPRING_MAIL_PORT, SPRING_MAIL_USERNAME, SPRING_MAIL_PASSWORD).";

    private final JavaMailSender mailSender;
    private final String from;

    public SmtpEmailSender(ObjectProvider<JavaMailSender> mailSender,
                           @Value("${spring.mail.host:}") String host,
                           @Value("${bitadilat.mail.from:}") String from) {
        JavaMailSender sender = mailSender.getIfAvailable();
        if (sender == null || host == null || host.isBlank() || from == null || from.isBlank()) {
            throw new IllegalStateException(NOT_CONFIGURED);
        }
        this.mailSender = sender;
        this.from = from.trim();
    }

    @Override
    public void sendPasswordResetCode(String toEmail, String code) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(from);
        message.setTo(toEmail);
        message.setSubject("BiTadilat şifre sıfırlama kodunuz");
        message.setText("Şifre sıfırlama kodunuz: " + code + "\n\n"
                + "Kod kısa süre geçerlidir. Bu isteği siz yapmadıysanız bu e-postayı yok sayabilirsiniz.");
        mailSender.send(message);
        log.info("Şifre sıfırlama e-postası gönderildi.");
    }
}
