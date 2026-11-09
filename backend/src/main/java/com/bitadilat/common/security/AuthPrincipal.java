package com.bitadilat.common.security;

import java.util.UUID;

/** familyId: access token'daki "fid" claim'i, yoksa null. İsteği yapan kimliği doğrulanmış kullanıcı. Denetleyicilerde {@code @AuthenticationPrincipal} ile alınır. */
public record AuthPrincipal(UUID userId, boolean admin, UUID familyId) {

    /** Refresh ailesi bilinmeyen (claim'siz eski token) kimlik. */
    public AuthPrincipal(UUID userId, boolean admin) {
        this(userId, admin, null);
    }
}
