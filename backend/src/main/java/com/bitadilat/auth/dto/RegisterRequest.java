package com.bitadilat.auth.dto;

import com.bitadilat.common.ValidPassword;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank @Size(min = 2, max = 120) String fullName,
        @NotBlank @Size(max = 254) @Pattern(regexp = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", message = "E-posta geçersiz.")
        String email,
        @NotBlank String phone,
        @NotNull @ValidPassword String password,
        boolean wantsPro,
        @NotNull @AssertTrue Boolean kvkkAccepted,
        @NotNull @AssertTrue Boolean termsAccepted) {
}
