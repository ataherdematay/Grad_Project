package com.bitadilat.offer.dto;

import com.bitadilat.offer.DeclineReason;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record DeclineBody(@NotNull DeclineReason reason, @Size(max = 500) String note,
                          @NotNull Boolean keepRequestOpen) {
}
