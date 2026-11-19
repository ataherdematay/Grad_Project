package com.bitadilat.user.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record EmailChangeRequest(
        @NotBlank @Size(max = 254) @Pattern(regexp = "^\\s*[^@\\s]+@[^@\\s]+\\.[^@\\s]+\\s*$",
                message = "E-posta geçersiz.") String newEmail,
        @NotBlank @Size(max = 200) String password) {
}
