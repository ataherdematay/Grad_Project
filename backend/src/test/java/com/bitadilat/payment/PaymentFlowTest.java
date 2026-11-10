package com.bitadilat.payment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway;
import com.bitadilat.payment.gateway.PaymentGateway.GatewayPayment;
import com.bitadilat.payment.gateway.PaymentGateway.Status;
import com.bitadilat.payment.gateway.PaymentGateway.ThreeDsRequest;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

/** Ödeme akışını HTTP katmanından sağlayıcıya kadar çalıştırır; yalnızca Craftgate sahtedir. */
@SpringBootTest
@Import(TestDatabaseConfig.class)
@AutoConfigureMockMvc
@ExtendWith(OutputCaptureExtension.class)
class PaymentFlowTest {

    private static final String OFFER_ID = "OFFER-BD-88412";
    private static final String CARD_NUMBER = "5258640000000001";
    private static final String CVC = "987";
    private static final String SUCCESS_SID = "7c6ec3a02d3347a997a3fc5b1a2c91d0";
    private static final String FAILURE_SID = "1476367258dd4a7aa4b9cbda6b0091c0";
    private static final BigDecimal TOTAL = new BigDecimal("2450.00");
    private static final AtomicLong NEXT_PAYMENT_ID = new AtomicLong(1000);

    @Autowired
    private MockMvc mvc;

    @Autowired
    private ObjectMapper json;

    @MockitoBean
    private PaymentGateway gateway;

    private long paymentId;
    private String ref;
    private String conversationId;

    @BeforeEach
    void setUp() {
        paymentId = NEXT_PAYMENT_ID.incrementAndGet();
        when(gateway.isCallbackAuthentic(any())).thenReturn(true);
        when(gateway.init3ds(any())).thenReturn(
                new PaymentGateway.ThreeDsSession(paymentId, "<form>banka</form>", null));
    }

    // ─── Başlatma ───────────────────────────────────────────────────────────

