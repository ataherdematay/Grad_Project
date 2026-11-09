package com.bitadilat.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.Base64;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class CommonRulesTest {

    @Test
    void phoneNumbersNormalizeToE164() {
        for (String raw : new String[] {"0532 849 20 11", "5328492011", "+90 532 849 20 11", "+905328492011",
                "0090 532 849 20 11", "905328492011", "(0532) 849-20-11", "0532.849.20.11"}) {
            assertThat(PhoneNumbers.normalize(raw)).as(raw).isEqualTo("+905328492011");
        }
    }

    @Test
    void nonMobileOrForeignNumbersAreRejected() {
        for (String raw : new String[] {"0212 555 55 55", "+44 7911 123456", "532 849 20", "abc", "", "  ",
                "05328492011999"}) {
            assertThat(PhoneNumbers.normalize(raw)).as(raw).isNull();
        }
        assertThat(PhoneNumbers.normalize(null)).isNull();
    }

    @Test
    void passwordRule() {
        assertThat(ValidPassword.PasswordRules.isValid("Abcdefg1")).isTrue();
        assertThat(ValidPassword.PasswordRules.isValid("şifre1234")).isTrue();
        assertThat(ValidPassword.PasswordRules.isValid("Abcde1")).isFalse();          // kısa
        assertThat(ValidPassword.PasswordRules.isValid("abcdefgh")).isFalse();        // rakam yok
        assertThat(ValidPassword.PasswordRules.isValid("12345678")).isFalse();         // harf yok
        assertThat(ValidPassword.PasswordRules.isValid("a1".repeat(40))).isFalse();    // BCrypt 72 bayt sınırı
    }

    @Test
    void aesGcmRoundTripBindsToAad() {
        String key = Base64.getEncoder().encodeToString(new byte[32]);
        AesGcmCrypto crypto = new AesGcmCrypto(key);
        String cipher = crypto.encrypt("Moda Cad. No: 14", "addr:a");

        assertThat(cipher).doesNotContain("Moda");
        assertThat(crypto.decrypt(cipher, "addr:a")).isEqualTo("Moda Cad. No: 14");
        assertThat(crypto.encrypt("Moda Cad. No: 14", "addr:a")).isNotEqualTo(cipher);
        assertThatThrownBy(() -> crypto.decrypt(cipher, "addr:" + UUID.randomUUID()))
                .isInstanceOf(IllegalStateException.class);
        assertThat(crypto.encrypt(null, "x")).isNull();
    }

    @Test
    void badAddressKeyIsRejectedAtStartup() {
        assertThatThrownBy(() -> new AesGcmCrypto(Base64.getEncoder().encodeToString(new byte[16])))
                .isInstanceOf(IllegalStateException.class);
        assertThatThrownBy(() -> new AesGcmCrypto("%%%")).isInstanceOf(IllegalStateException.class);
    }
}
