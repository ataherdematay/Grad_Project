package com.bitadilat.chat.dto;

import com.bitadilat.job.ActorRole;
import com.bitadilat.job.JobStatus;
import com.bitadilat.job.dto.JobSummary;
import com.bitadilat.media.dto.MediaRef;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Sohbet DTO'ları. {@code Message.id} bigserial'dır ve imleç olarak kullanılır. */
public final class ChatDtos {

    private ChatDtos() {
    }

    public record Message(long id, ActorRole senderRole, boolean mine, String body, MediaRef photo,
                          Instant createdAt) {
    }

    public record MessageList(List<Message> items, long otherLastReadId) {
    }

    public record Conversation(UUID jobId, String publicCode, String title, JobSummary.Counterpart counterpart,
                               Message lastMessage, int unreadCount, JobStatus jobStatus) {
    }

    public record ConversationList(List<Conversation> items) {
    }

    public record SendMessage(@NotNull @Size(max = 4000) String body, UUID photoId) {
    }

    public record MarkRead(@NotNull @Min(0) Long lastReadId) {
    }
}
