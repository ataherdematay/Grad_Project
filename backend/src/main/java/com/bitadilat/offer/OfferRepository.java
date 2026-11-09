package com.bitadilat.offer;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OfferRepository extends JpaRepository<Offer, UUID> {

    List<Offer> findByRequestIdAndStatus(UUID requestId, OfferStatus status);

    long countByRequestIdAndStatus(UUID requestId, OfferStatus status);

    List<Offer> findByProIdOrderByCreatedAtDescIdDesc(UUID proId);

    List<Offer> findByProIdAndRequestIdIn(UUID proId, Collection<UUID> requestIds);

    Optional<Offer> findByRequestIdAndProIdAndStatus(UUID requestId, UUID proId, OfferStatus status);

    Optional<Offer> findByProIdAndIdempotencyKey(UUID proId, String idempotencyKey);

    @Query("select o.requestId from Offer o where o.id = :id")
    Optional<UUID> requestIdOf(@Param("id") UUID id);

    boolean existsByRequestIdAndProId(UUID requestId, UUID proId);

    /** Talep başına: [requestId, adet, en düşük toplam, en yüksek toplam]; yalnız PENDING ve süresi dolmamış. */
    @Query("""
            select o.requestId, count(o), min(o.totalAmount), max(o.totalAmount) from Offer o
            where o.requestId in :requestIds and o.status = com.bitadilat.offer.OfferStatus.PENDING
              and o.validUntil > :now
            group by o.requestId""")
    List<Object[]> pendingStats(@Param("requestIds") Collection<UUID> requestIds, @Param("now") Instant now);
}
