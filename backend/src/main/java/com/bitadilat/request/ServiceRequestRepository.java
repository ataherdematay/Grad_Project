package com.bitadilat.request;

import jakarta.persistence.LockModeType;
import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ServiceRequestRepository extends JpaRepository<ServiceRequest, UUID> {

    /** {@code SELECT … FOR UPDATE}: durum değiştiren her işlem talebi önce bununla kilitler. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select r from ServiceRequest r where r.id = :id")
    Optional<ServiceRequest> lockById(@Param("id") UUID id);

    Optional<ServiceRequest> findByIdAndCustomerId(UUID id, UUID customerId);

    List<ServiceRequest> findByCustomerIdOrderByCreatedAtDescIdDesc(UUID customerId);

    @Query("""
            select r from ServiceRequest r
            where r.status = com.bitadilat.request.RequestStatus.OPEN and r.expiresAt > :now
              and r.customerId <> :proId
              and r.categoryId in :categoryIds and r.districtId in :districtIds
            order by r.createdAt desc, r.id desc""")
    List<ServiceRequest> feed(@Param("now") Instant now, @Param("proId") UUID proId,
                              @Param("categoryIds") Collection<String> categoryIds,
                              @Param("districtIds") Collection<Integer> districtIds);
}
