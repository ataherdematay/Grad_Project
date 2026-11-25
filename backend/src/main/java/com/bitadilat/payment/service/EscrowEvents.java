package com.bitadilat.payment.service;

import com.bitadilat.payment.domain.EscrowEventType;
import com.bitadilat.payment.domain.EscrowPayment;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Emanet olay kaydının tek yazma noktası ({@code escrow_event}). Geçişi yapan işlemin içinde çağrılır: geçiş geri
 * alınırsa olay da geri alınır. Okuma {@link PaymentTimelineService} içindedir.
 */
@Component
public class EscrowEvents {

    private final JdbcTemplate jdbc;

    public EscrowEvents(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** {@code actor}: CUSTOMER, PRO, SYSTEM veya ADMIN. */
    public void record(EscrowPayment payment, EscrowEventType type, BigDecimal amount, String actor, String note) {
        jdbc.update("insert into escrow_event (payment_ref, type, amount, actor_role, note, created_at) "
                + "values (?, ?, ?, ?, ?, ?)", payment.getRef(), type.name(), amount, actor,
                note == null ? null : note.substring(0, Math.min(note.length(), 500)), Timestamp.from(Instant.now()));
    }

    public void record(EscrowPayment payment, EscrowEventType type, BigDecimal amount, String actor) {
        record(payment, type, amount, actor, null);
    }
}
