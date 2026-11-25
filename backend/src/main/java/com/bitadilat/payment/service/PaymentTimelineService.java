package com.bitadilat.payment.service;

import com.bitadilat.common.ApiException;
import com.bitadilat.common.Paging;
import com.bitadilat.job.ActorRole;
import com.bitadilat.payment.domain.EscrowChannel;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowProvider;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.payment.dto.PaymentDemoDtos.Amounts;
import com.bitadilat.payment.dto.PaymentDemoDtos.CardInfo;
import com.bitadilat.payment.dto.PaymentDemoDtos.Counts;
import com.bitadilat.payment.dto.PaymentDemoDtos.MoneyLocation;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentHistory;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentHistoryItem;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentReceipt;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentSummary;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentTimeline;
import com.bitadilat.payment.dto.PaymentDemoDtos.ReceiptItem;
import com.bitadilat.payment.dto.PaymentDemoDtos.TimelineEvent;
import com.bitadilat.payment.gateway.PaymentGateway;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Ödeme zaman çizelgesi, makbuz, müşteri ödeme geçmişi ve admin kasa özeti (salt okunur, Craftgate çağrısı yok).
 *
 * <p>Zaman çizelgesi iki kaynaktan birleşir: emanete ait olaylar {@code escrow_event} tablosundan ({@link EscrowEvents}),
 * iş kaynaklı olaylar (teslim, müşteri onayı/otomatik onay, otomatik aktarım zamanı) {@code job_events} ve {@code jobs}
 * kayıtlarından. Tabloda olmayan olay türleri (eski ve seed kayıtlar) emanet satırındaki zaman damgalarından türetilir.
 * Zaman damgası olan türlerde (kilit, aktarım, iade) saat satırdan alınır: seed anlatısı tutarlı kalır.
 */
@Service
public class PaymentTimelineService {

    /** Bu rol, görüntüleyenin rolüdür; alan görünürlüğünü belirler. */
    public enum Viewer { CUSTOMER, PRO, ADMIN }

    static final String SANDBOX_NOTICE = "Bu bir sandbox (deneme) ödemesidir; kartınızdan gerçek para çekilmemiştir.";

    /** Aynı anda olan olayların kararlı sırası. */
    private static final List<String> ORDER = List.of("PAYMENT_INITIALIZED", "THREEDS_STARTED", "PAYMENT_LOCKED",
            "WORK_DELIVERED", "AUTO_RELEASE_SCHEDULED", "DISPUTE_OPENED", "CUSTOMER_APPROVED", "AUTO_APPROVED",
            "REFUND_REQUESTED", "RELEASED_TO_PRO", "REFUNDED", "SPLIT_SETTLED", "REVIEW_REQUIRED", "FAILED");

    private static final Set<EscrowStatus> PAID_STATES = EnumSet.of(EscrowStatus.LOCKED, EscrowStatus.DISPUTED,
            EscrowStatus.RELEASED_TO_PRO, EscrowStatus.REFUNDED_TO_CUSTOMER, EscrowStatus.SPLIT_SETTLED);

    private final EscrowPaymentRepository escrows;
    private final JdbcTemplate jdbc;
    private final PaymentGateway gateway;
    private final boolean sandboxGateway;

    public PaymentTimelineService(EscrowPaymentRepository escrows, JdbcTemplate jdbc, PaymentGateway gateway,
                                  @Value("${craftgate.base-url:}") String craftgateBaseUrl) {
        this.escrows = escrows;
        this.jdbc = jdbc;
        this.gateway = gateway;
        this.sandboxGateway = isSandboxHost(craftgateBaseUrl);
    }

