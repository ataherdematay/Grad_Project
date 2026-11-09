package com.bitadilat.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** refresh ve logout için ortak gövde. */
public record RefreshRequest(@NotBlank @Size(max = 200) String refreshToken) {
}
