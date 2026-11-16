package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.ReviewCheck;
import com.bitadilat.admin.AdminDtos.ReviewItem;
import com.bitadilat.admin.AdminDtos.ReviewList;
import com.bitadilat.admin.AdminDtos.ReviewResolveBody;
import com.bitadilat.common.ApiException;
import com.bitadilat.job.EscrowNotifications;
import com.bitadilat.job.JobStatus;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowPendingAction;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.gateway.PaymentGateway;
import com.bitadilat.payment.gateway.PaymentGateway.RefundState;
import com.bitadilat.payment.service.EscrowService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Elle incelemeye düşmüş emanetler ({@code REFUND_NEEDS_REVIEW}, {@code PAYOUT_NEEDS_REVIEW}) ve admin çözümü.
 *
 * <p>Para güvenliği: her çözüm satır kilidi altında önce Craftgate'e gerçek iade durumunu sorar; izin verilen çözümler
 * yalnızca bu yanıttan hesaplanır ({@link #allowed}). Böylece Craftgate'te iade edilmiş bir ödeme ustaya aktarılmaz,
 * iade edilmiş tutar ikinci kez gönderilmez (yeniden iade yalnızca kalanı gönderir) ve iade edilmemiş bir ödeme
 * "iade edildi" diye işaretlenmez. Craftgate yanıt vermezse 502, hiçbir şey değişmez.
 */
@Slf4j
@Service
public class AdminPaymentReviewService {

    static final int MAX_ITEMS = 500;
    static final String ACTION = "RESOLVE_PAYMENT_REVIEW";
    static final String TARGET = "PAYMENT";

    /** Admin çözümü. */
    public enum Resolution {
        /** Craftgate'te tam iade görünüyor: para gönderilmez, yalnızca defter ve durum işlenir. */
        MARK_REFUNDED,
        /** Kalan tutar iade edilir (iade edilmiş tutar düşülür; hiç iade yoksa tam iade). */
        RETRY_REFUND,
        /** Tamamlanmış işin ödemesi ustaya aktarılır; yalnızca Craftgate'te hiç iade yoksa. */
        RELEASE
    }

    private static final String SELECT = """
            select e.ref, e.job_id, e.job_ref, j.status as job_status, e.status, e.error_code, e.pending_action,
                   e.total_amount, e.refunded_amount, cu.full_name as customer_name, p.business_name,
                   e.refund_attempts, e.last_refund_attempt_at, e.created_at
            from escrow_payment e
            left join jobs j on j.id = e.job_id
            left join users cu on cu.id = e.customer_id
            left join pro_profiles p on p.user_id = e.pro_id
            where e.status in ('LOCKED', 'DISPUTED')
              and e.error_code in ('REFUND_NEEDS_REVIEW', 'PAYOUT_NEEDS_REVIEW')""";

    private final JdbcTemplate jdbc;
    private final EscrowPaymentRepository repository;
    private final PaymentGateway gateway;
    private final EscrowService escrow;
    private final EscrowNotifications notifications;
    private final AdminAudit audit;

    public AdminPaymentReviewService(JdbcTemplate jdbc, EscrowPaymentRepository repository, PaymentGateway gateway,
                                     EscrowService escrow, EscrowNotifications notifications, AdminAudit audit) {
        this.jdbc = jdbc;
        this.repository = repository;
        this.gateway = gateway;
        this.escrow = escrow;
        this.notifications = notifications;
        this.audit = audit;
    }

    /** İncelemedeki kayıtlar, en eski önce (en çok {@value #MAX_ITEMS}). Craftgate'e gidilmez. */
    @Transactional(readOnly = true)
    public ReviewList list() {
        return new ReviewList(jdbc.query(SELECT + " order by e.created_at, e.ref limit " + MAX_ITEMS,
                (rs, i) -> item(rs)));
    }

    /** Kaydın güncel Craftgate iade durumu ve bu duruma göre izin verilen çözümler (salt okunur). */
    @Transactional(readOnly = true)
    public ReviewCheck check(String ref) {
        ReviewItem item = fetch(ref);
        EscrowPayment p = repository.findById(ref).orElseThrow(() -> ApiException.notFound("Ödeme bulunamadı."));
        Gateway g = ask(p);
        return new ReviewCheck(item, g.state().name(), g.refunded(), allowed(p, g));
    }

    /**
     * Çözümü uygular. Sıra: satır kilidi, Craftgate'e sorma, izin denetimi, denetim satırı ve bildirimler, en son para
     * hareketi. Craftgate hatası (502) veya tutarsızlık (409) her şeyi geri alır.
     */
    @Transactional
    public ReviewCheck resolve(UUID adminId, String ref, ReviewResolveBody body) {
        String note = AdminAudit.requiredNote(body == null ? null : body.note(), 10, 1000);
        if (body.resolution() == null) {
            throw ApiException.validation("resolution", "resolution zorunlu.");
        }
        Resolution resolution = AdminAudit.parseEnum(Resolution.class, body.resolution(), "resolution");
        EscrowPayment p = repository.findForUpdate(ref).orElseThrow(() -> ApiException.notFound("Ödeme bulunamadı."));
        if (!p.needsReview() || (p.getStatus() != EscrowStatus.LOCKED && p.getStatus() != EscrowStatus.DISPUTED)) {
            throw ApiException.illegalState("Bu ödeme elle incelemede değil.");
        }
        Gateway g = ask(p);
        if (!allowed(p, g).contains(resolution.name())) {
            log.warn("Admin çözümü Craftgate durumuyla uyuşmadı; uygulanmadı. ref={} çözüm={} durum={} iade={}",
                    ref, resolution, g.state(), g.refunded().toPlainString());
            throw ApiException.illegalState("Craftgate'teki iade durumu (" + g.state() + ", "
                    + g.refunded().toPlainString() + " TL) bu çözüme izin vermiyor.");
        }
        audit.record(adminId, ACTION, TARGET, ref, resolution.name() + ": " + note);
        switch (resolution) {
            case MARK_REFUNDED -> {
                escrow.recordRefundAlreadyDone(p);
                p.clearReview();
                repository.saveAndFlush(p);
                notifications.refundCompleted(p);
            }
            case RETRY_REFUND -> {
                p.clearReview();
                // Yeniden Craftgate'e sorar ve yalnızca kalanı iade eder; hata işlemi geri alır.
                escrow.refundFully(p);
                notifications.refundCompleted(p);
            }
            case RELEASE -> {
                p.clearReview();
                // Craftgate'te iade görünürse 409 ile durur (kontrolden sonra iade yapılmış olabilir).
                escrow.releaseAfterDispute(p);
                notifications.payoutCompleted(p);
            }
        }
        log.info("Admin incelemesi çözüldü. ref={} çözüm={} admin={}", ref, resolution, adminId);
        return new ReviewCheck(fetchAny(ref), g.state().name(), g.refunded(), List.of());
    }

    /**
     * Craftgate durumundan izin verilen çözümler. Para iki kez hareket etmez:
     * <ul>
     *   <li>Sonuç bekleyen iade veya okunamayan durum: çözüm yok (sonra yeniden sorulur).</li>
     *   <li>Tam iade edilmiş: yalnızca {@code MARK_REFUNDED}.</li>
     *   <li>Toplamdan az kısmi iade: yalnızca {@code RETRY_REFUND} (kalan gider). Ustaya aktarım yok.</li>
     *   <li>Toplam kadar iade görünüyor ama durum tam iade değil: tutarsız, çözüm yok.</li>
     *   <li>Hiç iade yok: {@code RETRY_REFUND}; tamamlanmış işin bekleyen aktarımında ({@code RELEASE} niyeti, emanet
     *       LOCKED) yalnızca {@code RELEASE}.</li>
     * </ul>
     */
    static List<String> allowed(EscrowPayment p, Gateway g) {
        BigDecimal total = p.getTotalAmount();
        return switch (g.state()) {
            case REFUND_PENDING -> List.of();
            case FULLY_REFUNDED -> List.of(Resolution.MARK_REFUNDED.name());
            case PARTIALLY_REFUNDED -> g.refunded().signum() > 0 && g.refunded().compareTo(total) < 0
                    ? List.of(Resolution.RETRY_REFUND.name()) : List.of();
            case NOT_REFUNDED -> {
                if (g.refunded().signum() > 0) {
                    yield g.refunded().compareTo(total) < 0 ? List.of(Resolution.RETRY_REFUND.name()) : List.of();
                }
                yield p.getPendingAction() == EscrowPendingAction.RELEASE && p.getStatus() == EscrowStatus.LOCKED
                        ? List.of(Resolution.RELEASE.name())
                        : List.of(Resolution.RETRY_REFUND.name());
            }
        };
    }

    record Gateway(RefundState state, BigDecimal refunded) {
    }

    /** Craftgate'e iade durumu ve toplamı sorulur. Sonuç bekleyen iade: REFUND_PENDING. Yanıt yok: 502. */
    private Gateway ask(EscrowPayment p) {
        if (p.isSeed() || p.getCraftgatePaymentId() == null) {
            return new Gateway(RefundState.NOT_REFUNDED, money(BigDecimal.ZERO));
        }
        RefundState reported = gateway.refundState(p.getCraftgatePaymentId());
        RefundState state = reported == null ? RefundState.NOT_REFUNDED : reported;
        if (state == RefundState.REFUND_PENDING) {
            return new Gateway(state, money(p.getRefundedAmount()));
        }
        // Kalemde sonuç bekleyen iade varsa refundedTotal GatewayException fırlatır: 502, çözüm sonra denenir.
        BigDecimal refunded = money(gateway.refundedTotal(p.getCraftgatePaymentId()));
        return new Gateway(state, refunded);
    }

    private ReviewItem fetch(String ref) {
        return jdbc.query(SELECT + " and e.ref = ?", (rs, i) -> item(rs), ref).stream().findFirst()
                .orElseThrow(() -> ApiException.notFound("İncelemede böyle bir ödeme yok."));
    }

    /** Çözümden sonra (artık incelemede değil) kaydın güncel hali. */
    private ReviewItem fetchAny(String ref) {
        String sql = SELECT.substring(0, SELECT.indexOf("where e.status")) + "where e.ref = ?";
        return jdbc.query(sql, (rs, i) -> item(rs), ref).stream().findFirst()
                .orElseThrow(() -> ApiException.notFound("Ödeme bulunamadı."));
    }

    private static ReviewItem item(java.sql.ResultSet rs) throws java.sql.SQLException {
        String jobStatus = rs.getString("job_status");
        String pending = rs.getString("pending_action");
        java.sql.Timestamp last = rs.getTimestamp("last_refund_attempt_at");
        return new ReviewItem(rs.getString("ref"), rs.getObject("job_id", UUID.class), rs.getString("job_ref"),
                jobStatus == null ? null : JobStatus.valueOf(jobStatus), EscrowStatus.valueOf(rs.getString("status")),
                rs.getString("error_code"), pending == null ? null : EscrowPendingAction.valueOf(pending),
                money(rs.getBigDecimal("total_amount")), money(rs.getBigDecimal("refunded_amount")),
                rs.getString("customer_name"), rs.getString("business_name"), rs.getInt("refund_attempts"),
                last == null ? null : last.toInstant(), rs.getTimestamp("created_at").toInstant());
    }

    private static BigDecimal money(BigDecimal v) {
        return (v == null ? BigDecimal.ZERO : v).setScale(2, RoundingMode.HALF_UP);
    }
}
