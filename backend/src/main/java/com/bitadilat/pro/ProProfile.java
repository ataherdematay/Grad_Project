package com.bitadilat.pro;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "pro_profiles")
@Getter
@Setter
@NoArgsConstructor
public class ProProfile {

    /** users.id ile aynı. */
    @Id
    private UUID userId;

    @Column(nullable = false)
    private String businessName;

    private String bio;

    @Column(nullable = false)
    private int experienceYears;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReviewStatus reviewStatus = ReviewStatus.PENDING_REVIEW;

    private String reviewNote;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Availability availability = Availability.ACTIVE;

    @Column(precision = 3, scale = 2)
    private BigDecimal ratingAvg;

    @Column(nullable = false)
    private int ratingCount;

    @Column(nullable = false)
    private int completedJobs;

    @Column(nullable = false)
    private int cancellationCount;

    @Column(nullable = false)
    private int warningCount;

    private Instant approvedAt;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private Instant updatedAt;

    @Version
    private Long version;
}
