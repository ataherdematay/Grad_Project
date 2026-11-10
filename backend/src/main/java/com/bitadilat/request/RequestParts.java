package com.bitadilat.request;

import com.bitadilat.request.dto.AnswerDto;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/** Talebin fotoğraf ve cevap satırları (request_photos, request_answers). */
@Component
public class RequestParts {

    private final JdbcTemplate jdbc;

    public RequestParts(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<UUID> photoIds(UUID requestId) {
        return jdbc.queryForList("select media_id from request_photos where request_id = ? order by sort_order",
                UUID.class, requestId);
    }

    public Map<UUID, Integer> photoCounts(List<UUID> requestIds) {
        Map<UUID, Integer> out = new HashMap<>();
        for (UUID id : requestIds) {
            out.put(id, jdbc.queryForObject("select count(*) from request_photos where request_id = ?",
                    Integer.class, id));
        }
        return out;
    }

    public List<AnswerDto> answers(UUID requestId) {
        return jdbc.query("select question_key, answer from request_answers where request_id = ? order by question_key",
                (rs, i) -> new AnswerDto(rs.getString(1), rs.getString(2)), requestId);
    }

    public void replacePhotos(UUID requestId, List<UUID> mediaIds) {
        jdbc.update("delete from request_photos where request_id = ?", requestId);
        int order = 0;
        try {
            for (UUID m : mediaIds) {
                jdbc.update("insert into request_photos (request_id, media_id, sort_order) values (?, ?, ?)",
                        requestId, m, order++);
            }
        } catch (org.springframework.dao.DuplicateKeyException e) {
            // ux_request_photos_media: eşzamanlı başka bir istek aynı fotoğrafı az önce bağladı.
            throw com.bitadilat.common.ApiException.validation("photoIds", "Medya zaten kullanılmış.");
        }
    }

    public void replaceAnswers(UUID requestId, Map<String, String> answers) {
        jdbc.update("delete from request_answers where request_id = ?", requestId);
        answers.forEach((k, v) -> jdbc.update(
                "insert into request_answers (request_id, question_key, answer) values (?, ?, ?)", requestId, k, v));
    }

    /** İptal edilmemiş (aktif veya tamamlanmış) iş; talep başına en fazla bir tane vardır. */
    public record JobRef(UUID id, String status) {
    }

    public java.util.Optional<JobRef> activeJob(UUID requestId) {
        return jdbc.query("select id, status from jobs where request_id = ? and status <> 'CANCELLED'",
                (rs, i) -> new JobRef(rs.getObject(1, UUID.class), rs.getString(2)), requestId).stream().findFirst();
    }

    public String nextPublicCode() {
        Long n = jdbc.queryForObject("select nextval('request_code_seq')", Long.class);
        return String.format("BD-%05d", n);
    }
}
