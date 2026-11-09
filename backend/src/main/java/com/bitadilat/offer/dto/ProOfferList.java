package com.bitadilat.offer.dto;

import java.util.List;

public record ProOfferList(List<ProOfferSummary> items, String nextCursor) {
}