    @Test
    void amountComesFromServerEvenIfClientSendsOne() throws Exception {
        String body = """
                {"offerId":"%s","attemptKey":"%s","cardHolderName":"Ayşe Demir","cardNumber":"%s",
                 "expireMonth":"07","expireYear":"2044","cvc":"%s","totalPrice":1,"totalAmount":1,"price":1}
                """.formatted(OFFER_ID, UUID.randomUUID(), CARD_NUMBER, CVC);

        mvc.perform(post("/api/payments/3ds/init").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.htmlContent").value("<form>banka</form>"));

        ArgumentCaptor<ThreeDsRequest> sent = ArgumentCaptor.forClass(ThreeDsRequest.class);
        verify(gateway).init3ds(sent.capture());
        assertThat(sent.getValue().amount()).isEqualByComparingTo(TOTAL);
        assertThat(sent.getValue().callbackUrl()).isEqualTo("http://localhost:8090/api/payments/3ds/callback");
    }

    @Test
    void callbackUrlFromClientIsIgnored() throws Exception {
        String body = """
                {"offerId":"%s","attemptKey":"%s","cardHolderName":"Ayşe Demir","cardNumber":"%s",
                 "expireMonth":"07","expireYear":"2044","cvc":"%s","callbackUrl":"https://kotu.example/cb"}
                """.formatted(OFFER_ID, UUID.randomUUID(), CARD_NUMBER, CVC);

        mvc.perform(post("/api/payments/3ds/init").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk());

        ArgumentCaptor<ThreeDsRequest> sent = ArgumentCaptor.forClass(ThreeDsRequest.class);
        verify(gateway).init3ds(sent.capture());
        assertThat(sent.getValue().callbackUrl()).doesNotContain("kotu.example");
    }

    @Test
    void invalidCardNeverReachesGateway() throws Exception {
        init(UUID.randomUUID().toString(), "5258640000000002")
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_CARD"))
                .andExpect(jsonPath("$.field").value("number"));

        verify(gateway, never()).init3ds(any());
    }

    @Test
    void unknownOfferIsRejected() throws Exception {
        String body = """
                {"offerId":"YOK","attemptKey":"%s","cardHolderName":"Ayşe Demir","cardNumber":"%s",
                 "expireMonth":"07","expireYear":"2044","cvc":"%s"}
                """.formatted(UUID.randomUUID(), CARD_NUMBER, CVC);

        mvc.perform(post("/api/payments/3ds/init").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isNotFound());
        verify(gateway, never()).init3ds(any());
    }

    @Test
    void sameAttemptKeyDoesNotStartSecondPayment() throws Exception {
        String attempt = UUID.randomUUID().toString();
        init(attempt, CARD_NUMBER).andExpect(status().isOk());
        init(attempt, CARD_NUMBER)
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_ATTEMPT"));

        verify(gateway, times(1)).init3ds(any());
    }

    @Test
    void declineAtInitIsStoredAsFailedWithFriendlyMessage() throws Exception {
        when(gateway.init3ds(any())).thenThrow(new GatewayException("Kartınızın bakiyesi yetersiz.", false));

        String response = init(UUID.randomUUID().toString(), CARD_NUMBER)
                .andExpect(status().isPaymentRequired())
                .andExpect(jsonPath("$.code").value("PAYMENT_DECLINED"))
                .andReturn().getResponse().getContentAsString();

        String declinedRef = json.readTree(response).get("ref").asString();
        mvc.perform(get("/api/payments/" + declinedRef))
                .andExpect(jsonPath("$.status").value("FAILED"))
                .andExpect(jsonPath("$.errorMessage").value("Kartınızın bakiyesi yetersiz."));
    }

    @Test
    void cardDataIsNeverLoggedOrReturned(CapturedOutput output) throws Exception {
        when(gateway.init3ds(any())).thenThrow(new GatewayException("Reddedildi.", false));

        String response = init(UUID.randomUUID().toString(), CARD_NUMBER)
                .andReturn().getResponse().getContentAsString();

        assertThat(output.getAll()).doesNotContain(CARD_NUMBER).doesNotContain("\"" + CVC + "\"");
        assertThat(response).doesNotContain(CARD_NUMBER);

        String declinedRef = json.readTree(response).get("ref").asString();
        String view = mvc.perform(get("/api/payments/" + declinedRef)).andReturn().getResponse().getContentAsString();
        assertThat(view).doesNotContain(CARD_NUMBER).doesNotContain(CVC).contains("\"cardLast4\":\"0001\"");
    }

    @Test
    void malformedBodyDoesNotEchoCardData() throws Exception {
        String response = mvc.perform(post("/api/payments/3ds/init")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"cardNumber\":\"" + CARD_NUMBER + "\""))
                .andExpect(status().isBadRequest())
                .andReturn().getResponse().getContentAsString();

        assertThat(response).doesNotContain(CARD_NUMBER);
    }

    // ─── Callback güvenliği ─────────────────────────────────────────────────

    @Test
    void successfulPaymentLocksEscrow() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenReturn(craftgate(Status.SUCCESS, TOTAL, conversationId));

        String page = callback("SUCCESS", "WAITING", conversationId);

