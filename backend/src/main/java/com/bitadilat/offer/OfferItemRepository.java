package com.bitadilat.offer;

import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OfferItemRepository extends JpaRepository<OfferItem, UUID> {

    List<OfferItem> findByOfferIdInOrderBySortOrderAsc(Collection<UUID> offerIds);
}
