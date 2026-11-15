package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.ActiveProfiles;
import tools.jackson.databind.JsonNode;

/**
 * dev seed'inin admin ve bildirim eklemeleri. Craftgate sahte değildir: SEED emaneti dev'de yalnızca defterde
 * işlenir, gateway'e gidilseydi (anahtarsız istemci) karar 502 verirdi.
 */
@ActiveProfiles("dev")
@org.springframework.boot.test.context.SpringBootTest(properties = {
        "spring.datasource.url=${TEST_DB_URL:jdbc:postgresql://localhost:5432/bitadilat_test}",
        "spring.datasource.username=${TEST_DB_USER:${USER}}",
        "spring.datasource.password=${TEST_DB_PASSWORD:}"
})
class AdminDevSeedTest extends ApiTestBase {

    private static final String DEMO = "Demo1234!";

    @BeforeEach
    void reset() throws Exception {
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
    }

    private String login(String email) throws Exception {
        return body(call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", email, "password", DEMO))
                .andExpect(status().isOk())).get("accessToken").asString();
    }

    private JsonNode get(String token, String path) throws Exception {
        return body(call(HttpMethod.GET, "/api/v1" + path, token, null).andExpect(status().isOk()));
    }

    private List<String> types(String token) throws Exception {
        List<String> out = new ArrayList<>();
        get(token, "/notifications?limit=50").get("items").forEach(n -> out.add(n.get("type").asString()));
        return out;
    }

    @Test
    void adminSeesTheSeededQueuesAndTotals() throws Exception {
        String admin = login("admin@bitadilat.test");
        assertThat(get(admin, "/me").get("isAdmin").asBoolean()).isTrue();

        JsonNode stats = get(admin, "/admin/stats");
        assertThat(stats.get("pendingApplications").asInt()).isEqualTo(1);
        assertThat(stats.get("openComplaints").asInt()).isEqualTo(1);
        assertThat(stats.get("activeJobs").asInt()).isEqualTo(2); // BD-88409 SCHEDULED, BD-88398 DISPUTED
        assertThat(stats.get("lockedEscrowTotal").asDouble()).isEqualTo(3400.0); // 1.200 LOCKED + 2.200 DISPUTED

        JsonNode pending = get(admin, "/admin/applications").get("items");
        assertThat(pending).hasSize(1);
        assertThat(pending.get(0).get("businessName").asString()).isEqualTo("Yıldız Elektrik");
        assertThat(pending.get(0).get("documentCount").asInt()).isEqualTo(2);
        JsonNode detail = get(admin, "/admin/applications/" + pending.get(0).get("proId").asString());
        assertThat(detail.get("documents")).hasSize(2);
        assertThat(detail.get("email").asString()).isEqualTo("hasan@bitadilat.test");

        JsonNode needs = get(admin, "/admin/applications?status=NEEDS_DOCUMENTS").get("items");
        assertThat(needs).hasSize(1);
        assertThat(needs.get(0).get("businessName").asString()).isEqualTo("Aksoy Boya & Badana");
        JsonNode selim = get(admin, "/admin/applications/" + needs.get(0).get("proId").asString());
        assertThat(selim.get("reviewNote").asString()).contains("Vergi levhası eksik");
        assertThat(selim.get("documents").get(1).get("status").asString()).isEqualTo("REJECTED");

        JsonNode complaints = get(admin, "/admin/complaints").get("items");
        assertThat(complaints).hasSize(1);
        assertThat(complaints.get(0).get("publicCode").asString()).isEqualTo("SK-1001");
        assertThat(complaints.get(0).get("status").asString()).isEqualTo("OPEN");
        assertThat(complaints.get(0).get("jobPublicCode").asString()).isEqualTo("BD-88398");
        assertThat(complaints.get(0).get("amount").asDouble()).isEqualTo(2200.0);

        JsonNode ledger = get(admin, "/admin/payments");
        assertThat(ledger.get("items").size()).isGreaterThanOrEqualTo(13);
        assertThat(ledger.get("totals").get("lockedTotal").asDouble()).isEqualTo(3400.0);
        assertThat(get(admin, "/admin/users?q=hasan").get("items").get(0).get("pro").get("reviewStatus").asString())
                .isEqualTo("PENDING_REVIEW");
    }