    static boolean isSandboxHost(String baseUrl) {
        try {
            String host = baseUrl == null || baseUrl.isBlank() ? null : URI.create(baseUrl.trim()).getHost();
            return host != null && host.startsWith("sandbox");
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    // ─── Uç noktalar ────────────────────────────────────────────────────────

    /** İşin ödeme zaman çizelgesi: müşteri, usta ve admin; diğerleri 404. */
    @Transactional(readOnly = true)
    public PaymentTimeline timelineForJob(UUID userId, boolean admin, UUID jobId) {
        JobRow job = jobRow(jobId);
        Viewer viewer = viewerOf(job, userId, admin);
        return timeline(escrowOf(jobId), viewer);
    }

    /** Admin: ödeme ref'ine göre aynı DTO (işi olmayan öksüz ödeme dahil). */
    @Transactional(readOnly = true)
    public PaymentTimeline timelineForRef(String ref) {
        EscrowPayment p = escrows.findById(ref).filter(x -> x.getChannel() == EscrowChannel.APP)
                .orElseThrow(() -> ApiException.notFound("Ödeme kaydı bulunamadı."));
        return timeline(p, Viewer.ADMIN);
    }

    /** Makbuz: işin müşterisi ve admin. Usta (katılımcı ama yetkisiz) 403, yabancı 404. */
    @Transactional(readOnly = true)
    public PaymentReceipt receipt(UUID userId, boolean admin, UUID jobId) {
        JobRow job = jobRow(jobId);
        Viewer viewer = viewerOf(job, userId, admin);
        if (viewer == Viewer.PRO) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Makbuzu yalnızca müşteri görebilir.");
        }
        EscrowPayment p = escrowOf(jobId);
        if (!PAID_STATES.contains(p.getStatus())) {
            throw ApiException.illegalState("Ödeme tamamlanmadığı için makbuz yok.");
        }
        List<ReceiptItem> items = jdbc.query("""
                select kind, description, quantity, unit_price from offer_items
                where offer_id = ?::uuid order by sort_order, id""", (rs, i) -> {
            BigDecimal qty = rs.getBigDecimal("quantity");
            BigDecimal unit = rs.getBigDecimal("unit_price");
            return new ReceiptItem(rs.getString("kind"), rs.getString("description"), qty, unit,
                    money(qty.multiply(unit)));
        }, p.getOfferId());
        if (items.isEmpty()) {
            // Teklifte kalem yoksa yalnızca işçilik ve malzeme toplamları vardır.
            items = new ArrayList<>(jdbc.query(
                    "select labor_amount, materials_amount from offers where id = ?::uuid", (rs, i) -> {
                        List<ReceiptItem> l = new ArrayList<>();
                        l.add(new ReceiptItem("LABOR", "İşçilik", BigDecimal.ONE.setScale(2),
                                money(rs.getBigDecimal("labor_amount")), money(rs.getBigDecimal("labor_amount"))));
                        if (rs.getBigDecimal("materials_amount").signum() > 0) {
                            l.add(new ReceiptItem("MATERIAL", "Malzeme", BigDecimal.ONE.setScale(2),
                                    money(rs.getBigDecimal("materials_amount")),
                                    money(rs.getBigDecimal("materials_amount"))));
                        }
                        return l;
                    }, p.getOfferId()).stream().flatMap(List::stream).toList());
        }
        Instant issued = p.getLockedAt() != null ? p.getLockedAt() : p.getCreatedAt();
        String no = "BT-" + DateTimeFormatter.ofPattern("yyyyMMdd").withZone(ZoneOffset.UTC).format(issued) + "-"
                + p.getRef().replace("-", "").substring(0, 6).toUpperCase();
        boolean sandbox = sandbox(p);
        return new PaymentReceipt(no, issued, p.getRef(), job.id(), job.publicCode(), job.title(),
                proName(p.getProId()), customerName(p.getCustomerId()), items, money(p.getTotalAmount()),
                money(p.getRefundedAmount()), money(p.getTotalAmount().subtract(p.getRefundedAmount())), "TRY",
                card(p), p.getStatus(), location(p.getStatus()), providerOf(p), sandbox,
                sandbox ? SANDBOX_NOTICE : null);
    }

    /** Müşterinin ödeme geçmişi (yeniden eskiye): kilitlenmiş ve sonrası; başarısız/yarım denemeler yok. */
    @Transactional(readOnly = true)
    public PaymentHistory history(UUID customerId, String cursor, Integer limit) {
        List<PaymentHistoryItem> all = jdbc.query("""
                select e.ref, e.job_id, e.job_ref, r.title, p.business_name, e.total_amount, e.refunded_amount,
                       e.status, e.provider, e.locked_at, e.created_at
                from escrow_payment e
                left join service_requests r on r.id = e.request_id
                left join pro_profiles p on p.user_id = e.pro_id
                where e.customer_id = ? and e.channel = 'APP'
                  and e.status in ('LOCKED', 'DISPUTED', 'RELEASED_TO_PRO', 'REFUNDED_TO_CUSTOMER', 'SPLIT_SETTLED')
                order by coalesce(e.locked_at, e.created_at) desc, e.ref desc limit 500""", (rs, i) -> {
            EscrowStatus status = EscrowStatus.valueOf(rs.getString("status"));
            EscrowProvider provider = EscrowProvider.valueOf(rs.getString("provider"));
            return new PaymentHistoryItem(rs.getString("ref"), rs.getObject("job_id", UUID.class),
                    rs.getString("job_ref"), rs.getString("title"), rs.getString("business_name"),
                    money(rs.getBigDecimal("total_amount")), money(rs.getBigDecimal("refunded_amount")), status,
                    location(status), providerName(provider), sandbox(provider), instant(rs.getTimestamp("locked_at")),
                    instant(rs.getTimestamp("created_at")));
        }, customerId);
        Paging.Slice<PaymentHistoryItem> page = Paging.slice(all, cursor, limit);
        return new PaymentHistory(page.items(), page.nextCursor());
    }

    /** Admin kasa özeti: tüm APP kanalı ödemeleri üzerinden tek sorgu. */
    @Transactional(readOnly = true)
    public PaymentSummary summary() {
        return jdbc.queryForObject("""
                select
                  coalesce(sum(total_amount) filter (where status in ('LOCKED', 'DISPUTED')), 0) as vault,
                  coalesce(sum(pro_payout) filter (where status in ('RELEASED_TO_PRO', 'SPLIT_SETTLED')), 0) as paid,
                  coalesce(sum(refunded_amount) filter (where status in ('REFUNDED_TO_CUSTOMER', 'SPLIT_SETTLED')), 0)
                      as refunded,
                  coalesce(sum(commission) filter (where status = 'RELEASED_TO_PRO'), 0) as commission,
                  count(*) filter (where status in ('LOCKED', 'DISPUTED', 'RELEASED_TO_PRO', 'REFUNDED_TO_CUSTOMER',
                                                    'SPLIT_SETTLED')) as total,
                  count(*) filter (where status = 'LOCKED') as locked,
                  count(*) filter (where status = 'DISPUTED') as disputed,
                  count(*) filter (where status = 'RELEASED_TO_PRO') as released,
                  count(*) filter (where status = 'REFUNDED_TO_CUSTOMER') as refunded_n,
                  count(*) filter (where status = 'SPLIT_SETTLED') as split_n,
                  count(*) filter (where status = 'FAILED') as failed,
                  count(*) filter (where pending_action is not null and status in ('LOCKED', 'DISPUTED')) as pending,
                  count(*) filter (where error_code in ('REFUND_NEEDS_REVIEW', 'PAYOUT_NEEDS_REVIEW')
                                     and status in ('LOCKED', 'DISPUTED')) as review,
                  count(*) filter (where provider = 'SEED') as seed
                from escrow_payment where channel = 'APP'""", (rs, i) -> {
            int locked = rs.getInt("locked");
            int disputed = rs.getInt("disputed");
            return new PaymentSummary(money(rs.getBigDecimal("vault")), money(rs.getBigDecimal("paid")),
                    money(rs.getBigDecimal("refunded")), money(rs.getBigDecimal("commission")),
                    new Counts(rs.getInt("total"), locked + disputed, locked, disputed, rs.getInt("released"),
                            rs.getInt("refunded_n"), rs.getInt("split_n"), rs.getInt("failed"), rs.getInt("pending"),
                            rs.getInt("review"), rs.getInt("seed")), Instant.now());
        });
    }

    // ─── Zaman çizelgesi üretimi ────────────────────────────────────────────

    private PaymentTimeline timeline(EscrowPayment p, Viewer viewer) {
        JobRow job = p.getJobId() == null ? null : jobRow(p.getJobId());
        List<TimelineEvent> events = events(p, job, viewer);
        boolean customer = viewer == Viewer.CUSTOMER;
        Amounts amounts = new Amounts(money(p.getTotalAmount()), customer ? null : money(p.getCommission()),
                customer ? null : money(p.getProPayout()), money(p.getRefundedAmount()));
        Instant autoRelease = job != null && "WORK_FINISHED".equals(job.status()) && p.getStatus() == EscrowStatus.LOCKED
                ? job.autoCompleteAt() : null;
        return new PaymentTimeline(p.getRef(), p.getJobId(), job != null ? job.publicCode() : p.getJobRef(),
                job != null ? job.title() : null, p.getStatus(), location(p.getStatus()), providerOf(p), sandbox(p),
                p.getCraftgatePaymentId(), viewer == Viewer.PRO ? null : card(p), amounts, autoRelease,
                p.getPendingAction(), p.getErrorCode(), events);
    }

    private List<TimelineEvent> events(EscrowPayment p, JobRow job, Viewer viewer) {
        record Stored(String type, Instant at, BigDecimal amount, String actor, String note) {
        }
        List<Stored> stored = jdbc.query("""
                select type, amount, actor_role, note, created_at from escrow_event
                where payment_ref = ? order by created_at, id""", (rs, i) -> new Stored(rs.getString("type"),
                rs.getTimestamp("created_at").toInstant(), rs.getBigDecimal("amount"), rs.getString("actor_role"),
                rs.getString("note")), p.getRef());
        List<TimelineEvent> out = new ArrayList<>();
        Set<String> have = new java.util.HashSet<>();
        for (Stored s : stored) {
            Instant at = rowTime(p, s.type(), s.at());
            out.add(new TimelineEvent(s.type(), at, s.amount(), s.actor(), s.note()));
            have.add(s.type());
        }
        // Tabloda olmayan türler satırdan türetilir (eski ve seed kayıtlar).
        addDerived(out, have, "PAYMENT_INITIALIZED", p.getCreatedAt(), p.getTotalAmount(), "CUSTOMER", null);
        if (p.getCraftgatePaymentId() != null) {
            addDerived(out, have, "THREEDS_STARTED", p.getCreatedAt(), null, "CUSTOMER", null);
        }
        if (p.getLockedAt() != null) {
            addDerived(out, have, "PAYMENT_LOCKED", p.getLockedAt(), p.getTotalAmount(), "SYSTEM", null);
        }
        if (p.getStatus() == EscrowStatus.FAILED) {
            addDerived(out, have, "FAILED", p.getCreatedAt(), null, "SYSTEM", p.getErrorCode());
        }
        if (p.getStatus() == EscrowStatus.RELEASED_TO_PRO && p.getReleasedAt() != null) {
            addDerived(out, have, "RELEASED_TO_PRO", p.getReleasedAt(), p.getProPayout(), "SYSTEM", null);
        }
        if (p.getStatus() == EscrowStatus.REFUNDED_TO_CUSTOMER && p.getRefundedAt() != null) {
            addDerived(out, have, "REFUNDED", p.getRefundedAt(), p.getRefundedAmount(), "SYSTEM", null);
        }
        if (p.getStatus() == EscrowStatus.SPLIT_SETTLED && p.getRefundedAt() != null) {
            addDerived(out, have, "SPLIT_SETTLED", p.getRefundedAt(), p.getRefundedAmount(), "ADMIN", null);
        }
        if (job != null) {
            addJobEvents(out, have, p, job);
        }
        // Usta, müşterinin aldığı iadenin kendi payı dışındaki tutarlarını bilmek zorunda değil; müşteri usta payını görmez.
        List<TimelineEvent> visible = out.stream()
                .map(e -> viewer == Viewer.CUSTOMER
                        && (e.type().equals("RELEASED_TO_PRO") || e.type().equals("AUTO_RELEASE_SCHEDULED"))
                        ? new TimelineEvent(e.type(), e.at(), null, e.actor(), e.note()) : e)
                .sorted(Comparator.comparing(TimelineEvent::at).thenComparingInt(e -> ORDER.indexOf(e.type())))
                .toList();
        return visible;
    }

    /** Zaman damgası satırda olan türlerde olay saati satırdan alınır (seed anlatısı ve tutarlılık için). */
    private static Instant rowTime(EscrowPayment p, String type, Instant stored) {
        Instant column = switch (type) {
            case "PAYMENT_INITIALIZED", "THREEDS_STARTED" -> p.getCreatedAt();
            case "PAYMENT_LOCKED" -> p.getLockedAt();
            case "RELEASED_TO_PRO" -> p.getReleasedAt();
            case "REFUNDED", "SPLIT_SETTLED" -> p.getRefundedAt();
            default -> null;
        };
        return column != null ? column : stored;
    }

    private static void addDerived(List<TimelineEvent> out, Set<String> have, String type, Instant at,
                                   BigDecimal amount, String actor, String note) {
        if (!have.contains(type)) {
            out.add(new TimelineEvent(type, at, amount, actor, note));
            have.add(type);
        }
    }

    private void addJobEvents(List<TimelineEvent> out, Set<String> have, EscrowPayment p, JobRow job) {
        record JobEv(String to, String actor, Instant at) {
        }
        List<JobEv> evs = jdbc.query("""
                select to_status, actor_role, created_at from job_events
                where job_id = ? and type = 'STATUS_CHANGED' order by created_at, seq""",
                (rs, i) -> new JobEv(rs.getString("to_status"), rs.getString("actor_role"),
                        rs.getTimestamp("created_at").toInstant()), job.id());
        JobEv delivered = evs.stream().filter(e -> "WORK_FINISHED".equals(e.to())).findFirst().orElse(null);
        if (delivered != null) {
            out.add(new TimelineEvent("WORK_DELIVERED", delivered.at(), null, ActorRole.PRO.name(), null));
            // Tamamlanınca iş kaydındaki zaman silinir: o zaman teslim anı + 48 saat olarak yeniden hesaplanır.
            Instant due = job.autoCompleteAt() != null ? job.autoCompleteAt()
                    : delivered.at().plus(com.bitadilat.job.JobStateMachine.AUTO_COMPLETE_AFTER);
            out.add(new TimelineEvent("AUTO_RELEASE_SCHEDULED", delivered.at(), p.getProPayout(),
                    ActorRole.SYSTEM.name(), "autoReleaseAt=" + due));
        }
        evs.stream().filter(e -> "COMPLETED".equals(e.to())).findFirst().ifPresent(e -> out.add(new TimelineEvent(
                "SYSTEM".equals(e.actor()) ? "AUTO_APPROVED" : "CUSTOMER_APPROVED", e.at(), null, e.actor(), null)));
        // Şikayet açılış saati şikayet kaydındandır (seed anlatısında olay satırı farklı bir saatte yazılmış olabilir).
        Instant complaintAt = jdbc.query("select min(created_at) from complaints where job_id = ?",
                rs -> rs.next() && rs.getTimestamp(1) != null ? rs.getTimestamp(1).toInstant() : null, job.id());
        if (complaintAt != null) {
            out.removeIf(e -> e.type().equals("DISPUTE_OPENED"));
            out.add(new TimelineEvent("DISPUTE_OPENED", complaintAt, null, ActorRole.CUSTOMER.name(), null));
        }
    }

    // ─── Yardımcılar ────────────────────────────────────────────────────────

    private record JobRow(UUID id, UUID customerId, UUID proId, String status, Instant autoCompleteAt,
                          String publicCode, String title) {
    }

    private JobRow jobRow(UUID jobId) {
        List<JobRow> rows = jdbc.query("""
                select j.id, j.customer_id, j.pro_id, j.status, j.auto_complete_at, r.public_code, r.title
                from jobs j join service_requests r on r.id = j.request_id where j.id = ?""",
                (rs, i) -> new JobRow(rs.getObject("id", UUID.class), rs.getObject("customer_id", UUID.class),
                        rs.getObject("pro_id", UUID.class), rs.getString("status"),
                        instant(rs.getTimestamp("auto_complete_at")), rs.getString("public_code"),
                        rs.getString("title")), jobId);
        if (rows.isEmpty()) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        return rows.get(0);
    }

    private static Viewer viewerOf(JobRow job, UUID userId, boolean admin) {
        if (admin) {
            return Viewer.ADMIN;
        }
        if (job.customerId().equals(userId)) {
            return Viewer.CUSTOMER;
        }
        if (job.proId().equals(userId)) {
            return Viewer.PRO;
        }
        throw ApiException.notFound("İş bulunamadı.");
    }

    private EscrowPayment escrowOf(UUID jobId) {
        return escrows.findByJobId(jobId)
                .orElseThrow(() -> ApiException.notFound("Bu işin ödeme kaydı bulunamadı."));
    }

    public static MoneyLocation locationOf(EscrowStatus status) {
        return location(status);
    }

    static MoneyLocation location(EscrowStatus status) {
        return switch (status) {
            case INITIALIZED, FAILED -> MoneyLocation.CUSTOMER_CARD;
            case LOCKED, DISPUTED -> MoneyLocation.BITADILAT_VAULT;
            case RELEASED_TO_PRO -> MoneyLocation.PRO;
            case REFUNDED_TO_CUSTOMER -> MoneyLocation.CUSTOMER_REFUNDED;
            case SPLIT_SETTLED -> MoneyLocation.SPLIT;
        };
    }

    private String providerOf(EscrowPayment p) {
        if (p.getProvider() == EscrowProvider.SEED) {
            return "SEED";
        }
        return gateway.isDemo() ? "DEMO" : "CRAFTGATE";
    }

    private static String providerName(EscrowProvider provider) {
        return provider.name();
    }

    private boolean sandbox(EscrowPayment p) {
        return sandbox(p.getProvider());
    }

    private boolean sandbox(EscrowProvider provider) {
        return provider == EscrowProvider.SEED || gateway.isDemo() || sandboxGateway;
    }

    private static CardInfo card(EscrowPayment p) {
        if (p.getCardLast4() == null) {
            return null;
        }
        return new CardInfo(p.getCardBrand(), p.getCardLast4(), "**** **** **** " + p.getCardLast4());
    }

    private String proName(UUID proId) {
        return proId == null ? null : jdbc.query("select business_name from pro_profiles where user_id = ?",
                rs -> rs.next() ? rs.getString(1) : null, proId);
    }

    private String customerName(UUID customerId) {
        return customerId == null ? null : jdbc.query("select full_name from users where id = ?",
                rs -> rs.next() ? rs.getString(1) : null, customerId);
    }

    private static BigDecimal money(BigDecimal v) {
        return (v == null ? BigDecimal.ZERO : v).setScale(2, RoundingMode.HALF_UP);
    }

    private static Instant instant(Timestamp t) {
        return t == null ? null : t.toInstant();
    }
}
