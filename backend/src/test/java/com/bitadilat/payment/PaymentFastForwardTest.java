package com.bitadilat.payment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.admin.AdminTestBase;
import com.bitadilat.payment.exception.GatewayException;
import java.math.BigDecimal;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.ActiveProfiles;
import tools.jackson.databind.JsonNode;

/**
 * Demo saati ({@code POST /api/v1/dev/jobs/{jobId}/payment/fast-forward}): yalnızca dev profilinde bean'dir. Aktarım
 * normal yoldan gider; Craftgate iade kontrolü atlanmaz.
 */
@ActiveProfiles("dev")
@org.springframework.boot.test.context.SpringBootTest(properties = {
        "spring.datasource.url=${TEST_DB_URL:jdbc:postgresql://localhost:5432/bitadilat_test}",
        "spring.datasource.username=${TEST_DB_USER:${USER}}",
        "spring.datasource.password=${TEST_DB_PASSWORD:}"
})
class PaymentFastForwardTest extends AdminTestBase {

    private String deliveredJob(Setup s) throws Exception {
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        return jobId;
    }

    private org.springframework.test.web.servlet.ResultActions forward(Account who, String jobId) throws Exception {
        return call(HttpMethod.POST, "/api/v1/dev/jobs/" + jobId + "/payment/fast-forward", who.access(), null);
    }

    @Test
    void fastForwardRunsTheAutoReleaseNowThroughTheNormalPath() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = deliveredJob(s);
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");

        JsonNode r = body(forward(s.customer(), jobId).andExpect(status().isOk()));
        assertThat(r.get("jobStatus").asString()).isEqualTo("COMPLETED");
        assertThat(r.get("escrowStatus").asString()).isEqualTo("RELEASED_TO_PRO");
        assertThat(r.get("moneyLocation").asString()).isEqualTo("PRO");
        assertThat(r.get("released").asBoolean()).isTrue();
        assertThat(escrowStatus(jobId)).isEqualTo("RELEASED_TO_PRO");
        // Normal yoldan: Craftgate'te iade soruldu (güvence atlanmadı), müşteri onayı değil otomatik onay.
        verify(gateway).refundedTotal(anyLong());
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isEqualTo(1);

        JsonNode t = body(get(s.customer(), "/jobs/" + jobId + "/payment/timeline").andExpect(status().isOk()));
        java.util.List<String> types = new java.util.ArrayList<>();
        t.get("events").forEach(e -> types.add(e.get("type").asString()));
        assertThat(types).contains("AUTO_APPROVED", "RELEASED_TO_PRO").doesNotContain("CUSTOMER_APPROVED");
        // Ikinci cagri: is artik WORK_FINISHED degil.
        forward(s.customer(), jobId).andExpect(status().isConflict());
    }

    @Test
    void fastForwardDoesNotSkipTheCraftgateRefundCheck() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = deliveredJob(s);
        // Craftgate'te iade görünüyor: aktarım yapılmaz, elle inceleme (PAYOUT_NEEDS_REVIEW).
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("100.00"));
        JsonNode r = body(forward(s.pro(), jobId).andExpect(status().isOk()));
        assertThat(r.get("released").asBoolean()).isFalse();
        assertThat(r.get("escrowStatus").asString()).isEqualTo("LOCKED");
        assertThat(r.get("errorCode").asString()).isEqualTo("PAYOUT_NEEDS_REVIEW");
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");
        assertThat(count("select count(*) from payout_ledger where payment_ref = (select ref from escrow_payment "
                + "where job_id = ?::uuid)", jobId)).isZero();
    }

    @Test
    void fastForwardWhenCraftgateIsDownQueuesThePayout() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = deliveredJob(s);
        when(gateway.refundedTotal(anyLong())).thenThrow(new GatewayException("Craftgate yanıt vermedi.", true));
        JsonNode r = body(forward(s.customer(), jobId).andExpect(status().isOk()));
        assertThat(r.get("released").asBoolean()).isFalse();
        assertThat(r.get("pendingAction").asString()).isEqualTo("RELEASE");
        assertThat(r.get("jobStatus").asString()).isEqualTo("COMPLETED");
    }

    @Test
    void fastForwardRejectsWrongStateOpenComplaintAndStrangers() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        // Henüz teslim edilmedi.
        forward(s.customer(), jobId).andExpect(status().isConflict());
        finishWork(s, jobId);
        forward(register(), jobId).andExpect(status().isNotFound());
        forward(s.customer(), UUID.randomUUID().toString()).andExpect(status().isNotFound());
        verify(gateway, never()).refundedTotal(anyLong());
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");

        // Açık şikayet: otomatik aktarım yapılmaz.
        Disputed d = disputedJob();
        // disputedJob işi IN_PROGRESS iken şikayet eder; WORK_FINISHED değil.
        forward(d.s().customer(), d.jobId()).andExpect(status().isConflict());
    }

    @Test
    void seedPaymentIsReleasedLedgerOnly() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = deliveredJob(s);
        jdbc.update("update escrow_payment set provider = 'SEED' where job_id = ?::uuid", jobId);
        JsonNode r = body(forward(admin(), jobId).andExpect(status().isOk()));
        assertThat(r.get("released").asBoolean()).isTrue();
        verify(gateway, never()).refundedTotal(anyLong());
        JsonNode t = body(get(admin(), "/jobs/" + jobId + "/payment/timeline").andExpect(status().isOk()));
        assertThat(t.get("provider").asString()).isEqualTo("SEED");
    }
}
