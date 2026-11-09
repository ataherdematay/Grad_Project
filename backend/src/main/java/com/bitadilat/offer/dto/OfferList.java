package com.bitadilat.offer.dto;

import java.util.List;

public record OfferList(List<OfferSummary> items, long declinedCount, String nextCursor) {
}
