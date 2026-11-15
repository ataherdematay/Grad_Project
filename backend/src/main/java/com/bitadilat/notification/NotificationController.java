package com.bitadilat.notification;

import com.bitadilat.common.security.AuthPrincipal;
import java.util.List;
import java.util.UUID;
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

@RestController
@RequestMapping("/api/v1")
public class NotificationController {

    /** {@code ids} yoksa hepsi okundu olur. */
    public record ReadBody(List<UUID> ids) {
    }

    public record DeviceBody(String platform, String token) {
    }

    private final NotificationQueryService notifications;

    public NotificationController(NotificationQueryService notifications) {
        this.notifications = notifications;
    }

    @GetMapping("/notifications")
    public NotificationQueryService.Page list(@AuthenticationPrincipal AuthPrincipal me,
                                              @RequestParam(required = false) String cursor,
                                              @RequestParam(required = false) Integer limit) {
        return notifications.list(me.userId(), cursor, limit);
    }

    @PostMapping("/notifications/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void read(@AuthenticationPrincipal AuthPrincipal me, @RequestBody(required = false) ReadBody body) {
        notifications.markRead(me.userId(), body == null ? null : body.ids());
    }

    @PutMapping("/devices")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void device(@AuthenticationPrincipal AuthPrincipal me, @RequestBody DeviceBody body) {
        notifications.registerDevice(me.userId(), body.platform(), body.token());
    }
}
