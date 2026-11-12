package com.bitadilat.admin;

import com.bitadilat.job.ComplaintReason;
import com.bitadilat.job.JobStatus;
import com.bitadilat.job.dto.ComplaintView;
import com.bitadilat.job.dto.JobEventView;
import com.bitadilat.media.dto.MediaRef;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.pro.Availability;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.pro.dto.ApplicationView;
import com.bitadilat.user.UserMode;
import com.bitadilat.user.UserStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Yönetici paneli DTO sözleşmeleri (API_V1.md §Admin ve STATE_MACHINES.md §1, §5, §6). */
public final class AdminDtos {

    private AdminDtos() {
    }

    // ─── Usta başvuruları ───────────────────────────────────────────────────

    public record ProApplicationItem(
            UUID proId,
            String fullName,
            String email,
            String phone,
            String businessName,
            String bio,
            int experienceYears,
            ReviewStatus reviewStatus,
            String reviewNote,
            List<String> categoryIds,
            List<Integer> districtIds,
            List<ApplicationView.Doc> documents,
            Instant submittedAt,
            Instant approvedAt) {
    }

    public record ProApplicationList(
            List<ProApplicationItem> items,
            String nextCursor) {
    }

    public record RejectBody(
            @NotBlank @Size(min = 5, max = 500) String reason) {
    }

    public record RequestDocumentsBody(
            @NotBlank @Size(min = 5, max = 500) String note) {
    }

    // ─── Şikayetler ve hakem kararları ──────────────────────────────────────

    public record AdminComplaintSummary(
            UUID id,
            String publicCode,
            UUID jobId,
            String requestPublicCode,
            UUID customerId,
            String customerName,
            UUID proId,
            String proBusinessName,
            ComplaintReason reason,
            String description,
            String status,
            String decision,
            String decisionNote,
            boolean warnPro,
            boolean suspendPro,
            Instant createdAt,
            Instant decidedAt) {
    }

    public record AdminComplaintList(
            List<AdminComplaintSummary> items,
            String nextCursor) {
    }

    public record PartyCustomer(
            UUID id,
            String fullName,
            String email,
            String phone) {
    }

    public record PartyPro(
            UUID id,
            String fullName,
            String businessName,
            String email,
            String phone,
            ReviewStatus reviewStatus,
            int warningCount,
            int cancellationCount) {
    }

    public record DisputedJobSummary(
            UUID id,
            String publicCode,
            String title,
            String categoryId,
            JobStatus status,
            JobStatus statusBeforeDispute,
            Instant scheduledFrom,
            Instant scheduledTo,
            Instant arrivedAt,
            Instant startedAt,
            Instant finishedAt,
            BigDecimal totalAmount) {
    }

    public record DisputedEscrowSummary(
            String ref,
            EscrowStatus status,
            BigDecimal totalAmount,
            BigDecimal refundedAmount,
            BigDecimal commission,
            BigDecimal proPayout) {
    }

    public record AdminChatMessage(
            long id,
            String senderRole,
            UUID senderId,
            String body,
            MediaRef photo,
            Instant createdAt) {
    }

    public record AdminComplaintDetail(
            ComplaintView complaint,
            PartyCustomer customer,
            PartyPro pro,
            DisputedJobSummary job,
            DisputedEscrowSummary payment,
            List<JobEventView> timeline,
            List<AdminChatMessage> messages,
             boolean warnPro,
            boolean suspendPro) {
    }

    public record ComplaintDecisionBody(
            @NotBlank @Pattern(regexp = "FULL_REFUND|SPLIT_50_50|RELEASE_TO_PRO") String decision,
            @NotBlank @Size(min = 10, max = 1000) String decisionNote,
            Boolean warnPro,
            Boolean suspendPro) {
    }

    // ─── Kullanıcı ve usta hesap yönetimi ───────────────────────────────────

    public record AdminUserItem(
            UUID id,
            String fullName,
            String email,
            String phone,
            UserStatus status,
            UserMode lastMode,
            boolean isAdmin,
            String businessName,
            ReviewStatus proReviewStatus,
            Availability proAvailability,
            int warningCount,
            int cancellationCount,
            Instant createdAt) {
    }

    public record AdminUserList(
            List<AdminUserItem> items,
            String nextCursor) {
    }

    public record SuspendUserBody(
            @NotBlank @Size(min = 5, max = 500) String reason) {
    }

    public record ReactivateUserBody(
            @Size(max = 500) String note) {
    }

    // ─── Emanet (escrow) ve defter (payout_ledger) ──────────────────────────

    public record LedgerEntryView(
            UUID id,
            String kind,
            BigDecimal amount,
            Instant createdAt) {
    }

    public record AdminPaymentItem(
            String ref,
            String jobRef,
            UUID requestId,
            UUID jobId,
            UUID customerId,
            String customerName,
            UUID proId,
            String proBusinessName,
            EscrowStatus status,
            String channel,
            String provider,
            BigDecimal totalAmount,
            BigDecimal commission,
            BigDecimal proPayout,
            BigDecimal refundedAmount,
            String errorCode,
            boolean resultUncertain,
            Instant createdAt,
            Instant lockedAt,
            Instant releasedAt,
            Instant refundedAt,
            List<LedgerEntryView> ledgerEntries) {
    }

    public record AdminPaymentList(
            List<AdminPaymentItem> items,
            String nextCursor) {
    }

    // ─── Denetim kayıtları (admin_actions) ──────────────────────────────────

    public record AdminActionItem(
            UUID id,
            UUID adminId,
            String adminEmail,
            String action,
            String targetType,
            String targetId,
            String note,
            Instant createdAt) {
    }

    public record AdminActionList(
            List<AdminActionItem> items,
            String nextCursor) {
    }
}
