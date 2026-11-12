package com.bitadilat.notification;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** Bildirim ve push cihaz kaydı (API_V1.md §Bildirim). */
public final class NotificationDtos {

    private NotificationDtos() {
    }

    public record NotificationItem(
            UUID id,
            String type,
            String titleKey,
            String bodyKey,
            Map<String, Object> params,
            String targetRoute,
            Instant readAt,
            Instant createdAt) {
    }

    public record NotificationList(
            List<NotificationItem> items,
            String nextCursor,
            long unreadCount) {
    }

    /** {@code ids} null veya boşsa kullanıcının tüm okunmamış bildirimleri okundu işaretlenir. */
    public record MarkReadBody(List<UUID> ids) {
    }

    public record DeviceBody(
            @NotBlank @Pattern(regexp = "IOS|ANDROID|WEB") String platform,
            @NotBlank @Size(min = 8, max = 512) String token) {
    }
}
