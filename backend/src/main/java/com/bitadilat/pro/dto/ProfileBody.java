package com.bitadilat.pro.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

public record ProfileBody(
        @NotBlank @Size(min = 2, max = 100) String businessName,
        @Size(max = 1000) String bio,
        @NotNull @Min(0) @Max(60) Integer experienceYears,
        @NotEmpty List<@NotBlank String> categoryIds,
        @NotEmpty List<@NotNull Integer> districtIds,
        @NotNull @Size(max = 28) List<@Valid @NotNull WorkingHourDto> workingHours) {
}
