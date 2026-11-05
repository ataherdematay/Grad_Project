package com.bitadilat.payment.dto;

import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowStatus;
import java.math.BigDecimal;

public record PaymentView(
        String ref,
        EscrowStatus status,
        String offerId,
        String jobRef,
        String proName,
        BigDecimal totalAmount,
        BigDecimal commission,
        BigDecimal proPayout,
        BigDecimal refundedAmount,
        String cardLast4,
        Long craftgatePaymentId,
        String errorMessage,
        boolean resultUncertain) {

    public static PaymentView from(EscrowPayment p, String proName) {
        return new PaymentView(
                p.getRef(),
                p.getStatus(),
                p.getOfferId(),
                p.getJobRef(),
                proName,
                p.getTotalAmount(),
                p.getCommission(),
                p.getProPayout(),
                p.getRefundedAmount(),
                p.getCardLast4(),
                p.getCraftgatePaymentId(),
                p.getErrorMessage(),
                p.isResultUncertain() || p.getStatus() == EscrowStatus.INITIALIZED);
    }
}
