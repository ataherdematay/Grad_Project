package com.bitadilat.job.dto;

import com.bitadilat.job.ActorRole;
import com.bitadilat.job.JobStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

/**
 * Liste satırı. {@code counterpart}: müşteri ustanın işletme adını, usta müşteriyi "Ali Y." biçiminde görür.
 * {@code unreadMessages}: görüntüleyenin okumadığı karşı taraf mesajları.
 */
public record JobSummary(UUID id, String publicCode, UUID requestId, String title, String categoryId,
                         JobStatus status, ActorRole viewerRole, Counterpart counterpart, BigDecimal totalAmount,
                         Instant scheduledFrom, Instant scheduledTo, Instant updatedAt, int unreadMessages) {

    public record Counterpart(UUID id, String displayName) {
    }
}
