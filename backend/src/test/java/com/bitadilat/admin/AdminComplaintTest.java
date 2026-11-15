package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.payment.exception.GatewayException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** Şikayet kuyruğu, inceleme ve üç karar türünün para / iş / talep / şikayet sonuçları. */
class AdminComplaintTest extends AdminTestBase {

    private long cgPaymentId(Disputed d) {
        return jdbc.queryForObject("select craftgate_payment_id from escrow_payment where ref = ?", Long.class, d.ref());
    }

    private String conversationId(Disputed d) {
        return jdbc.queryForObject("select conversation_id from escrow_payment where ref = ?", String.class, d.ref());
    }

    private String requestStatus(Disputed d) {
        return jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                d.s().requestId());
    }

    private String complaintStatus(Disputed d) {
        return jdbc.queryForObject("select status from complaints where id = ?::uuid", String.class, d.complaintId());
    }

    private Map<String, Object> decidedNotification(Account user) {
        return jdbc.queryForMap("""
                select params ->> 'complaintCode' as code, params ->> 'decision' as decision,
                       params ->> 'amount' as amount, target_route
                from notifications where user_id = ?::uuid and type = 'COMPLAINT_DECIDED'""", user.id());
    }

    // ─── Kuyruk, ayrıntı, inceleme ──────────────────────────────────────────

    @Test
    void queueListsOpenAndInReviewOldestFirstWithRealAmounts() throws Exception {
        Account admin = admin();
        Disputed first = disputedJob("900", "300");
        Disputed second = disputedJob("500", "0");
        JsonNode items = ok(get(admin, "/admin/complaints")).get("items");
        assertThat(items).hasSize(2);
        JsonNode row = items.get(0);
        assertThat(row.get("id").asString()).isEqualTo(first.complaintId());
        assertThat(items.get(1).get("id").asString()).isEqualTo(second.complaintId());
        assertThat(row.get("publicCode").asString()).isEqualTo(first.complaintCode());
        assertThat(row.get("jobId").asString()).isEqualTo(first.jobId());
        assertThat(row.get("jobPublicCode").asString()).isEqualTo(first.s().publicCode());
        assertThat(row.get("reason").asString()).isEqualTo("EXTRA_CHARGE");
        assertThat(row.get("status").asString()).isEqualTo("OPEN");
        assertThat(row.get("customerName").asString()).isEqualTo("Test Kullanıcı");
        assertThat(row.get("proBusinessName").asString()).startsWith("Test Usta");
        assertThat(row.get("amount").asDouble()).isEqualTo(1200.0);
        assertThat(items.get(1).get("amount").asDouble()).isEqualTo(500.0);

        ok(post(admin, "/admin/complaints/" + first.complaintId() + "/review", null));
        assertThat(ok(get(admin, "/admin/complaints")).get("items")).hasSize(2); // IN_REVIEW de varsayılanda
        assertThat(ok(get(admin, "/admin/complaints?status=OPEN")).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/complaints?status=IN_REVIEW")).get("items").get(0).get("id").asString())
                .isEqualTo(first.complaintId());
        assertThat(ok(get(admin, "/admin/complaints?status=RESOLVED")).get("items")).isEmpty();
        get(admin, "/admin/complaints?status=NOPE").andExpect(status().isBadRequest());

        ok(decide(admin, first, "RELEASE_TO_PRO"));
        assertThat(ok(get(admin, "/admin/complaints")).get("items")).hasSize(1);
        assertThat(ok(get(admin, "/admin/complaints?status=DISMISSED")).get("items")).hasSize(1);
    }

    @Test
    void detailCarriesJobTimelinePaymentChatPartiesAndEvidence() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        call(HttpMethod.POST, "/api/v1/jobs/" + d.jobId() + "/messages", d.s().customer().access(),
                Map.of("body", "Usta bey ek ücret istiyor.")).andExpect(status().isCreated());
        call(HttpMethod.POST, "/api/v1/jobs/" + d.jobId() + "/messages", d.s().pro().access(),
                Map.of("body", "Parça farkı var.")).andExpect(status().isCreated());

        JsonNode c = ok(get(admin, "/admin/complaints/" + d.complaintId()));
        assertThat(c.get("id").asString()).isEqualTo(d.complaintId());
        assertThat(c.get("publicCode").asString()).isEqualTo(d.complaintCode());
        assertThat(c.get("status").asString()).isEqualTo("OPEN");
        assertThat(c.get("description").asString()).contains("Teklif dışı");
        assertThat(c.get("decision").isNull()).isTrue();
        assertThat(c.get("warnPro").asBoolean()).isFalse();
        assertThat(c.get("suspendPro").asBoolean()).isFalse();
        assertThat(c.get("evidence")).isEmpty();

        JsonNode job = c.get("job");
        assertThat(job.get("id").asString()).isEqualTo(d.jobId());
        assertThat(job.get("publicCode").asString()).isEqualTo(d.s().publicCode());
        assertThat(job.get("title").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(job.get("status").asString()).isEqualTo("DISPUTED");
        assertThat(job.get("statusBeforeDispute").asString()).isEqualTo("IN_PROGRESS");
        assertThat(job.get("districtName").asString()).isEqualTo("Kadıköy");
        assertThat(job.get("timeline").size()).isGreaterThanOrEqualTo(5);
        assertThat(job.get("offer").get("status").asString()).isEqualTo("ACCEPTED");
        assertThat(job.get("offer").get("serviceFee").asDouble()).isEqualTo(120.0); // admin her şeyi görür

        JsonNode payment = c.get("payment");
        assertThat(payment.get("ref").asString()).isEqualTo(d.ref());
        assertThat(payment.get("status").asString()).isEqualTo("DISPUTED");
        assertThat(payment.get("provider").asString()).isEqualTo("CRAFTGATE");
        assertThat(payment.get("totalAmount").asDouble()).isEqualTo(1200.0);
        assertThat(payment.get("commission").asDouble()).isEqualTo(120.0);
        assertThat(payment.get("proPayout").asDouble()).isEqualTo(1080.0);
        assertThat(payment.get("refundedAmount").asDouble()).isZero();

        JsonNode messages = c.get("messages");
        assertThat(messages).hasSize(2);
        assertThat(messages.get(0).get("senderRole").asString()).isEqualTo("CUSTOMER");
        assertThat(messages.get(0).get("body").asString()).isEqualTo("Usta bey ek ücret istiyor.");
        assertThat(messages.get(1).get("senderRole").asString()).isEqualTo("PRO");
        assertThat(messages.get(1).get("photo").isNull()).isTrue();

        assertThat(c.get("customer").get("id").asString()).isEqualTo(d.s().customer().id());
        assertThat(c.get("customer").get("fullName").asString()).isEqualTo("Test Kullanıcı");
        JsonNode pro = c.get("pro");
        assertThat(pro.get("id").asString()).isEqualTo(d.s().pro().id());
        assertThat(pro.get("businessName").asString()).startsWith("Test Usta");
        assertThat(pro.get("warningCount").asInt()).isZero();
        assertThat(pro.get("cancellationCount").asInt()).isZero();
        get(admin, "/admin/complaints/" + UUID.randomUUID()).andExpect(status().isNotFound());
    }

    @Test
    void evidenceIsOpenableByAdminThroughSignedUrls() throws Exception {
        Account admin = admin();
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        String evidence = upload(s.customer(), jpeg(30, 30), "COMPLAINT").get("id").asString();
        JsonNode created = body(jobPost(s.customer(), jobId, "/complaint", Map.of("reason", "NO_SHOW",
                "description", "Usta belirtilen saatte gelmedi ve aramalara dönmedi.",
                "evidenceIds", List.of(evidence))).andExpect(status().isCreated()));
        JsonNode c = ok(get(admin, "/admin/complaints/" + created.get("id").asString()));
        String url = c.get("evidence").get(0).get("url").asString();
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get(
                url.substring(url.indexOf("/api/v1/media/")))).andExpect(status().isOk());
    }

    @Test
    void reviewMovesOpenToInReviewOnceAndIsAudited() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        JsonNode r = ok(post(admin, "/admin/complaints/" + d.complaintId() + "/review", null));
        assertThat(r.get("status").asString()).isEqualTo("IN_REVIEW");
        assertThat(adminActions("REVIEW_COMPLAINT", d.complaintId())).isEqualTo(1);
        post(admin, "/admin/complaints/" + d.complaintId() + "/review", null).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        assertThat(adminActions("REVIEW_COMPLAINT", d.complaintId())).isEqualTo(1);
        post(admin, "/admin/complaints/" + UUID.randomUUID() + "/review", null).andExpect(status().isNotFound());
        // IN_REVIEW şikayet karara bağlanabilir; karardan sonra inceleme yok.
        ok(decide(admin, d, "FULL_REFUND"));
        post(admin, "/admin/complaints/" + d.complaintId() + "/review", null).andExpect(status().isConflict());
    }

    // ─── Üç karar ───────────────────────────────────────────────────────────

    @Test
    void fullRefundRefundsThroughGatewayCancelsJobAndRequestAndWritesLedger() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob("900", "300");
        long paymentId = cgPaymentId(d);
        JsonNode c = ok(decide(admin, d, "FULL_REFUND"));

        assertThat(c.get("status").asString()).isEqualTo("RESOLVED");
        assertThat(c.get("decision").asString()).isEqualTo("FULL_REFUND");
        assertAmounts(c, d, "1200.00", "0.00");
        assertThat(c.get("decisionNote").asString()).contains("incelendi");
        assertThat(c.get("decidedAt").isNull()).isFalse();
        assertThat(c.get("job").get("status").asString()).isEqualTo("CANCELLED");
        assertThat(c.get("payment").get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(c.get("payment").get("refundedAmount").asDouble()).isEqualTo(1200.0);

        assertThat(escrowStatus(d.jobId())).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(jobStatus(d.jobId())).isEqualTo("CANCELLED");
        assertThat(requestStatus(d)).isEqualTo("CANCELLED");
        assertThat(complaintStatus(d)).isEqualTo("RESOLVED");
        assertThat(jdbc.queryForObject("select cancelled_by from jobs where id = ?::uuid", String.class, d.jobId()))
                .isEqualTo("ADMIN");
        assertThat(jdbc.queryForObject("select decided_by::text from complaints where id = ?::uuid", String.class,
                d.complaintId())).isEqualTo(admin.id());
        assertThat(jdbc.queryForObject("select actor_role from job_events where job_id = ?::uuid "
                + "and to_status = 'CANCELLED'", String.class, d.jobId())).isEqualTo("ADMIN");

        // Gateway: tam iade tam bir kez, doğru ödeme ve konuşma kimliğiyle; kısmi iade yok.
        verify(gateway, times(1)).refundFully(paymentId, conversationId(d));
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
        // Defter: yalnız müşteri iadesi, komisyon yok.
        assertThat(ledgerRows(d.ref())).isEqualTo(1);
        assertThat(ledger(d.ref(), "REFUND")).isEqualByComparingTo("1200.00");
        assertThat(jdbc.queryForObject("select commission from escrow_payment where ref = ?", BigDecimal.class,
                d.ref())).isEqualByComparingTo("0");

        // Bildirimler: müşteriye iade tutarı, ustaya 0.
        Map<String, Object> toCustomer = decidedNotification(d.s().customer());
        assertThat(toCustomer.get("code")).isEqualTo(d.complaintCode());
        assertThat(toCustomer.get("decision")).isEqualTo("FULL_REFUND");
        assertThat(toCustomer.get("amount")).isEqualTo("1200.00");
        assertThat(toCustomer.get("target_route")).isEqualTo("/c/complaints/" + d.complaintId());
        Map<String, Object> toPro = decidedNotification(d.s().pro());
        assertThat(toPro.get("amount")).isEqualTo("0.00");
        assertThat(toPro.get("target_route")).isEqualTo("/p/jobs/" + d.jobId());

        assertThat(adminActions("DECIDE_COMPLAINT", d.complaintId())).isEqualTo(1);
        // Karar sonrası ödeme defteri ve iş yeniden açılamaz.
        jobPost(d.s().customer(), d.jobId(), "/cancel", Map.of("reason", "OTHER")).andExpect(status().isConflict());
    }

    @Test
    void split5050RefundsHalfThroughGatewayAndPaysTheProTheOtherHalf() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob("801.01", "0"); // tek kuruşluk fark: 400.51 / 400.50
        long paymentId = cgPaymentId(d);
        JsonNode c = ok(decide(admin, d, "SPLIT_50_50"));

        assertThat(c.get("status").asString()).isEqualTo("RESOLVED");
        assertThat(c.get("decision").asString()).isEqualTo("SPLIT_50_50");
        assertAmounts(c, d, "400.51", "400.50");
        assertThat(c.get("job").get("status").asString()).isEqualTo("RESOLVED");
        assertThat(c.get("payment").get("status").asString()).isEqualTo("SPLIT_SETTLED");
        assertThat(c.get("payment").get("refundedAmount").asDouble()).isEqualTo(400.51);
        assertThat(c.get("payment").get("proPayout").asDouble()).isEqualTo(400.50);
        assertThat(c.get("payment").get("commission").asDouble()).isZero();

        assertThat(escrowStatus(d.jobId())).isEqualTo("SPLIT_SETTLED");
        assertThat(jobStatus(d.jobId())).isEqualTo("RESOLVED");
        assertThat(requestStatus(d)).isEqualTo("ASSIGNED");
        assertThat(complaintStatus(d)).isEqualTo("RESOLVED");

        verify(gateway, times(1)).refundPartially(eq(paymentId), eq(new BigDecimal("400.51")), eq(conversationId(d)));
        verify(gateway, never()).refundFully(anyLong(), anyString());
        assertThat(ledger(d.ref(), "REFUND")).isEqualByComparingTo("400.51");
        assertThat(ledger(d.ref(), "PAYOUT")).isEqualByComparingTo("400.50");
        assertThat(ledger(d.ref(), "COMMISSION")).isEqualByComparingTo("0");
        assertThat(ledgerRows(d.ref())).isEqualTo(2);

        assertThat(decidedNotification(d.s().customer()).get("amount")).isEqualTo("400.51");
        assertThat(decidedNotification(d.s().pro()).get("amount")).isEqualTo("400.50");
        assertThat(decidedNotification(d.s().customer()).get("decision")).isEqualTo("SPLIT_50_50");
        assertThat(adminActions("DECIDE_COMPLAINT", d.complaintId())).isEqualTo(1);
    }

    @Test
    void releaseToProDismissesComplaintCompletesJobKeepsTenPercentAndNeverTouchesGatewayRefunds() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob("900", "300");
        int completedBefore = jdbc.queryForObject("select completed_jobs from pro_profiles where user_id = ?::uuid",
                Integer.class, d.s().pro().id());
        JsonNode c = ok(decide(admin, d, "RELEASE_TO_PRO"));

        assertThat(c.get("status").asString()).isEqualTo("DISMISSED");
        assertThat(c.get("decision").asString()).isEqualTo("RELEASE_TO_PRO");
        assertAmounts(c, d, "0.00", "1080.00");
        assertThat(c.get("job").get("status").asString()).isEqualTo("COMPLETED");
        assertThat(c.get("payment").get("status").asString()).isEqualTo("RELEASED_TO_PRO");
        assertThat(escrowStatus(d.jobId())).isEqualTo("RELEASED_TO_PRO");
        assertThat(jobStatus(d.jobId())).isEqualTo("COMPLETED");
        assertThat(requestStatus(d)).isEqualTo("ASSIGNED");
        assertThat(complaintStatus(d)).isEqualTo("DISMISSED");

        // Release'de gateway'e iade gitmez.
        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
        assertThat(ledger(d.ref(), "PAYOUT")).isEqualByComparingTo("1080.00");
        assertThat(ledger(d.ref(), "COMMISSION")).isEqualByComparingTo("120.00");
        assertThat(ledger(d.ref(), "REFUND")).isEqualByComparingTo("0");
        assertThat(ledgerRows(d.ref())).isEqualTo(2);
        assertThat(jdbc.queryForObject("select completed_jobs from pro_profiles where user_id = ?::uuid",
                Integer.class, d.s().pro().id())).isEqualTo(completedBefore + 1);

        assertThat(decidedNotification(d.s().customer()).get("amount")).isEqualTo("0.00");
        assertThat(decidedNotification(d.s().pro()).get("amount")).isEqualTo("1080.00");
        assertThat(decidedNotification(d.s().pro()).get("decision")).isEqualTo("RELEASE_TO_PRO");
        assertThat(adminActions("DECIDE_COMPLAINT", d.complaintId())).isEqualTo(1);
        // Müşteri artık değerlendirme yapabilir: iş COMPLETED.
        assertThat(job(d.s().customer(), d.jobId()).get("allowedActions").toString()).contains("REVIEW");
    }

    /** refundAmount / proAmount hem admin detayında hem katılımcının GET /complaints/{id} yanıtında aynıdır. */
    private void assertAmounts(JsonNode adminView, Disputed d, String refund, String pro) throws Exception {
        assertThat(adminView.get("refundAmount").decimalValue()).isEqualByComparingTo(refund);
        assertThat(adminView.get("proAmount").decimalValue()).isEqualByComparingTo(pro);
        JsonNode mine = body(call(HttpMethod.GET, "/api/v1/complaints/" + d.complaintId(), d.s().customer().access(),
                null).andExpect(status().isOk()));
        assertThat(mine.get("refundAmount").decimalValue()).isEqualByComparingTo(refund);
        assertThat(mine.get("proAmount").decimalValue()).isEqualByComparingTo(pro);
    }

    @Test
    void amountsAreNullUntilTheComplaintIsDecided() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        JsonNode open = ok(get(admin, "/admin/complaints/" + d.complaintId()));
        assertThat(open.get("refundAmount").isNull()).isTrue();
        assertThat(open.get("proAmount").isNull()).isTrue();
        JsonNode mine = body(call(HttpMethod.GET, "/api/v1/complaints/" + d.complaintId(), d.s().pro().access(), null)
                .andExpect(status().isOk()));
        assertThat(mine.get("refundAmount").isNull()).isTrue();
        assertThat(mine.get("proAmount").isNull()).isTrue();
    }

    // ─── Hata ve yarış durumları ────────────────────────────────────────────

    @Test
    void gatewayFailureReturns502AndChangesNothingThenRetrySucceeds() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        doThrow(new GatewayException("Craftgate yanıt vermedi.", true)).when(gateway).refundFully(anyLong(), anyString());
        // Askı ve uyarı da istenmiş: hiçbiri uygulanmamalı.
        decide(admin, d, "FULL_REFUND", true, true).andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.code").value("GATEWAY_ERROR"));
        assertNothingChanged(d);

        doThrow(new GatewayException("Craftgate yanıt vermedi.", true)).when(gateway)
                .refundPartially(anyLong(), any(), anyString());
        decide(admin, d, "SPLIT_50_50", true, true).andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.code").value("GATEWAY_ERROR"));
        assertNothingChanged(d);

        // Gateway düzelince aynı karar uygulanır.
        org.mockito.Mockito.doNothing().when(gateway).refundFully(anyLong(), anyString());
        ok(decide(admin, d, "FULL_REFUND"));
        assertThat(escrowStatus(d.jobId())).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(adminActions("DECIDE_COMPLAINT", d.complaintId())).isEqualTo(1);
    }

    private void assertNothingChanged(Disputed d) {
        assertThat(escrowStatus(d.jobId())).isEqualTo("DISPUTED");
        assertThat(jobStatus(d.jobId())).isEqualTo("DISPUTED");
        assertThat(requestStatus(d)).isEqualTo("ASSIGNED");
        assertThat(complaintStatus(d)).isEqualTo("OPEN");
        assertThat(jdbc.queryForObject("select decision from complaints where id = ?::uuid", String.class,
                d.complaintId())).isNull();
        assertThat(ledgerRows(d.ref())).isZero();
        assertThat(count("select count(*) from notifications where type = 'COMPLAINT_DECIDED'")).isZero();
        assertThat(count("select count(*) from admin_actions")).isZero();
        assertThat(jdbc.queryForObject("select warning_count from pro_profiles where user_id = ?::uuid", Integer.class,
                d.s().pro().id())).isZero();
        assertThat(jdbc.queryForObject("select review_status from pro_profiles where user_id = ?::uuid", String.class,
                d.s().pro().id())).isEqualTo("APPROVED");
        assertThat(jdbc.queryForObject("select refunded_amount from escrow_payment where ref = ?", BigDecimal.class,
                d.ref())).isEqualByComparingTo("0");
    }

    @Test
    void secondDecisionOnTheSameComplaintIs409AndMovesNoMoneyTwice() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        ok(decide(admin, d, "FULL_REFUND"));
        for (String again : List.of("FULL_REFUND", "SPLIT_50_50", "RELEASE_TO_PRO")) {
            decide(admin, d, again).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        }
        verify(gateway, times(1)).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
        assertThat(ledgerRows(d.ref())).isEqualTo(1);
        assertThat(adminActions("DECIDE_COMPLAINT", d.complaintId())).isEqualTo(1);
        assertThat(count("select count(*) from notifications where type = 'COMPLAINT_DECIDED'")).isEqualTo(2);
        assertThat(escrowStatus(d.jobId())).isEqualTo("REFUNDED_TO_CUSTOMER");
    }

    @Test
    void twoParallelDecisionsProduceExactlyOneOutcome() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        ExecutorService pool = Executors.newFixedThreadPool(2);
        CountDownLatch go = new CountDownLatch(1);
        try {
            Future<Integer> refund = pool.submit(() -> {
                go.await();
                return decide(admin, d, "FULL_REFUND").andReturn().getResponse().getStatus();
            });
            Future<Integer> release = pool.submit(() -> {
                go.await();
                return decide(admin, d, "RELEASE_TO_PRO").andReturn().getResponse().getStatus();
            });
            go.countDown();
            int a = refund.get();
            int b = release.get();
            assertThat(List.of(a, b)).containsExactlyInAnyOrder(200, 409);
            boolean refundWon = a == 200;
            assertThat(escrowStatus(d.jobId())).isEqualTo(refundWon ? "REFUNDED_TO_CUSTOMER" : "RELEASED_TO_PRO");
            assertThat(jobStatus(d.jobId())).isEqualTo(refundWon ? "CANCELLED" : "COMPLETED");
            assertThat(complaintStatus(d)).isEqualTo(refundWon ? "RESOLVED" : "DISMISSED");
            verify(gateway, times(refundWon ? 1 : 0)).refundFully(anyLong(), anyString());
            assertThat(ledgerRows(d.ref())).isEqualTo(refundWon ? 1 : 2);
            assertThat(adminActions("DECIDE_COMPLAINT", d.complaintId())).isEqualTo(1);
            assertThat(count("select count(*) from notifications where type = 'COMPLAINT_DECIDED'")).isEqualTo(2);
        } finally {
            pool.shutdownNow();
        }
    }

    @Test
    void decisionValidationAndUnknownComplaint() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        String path = "/admin/complaints/" + d.complaintId() + "/decision";
        post(admin, path, Map.of("note", "Yeterince uzun bir gerekçe.")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("decision"));
        post(admin, path, Map.of("decision", "SPLIT_70_30", "note", "Yeterince uzun bir gerekçe."))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("decision"));
        post(admin, path, Map.of("decision", "FULL_REFUND", "note", "kısa")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("note"));
        post(admin, path, Map.of("decision", "FULL_REFUND", "note", "x".repeat(2001))).andExpect(status().isBadRequest());
        post(admin, "/admin/complaints/" + UUID.randomUUID() + "/decision",
                Map.of("decision", "FULL_REFUND", "note", "Yeterince uzun bir gerekçe.")).andExpect(status().isNotFound());
        verify(gateway, never()).refundFully(anyLong(), anyString());
        assertNothingChanged(d);
        // warnPro/suspendPro verilmezse false sayılır.
        ok(post(admin, path, Map.of("decision", "RELEASE_TO_PRO", "note", "Yeterince uzun bir gerekçe.")));
        assertThat(jdbc.queryForObject("select warn_pro or suspend_pro from complaints where id = ?::uuid",
                Boolean.class, d.complaintId())).isFalse();
    }

    // ─── Uyarı ve askı ──────────────────────────────────────────────────────

    @Test
    void warnProAddsOneWarningOnly() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        JsonNode c = ok(decide(admin, d, "SPLIT_50_50", true, false));
        assertThat(c.get("warnPro").asBoolean()).isTrue();
        assertThat(c.get("suspendPro").asBoolean()).isFalse();
        assertThat(c.get("pro").get("warningCount").asInt()).isEqualTo(1);
        assertThat(jdbc.queryForObject("select review_status from pro_profiles where user_id = ?::uuid", String.class,
                d.s().pro().id())).isEqualTo("APPROVED");
        assertThat(adminActions("WARN_PRO", d.s().pro().id())).isEqualTo(1);
        assertThat(adminActions("SUSPEND_PRO", d.s().pro().id())).isZero();
    }

    @Test
    void suspendProSuspendsTheProfileWithdrawsPendingOffersAndKeepsTheAccountActive() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        // Ustanın başka bir talepte bekleyen teklifi var.
        Account otherCustomer = register();
        JsonNode otherRequest = createRequest(otherCustomer, addressId(otherCustomer, "Kadıköy"));
        String pendingOffer = sendOffer(d.s().pro(), otherRequest.get("id").asString(), offerBody("400", "100"))
                .get("id").asString();
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, pendingOffer))
                .isEqualTo("PENDING");

        JsonNode c = ok(decide(admin, d, "RELEASE_TO_PRO", true, true));
        assertThat(c.get("suspendPro").asBoolean()).isTrue();
        assertThat(jdbc.queryForObject("select review_status from pro_profiles where user_id = ?::uuid", String.class,
                d.s().pro().id())).isEqualTo("SUSPENDED");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, pendingOffer))
                .isEqualTo("WITHDRAWN");
        // Hesap askıya alınmaz: giriş sürer; usta kapısı kapanır.
        assertThat(jdbc.queryForObject("select status from users where id = ?::uuid", String.class, d.s().pro().id()))
                .isEqualTo("ACTIVE");
        call(HttpMethod.GET, "/api/v1/me", d.s().pro().access(), null).andExpect(status().isOk())
                .andExpect(jsonPath("$.pro.reviewStatus").value("SUSPENDED"));
        call(HttpMethod.GET, "/api/v1/pro/profile", d.s().pro().access(), null).andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("PRO_NOT_APPROVED"));
        // Askıdaki usta yeni teklif veremez.
        call(HttpMethod.POST, "/api/v1/pro/requests/" + otherRequest.get("id").asString() + "/offers",
                d.s().pro().access(), offerBody("300", "0")).andExpect(status().isForbidden());
        assertThat(adminActions("SUSPEND_PRO", d.s().pro().id())).isEqualTo(1);
        assertThat(adminActions("WARN_PRO", d.s().pro().id())).isEqualTo(1);
        // Başvuru geçmişinde görünür.
        JsonNode history = ok(get(admin, "/admin/applications/" + d.s().pro().id())).get("history");
        assertThat(history.toString()).contains("SUSPEND_PRO").contains("WARN_PRO");
        assertThat(ok(get(admin, "/admin/applications?status=SUSPENDED")).get("items")).hasSize(1);
    }

    // ─── SEED ödemesi ───────────────────────────────────────────────────────

    /**
     * dev dışı profilde (testin varsayılanı) SEED emaneti iade edilemez: 409, hiçbir şey değişmez, gateway'e
     * gidilmez. dev'de defter-yalnız davranışı AdminDevSeedTest'te sınanır.
     */
    @Test
    void seedRefundsAreRefusedOutsideDevWithoutChangingAnything() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob();
        jdbc.update("update escrow_payment set provider = 'SEED' where ref = ?", d.ref());
        for (String decision : List.of("FULL_REFUND", "SPLIT_50_50")) {
            decide(admin, d, decision, true, true).andExpect(status().isConflict())
                    .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
            assertNothingChanged(d);
        }
        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
    }
}
