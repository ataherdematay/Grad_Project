package com.bitadilat.admin;

import com.bitadilat.common.ApiException;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/** {@code admin_actions}: durum değiştiren her admin çağrısı, değişiklikle aynı işlemde bir satır bırakır. */
@Component
public class AdminAudit {

    static final String PRO_PROFILE = "PRO_PROFILE";
    static final String COMPLAINT = "COMPLAINT";
    static final String USER = "USER";

    private final JdbcTemplate jdbc;

    public AdminAudit(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void record(UUID adminId, String action, String targetType, Object targetId, String note) {
        jdbc.update("insert into admin_actions (admin_id, action, target_type, target_id, note) values (?, ?, ?, ?, ?)",
                adminId, action, targetType, String.valueOf(targetId), note);
    }

    /** Not zorunlu alan: kırpılmış uzunluk {@code min..max}. */
    static String requiredNote(String raw, int min, int max) {
        String note = raw == null ? "" : raw.trim();
        if (note.length() < min || note.length() > max) {
            throw ApiException.validation("note", "note " + min + "-" + max + " karakter olmalı.");
        }
        return note;
    }

    /** İsteğe bağlı not: boşsa null, doluysa en çok {@code max} karakter. */
    static String optionalNote(String raw, int max) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        String note = raw.trim();
        if (note.length() > max) {
            throw ApiException.validation("note", "note en fazla " + max + " karakter olmalı.");
        }
        return note;
    }

    static <E extends Enum<E>> E parseEnum(Class<E> type, String raw, String field) {
        try {
            return Enum.valueOf(type, raw.trim());
        } catch (RuntimeException e) {
            throw ApiException.validation(field, field + " geçersiz.");
        }
    }

    /** LIKE kalıbı için özel karakterleri kaçırır. */
    static String likePattern(String q) {
        String escaped = q.trim().replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
        return "%" + escaped + "%";
    }
}
