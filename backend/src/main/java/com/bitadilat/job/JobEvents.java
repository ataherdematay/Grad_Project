package com.bitadilat.job;

import com.bitadilat.job.dto.JobEventView;
import com.bitadilat.media.MediaService;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/** {@code job_events}: durum değişikliklerinin, notların ve fotoğrafların zaman çizelgesi ve denetim izi. */
@Component
public class JobEvents {

    private final JdbcTemplate jdbc;
    private final MediaService media;

    public JobEvents(JdbcTemplate jdbc, MediaService media) {
        this.jdbc = jdbc;
        this.media = media;
    }

    public void record(UUID jobId, UUID actorId, ActorRole role, EventType type, JobStatus from, JobStatus to,
                       String note, UUID mediaId, Instant at) {
        jdbc.update("""
                insert into job_events (job_id, actor_id, actor_role, type, from_status, to_status, note, media_id, created_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                jobId, actorId, role.name(), type.name(), from == null ? null : from.name(),
                to == null ? null : to.name(), note, mediaId, Timestamp.from(at));
    }

    /** Eskiden yeniye. Aynı anda yazılan olaylar için {@code seq} kararlı sıra verir. */
    public List<JobEventView> timeline(UUID jobId) {
        return jdbc.query("""
                select id, type, from_status, to_status, note, media_id, actor_role, created_at
                from job_events where job_id = ? order by created_at, seq""", (rs, i) -> {
            UUID mediaId = rs.getObject("media_id", UUID.class);
            String from = rs.getString("from_status");
            String to = rs.getString("to_status");
            return new JobEventView(rs.getObject("id", UUID.class), EventType.valueOf(rs.getString("type")),
                    from == null ? null : JobStatus.valueOf(from), to == null ? null : JobStatus.valueOf(to),
                    rs.getString("note"), mediaId == null ? null : media.ref(mediaId),
                    ActorRole.valueOf(rs.getString("actor_role")), rs.getTimestamp("created_at").toInstant());
        }, jobId);
    }
}
