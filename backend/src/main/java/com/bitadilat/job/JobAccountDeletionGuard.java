package com.bitadilat.job;

import com.bitadilat.common.ApiException;
import com.bitadilat.user.AccountDeletionGuard;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Açık işi (COMPLETED, CANCELLED, RESOLVED dışı) olan müşteri veya usta, ya da süren / kilitli emaneti olan müşteri
 * hesabını silemez (409 ILLEGAL_STATE).
 */
@Component
class JobAccountDeletionGuard implements AccountDeletionGuard {

    private final JdbcTemplate jdbc;

    JobAccountDeletionGuard(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public void assertCanDelete(UUID userId) {
        Integer open = jdbc.queryForObject("""
                select count(*) from jobs
                where (customer_id = ? or pro_id = ?) and status not in ('COMPLETED', 'CANCELLED', 'RESOLVED')""",
                Integer.class, userId, userId);
        if (open != null && open > 0) {
            throw ApiException.illegalState("Açık işiniz varken hesabınızı silemezsiniz.");
        }
        // İşe bağlı olmayan para da sayılır: süren 3DS ödemesi veya iadesi bekleyen kilitli emanet (STATE_MACHINES §1).
        Integer held = jdbc.queryForObject("""
                select count(*) from escrow_payment
                where customer_id = ? and status in ('INITIALIZED', 'LOCKED', 'DISPUTED')""", Integer.class, userId);
        if (held != null && held > 0) {
            throw ApiException.illegalState("Süren veya iadesi bekleyen ödemeniz varken hesabınızı silemezsiniz.");
        }
    }
}
