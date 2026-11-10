package com.bitadilat.job;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface JobRepository extends JpaRepository<Job, UUID> {

    /** {@code SELECT … FOR UPDATE}: durum değiştiren her işlem önce işi bununla kilitler (sıra: iş, emanet, talep). */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select j from Job j where j.id = :id")
    Optional<Job> lockById(@Param("id") UUID id);

    List<Job> findByCustomerIdOrderByUpdatedAtDescIdDesc(UUID customerId);

    List<Job> findByProIdOrderByUpdatedAtDescIdDesc(UUID proId);
}
