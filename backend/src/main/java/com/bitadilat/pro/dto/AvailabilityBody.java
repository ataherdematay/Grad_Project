package com.bitadilat.pro.dto;

import com.bitadilat.pro.Availability;
import jakarta.validation.constraints.NotNull;

public record AvailabilityBody(@NotNull Availability availability) {
}
