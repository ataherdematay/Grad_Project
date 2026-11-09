package com.bitadilat.request.dto;

import com.bitadilat.request.Urgency;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** POST ile aynı alanlar, hepsi isteğe bağlı: gönderilmeyen alan değişmez. */
public record UpdateRequestBody(
        @Size(max = 32) String categoryId,
        Urgency urgency,
        Instant preferredFrom,
        Instant preferredTo,
        @Size(min = 5, max = 150) String title,
        @Size(min = 20, max = 2000) String description,
        UUID addressId,
        @Size(max = 5) List<UUID> photoIds,
        @Size(max = 20) List<@Valid @NotNull AnswerDto> answers) {
}
