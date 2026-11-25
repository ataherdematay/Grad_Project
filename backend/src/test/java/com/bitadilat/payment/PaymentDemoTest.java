package com.bitadilat.payment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.admin.AdminTestBase;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import tools.jackson.databind.JsonNode;

/**
 * Ödeme demosu uç noktaları: zaman çizelgesi, makbuz, müşteri ödeme geçmişi ve admin kasa özeti. Craftgate sahte,
 * veritabanı gerçek PostgreSQL.
 */
class PaymentDemoTest extends AdminTestBase {

    private static List<String> types(JsonNode timeline) {
        List<String> out = new ArrayList<>();
        timeline.get("events").forEach(e -> out.add(e.get("type").asString()));
        return out;
    }

    private JsonNode timeline(Account who, String jobId) throws Exception {
        return ok(get(who, "/jobs/" + jobId + "/payment/timeline"));
    }

    /** Ödenmiş, randevulu, teslim edilmiş iş. */
    private String deliveredJob(Setup s) throws Exception {
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        return jobId;
    }

    // ─── Zaman çizelgesi ────────────────────────────────────────────────────

    @Test
    void timelineFollowsThePaymentFromVaultToPro() throws Exception {
        Setup s = openRequestWithOffer(); // 900 + 300 = 1200, komisyon 120, net 1080
        String jobId = deliveredJob(s);

        JsonNode t = timeline(s.customer(), jobId);
        assertThat(t.get("status").asString()).isEqualTo("LOCKED");
        assertThat(t.get("moneyLocation").asString()).isEqualTo("BITADILAT_VAULT");
        assertThat(t.get("provider").asString()).isEqualTo("CRAFTGATE");
        assertThat(t.get("sandbox").asBoolean()).isTrue();
        assertThat(t.get("craftgatePaymentId").asLong()).isGreaterThan(0);
        assertThat(types(t)).containsExactly("PAYMENT_INITIALIZED", "THREEDS_STARTED", "PAYMENT_LOCKED",
                "WORK_DELIVERED", "AUTO_RELEASE_SCHEDULED");
        assertThat(t.get("autoReleaseAt").isNull()).isFalse();
        // Kart yalnızca maskeli: marka ve son 4 hane.
        assertThat(t.get("card").get("brand").asString()).isEqualTo("MASTERCARD");
        assertThat(t.get("card").get("last4").asString()).isEqualTo("0001");
        assertThat(t.get("card").get("masked").asString()).isEqualTo("**** **** **** 0001");
        assertThat(t.toString()).doesNotContain("5258640000000001").doesNotContain("987");
        // Müşteri komisyonu ve usta payını görmez.
        assertThat(t.get("amounts").get("gross").asDouble()).isEqualTo(1200.0);
        assertThat(t.get("amounts").get("commission").isNull()).isTrue();
        assertThat(t.get("amounts").get("proNet").isNull()).isTrue();
        assertThat(t.get("amounts").get("refunded").asDouble()).isZero();
        // Olaylar zaman sırasında.
        List<String> ats = new ArrayList<>();
        t.get("events").forEach(e -> ats.add(e.get("at").asString()));
        assertThat(ats).isSorted();

        for (JsonNode e : t.get("events")) {
            if (e.get("type").asString().equals("AUTO_RELEASE_SCHEDULED")) {
                assertThat(e.get("amount").isNull()).isTrue();
                assertThat(e.get("note").asString()).startsWith("autoReleaseAt=");
            }
        }
        JsonNode proView = timeline(s.pro(), jobId);
        assertThat(proView.get("amounts").get("commission").asDouble()).isEqualTo(120.0);
        assertThat(proView.get("amounts").get("proNet").asDouble()).isEqualTo(1080.0);
        assertThat(proView.get("card").isNull()).isTrue(); // usta kart bilgisi görmez
        JsonNode adminView = timeline(admin(), jobId);
        assertThat(adminView.get("amounts").get("commission").asDouble()).isEqualTo(120.0);
        assertThat(adminView.get("card").get("last4").asString()).isEqualTo("0001");

        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk());
        JsonNode done = timeline(s.customer(), jobId);
        assertThat(done.get("status").asString()).isEqualTo("RELEASED_TO_PRO");
        assertThat(done.get("moneyLocation").asString()).isEqualTo("PRO");
        assertThat(done.get("autoReleaseAt").isNull()).isTrue();
        assertThat(types(done)).containsExactly("PAYMENT_INITIALIZED", "THREEDS_STARTED", "PAYMENT_LOCKED",
                "WORK_DELIVERED", "AUTO_RELEASE_SCHEDULED", "CUSTOMER_APPROVED", "RELEASED_TO_PRO");
        for (JsonNode e : done.get("events")) {
            if (e.get("type").asString().equals("RELEASED_TO_PRO")) {
                assertThat(e.get("amount").isNull()).isTrue(); // müşteri usta payını görmez
            }
        }
        JsonNode proDone = timeline(s.pro(), jobId);
        for (JsonNode e : proDone.get("events")) {
            if (e.get("type").asString().equals("RELEASED_TO_PRO")) {
                assertThat(e.get("amount").asDouble()).isEqualTo(1080.0);
                assertThat(e.get("actor").asString()).isEqualTo("SYSTEM");
            }
            if (e.get("type").asString().equals("CUSTOMER_APPROVED")) {
                assertThat(e.get("actor").asString()).isEqualTo("CUSTOMER");
            }
        }
    }

    @Test
    void timelineIsLimitedToParticipantsAndAdmins() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        Account stranger = register();
        get(stranger, "/jobs/" + jobId + "/payment/timeline").andExpect(status().isNotFound());
        get(s.customer(), "/jobs/" + java.util.UUID.randomUUID() + "/payment/timeline").andExpect(status().isNotFound());
        // İş var ama ödeme kaydı yok (ör. temizlenmiş): 404, sahte boş çizelge yok.
        jdbc.update("update escrow_payment set job_id = null where job_id = ?::uuid", jobId);
        get(s.customer(), "/jobs/" + jobId + "/payment/timeline").andExpect(status().isNotFound());
    }

    @Test
    void seedProviderIsLabelledAndFallsBackToRowTimestamps() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        jdbc.update("update escrow_payment set provider = 'SEED' where job_id = ?::uuid", jobId);
        jdbc.update("delete from escrow_event");
        JsonNode t = timeline(s.customer(), jobId);
        assertThat(t.get("provider").asString()).isEqualTo("SEED");
        assertThat(t.get("sandbox").asBoolean()).isTrue();
        // Olay kaydı olmayan (eski/seed) ödemede olaylar emanet satırından türetilir.
        assertThat(types(t)).containsExactly("PAYMENT_INITIALIZED", "THREEDS_STARTED", "PAYMENT_LOCKED");
    }

    @Test
    void cancelRefundShowsRequestAndRefund() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());
        JsonNode t = timeline(s.customer(), jobId);
        assertThat(t.get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(t.get("moneyLocation").asString()).isEqualTo("CUSTOMER_REFUNDED");
        assertThat(types(t)).containsSubsequence("PAYMENT_LOCKED", "REFUND_REQUESTED", "REFUNDED");
        assertThat(t.get("amounts").get("refunded").asDouble()).isEqualTo(1200.0);
        assertThat(t.get("autoReleaseAt").isNull()).isTrue();
    }

    @Test
    void refundRequestedRecordsWhoCancelled() throws Exception {
        // Denetim: REFUND_REQUESTED eskiden usta iptal etse bile actor=CUSTOMER yazıyordu.
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        jobPost(s.pro(), jobId, "/cancel", Map.of("reason", "CANNOT_DO_JOB")).andExpect(status().isOk());
        JsonNode t = timeline(admin(), jobId);
        String actor = null;
        for (JsonNode e : t.get("events")) {
            if (e.get("type").asString().equals("REFUND_REQUESTED")) {
                actor = e.get("actor").asString();
            }
        }
        assertThat(actor).isEqualTo("PRO");
        assertThat(jdbc.queryForObject("select count(*) from escrow_event where type = 'REFUND_REQUESTED' "
                + "and actor_role = 'PRO' and payment_ref = ?", Long.class, t.get("paymentRef").asString()))
                .isEqualTo(1L);
    }

    @Test
    void adminFullRefundDecisionIsRecordedAsAdmin() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        decide(admin, d, "FULL_REFUND").andExpect(status().isOk());
        assertThat(jdbc.queryForObject("select count(*) from escrow_event where type = 'REFUNDED' "
                + "and actor_role = 'ADMIN' and payment_ref = ?", Long.class, d.ref())).isEqualTo(1L);
        assertThat(jdbc.queryForObject("select count(*) from escrow_event where type = 'REFUNDED' "
                + "and actor_role = 'SYSTEM' and payment_ref = ?", Long.class, d.ref())).isZero();
    }

    @Test
    void disputeAndSplitSettlementAreShown() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        JsonNode open = timeline(d.s().customer(), d.jobId());
        assertThat(open.get("status").asString()).isEqualTo("DISPUTED");
        assertThat(open.get("moneyLocation").asString()).isEqualTo("BITADILAT_VAULT");
        assertThat(types(open)).contains("DISPUTE_OPENED");

        decide(admin, d, "SPLIT_50_50").andExpect(status().isOk());
        JsonNode t = timeline(d.s().customer(), d.jobId());
        assertThat(t.get("status").asString()).isEqualTo("SPLIT_SETTLED");
        assertThat(t.get("moneyLocation").asString()).isEqualTo("SPLIT");
        assertThat(types(t)).containsSubsequence("PAYMENT_LOCKED", "DISPUTE_OPENED", "SPLIT_SETTLED");
        assertThat(t.get("amounts").get("refunded").asDouble()).isEqualTo(600.0);
        // Aynı DTO admin ref uç noktasında.
        JsonNode byRef = ok(get(admin, "/admin/payments/" + d.ref() + "/timeline"));
        assertThat(byRef.get("paymentRef").asString()).isEqualTo(d.ref());
        assertThat(types(byRef)).isEqualTo(types(t));
        assertThat(byRef.get("amounts").get("proNet").asDouble()).isEqualTo(600.0);
    }

    // ─── Makbuz ─────────────────────────────────────────────────────────────

    @Test
    void receiptIsForTheCustomerAndAdminOnly() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        JsonNode r = ok(get(s.customer(), "/jobs/" + jobId + "/payment/receipt"));
        assertThat(r.get("receiptNo").asString()).matches("BT-\\d{8}-[0-9A-F]{6}");
        assertThat(r.get("jobPublicCode").asString()).isEqualTo(s.publicCode());
        assertThat(r.get("jobTitle").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(r.get("proName").asString()).startsWith("Test Usta");
        assertThat(r.get("total").asDouble()).isEqualTo(1200.0);
        assertThat(r.get("currency").asString()).isEqualTo("TRY");
        double sum = 0;
        for (JsonNode i : r.get("items")) {
            sum += i.get("amount").asDouble();
        }
        assertThat(sum).isEqualTo(1200.0);
        assertThat(r.get("items").size()).isGreaterThanOrEqualTo(2);
        assertThat(r.get("card").get("masked").asString()).isEqualTo("**** **** **** 0001");
        assertThat(r.get("status").asString()).isEqualTo("LOCKED");
        assertThat(r.get("sandbox").asBoolean()).isTrue();
        assertThat(r.get("sandboxNotice").asString()).contains("sandbox");
        assertThat(r.has("commission")).isFalse(); // müşteri makbuzunda hizmet bedeli kırılımı yok

        ok(get(admin(), "/jobs/" + jobId + "/payment/receipt"));
        get(s.pro(), "/jobs/" + jobId + "/payment/receipt").andExpect(status().isForbidden());
        get(register(), "/jobs/" + jobId + "/payment/receipt").andExpect(status().isNotFound());
    }

    @Test
    void receiptShowsRefundAfterCancellation() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());
        JsonNode r = ok(get(s.customer(), "/jobs/" + jobId + "/payment/receipt"));
        assertThat(r.get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(r.get("refundedTotal").asDouble()).isEqualTo(1200.0);
        assertThat(r.get("netPaid").asDouble()).isZero();
    }

    // ─── Müşteri ödeme geçmişi ──────────────────────────────────────────────

    @Test
    void myPaymentsListsOnlyMyPaidPaymentsNewestFirstWithPaging() throws Exception {
        Setup first = openRequestWithOffer();
        String job1 = payAndOpenJob(first);
        Setup other = openRequestWithOffer("100", "50"); // başka müşteri
        payAndOpenJob(other);

        // Aynı müşteri ikinci talep + ödeme.
        String address = addressId(first.customer(), "Kadıköy");
        JsonNode request2 = createRequest(first.customer(), address);
        String offer2 = sendOffer(first.pro(), request2.get("id").asString(), offerBody("500", "100"))
                .get("id").asString();
        String ref2 = initPayment(first.customer(), offer2);
        callback(ref2);
        // Bu müşterinin başarısız/yarım denemesi geçmişte görünmez.
        initPayment(first.customer(), sendOffer(first.pro(), createRequest(first.customer(), address).get("id").asString(),
                offerBody("10", "10")).get("id").asString());

        JsonNode all = ok(get(first.customer(), "/me/payments"));
        assertThat(all.get("items").size()).isEqualTo(2);
        assertThat(all.get("nextCursor").isNull()).isTrue();
        JsonNode newest = all.get("items").get(0);
        assertThat(newest.get("ref").asString()).isEqualTo(ref2);
        assertThat(newest.get("totalAmount").asDouble()).isEqualTo(600.0);
        assertThat(newest.get("status").asString()).isEqualTo("LOCKED");
        assertThat(newest.get("moneyLocation").asString()).isEqualTo("BITADILAT_VAULT");
        assertThat(newest.get("jobPublicCode").asString()).startsWith("BD-");
        assertThat(newest.get("jobTitle").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(newest.get("paidAt").isNull()).isFalse();
        assertThat(all.get("items").get(1).get("jobId").asString()).isEqualTo(job1);

        JsonNode page1 = ok(get(first.customer(), "/me/payments?limit=1"));
        assertThat(page1.get("items").size()).isEqualTo(1);
        assertThat(page1.get("nextCursor").asString()).isEqualTo("1");
        JsonNode page2 = ok(get(first.customer(), "/me/payments?limit=1&cursor=" + page1.get("nextCursor").asString()));
        assertThat(page2.get("items").get(0).get("jobId").asString()).isEqualTo(job1);
        assertThat(page2.get("nextCursor").isNull()).isTrue();

        get(first.customer(), "/me/payments?limit=0").andExpect(status().isBadRequest());
        get(first.customer(), "/me/payments?cursor=-1").andExpect(status().isBadRequest());
        get(first.customer(), "/me/payments?cursor=abc").andExpect(status().isBadRequest());
        JsonNode past = ok(get(first.customer(), "/me/payments?cursor=99"));
        assertThat(past.get("items").size()).isZero();
        assertThat(past.get("nextCursor").isNull()).isTrue();
        // limit üst sınırı 50: daha büyük istek 400 değil, 50'ye kırpılır.
        assertThat(ok(get(first.customer(), "/me/payments?limit=500")).get("items").size()).isEqualTo(2);
        // Ödemesi olmayan müşteri: boş liste, 404 değil.
        JsonNode none = ok(get(register(), "/me/payments"));
        assertThat(none.get("items").size()).isZero();
    }

    // ─── Admin kasa özeti ───────────────────────────────────────────────────

    @Test
    void adminSummaryTotalsTheVaultPayoutsRefundsAndCommission() throws Exception {
        Account admin = admin();
        JsonNode empty = ok(get(admin, "/admin/payments/summary"));
        assertThat(empty.get("vaultTotal").asDouble()).isZero();
        assertThat(empty.get("counts").get("total").asInt()).isZero();

        Setup released = openRequestWithOffer(); // 1200: komisyon 120, usta 1080
        String j1 = deliveredJob(released);
        jobPost(released.customer(), j1, "/confirm", null).andExpect(status().isOk());
        Setup refunded = openRequestWithOffer("500", "100"); // 600 iade
        String j2 = payAndOpenJob(refunded);
        schedule(refunded, j2);
        jobPost(refunded.customer(), j2, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());
        Setup vault = openRequestWithOffer("300", "100"); // 400 kasada
        payAndOpenJob(vault);

        JsonNode sum = ok(get(admin, "/admin/payments/summary"));
        assertThat(sum.get("vaultTotal").asDouble()).isEqualTo(400.0);
        assertThat(sum.get("paidToProsTotal").asDouble()).isEqualTo(1080.0);
        assertThat(sum.get("refundedToCustomersTotal").asDouble()).isEqualTo(600.0);
        assertThat(sum.get("commissionEarnedTotal").asDouble()).isEqualTo(120.0);
        JsonNode counts = sum.get("counts");
        assertThat(counts.get("total").asInt()).isEqualTo(3);
        assertThat(counts.get("vault").asInt()).isEqualTo(1);
        assertThat(counts.get("locked").asInt()).isEqualTo(1);
        assertThat(counts.get("released").asInt()).isEqualTo(1);
        assertThat(counts.get("refunded").asInt()).isEqualTo(1);
        assertThat(sum.get("generatedAt").asString()).isNotBlank();

        get(released.customer(), "/admin/payments/summary").andExpect(status().isForbidden());
        get(admin, "/admin/payments/" + java.util.UUID.randomUUID() + "/timeline").andExpect(status().isNotFound());
        get(released.customer(), "/admin/payments/x/timeline").andExpect(status().isForbidden());
    }

    @Test
    void unauthenticatedCallersAreRejected() throws Exception {
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                .get("/api/v1/jobs/" + java.util.UUID.randomUUID() + "/payment/timeline"))
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").exists());
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get("/api/v1/me/payments"))
                .andExpect(status().isUnauthorized());
    }
}
