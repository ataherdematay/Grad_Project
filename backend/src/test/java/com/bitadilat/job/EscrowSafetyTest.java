package com.bitadilat.job;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway.RefundState;
import com.bitadilat.payment.service.PaymentSweeper;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import tools.jackson.databind.JsonNode;

/**
 * Para güvenliği: iş iptalinin iadesi outbox ile işlem kesinleştikten sonra yapılır (e), ustaya aktarım öncesi
 * Craftgate'te iade sorulur (g).
 */
class EscrowSafetyTest extends Wave3TestBase {

    @Autowired
    private PaymentSweeper sweeper;
    @Autowired
    private JobScheduler scheduler;

    private String escrowRow(String jobId) {
        return jdbc.queryForObject("select status || '/' || coalesce(pending_action, '-') || '/' "
                + "|| coalesce(error_code, '-') || '/' || refund_attempts from escrow_payment where job_id = ?::uuid",
                String.class, jobId);
    }

    private String refOf(String jobId) {
        return jdbc.queryForObject("select ref from escrow_payment where job_id = ?::uuid", String.class, jobId);
    }

    /** Test iş parçacığının açık işleminden bağımsız, yalnızca kesinleşmiş veriyi gören okuma. */
    private String committed(String sql, String arg) throws Exception {
        try (Connection c = jdbc.getDataSource().getConnection(); PreparedStatement st = c.prepareStatement(sql)) {
            st.setString(1, arg);
            try (ResultSet rs = st.executeQuery()) {
                rs.next();
                return rs.getString(1);
            }
        }
    }

    // ─── (e) iptal iadesi: outbox ──────────────────────────────────────────

    @Test
    void cancelRefundIsSentOnlyAfterTheCancellationIsCommitted() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        List<String> seenByCraftgate = new ArrayList<>();
        doAnswer(inv -> {
            // Craftgate'e iade gönderildiği anda iptal veritabanında kesinleşmiş olmalı; aksi halde işlem geri alınırsa
            // para iade edilmiş ama iş iptal edilmemiş olur.
            seenByCraftgate.add(committed("select status from jobs where id = ?::uuid", jobId) + "/"
                    + committed("select coalesce(pending_action, '-') from escrow_payment where job_id = ?::uuid", jobId));
            return null;
        }).when(gateway).refundFully(anyLong(), anyString());

        JsonNode cancelled = body(jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED"))
                .andExpect(status().isOk()));

        assertThat(seenByCraftgate).containsExactly("CANCELLED/REFUND");
        assertThat(cancelled.get("payment").get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(cancelled.get("payment").get("pendingAction").isNull()).isTrue();
        assertThat(escrowRow(jobId)).isEqualTo("REFUNDED_TO_CUSTOMER/-/-/0");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'REFUND'", refOf(jobId)))
                .isEqualTo(1);
    }

    @Test
    void refundFailureStillCancelsTheJobAndTheSweeperRefundsLaterExactlyOnce() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        doThrow(new GatewayException("Craftgate yanıt vermedi.", true)).when(gateway).refundFully(anyLong(), anyString());

        JsonNode cancelled = body(jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED"))
                .andExpect(status().isOk()));
        assertThat(cancelled.get("status").asString()).isEqualTo("CANCELLED");
        assertThat(cancelled.get("payment").get("status").asString()).isEqualTo("LOCKED");
        assertThat(cancelled.get("payment").get("pendingAction").asString()).isEqualTo("REFUND");
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("CANCELLED");
        assertThat(notifications(s.pro(), "JOB_CANCELLED")).isEqualTo(1);
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/REFUND/-/1");
        assertThat(count("select count(*) from payout_ledger")).isZero();

        // Bekleme süresi (5 dk) dolmadan denenmez.
        sweeper.run(Instant.now());
        verify(gateway, times(1)).refundFully(anyLong(), anyString());

        doNothing().when(gateway).refundFully(anyLong(), anyString());
        sweeper.run(Instant.now().plus(Duration.ofMinutes(10)));
        verify(gateway, times(2)).refundFully(anyLong(), anyString());
        assertThat(escrowRow(jobId)).isEqualTo("REFUNDED_TO_CUSTOMER/-/-/1");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'REFUND'", refOf(jobId)))
                .isEqualTo(1);
        JsonNode after = job(s.customer(), jobId);
        assertThat(after.get("payment").get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(after.get("payment").get("pendingAction").isNull()).isTrue();

        // Tekrar çalışma zararsız.
        sweeper.run(Instant.now().plus(Duration.ofHours(1)));
        verify(gateway, times(2)).refundFully(anyLong(), anyString());
    }

