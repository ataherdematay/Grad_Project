package com.bitadilat.job.dto;

import com.bitadilat.job.ComplaintReason;
import com.bitadilat.job.JobCancelReason;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** İş uç noktalarının istek gövdeleri. Metin uzunlukları servis katmanında kırpılmış metne uygulanır. */
public final class JobBodies {

    private JobBodies() {
    }

    public record ProposeSlot(@NotNull Instant slotFrom, @NotNull Instant slotTo) {
    }

    public record Finish(@NotNull @Size(max = 2000) String note, @Size(max = 5) List<UUID> photoIds) {
    }

    public record AddEvent(@Size(max = 2000) String note, @Size(max = 5) List<UUID> photoIds) {
    }

    public record Cancel(@NotNull JobCancelReason reason, @Size(max = 500) String note) {
    }

    public record Review(@NotNull @Min(1) @Max(5) Integer rating, @Size(max = 5) List<String> tags,
                         @Size(max = 2000) String comment, Boolean anonymous) {
    }

    public record Complaint(@NotNull ComplaintReason reason, @NotNull @Size(max = 4000) String description,
                            @Size(max = 5) List<UUID> evidenceIds) {
    }
}
