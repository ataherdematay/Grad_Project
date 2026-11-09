package com.bitadilat.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Kısmi güncelleme: null alan değişmez. {@code doorNote} boş string ile temizlenir.
 * Varsayılan adreste {@code isDefault=false} yok sayılır; varsayılan başka adres seçilerek değişir.
 */
public record AddressPatch(
        @Size(max = 40) @Pattern(regexp = ".*\\S.*", message = "Boş olamaz.") String label,
        Integer districtId,
        @Size(max = 120) @Pattern(regexp = ".*\\S.*", message = "Boş olamaz.") String neighborhood,
        @Size(max = 500) @Pattern(regexp = ".*\\S.*", message = "Boş olamaz.") String lineFull,
        @Size(max = 300) String doorNote,
        @JsonProperty("isDefault") Boolean isDefault) {
}
