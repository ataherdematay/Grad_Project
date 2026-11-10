package com.bitadilat.job.dto;

import com.bitadilat.job.ActorRole;
import com.bitadilat.job.EventType;
import com.bitadilat.job.JobStatus;
import com.bitadilat.media.dto.MediaRef;
import java.time.Instant;
import java.util.UUID;

/** Zaman çizelgesi satırı. {@code photo} yalnızca PHOTO olaylarında dolu. */
public record JobEventView(UUID id, EventType type, JobStatus fromStatus, JobStatus toStatus, String note,
                           MediaRef photo, ActorRole actorRole, Instant createdAt) {
}
