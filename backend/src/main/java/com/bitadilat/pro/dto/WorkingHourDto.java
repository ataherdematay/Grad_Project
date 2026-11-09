package com.bitadilat.pro.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

/** start/end "HH:mm". */
public record WorkingHourDto(@Min(1) @Max(7) int weekday, @NotBlank String start, @NotBlank String end,
                             boolean acceptsUrgent) {
}
