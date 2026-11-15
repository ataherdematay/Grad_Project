package com.bitadilat.notification;

import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.databind.ObjectMapper;

/**
 * Bildirim satırı yazar. Çağıranın işlemine katılır: iş geri alınırsa bildirim de gider. Metni istemci {@code type} ve
 * {@code params}'tan kurar (TR/EN); {@code title_key}/{@code body_key} yalnızca eski çeviri anahtarlarıdır.
 * Listeleme, okundu işaretleme ve cihaz kaydı {@link NotificationController} ve {@link NotificationQueryService}'tedir.
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
    public static final String APPOINTMENT_PROPOSED = "APPOINTMENT_PROPOSED";
    public static final String APPOINTMENT_CONFIRMED = "APPOINTMENT_CONFIRMED";
    public static final String JOB_STAGE_CHANGED = "JOB_STAGE_CHANGED";

    // Wave 4 (admin kararları)
    public static final String COMPLAINT_DECIDED = "COMPLAINT_DECIDED";
    public static final String PRO_APPROVED = "PRO_APPROVED";
    public static final String PRO_REJECTED = "PRO_REJECTED";
    public static final String PRO_NEEDS_DOCUMENTS = "PRO_NEEDS_DOCUMENTS";

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
