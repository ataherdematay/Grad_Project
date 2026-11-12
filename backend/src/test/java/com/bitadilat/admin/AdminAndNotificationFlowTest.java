package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import com.bitadilat.notification.NotificationService;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class AdminAndNotificationFlowTest extends Wave3TestBase {

    private Account registerAdmin() throws Exception {
        Account admin = register();
        jdbc.update("update users set is_admin = true where id = ?::uuid", admin.id());
        return admin;
    }

    private Account pendingPro(String businessName) throws Exception {
        Account a = register();
        jdbc.update("insert into pro_profiles (user_id, business_name, experience_years, review_status) "
                + "values (?::uuid, ?, 4, 'PENDING_REVIEW')", a.id(), businessName);
        jdbc.update("insert into pro_categories (pro_id, category_id) values (?::uuid, 'plumbing')", a.id());
        jdbc.update("insert into pro_districts (pro_id, district_id) values (?::uuid, ?)", a.id(), districtId("Kadıköy"));
        return a;
    }

    @Test
    void nonAdminCannotAccessAdminEndpoints() throws Exception {
        Account customer = register();
        call(HttpMethod.GET, "/api/v1/admin/applications", customer.access(), null)
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    @Test
    void proApplicationReviewLifecycleCreatesAuditAndNotifications() throws Exception {
        Account admin = registerAdmin();
        Account pro1 = pendingPro("Usta Bir Tesisat");
        Account pro2 = pendingPro("Usta İki Elektrik");

        // List pending applications
        JsonNode list = body(call(HttpMethod.GET, "/api/v1/admin/applications?status=PENDING_REVIEW", admin.access(), null)
                .andExpect(status().isOk()));
        assertThat(list.get("items").size()).isGreaterThanOrEqualTo(2);

        // Request additional documents from pro1
        call(HttpMethod.POST, "/api/v1/admin/applications/" + pro1.id() + "/request-documents", admin.access(),
                Map.of("note", "Vergi levhası okunmuyor, lütfen net yükleyin."))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reviewStatus").value("NEEDS_DOCUMENTS"));

        assertThat(notifications(pro1, NotificationService.PRO_DOCUMENTS_REQUESTED)).isEqualTo(1);

        // Approve pro1 after document request
        call(HttpMethod.POST, "/api/v1/admin/applications/" + pro1.id() + "/approve", admin.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reviewStatus").value("APPROVED"));

        assertThat(notifications(pro1, NotificationService.PRO_APPLICATION_APPROVED)).isEqualTo(1);

        // Reject pro2
        call(HttpMethod.POST, "/api/v1/admin/applications/" + pro2.id() + "/reject", admin.access(),
                Map.of("reason", "Mesleki yeterlilik belgesi geçersiz."))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.reviewStatus").value("REJECTED"));

        assertThat(notifications(pro2, NotificationService.PRO_APPLICATION_REJECTED)).isEqualTo(1);

        // Audit log contains all 3 actions
        JsonNode actions = body(call(HttpMethod.GET, "/api/v1/admin/actions?targetType=PRO_PROFILE", admin.access(), null)
                .andExpect(status().isOk()));
        assertThat(actions.get("items").size()).isGreaterThanOrEqualTo(3);
    }

    @Test
    void complaintArbitrationSplit5050SettlesEscrowAndUpdatesJob() throws Exception {
        Account admin = registerAdmin();
        Setup s = openRequestWithOffer("800", "200"); // total = 1000.00
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);

        // Customer opens a complaint while job is DELIVERED
        JsonNode createdComplaint = body(jobPost(s.customer(), jobId, "/complaint",
                Map.of("reason", "INCOMPLETE_WORK",
                        "description", "Musluk bağlantısı hala su kaçırıyor, işçilik kusurlu.",
                        "evidenceIds", List.of()))
                .andExpect(status().isCreated()));
        String complaintId = createdComplaint.get("id").asString();
        assertThat(jobStatus(jobId)).isEqualTo("DISPUTED");

        // Admin moves complaint to IN_REVIEW
        call(HttpMethod.POST, "/api/v1/admin/complaints/" + complaintId + "/review", admin.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.complaint.status").value("IN_REVIEW"));

        // Admin decides SPLIT_50_50 with pro warning
        call(HttpMethod.POST, "/api/v1/admin/complaints/" + complaintId + "/decision", admin.access(),
                Map.of("decision", "SPLIT_50_50",
                        "decisionNote", "Malzeme takılmış ancak işçilik yarım kalmış; yarı yarıya uzlaşı.",
                        "warnPro", true,
                        "suspendPro", false))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.complaint.status").value("RESOLVED"))
                .andExpect(jsonPath("$.complaint.decision").value("SPLIT_50_50"));

        assertThat(jobStatus(jobId)).isEqualTo("RESOLVED");
        assertThat(escrowStatus(jobId)).isEqualTo("SPLIT_SETTLED");

        int warnings = jdbc.queryForObject("select warning_count from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id());
        assertThat(warnings).isEqualTo(1);

        assertThat(notifications(s.customer(), NotificationService.COMPLAINT_DECIDED)).isEqualTo(1);
        assertThat(notifications(s.pro(), NotificationService.COMPLAINT_DECIDED)).isEqualTo(1);

        // Verify payment ledger view via admin endpoint
        JsonNode payments = body(call(HttpMethod.GET, "/api/v1/admin/payments?status=SPLIT_SETTLED", admin.access(), null)
                .andExpect(status().isOk()));
        assertThat(payments.get("items").size()).isGreaterThanOrEqualTo(1);
    }

    @Test
    void suspendAndReactivateUserWithdrawsPendingOffersAndPreventsSelfSuspend() throws Exception {
        Account admin = registerAdmin();
        Setup s = openRequestWithOffer("600", "150");

        // Admin cannot suspend themselves
        call(HttpMethod.POST, "/api/v1/admin/users/" + admin.id() + "/suspend", admin.access(),
                Map.of("reason", "Kendi hesabımı askıya alamam."))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));

        // Suspend pro account -> pending offer becomes WITHDRAWN
        call(HttpMethod.POST, "/api/v1/admin/users/" + s.pro().id() + "/suspend", admin.access(),
                Map.of("reason", "Platform kuralları ihlali nedeniyle geçici askıya alma."))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SUSPENDED"));

        String offerStatus = jdbc.queryForObject("select status from offers where id = ?::uuid",
                String.class, s.offerId());
        assertThat(offerStatus).isEqualTo("WITHDRAWN");

        // Reactivate pro account
        call(HttpMethod.POST, "/api/v1/admin/users/" + s.pro().id() + "/reactivate", admin.access(),
                Map.of("note", "İnceleme tamamlandı, hesap tekrar açıldı."))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    void notificationListingMarkingReadAndDeviceRegistration() throws Exception {
        Account admin = registerAdmin();
        Account pro = pendingPro("Bildirim Test Usta");

        // Trigger a notification by approving pro
        call(HttpMethod.POST, "/api/v1/admin/applications/" + pro.id() + "/approve", admin.access(), null)
                .andExpect(status().isOk());

        // Fetch notifications for pro
        JsonNode notifList = body(call(HttpMethod.GET, "/api/v1/notifications", pro.access(), null)
                .andExpect(status().isOk()));
        assertThat(notifList.get("unreadCount").asLong()).isEqualTo(1L);
        String notifId = notifList.get("items").get(0).get("id").asString();

        // Mark notification as read
        call(HttpMethod.POST, "/api/v1/notifications/read", pro.access(),
                Map.of("ids", List.of(notifId)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.markedCount").value(1));

        call(HttpMethod.GET, "/api/v1/notifications", pro.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.unreadCount").value(0));

        // Register push device token
        call(HttpMethod.PUT, "/api/v1/devices", pro.access(),
                Map.of("platform", "ANDROID", "token", "fcm-test-device-token-1234567890"))
                .andExpect(status().isNoContent());

        long tokenCount = count("select count(*) from device_tokens where user_id = ?::uuid and platform = 'ANDROID'",
                pro.id());
        assertThat(tokenCount).isEqualTo(1L);
    }
}
