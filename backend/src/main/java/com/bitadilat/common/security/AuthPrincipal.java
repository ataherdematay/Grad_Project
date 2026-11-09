package com.bitadilat.common.security;

import java.util.UUID;

/** İsteği yapan kimliği doğrulanmış kullanıcı. Denetleyicilerde {@code @AuthenticationPrincipal} ile alınır. */
public record AuthPrincipal(UUID userId, boolean admin) {
}
