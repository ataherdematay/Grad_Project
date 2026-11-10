package com.bitadilat.payment.dto;

import com.bitadilat.payment.domain.EscrowStatus;
import java.math.BigDecimal;
import java.util.UUID;

/**
 * Uygulama kanalı ödeme sonucu. {@code errorCode}: PAYMENT_DECLINED, REQUEST_ALREADY_ASSIGNED, OFFER_EXPIRED veya
 * RESULT_UNCERTAIN. {@code errorMessage} kullanıcıya gösterilebilir Türkçe metindir. Kart numarası ve CVC hiç yok.
 */
public record PaymentResult(String ref, EscrowStatus status, UUID offerId, UUID requestId, UUID jobId,
                            BigDecimal totalAmount, String cardLast4, String errorCode, String errorMessage,
                            boolean resultUncertain) {
}
