package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.ApplicationDetail;
import com.bitadilat.admin.AdminDtos.ApplicationList;
import com.bitadilat.admin.AdminDtos.ComplaintDetail;
import com.bitadilat.admin.AdminDtos.ComplaintList;
import com.bitadilat.admin.AdminDtos.DecisionBody;
import com.bitadilat.admin.AdminDtos.NoteBody;
import com.bitadilat.admin.AdminDtos.PaymentLedger;
import com.bitadilat.admin.AdminDtos.RequestDocumentsBody;
import com.bitadilat.admin.AdminDtos.Stats;
import com.bitadilat.admin.AdminDtos.UserItem;
import com.bitadilat.admin.AdminDtos.UserList;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.security.AuthPrincipal;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Admin uç noktaları. Güvenlik zinciri {@code /api/v1/admin/**} için ROLE_ADMIN ister; her yöntem ayrıca
 * {@code isAdmin} bayrağını denetler (zincir yanlış yapılandırılsa da yetkisiz çağrı 403 alır).
 */
@RestController
@RequestMapping("/api/v1/admin")
public class AdminController {

    private final AdminReportService reports;
    private final AdminApplicationService applications;
    private final AdminComplaintService complaints;
    private final AdminAccountService accounts;

    public AdminController(AdminReportService reports, AdminApplicationService applications,
                           AdminComplaintService complaints, AdminAccountService accounts) {
        this.reports = reports;
        this.applications = applications;
        this.complaints = complaints;
        this.accounts = accounts;
    }

    private static UUID admin(AuthPrincipal me) {
        if (me == null || !me.admin()) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bu işlem için yetkin yok.");
        }
        return me.userId();
    }

    @GetMapping("/stats")
    public Stats stats(@AuthenticationPrincipal AuthPrincipal me) {
        admin(me);
        return reports.stats();
    }

    // ─── Usta başvuruları ───────────────────────────────────────────────────

    @GetMapping("/applications")
    public ApplicationList applications(@AuthenticationPrincipal AuthPrincipal me,
                                        @RequestParam(required = false) String status,
                                        @RequestParam(required = false) String q) {
        admin(me);
        return applications.list(status, q);
    }

    @GetMapping("/applications/{proId}")
    public ApplicationDetail application(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID proId) {
        admin(me);
        return applications.detail(proId);
    }

    @PostMapping("/applications/{proId}/approve")
    public ApplicationDetail approve(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID proId,
                                     @RequestBody(required = false) NoteBody body) {
        return applications.approve(admin(me), proId, body == null ? null : body.note());
    }

    @PostMapping("/applications/{proId}/reject")
    public ApplicationDetail reject(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID proId,
                                    @RequestBody NoteBody body) {
        return applications.reject(admin(me), proId, body.note());
    }

    @PostMapping("/applications/{proId}/request-documents")
    public ApplicationDetail requestDocuments(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID proId,
                                              @RequestBody RequestDocumentsBody body) {
        return applications.requestDocuments(admin(me), proId, body.note(), body.documentTypes());
    }

    // ─── Şikayetler ─────────────────────────────────────────────────────────

    @GetMapping("/complaints")
    public ComplaintList complaints(@AuthenticationPrincipal AuthPrincipal me,
                                    @RequestParam(required = false) String status) {
        admin(me);
        return complaints.list(status);
    }

    @GetMapping("/complaints/{id}")
    public ComplaintDetail complaint(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID id) {
        return complaints.detail(admin(me), id);
    }

    @PostMapping("/complaints/{id}/review")
    public ComplaintDetail review(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID id) {
        return complaints.review(admin(me), id);
    }

    @PostMapping("/complaints/{id}/decision")
    public ComplaintDetail decide(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID id,
                                  @RequestBody DecisionBody body) {
        return complaints.decide(admin(me), id, body);
    }

    // ─── Hesaplar ───────────────────────────────────────────────────────────

    @GetMapping("/users")
    public UserList users(@AuthenticationPrincipal AuthPrincipal me, @RequestParam(required = false) String q,
                          @RequestParam(required = false) String role,
                          @RequestParam(required = false) String status) {
        admin(me);
        return accounts.list(q, role, status);
    }

    @PostMapping("/users/{id}/suspend")
    public UserItem suspend(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID id,
                            @RequestBody NoteBody body) {
        return accounts.suspend(admin(me), id, body.note());
    }

    @PostMapping("/users/{id}/reactivate")
    public UserItem reactivate(@AuthenticationPrincipal AuthPrincipal me, @PathVariable UUID id) {
        return accounts.reactivate(admin(me), id);
    }

    // ─── Ödeme defteri ──────────────────────────────────────────────────────

    @GetMapping("/payments")
    public PaymentLedger payments(@AuthenticationPrincipal AuthPrincipal me,
                                  @RequestParam(required = false) String status) {
        admin(me);
        return reports.payments(status);
    }
}
