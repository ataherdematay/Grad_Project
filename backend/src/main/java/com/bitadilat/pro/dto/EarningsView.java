package com.bitadilat.pro.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Usta kazançları. {@code releasedTotal}: ustaya aktarılan net (serbest bırakılan + bölüşülen). {@code pendingTotal}:
 * LOCKED ve DISPUTED emanetin net tutarı. {@code serviceFeeTotal}: serbest bırakılan işlerden kesilen hizmet bedeli.
 * {@code items[].status}: PENDING, RELEASED, REFUNDED veya SPLIT.
 */
public record EarningsView(BigDecimal releasedTotal, BigDecimal pendingTotal, BigDecimal serviceFeeTotal,
                           List<Item> items) {

    public record Item(UUID jobId, String publicCode, String title, BigDecimal totalAmount, BigDecimal serviceFee,
                       BigDecimal netEarning, String status, Instant date) {
    }
}
