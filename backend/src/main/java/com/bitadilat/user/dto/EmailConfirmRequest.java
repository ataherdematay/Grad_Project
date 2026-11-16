package com.bitadilat.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record EmailConfirmRequest(@NotBlank @Pattern(regexp = "^\\d{6}$", message = "Kod 6 haneli olmalı.") String code) {
}
