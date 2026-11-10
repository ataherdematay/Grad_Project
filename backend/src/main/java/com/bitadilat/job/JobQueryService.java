package com.bitadilat.job;

import com.bitadilat.common.ApiException;
import com.bitadilat.common.Paging;
import com.bitadilat.job.JobStateMachine.Action;
import com.bitadilat.job.dto.JobDetail;
import com.bitadilat.job.dto.JobList;
import com.bitadilat.job.dto.JobSummary;
import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.offer.OfferService;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.pro.ProProfile;
import com.bitadilat.pro.ProProfileRepository;
import com.bitadilat.pro.ProPublicService;
import com.bitadilat.pro.dto.ReviewList;
import com.bitadilat.request.RequestService;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import com.bitadilat.user.AddressService;
import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * İş okuma görünümleri (liste ve ayrıntı). Katılımcı olmayan 404 alır. Alan görünürlüğü rol bazlıdır: hizmet bedeli ve
 * net kazanç yalnızca ustaya, kart bilgisi hiç gösterilmez, tam adres iki katılımcıya da açıktır.
 */
@Service
public class JobQueryService {

    private final JobRepository jobs;
    private final ServiceRequestRepository requests;
    private final OfferRepository offerRepository;
    private final OfferService offerService;
    private final RequestService requestService;
    private final UserRepository users;
    private final ProProfileRepository profiles;
    private final AddressService addresses;
    private final EscrowPaymentRepository escrows;
    private final AppointmentProposalRepository proposals;
    private final JobEvents events;
    private final JdbcTemplate jdbc;

    public JobQueryService(JobRepository jobs, ServiceRequestRepository requests, OfferRepository offerRepository,
                           OfferService offerService, RequestService requestService, UserRepository users,
                           ProProfileRepository profiles, AddressService addresses, EscrowPaymentRepository escrows,
                           AppointmentProposalRepository proposals, JobEvents events, JdbcTemplate jdbc) {
        this.jobs = jobs;
        this.requests = requests;
        this.offerRepository = offerRepository;
        this.offerService = offerService;
        this.requestService = requestService;
        this.users = users;
        this.profiles = profiles;
        this.addresses = addresses;
        this.escrows = escrows;
        this.proposals = proposals;
        this.events = events;
        this.jdbc = jdbc;
    }

    /** İşteki rol; katılımcı değilse null. */
    public static ActorRole roleOf(Job job, UUID userId) {
        if (job.getCustomerId().equals(userId)) {
            return ActorRole.CUSTOMER;
        }
        return job.getProId().equals(userId) ? ActorRole.PRO : null;
    }

    @Transactional(readOnly = true)
    public JobList list(UUID userId, String as, String scope, String cursor, Integer limit) {
        ActorRole role;
        if ("CUSTOMER".equals(as)) {
            role = ActorRole.CUSTOMER;
        } else if ("PRO".equals(as)) {
            role = ActorRole.PRO;
        } else {
            throw ApiException.validation("as", "as CUSTOMER veya PRO olmalı.");
        }
        boolean active;
        if ("active".equals(scope)) {
            active = true;
        } else if ("past".equals(scope)) {
            active = false;
        } else {
            throw ApiException.validation("scope", "scope active veya past olmalı.");
        }
        List<Job> mine = role == ActorRole.CUSTOMER
                ? jobs.findByCustomerIdOrderByUpdatedAtDescIdDesc(userId)
                : jobs.findByProIdOrderByUpdatedAtDescIdDesc(userId);
        List<Job> filtered = mine.stream().filter(j -> j.getStatus().isActive() == active).toList();
        if (limit == null && (cursor == null || cursor.isBlank())) {
            return new JobList(filtered.stream().map(j -> summary(j, role, userId)).toList(), null);
        }
        Paging.Slice<Job> page = Paging.slice(filtered, cursor, limit);
        return new JobList(page.items().stream().map(j -> summary(j, role, userId)).toList(), page.nextCursor());
    }

    @Transactional(readOnly = true)
    public JobDetail get(UUID userId, UUID jobId) {
        Job job = jobs.findById(jobId).orElseThrow(() -> ApiException.notFound("İş bulunamadı."));
        ActorRole role = roleOf(job, userId);
        if (role == null) {
            throw ApiException.notFound("İş bulunamadı.");
        }
        return detail(job, role, userId);
    }

    // ─── Görünüm üretimi ────────────────────────────────────────────────────

    public JobSummary summary(Job job, ActorRole role, UUID viewerId) {
        ServiceRequest r = requests.findById(job.getRequestId()).orElseThrow();
        Offer offer = offerRepository.findById(job.getOfferId()).orElseThrow();
        return new JobSummary(job.getId(), r.getPublicCode(), r.getId(), r.getTitle(), r.getCategoryId(),
                job.getStatus(), role, counterpart(job, role), offer.getTotalAmount(), job.getScheduledFrom(),
                job.getScheduledTo(), job.getUpdatedAt(), unread(job.getId(), viewerId));
    }

