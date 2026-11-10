package com.bitadilat.job;

import com.bitadilat.common.ApiException;
import com.bitadilat.user.AccountDeletionGuard;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/** Açık işi (COMPLETED, CANCELLED, RESOLVED dışı) olan müşteri veya usta hesabını silemez (409 ILLEGAL_STATE). */
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
    }
}
