package com.bitadilat.pro;

import com.bitadilat.common.Money;
import com.bitadilat.pro.dto.EarningsView;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Ustanın kazançları: emanet kayıtlarından (işe bağlı, uygulama kanalı) hesaplanır; yalnızca kendi payı. */
@Service
public class EarningsService {

    private final ProAccess access;
    private final JdbcTemplate jdbc;

    public EarningsService(ProAccess access, JdbcTemplate jdbc) {
        this.access = access;
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public EarningsView earnings(UUID proId) {
        access.requireApproved(proId);
        List<EarningsView.Item> items = jdbc.query("""
                select p.job_id, r.public_code, r.title, p.status, p.total_amount, p.commission, p.pro_payout,
                       p.locked_at, p.released_at, p.refunded_at, p.created_at
                from escrow_payment p
                join jobs j on j.id = p.job_id
                join service_requests r on r.id = j.request_id
                where p.pro_id = ? and p.job_id is not null
                  and p.status in ('LOCKED', 'DISPUTED', 'RELEASED_TO_PRO', 'REFUNDED_TO_CUSTOMER', 'SPLIT_SETTLED')""",
                (rs, i) -> {
                    String status = switch (rs.getString("status")) {
                        case "RELEASED_TO_PRO" -> "RELEASED";
                        case "REFUNDED_TO_CUSTOMER" -> "REFUNDED";
                        case "SPLIT_SETTLED" -> "SPLIT";
                        default -> "PENDING";
                    };
                    Timestamp when = switch (status) {
                        case "RELEASED" -> rs.getTimestamp("released_at");
                        case "REFUNDED", "SPLIT" -> rs.getTimestamp("refunded_at");
                        default -> rs.getTimestamp("locked_at");
                    };
                    Instant date = (when != null ? when : rs.getTimestamp("created_at")).toInstant();
                    return new EarningsView.Item(rs.getObject("job_id", UUID.class), rs.getString("public_code"),
                            rs.getString("title"), rs.getBigDecimal("total_amount"), rs.getBigDecimal("commission"),
                            rs.getBigDecimal("pro_payout"), status, date);
                }, proId).stream().sorted(Comparator.comparing(EarningsView.Item::date).reversed()).toList();

        BigDecimal released = BigDecimal.ZERO;
        BigDecimal pending = BigDecimal.ZERO;
        BigDecimal fees = BigDecimal.ZERO;
        for (EarningsView.Item it : items) {
            switch (it.status()) {
                case "RELEASED" -> {
                    released = released.add(it.netEarning());
                    fees = fees.add(it.serviceFee());
                }
                case "SPLIT" -> released = released.add(it.netEarning());
                case "PENDING" -> pending = pending.add(it.netEarning());
                default -> {
                }
            }
        }
        return new EarningsView(Money.of(released), Money.of(pending), Money.of(fees), items);
    }
}
