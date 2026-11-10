package com.bitadilat.job;

import com.bitadilat.job.JobStateMachine.Trigger;
import java.time.Instant;
import java.util.UUID;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/** Durum geçişi + {@code job_events} satırı + kayıt: işin durumunu değiştiren tek giriş noktası. */
@Component
public class JobFlow {

    private final JobRepository jobs;
    private final JobEvents events;

    public JobFlow(JobRepository jobs, JobEvents events) {
        this.jobs = jobs;
        this.events = events;
    }

    /** Çağıran işi kilitlemiş olmalı. Geçersiz geçiş 409 ILLEGAL_STATE. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void move(Job job, Trigger trigger, UUID actorId, ActorRole role, String note, Instant now) {
        JobStatus from = job.getStatus();
        JobStateMachine.transition(job, trigger, now);
        jobs.saveAndFlush(job);
        events.record(job.getId(), actorId, role, EventType.STATUS_CHANGED, from, job.getStatus(), note, null, now);
    }
}
