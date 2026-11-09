package com.bitadilat.offer.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record CreateOfferBody(
        @NotNull @DecimalMin(value = "0", inclusive = false) @Digits(integer = 10, fraction = 2) BigDecimal laborAmount,
        @NotNull @DecimalMin("0") @Digits(integer = 10, fraction = 2) BigDecimal materialsAmount,
        @NotNull Instant arrivalFrom,
        @NotNull Instant arrivalTo,
        @NotNull Integer warrantyMonths,
        @Size(max = 500) String note,
        @Size(max = 30) List<@Valid @NotNull OfferItemIn> items) {
}
