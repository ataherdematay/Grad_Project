package com.bitadilat.request.dto;

import com.bitadilat.media.dto.MediaRef;
import com.bitadilat.request.RequestStatus;
import com.bitadilat.request.Urgency;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** RequestSummary alanları + ayrıntı. {@code address.lineFull/doorNote} yalnızca sahibe dolu. */
public record RequestDetail(
        UUID id,
        String publicCode,
        String title,
        String categoryId,
        Urgency urgency,
        RequestStatus status,
        String districtName,
        String neighborhood,
        Instant createdAt,
        Instant expiresAt,
        int offerCount,
        BigDecimal minOfferTotal,
        BigDecimal maxOfferTotal,
        UUID jobId,
        String description,
        Instant preferredFrom,
        Instant preferredTo,
        List<MediaRef> photos,
        List<AnswerDto> answers,
        int matchedProCount,
        List<String> matchFactors,
        Address address) {

    public record Address(String districtName, String neighborhood, String lineFull, String doorNote) {
    }
}
