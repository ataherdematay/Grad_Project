package com.bitadilat.request.dto;

import com.bitadilat.request.RequestStatus;
import com.bitadilat.request.Urgency;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * {@code offerCount} ve min/max yalnızca PENDING (süresi dolmamış) teklifleri sayar. {@code jobId}: talep ASSIGNED
 * iken işin kimliği, aksi halde null.
 */
public record RequestSummary(
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
        UUID jobId) {
}
