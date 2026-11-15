package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** /admin erişimi, özet sayılar ve usta başvurusu incelemesi. */
class AdminApplicationTest extends AdminTestBase {

    private static final String ANY = UUID.randomUUID().toString();

    // ─── Erişim ─────────────────────────────────────────────────────────────

    @Test
    void everyAdminEndpointRejectsNonAdminsWith403AndAnonymousWith401() throws Exception {
        Account user = register();
        Account pro = pro("Normal Usta", List.of("plumbing"), List.of("Kadıköy"));
        Map<String, Object> note = Map.of("note", "Yeterince uzun bir not.");
        List<Object[]> calls = List.of(
                new Object[]{HttpMethod.GET, "/admin/stats", null},
                new Object[]{HttpMethod.GET, "/admin/applications", null},
                new Object[]{HttpMethod.GET, "/admin/applications/" + ANY, null},
                new Object[]{HttpMethod.POST, "/admin/applications/" + ANY + "/approve", Map.of()},
                new Object[]{HttpMethod.POST, "/admin/applications/" + ANY + "/reject", note},
                new Object[]{HttpMethod.POST, "/admin/applications/" + ANY + "/request-documents",
                        Map.of("note", "Yeterince uzun bir not.", "documentTypes", List.of("TAX"))},
                new Object[]{HttpMethod.GET, "/admin/complaints", null},
                new Object[]{HttpMethod.GET, "/admin/complaints/" + ANY, null},
                new Object[]{HttpMethod.POST, "/admin/complaints/" + ANY + "/review", null},
                new Object[]{HttpMethod.POST, "/admin/complaints/" + ANY + "/decision",
                        Map.of("decision", "FULL_REFUND", "note", "Yeterince uzun bir not.")},
                new Object[]{HttpMethod.GET, "/admin/users", null},
                new Object[]{HttpMethod.POST, "/admin/users/" + ANY + "/suspend", note},
                new Object[]{HttpMethod.POST, "/admin/users/" + ANY + "/reactivate", null},
                new Object[]{HttpMethod.GET, "/admin/payments", null});
        for (Object[] c : calls) {
            for (Account who : List.of(user, pro)) {
                call((HttpMethod) c[0], "/api/v1" + c[1], who.access(), c[2])
                        .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
            }
            call((HttpMethod) c[0], "/api/v1" + c[1], null, c[2]).andExpect(status().isUnauthorized());
        }
        assertThat(count("select count(*) from admin_actions")).isZero();
    }

    @Test
    void statsCountPendingApplicationsOpenComplaintsActiveJobsAndLockedEscrow() throws Exception {
        Account admin = admin();
        JsonNode empty = ok(get(admin, "/admin/stats"));
        assertThat(empty.get("pendingApplications").asInt()).isZero();
        assertThat(empty.get("openComplaints").asInt()).isZero();
        assertThat(empty.get("activeJobs").asInt()).isZero();
        assertThat(empty.get("lockedEscrowTotal").asDouble()).isZero();

        pendingPro("Yıldız Elektrik");
        pendingPro("Işık Elektrik");
        Disputed d = disputedJob("900", "300"); // 1200 TL, iş ve emanet DISPUTED
        Setup other = openRequestWithOffer("500", "0");
        payAndOpenJob(other); // 500 TL, LOCKED, iş AWAITING_APPOINTMENT

        JsonNode stats = ok(get(admin, "/admin/stats"));
        assertThat(stats.get("pendingApplications").asInt()).isEqualTo(2);
        assertThat(stats.get("openComplaints").asInt()).isEqualTo(1);
        assertThat(stats.get("activeJobs").asInt()).isEqualTo(2);
        assertThat(stats.get("lockedEscrowTotal").asDouble()).isEqualTo(1700.0);

        // Şikayet karara bağlanınca sayılar düşer; tutar çıkar.
        ok(decide(admin, d, "FULL_REFUND"));
        JsonNode after = ok(get(admin, "/admin/stats"));
        assertThat(after.get("openComplaints").asInt()).isZero();
        assertThat(after.get("activeJobs").asInt()).isEqualTo(1);
        assertThat(after.get("lockedEscrowTotal").asDouble()).isEqualTo(500.0);
    }

