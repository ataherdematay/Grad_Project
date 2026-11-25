package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** Hesap listesi / askı / yeniden etkinleştirme ve emanet defteri toplamları. */
class AdminAccountPaymentTest extends AdminTestBase {

    private static final String NOTE = "Kullanım şartlarını tekrar tekrar ihlal etti.";

    private JsonNode login(Account a) throws Exception {
        return body(call(HttpMethod.POST, "/api/v1/auth/login", null,
                Map.of("identifier", a.email(), "password", PASSWORD)));
    }

    // ─── Hesaplar ───────────────────────────────────────────────────────────

    @Test
    void userListFiltersByQueryRoleAndStatus() throws Exception {
        Account admin = admin();
        Account customer = register();
        Account pro = pro("Süzgeç Tesisat", List.of("plumbing"), List.of("Kadıköy"));
        jdbc.update("update users set status = 'SUSPENDED' where id = ?::uuid", register().id());

        JsonNode byEmail = ok(get(admin, "/admin/users?q=" + customer.email())).get("items");
        assertThat(byEmail).hasSize(1);
        JsonNode row = byEmail.get(0);
        assertThat(row.get("id").asString()).isEqualTo(customer.id());
        assertThat(row.get("email").asString()).isEqualTo(customer.email());
        assertThat(row.get("phone").asString()).startsWith("+90");
        assertThat(row.get("isAdmin").asBoolean()).isFalse();
        assertThat(row.get("status").asString()).isEqualTo("ACTIVE");
        assertThat(row.get("createdAt").asString()).isNotBlank();
        assertThat(row.get("pro").isNull()).isTrue();

        JsonNode byBusiness = ok(get(admin, "/admin/users?q=süzgeç")).get("items");
        assertThat(byBusiness).hasSize(1);
        assertThat(byBusiness.get(0).get("pro").get("businessName").asString()).isEqualTo("Süzgeç Tesisat");
        assertThat(byBusiness.get(0).get("pro").get("reviewStatus").asString()).isEqualTo("APPROVED");

        assertThat(ok(get(admin, "/admin/users?q=" + pro.email() + "&role=PRO")).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/users?q=" + pro.email() + "&role=CUSTOMER")).get("items")).isEmpty();
        assertThat(ok(get(admin, "/admin/users?q=" + customer.email() + "&role=CUSTOMER")).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/users?q=" + admin.email() + "&role=ADMIN")).get("items").get(0)
                .get("isAdmin").asBoolean()).isTrue();
        assertThat(ok(get(admin, "/admin/users?q=" + admin.email() + "&role=CUSTOMER")).get("items")).isEmpty();
        for (JsonNode u : ok(get(admin, "/admin/users?status=SUSPENDED")).get("items")) {
            assertThat(u.get("status").asString()).isEqualTo("SUSPENDED");
        }
        assertThat(ok(get(admin, "/admin/users?status=SUSPENDED")).get("items").size()).isGreaterThanOrEqualTo(1);
        // İlçe süzgeci: o ilçede adresi olan müşteri ve o ilçeye hizmet veren usta.
        Account kadikoyCustomer = register();
        addressId(kadikoyCustomer, "Kadıköy");
        Account besiktasCustomer = register();
        addressId(besiktasCustomer, "Beşiktaş");
        List<String> inKadikoy = new ArrayList<>();
        ok(get(admin, "/admin/users?district=" + districtId("Kadıköy"))).get("items")
                .forEach(u -> inKadikoy.add(u.get("id").asString()));
        assertThat(inKadikoy).contains(kadikoyCustomer.id(), pro.id()).doesNotContain(besiktasCustomer.id(),
                customer.id());
        assertThat(ok(get(admin, "/admin/users?district=" + districtId("Beşiktaş") + "&role=CUSTOMER&q="
                + besiktasCustomer.email())).get("items")).hasSize(1);
        get(admin, "/admin/users?district=abc").andExpect(status().isBadRequest());
        get(admin, "/admin/users?role=BOSS").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("role"));
        get(admin, "/admin/users?status=GONE").andExpect(status().isBadRequest());
    }

