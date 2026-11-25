package com.bitadilat.payment.dto;

import com.bitadilat.payment.domain.EscrowPendingAction;
import com.bitadilat.payment.domain.EscrowStatus;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Ödeme zaman çizelgesi, makbuz, geçmiş ve admin özeti DTO'ları (sözleşme: docs/spec/API_V1.md, "Payment demo"). */
public final class PaymentDemoDtos {

    private PaymentDemoDtos() {
    }

    /** Paranın şu an bulunduğu yer. */
    public enum MoneyLocation {
        CUSTOMER_CARD, BITADILAT_VAULT, PRO, CUSTOMER_REFUNDED, SPLIT
    }

    /** Kart bilgisi yalnızca maskeli: marka (bilinmiyorsa null) ve son 4 hane. */
    public record CardInfo(String brand, String last4, String masked) {
    }

    /** Role göre doldurulur: müşteri {@code commission} ve {@code proNet} görmez (null); usta ve admin görür. */
    public record Amounts(BigDecimal gross, BigDecimal commission, BigDecimal proNet, BigDecimal refunded) {
    }

    public record TimelineEvent(String type, Instant at, BigDecimal amount, String actor, String note) {
    }

    public record PaymentTimeline(String paymentRef, UUID jobId, String jobPublicCode, String jobTitle,
                                  EscrowStatus status, MoneyLocation moneyLocation, String provider, boolean sandbox,
                                  Long craftgatePaymentId, CardInfo card, Amounts amounts, Instant autoReleaseAt,
                                  EscrowPendingAction pendingAction, String errorCode, List<TimelineEvent> events) {
    }

    public record ReceiptItem(String kind, String label, BigDecimal quantity, BigDecimal unitPrice,
                              BigDecimal amount) {
    }

    public record PaymentReceipt(String receiptNo, Instant issuedAt, String paymentRef, UUID jobId,
                                 String jobPublicCode, String jobTitle, String proName, String customerName,
                                 List<ReceiptItem> items, BigDecimal total, BigDecimal refundedTotal,
                                 BigDecimal netPaid, String currency, CardInfo card, EscrowStatus status,
                                 MoneyLocation moneyLocation, String provider, boolean sandbox,
                                 String sandboxNotice) {
    }

    public record PaymentHistoryItem(String ref, UUID jobId, String jobPublicCode, String jobTitle, String proName,
                                     BigDecimal totalAmount, BigDecimal refundedAmount, EscrowStatus status,
                                     MoneyLocation moneyLocation, String provider, boolean sandbox, Instant paidAt,
                                     Instant createdAt) {
    }

    public record PaymentHistory(List<PaymentHistoryItem> items, String nextCursor) {
    }

    public record PaymentSummary(BigDecimal vaultTotal, BigDecimal paidToProsTotal,
                                 BigDecimal refundedToCustomersTotal, BigDecimal commissionEarnedTotal,
                                 Counts counts, Instant generatedAt) {
    }

    public record Counts(int total, int vault, int locked, int disputed, int released, int refunded, int split,
                         int failed, int pendingAction, int needsReview, int seed) {
    }

    /** {@code POST /dev/jobs/{jobId}/payment/fast-forward} yanıtı. */
    public record FastForwardResult(UUID jobId, String jobStatus, EscrowStatus escrowStatus,
                                    MoneyLocation moneyLocation, boolean released, EscrowPendingAction pendingAction,
                                    String errorCode) {
    }
}
