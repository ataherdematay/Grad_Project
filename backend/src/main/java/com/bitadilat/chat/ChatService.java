package com.bitadilat.chat;

import com.bitadilat.chat.dto.ChatDtos.Conversation;
import com.bitadilat.chat.dto.ChatDtos.ConversationList;
import com.bitadilat.chat.dto.ChatDtos.Message;
import com.bitadilat.chat.dto.ChatDtos.MessageList;
import com.bitadilat.chat.dto.ChatDtos.SendMessage;
import com.bitadilat.common.ApiException;
import com.bitadilat.job.ActorRole;
import com.bitadilat.job.Job;
import com.bitadilat.job.JobQueryService;
import com.bitadilat.job.JobRepository;
import com.bitadilat.media.MediaPurpose;
import com.bitadilat.media.MediaService;
import com.bitadilat.notification.NotificationService;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * İş sohbeti. Yalnızca iş katılımcıları okur ve yazar (diğerleri 404). İş kapandıktan (COMPLETED, CANCELLED,
 * RESOLVED) 30 gün sonra sohbet salt okunur olur: gönderme 409 ILLEGAL_STATE, okuma ve okundu bilgisi sürer.
 */
@Service
public class ChatService {

    static final int DEFAULT_LIMIT = 50;
    static final int MAX_LIMIT = 100;

    private final JobRepository jobs;
    private final ServiceRequestRepository requests;
    private final JobQueryService views;
    private final MediaService media;
    private final NotificationService notifications;
    private final JdbcTemplate jdbc;

