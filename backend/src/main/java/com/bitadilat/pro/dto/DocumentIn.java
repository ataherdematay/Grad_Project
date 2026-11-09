package com.bitadilat.pro.dto;

import com.bitadilat.pro.DocumentType;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record DocumentIn(@NotNull DocumentType type, @NotNull UUID mediaId) {
}
