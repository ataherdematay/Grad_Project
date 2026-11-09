package com.bitadilat.notification;

import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.databind.ObjectMapper;

/**
 * Bildirim satırı yazar (uç noktalar sonraki dalgada). Çağıranın işlemine katılır: iş geri alınırsa bildirim de gider.
 * Başlık ve gövde anahtarları istemcide çevrilir: {@code notification.<TYPE>.title} / {@code .body}.
 */
@Service
public class NotificationService {

    public static final String NEW_MATCHING_REQUEST = "NEW_MATCHING_REQUEST";
    public static final String OFFER_RECEIVED = "OFFER_RECEIVED";
    public static final String OFFER_DECLINED = "OFFER_DECLINED";

    private final JdbcTemplate jdbc;
    private final ObjectMapper json;

    public NotificationService(JdbcTemplate jdbc, ObjectMapper json) {
        this.jdbc = jdbc;
        this.json = json;
    }

    @Transactional
    public void notify(UUID userId, String type, Map<String, Object> params, String targetRoute) {
        jdbc.update("""
                insert into notifications (user_id, type, title_key, body_key, params, target_route)
                values (?, ?, ?, ?, cast(? as jsonb), ?)""",
                userId, type, "notification." + type + ".title", "notification." + type + ".body",
                json.writeValueAsString(params == null ? Map.of() : params), targetRoute);
    }
}
