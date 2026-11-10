package com.bitadilat.payment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway.ThreeDsRequest;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** Uygulama kanalı: init ön koşulları, banka dönüşünde teklif kabulü, yarış, done sayfası ve sonuç erişimi. */
class PaymentAppTest extends Wave3TestBase {

    // ─── init ───────────────────────────────────────────────────────────────

    @Test
    void initReturnsRefAndBankPageAndUsesServerSideAmount() throws Exception {
        Setup s = openRequestWithOffer("1650", "800");
        JsonNode r = body(initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isOk()));
        assertThat(r.get("ref").asString()).isNotBlank();
        assertThat(r.get("htmlContent").asString()).contains("banka");

        ArgumentCaptor<ThreeDsRequest> sent = ArgumentCaptor.forClass(ThreeDsRequest.class);
        verify(gateway).init3ds(sent.capture());
        assertThat(sent.getValue().amount()).isEqualByComparingTo("2450.00");
        assertThat(jdbc.queryForObject("select channel || '/' || provider || '/' || status from escrow_payment",
                String.class)).isEqualTo("APP/CRAFTGATE/INITIALIZED");
    }

    @Test
    void anotherCustomersOfferIs404() throws Exception {
        Setup s = openRequestWithOffer();
        Account stranger = register();
        initPaymentRaw(stranger, s.offerId(), newKey()).andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
        initPaymentRaw(s.customer(), newKey(), newKey()).andExpect(status().isNotFound()); // olmayan teklif
        initPaymentRaw(s.customer(), "abc", newKey()).andExpect(status().isNotFound());
        assertThat(count("select count(*) from escrow_payment where request_id = ?::uuid", s.requestId())).isZero();
    }

    @Test
    void expiredOfferIs409AndNothingIsCharged() throws Exception {
        Setup s = openRequestWithOffer();
        jdbc.update("update offers set valid_until = now() - interval '1 minute' where id = ?::uuid", s.offerId());
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("OFFER_EXPIRED"));
        verify(gateway, never()).init3ds(any());
    }

    @Test
    void closedRequestAndNonPendingOfferAreIllegalState() throws Exception {
        Setup s = openRequestWithOffer();
        jdbc.update("update offers set status = 'WITHDRAWN' where id = ?::uuid", s.offerId());
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        jdbc.update("update service_requests set status = 'CANCELLED' where id = ?::uuid", s.requestId());
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
    }

    @Test
    void secondInitWhileFirstIsInitializedIsPaymentInProgress() throws Exception {
        Setup s = openRequestWithOffer();
        String other = secondOffer(s, "500", "200");
        initPayment(s.customer(), s.offerId());
        initPaymentRaw(s.customer(), other, newKey()).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("PAYMENT_IN_PROGRESS"));
        assertThat(count("select count(*) from escrow_payment where request_id = ?::uuid", s.requestId())).isEqualTo(1);
    }

    @Test
    void reusedAttemptKeyIsDuplicateAttempt() throws Exception {
        Setup s = openRequestWithOffer();
        String key = newKey();
        initPaymentRaw(s.customer(), s.offerId(), key).andExpect(status().isOk());
        initPaymentRaw(s.customer(), s.offerId(), key).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_ATTEMPT"));
        // UUID olmayan anahtar 400.
        initPaymentRaw(s.customer(), s.offerId(), "not-a-uuid").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("attemptKey"));
    }

    @Test
    void invalidCardIs400WithFieldAndGatewayIsNotCalled() throws Exception {
        Setup s = openRequestWithOffer();
        var bad = initBody(s.offerId(), newKey());
        bad.put("cardNumber", "1234 5678 9012 3456");
        call(HttpMethod.POST, "/api/v1/payments/3ds/init", s.customer().access(), bad)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_CARD"))
                .andExpect(jsonPath("$.field").value("number"));
        verify(gateway, never()).init3ds(any());
    }

    @Test
    void gatewayRejectionIs402WithRefAndFreesTheRequest() throws Exception {
        Setup s = openRequestWithOffer();
        org.mockito.Mockito.when(gateway.init3ds(any())).thenThrow(new GatewayException("Kart reddedildi.", false));
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isPaymentRequired())
                .andExpect(jsonPath("$.code").value("PAYMENT_DECLINED")).andExpect(jsonPath("$.ref").exists());
        assertThat(jdbc.queryForObject("select status from escrow_payment", String.class)).isEqualTo("FAILED");
        // FAILED kayıt yeni denemeyi engellemez.
        org.mockito.Mockito.reset(gateway);
        stubGateway();
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isOk());
    }

    @Test
    void gatewayOutageIs502GatewayErrorNotDeclinedAndFreesTheRequest() throws Exception {
        Setup s = openRequestWithOffer();
        org.mockito.Mockito.when(gateway.init3ds(any())).thenThrow(new GatewayException("Craftgate yanıt vermedi.", true));
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.code").value("GATEWAY_ERROR"));
        assertThat(jdbc.queryForObject("select status from escrow_payment", String.class)).isEqualTo("FAILED");
        org.mockito.Mockito.reset(gateway);
        stubGateway();
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isOk());
    }

    // ─── banka dönüşü ve kabul ──────────────────────────────────────────────

    @Test
    void successfulCallbackAcceptsOfferSupersedesOthersAndOpensJob() throws Exception {
        Setup s = openRequestWithOffer();
        String otherOffer = secondOffer(s, "500", "200");
        String ref = pay(s);

        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, s.offerId()))
                .isEqualTo("ACCEPTED");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, otherOffer))
                .isEqualTo("SUPERSEDED");
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("ASSIGNED");
        String jobId = jdbc.queryForObject("select job_id::text from escrow_payment where ref = ?", String.class, ref);
        assertThat(jobId).isNotNull();
        assertThat(jobStatus(jobId)).isEqualTo("AWAITING_APPOINTMENT");
        assertThat(jdbc.queryForObject("select count(*) from jobs where offer_id = ?::uuid and customer_id = ?::uuid "
                + "and pro_id = ?::uuid", Long.class, s.offerId(), s.customer().id(), s.pro().id())).isEqualTo(1L);
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");

        // Bildirimler: kabul edilen ustaya OFFER_ACCEPTED, diğer ustalara OFFER_SUPERSEDED.
        assertThat(notifications(s.pro(), "OFFER_ACCEPTED")).isEqualTo(1);
        assertThat(count("select count(*) from notifications where type = 'OFFER_SUPERSEDED'")).isEqualTo(1);

        // RequestSummary.jobId dolu, talep ASSIGNED.
        JsonNode list = body(call(HttpMethod.GET, "/api/v1/requests?scope=active", s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(list.get("items").get(0).get("status").asString()).isEqualTo("ASSIGNED");
        assertThat(list.get("items").get(0).get("jobId").asString()).isEqualTo(jobId);
        call(HttpMethod.GET, "/api/v1/requests/" + s.requestId(), s.customer().access(), null)
                .andExpect(jsonPath("$.jobId").value(jobId));
    }

    @Test
    void appChannelCallbackRedirectsToDonePageAndDonePageShowsNoData() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        callback(ref).andExpect(status().isSeeOther())
                .andExpect(header().string("Location", "/api/payments/3ds/done?ref=" + ref));

        String page = mvc.perform(get("/api/payments/3ds/done").param("ref", ref)).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        assertThat(page).contains("İşlem tamamlandı, uygulamaya dönülüyor…").doesNotContain(ref)
                .doesNotContain("2450").doesNotContain("LOCKED");
    }

    @Test
    void prototypeChannelStillRendersTheOldResultPage() throws Exception {
        // Prototip kanalı: statik teklif, iş açmaz, sayfa 200 ve eski ekran kimliği.
        var init = body(mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                        .post("/api/payments/3ds/init").contentType("application/json")
                        .content(json.writeValueAsString(initBody("OFFER-BD-88412", newKey()))))
                .andExpect(status().isOk()));
        String ref = init.get("ref").asString();
        String page = callback(ref).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        assertThat(page).contains("7c6ec3a02d3347a997a3fc5b1a2c91d0");
        assertThat(jdbc.queryForObject("select channel || '/' || status from escrow_payment where ref = ?",
                String.class, ref)).isEqualTo("PROTOTYPE/LOCKED");
        assertThat(count("select count(*) from jobs")).isZero();
    }

    @Test
    void failedBankResultCreatesNoJobAndLeavesOfferPending() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        org.mockito.Mockito.doReturn(
                new com.bitadilat.payment.gateway.PaymentGateway.GatewayPayment(1L,
                        com.bitadilat.payment.gateway.PaymentGateway.Status.FAILURE, null, "x", "NOT_SUFFICIENT_FUNDS"))
                .when(gateway).retrieve(anyLong());
        callback(ref).andExpect(status().isSeeOther());
        assertThat(jdbc.queryForObject("select status from escrow_payment where ref = ?", String.class, ref))
                .isEqualTo("FAILED");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, s.offerId()))
                .isEqualTo("PENDING");
        assertThat(count("select count(*) from jobs")).isZero();
        assertThat(body(call(HttpMethod.GET, "/api/v1/payments/" + ref, s.customer().access(), null)
                .andExpect(status().isOk())).get("errorCode").asString()).isEqualTo("PAYMENT_DECLINED");
    }

    @Test
    void repeatedCallbackIsIdempotent() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        callback(ref);
        callback(ref);
        assertThat(count("select count(*) from jobs where request_id = ?::uuid", s.requestId())).isEqualTo(1);
        assertThat(notifications(s.pro(), "OFFER_ACCEPTED")).isEqualTo(1);
    }

    @Test
    void offerExpiredDuringBankStepIsRefundedAutomatically() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        jdbc.update("update offers set valid_until = now() - interval '1 minute' where id = ?::uuid", s.offerId());
        callback(ref);
        JsonNode result = body(call(HttpMethod.GET, "/api/v1/payments/" + ref, s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(result.get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(result.get("errorCode").asString()).isEqualTo("OFFER_EXPIRED");
        assertThat(result.get("errorMessage").asString()).isNotBlank();
        assertThat(result.get("jobId").isNull()).isTrue();
        verify(gateway, times(1)).refundFully(anyLong(), anyString());
        assertThat(count("select count(*) from jobs")).isZero();
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("OPEN");
    }

    @Test
    void failedAutomaticRefundKeepsRecordLockedAndSweeperRetries() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        jdbc.update("update offers set valid_until = now() - interval '1 minute' where id = ?::uuid", s.offerId());
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).refundFully(anyLong(), anyString());
        callback(ref);
        JsonNode result = body(call(HttpMethod.GET, "/api/v1/payments/" + ref, s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(result.get("status").asString()).isEqualTo("LOCKED");
        assertThat(result.get("errorCode").asString()).isEqualTo("OFFER_EXPIRED");
        assertThat(result.get("resultUncertain").asBoolean()).isTrue();

        org.mockito.Mockito.doNothing().when(gateway).refundFully(anyLong(), anyString());
        sweeper.run(java.time.Instant.now().plus(java.time.Duration.ofHours(1))); // ilk bekleme süresi dolmuş
        assertThat(jdbc.queryForObject("select status from escrow_payment where ref = ?", String.class, ref))
                .isEqualTo("REFUNDED_TO_CUSTOMER");
    }

    @Test
    void sweeperClosesStaleInitializedPaymentUsingGatewayTruth() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        // Kullanıcı WebView'i kapattı, callback hiç gelmedi; banka ise ödemeyi almış.
        jdbc.update("update escrow_payment set created_at = now() - interval '2 hours' where ref = ?", ref);
        sweeper.run(java.time.Instant.now());
        assertThat(jdbc.queryForObject("select status from escrow_payment where ref = ?", String.class, ref))
                .isEqualTo("LOCKED");
        assertThat(jdbc.queryForObject("select job_id from escrow_payment where ref = ?", String.class, ref))
                .isNotNull();
    }

    @Test
    void twoPaymentsRacingForTheSameRequestOneOpensTheJobTheOtherIsRefunded() throws Exception {
        Setup s = openRequestWithOffer();
        String otherOffer = secondOffer(s, "500", "200");
        // Kısmi benzersiz indeks normalde ikinci INITIALIZED kaydı engeller; yarışın kendisini sınamak için kaldırılır
        // ve test bitince geri konur.
        jdbc.execute("drop index ux_escrow_one_initialized_per_request");
        String first;
        String second;
        try {
            first = initPayment(s.customer(), s.offerId());
            // Servis katmanı da ikinci INITIALIZED başlatmayı reddeder; ilk kayıt geçici olarak FAILED yapılır.
            jdbc.update("update escrow_payment set status = 'FAILED' where ref = ?", first);
            second = initPayment(s.customer(), otherOffer);
            jdbc.update("update escrow_payment set status = 'INITIALIZED' where ref = ?", first);
            ExecutorService pool = Executors.newFixedThreadPool(2);
            CountDownLatch go = new CountDownLatch(1);
            List<Callable<Object>> tasks = List.of(
                    () -> {
                        go.await();
                        return callback(first).andReturn().getResponse().getStatus();
                    },
                    () -> {
                        go.await();
                        return callback(second).andReturn().getResponse().getStatus();
                    });
            List<Future<Object>> futures = tasks.stream().map(pool::submit).toList();
            go.countDown();
            for (Future<Object> f : futures) {
                f.get(30, TimeUnit.SECONDS);
            }
            pool.shutdown();
        } finally {
            jdbc.execute("create unique index ux_escrow_one_initialized_per_request on escrow_payment (request_id) "
                    + "where status = 'INITIALIZED'");
        }

        assertThat(count("select count(*) from jobs where request_id = ?::uuid", s.requestId())).isEqualTo(1);
        assertThat(count("select count(*) from escrow_payment where status = 'LOCKED' and job_id is not null"))
                .isEqualTo(1);
        List<String> loserRefs = jdbc.queryForList(
                "select ref from escrow_payment where status = 'REFUNDED_TO_CUSTOMER'", String.class);
        assertThat(loserRefs).hasSize(1);
        JsonNode loser = body(call(HttpMethod.GET, "/api/v1/payments/" + loserRefs.get(0), s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(loser.get("errorCode").asString()).isEqualTo("REQUEST_ALREADY_ASSIGNED");
        assertThat(loser.get("jobId").isNull()).isTrue();
        verify(gateway, times(1)).refundFully(anyLong(), anyString());
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("ASSIGNED");
    }

    // ─── PaymentResult erişimi ──────────────────────────────────────────────

    @Test
    void paymentResultVisibleToCustomerAndAssignedProOnly() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = pay(s);
        JsonNode mine = body(call(HttpMethod.GET, "/api/v1/payments/" + ref, s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(mine.get("status").asString()).isEqualTo("LOCKED");
        assertThat(mine.get("totalAmount").asDouble()).isEqualTo(1200.0);
        assertThat(mine.get("cardLast4").asString()).isEqualTo("0001");
        assertThat(mine.get("jobId").asString()).isNotBlank();
        assertThat(mine.get("offerId").asString()).isEqualTo(s.offerId());
        assertThat(mine.get("requestId").asString()).isEqualTo(s.requestId());
        assertThat(mine.get("resultUncertain").asBoolean()).isFalse();
        assertThat(mine.toString()).doesNotContain(CARD_NUMBER).doesNotContain("cvc");

        JsonNode pro = body(call(HttpMethod.GET, "/api/v1/payments/" + ref, s.pro().access(), null)
                .andExpect(status().isOk()));
        assertThat(pro.get("cardLast4").isNull()).isTrue();

        call(HttpMethod.GET, "/api/v1/payments/" + ref, register().access(), null).andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/payments/" + ref, null, null).andExpect(status().isUnauthorized());
        call(HttpMethod.GET, "/api/v1/payments/does-not-exist", s.customer().access(), null)
                .andExpect(status().isNotFound());
    }

    @Test
    void whileInitializedResultIsUncertain() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = initPayment(s.customer(), s.offerId());
        JsonNode r = body(call(HttpMethod.GET, "/api/v1/payments/" + ref, s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(r.get("status").asString()).isEqualTo("INITIALIZED");
        assertThat(r.get("resultUncertain").asBoolean()).isTrue();
        assertThat(r.get("jobId").isNull()).isTrue();
    }

    @Test
    void prototypeEndpointsCannotTouchAppPayments() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = pay(s);
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post("/api/payments/" + ref
                + "/refund").contentType("application/json").content("{\"type\":\"FULL\"}"))
                .andExpect(status().isNotFound());
        verify(gateway, never()).refundFully(anyLong(), anyString());
        mvc.perform(get("/api/payments/" + ref)).andExpect(status().isNotFound());
    }

    @org.springframework.beans.factory.annotation.Autowired
    private com.bitadilat.payment.service.PaymentSweeper sweeper;
}
