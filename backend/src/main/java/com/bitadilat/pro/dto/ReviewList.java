package com.bitadilat.pro.dto;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record ReviewList(List<Item> items, String nextCursor) {

    public record Item(UUID id, int rating, List<String> tags, String comment, String authorDisplay,
                       Instant createdAt) {
    }
}
