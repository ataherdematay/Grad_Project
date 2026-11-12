package com.bitadilat.notification;

import com.bitadilat.common.Paging;
import com.bitadilat.notification.NotificationDtos.NotificationItem;
import com.bitadilat.notification.NotificationDtos.NotificationList;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

/**
 * Bildirim satırı yazar ve kullanıcı bildirimlerini / cihaz anahtarlarını yönetir (API_V1.md §Bildirim).
 * Çağıranın işlemine katılır: iş geri alınırsa bildirim de gider.
 * Başlık ve gövde anahtarları istemcide çevrilir: {@code notification.<TYPE>.title} / {@code .body}.
 */
@Service
public class NotificationService {

    public static final String NEW_MATCHING_REQUEST = "NEW_MATCHING_REQUEST";
    public static final String OFFER_RECEIVED = "OFFER_RECEIVED";
    public static final String OFFER_DECLINED = "OFFER_DECLINED";
    public static final String REQUEST_UPDATED = "REQUEST_UPDATED";

    // Wave 3 (sözleşmedeki türler)
    public static final String OFFER_ACCEPTED = "OFFER_ACCEPTED";
    public static final String OFFER_SUPERSEDED = "OFFER_SUPERSEDED";
    public static final String WORK_FINISHED = "WORK_FINISHED";
    public static final String PAYOUT_RELEASED = "PAYOUT_RELEASED";
    public static final String JOB_CANCELLED = "JOB_CANCELLED";
    public static final String COMPLAINT_OPENED = "COMPLAINT_OPENED";
    public static final String AUTO_COMPLETE_REMINDER = "AUTO_COMPLETE_REMINDER";
    public static final String NEW_MESSAGE = "NEW_MESSAGE";
    // Sözleşmede tür adı verilmeyen iş bildirimleri
    public static final String APPOINTMENT_PROPOSED = "APPOINTMENT_PROPOSED";
    public static final String APPOINTMENT_ACCEPTED = "APPOINTMENT_ACCEPTED";
    public static final String JOB_STAGE_UPDATED = "JOB_STAGE_UPDATED";

    // Wave 4 (yönetici kararları ve usta başvuru bildirimleri)
    public static final String PRO_APPLICATION_APPROVED = "PRO_APPLICATION_APPROVED";
    public static final String PRO_APPLICATION_REJECTED = "PRO_APPLICATION_REJECTED";
    public static final String PRO_DOCUMENTS_REQUESTED = "PRO_DOCUMENTS_REQUESTED";
    public static final String COMPLAINT_DECIDED = "COMPLAINT_DECIDED";
    public static final String ACCOUNT_SUSPENDED = "ACCOUNT_SUSPENDED";
    public static final String ACCOUNT_REACTIVATED = "ACCOUNT_REACTIVATED";

    private static final TypeReference<Map<String, Object>> MAP_TYPE = new TypeReference<>() {
    };

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

    @Transactional(readOnly = true)
    public NotificationList list(UUID userId, String cursor, Integer limit) {
        List<NotificationItem> all = jdbc.query("""
                select id, type, title_key, body_key, params::text as params_json, target_route, read_at, created_at
                from notifications
                where user_id = ?
                order by created_at desc, id desc""",
                (rs, i) -> {
                    Timestamp readTs = rs.getTimestamp("read_at");
                    String rawJson = rs.getString("params_json");
                    Map<String, Object> parsed = rawJson == null || rawJson.isBlank()
                            ? Map.of()
                            : json.readValue(rawJson, MAP_TYPE);
                    return new NotificationItem(
                            rs.getObject("id", UUID.class),
                            rs.getString("type"),
                            rs.getString("title_key"),
                            rs.getString("body_key"),
                            parsed,
                            rs.getString("target_route"),
                            readTs == null ? null : readTs.toInstant(),
                            rs.getTimestamp("created_at").toInstant());
                },
                userId);
        Long unread = jdbc.queryForObject(
                "select count(*) from notifications where user_id = ? and read_at is null", Long.class, userId);
        Paging.Slice<NotificationItem> page = Paging.slice(all, cursor, limit);
        return new NotificationList(page.items(), page.nextCursor(), unread == null ? 0L : unread);
    }

    @Transactional
    public int markRead(UUID userId, List<UUID> ids) {
        Instant now = Instant.now();
        if (ids == null || ids.isEmpty()) {
            return jdbc.update(
                    "update notifications set read_at = ? where user_id = ? and read_at is null",
                    Timestamp.from(now), userId);
        }
        int updated = 0;
        for (UUID id : ids.stream().distinct().toList()) {
            updated += jdbc.update(
                    "update notifications set read_at = ? where id = ? and user_id = ? and read_at is null",
                    Timestamp.from(now), id, userId);
        }
        return updated;
    }

    @Transactional
    public void registerDevice(UUID userId, String platform, String token) {
        jdbc.update("""
                insert into device_tokens (user_id, platform, token, updated_at)
                values (?, ?, ?, now())
                on conflict (token) do update set
                  user_id = excluded.user_id,
                  platform = excluded.platform,
                  updated_at = now()""",
                userId, platform, token.trim());
    }
}
