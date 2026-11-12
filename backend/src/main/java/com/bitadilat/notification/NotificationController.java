package com.bitadilat.notification;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.notification.NotificationDtos.DeviceBody;
import com.bitadilat.notification.NotificationDtos.MarkReadBody;
import com.bitadilat.notification.NotificationDtos.NotificationList;
import jakarta.validation.Valid;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Bildirim listesi, okundu işaretleme ve push cihaz kaydı (API_V1.md §Bildirim). */
@RestController
@RequestMapping("/api/v1")
public class NotificationController {

    private final NotificationService notifications;

    public NotificationController(NotificationService notifications) {
        this.notifications = notifications;
    }

    @GetMapping("/notifications")
    public NotificationList list(@AuthenticationPrincipal AuthPrincipal principal,
                                 @RequestParam(required = false) String cursor,
                                 @RequestParam(required = false) Integer limit) {
        return notifications.list(principal.userId(), cursor, limit);
    }

    @PostMapping("/notifications/read")
    public Map<String, Object> markRead(@AuthenticationPrincipal AuthPrincipal principal,
                                        @RequestBody(required = false) MarkReadBody body) {
        int marked = notifications.markRead(principal.userId(), body == null ? null : body.ids());
        return Map.of("markedCount", marked);
    }

    @PutMapping("/devices")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void registerDevice(@AuthenticationPrincipal AuthPrincipal principal,
                               @Valid @RequestBody DeviceBody body) {
        notifications.registerDevice(principal.userId(), body.platform(), body.token());
    }
}
