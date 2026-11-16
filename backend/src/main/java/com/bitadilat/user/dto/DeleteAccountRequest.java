package com.bitadilat.user.dto;

/**
 * {@code DELETE /me} isteğe bağlı gövdesi. {@code reason}: {@code NO_LONGER_NEEDED}, {@code FOUND_ALTERNATIVE},
 * {@code PRIVACY}, {@code BAD_EXPERIENCE}, {@code OTHER} veya null. Serbest metin alınmaz.
 */
public record DeleteAccountRequest(String reason) {
}
