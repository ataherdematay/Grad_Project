package com.bitadilat.common;

import java.util.List;

/** Sözleşmedeki {@code ?cursor=&limit=} sayfalama: imleç, sıralı listedeki sıra numarasıdır (opak dize olarak). */
public final class Paging {

    public static final int DEFAULT_LIMIT = 20;
    public static final int MAX_LIMIT = 50;

    private Paging() {
    }

    public record Slice<T>(List<T> items, String nextCursor) {
    }

    public static <T> Slice<T> slice(List<T> all, String cursor, Integer limit) {
        int size = limit == null ? DEFAULT_LIMIT : limit;
        if (size < 1) {
            throw ApiException.validation("limit", "limit en az 1 olmalı.");
        }
        size = Math.min(size, MAX_LIMIT);
        int start = 0;
        if (cursor != null && !cursor.isBlank()) {
            try {
                start = Integer.parseInt(cursor.trim());
            } catch (NumberFormatException e) {
                throw ApiException.validation("cursor", "Geçersiz imleç.");
            }
            if (start < 0) {
                throw ApiException.validation("cursor", "Geçersiz imleç.");
            }
        }
        if (start >= all.size()) {
            return new Slice<>(List.of(), null);
        }
        int end = Math.min(all.size(), start + size);
        return new Slice<>(all.subList(start, end), end < all.size() ? String.valueOf(end) : null);
    }
}
