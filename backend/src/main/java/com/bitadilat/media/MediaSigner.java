package com.bitadilat.media;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.Base64;
import java.util.UUID;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Medya adresi imzası: HMAC-SHA256(anahtar, "id.exp"), base64url. Anahtar {@code bitadilat.media.signing-key}
 * (env MEDIA_SIGNING_KEY), en az 32 bayt. İmza yalnızca erişim kontrolünden geçmiş çağıranlara üretilir.
 */
@Component
public class MediaSigner {

    public static final Duration TTL = Duration.ofMinutes(10);

    private final SecretKeySpec key;

    public MediaSigner(@Value("${bitadilat.media.signing-key}") String signingKey) {
        byte[] bytes = signingKey.getBytes(StandardCharsets.UTF_8);
        if (bytes.length < 32) {
            throw new IllegalStateException("bitadilat.media.signing-key (MEDIA_SIGNING_KEY) en az 32 bayt olmalı.");
        }
        this.key = new SecretKeySpec(bytes, "HmacSHA256");
    }

    public String sign(UUID mediaId, long expEpochSeconds) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(mac(mediaId, expEpochSeconds));
    }

    public boolean verify(UUID mediaId, long expEpochSeconds, String signature) {
        if (signature == null) {
            return false;
        }
        byte[] given;
        try {
            given = Base64.getUrlDecoder().decode(signature);
        } catch (IllegalArgumentException e) {
            return false;
        }
        return MessageDigest.isEqual(mac(mediaId, expEpochSeconds), given);
    }

    private byte[] mac(UUID mediaId, long exp) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(key);
            return mac.doFinal((mediaId + "." + exp).getBytes(StandardCharsets.UTF_8));
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("HMAC hesaplanamadı", e);
        }
    }
}
