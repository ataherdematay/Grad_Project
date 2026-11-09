package com.bitadilat.offer;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
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
@Table(name = "offers")
@Getter
@Setter
@NoArgsConstructor
public class Offer {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String publicCode;

    @Column(nullable = false)
    private UUID requestId;

    /** pro_profiles.user_id */
    @Column(nullable = false)
    private UUID proId;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal laborAmount;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal materialsAmount;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(nullable = false)
    private Instant arrivalFrom;

    @Column(nullable = false)
    private Instant arrivalTo;

    @Column(nullable = false)
    private int warrantyMonths;

    private String note;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OfferStatus status = OfferStatus.PENDING;

    @Column(nullable = false)
    private Instant validUntil;

    @Enumerated(EnumType.STRING)
    private DeclineReason declineReason;

    private String declineNote;

    private String idempotencyKey;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private Instant updatedAt;

    @Version
    private Long version;

    /** Durum yalnızca bu yöntemle değişir; geçersiz geçiş 409 ILLEGAL_STATE. */
    public void moveTo(OfferStatus target) {
        this.status = status.to(target);
    }

    /**
     * PENDING bir teklif {@code valid_until} geçince okuma anında EXPIRED sayılır (zamanlayıcı henüz işlememiş olsa
     * da). Talebin kendisi süresi dolmuş veya kapanmışsa çağıran {@code requestOpen=false} verir.
     */
    public OfferStatus effectiveStatus(Instant now, boolean requestOpen) {
        if (status == OfferStatus.PENDING && (!validUntil.isAfter(now) || !requestOpen)) {
            return OfferStatus.EXPIRED;
        }
        return status;
    }
}
