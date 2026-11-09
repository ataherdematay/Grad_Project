package com.bitadilat.offer.dto;

import com.bitadilat.offer.DeclineReason;
import com.bitadilat.offer.OfferStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** OfferSummary + kalemler. {@code serviceFee}/{@code netEarning} yalnızca teklifi veren ustaya dolu. */
public record OfferDetail(UUID id, String publicCode, UUID requestId, OfferStatus status, ProCard pro,
                          BigDecimal laborAmount, BigDecimal materialsAmount, BigDecimal totalAmount,
                          Instant arrivalFrom, Instant arrivalTo, int warrantyMonths, String note,
                          Instant validUntil, Instant createdAt, List<OfferItemView> items,
                          BigDecimal serviceFee, BigDecimal netEarning, DeclineReason declineReason) {
}
