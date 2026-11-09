package com.bitadilat.pro.dto;

import java.util.List;

public record FeedList(List<FeedItem> items, boolean onBreak, String nextCursor) {
}
