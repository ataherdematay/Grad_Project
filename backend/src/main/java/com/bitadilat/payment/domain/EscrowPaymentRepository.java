package com.bitadilat.payment.domain;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EscrowPaymentRepository extends JpaRepository<EscrowPayment, String> {

    boolean existsByAttemptKey(String attemptKey);

    /*
     * Durum değiştiren işlemler satırı kilitler. Aynı callback iki kez gelse veya iade düğmesine
     * iki kez basılsa ikinci istek ilkinin bitmesini bekler ve güncel durumu görür.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from EscrowPayment p where p.ref = :ref")
    Optional<EscrowPayment> findForUpdate(@Param("ref") String ref);

    boolean existsByRequestIdAndStatus(java.util.UUID requestId, EscrowStatus status);

    /** İşin emaneti (iş kilidinden sonra alınır: kilit sırası iş, emanet, talep). */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from EscrowPayment p where p.jobId = :jobId")
    Optional<EscrowPayment> findByJobIdForUpdate(@Param("jobId") java.util.UUID jobId);

    Optional<EscrowPayment> findByJobId(java.util.UUID jobId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from EscrowPayment p where p.conversationId = :conversationId")
    Optional<EscrowPayment> findByConversationIdForUpdate(@Param("conversationId") String conversationId);
}
