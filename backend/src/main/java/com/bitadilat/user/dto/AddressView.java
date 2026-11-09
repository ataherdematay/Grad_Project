package com.bitadilat.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.UUID;

public record AddressView(
        UUID id,
        String label,
        Integer districtId,
        String districtName,
        String neighborhood,
        String lineFull,
        String doorNote,
        @JsonProperty("isDefault") boolean isDefault) {
}
