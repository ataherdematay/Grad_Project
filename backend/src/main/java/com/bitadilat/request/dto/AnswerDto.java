package com.bitadilat.request.dto;

import com.bitadilat.request.QuestionCatalog;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Sihirbaz sorusuna verilen cevap: istekte ve yanıtta aynı şekil. */
public record AnswerDto(
        @NotBlank @Size(max = 60) String questionKey,
        @NotBlank @Size(max = 500) String answer) implements QuestionCatalog.Answer {
}
