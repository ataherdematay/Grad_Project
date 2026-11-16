package com.bitadilat.admin;

import com.bitadilat.job.ComplaintReason;
import com.bitadilat.job.JobStatus;
import com.bitadilat.job.dto.JobEventView;
import com.bitadilat.media.dto.MediaRef;
import com.bitadilat.offer.dto.OfferDetail;
import com.bitadilat.payment.domain.EscrowPendingAction;
import com.bitadilat.payment.domain.EscrowProvider;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.pro.DocumentStatus;
import com.bitadilat.pro.DocumentType;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.user.UserStatus;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Wave 4 admin sözleşmesinin gövde ve yanıt tipleri (docs/spec/API_V1.md "Ayrıntılı sözleşme (wave 4)"). */
public final class AdminDtos {

    private AdminDtos() {
    }

    // ─── İstek gövdeleri ────────────────────────────────────────────────────

    public record NoteBody(String note) {
    }

    public record RequestDocumentsBody(String note, List<DocumentType> documentTypes) {
    }

    /** {@code warnPro} ve {@code suspendPro} verilmezse false sayılır. */
    public record DecisionBody(String decision, String note, Boolean warnPro, Boolean suspendPro) {
    }

    // ─── Özet ───────────────────────────────────────────────────────────────

    public record Stats(int pendingApplications, int openComplaints, int activeJobs, BigDecimal lockedEscrowTotal) {
    }

    // ─── Usta başvuruları ───────────────────────────────────────────────────

    public record ApplicationSummary(UUID proId, String fullName, String businessName, List<String> categoryIds,
                                     List<String> districtNames, Instant submittedAt, ReviewStatus reviewStatus,
                                     int documentCount) {
    }

    public record ApplicationList(List<ApplicationSummary> items) {
    }

    public record DocumentView(UUID id, DocumentType type, DocumentStatus status, MediaRef media) {
    }

    public record ActionView(UUID id, String action, String note, String adminName, Instant createdAt) {
    }

    public record ApplicationDetail(UUID proId, String fullName, String businessName, List<String> categoryIds,
                                    List<String> districtNames, Instant submittedAt, ReviewStatus reviewStatus,
                                    int documentCount, String email, String phone, String bio, int experienceYears,
                                    String reviewNote, List<DocumentView> documents, List<ActionView> history) {
    }

    // ─── Şikayetler ─────────────────────────────────────────────────────────

    public record ComplaintItem(UUID id, String publicCode, UUID jobId, String jobPublicCode, ComplaintReason reason,
                                String status, String customerName, String proBusinessName, BigDecimal amount,
                                Instant createdAt) {
    }

    public record ComplaintList(List<ComplaintItem> items) {
    }

    public record JobInfo(UUID id, String publicCode, String title, JobStatus status, JobStatus statusBeforeDispute,
                          List<JobEventView> timeline, OfferDetail offer, String districtName) {
    }

    public record PaymentInfo(String ref, EscrowStatus status, EscrowProvider provider, BigDecimal totalAmount,
                              BigDecimal commission, BigDecimal proPayout, BigDecimal refundedAmount) {
    }

    public record ChatMessage(long id, String senderRole, String body, MediaRef photo, Instant createdAt) {
    }

    public record Party(UUID id, String fullName) {
    }

    public record ProParty(UUID id, String businessName, String fullName, int warningCount, int cancellationCount) {
    }

    /** Wave 3 {@code Complaint} alanları + karar bayrakları + iş, ödeme, sohbet ve taraflar. */
    public record ComplaintDetail(UUID id, String publicCode, UUID jobId, ComplaintReason reason, String description,
                                  List<MediaRef> evidence, String status, String decision, String decisionNote,
                                  Instant createdAt, Instant decidedAt, BigDecimal refundAmount, BigDecimal proAmount,
                                  boolean warnPro, boolean suspendPro,
                                  JobInfo job, PaymentInfo payment, List<ChatMessage> messages, Party customer,
                                  ProParty pro) {
    }

    // ─── Hesaplar ───────────────────────────────────────────────────────────

    public record ProBrief(String businessName, ReviewStatus reviewStatus) {
    }

    /** {@code activeJobCount} yalnızca askıya alma yanıtında dolu: açık işler olduğu gibi bırakılır. */
    public record UserItem(UUID id, String fullName, String email, String phone,
                           @JsonProperty("isAdmin") boolean isAdmin, UserStatus status, Instant createdAt,
                           ProBrief pro, @JsonInclude(JsonInclude.Include.NON_NULL) Integer activeJobCount) {
    }

    public record UserList(List<UserItem> items) {
    }

    // ─── Ödeme defteri ──────────────────────────────────────────────────────

    public record PaymentItem(String ref, String jobPublicCode, EscrowStatus status, EscrowProvider provider,
                              BigDecimal totalAmount, BigDecimal commission, BigDecimal proPayout,
                              BigDecimal refundedAmount, String customerName, String proBusinessName,
                              Instant createdAt, Instant lockedAt, Instant releasedAt, Instant refundedAt,
                              String errorCode) {
    }

    public record PaymentTotals(BigDecimal lockedTotal, BigDecimal releasedTotal, BigDecimal commissionTotal,
                                BigDecimal refundedTotal) {
    }

    public record PaymentLedger(List<PaymentItem> items, PaymentTotals totals) {
    }

    // ─── İncelemedeki ödemeler (follow-up) ──────────────────────────────────

    public record ReviewItem(String ref, UUID jobId, String jobPublicCode, JobStatus jobStatus, EscrowStatus status,
                             String errorCode, EscrowPendingAction pendingAction, BigDecimal totalAmount,
                             BigDecimal refundedAmount, String customerName, String proBusinessName, int attempts,
                             Instant lastAttemptAt, Instant createdAt) {
    }

    public record ReviewList(List<ReviewItem> items) {
    }

    /**
     * {@code gatewayRefundState}: Craftgate'in yanıtı ({@code NOT_REFUNDED}, {@code PARTIALLY_REFUNDED},
     * {@code REFUND_PENDING}, {@code FULLY_REFUNDED}); {@code allowedResolutions} bu yanıttan hesaplanır.
     */
    public record ReviewCheck(ReviewItem payment, String gatewayRefundState, BigDecimal gatewayRefundedTotal,
                              List<String> allowedResolutions) {
    }

    public record ReviewResolveBody(String resolution, String note) {
    }
}
