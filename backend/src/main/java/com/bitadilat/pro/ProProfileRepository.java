package com.bitadilat.pro;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProProfileRepository extends JpaRepository<ProProfile, UUID> {

    /** {@code SELECT … FOR UPDATE}: admin başvuru kararları aynı profili aynı anda değiştiremez. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from ProProfile p where p.userId = :id")
    Optional<ProProfile> lockById(@Param("id") UUID id);
}
