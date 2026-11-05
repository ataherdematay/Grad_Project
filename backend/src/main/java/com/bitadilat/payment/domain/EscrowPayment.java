package com.bitadilat.payment.domain;

import com.bitadilat.payment.exception.IllegalEscrowTransitionException;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Version;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Güvence havuzu defter kaydı. Tek durum kaynağıdır: durum yalnızca buradaki metotlarla değişir,
 * izin verilmeyen geçişler hata fırlatır. Kart numarası ve CVC bu sınıfa hiç girmez.
 */
@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class EscrowPayment {

    static final BigDecimal COMMISSION_RATE = new BigDecimal("0.10");

    @Id
    private String ref;

    @Column(nullable = false)
    private String offerId;

    @Column(nullable = false)
    private String jobRef;

    @Column(nullable = false, unique = true)
    private String attemptKey;

    @Column(nullable = false, unique = true)
    private String conversationId;

    @Column(unique = true)
    private Long craftgatePaymentId;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal commission;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal proPayout;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal refundedAmount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EscrowStatus status;

    private String cardLast4;

    private String errorMessage;

    @Column(nullable = false)
    private boolean resultUncertain;

    @Column(nullable = false)
    private Instant createdAt;

    private Instant lockedAt;
    private Instant releasedAt;
    private Instant refundedAt;

    @Version
    private long version;

    public static EscrowPayment start(Offer offer, String attemptKey, String cardLast4) {
        EscrowPayment p = new EscrowPayment();
        p.ref = UUID.randomUUID().toString();
        p.conversationId = UUID.randomUUID().toString();
        p.offerId = offer.id();
        p.jobRef = offer.jobRef();
        p.attemptKey = attemptKey;
        p.cardLast4 = cardLast4;
        p.totalAmount = money(offer.totalAmount());
        p.commission = money(offer.totalAmount().multiply(COMMISSION_RATE));
        p.proPayout = p.totalAmount.subtract(p.commission);
        p.refundedAmount = money(BigDecimal.ZERO);
        p.status = EscrowStatus.INITIALIZED;
        p.createdAt = Instant.now();
        return p;
    }

    public void attachCraftgatePayment(Long paymentId) {
        this.craftgatePaymentId = paymentId;
    }

    public void lock() {
        require(Set.of(EscrowStatus.INITIALIZED));
        status = EscrowStatus.LOCKED;
        errorMessage = null;
        lockedAt = Instant.now();
    }

    public void fail(String message) {
        require(Set.of(EscrowStatus.INITIALIZED));
        status = EscrowStatus.FAILED;
        errorMessage = message;
    }

    /** Craftgate yanıtı kayıtla uyuşmadı: para çekilmiş olabilir, kullanıcıya "ücret alınmadı" denmez. */
    public void failUnverified(String message) {
        fail(message);
        resultUncertain = true;
    }

    public void dispute() {
        require(Set.of(EscrowStatus.LOCKED));
        status = EscrowStatus.DISPUTED;
    }

    public void release() {
        require(Set.of(EscrowStatus.LOCKED, EscrowStatus.DISPUTED));
        status = EscrowStatus.RELEASED_TO_PRO;
        releasedAt = Instant.now();
    }

    public void refundFully() {
        requireRefundable();
        status = EscrowStatus.REFUNDED_TO_CUSTOMER;
        refundedAmount = totalAmount;
        commission = money(BigDecimal.ZERO);
        proPayout = money(BigDecimal.ZERO);
        refundedAt = Instant.now();
    }

    /** Adım 46'daki karar metnine uyar: yarısı müşteriye, yarısı ustaya; bu yolda komisyon alınmaz. */
    public void settleSplit() {
        requireSplittable();
        BigDecimal half = splitRefundAmount();
        status = EscrowStatus.SPLIT_SETTLED;
        refundedAmount = half;
        proPayout = totalAmount.subtract(half);
        commission = money(BigDecimal.ZERO);
        refundedAt = Instant.now();
    }

    public BigDecimal splitRefundAmount() {
        return totalAmount.divide(BigDecimal.valueOf(2), 2, RoundingMode.HALF_UP);
    }

    /** Craftgate'e gitmeden önce çağrılır; böylece geçersiz bir istek para hareketine yol açmaz. */
    public void requireRefundable() {
        require(Set.of(EscrowStatus.LOCKED, EscrowStatus.DISPUTED));
    }

    public void requireSplittable() {
        require(Set.of(EscrowStatus.DISPUTED));
    }

    private void require(Set<EscrowStatus> allowed) {
        if (!allowed.contains(status)) {
            throw new IllegalEscrowTransitionException(status);
        }
    }

    private static BigDecimal money(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }
}
