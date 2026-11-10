package com.bitadilat.job.dto;

import com.bitadilat.job.ActorRole;
import com.bitadilat.job.JobStateMachine.Action;
import com.bitadilat.job.JobStatus;
import com.bitadilat.offer.dto.OfferDetail;
import com.bitadilat.payment.domain.EscrowStatus;
import com.bitadilat.pro.dto.ReviewList;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/**
 * JobSummary alanları + ayrıntı. {@code offer.serviceFee/netEarning} ve {@code payment.serviceFee/netEarning}
 * yalnızca ustaya dolu. Tam adres iş açıldığı için iki katılımcıya da görünür. {@code allowedActions} görüntüleyen
 * için durum makinesinden hesaplanır; istemci düğmeleri yalnızca bu listeden gösterir.
 */
public record JobDetail(
        UUID id, String publicCode, UUID requestId, String title, String categoryId, JobStatus status,
        ActorRole viewerRole, JobSummary.Counterpart counterpart, BigDecimal totalAmount, Instant scheduledFrom,
        Instant scheduledTo, Instant updatedAt, int unreadMessages,
        OfferDetail offer, Address address, Appointment appointment, List<JobEventView> timeline, Payment payment,
        Instant autoCompleteAt, ReviewList.Item review, ComplaintRef complaint, Set<Action> allowedActions) {

    public record Address(String districtName, String neighborhood, String lineFull, String doorNote) {
    }

    public record Appointment(Instant scheduledFrom, Instant scheduledTo, PendingProposal pendingProposal) {
    }

    public record PendingProposal(UUID id, ActorRole proposedBy, Instant slotFrom, Instant slotTo, Instant createdAt) {
    }

    public record Payment(String ref, EscrowStatus status, BigDecimal totalAmount, BigDecimal refundedAmount,
                          BigDecimal serviceFee, BigDecimal netEarning) {
    }

    public record ComplaintRef(UUID id, String publicCode, String status) {
    }
}