    // ─── Liste ve ayrıntı ───────────────────────────────────────────────────

    @Test
    void applicationListFiltersByStatusSearchesAndOrdersOldestFirst() throws Exception {
        Account admin = admin();
        Account first = pendingPro("Birinci Elektrik");
        Account second = pendingPro("İkinci Tesisat");
        // Varsayılan: PENDING_REVIEW, en eski başvuru önce.
        JsonNode list = ok(get(admin, "/admin/applications")).get("items");
        assertThat(list).hasSize(2);
        assertThat(list.get(0).get("proId").asString()).isEqualTo(first.id());
        assertThat(list.get(1).get("proId").asString()).isEqualTo(second.id());
        JsonNode row = list.get(0);
        assertThat(row.get("businessName").asString()).isEqualTo("Birinci Elektrik");
        assertThat(row.get("fullName").asString()).isEqualTo("Test Kullanıcı");
        assertThat(row.get("categoryIds").get(0).asString()).isEqualTo("electrical");
        assertThat(row.get("districtNames").get(0).asString()).isEqualTo("Ümraniye");
        assertThat(row.get("reviewStatus").asString()).isEqualTo("PENDING_REVIEW");
        assertThat(row.get("documentCount").asInt()).isEqualTo(3);
        assertThat(row.get("submittedAt").asString()).isNotBlank();

        // Arama: işletme adı, e-posta, telefon.
        assertThat(ok(get(admin, "/admin/applications?q=tesisat")).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/applications?q=" + first.email())).get("items")).hasSize(1);
        String digits = first.phone().replaceAll("\\s+", "").substring(1);
        assertThat(ok(get(admin, "/admin/applications?q=" + digits)).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/applications?q=yokboyle")).get("items")).isEmpty();
        // Durum süzgeci.
        assertThat(ok(get(admin, "/admin/applications?status=APPROVED")).get("items")).isEmpty();
        get(admin, "/admin/applications?status=BOGUS").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("status"));
        jdbc.update("update pro_profiles set review_status = 'SUSPENDED' where user_id = ?::uuid", second.id());
        assertThat(ok(get(admin, "/admin/applications?status=SUSPENDED")).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/applications")).get("items")).hasSize(1);
    }

    @Test
    void applicationDetailShowsContactDocumentsWithSignedMediaAndHistory() throws Exception {
        Account admin = admin();
        Account hasan = pendingPro("Yıldız Elektrik");
        JsonNode d = ok(get(admin, "/admin/applications/" + hasan.id()));
        assertThat(d.get("proId").asString()).isEqualTo(hasan.id());
        assertThat(d.get("email").asString()).isEqualTo(hasan.email());
        assertThat(d.get("phone").asString()).startsWith("+90");
        assertThat(d.get("bio").asString()).isEqualTo("Ev elektrik tesisatı.");
        assertThat(d.get("experienceYears").asInt()).isEqualTo(6);
        assertThat(d.get("reviewNote").isNull()).isTrue();
        assertThat(d.get("history")).isEmpty();
        JsonNode docs = d.get("documents");
        assertThat(docs).hasSize(3);
        assertThat(docs.get(0).get("type").asString()).isEqualTo("IDENTITY");
        assertThat(docs.get(0).get("status").asString()).isEqualTo("PENDING");
        String url = docs.get(0).get("media").get("url").asString();
        assertThat(url).contains("/api/v1/media/").contains("sig=");
        // İmzalı adres Authorization olmadan açılır.
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get(
                        url.substring(url.indexOf("/api/v1/media/"))))
                .andExpect(status().isOk());
        get(admin, "/admin/applications/" + UUID.randomUUID()).andExpect(status().isNotFound());
        get(admin, "/admin/applications/not-a-uuid").andExpect(status().isNotFound());
    }

    // ─── Karar: approve / reject / request-documents ────────────────────────

    @Test
    void approveAcceptsEveryDocumentSetsApprovedAtNotifiesAndAuditsInOneStep() throws Exception {
        Account admin = admin();
        Account hasan = pendingPro("Yıldız Elektrik");
        JsonNode d = ok(post(admin, "/admin/applications/" + hasan.id() + "/approve", Map.of("note", "Belgeler tamam.")));
        assertThat(d.get("reviewStatus").asString()).isEqualTo("APPROVED");
        assertThat(d.get("reviewNote").asString()).isEqualTo("Belgeler tamam.");
        d.get("documents").forEach(doc -> assertThat(doc.get("status").asString()).isEqualTo("ACCEPTED"));
        assertThat(jdbc.queryForObject("select approved_at is not null from pro_profiles where user_id = ?::uuid",
                Boolean.class, hasan.id())).isTrue();
        assertThat(jdbc.queryForObject("select count(*) from pro_documents where pro_id = ?::uuid and reviewed_by = ?::uuid",
                Integer.class, hasan.id(), admin.id())).isEqualTo(3);

        assertThat(notifications(hasan, "PRO_APPROVED")).isEqualTo(1);
        Map<String, Object> n = jdbc.queryForMap(
                "select params::text as params, target_route from notifications where user_id = ?::uuid and type = 'PRO_APPROVED'",
                hasan.id());
        assertThat(n.get("target_route")).isEqualTo("/p/feed");
        assertThat(n.get("params")).isEqualTo("{}");

        assertThat(adminActions("APPROVE_APPLICATION", hasan.id())).isEqualTo(1);
        Map<String, Object> action = jdbc.queryForMap(
                "select admin_id::text as admin_id, target_type, note from admin_actions where target_id = ?", hasan.id());
        assertThat(action.get("admin_id")).isEqualTo(admin.id());
        assertThat(action.get("target_type")).isEqualTo("PRO_PROFILE");
        assertThat(action.get("note")).isEqualTo("Belgeler tamam.");
        assertThat(d.get("history").get(0).get("action").asString()).isEqualTo("APPROVE_APPLICATION");
        assertThat(d.get("history").get(0).get("adminName").asString()).isEqualTo("Test Kullanıcı");

        // Onaylı usta artık usta kapısından geçer ve tekrar karar 409.
        call(HttpMethod.GET, "/api/v1/pro/profile", hasan.access(), null).andExpect(status().isOk());
        post(admin, "/admin/applications/" + hasan.id() + "/approve", Map.of()).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        post(admin, "/admin/applications/" + hasan.id() + "/reject", Map.of("note", "Çok geç oldu artık reddedilemez."))
                .andExpect(status().isConflict());
        assertThat(adminActions("APPROVE_APPLICATION", hasan.id())).isEqualTo(1);
    }

    @Test
    void approveWorksWithoutBody() throws Exception {
        Account admin = admin();
        Account hasan = pendingPro("Yıldız Elektrik");
        call(HttpMethod.POST, "/api/v1/admin/applications/" + hasan.id() + "/approve", admin.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.reviewStatus").value("APPROVED"))
                .andExpect(jsonPath("$.reviewNote").doesNotExist());
    }

    @Test
    void rejectNeedsANoteSetsRejectedAndNotifiesWithTheNote() throws Exception {
        Account admin = admin();
        Account hasan = pendingPro("Yıldız Elektrik");
        post(admin, "/admin/applications/" + hasan.id() + "/reject", Map.of("note", "kısa"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("note"));
        post(admin, "/admin/applications/" + hasan.id() + "/reject", Map.of("note", "x".repeat(1001)))
                .andExpect(status().isBadRequest());
        assertThat(adminActions("REJECT_APPLICATION", hasan.id())).isZero();

        String note = "Kimlik fotoğrafı okunmuyor ve meslek belgesi geçersiz.";
        JsonNode d = ok(post(admin, "/admin/applications/" + hasan.id() + "/reject", Map.of("note", note)));
        assertThat(d.get("reviewStatus").asString()).isEqualTo("REJECTED");
        assertThat(d.get("reviewNote").asString()).isEqualTo(note);
        d.get("documents").forEach(doc -> assertThat(doc.get("status").asString()).isEqualTo("PENDING"));
        Map<String, Object> n = jdbc.queryForMap(
                "select params ->> 'note' as note, target_route from notifications where user_id = ?::uuid and type = 'PRO_REJECTED'",
                hasan.id());
        assertThat(n.get("note")).isEqualTo(note);
        assertThat(n.get("target_route")).isEqualTo("/p/application");
        assertThat(adminActions("REJECT_APPLICATION", hasan.id())).isEqualTo(1);
        assertThat(ok(get(admin, "/admin/applications?status=REJECTED")).get("items")).hasSize(1);
        // Reddedilen usta usta kapısından geçemez.
        call(HttpMethod.GET, "/api/v1/pro/profile", hasan.access(), null).andExpect(status().isForbidden());
    }

    @Test
    void requestDocumentsRejectsOnlyTheListedTypesAndNotifies() throws Exception {
        Account admin = admin();
        Account hasan = pendingPro("Yıldız Elektrik");
        String path = "/admin/applications/" + hasan.id() + "/request-documents";
        String note = "Vergi levhası okunmuyor, yeniden yükleyin.";
        // Doğrulama: not, boş tür listesi, başvuruda olmayan tür.
        post(admin, path, Map.of("note", "kısa", "documentTypes", List.of("TAX"))).andExpect(status().isBadRequest());
        post(admin, path, Map.of("note", note, "documentTypes", List.of())).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("documentTypes"));
        post(admin, path, Map.of("note", note, "documentTypes", List.of("CRIMINAL_RECORD")))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("documentTypes"));
        post(admin, path, Map.of("note", note, "documentTypes", List.of("NOPE"))).andExpect(status().isBadRequest());
        assertThat(adminActions("REQUEST_DOCUMENTS", hasan.id())).isZero();
        assertThat(jdbc.queryForObject("select review_status from pro_profiles where user_id = ?::uuid", String.class,
                hasan.id())).isEqualTo("PENDING_REVIEW");

        JsonNode d = ok(post(admin, path, Map.of("note", note, "documentTypes", List.of("TAX", "TAX"))));
        assertThat(d.get("reviewStatus").asString()).isEqualTo("NEEDS_DOCUMENTS");
        assertThat(d.get("reviewNote").asString()).isEqualTo(note);
        for (JsonNode doc : d.get("documents")) {
            String expected = doc.get("type").asString().equals("TAX") ? "REJECTED" : "PENDING";
            assertThat(doc.get("status").asString()).isEqualTo(expected);
        }
        Map<String, Object> n = jdbc.queryForMap(
                "select params ->> 'note' as note, target_route from notifications where user_id = ?::uuid and type = 'PRO_NEEDS_DOCUMENTS'",
                hasan.id());
        assertThat(n.get("note")).isEqualTo(note);
        assertThat(n.get("target_route")).isEqualTo("/p/application");
        assertThat(adminActions("REQUEST_DOCUMENTS", hasan.id())).isEqualTo(1);

        // Usta kendi başvurusunda reddedilen belgeyi ve notu görür.
        JsonNode mine = body(call(HttpMethod.GET, "/api/v1/pro/application", hasan.access(), null)
                .andExpect(status().isOk()));
        assertThat(mine.get("reviewStatus").asString()).isEqualTo("NEEDS_DOCUMENTS");
        assertThat(mine.get("reviewNote").asString()).isEqualTo(note);
        // NEEDS_DOCUMENTS başvurusuna ikinci karar 409.
        post(admin, path, Map.of("note", note, "documentTypes", List.of("TAX"))).andExpect(status().isConflict());
        post(admin, "/admin/applications/" + hasan.id() + "/approve", Map.of()).andExpect(status().isConflict());
    }

    @Test
    void decisionsOnUnknownOrNonPendingApplicationsFail() throws Exception {
        Account admin = admin();
        post(admin, "/admin/applications/" + UUID.randomUUID() + "/approve", Map.of()).andExpect(status().isNotFound());
        Account approved = pro("Zaten Onaylı", List.of("plumbing"), List.of("Kadıköy"));
        post(admin, "/admin/applications/" + approved.id() + "/approve", Map.of()).andExpect(status().isConflict());
        post(admin, "/admin/applications/" + approved.id() + "/reject", Map.of("note", "Gerekçe yeterince uzun."))
                .andExpect(status().isConflict());
        post(admin, "/admin/applications/" + approved.id() + "/request-documents",
                Map.of("note", "Gerekçe yeterince uzun.", "documentTypes", List.of("TAX")))
                .andExpect(status().isConflict());
        assertThat(count("select count(*) from admin_actions")).isZero();
        assertThat(count("select count(*) from notifications where type like 'PRO\\_%'")).isZero();
    }
}
