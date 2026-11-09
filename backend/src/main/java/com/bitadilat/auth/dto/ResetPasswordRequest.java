package com.bitadilat.auth.dto;

import com.bitadilat.common.ValidPassword;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
        @NotBlank @Size(max = 254) String email,
        @NotBlank @Pattern(regexp = "^\\d{6}$", message = "Kod 6 haneli olmalı.") String code,
        @NotNull @ValidPassword String newPassword) {
}
