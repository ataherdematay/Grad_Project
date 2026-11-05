package com.bitadilat.payment.domain;

/** Güvence havuzu kaydının yaşam döngüsü. docs/API_CONTRACT.md ile aynı adlar kullanılır. */
public enum EscrowStatus {
    /** 3DS başladı, banka sonucu henüz yok. Kartta para çekilmiş sayılmaz. */
    INITIALIZED,
    /** Ödeme alındı, para havuzda bekliyor. */
    LOCKED,
    /** Müşteri itiraz etti, karar verilene kadar para hareket etmez. */
    DISPUTED,
    /** Usta payı defterde serbest bırakıldı. */
    RELEASED_TO_PRO,
    /** Tutarın tamamı Craftgate üzerinden müşteriye iade edildi. */
    REFUNDED_TO_CUSTOMER,
    /** Hakem kararıyla tutarın yarısı iade edildi, yarısı ustaya yazıldı. */
    SPLIT_SETTLED,
    /** Ödeme alınamadı. */
    FAILED
}
