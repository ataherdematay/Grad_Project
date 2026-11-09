package com.bitadilat.offer;

import java.util.UUID;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/** Teklif durum değişikliklerinin toplu ve ortak işleri; talep tarafı da bunu kullanır (talep → teklif tek yönlü). */
@Component
public class OfferLifecycle {

    private final OfferRepository offers;

    public OfferLifecycle(OfferRepository offers) {
        this.offers = offers;
    }

    /** Talebin tüm PENDING tekliflerini EXPIRED yapar (düzenleme, iptal, süre dolumu). Çağıran talebi kilitlemiş olmalı. */
    @Transactional
    public int expirePendingOf(UUID requestId) {
        var pending = offers.findByRequestIdAndStatus(requestId, OfferStatus.PENDING);
        pending.forEach(o -> o.moveTo(OfferStatus.EXPIRED));
        offers.saveAll(pending);
        return pending.size();
    }
}
