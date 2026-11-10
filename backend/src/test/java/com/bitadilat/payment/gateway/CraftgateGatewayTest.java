package com.bitadilat.payment.gateway;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.bitadilat.payment.gateway.PaymentGateway.RefundState;
import com.bitadilat.payment.gateway.PaymentGateway.Status;
import io.craftgate.Craftgate;
import io.craftgate.adapter.PaymentAdapter;
import io.craftgate.adapter.PaymentReportingAdapter;
import io.craftgate.model.PaymentRefundStatus;
import io.craftgate.model.PaymentStatus;
import io.craftgate.model.RefundStatus;
import io.craftgate.response.PaymentResponse;
import io.craftgate.response.ReportingPaymentRefundResponse;
import io.craftgate.response.ReportingPaymentResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

/** Craftgate SDK yanıtlarının servis katmanının kararlarına eşlenmesi (SDK 1.0.82). */
class CraftgateGatewayTest {

    private static final long PAYMENT_ID = 77L;

    private PaymentAdapter payment;
    private PaymentReportingAdapter reporting;
    private CraftgateGateway gateway;

    @BeforeEach
    void setUp() {
        Craftgate craftgate = mock(Craftgate.class);
        payment = mock(PaymentAdapter.class);
        reporting = mock(PaymentReportingAdapter.class);
        when(craftgate.payment()).thenReturn(payment);
        when(craftgate.paymentReporting()).thenReturn(reporting);
        gateway = new CraftgateGateway(craftgate, "");
    }

    private Status retrieved(PaymentStatus status) {
        PaymentResponse response = new PaymentResponse();
        response.setId(PAYMENT_ID);
        response.setPaymentStatus(status);
        when(payment.retrievePayment(PAYMENT_ID)).thenReturn(response);
        return gateway.retrieve(PAYMENT_ID).status();
    }

    @Test
    void threeDsNotCompletedIsInProgressButWaitingIsStillProcessingAtTheBank() {
        assertThat(retrieved(PaymentStatus.INIT_THREEDS)).isEqualTo(Status.IN_PROGRESS);
        assertThat(retrieved(PaymentStatus.CALLBACK_THREEDS)).isEqualTo(Status.IN_PROGRESS);
        // WAITING: tamamlama gönderilmiş, banka sonucu bekleniyor. Para çekilebilir; "3DS terk edildi" sayılmamalı.
        assertThat(retrieved(PaymentStatus.WAITING)).isNotEqualTo(Status.IN_PROGRESS);
        assertThat(retrieved(PaymentStatus.SUCCESS)).isEqualTo(Status.SUCCESS);
        assertThat(retrieved(PaymentStatus.FAILURE)).isEqualTo(Status.FAILURE);
    }

    private RefundState refundState(PaymentRefundStatus status, RefundStatus... refunds) {
        ReportingPaymentResponse report = new ReportingPaymentResponse();
        report.setId(PAYMENT_ID);
        report.setRefundStatus(status);
        report.setRefunds(java.util.Arrays.stream(refunds).map(s -> {
            ReportingPaymentRefundResponse r = new ReportingPaymentRefundResponse();
            r.setStatus(s);
            return r;
        }).toList());
        when(reporting.retrievePayment(PAYMENT_ID)).thenReturn(report);
        return gateway.refundState(PAYMENT_ID);
    }

    @Test
    void onlyFullyRefundedCountsAsFullyRefunded() {
        assertThat(refundState(PaymentRefundStatus.FULLY_REFUNDED, RefundStatus.SUCCESS))
                .isEqualTo(RefundState.FULLY_REFUNDED);
        // %50/%50 uzlaşma veya elle yapılmış kısmi iade tam iade sayılmaz.
        assertThat(refundState(PaymentRefundStatus.PARTIAL_REFUNDED, RefundStatus.SUCCESS))
                .isEqualTo(RefundState.PARTIALLY_REFUNDED);
        assertThat(refundState(PaymentRefundStatus.NOT_REFUNDED)).isEqualTo(RefundState.NOT_REFUNDED);
        assertThat(refundState(PaymentRefundStatus.NO_REFUND)).isEqualTo(RefundState.NOT_REFUNDED);
        assertThat(refundState(null)).isEqualTo(RefundState.NOT_REFUNDED);
        // Başarısız iade kaydı iade sayılmaz.
        assertThat(refundState(PaymentRefundStatus.NOT_REFUNDED, RefundStatus.FAILURE))
                .isEqualTo(RefundState.NOT_REFUNDED);
    }

    @Test
    void aRefundStillWaitingAtCraftgateIsNotReportedAsNotRefunded() {
        // Önceki iade isteği zaman aşımına düştü ama Craftgate kabul etti, banka sonucu bekleniyor: ikinci iade
        // gönderilmemeli.
        assertThat(refundState(PaymentRefundStatus.NOT_REFUNDED, RefundStatus.WAITING))
                .isNotEqualTo(RefundState.NOT_REFUNDED);
        // Toplam durum henüz güncellenmemiş ama başarılı iade kaydı var: "iade yok" denmez.
        assertThat(refundState(PaymentRefundStatus.NOT_REFUNDED, RefundStatus.SUCCESS))
                .isNotEqualTo(RefundState.NOT_REFUNDED);
    }
}