        assertThat(page).contains(SUCCESS_SID);
        assertStatus("LOCKED");
    }

    @Test
    void forgedSuccessWithoutConversationIdChangesNothing() throws Exception {
        startPayment();

        String page = callback("SUCCESS", "COMPLETED", null);

        assertThat(page).contains(FAILURE_SID);
        assertStatus("INITIALIZED");
        verify(gateway, never()).complete3ds(anyLong());
    }

    @Test
    void forgedSuccessIsDecidedByCraftgateNotByParams() throws Exception {
        startPayment();
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.IN_PROGRESS, null, conversationId));

        String page = callback("SUCCESS", "COMPLETED", conversationId);

        assertThat(page).contains(FAILURE_SID);
        assertStatus("INITIALIZED");
    }

    @Test
    void forgedWaitingFailsWhenCraftgateRefusesToComplete() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenThrow(new GatewayException("Tamamlanamadı.", false));
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.IN_PROGRESS, null, conversationId));

        String page = callback("SUCCESS", "WAITING", conversationId);

        assertThat(page).contains(FAILURE_SID);
        assertStatus("FAILED");
    }

    @Test
    void invalidSignatureChangesNothing() throws Exception {
        startPayment();
        when(gateway.isCallbackAuthentic(any())).thenReturn(false);

        String page = callback("SUCCESS", "WAITING", conversationId);

        assertThat(page).contains(FAILURE_SID);
        assertStatus("INITIALIZED");
        verify(gateway, never()).complete3ds(anyLong());
    }

    @Test
    void unknownConversationIsIgnored() throws Exception {
        String page = mvc.perform(post("/api/payments/3ds/callback")
                        .param("paymentId", "999999")
                        .param("status", "SUCCESS")
                        .param("completeStatus", "WAITING")
                        .param("conversationId", "x"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        assertThat(page).contains(FAILURE_SID);
        verify(gateway, never()).complete3ds(anyLong());
    }

    @Test
    void wrongAmountInCompleteResponseDoesNotLock() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenReturn(craftgate(Status.SUCCESS, BigDecimal.ONE, conversationId));

        assertThat(callback("SUCCESS", "WAITING", conversationId)).contains(FAILURE_SID);
        assertStatus("FAILED");
    }

    @Test
    void wrongConversationInCompleteResponseDoesNotLock() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenReturn(craftgate(Status.SUCCESS, TOTAL, "baska"));

        assertThat(callback("SUCCESS", "WAITING", conversationId)).contains(FAILURE_SID);
        assertStatus("FAILED");
    }

    @Test
    void completeFailureSendsUserToErrorScreenNotRawJson() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenThrow(new GatewayException("Reddedildi.", false));
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.FAILURE, null, conversationId));

        String page = callback("SUCCESS", "WAITING", conversationId);

        assertThat(page).contains(FAILURE_SID).contains("<!DOCTYPE html>");
        assertStatus("FAILED");
    }

    @Test
    void completeThrowsButPaymentActuallySucceededLocks() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenThrow(new GatewayException("Zaman aşımı.", true));
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.SUCCESS, TOTAL, conversationId));

        assertThat(callback("SUCCESS", "WAITING", conversationId)).contains(SUCCESS_SID);
        assertStatus("LOCKED");
    }

    @Test
    void unknownResultKeepsRecordOpenInsteadOfGuessing() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenThrow(new GatewayException("Bağlantı yok.", true));
        when(gateway.retrieve(paymentId)).thenThrow(new GatewayException("Bağlantı yok.", true));

        assertThat(callback("SUCCESS", "WAITING", conversationId)).contains(FAILURE_SID);
        assertStatus("INITIALIZED");
    }

    @Test
    void repeatedCallbackCompletesOnlyOnce() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenReturn(craftgate(Status.SUCCESS, TOTAL, conversationId));

        callback("SUCCESS", "WAITING", conversationId);
        String second = callback("SUCCESS", "WAITING", conversationId);

        assertThat(second).contains(SUCCESS_SID);
        verify(gateway, times(1)).complete3ds(paymentId);
        assertStatus("LOCKED");
    }

    @Test
    void repeatedCallbackCannotOverwriteRefundedPayment() throws Exception {
        lockedPayment();
        mvc.perform(refund("FULL")).andExpect(status().isOk());

        callback("SUCCESS", "WAITING", conversationId);

        assertStatus("REFUNDED_TO_CUSTOMER");
    }

    @Test
    void bankFailureMarksFailed() throws Exception {
        startPayment();
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.FAILURE, null, conversationId));

        assertThat(callback("FAILURE", null, conversationId)).contains(FAILURE_SID);
        assertStatus("FAILED");
        verify(gateway, never()).complete3ds(anyLong());
    }

    /**
     * iOS E2E'de görüldü: banka sayfası callback'i kendi origin'inden form POST'u ile gönderir.
     * CORS açıkken (dev ve admin web'li prod) bu istek "Invalid CORS request" 403 alıyor, ödeme
     * INITIALIZED kalıyordu.
     */
    @Test
    void bankCallbackFromBankOriginIsNotBlockedByCors() throws Exception {
        startPayment();
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.FAILURE, null, conversationId));

        String page = mvc.perform(post("/api/payments/3ds/callback")
                        .header("Origin", "https://sandbox-api.craftgate.io")
                        .param("paymentId", "")
                        .param("status", "FAILURE")
                        .param("completeStatus", "")
                        .param("conversationId", conversationId))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        assertThat(page).contains(FAILURE_SID);
        assertStatus("FAILED");

        mvc.perform(get("/api/payments/3ds/done").header("Origin", "https://sandbox-api.craftgate.io"))
                .andExpect(status().isOk());
    }

    /** Sandbox'ta görüldü: bankada iptal edilince callback'te paymentId boş, conversationId dolu gelir. */
    @Test
    void cancelledAtBankWithEmptyPaymentIdMarksFailed() throws Exception {
        startPayment();
        when(gateway.retrieve(paymentId)).thenReturn(craftgate(Status.FAILURE, null, conversationId));

        String page = mvc.perform(post("/api/payments/3ds/callback")
                        .param("paymentId", "")
                        .param("status", "FAILURE")
                        .param("completeStatus", "")
                        .param("conversationId", conversationId))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        assertThat(page).contains(FAILURE_SID).contains(ref);
        assertStatus("FAILED");
    }

    @Test
    void failureWithUnknownConversationChangesNothing() throws Exception {
        startPayment();

        mvc.perform(post("/api/payments/3ds/callback")
                        .param("paymentId", "")
                        .param("status", "FAILURE")
                        .param("conversationId", "tahmin-edilen"))
                .andExpect(status().isOk());

        assertStatus("INITIALIZED");
    }

    @Test
    void paymentIdFromAnotherPaymentIsRejected() throws Exception {
        startPayment();

        mvc.perform(post("/api/payments/3ds/callback")
                        .param("paymentId", String.valueOf(paymentId + 500))
                        .param("status", "SUCCESS")
                        .param("completeStatus", "WAITING")
                        .param("conversationId", conversationId))
                .andExpect(status().isOk());

        assertStatus("INITIALIZED");
        verify(gateway, never()).complete3ds(anyLong());
    }

    @Test
    void callbackPageDoesNotReflectParameters() throws Exception {
        startPayment();
        String attack = "\";alert(1)//<script>x</script>";

        String page = mvc.perform(post("/api/payments/3ds/callback")
                        .param("paymentId", attack)
                        .param("status", attack)
                        .param("completeStatus", attack)
                        .param("conversationId", attack)
                        .param("errorDescription", attack))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        assertThat(page).doesNotContain("alert(1)").doesNotContain("<script>x");
    }

    // ─── Güvence havuzu ─────────────────────────────────────────────────────

    @Test
    void releaseSplitsCommissionAtTenPercent() throws Exception {
        lockedPayment();

        mvc.perform(post("/api/payments/" + ref + "/release"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("RELEASED_TO_PRO"))
                .andExpect(jsonPath("$.proPayout").value(2205.00))
                .andExpect(jsonPath("$.commission").value(245.00));
    }

    @Test
    void cannotReleaseBeforePaymentIsLocked() throws Exception {
        startPayment();

        mvc.perform(post("/api/payments/" + ref + "/release"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        assertStatus("INITIALIZED");
    }

    @Test
    void cannotRefundBeforePaymentIsLocked() throws Exception {
        startPayment();

        mvc.perform(refund("FULL")).andExpect(status().isConflict());
        verify(gateway, never()).refundFully(anyLong(), anyString());
    }

    @Test
    void fullRefundCallsCraftgateOnce() throws Exception {
        lockedPayment();

        mvc.perform(refund("FULL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("REFUNDED_TO_CUSTOMER"))
                .andExpect(jsonPath("$.refundedAmount").value(2450.00))
                .andExpect(jsonPath("$.proPayout").value(0));
        mvc.perform(refund("FULL")).andExpect(status().isConflict());

        verify(gateway, times(1)).refundFully(paymentId, conversationId);
    }

    @Test
    void splitRefundRequiresDispute() throws Exception {
        lockedPayment();

        mvc.perform(refund("SPLIT_50_50")).andExpect(status().isConflict());
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
    }

    @Test
    void disputeThenSplitRefundsHalfWithoutCommission() throws Exception {
        lockedPayment();
        mvc.perform(post("/api/payments/" + ref + "/dispute"))
                .andExpect(jsonPath("$.status").value("DISPUTED"));

        mvc.perform(refund("SPLIT_50_50"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("SPLIT_SETTLED"))
                .andExpect(jsonPath("$.refundedAmount").value(1225.00))
                .andExpect(jsonPath("$.proPayout").value(1225.00))
                .andExpect(jsonPath("$.commission").value(0));

        verify(gateway).refundPartially(eq(paymentId), eq(new BigDecimal("1225.00")), eq(conversationId));
    }

    @Test
    void disputedPaymentCanBeReleasedToPro() throws Exception {
        lockedPayment();
        mvc.perform(post("/api/payments/" + ref + "/dispute")).andExpect(status().isOk());

        mvc.perform(post("/api/payments/" + ref + "/release"))
                .andExpect(jsonPath("$.status").value("RELEASED_TO_PRO"));
    }

    @Test
    void failedRefundLeavesEscrowUntouched() throws Exception {
        lockedPayment();
        org.mockito.Mockito.doThrow(new GatewayException("İade tamamlanamadı.", false))
                .when(gateway).refundFully(anyLong(), anyString());

        mvc.perform(refund("FULL"))
                .andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.message").value("İade tamamlanamadı."));
        assertStatus("LOCKED");
    }

    @Test
    void conversationIdIsNotExposedToBrowser() throws Exception {
        startPayment();

        String view = mvc.perform(get("/api/payments/" + ref)).andReturn().getResponse().getContentAsString();

        assertThat(view).doesNotContain(conversationId);
    }

    // ─── Statik dosyalar ────────────────────────────────────────────────────

    @Test
    void servesPrototypeButNotRepositoryRoot() throws Exception {
        mvc.perform(get("/preview/index.html")).andExpect(status().isOk());
        mvc.perform(get("/README.md")).andExpect(status().isNotFound());
        mvc.perform(get("/.git/config")).andExpect(status().isNotFound());
        mvc.perform(get("/preview/../README.md")).andExpect(status().is4xxClientError());
    }

    // ─── Yardımcılar ────────────────────────────────────────────────────────

    private ResultActions init(String attemptKey, String cardNumber) throws Exception {
        String body = """
                {"offerId":"%s","attemptKey":"%s","cardHolderName":"Ayşe Demir","cardNumber":"%s",
                 "expireMonth":"07","expireYear":"2044","cvc":"%s"}
                """.formatted(OFFER_ID, attemptKey, cardNumber, CVC);
        return mvc.perform(post("/api/payments/3ds/init").contentType(MediaType.APPLICATION_JSON).content(body));
    }

    private void startPayment() throws Exception {
        String response = init(UUID.randomUUID().toString(), CARD_NUMBER)
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        JsonNode node = json.readTree(response);
        ref = node.get("ref").asString();

        ArgumentCaptor<ThreeDsRequest> sent = ArgumentCaptor.forClass(ThreeDsRequest.class);
        verify(gateway).init3ds(sent.capture());
        conversationId = sent.getValue().conversationId();
    }

    private void lockedPayment() throws Exception {
        startPayment();
        when(gateway.complete3ds(paymentId)).thenReturn(craftgate(Status.SUCCESS, TOTAL, conversationId));
        callback("SUCCESS", "WAITING", conversationId);
        assertStatus("LOCKED");
    }

    private String callback(String paymentStatus, String completeStatus, String conversation) throws Exception {
        var request = post("/api/payments/3ds/callback")
                .param("paymentId", String.valueOf(paymentId))
                .param("status", paymentStatus);
        if (completeStatus != null) {
            request.param("completeStatus", completeStatus);
        }
        if (conversation != null) {
            request.param("conversationId", conversation);
        }
        return mvc.perform(request)
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder refund(String type) {
        return post("/api/payments/" + ref + "/refund")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"type\":\"" + type + "\"}");
    }

    private void assertStatus(String expected) throws Exception {
        mvc.perform(get("/api/payments/" + ref)).andExpect(jsonPath("$.status").value(expected));
    }

    private GatewayPayment craftgate(Status paymentStatus, BigDecimal paid, String conversation) {
        return new GatewayPayment(paymentId, paymentStatus, paid, conversation, null);
    }
}
