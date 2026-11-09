package com.bitadilat.offer.dto;

import com.bitadilat.offer.OfferStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record OfferSummary(UUID id, String publicCode, UUID requestId, OfferStatus status, ProCard pro,
                           BigDecimal laborAmount, BigDecimal materialsAmount, BigDecimal totalAmount,
                           Instant arrivalFrom, Instant arrivalTo, int warrantyMonths, String note,
                           Instant validUntil, Instant createdAt) {
}
