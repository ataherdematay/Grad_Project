package com.bitadilat.media.dto;

import java.time.Instant;
import java.util.UUID;

/** Kısa ömürlü (10 dk) imzalı adres; Authorization başlığı olmadan açılır (ör. Image.network). */
public record MediaRef(UUID id, String url, Instant expiresAt) {
}
