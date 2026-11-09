package com.bitadilat.request;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "service_requests")
@Getter
@Setter
@NoArgsConstructor
public class ServiceRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String publicCode;

    @Column(nullable = false)
    private UUID customerId;

    @Column(nullable = false)
    private String categoryId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Urgency urgency;

    private Instant preferredFrom;

    private Instant preferredTo;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String description;

    @Column(nullable = false)
    private Integer districtId;

    @Column(nullable = false)
    private String neighborhood;

    private UUID addressId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RequestStatus status = RequestStatus.OPEN;

    @Column(nullable = false)
    private int matchedProCount;

    @Column(nullable = false)
    private Instant expiresAt;

    @Enumerated(EnumType.STRING)
    private CancelReason cancelReason;

    private String cancelNote;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private Instant updatedAt;

    @Version
    private Long version;

    /** Durum yalnızca bu yöntemle değişir; geçersiz geçiş 409 ILLEGAL_STATE. */
    public void moveTo(RequestStatus target) {
        this.status = status.to(target);
    }

    /** OPEN iken süresi dolmuş ama zamanlayıcı henüz işlememiş talep okuma anında EXPIRED sayılır. */
    public RequestStatus effectiveStatus(Instant now) {
        return status == RequestStatus.OPEN && !expiresAt.isAfter(now) ? RequestStatus.EXPIRED : status;
    }

    public boolean isOpenAt(Instant now) {
        return effectiveStatus(now) == RequestStatus.OPEN;
    }
}
