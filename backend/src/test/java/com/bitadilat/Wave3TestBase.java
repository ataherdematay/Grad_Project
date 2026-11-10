package com.bitadilat;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.payment.gateway.PaymentGateway;
import com.bitadilat.payment.gateway.PaymentGateway.GatewayPayment;
import com.bitadilat.payment.gateway.PaymentGateway.Status;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.Year;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.ResultActions;
import tools.jackson.databind.JsonNode;

/**
 * Wave 3 testlerinin ortak zemini: Craftgate sahte ({@code @MockitoBean}), gerçek PostgreSQL ve gerçek güvenlik zinciri.
 * Ödeme akışı uçtan uca yürütülür: init, banka dönüşü (callback), teklif kabulü ve iş açılışı.
 */
public abstract class Wave3TestBase extends Wave2TestBase {

    protected static final String CARD_NUMBER = "5258640000000001";
    private static final AtomicLong NEXT_PAYMENT_ID = new AtomicLong(50_000);

    @MockitoBean
    protected PaymentGateway gateway;

    /** Müşteri, usta, talep ve ustanın PENDING teklifi. */
    public record Setup(Account customer, Account pro, String requestId, String offerId, String addressId,
                           String publicCode) {
    }

    @BeforeEach
    protected void stubGateway() {
        when(gateway.isCallbackAuthentic(any())).thenReturn(true);
        when(gateway.init3ds(any())).thenAnswer(inv ->
                new PaymentGateway.ThreeDsSession(NEXT_PAYMENT_ID.incrementAndGet(), "<form>banka</form>", null));
        // Craftgate'in gerçek durumu: kaydın tutarı ve conversationId ile başarılı.
        when(gateway.retrieve(anyLong())).thenAnswer(inv -> {
            long paymentId = inv.getArgument(0);
            Map<String, Object> row = jdbc.queryForMap(
                    "select total_amount, conversation_id from escrow_payment where craftgate_payment_id = ?", paymentId);
            return new GatewayPayment(paymentId, Status.SUCCESS, (BigDecimal) row.get("total_amount"),
                    (String) row.get("conversation_id"), null);
        });
    }

    protected Setup openRequestWithOffer() throws Exception {
        return openRequestWithOffer("900", "300");
    }

    protected Setup openRequestWithOffer(String labor, String materials) throws Exception {
        Account customer = register();
        String address = addressId(customer, "Kadıköy");
        Account pro = pro("Test Usta " + UUID.randomUUID().toString().substring(0, 6), List.of("plumbing"),
                List.of("Kadıköy"));
        JsonNode request = createRequest(customer, address);
        String offerId = sendOffer(pro, request.get("id").asString(), offerBody(labor, materials)).get("id").asString();
        return new Setup(customer, pro, request.get("id").asString(), offerId, address,
                request.get("publicCode").asString());
    }

    /** Aynı talebe ikinci usta teklifi. */
    protected String secondOffer(Setup s, String labor, String materials) throws Exception {
        Account other = pro("Diğer Usta " + UUID.randomUUID().toString().substring(0, 6), List.of("plumbing"),
                List.of("Kadıköy"));
        return sendOffer(other, s.requestId(), offerBody(labor, materials)).get("id").asString();
    }

    protected Map<String, Object> initBody(String offerId, String attemptKey) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("offerId", offerId);
        m.put("attemptKey", attemptKey);
        m.put("cardHolderName", "Ali Yılmaz");
        m.put("cardNumber", CARD_NUMBER);
        m.put("expireMonth", "12");
        m.put("expireYear", String.valueOf(Year.now().getValue() + 2));
        m.put("cvc", "987");
        return m;
    }

    protected ResultActions initPaymentRaw(Account customer, String offerId, String attemptKey) throws Exception {
        return call(HttpMethod.POST, "/api/v1/payments/3ds/init", customer.access(), initBody(offerId, attemptKey));
    }

    protected String initPayment(Account customer, String offerId) throws Exception {
        return body(initPaymentRaw(customer, offerId, newKey()).andExpect(status().isOk())).get("ref").asString();
    }

    /** Banka dönüşü (callback). 303 (APP) veya 200 (prototip) döner. */
    protected ResultActions callback(String ref) throws Exception {
        Map<String, Object> row = jdbc.queryForMap(
                "select craftgate_payment_id, conversation_id from escrow_payment where ref = ?", ref);
        return mvc.perform(post("/api/payments/3ds/callback")
                .param("status", "SUCCESS")
                .param("paymentId", String.valueOf(row.get("craftgate_payment_id")))
                .param("conversationId", (String) row.get("conversation_id")));
    }

    /** init + başarılı callback. Ödeme ref'ini döner. */
    protected String pay(Setup s) throws Exception {
        String ref = initPayment(s.customer(), s.offerId());
        callback(ref);
        return ref;
    }

    /** Ödemeyi alır ve açılan işin kimliğini döner (teklif kabulü yapılmış, iş AWAITING_APPOINTMENT). */
    protected String payAndOpenJob(Setup s) throws Exception {
        String ref = pay(s);
        return jdbc.queryForObject("select job_id::text from escrow_payment where ref = ?", String.class, ref);
    }

    protected JsonNode job(Account viewer, String jobId) throws Exception {
        return body(call(HttpMethod.GET, "/api/v1/jobs/" + jobId, viewer.access(), null).andExpect(status().isOk()));
    }

    protected ResultActions jobPost(Account who, String jobId, String path, Object payload) throws Exception {
        return call(HttpMethod.POST, "/api/v1/jobs/" + jobId + path, who.access(), payload);
    }

    /** Müşteri aralık önerir, usta kabul eder: iş SCHEDULED. */
    protected void schedule(Setup s, String jobId) throws Exception {
        Instant from = Instant.now().plus(1, ChronoUnit.DAYS);
        JsonNode proposed = body(jobPost(s.customer(), jobId, "/appointment/proposals",
                Map.of("slotFrom", from.toString(), "slotTo", from.plus(2, ChronoUnit.HOURS).toString()))
                .andExpect(status().isOk()));
        String pid = proposed.get("appointment").get("pendingProposal").get("id").asString();
        jobPost(s.pro(), jobId, "/appointment/proposals/" + pid + "/accept", null).andExpect(status().isOk());
    }

    /** SCHEDULED → ARRIVED → IN_PROGRESS. */
    protected void startWork(Setup s, String jobId) throws Exception {
        jobPost(s.pro(), jobId, "/arrived", null).andExpect(status().isOk());
        jobPost(s.pro(), jobId, "/start", null).andExpect(status().isOk());
    }

    protected void finishWork(Setup s, String jobId) throws Exception {
        jobPost(s.pro(), jobId, "/finish", Map.of("note", "İş tamamlandı, her şey çalışıyor.", "photoIds", List.of()))
                .andExpect(status().isOk());
    }

    protected String escrowStatus(String jobId) {
        return jdbc.queryForObject("select status from escrow_payment where job_id = ?::uuid", String.class, jobId);
    }

    protected String jobStatus(String jobId) {
        return jdbc.queryForObject("select status from jobs where id = ?::uuid", String.class, jobId);
    }

    protected long notifications(Account user, String type) {
        return count("select count(*) from notifications where user_id = ?::uuid and type = ?", user.id(), type);
    }
}
