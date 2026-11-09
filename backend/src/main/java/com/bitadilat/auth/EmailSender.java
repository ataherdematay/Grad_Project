package com.bitadilat.auth;

/**
 * Şifre sıfırlama kodunu e-postayla gönderir. Gerçek uygulama prod'da sağlanmalıdır; bean yoksa uygulama açılmaz.
 * Dev ve testte {@link LoggingEmailSender} kodu loga yazar.
 */
public interface EmailSender {

    void sendPasswordResetCode(String toEmail, String code);
}
