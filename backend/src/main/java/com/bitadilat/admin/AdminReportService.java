package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.PaymentItem;
import com.bitadilat.admin.AdminDtos.PaymentLedger;
import com.bitadilat.admin.AdminDtos.PaymentTotals;
import com.bitadilat.admin.AdminDtos.Stats;
import com.bitadilat.payment.domain.EscrowProvider;
import com.bitadilat.payment.domain.EscrowStatus;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Özet sayılar ve emanet defteri (salt okunur). */
@Service
public class AdminReportService {

    static final int MAX_ITEMS = 500;

    private final JdbcTemplate jdbc;

    public AdminReportService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * {@code activeJobs}: COMPLETED, CANCELLED ve RESOLVED dışındaki işler (DISPUTED dahil).
     * {@code lockedEscrowTotal}: LOCKED ve DISPUTED emanetlerin toplam tutarı.
     */
    @Transactional(readOnly = true)
    public Stats stats() {
        Integer pending = jdbc.queryForObject(
                "select count(*) from pro_profiles where review_status = 'PENDING_REVIEW'", Integer.class);
        Integer complaints = jdbc.queryForObject(
                "select count(*) from complaints where status in ('OPEN', 'IN_REVIEW')", Integer.class);
        Integer active = jdbc.queryForObject(
                "select count(*) from jobs where status not in ('COMPLETED', 'CANCELLED', 'RESOLVED')", Integer.class);
        BigDecimal locked = jdbc.queryForObject(
                "select coalesce(sum(total_amount), 0) from escrow_payment where status in ('LOCKED', 'DISPUTED')",
                BigDecimal.class);
        return new Stats(pending == null ? 0 : pending, complaints == null ? 0 : complaints,
                active == null ? 0 : active, money(locked));
    }

    /**
     * Tüm emanet kayıtları, en yeni önce (en çok {@value #MAX_ITEMS}). {@code totals} süzgece uyan tüm satırlar
     * üzerinden hesaplanır: lockedTotal = LOCKED/DISPUTED tutarı, releasedTotal = ustalara yazılan pay
     * (RELEASED_TO_PRO ve SPLIT_SETTLED), commissionTotal = alınan komisyon, refundedTotal = müşteriye iade edilen.
     */
    @Transactional(readOnly = true)
    public PaymentLedger payments(String status) {
        List<Object> args = new ArrayList<>();
        String where = "";
        if (status != null && !status.isBlank()) {
            args.add(AdminAudit.parseEnum(EscrowStatus.class, status, "status").name());
            where = " where e.status = ?";
        }
        List<PaymentItem> items = jdbc.query("""
                select e.ref, e.job_ref, e.status, e.provider, e.total_amount, e.commission, e.pro_payout,
                       e.refunded_amount, cu.full_name as customer_name, p.business_name, e.created_at, e.locked_at,
                       e.released_at, e.refunded_at, e.error_code
                from escrow_payment e
                left join users cu on cu.id = e.customer_id
                left join pro_profiles p on p.user_id = e.pro_id""" + where
                + " order by e.created_at desc, e.ref desc limit " + MAX_ITEMS,
                (rs, i) -> new PaymentItem(rs.getString("ref"), rs.getString("job_ref"),
                        EscrowStatus.valueOf(rs.getString("status")), EscrowProvider.valueOf(rs.getString("provider")),
                        rs.getBigDecimal("total_amount"), rs.getBigDecimal("commission"),
                        rs.getBigDecimal("pro_payout"), rs.getBigDecimal("refunded_amount"),
                        rs.getString("customer_name"), rs.getString("business_name"),
                        instant(rs.getTimestamp("created_at")), instant(rs.getTimestamp("locked_at")),
                        instant(rs.getTimestamp("released_at")), instant(rs.getTimestamp("refunded_at")),
                        rs.getString("error_code")), args.toArray());
        PaymentTotals totals = jdbc.queryForObject("""
                select
                  coalesce(sum(total_amount) filter (where status in ('LOCKED', 'DISPUTED')), 0) as locked,
                  coalesce(sum(pro_payout) filter (where status in ('RELEASED_TO_PRO', 'SPLIT_SETTLED')), 0) as released,
                  coalesce(sum(commission) filter (where status = 'RELEASED_TO_PRO'), 0) as commission,
                  coalesce(sum(refunded_amount) filter (where status in ('REFUNDED_TO_CUSTOMER', 'SPLIT_SETTLED')), 0)
                      as refunded
                from escrow_payment e""" + where,
                (rs, i) -> new PaymentTotals(money(rs.getBigDecimal("locked")), money(rs.getBigDecimal("released")),
                        money(rs.getBigDecimal("commission")), money(rs.getBigDecimal("refunded"))), args.toArray());
        return new PaymentLedger(items, totals);
    }

    private static BigDecimal money(BigDecimal v) {
        return (v == null ? BigDecimal.ZERO : v).setScale(2, RoundingMode.HALF_UP);
    }

    private static Instant instant(java.sql.Timestamp t) {
        return t == null ? null : t.toInstant();
    }
}
