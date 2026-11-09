package com.bitadilat.offer.dto;

import java.math.BigDecimal;
import java.util.UUID;

/** Teklifte ve listelerde görünen usta özeti. {@code verified}: inceleme durumu APPROVED. */
public record ProCard(UUID id, String businessName, String fullName, BigDecimal ratingAvg, int ratingCount,
                      int completedJobs, boolean verified) {
}
