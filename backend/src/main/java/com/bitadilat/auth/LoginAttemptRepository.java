package com.bitadilat.auth;

import java.time.Instant;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface LoginAttemptRepository extends JpaRepository<LoginAttempt, UUID> {

    /**
     * Aynı tanımlayıcı için girişleri işlem sonuna kadar sıraya sokar (Postgres advisory lock). Böylece paralel
     * istekler sayaç kontrolünü aynı anda geçip sınırı aşamaz.
     */
    @Query(value = "select 1 from pg_advisory_xact_lock(hashtextextended(:hash, 0))", nativeQuery = true)
    Integer lockIdentifier(@Param("hash") String hash);

    long countByIdentifierHashAndSuccessFalseAndCreatedAtAfter(String identifierHash, Instant since);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("delete from LoginAttempt a where a.identifierHash = :hash and a.success = false")
    void clearFailures(@Param("hash") String hash);
}
