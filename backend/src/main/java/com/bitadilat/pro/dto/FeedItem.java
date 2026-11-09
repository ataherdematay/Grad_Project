package com.bitadilat.pro.dto;

import com.bitadilat.request.Urgency;
import java.time.Instant;
import java.util.UUID;

public record FeedItem(UUID id, String publicCode, String title, String categoryId, Urgency urgency,
                       String districtName, String neighborhood, Instant createdAt, Instant preferredFrom,
                       Instant preferredTo, int photoCount, int offerCount, UUID myOfferId) {
}
