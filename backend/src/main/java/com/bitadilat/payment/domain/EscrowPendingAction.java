package com.bitadilat.payment.domain;

/**
 * Kaydedilmiş ama henüz Craftgate'te yapılmamış para hareketi (outbox). İşlem kesinleştikten sonra denenir; başarısız
 * olursa ödeme toplayıcısı artan aralıkla yeniden dener.
 */
public enum EscrowPendingAction {
    /** İş iptal edildi; tam iade bekliyor. */
    REFUND,
    /** İş tamamlandı; ustaya aktarım öncesi Craftgate'teki iade kontrolü yapılamadı. */
    RELEASE
}
