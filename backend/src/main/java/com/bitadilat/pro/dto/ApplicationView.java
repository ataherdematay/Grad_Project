package com.bitadilat.pro.dto;

import com.bitadilat.media.dto.MediaRef;
import com.bitadilat.pro.DocumentStatus;
import com.bitadilat.pro.DocumentType;
import com.bitadilat.pro.ReviewStatus;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ApplicationView(ReviewStatus reviewStatus, String reviewNote, String businessName, String bio,
                              int experienceYears, List<String> categoryIds, List<Integer> districtIds,
                              List<Doc> documents, Instant submittedAt) {

    public record Doc(UUID id, DocumentType type, DocumentStatus status, MediaRef media) {
    }
}
