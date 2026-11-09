package com.bitadilat.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** Adres oluşturma gövdesi. İlk adres her zaman varsayılan olur. */
public record AddressRequest(
        @NotBlank @Size(max = 40) String label,
        @NotNull Integer districtId,
        @NotBlank @Size(max = 120) String neighborhood,
        @NotBlank @Size(max = 500) String lineFull,
        @Size(max = 300) String doorNote,
        @JsonProperty("isDefault") Boolean isDefault) {
}
