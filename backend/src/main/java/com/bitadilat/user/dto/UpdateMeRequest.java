package com.bitadilat.user.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Gönderilmeyen (null) alanlar değişmez. */
public record UpdateMeRequest(
        @Size(min = 2, max = 120) @Pattern(regexp = ".*\\S.*", message = "Ad boş olamaz.") String fullName,
        @Pattern(regexp = "tr|en", message = "Dil tr veya en olmalı.") String locale,
        @Pattern(regexp = "CUSTOMER|PRO", message = "Mod CUSTOMER veya PRO olmalı.") String lastMode) {
}
