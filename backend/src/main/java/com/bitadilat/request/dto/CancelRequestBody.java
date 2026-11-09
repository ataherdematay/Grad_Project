package com.bitadilat.request.dto;

import com.bitadilat.request.CancelReason;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CancelRequestBody(@NotNull CancelReason reason, @Size(max = 500) String note) {
}
