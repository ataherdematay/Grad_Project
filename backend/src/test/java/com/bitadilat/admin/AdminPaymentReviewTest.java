package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway.RefundState;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import tools.jackson.databind.JsonNode;

/**
 * Admin incelemesi: {@code REFUND_NEEDS_REVIEW} / {@code PAYOUT_NEEDS_REVIEW} kayıtları Craftgate'e sorularak çözülür;
 * para iki kez hareket etmez.
 */
class AdminPaymentReviewTest extends AdminTestBase {

    private static final String NOTE = "Craftgate panelinde kontrol edildi.";

    private record Stuck(Setup s, String jobId, String ref) {
    }

    private String escrowRow(String ref) {
        return jdbc.queryForObject("select status || '/' || coalesce(pending_action, '-') || '/' "
                + "|| coalesce(error_code, '-') from escrow_payment where ref = ?", String.class, ref);
    }

    private long ledgerRows(String ref, String kind) {
        return count("select count(*) from payout_ledger where payment_ref = ? and kind = ?", ref, kind);
    }

    /** İptal edilmiş iş; iade 8 denemede yapılamadı (REFUND_NEEDS_REVIEW). */
    private Stuck refundReview() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        String ref = jdbc.queryForObject("select ref from escrow_payment where job_id = ?::uuid", String.class, jobId);
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).refundFully(anyLong(), anyString());
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());
        jdbc.update("update escrow_payment set refund_attempts = 8, error_code = 'REFUND_NEEDS_REVIEW', "
                + "next_refund_attempt_at = null where ref = ?", ref);
        org.mockito.Mockito.reset(gateway);
        stubGateway();
        return new Stuck(s, jobId, ref);
    }

    /** Tamamlanmış iş; aktarım öncesi Craftgate'te iade görüldü (PAYOUT_NEEDS_REVIEW). */
    private Stuck payoutReview(String refundedAtCraftgate) throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        String ref = jdbc.queryForObject("select ref from escrow_payment where job_id = ?::uuid", String.class, jobId);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal(refundedAtCraftgate));
        if (new BigDecimal(refundedAtCraftgate).signum() == 0) {
            // Kontrol 8 kez yapılamadı: Craftgate'te iade yok ama kayıt incelemede.
            when(gateway.refundedTotal(anyLong())).thenThrow(new GatewayException("yanıt yok", true));
        }
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk());
        jdbc.update("update escrow_payment set refund_attempts = 8, error_code = 'PAYOUT_NEEDS_REVIEW', "
                + "next_refund_attempt_at = null where ref = ?", ref);
        org.mockito.Mockito.reset(gateway);
        stubGateway();
        return new Stuck(s, jobId, ref);
    }

    private org.springframework.test.web.servlet.ResultActions resolve(Account admin, String ref, String resolution)
            throws Exception {
        return post(admin, "/admin/payments/" + ref + "/resolve", Map.of("resolution", resolution, "note", NOTE));
    }

    @Test
    void listShowsOnlyRowsInReviewWithJobAndParties() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        Stuck p = payoutReview("1200.00");
        payAndOpenJob(openRequestWithOffer()); // normal LOCKED kayıt listede yok

        JsonNode items = ok(get(admin, "/admin/payments/review")).get("items");
        List<String> refs = new ArrayList<>();
        items.forEach(i -> refs.add(i.get("ref").asString()));
        assertThat(refs).containsExactly(r.ref(), p.ref());
        JsonNode first = items.get(0);
        assertThat(first.get("errorCode").asString()).isEqualTo("REFUND_NEEDS_REVIEW");
        assertThat(first.get("pendingAction").asString()).isEqualTo("REFUND");
        assertThat(first.get("jobStatus").asString()).isEqualTo("CANCELLED");
        assertThat(first.get("jobPublicCode").asString()).isEqualTo(r.s().publicCode());
        assertThat(first.get("totalAmount").decimalValue()).isEqualByComparingTo("1200.00");
        assertThat(first.get("attempts").asInt()).isEqualTo(8);
        assertThat(first.get("customerName").asString()).isNotBlank();
        assertThat(first.get("proBusinessName").asString()).startsWith("Test Usta");
        assertThat(items.get(1).get("errorCode").asString()).isEqualTo("PAYOUT_NEEDS_REVIEW");
        assertThat(items.get(1).get("jobStatus").asString()).isEqualTo("COMPLETED");

        // Müşterinin iş ekranı inceleme kodunu görür.
        JsonNode job = job(r.s().customer(), r.jobId());
        assertThat(job.get("payment").get("errorCode").asString()).isEqualTo("REFUND_NEEDS_REVIEW");
    }

    @Test
    void checkAsksCraftgateAndOffersOnlyResolutionsThatCannotMoveMoneyTwice() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        Stuck p = payoutReview("1200.00");

        when(gateway.refundState(anyLong())).thenReturn(RefundState.NOT_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(BigDecimal.ZERO);
        JsonNode check = ok(get(admin, "/admin/payments/" + r.ref() + "/review"));
        assertThat(check.get("gatewayRefundState").asString()).isEqualTo("NOT_REFUNDED");
        assertThat(check.get("allowedResolutions").toString()).isEqualTo("[\"RETRY_REFUND\"]");
        assertThat(ok(get(admin, "/admin/payments/" + p.ref() + "/review")).get("allowedResolutions").toString())
                .isEqualTo("[\"RELEASE\"]");

        when(gateway.refundState(anyLong())).thenReturn(RefundState.FULLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));
        check = ok(get(admin, "/admin/payments/" + p.ref() + "/review"));
        assertThat(check.get("allowedResolutions").toString()).isEqualTo("[\"MARK_REFUNDED\"]");
        assertThat(check.get("gatewayRefundedTotal").decimalValue()).isEqualByComparingTo("1200.00");

        when(gateway.refundState(anyLong())).thenReturn(RefundState.PARTIALLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("200.00"));
        assertThat(ok(get(admin, "/admin/payments/" + p.ref() + "/review")).get("allowedResolutions").toString())
                .isEqualTo("[\"RETRY_REFUND\"]");

        when(gateway.refundState(anyLong())).thenReturn(RefundState.REFUND_PENDING);
        assertThat(ok(get(admin, "/admin/payments/" + r.ref() + "/review")).get("allowedResolutions")).isEmpty();

        // Toplam kadar iade ama durum tam iade değil: tutarsız, çözüm yok.
        when(gateway.refundState(anyLong())).thenReturn(RefundState.PARTIALLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));
        assertThat(ok(get(admin, "/admin/payments/" + r.ref() + "/review")).get("allowedResolutions")).isEmpty();

        // Kontrol hiçbir para hareketi yapmaz.
        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
        assertThat(count("select count(*) from admin_actions")).isZero();
    }

    @Test
    void markRefundedWritesTheLedgerWithoutSendingMoneyAndNotifiesBothSides() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        when(gateway.refundState(anyLong())).thenReturn(RefundState.FULLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));

        // Craftgate tam iade diyor: yeniden iade reddedilir.
        resolve(admin, r.ref(), "RETRY_REFUND").andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        verify(gateway, never()).refundFully(anyLong(), anyString());

        JsonNode done = ok(resolve(admin, r.ref(), "MARK_REFUNDED"));
        assertThat(done.get("payment").get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(escrowRow(r.ref())).isEqualTo("REFUNDED_TO_CUSTOMER/-/-");
        assertThat(ledgerRows(r.ref(), "REFUND")).isEqualTo(1);
        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundPartially(anyLong(), any(), anyString());
        assertThat(count("select count(*) from admin_actions where action = 'RESOLVE_PAYMENT_REVIEW' "
                + "and target_type = 'PAYMENT' and target_id = ? and note like 'MARK_REFUNDED: %'", r.ref()))
                .isEqualTo(1);
        assertThat(notifications(r.s().customer(), "REFUND_COMPLETED")).isEqualTo(1);
        assertThat(notifications(r.s().pro(), "REFUND_COMPLETED")).isEqualTo(1);
        JsonNode job = job(r.s().customer(), r.jobId());
        assertThat(job.get("payment").get("errorCode").isNull()).isTrue();
        assertThat(job.get("payment").get("pendingAction").isNull()).isTrue();

        // Artık incelemede değil: ikinci çözüm 409, defter değişmez.
        resolve(admin, r.ref(), "MARK_REFUNDED").andExpect(status().isConflict());
        assertThat(ledgerRows(r.ref(), "REFUND")).isEqualTo(1);
        assertThat(ok(get(admin, "/admin/payments/review")).get("items")).isEmpty();
    }

    @Test
    void retryRefundSendsOnlyTheRemainderOnce() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        when(gateway.refundState(anyLong())).thenReturn(RefundState.PARTIALLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("200.00"));

        ok(resolve(admin, r.ref(), "RETRY_REFUND"));

        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, times(1)).refundPartially(anyLong(), eq(new BigDecimal("1000.00")), anyString());
        assertThat(escrowRow(r.ref())).isEqualTo("REFUNDED_TO_CUSTOMER/-/-");
        assertThat(ledgerRows(r.ref(), "REFUND")).isEqualTo(1);

        resolve(admin, r.ref(), "RETRY_REFUND").andExpect(status().isConflict());
        verify(gateway, times(1)).refundPartially(anyLong(), any(), anyString());
    }

    @Test
    void retryRefundWithNothingRefundedSendsAFullRefund() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        when(gateway.refundState(anyLong())).thenReturn(RefundState.NOT_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(BigDecimal.ZERO);

        ok(resolve(admin, r.ref(), "RETRY_REFUND"));

        verify(gateway, times(1)).refundFully(anyLong(), anyString());
        assertThat(escrowRow(r.ref())).isEqualTo("REFUNDED_TO_CUSTOMER/-/-");
        // İptal edilmiş işin ödemesi ustaya aktarılamaz.
        Stuck other = refundReview();
        resolve(admin, other.ref(), "RELEASE").andExpect(status().isConflict());
        assertThat(ledgerRows(other.ref(), "PAYOUT")).isZero();
    }

    @Test
    void releaseIsRefusedWhenCraftgateShowsARefundAndAllowedWhenItShowsNone() throws Exception {
        Account admin = admin();
        Stuck p = payoutReview("1200.00");
        when(gateway.refundState(anyLong())).thenReturn(RefundState.FULLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));

        resolve(admin, p.ref(), "RELEASE").andExpect(status().isConflict());
        assertThat(ledgerRows(p.ref(), "PAYOUT")).isZero();
        assertThat(escrowRow(p.ref())).isEqualTo("LOCKED/RELEASE/PAYOUT_NEEDS_REVIEW");
        assertThat(count("select count(*) from admin_actions")).isZero();

        // Aktarım kontrolü 8 kez yapılamamış, Craftgate'te iade yok: ustaya aktarılır.
        Stuck q = payoutReview("0");
        when(gateway.refundState(anyLong())).thenReturn(RefundState.NOT_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(BigDecimal.ZERO);
        JsonNode done = ok(resolve(admin, q.ref(), "RELEASE"));
        assertThat(done.get("payment").get("status").asString()).isEqualTo("RELEASED_TO_PRO");
        assertThat(escrowRow(q.ref())).isEqualTo("RELEASED_TO_PRO/-/-");
        assertThat(ledgerRows(q.ref(), "PAYOUT")).isEqualTo(1);
        assertThat(ledgerRows(q.ref(), "COMMISSION")).isEqualTo(1);
        assertThat(notifications(q.s().pro(), "PAYOUT_RELEASED")).isEqualTo(1);
        assertThat(notifications(q.s().customer(), "PAYOUT_COMPLETED")).isEqualTo(1);
        verify(gateway, never()).refundFully(anyLong(), anyString());

        resolve(admin, q.ref(), "RELEASE").andExpect(status().isConflict());
        assertThat(ledgerRows(q.ref(), "PAYOUT")).isEqualTo(1);
    }

    @Test
    void seedPaymentIsNotResolvedOutsideTheDevProfile() throws Exception {
        Account admin = admin();
        Stuck q = payoutReview("0");
        jdbc.update("update escrow_payment set provider = 'SEED' where ref = ?", q.ref());

        JsonNode check = ok(get(admin, "/admin/payments/" + q.ref() + "/review"));
        assertThat(check.get("allowedResolutions")).isEmpty();
        resolve(admin, q.ref(), "RELEASE").andExpect(status().isConflict());
        resolve(admin, q.ref(), "RETRY_REFUND").andExpect(status().isConflict());
        assertThat(escrowRow(q.ref())).isEqualTo("LOCKED/RELEASE/PAYOUT_NEEDS_REVIEW");
        assertThat(ledgerRows(q.ref(), "PAYOUT")).isZero();
        assertThat(count("select count(*) from admin_actions")).isZero();
    }

    @Test
    void craftgateOutageOrPendingRefundChangesNothing() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        when(gateway.refundState(anyLong())).thenThrow(new GatewayException("yanıt yok", true));
        resolve(admin, r.ref(), "RETRY_REFUND").andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.code").value("GATEWAY_ERROR"));
        get(admin, "/admin/payments/" + r.ref() + "/review").andExpect(status().isBadGateway());

        org.mockito.Mockito.reset(gateway);
        stubGateway();
        when(gateway.refundState(anyLong())).thenReturn(RefundState.NOT_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(BigDecimal.ZERO);
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).refundFully(anyLong(), anyString());
        resolve(admin, r.ref(), "RETRY_REFUND").andExpect(status().isBadGateway());

        assertThat(escrowRow(r.ref())).isEqualTo("LOCKED/REFUND/REFUND_NEEDS_REVIEW");
        assertThat(ledgerRows(r.ref(), "REFUND")).isZero();
        assertThat(count("select count(*) from admin_actions")).isZero();
        assertThat(notifications(r.s().customer(), "REFUND_COMPLETED")).isZero();

        // İade Craftgate'te gerçekleşmiş ama yanıt gelmemişti: sonraki çözüm iadeyi yeniden göndermez.
        clearInvocations(gateway);
        when(gateway.refundState(anyLong())).thenReturn(RefundState.FULLY_REFUNDED);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));
        resolve(admin, r.ref(), "RETRY_REFUND").andExpect(status().isConflict());
        ok(resolve(admin, r.ref(), "MARK_REFUNDED"));
        verify(gateway, never()).refundFully(anyLong(), anyString());
        assertThat(ledgerRows(r.ref(), "REFUND")).isEqualTo(1);
    }

    @Test
    void resolveNeedsAnAdminAValidResolutionAndANote() throws Exception {
        Account admin = admin();
        Stuck r = refundReview();
        post(r.s().customer(), "/admin/payments/" + r.ref() + "/resolve",
                Map.of("resolution", "MARK_REFUNDED", "note", NOTE)).andExpect(status().isForbidden());
        get(r.s().customer(), "/admin/payments/review").andExpect(status().isForbidden());
        post(admin, "/admin/payments/" + r.ref() + "/resolve", Map.of("resolution", "MARK_REFUNDED", "note", "kısa"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("note"));
        post(admin, "/admin/payments/" + r.ref() + "/resolve", Map.of("resolution", "PAY_TWICE", "note", NOTE))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("resolution"));
        post(admin, "/admin/payments/nope/resolve", Map.of("resolution", "MARK_REFUNDED", "note", NOTE))
                .andExpect(status().isNotFound());
        // İncelemede olmayan kayıt.
        Setup s = openRequestWithOffer();
        String ref = pay(s);
        post(admin, "/admin/payments/" + ref + "/resolve", Map.of("resolution", "MARK_REFUNDED", "note", NOTE))
                .andExpect(status().isConflict());
        get(admin, "/admin/payments/" + ref + "/review").andExpect(status().isNotFound());
        verify(gateway, never()).refundFully(anyLong(), anyString());
    }
}
