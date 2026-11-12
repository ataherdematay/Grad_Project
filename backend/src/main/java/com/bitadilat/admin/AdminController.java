package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.AdminActionList;
import com.bitadilat.admin.AdminDtos.AdminComplaintDetail;
import com.bitadilat.admin.AdminDtos.AdminComplaintList;
import com.bitadilat.admin.AdminDtos.AdminPaymentList;
import com.bitadilat.admin.AdminDtos.AdminUserItem;
import com.bitadilat.admin.AdminDtos.AdminUserList;
import com.bitadilat.admin.AdminDtos.ComplaintDecisionBody;
import com.bitadilat.admin.AdminDtos.ProApplicationItem;
import com.bitadilat.admin.AdminDtos.ProApplicationList;
import com.bitadilat.admin.AdminDtos.ReactivateUserBody;
import com.bitadilat.admin.AdminDtos.RejectBody;
import com.bitadilat.admin.AdminDtos.RequestDocumentsBody;
import com.bitadilat.admin.AdminDtos.SuspendUserBody;
import com.bitadilat.common.security.AuthPrincipal;
import jakarta.validation.Valid;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Yönetici paneli uç noktaları (API_V1.md §Admin: /api/v1/admin/**). */
@RestController
@RequestMapping("/api/v1/admin")
public class AdminController {

    private final AdminService admin;

    public AdminController(AdminService admin) {
        this.admin = admin;
    }

    // ─── Usta başvuruları ───────────────────────────────────────────────────

    @GetMapping("/applications")
    public ProApplicationList listApplications(@AuthenticationPrincipal AuthPrincipal principal,
                                               @RequestParam(required = false) String status,
                                               @RequestParam(required = false) String cursor,
                                               @RequestParam(required = false) Integer limit) {
        return admin.listApplications(principal, status, cursor, limit);
    }

    @PostMapping("/applications/{proId}/approve")
    public ProApplicationItem approveApplication(@AuthenticationPrincipal AuthPrincipal principal,
                                                 @PathVariable UUID proId) {
        return admin.approveApplication(principal, proId);
    }

    @PostMapping("/applications/{proId}/reject")
    public ProApplicationItem rejectApplication(@AuthenticationPrincipal AuthPrincipal principal,
                                                @PathVariable UUID proId,
                                                @Valid @RequestBody RejectBody body) {
        return admin.rejectApplication(principal, proId, body.reason());
    }

    @PostMapping("/applications/{proId}/request-documents")
    public ProApplicationItem requestDocuments(@AuthenticationPrincipal AuthPrincipal principal,
                                               @PathVariable UUID proId,
                                               @Valid @RequestBody RequestDocumentsBody body) {
        return admin.requestDocuments(principal, proId, body.note());
    }

    // ─── Şikayetler ve hakem kararları ──────────────────────────────────────

    @GetMapping("/complaints")
    public AdminComplaintList listComplaints(@AuthenticationPrincipal AuthPrincipal principal,
                                             @RequestParam(required = false) String status,
                                             @RequestParam(required = false) String cursor,
                                             @RequestParam(required = false) Integer limit) {
        return admin.listComplaints(principal, status, cursor, limit);
    }

    @GetMapping("/complaints/{id}")
    public AdminComplaintDetail getComplaint(@AuthenticationPrincipal AuthPrincipal principal,
                                             @PathVariable UUID id) {
        return admin.getComplaintDetail(principal, id);
    }

    @PostMapping("/complaints/{id}/review")
    public AdminComplaintDetail reviewComplaint(@AuthenticationPrincipal AuthPrincipal principal,
                                                @PathVariable UUID id) {
        return admin.markComplaintInReview(principal, id);
    }

    @PostMapping("/complaints/{id}/decision")
    public AdminComplaintDetail decideComplaint(@AuthenticationPrincipal AuthPrincipal principal,
                                                @PathVariable UUID id,
                                                @Valid @RequestBody ComplaintDecisionBody body) {
        return admin.decideComplaint(principal, id, body);
    }

    // ─── Kullanıcı ve usta hesap yönetimi ───────────────────────────────────

    @GetMapping("/users")
    public AdminUserList listUsers(@AuthenticationPrincipal AuthPrincipal principal,
                                   @RequestParam(required = false) String q,
                                   @RequestParam(required = false) String role,
                                   @RequestParam(required = false) String status,
                                   @RequestParam(required = false) String district,
                                   @RequestParam(required = false) String cursor,
                                   @RequestParam(required = false) Integer limit) {
        return admin.listUsers(principal, q, role, status, district, cursor, limit);
    }

    @PostMapping("/users/{id}/suspend")
    public AdminUserItem suspendUser(@AuthenticationPrincipal AuthPrincipal principal,
                                     @PathVariable UUID id,
                                     @Valid @RequestBody SuspendUserBody body) {
        return admin.suspendUser(principal, id, body.reason());
    }

    @PostMapping("/users/{id}/reactivate")
    public AdminUserItem reactivateUser(@AuthenticationPrincipal AuthPrincipal principal,
                                        @PathVariable UUID id,
                                        @Valid @RequestBody(required = false) ReactivateUserBody body) {
        return admin.reactivateUser(principal, id, body == null ? null : body.note());
    }

    // ─── Emanet (escrow) ve denetim kayıtları (admin_actions) ───────────────

    @GetMapping("/payments")
    public AdminPaymentList listPayments(@AuthenticationPrincipal AuthPrincipal principal,
                                         @RequestParam(required = false) String status,
                                         @RequestParam(required = false) String cursor,
                                         @RequestParam(required = false) Integer limit) {
        return admin.listPayments(principal, status, cursor, limit);
    }

    @GetMapping("/actions")
    public AdminActionList listActions(@AuthenticationPrincipal AuthPrincipal principal,
                                       @RequestParam(required = false) String targetType,
                                       @RequestParam(required = false) String targetId,
                                       @RequestParam(required = false) String cursor,
                                       @RequestParam(required = false) Integer limit) {
        return admin.listActions(principal, targetType, targetId, cursor, limit);
    }
}