    public JobSummary.Counterpart counterpart(Job job, ActorRole role) {
        if (role == ActorRole.CUSTOMER) {
            String name = profiles.findById(job.getProId()).map(ProProfile::getBusinessName).orElse("");
            return new JobSummary.Counterpart(job.getProId(), name);
        }
        String name = users.findById(job.getCustomerId()).map(User::getFullName).map(JobQueryService::shortName)
                .orElse("");
        return new JobSummary.Counterpart(job.getCustomerId(), name);
    }

    public int unread(UUID jobId, UUID viewerId) {
        Integer n = jdbc.queryForObject("""
                select count(*) from messages m
                where m.job_id = ? and m.sender_id <> ?
                  and m.id > coalesce((select last_read_id from message_reads where job_id = ? and user_id = ?), 0)""",
                Integer.class, jobId, viewerId, jobId, viewerId);
        return n == null ? 0 : n;
    }

    /** İşlemin içinde (komuttan sonra) da çağrılır; güncel satırlardan üretir. */
    public JobDetail detail(Job job, ActorRole role, UUID viewerId) {
        Instant now = Instant.now();
        boolean pro = role == ActorRole.PRO;
        JobSummary s = summary(job, role, viewerId);
        ServiceRequest r = requests.findById(job.getRequestId()).orElseThrow();

        JobDetail.Address address = address(r);
        Optional<AppointmentProposal> pending = proposals.findByJobIdAndStatus(job.getId(), ProposalStatus.PENDING);
        JobDetail.PendingProposal pendingView = pending
                .map(p -> new JobDetail.PendingProposal(p.getId(), p.getProposedBy(), p.getSlotFrom(),
                        p.getSlotTo(), p.getCreatedAt()))
                .orElse(null);
        ReviewList.Item review = review(job.getId());
        Set<Action> actions = JobStateMachine.allowedActions(new JobStateMachine.Context(job.getStatus(), role,
                pending.map(p -> p.getProposedBy() != role).orElse(false), review != null, job.chatOpen(now)));

        return new JobDetail(job.getId(), s.publicCode(), s.requestId(), s.title(), s.categoryId(), s.status(),
                role, s.counterpart(), s.totalAmount(), s.scheduledFrom(), s.scheduledTo(), s.updatedAt(),
                s.unreadMessages(), offerService.forJob(job.getOfferId(), pro), address,
                new JobDetail.Appointment(job.getScheduledFrom(), job.getScheduledTo(), pendingView),
                events.timeline(job.getId()), payment(job, pro), job.getAutoCompleteAt(), review,
                complaintRef(job.getId()), actions);
    }

    private JobDetail.Address address(ServiceRequest r) {
        String districtName = requestService.districtName(r.getDistrictId());
        if (r.getAddressId() != null) {
            var view = addresses.findView(r.getCustomerId(), r.getAddressId());
            if (view.isPresent()) {
                return new JobDetail.Address(districtName, r.getNeighborhood(), view.get().lineFull(),
                        view.get().doorNote());
            }
        }
        // Müşteri adresi sonradan sildiyse yalnızca ilçe ve mahalle kalır.
        return new JobDetail.Address(districtName, r.getNeighborhood(), null, null);
    }

    private JobDetail.Payment payment(Job job, boolean pro) {
        return escrows.findByJobId(job.getId()).map(p -> toPayment(p, pro)).orElse(null);
    }

    private static JobDetail.Payment toPayment(EscrowPayment p, boolean pro) {
        return new JobDetail.Payment(p.getRef(), p.getStatus(), p.getTotalAmount(), p.getRefundedAmount(),
                pro ? p.getCommission() : null, pro ? p.getProPayout() : null);
    }

    ReviewList.Item review(UUID jobId) {
        List<ReviewList.Item> found = jdbc.query("""
                select r.id, r.rating, r.tags, r.comment, r.is_anonymous, u.full_name, r.created_at
                from reviews r join users u on u.id = r.customer_id where r.job_id = ?""", (rs, i) -> {
            java.sql.Array arr = rs.getArray("tags");
            List<String> tags = arr == null ? List.of() : List.of((String[]) arr.getArray());
            return new ReviewList.Item(rs.getObject("id", UUID.class), rs.getInt("rating"), tags,
                    rs.getString("comment"),
                    rs.getBoolean("is_anonymous") ? "Anonim" : ProPublicService.initials(rs.getString("full_name")),
                    rs.getTimestamp("created_at").toInstant());
        }, jobId);
        return found.isEmpty() ? null : found.get(0);
    }

    private JobDetail.ComplaintRef complaintRef(UUID jobId) {
        List<JobDetail.ComplaintRef> found = jdbc.query("""
                select id, public_code, status from complaints where job_id = ? order by created_at desc limit 1""",
                (rs, i) -> new JobDetail.ComplaintRef(rs.getObject("id", UUID.class), rs.getString("public_code"),
                        rs.getString("status")), jobId);
        return found.isEmpty() ? null : found.get(0);
    }

    /** "Ali Yılmaz" → "Ali Y."; tek isim → "Ali". */
    public static String shortName(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "";
        }
        String[] parts = fullName.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0];
        }
        String last = parts[parts.length - 1];
        return String.join(" ", java.util.Arrays.copyOf(parts, parts.length - 1)) + " "
                + last.substring(0, 1).toUpperCase(Locale.forLanguageTag("tr-TR")) + ".";
    }
}
