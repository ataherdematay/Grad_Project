package com.bitadilat.offer.dto;

import com.bitadilat.offer.ItemKind;
import java.math.BigDecimal;

public record OfferItemView(ItemKind kind, String description, BigDecimal quantity, BigDecimal unitPrice,
                            BigDecimal lineTotal) {
}