    @Test
    void everySeededAccountExceptThePendingApplicantHasNotificationsWithRealTargets() throws Exception {
        for (String who : List.of("ali", "zeynep", "mehmet", "ahmet", "emre", "selim", "admin")) {
            String token = login(who + "@bitadilat.test");
            JsonNode center = get(token, "/notifications?limit=50");
            assertThat(center.get("items").size()).as(who).isGreaterThanOrEqualTo(1);
            assertThat(get(token, "/me").get("unreadNotifications").asInt()).as(who)
                    .isEqualTo(center.get("unreadCount").asInt());
            for (JsonNode n : center.get("items")) {
                assertThat(n.get("targetRoute").isNull()).as(who + " " + n.get("type").asString()).isFalse();
                assertThat(n.get("targetRoute").asString()).startsWith("/");
            }
        }
        // Hasan'ın başvurusu henüz bekliyor: bildirimi yok (boş durum).
        String hasan = login("hasan@bitadilat.test");
        assertThat(get(hasan, "/notifications").get("items")).isEmpty();

        assertThat(types(login("ali@bitadilat.test"))).containsExactlyInAnyOrder("OFFER_RECEIVED", "OFFER_RECEIVED",
                "OFFER_RECEIVED", "APPOINTMENT_CONFIRMED");
        assertThat(get(login("ali@bitadilat.test"), "/me").get("unreadNotifications").asInt()).isEqualTo(3);
        assertThat(types(login("selim@bitadilat.test"))).containsExactly("PRO_NEEDS_DOCUMENTS");
        assertThat(types(login("emre@bitadilat.test"))).contains("COMPLAINT_OPENED", "NEW_MATCHING_REQUEST");
        assertThat(types(login("admin@bitadilat.test"))).containsExactly("COMPLAINT_OPENED");
        assertThat(types(login("mehmet@bitadilat.test"))).contains("OFFER_ACCEPTED", "APPOINTMENT_PROPOSED",
                "NEW_MATCHING_REQUEST");
        assertThat(types(login("ahmet@bitadilat.test"))).contains("PAYOUT_RELEASED");
        assertThat(types(login("zeynep@bitadilat.test"))).contains("JOB_STAGE_CHANGED", "NEW_MESSAGE");

        // Ali'nin teklif bildirimi gerçek teklif ve talep kimliklerine işaret eder.
        String ali = login("ali@bitadilat.test");
        JsonNode offer = get(ali, "/notifications?limit=50").get("items").get(0);
        assertThat(offer.get("params").get("proBusinessName").asString()).isEqualTo("Usta Eller Tesisat");
        assertThat(offer.get("params").get("amount").asString()).isEqualTo("1850.00");
        String requestId = offer.get("targetRoute").asString().split("/")[3];
        JsonNode request = get(ali, "/requests/" + requestId);
        assertThat(request.get("publicCode").asString()).isEqualTo("BD-88412");
    }

    @Test
    void sk1001CanBeDecidedOnTheSeedPaymentLedgerOnlyAndResetRestoresIt() throws Exception {
        String admin = login("admin@bitadilat.test");
        int zeynepBefore = get(login("zeynep@bitadilat.test"), "/notifications?limit=50").get("items").size();
        String complaintId = get(admin, "/admin/complaints").get("items").get(0).get("id").asString();
        JsonNode decided = body(call(HttpMethod.POST, "/api/v1/admin/complaints/" + complaintId + "/decision", admin,
                Map.of("decision", "SPLIT_50_50", "note", "Ek ücret teklifte yok, masraf paylaşılsın.",
                        "warnPro", true, "suspendPro", false)).andExpect(status().isOk()));
        assertThat(decided.get("status").asString()).isEqualTo("RESOLVED");
        assertThat(decided.get("payment").get("provider").asString()).isEqualTo("SEED");
        assertThat(decided.get("payment").get("status").asString()).isEqualTo("SPLIT_SETTLED");
        assertThat(decided.get("payment").get("refundedAmount").asDouble()).isEqualTo(1100.0);
        assertThat(decided.get("job").get("status").asString()).isEqualTo("RESOLVED");
        assertThat(decided.get("pro").get("warningCount").asInt()).isEqualTo(1);
        String ref = decided.get("payment").get("ref").asString();
        assertThat(jdbc.queryForObject("select sum(amount) from payout_ledger where payment_ref = ? and kind = 'REFUND'",
                java.math.BigDecimal.class, ref)).isEqualByComparingTo("1100");
        assertThat(jdbc.queryForObject("select sum(amount) from payout_ledger where payment_ref = ? and kind = 'PAYOUT'",
                java.math.BigDecimal.class, ref)).isEqualByComparingTo("1100");
        assertThat(get(admin, "/admin/stats").get("openComplaints").asInt()).isZero();
        assertThat(count("select count(*) from admin_actions")).isGreaterThanOrEqualTo(2);

        // /dev/reset yeniden yükler: şikayet yine açık, denetim kayıtları ve defter temiz, bildirimler aynı sayıda.
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent()); // ikinci kez de sorunsuz
        String again = login("admin@bitadilat.test");
        assertThat(get(again, "/admin/stats").get("openComplaints").asInt()).isEqualTo(1);
        assertThat(count("select count(*) from admin_actions")).isZero();
        assertThat(get(login("zeynep@bitadilat.test"), "/notifications?limit=50").get("items").size())
                .isEqualTo(zeynepBefore);
        assertThat(get(login("ali@bitadilat.test"), "/me").get("unreadNotifications").asInt()).isEqualTo(3);
    }

    private long count(String sql) {
        return jdbc.queryForObject(sql, Long.class);
    }
}
