package com.bitadilat.media.dto;

import java.util.UUID;

public record MediaUploaded(UUID id, String contentType, long sizeBytes, Integer width, Integer height) {
}
