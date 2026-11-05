package com.bitadilat.payment.dto;

import com.bitadilat.payment.domain.Offer;
import java.math.BigDecimal;

public record OfferView(
        String id,
        String jobRef,
        String jobTitle,
        String proName,
        BigDecimal laborAmount,
        BigDecimal materialsAmount,
        BigDecimal totalAmount) {

    public static OfferView from(Offer offer) {
        return new OfferView(
                offer.id(),
                offer.jobRef(),
                offer.jobTitle(),
                offer.proName(),
                offer.laborAmount(),
                offer.materialsAmount(),
                offer.totalAmount());
    }
}
