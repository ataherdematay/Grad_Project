package com.bitadilat.prod;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.bitadilat.auth.SmtpEmailSender;
import com.bitadilat.common.ProdConfigValidator;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.annotation.Profile;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

/** SMTP gönderici ve prod ayar doğrulayıcısı; gerçek e-posta gönderilmez. */
class ProdReadinessUnitTest {

    @SuppressWarnings("unchecked")
    private static ObjectProvider<JavaMailSender> provider(JavaMailSender sender) {
        ObjectProvider<JavaMailSender> p = mock(ObjectProvider.class);
        when(p.getIfAvailable()).thenReturn(sender);
        return p;
    }

    @Test
    void smtpSenderSendsResetCodeFromConfiguredAddress() {
        JavaMailSender mail = mock(JavaMailSender.class);
        SmtpEmailSender sender = new SmtpEmailSender(provider(mail), "smtp.example.test", "no-reply@example.test");
        sender.sendPasswordResetCode("user@example.test", "123456");

        ArgumentCaptor<SimpleMailMessage> msg = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mail).send(msg.capture());
        assertThat(msg.getValue().getFrom()).isEqualTo("no-reply@example.test");
        assertThat(msg.getValue().getTo()).containsExactly("user@example.test");
        assertThat(msg.getValue().getText()).contains("123456");
    }

    @Test
    void smtpSenderFailsFastWhenMailIsNotConfigured() {
        JavaMailSender mail = mock(JavaMailSender.class);
        assertThatThrownBy(() -> new SmtpEmailSender(provider(null), "", "a@b.test"))
                .isInstanceOf(IllegalStateException.class).hasMessageContaining("SPRING_MAIL_HOST");
        assertThatThrownBy(() -> new SmtpEmailSender(provider(mail), "", "a@b.test"))
                .isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new SmtpEmailSender(provider(mail), "smtp.example.test", " "))
                .isInstanceOf(IllegalStateException.class).hasMessageContaining("BITADILAT_MAIL_FROM");
    }

    @Test
    void smtpSenderIsProdOnly() {
        assertThat(SmtpEmailSender.class.getAnnotation(Profile.class).value()).containsExactly("prod");
    }

    @Test
    void validatorRequiresCallbackKeyAndRejectsWildcardCors() {
        assertThatCode(() -> new ProdConfigValidator("https://admin.example.test", "key", "https://api.example.test"))
                .doesNotThrowAnyException();
        assertThatThrownBy(() -> new ProdConfigValidator("https://admin.example.test", "", "https://api.example.test"))
                .hasMessageContaining("CRAFTGATE_CALLBACK_KEY");
        assertThatThrownBy(() -> new ProdConfigValidator("*", "key", "https://api.example.test"))
                .hasMessageContaining("joker");
        assertThatThrownBy(() -> new ProdConfigValidator("https://a.test,https://*.example.test", "key", "https://x"))
                .hasMessageContaining("joker");
        assertThatThrownBy(() -> new ProdConfigValidator("", "key", ""))
                .hasMessageContaining("APP_PUBLIC_BASE_URL");
    }

    @SuppressWarnings("unused")
    private static void unused() {
        any();
    }
}
