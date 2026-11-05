package com.bitadilat.payment.service;

import com.bitadilat.payment.domain.Offer;
import java.math.BigDecimal;
import java.util.Map;
import java.util.NoSuchElementException;
import org.springframework.stereotype.Component;

/**
 * Prototipteki tek demo teklif. Gerçek teklif modülü yazıldığında yalnızca bu sınıf değişir;
 * önemli olan tutarın sunucu tarafından belirlenmesidir.
 */
@Component
public class OfferCatalog {

    public static final String DEMO_OFFER_ID = "OFFER-BD-88412";

    private final Map<String, Offer> offers = Map.of(
            DEMO_OFFER_ID,
            new Offer(
                    DEMO_OFFER_ID,
                    "BD-88412",
                    "Su kaçak tespiti ve onarım",
                    "Mavi Hat Tesisat",
                    new BigDecimal("1650.00"),
                    new BigDecimal("800.00")));

    public Offer require(String offerId) {
        Offer offer = offers.get(offerId);
        if (offer == null) {
            throw new NoSuchElementException("Teklif bulunamadı.");
        }
        return offer;
    }
}