    public ChatService(JobRepository jobs, ServiceRequestRepository requests, JobQueryService views,
                       MediaService media, NotificationService notifications, JdbcTemplate jdbc) {
        this.jobs = jobs;
        this.requests = requests;
        this.views = views;
        this.media = media;
        this.notifications = notifications;
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public MessageList messages(UUID userId, UUID jobId, Long after, Integer limit) {
        Job job = participantJob(userId, jobId);
        long cursor = after == null ? 0 : after;
        if (cursor < 0) {
            throw ApiException.validation("after", "after negatif olamaz.");
        }
        int size = limit == null ? DEFAULT_LIMIT : limit;
        if (size < 1) {
            throw ApiException.validation("limit", "limit en az 1 olmalı.");
        }
        size = Math.min(size, MAX_LIMIT);
        List<Message> items = jdbc.query("""
                select id, sender_id, body, media_id, created_at from messages
                where job_id = ? and id > ? order by id limit ?""",
                (rs, i) -> toMessage(rs.getLong("id"), rs.getObject("sender_id", UUID.class), rs.getString("body"),
                        rs.getObject("media_id", UUID.class), rs.getTimestamp("created_at").toInstant(), job, userId),
                jobId, cursor, size);
        UUID other = otherParty(job, userId);
        Long otherRead = jdbc.query("select last_read_id from message_reads where job_id = ? and user_id = ?",
                rs -> rs.next() ? rs.getLong(1) : 0L, jobId, other);
        return new MessageList(items, otherRead == null ? 0L : otherRead);
    }

    @Transactional
    public Message send(UUID userId, UUID jobId, SendMessage b) {
        Job job = participantJob(userId, jobId);
        Instant now = Instant.now();
        String body = b.body().trim();
        if (body.isEmpty() || body.length() > 2000) {
            throw ApiException.validation("body", "body 1-2000 karakter olmalı.");
        }
        if (!job.chatOpen(now)) {
            throw ApiException.illegalState("İş kapandığı için sohbet salt okunur.");
        }
        if (b.photoId() != null) {
            media.requireAttachable(userId, List.of(b.photoId()), MediaPurpose.CHAT, "photoId",
                    MediaService.Reuse.NONE);
        }
        Instant created = Instant.now();
        long id = jdbc.queryForObject("""
                insert into messages (job_id, sender_id, body, media_id, created_at) values (?, ?, ?, ?, ?)
                returning id""", Long.class, jobId, userId, body, b.photoId(), Timestamp.from(created));

        UUID other = otherParty(job, userId);
        Integer unreadNotices = jdbc.queryForObject("""
                select count(*) from notifications
                where user_id = ? and type = 'NEW_MESSAGE' and read_at is null and params ->> 'jobId' = ?""",
                Integer.class, other, jobId.toString());
        if (unreadNotices == null || unreadNotices == 0) {
            String code = requests.findById(job.getRequestId()).map(ServiceRequest::getPublicCode).orElse("");
            notifications.notify(other, NotificationService.NEW_MESSAGE,
                    Map.of("jobId", jobId.toString(), "publicCode", code,
                            "senderRole", JobQueryService.roleOf(job, userId).name()),
                    "/jobs/" + jobId + "/chat");
        }
        return toMessage(id, userId, body, b.photoId(), created, job, userId);
    }

    /** Okundu bilgisi geriye gitmez ve işteki son mesajın ötesine geçmez. Aynı işin NEW_MESSAGE bildirimleri okunur olur. */
    @Transactional
    public void markRead(UUID userId, UUID jobId, long lastReadId) {
        participantJob(userId, jobId);
        jdbc.update("""
                insert into message_reads (job_id, user_id, last_read_id)
                values (?, ?, least(?, coalesce((select max(id) from messages where job_id = ?), 0)))
                on conflict (job_id, user_id) do update
                  set last_read_id = greatest(message_reads.last_read_id, excluded.last_read_id)""",
                jobId, userId, lastReadId, jobId);
        jdbc.update("""
                update notifications set read_at = now()
                where user_id = ? and type = 'NEW_MESSAGE' and read_at is null and params ->> 'jobId' = ?""",
                userId, jobId.toString());
    }

    @Transactional(readOnly = true)
    public ConversationList conversations(UUID userId, String as) {
        ActorRole role;
        if ("CUSTOMER".equals(as)) {
            role = ActorRole.CUSTOMER;
        } else if ("PRO".equals(as)) {
            role = ActorRole.PRO;
        } else {
            throw ApiException.validation("as", "as CUSTOMER veya PRO olmalı.");
        }
        List<Job> mine = role == ActorRole.CUSTOMER
                ? jobs.findByCustomerIdOrderByUpdatedAtDescIdDesc(userId)
                : jobs.findByProIdOrderByUpdatedAtDescIdDesc(userId);
        record Row(Conversation conversation, Instant activity) {
        }
        List<Row> rows = mine.stream().map(job -> {
            Message last = lastMessage(job, userId);
            ServiceRequest r = requests.findById(job.getRequestId()).orElseThrow();
            Conversation c = new Conversation(job.getId(), r.getPublicCode(), r.getTitle(),
                    views.counterpart(job, role), last, views.unread(job.getId(), userId), job.getStatus());
            return new Row(c, last != null ? last.createdAt() : job.getUpdatedAt());
        }).sorted(Comparator.comparing(Row::activity).reversed()).toList();
        return new ConversationList(rows.stream().map(Row::conversation).toList());
    }

    // ─── Yardımcılar ────────────────────────────────────────────────────────

    private Message lastMessage(Job job, UUID viewerId) {
        List<Message> found = jdbc.query("""
                select id, sender_id, body, media_id, created_at from messages
                where job_id = ? order by id desc limit 1""",
                (rs, i) -> toMessage(rs.getLong("id"), rs.getObject("sender_id", UUID.class), rs.getString("body"),
                        rs.getObject("media_id", UUID.class), rs.getTimestamp("created_at").toInstant(), job, viewerId),
                job.getId());
        return found.isEmpty() ? null : found.get(0);
    }

    private Message toMessage(long id, UUID senderId, String body, UUID mediaId, Instant createdAt, Job job,
                              UUID viewerId) {
        ActorRole senderRole = senderId.equals(job.getCustomerId()) ? ActorRole.CUSTOMER : ActorRole.PRO;
        return new Message(id, senderRole, senderId.equals(viewerId), body,
                mediaId == null ? null : media.ref(mediaId), createdAt);
    }

    private Job participantJob(UUID userId, UUID jobId) {
        Job job = jobs.findById(jobId).orElseThrow(() -> ApiException.notFound("İş bulunamadı."));
        if (JobQueryService.roleOf(job, userId) == null) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        return job;
    }

    private static UUID otherParty(Job job, UUID userId) {
        return job.getCustomerId().equals(userId) ? job.getProId() : job.getCustomerId();
    }
}
