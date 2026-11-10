package com.bitadilat.job;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * İş. Durum yalnızca {@link JobStateMachine} ile değişir (setter bilerek yok). Durum değiştiren her işlem satırı önce
 * {@code FOR UPDATE} ile kilitler.
 */
@Entity
@Table(name = "jobs")
@Getter
@Setter
@NoArgsConstructor
public class Job {

    /** İş kapandıktan sonra sohbet bu süre açık kalır. */
    public static final Duration CHAT_GRACE = Duration.ofDays(30);

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID requestId;

    @Column(nullable = false)
    private UUID offerId;

    @Column(nullable = false)
    private UUID customerId;

    /** pro_profiles.user_id */
    @Column(nullable = false)
    private UUID proId;

    @Setter(AccessLevel.NONE)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private JobStatus status = JobStatus.AWAITING_APPOINTMENT;

    @Setter(AccessLevel.NONE)
    @Enumerated(EnumType.STRING)
    private JobStatus statusBeforeDispute;

    private Instant scheduledFrom;
    private Instant scheduledTo;
    private Instant arrivedAt;
    private Instant startedAt;
    private Instant finishedAt;
    private Instant completedAt;
    private Instant cancelledAt;

    @Enumerated(EnumType.STRING)
    private ActorRole cancelledBy;

    private String cancelReason;
    private String cancelNote;

    private Instant autoCompleteAt;
    private Instant autoCompleteRemindedAt;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private Instant updatedAt;

    @Version
    private Long version;

    /** Yalnızca {@link JobStateMachine} çağırır. */
    void applyStatus(JobStatus next) {
        this.status = next;
    }

    void rememberStatusBeforeDispute(JobStatus before) {
        this.statusBeforeDispute = before;
    }

    /** İş kapanış zamanı; açık işte null. RESOLVED için kapanış zamanı updatedAt kabul edilir. */
    public Instant closedAt() {
        return switch (status) {
            case COMPLETED -> completedAt;
            case CANCELLED -> cancelledAt;
            case RESOLVED -> updatedAt;
            default -> null;
        };
    }

    /** Sohbet, iş kapandıktan 30 gün sonra salt okunur olur. */
    public boolean chatOpen(Instant now) {
        Instant closed = closedAt();
        return closed == null || closed.plus(CHAT_GRACE).isAfter(now);
    }
}