    @Test
    void suspendEndsEverySessionWithdrawsPendingOffersAndLeavesActiveJobsAlone() throws Exception {
        Account admin = admin();
        Setup s = openRequestWithOffer("900", "300");
        String jobId = payAndOpenJob(s); // usta ve müşteri için açık iş
        Account other = register();
        JsonNode otherRequest = createRequest(other, addressId(other, "Kadıköy"));
        String pending = sendOffer(s.pro(), otherRequest.get("id").asString(), offerBody("300", "0")).get("id").asString();
        JsonNode second = login(s.pro()); // ikinci oturum
        String secondRefresh = second.get("refreshToken").asString();

        JsonNode r = ok(post(admin, "/admin/users/" + s.pro().id() + "/suspend", Map.of("note", NOTE)));
        assertThat(r.get("id").asString()).isEqualTo(s.pro().id());
        assertThat(r.get("status").asString()).isEqualTo("SUSPENDED");
        assertThat(r.get("activeJobCount").asInt()).isEqualTo(1);
        assertThat(r.get("pro").get("reviewStatus").asString()).isEqualTo("APPROVED");

        // Tüm oturumlar kapandı: iki refresh de 401, mevcut access token 401, yeni giriş 401.
        for (String refresh : List.of(s.pro().refresh(), secondRefresh)) {
            call(HttpMethod.POST, "/api/v1/auth/refresh", null, Map.of("refreshToken", refresh))
                    .andExpect(status().isUnauthorized());
        }
        call(HttpMethod.GET, "/api/v1/me", s.pro().access(), null).andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("ACCOUNT_SUSPENDED"));
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", s.pro().email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());
        assertThat(count("select count(*) from refresh_tokens where user_id = ?::uuid and revoked_at is null",
                s.pro().id())).isZero();

        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, pending))
                .isEqualTo("WITHDRAWN");
        // Açık iş ve emanet olduğu gibi kaldı.
        assertThat(jobStatus(jobId)).isEqualTo("AWAITING_APPOINTMENT");
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");
        // Müşteri tarafı etkilenmez.
        call(HttpMethod.GET, "/api/v1/jobs/" + jobId, s.customer().access(), null).andExpect(status().isOk());

        assertThat(adminActions("SUSPEND_USER", s.pro().id())).isEqualTo(1);
        assertThat(jdbc.queryForObject("select note from admin_actions where target_id = ?", String.class, s.pro().id()))
                .isEqualTo(NOTE);
        // Listede askıda görünür.
        assertThat(ok(get(admin, "/admin/users?status=SUSPENDED&q=" + s.pro().email())).get("items")).hasSize(1);
    }

    @Test
    void suspendRejectsAdminsItselfRepeatsUnknownAndShortNotes() throws Exception {
        Account admin = admin();
        Account otherAdmin = admin();
        Account user = register();
        post(admin, "/admin/users/" + admin.id() + "/suspend", Map.of("note", NOTE)).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        post(admin, "/admin/users/" + otherAdmin.id() + "/suspend", Map.of("note", NOTE))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        assertThat(jdbc.queryForObject("select status from users where id = ?::uuid", String.class, admin.id()))
                .isEqualTo("ACTIVE");
        call(HttpMethod.GET, "/api/v1/me", admin.access(), null).andExpect(status().isOk());

        post(admin, "/admin/users/" + user.id() + "/suspend", Map.of("note", "kısa")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("note"));
        post(admin, "/admin/users/" + UUID.randomUUID() + "/suspend", Map.of("note", NOTE))
                .andExpect(status().isNotFound());
        ok(post(admin, "/admin/users/" + user.id() + "/suspend", Map.of("note", NOTE)));
        post(admin, "/admin/users/" + user.id() + "/suspend", Map.of("note", NOTE)).andExpect(status().isConflict());
        assertThat(adminActions("SUSPEND_USER", user.id())).isEqualTo(1);
        assertThat(adminActions("SUSPEND_USER", admin.id())).isZero();
    }

    @Test
    void reactivateRestoresLoginAndOnlyWorksOnSuspendedAccounts() throws Exception {
        Account admin = admin();
        Account user = register();
        post(admin, "/admin/users/" + user.id() + "/reactivate", null).andExpect(status().isConflict());
        ok(post(admin, "/admin/users/" + user.id() + "/suspend", Map.of("note", NOTE)));
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", user.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());

        JsonNode r = ok(post(admin, "/admin/users/" + user.id() + "/reactivate", null));
        assertThat(r.get("status").asString()).isEqualTo("ACTIVE");
        assertThat(r.has("activeJobCount")).isFalse();
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", user.email(), "password", PASSWORD))
                .andExpect(status().isOk());
        assertThat(adminActions("REACTIVATE_USER", user.id())).isEqualTo(1);
        post(admin, "/admin/users/" + user.id() + "/reactivate", null).andExpect(status().isConflict());
        post(admin, "/admin/users/" + UUID.randomUUID() + "/reactivate", null).andExpect(status().isNotFound());
        // Silinmiş hesap yeniden etkinleştirilemez.
        Account gone = register();
        jdbc.update("update users set status = 'DELETED' where id = ?::uuid", gone.id());
        post(admin, "/admin/users/" + gone.id() + "/reactivate", null).andExpect(status().isConflict());
        post(admin, "/admin/users/" + gone.id() + "/suspend", Map.of("note", NOTE)).andExpect(status().isConflict());
    }

    private String reviewStatus(Account a) {
        return jdbc.queryForObject("select review_status from pro_profiles where user_id = ?::uuid", String.class,
                a.id());
    }

    /** Lider kararı: reactivate, admin askısındaki usta profilini aynı işlemde APPROVED yapar ve denetlenir. */
    @Test
    void reactivateRestoresAnAdminSuspendedProProfileTogetherWithTheAccount() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        Account pro = d.s().pro();
        ok(decide(admin, d, "RELEASE_TO_PRO", false, true));
        assertThat(reviewStatus(pro)).isEqualTo("SUSPENDED");
        ok(post(admin, "/admin/users/" + pro.id() + "/suspend", Map.of("note", NOTE)));

        JsonNode r = ok(post(admin, "/admin/users/" + pro.id() + "/reactivate", null));
        assertThat(r.get("status").asString()).isEqualTo("ACTIVE");
        assertThat(r.get("pro").get("reviewStatus").asString()).isEqualTo("APPROVED");
        assertThat(reviewStatus(pro)).isEqualTo("APPROVED");
        assertThat(jdbc.queryForObject("select review_note from pro_profiles where user_id = ?::uuid", String.class,
                pro.id())).isNull();
        assertThat(adminActions("REACTIVATE_USER", pro.id())).isEqualTo(1);
        assertThat(adminActions("REACTIVATE_PRO", pro.id())).isEqualTo(1);
        assertThat(count("select count(*) from admin_actions where action = 'REACTIVATE_PRO' and target_type = "
                + "'PRO_PROFILE' and target_id = ? and admin_id = ?::uuid", pro.id(), admin.id())).isEqualTo(1);

        // Usta yeniden girip usta uç noktalarını kullanabilir.
        String access = login(pro).get("accessToken").asString();
        call(HttpMethod.GET, "/api/v1/pro/profile", access, null).andExpect(status().isOk());
        post(admin, "/admin/users/" + pro.id() + "/reactivate", null).andExpect(status().isConflict());
        assertThat(adminActions("REACTIVATE_PRO", pro.id())).isEqualTo(1);
    }

    @Test
    void reactivateRestoresAProfileSuspendedByAComplaintWhileTheAccountStayedActive() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        Account pro = d.s().pro();
        ok(decide(admin, d, "SPLIT_50_50", false, true));
        call(HttpMethod.GET, "/api/v1/pro/profile", pro.access(), null).andExpect(status().isForbidden());

        JsonNode r = ok(post(admin, "/admin/users/" + pro.id() + "/reactivate", null));
        assertThat(r.get("status").asString()).isEqualTo("ACTIVE");
        assertThat(reviewStatus(pro)).isEqualTo("APPROVED");
        assertThat(adminActions("REACTIVATE_USER", pro.id())).isZero();
        assertThat(adminActions("REACTIVATE_PRO", pro.id())).isEqualTo(1);
        call(HttpMethod.GET, "/api/v1/pro/profile", pro.access(), null).andExpect(status().isOk());
        // Başvuru geçmişinde görünür.
        assertThat(ok(get(admin, "/admin/applications/" + pro.id())).get("history").toString())
                .contains("REACTIVATE_PRO");
    }

    // ─── Emanet defteri ─────────────────────────────────────────────────────

    @Test
    void ledgerListsEscrowRowsAndTotalsMatchThePayoutLedger() throws Exception {
        Account admin = admin();
        // A: LOCKED 1200
        Setup a = openRequestWithOffer("900", "300");
        String refA = pay(a);
        // B: DISPUTED 500
        Disputed b = disputedJob("500", "0");
        // C: RELEASED_TO_PRO 1000 (komisyon 100, usta 900)
        Setup c = openRequestWithOffer("800", "200");
        String refC = pay(c);
        String jobC = jdbc.queryForObject("select job_id::text from escrow_payment where ref = ?", String.class, refC);
        schedule(c, jobC);
        startWork(c, jobC);
        finishWork(c, jobC);
        jobPost(c.customer(), jobC, "/confirm", null).andExpect(status().isOk());
        // D: REFUNDED_TO_CUSTOMER 700 (müşteri iptali)
        Setup dd = openRequestWithOffer("700", "0");
        String refD = pay(dd);
        String jobD = jdbc.queryForObject("select job_id::text from escrow_payment where ref = ?", String.class, refD);
        jobPost(dd.customer(), jobD, "/cancel", Map.of("reason", "PLANS_CHANGED")).andExpect(status().isOk());
        // E: SPLIT_SETTLED 1000 (admin kararı: 500 iade, 500 usta)
        Disputed e = disputedJob("1000", "0");
        ok(decide(admin, e, "SPLIT_50_50"));

        JsonNode ledger = ok(get(admin, "/admin/payments"));
        assertThat(ledger.get("items")).hasSize(5);
        JsonNode totals = ledger.get("totals");
        assertThat(totals.get("lockedTotal").asDouble()).isEqualTo(1700.0);
        assertThat(totals.get("releasedTotal").asDouble()).isEqualTo(1400.0);
        assertThat(totals.get("commissionTotal").asDouble()).isEqualTo(100.0);
        assertThat(totals.get("refundedTotal").asDouble()).isEqualTo(1200.0);
        // Toplamlar payout_ledger ile birebir tutar.
        assertThat(jdbc.queryForObject("select sum(amount) from payout_ledger where kind = 'PAYOUT'",
                java.math.BigDecimal.class)).isEqualByComparingTo("1400");
        assertThat(jdbc.queryForObject("select sum(amount) from payout_ledger where kind = 'COMMISSION'",
                java.math.BigDecimal.class)).isEqualByComparingTo("100");
        assertThat(jdbc.queryForObject("select sum(amount) from payout_ledger where kind = 'REFUND'",
                java.math.BigDecimal.class)).isEqualByComparingTo("1200");

        // En yeni önce; satır alanları.
        assertThat(ledger.get("items").get(0).get("ref").asString()).isEqualTo(e.ref());
        JsonNode rowA = null;
        for (JsonNode item : ledger.get("items")) {
            if (item.get("ref").asString().equals(refA)) {
                rowA = item;
            }
        }
        assertThat(rowA).isNotNull();
        assertThat(rowA.get("jobPublicCode").asString()).isEqualTo(a.publicCode());
        assertThat(rowA.get("status").asString()).isEqualTo("LOCKED");
        assertThat(rowA.get("provider").asString()).isEqualTo("CRAFTGATE");
        assertThat(rowA.get("totalAmount").asDouble()).isEqualTo(1200.0);
        assertThat(rowA.get("commission").asDouble()).isEqualTo(120.0);
        assertThat(rowA.get("proPayout").asDouble()).isEqualTo(1080.0);
        assertThat(rowA.get("refundedAmount").asDouble()).isZero();
        assertThat(rowA.get("customerName").asString()).isEqualTo("Test Kullanıcı");
        assertThat(rowA.get("proBusinessName").asString()).startsWith("Test Usta");
        assertThat(rowA.get("createdAt").asString()).isNotBlank();
        assertThat(rowA.get("lockedAt").asString()).isNotBlank();
        assertThat(rowA.get("releasedAt").isNull()).isTrue();
        assertThat(rowA.get("refundedAt").isNull()).isTrue();
        assertThat(rowA.get("errorCode").isNull()).isTrue();

        // Durum süzgeci toplamları da daraltır.
        JsonNode locked = ok(get(admin, "/admin/payments?status=LOCKED"));
        assertThat(locked.get("items")).hasSize(1);
        assertThat(locked.get("totals").get("lockedTotal").asDouble()).isEqualTo(1200.0);
        assertThat(locked.get("totals").get("refundedTotal").asDouble()).isZero();
        JsonNode refunded = ok(get(admin, "/admin/payments?status=REFUNDED_TO_CUSTOMER"));
        assertThat(refunded.get("items")).hasSize(1);
        assertThat(refunded.get("items").get(0).get("refundedAt").isNull()).isFalse();
        assertThat(refunded.get("totals").get("refundedTotal").asDouble()).isEqualTo(700.0);
        JsonNode released = ok(get(admin, "/admin/payments?status=RELEASED_TO_PRO"));
        assertThat(released.get("items").get(0).get("releasedAt").isNull()).isFalse();
        assertThat(released.get("totals").get("commissionTotal").asDouble()).isEqualTo(100.0);
        get(admin, "/admin/payments?status=NOPE").andExpect(status().isBadRequest());
        assertThat(refC).isNotEqualTo(refD);
        assertThat(b.ref()).isNotNull();
    }

    @Test
    void emptyLedgerHasZeroTotals() throws Exception {
        Account admin = admin();
        JsonNode ledger = ok(get(admin, "/admin/payments"));
        assertThat(ledger.get("items")).isEmpty();
        for (String key : List.of("lockedTotal", "releasedTotal", "commissionTotal", "refundedTotal")) {
            assertThat(ledger.get("totals").get(key).asDouble()).isZero();
        }
    }
}