    @Test
    void refundThatReachedCraftgateButTimedOutIsNeverSentTwice() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        // Craftgate iadeyi yaptı ama yanıt bize ulaşmadı.
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).refundFully(anyLong(), anyString());
        jobPost(s.pro(), jobId, "/cancel", Map.of("reason", "CANNOT_DO_JOB")).andExpect(status().isOk());
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/REFUND/-/1");
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("OPEN");

        clearInvocations(gateway);
        when(gateway.refundState(anyLong())).thenReturn(RefundState.FULLY_REFUNDED);
        sweeper.run(Instant.now().plus(Duration.ofHours(1)));

        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundPartially(anyLong(), org.mockito.ArgumentMatchers.any(), anyString());
        assertThat(escrowRow(jobId)).isEqualTo("REFUNDED_TO_CUSTOMER/-/-/1");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'REFUND'", refOf(jobId)))
                .isEqualTo(1);
    }

    @Test
    void cancelRefundThatKeepsFailingGoesToReviewAfterEightAttempts() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).refundFully(anyLong(), anyString());
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());
        Instant t = Instant.now();
        for (int i = 2; i <= 8; i++) {
            t = t.plus(Duration.ofDays(1));
            sweeper.run(t);
        }
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/REFUND/REFUND_NEEDS_REVIEW/8");
        clearInvocations(gateway);
        sweeper.run(t.plus(Duration.ofDays(30)));
        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundState(anyLong());
    }

    // ─── (g) ustaya aktarım öncesi Craftgate'te iade kontrolü ───────────────

    private String finishedJob(Setup s) throws Exception {
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        return jobId;
    }

    @Test
    void confirmDoesNotReleaseAPaymentThatCraftgateShowsAsRefunded() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = finishedJob(s);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));

        JsonNode done = body(jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk()));

        assertThat(done.get("status").asString()).isEqualTo("COMPLETED");
        assertThat(done.get("payment").get("status").asString()).isEqualTo("LOCKED");
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/RELEASE/PAYOUT_NEEDS_REVIEW/0");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", refOf(jobId))).isZero();
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isZero();
        // Admin raporunda görünür; zamanlayıcı elle incelemedeki kayda dokunmaz.
        clearInvocations(gateway);
        sweeper.run(Instant.now().plus(Duration.ofDays(1)));
        verify(gateway, never()).refundedTotal(anyLong());
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/RELEASE/PAYOUT_NEEDS_REVIEW/0");
    }

    @Test
    void autoCompleteDoesNotReleaseAPaymentThatCraftgateShowsAsRefunded() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = finishedJob(s);
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("50.00"));
        jdbc.update("update jobs set auto_complete_at = now() - interval '1 minute' where id = ?::uuid", jobId);

        assertThat(scheduler.run(Instant.now()).completed()).isEqualTo(1);

        assertThat(jobStatus(jobId)).isEqualTo("COMPLETED");
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/RELEASE/PAYOUT_NEEDS_REVIEW/0");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", refOf(jobId))).isZero();
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isZero();
    }

    @Test
    void craftgateOutageDoesNotBlockConfirmAndTheSweeperReleasesLater() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = finishedJob(s);
        when(gateway.refundedTotal(anyLong())).thenThrow(new GatewayException("Craftgate yanıt vermedi.", true));

        JsonNode done = body(jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk()));
        assertThat(done.get("status").asString()).isEqualTo("COMPLETED");
        assertThat(done.get("payment").get("status").asString()).isEqualTo("LOCKED");
        assertThat(done.get("payment").get("pendingAction").asString()).isEqualTo("RELEASE");
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/RELEASE/-/1");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", refOf(jobId))).isZero();
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isZero();

        // Craftgate döndü, iade yok: bekleme süresinden sonra zamanlayıcı aktarır.
        org.mockito.Mockito.reset(gateway);
        stubGateway();
        when(gateway.refundedTotal(anyLong())).thenReturn(BigDecimal.ZERO);
        sweeper.run(Instant.now());
        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/RELEASE/-/1");
        sweeper.run(Instant.now().plus(Duration.ofMinutes(10)));
        assertThat(escrowRow(jobId)).isEqualTo("RELEASED_TO_PRO/-/-/1");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'PAYOUT'", refOf(jobId)))
                .isEqualTo(1);
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'COMMISSION'",
                refOf(jobId))).isEqualTo(1);
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isEqualTo(1);

        sweeper.run(Instant.now().plus(Duration.ofHours(2)));
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", refOf(jobId))).isEqualTo(2);
    }

    @Test
    void releaseRetryThatFindsARefundGoesToReviewInsteadOfPayingThePro() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = finishedJob(s);
        when(gateway.refundedTotal(anyLong())).thenThrow(new GatewayException("Craftgate yanıt vermedi.", true));
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk());

        org.mockito.Mockito.reset(gateway);
        stubGateway();
        when(gateway.refundedTotal(anyLong())).thenReturn(new BigDecimal("1200.00"));
        sweeper.run(Instant.now().plus(Duration.ofMinutes(10)));

        assertThat(escrowRow(jobId)).isEqualTo("LOCKED/RELEASE/PAYOUT_NEEDS_REVIEW/1");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", refOf(jobId))).isZero();
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isZero();
    }
}
