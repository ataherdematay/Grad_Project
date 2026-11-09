package com.bitadilat.request;

import com.bitadilat.common.ApiException;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * Talep sihirbazının kategoriye özel soruları (tek seçim). {@code plumbing}: since, water_cut, other_rooms;
 * diğer kategoriler yalnız since. Seçenek {@code value} değerleri sabit makine kodlarıdır; talep cevabı bunu taşır.
 */
@Component
public class QuestionCatalog {

    public record Option(String value, String labelTr, String labelEn) {
    }

    public record Question(String key, String labelTr, String labelEn, List<Option> options) {
    }

    private static final Question SINCE = new Question("since", "Sorun ne zamandır var?", "How long has the problem existed?",
            List.of(new Option("today", "Bugün", "Today"),
                    new Option("few_days", "Birkaç gün", "A few days"),
                    new Option("over_week", "1 haftadan fazla", "More than a week")));

    private static final List<Option> YES_NO = List.of(new Option("yes", "Evet", "Yes"), new Option("no", "Hayır", "No"));

    private static final List<Question> PLUMBING = List.of(
            SINCE,
            new Question("water_cut", "Su kesildi mi?", "Was the water shut off?", YES_NO),
            new Question("other_rooms", "Diğer odalar etkilendi mi?", "Are other rooms affected?", YES_NO));

    private static final List<Question> DEFAULT = List.of(SINCE);

    public List<Question> forCategory(String categoryId) {
        return "plumbing".equals(categoryId) ? PLUMBING : DEFAULT;
    }

    /**
     * Cevapları kategoriye göre doğrular (bilinmeyen soru, geçersiz seçenek, yinelenen anahtar → 400 {@code answers}).
     * Sırayı korur.
     */
    public Map<String, String> validate(String categoryId, List<? extends Answer> answers) {
        Map<String, Question> byKey = new java.util.LinkedHashMap<>();
        forCategory(categoryId).forEach(q -> byKey.put(q.key(), q));
        Map<String, String> out = new java.util.LinkedHashMap<>();
        if (answers == null) {
            return out;
        }
        for (Answer a : answers) {
            Question q = byKey.get(a.questionKey());
            if (q == null) {
                throw ApiException.validation("answers", "Bu kategoride böyle bir soru yok: " + a.questionKey());
            }
            if (q.options().stream().noneMatch(o -> o.value().equals(a.answer()))) {
                throw ApiException.validation("answers", "Geçersiz cevap: " + a.questionKey());
            }
            if (out.put(a.questionKey(), a.answer()) != null) {
                throw ApiException.validation("answers", "Aynı soru birden çok kez cevaplanmış.");
            }
        }
        return out;
    }

    /** İstek gövdesindeki ve yanıttaki cevap çiftinin ortak şekli. */
    public interface Answer {
        String questionKey();

        String answer();
    }
}
