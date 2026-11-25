package com.bitadilat.payment.domain;

/** {@code escrow_event.type}: emanete ait olaylar. İş kaynaklı olaylar (teslim, onay) zaman çizelgesinde iş kaydından eklenir. */
public enum EscrowEventType {
    PAYMENT_INITIALIZED, THREEDS_STARTED, PAYMENT_LOCKED, FAILED, DISPUTE_OPENED, REFUND_REQUESTED, REFUNDED,
    RELEASED_TO_PRO, SPLIT_SETTLED, REVIEW_REQUIRED
}
