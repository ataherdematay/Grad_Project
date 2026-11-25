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
        assertThatCode(() -> validator("https://admin.example.test", "key", "https://api.example.test", "local", "/m", "k"))
                .doesNotThrowAnyException();
        assertThatThrownBy(() -> validator("https://admin.example.test", "", "https://api.example.test", "local", "/m", "k"))
                .hasMessageContaining("CRAFTGATE_CALLBACK_KEY");
        assertThatThrownBy(() -> validator("*", "key", "https://api.example.test", "local", "/m", "k"))
                .hasMessageContaining("joker");
        assertThatThrownBy(() -> validator("https://a.test,https://*.example.test", "key", "https://x", "local", "/m", "k"))
                .hasMessageContaining("joker");
        assertThatThrownBy(() -> validator("", "key", "", "local", "/m", "k"))
                .hasMessageContaining("APP_PUBLIC_BASE_URL");
    }

    private static ProdConfigValidator validator(String cors, String callbackKey, String baseUrl, String storage,
                                                 String dir, String apiKey) {
        return new ProdConfigValidator(cors, callbackKey, baseUrl, storage, dir, apiKey);
    }

    /** Prod'da MEDIA_STORAGE=local iken MEDIA_DIR zorunlu (varsayılan yok); supabase iken gerekmez. */
    @Test
    void validatorRequiresMediaDirOnlyForLocalStorage() {
        for (String dir : new String[] {"", "  ", null}) {
            assertThatThrownBy(() -> validator("", "key", "https://api.example.test", "local", dir, "k"))
                    .isInstanceOf(IllegalStateException.class).hasMessageContaining("MEDIA_DIR");
            assertThatThrownBy(() -> validator("", "key", "https://api.example.test", null, dir, "k"))
                    .hasMessageContaining("MEDIA_DIR");
            assertThatCode(() -> validator("", "key", "https://api.example.test", "supabase", dir, "k"))
                    .doesNotThrowAnyException();
        }
        assertThatCode(() -> validator("", "key", "https://api.example.test", "local", "/var/media", "k"))
                .doesNotThrowAnyException();
    }

    /** Sahte "sandbox-demo" ödeme kipi prod'da açılamaz: uygulama açılışta durur. */
    @Test
    void validatorRejectsFakeDemoPaymentModeInProd() {
        for (String key : new String[] {"sandbox-demo", "sandbox-demo-123", " Sandbox-Demo-x"}) {
            assertThatThrownBy(() -> validator("", "key", "https://api.example.test", "supabase", "", key))
                    .isInstanceOf(IllegalStateException.class).hasMessageContaining("sahte ödeme");
        }
        assertThatCode(() -> validator("", "key", "https://api.example.test", "supabase", "", "real-key"))
                .doesNotThrowAnyException();
    }

    @Test
    void localDiskStorageRefusesBlankDir() {
        assertThatThrownBy(() -> new com.bitadilat.media.LocalDiskMediaStorage(""))
                .isInstanceOf(IllegalStateException.class).hasMessageContaining("MEDIA_DIR");
    }

    @SuppressWarnings("unused")
    private static void unused() {
        any();
    }
}
