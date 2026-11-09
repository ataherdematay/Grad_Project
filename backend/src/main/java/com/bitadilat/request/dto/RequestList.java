package com.bitadilat.request.dto;

import java.util.List;

public record RequestList(List<RequestSummary> items, String nextCursor) {
}
