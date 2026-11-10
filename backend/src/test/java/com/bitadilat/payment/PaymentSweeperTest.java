package com.bitadilat.payment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway.GatewayPayment;
import com.bitadilat.payment.gateway.PaymentGateway.RefundState;
import com.bitadilat.payment.gateway.PaymentGateway.Status;
import com.bitadilat.payment.service.PaymentService;
import com.bitadilat.payment.service.PaymentSweeper;
import java.sql.Connection;
import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

/** Ödeme toplayıcı: öksüz iadede Craftgate'e sorma, sınırlı yeniden deneme ve takılı 3DS ödemesinin kapatılması. */
class PaymentSweeperTest extends Wave3TestBase {

    @Autowired
    private PaymentSweeper sweeper;
    @Autowired
    private PaymentService payments;

    // ─── öksüz iade ─────────────────────────────────────────────────────────

    /** Teklif süresi bitmiş, otomatik iade zaman aşımına düşmüş: LOCKED, işsiz, hata kodlu, deneme sayacı 1. */
    private String orphan(Setup s) throws Exception {
        String ref = initPayment(s.customer(), s.offerId());
        jdbc.update("update offers set valid_until = now() - interval '1 minute' where id = ?::uuid", s.offerId());
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).refundFully(anyLong(), anyString());
        callback(ref);
        assertThat(state(ref)).isEqualTo("LOCKED/OFFER_EXPIRED/1");
        return ref;
    }

    private String state(String ref) {
        return jdbc.queryForObject("select status || '/' || coalesce(error_code, '-') || '/' || refund_attempts "
                + "from escrow_payment where ref = ?", String.class, ref);
    }

    @Test
    void alreadyRefundedPaymentOnlyFixesTheLedgerAndNeverSendsASecondRefund() throws Exception {
        String ref = orphan(openRequestWithOffer());
        clearInvocations(gateway);
        when(gateway.refundState(anyLong())).thenReturn(RefundState.FULLY_REFUNDED);

        sweeper.run(Instant.now().plus(Duration.ofHours(1)));

        verify(gateway, never()).refundFully(anyLong(), anyString());
        assertThat(jdbc.queryForObject("select status from escrow_payment where ref = ?", String.class, ref))
                .isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(jdbc.queryForObject("select result_uncertain from escrow_payment where ref = ?", Boolean.class, ref))
                .isFalse();
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'REFUND'", ref))
                .isEqualTo(1);
        // Tekrar çalışma zararsızdır.
        sweeper.run(Instant.now().plus(Duration.ofHours(2)));
        verify(gateway, never()).refundFully(anyLong(), anyString());
        assertThat(count("select count(*) from payout_ledger where payment_ref = ? and kind = 'REFUND'", ref))
                .isEqualTo(1);
    }

    @Test
    void notYetRefundedPaymentIsRefundedAfterTheBackoff() throws Exception {
        String ref = orphan(openRequestWithOffer());
        clearInvocations(gateway);
        when(gateway.refundState(anyLong())).thenReturn(RefundState.NOT_REFUNDED);
        org.mockito.Mockito.doNothing().when(gateway).refundFully(anyLong(), anyString());

        sweeper.run(Instant.now()); // bekleme süresi (5 dk) dolmadı
        verify(gateway, never()).refundFully(anyLong(), anyString());

        sweeper.run(Instant.now().plus(Duration.ofMinutes(10)));
        verify(gateway, times(1)).refundFully(anyLong(), anyString());
        assertThat(state(ref)).isEqualTo("REFUNDED_TO_CUSTOMER/OFFER_EXPIRED/1");
    }

    @Test
    void afterEightFailedAttemptsTheRecordNeedsReviewAndTheSweeperStopsTrying() throws Exception {
        String ref = orphan(openRequestWithOffer()); // 1. deneme (banka dönüşü)
        when(gateway.refundState(anyLong())).thenReturn(RefundState.NOT_REFUNDED);
        Instant t = Instant.now();
        for (int i = 2; i <= 7; i++) {
            t = t.plus(Duration.ofDays(1));
            sweeper.run(t);
            assertThat(state(ref)).isEqualTo("LOCKED/OFFER_EXPIRED/" + i);
        }
        t = t.plus(Duration.ofDays(1));
        sweeper.run(t); // 8. deneme
        assertThat(state(ref)).isEqualTo("LOCKED/REFUND_NEEDS_REVIEW/8");
        assertThat(jdbc.queryForObject("select error_message from escrow_payment where ref = ?", String.class, ref))
                .contains("Destek ekibi");

        clearInvocations(gateway);
        sweeper.run(t.plus(Duration.ofDays(30)));
        sweeper.run(t.plus(Duration.ofDays(60)));
        verify(gateway, never()).refundFully(anyLong(), anyString());
        verify(gateway, never()).refundState(anyLong());
        assertThat(state(ref)).isEqualTo("LOCKED/REFUND_NEEDS_REVIEW/8");
    }

    @Test
    void backoffGrowsAndIsCapped() {
        assertThat(com.bitadilat.payment.domain.EscrowPayment.refundBackoff(1)).isEqualTo(Duration.ofMinutes(5));
        assertThat(com.bitadilat.payment.domain.EscrowPayment.refundBackoff(2)).isEqualTo(Duration.ofMinutes(10));
        assertThat(com.bitadilat.payment.domain.EscrowPayment.refundBackoff(4)).isEqualTo(Duration.ofMinutes(40));
        assertThat(com.bitadilat.payment.domain.EscrowPayment.refundBackoff(7)).isEqualTo(Duration.ofMinutes(320));
        assertThat(com.bitadilat.payment.domain.EscrowPayment.refundBackoff(30)).isEqualTo(Duration.ofHours(6));
    }

    // ─── takılı 3DS ─────────────────────────────────────────────────────────

    private String stale(Setup s) throws Exception {
        String ref = initPayment(s.customer(), s.offerId());
        jdbc.update("update escrow_payment set created_at = now() - interval '31 minutes' where ref = ?", ref);
        return ref;
    }

    private String st(String ref) {
        return jdbc.queryForObject("select status || '/' || coalesce(error_code, '-') from escrow_payment where ref = ?",
                String.class, ref);
    }

    @Test
    void staleInitializedPaymentThatSucceededAtCraftgateOpensTheJob() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("LOCKED/-");
        assertThat(count("select count(*) from jobs where request_id = ?::uuid", s.requestId())).isEqualTo(1);
        assertThat(jdbc.queryForObject("select job_id from escrow_payment where ref = ?", String.class, ref)).isNotNull();
    }

    @Test
    void staleInitializedPaymentThatSucceededAfterTheRequestWasAssignedIsRefunded() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        jdbc.update("update service_requests set status = 'ASSIGNED' where id = ?::uuid", s.requestId());
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("REFUNDED_TO_CUSTOMER/REQUEST_ALREADY_ASSIGNED");
        verify(gateway, times(1)).refundFully(anyLong(), anyString());
        assertThat(count("select count(*) from jobs")).isZero();
    }

    @Test
    void staleInitializedPaymentThatFailedAtCraftgateBecomesFailedAndTheCustomerCanRetry() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isConflict()); // takılı ödeme kilitliyor
        doReturn(
                new GatewayPayment(1L, Status.FAILURE, null, "x", "NOT_SUFFICIENT_FUNDS")).when(gateway).retrieve(anyLong());
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("FAILED/PAYMENT_DECLINED");
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isOk());
        assertThat(count("select count(*) from jobs")).isZero();
    }

    @Test
    void staleInitializedPaymentNeverCompletedAtCraftgateIsAbandonedAndTheCustomerCanRetry() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        doReturn(new GatewayPayment(1L, Status.IN_PROGRESS, null, "x", null)).when(gateway).retrieve(anyLong());
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("FAILED/THREEDS_ABANDONED");
        verify(gateway, never()).complete3ds(anyLong());
        initPaymentRaw(s.customer(), s.offerId(), newKey()).andExpect(status().isOk());
    }

    @Test
    void staleInitializedPaymentIsUntouchedWhenCraftgateDoesNotAnswerAndYoungOnesAreIgnored() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        doThrow(new GatewayException("zaman aşımı", true)).when(gateway).retrieve(anyLong());
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("INITIALIZED/-");
        verify(gateway, times(1)).retrieve(anyLong());

        // Craftgate dönünce sonraki turda kapanır.
        doReturn(new GatewayPayment(1L, Status.FAILURE, null, "x", null)).when(gateway).retrieve(anyLong());
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("FAILED/PAYMENT_DECLINED");

        // 30 dakikadan genç kayıt sorgulanmaz.
        clearInvocations(gateway);
        String fresh = initPayment(s.customer(), s.offerId());
        sweeper.run(Instant.now());
        verify(gateway, never()).retrieve(anyLong());
        assertThat(st(fresh)).isEqualTo("INITIALIZED/-");
    }

    // ─── yarış ──────────────────────────────────────────────────────────────

    @Test
    void sweeperSkipsARowThatARealCallbackHoldsAndNeverBlocksOrDoubleProcesses() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        clearInvocations(gateway);
        try (Connection holder = jdbc.getDataSource().getConnection()) {
            holder.setAutoCommit(false);
            try (var st = holder.prepareStatement("select 1 from escrow_payment where ref = ? for update")) {
                st.setString(1, ref);
                st.executeQuery();
            }
            long started = System.nanoTime();
            payments.reconcileStale(ref); // beklerse test kilitlenir; SKIP LOCKED hemen döner
            assertThat(Duration.ofNanos(System.nanoTime() - started)).isLessThan(Duration.ofSeconds(5));
            holder.rollback();
        }
        verify(gateway, never()).retrieve(anyLong());
        assertThat(st(ref)).isEqualTo("INITIALIZED/-");
    }

    @Test
    void sweeperAndCallbackRunningTogetherProduceExactlyOneOutcome() throws Exception {
        Setup s = openRequestWithOffer();
        String ref = stale(s);
        ExecutorService pool = Executors.newFixedThreadPool(2);
        try {
            CountDownLatch go = new CountDownLatch(1);
            Future<Integer> cb = pool.submit(() -> {
                go.await();
                return callback(ref).andReturn().getResponse().getStatus();
            });
            Future<?> sw = pool.submit(() -> {
                go.await();
                sweeper.run(Instant.now());
                return null;
            });
            go.countDown();
            cb.get(30, TimeUnit.SECONDS);
            sw.get(30, TimeUnit.SECONDS);
        } finally {
            pool.shutdownNow();
        }
        // Sweeper atlamış olabilir; bir tur daha çalışması zararsız olmalı.
        sweeper.run(Instant.now());
        assertThat(st(ref)).isEqualTo("LOCKED/-");
        assertThat(count("select count(*) from jobs where request_id = ?::uuid", s.requestId())).isEqualTo(1);
        assertThat(notifications(s.pro(), "OFFER_ACCEPTED")).isEqualTo(1);
        verify(gateway, never()).refundFully(anyLong(), anyString());
    }
}
