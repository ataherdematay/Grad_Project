package com.bitadilat.notification;

import com.bitadilat.common.ApiException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

/** Bildirim merkezi: liste (en yeni önce), okundu işaretleme, okunmamış sayısı ve cihaz token'ı. */
@Service
public class NotificationQueryService {

    static final int DEFAULT_LIMIT = 20;
    static final int MAX_LIMIT = 50;
    static final int MAX_READ_IDS = 500;
    private static final Set<String> PLATFORMS = Set.of("IOS", "ANDROID", "WEB");
    private static final TypeReference<Map<String, Object>> PARAMS = new TypeReference<>() {
    };

    public record Item(UUID id, String type, Map<String, Object> params, String targetRoute, boolean read,
                       Instant createdAt) {
    }

    public record Page(List<Item> items, String nextCursor, int unreadCount) {
    }

    private final JdbcTemplate jdbc;
    private final ObjectMapper json;

    public NotificationQueryService(JdbcTemplate jdbc, ObjectMapper json) {
        this.jdbc = jdbc;
        this.json = json;
    }

    /** İmleç, en yeni önce sıralı listedeki başlangıç sırasıdır (opak dize). */
    @Transactional(readOnly = true)
    public Page list(UUID userId, String cursor, Integer limit) {
        int size = limit == null ? DEFAULT_LIMIT : limit;
        if (size < 1) {
            throw ApiException.validation("limit", "limit en az 1 olmalı.");
        }
        size = Math.min(size, MAX_LIMIT);
        int offset = 0;
        if (cursor != null && !cursor.isBlank()) {
            try {
                offset = Integer.parseInt(cursor.trim());
            } catch (NumberFormatException e) {
                throw ApiException.validation("cursor", "Geçersiz imleç.");
            }
            if (offset < 0) {
                throw ApiException.validation("cursor", "Geçersiz imleç.");
            }
        }
        List<Item> rows = jdbc.query("""
                select id, type, params::text as params, target_route, read_at is not null as is_read, created_at
                from notifications where user_id = ?
                order by created_at desc, id desc limit ? offset ?""", (rs, i) -> new Item(
                rs.getObject("id", UUID.class), rs.getString("type"), parse(rs.getString("params")),
                rs.getString("target_route"), rs.getBoolean("is_read"), rs.getTimestamp("created_at").toInstant()),
                userId, size + 1, offset);
        String next = rows.size() > size ? String.valueOf(offset + size) : null;
        return new Page(rows.size() > size ? rows.subList(0, size) : rows, next, unreadCount(userId));
    }

    @Transactional(readOnly = true)
    public int unreadCount(UUID userId) {
        Integer n = jdbc.queryForObject(
                "select count(*) from notifications where user_id = ? and read_at is null", Integer.class, userId);
        return n == null ? 0 : n;
    }

    /**
     * {@code ids} null ise kullanıcının tüm bildirimleri okundu olur. Verilen kimliklerden başkasına ait olanlar
     * sessizce yok sayılır (varlık sızdırılmaz); boş liste hiçbir şeyi değiştirmez.
     */
    @Transactional
    public void markRead(UUID userId, List<UUID> ids) {
        Timestamp now = Timestamp.from(Instant.now());
        if (ids == null) {
            jdbc.update("update notifications set read_at = ? where user_id = ? and read_at is null", now, userId);
            return;
        }
        if (ids.isEmpty()) {
            return;
        }
        if (ids.size() > MAX_READ_IDS || ids.contains(null)) {
            throw ApiException.validation("ids", "ids en çok " + MAX_READ_IDS + " geçerli kimlik içerebilir.");
        }
        String marks = String.join(",", java.util.Collections.nCopies(ids.size(), "?"));
        Object[] args = new Object[ids.size() + 2];
        args[0] = now;
        args[1] = userId;
        for (int i = 0; i < ids.size(); i++) {
            args[i + 2] = ids.get(i);
        }
        jdbc.update("update notifications set read_at = ? where user_id = ? and read_at is null and id in (" + marks
                + ")", args);
    }

    /** Aynı token başka kullanıcıya geçmişse (cihaz el değiştirdi) yeni sahibine taşınır. Push henüz gönderilmez. */
    @Transactional
    public void registerDevice(UUID userId, String platform, String token) {
        String p = platform == null ? "" : platform.trim().toUpperCase();
        if (!PLATFORMS.contains(p)) {
            throw ApiException.validation("platform", "platform IOS, ANDROID veya WEB olmalı.");
        }
        String t = token == null ? "" : token.trim();
        if (t.isEmpty() || t.length() > 512) {
            throw ApiException.validation("token", "token 1-512 karakter olmalı.");
        }
        jdbc.update("""
                insert into device_tokens (user_id, platform, token) values (?, ?, ?)
                on conflict (token) do update set user_id = excluded.user_id, platform = excluded.platform,
                    updated_at = now()""", userId, p, t);
    }

    private Map<String, Object> parse(String raw) {
        try {
            Map<String, Object> m = json.readValue(raw, PARAMS);
            return m == null ? new LinkedHashMap<>() : m;
        } catch (RuntimeException e) {
            return new LinkedHashMap<>();
        }
    }
}
