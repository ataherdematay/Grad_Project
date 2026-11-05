package com.bitadilat.payment.domain;

import java.math.BigDecimal;

/** Ödemenin tutarını belirleyen teklif. Tutar her zaman buradan gelir, istemciden alınmaz. */
public record Offer(
        String id,
        String jobRef,
        String jobTitle,
        String proName,
        BigDecimal laborAmount,
        BigDecimal materialsAmount) {

    public BigDecimal totalAmount() {
        return laborAmount.add(materialsAmount);
    }
}
