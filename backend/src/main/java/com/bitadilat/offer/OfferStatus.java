package com.bitadilat.offer;

import com.bitadilat.common.ApiException;
import java.util.EnumSet;
import java.util.Set;

/**
 * Teklif durum makinesi (docs/spec/STATE_MACHINES.md §3). Geçişler yalnızca {@link #to} ile yapılır; tabloda olmayan
 * geçiş 409 ILLEGAL_STATE. Kabul/üstlenme geçişleri ödeme dalgasında kullanılacak, tablo şimdiden eksiksizdir.
 */
public enum OfferStatus {
    PENDING, ACCEPTED, DECLINED, WITHDRAWN, SUPERSEDED, EXPIRED;

    private Set<OfferStatus> allowed() {
        return switch (this) {
            case PENDING -> EnumSet.of(ACCEPTED, SUPERSEDED, DECLINED, WITHDRAWN, EXPIRED);
            case SUPERSEDED -> EnumSet.of(PENDING);
            case ACCEPTED -> EnumSet.of(WITHDRAWN);
            case DECLINED, WITHDRAWN, EXPIRED -> EnumSet.noneOf(OfferStatus.class);
        };
    }

    public boolean canMoveTo(OfferStatus target) {
        return allowed().contains(target);
    }

    /** Geçerliyse hedefi döner, değilse 409 ILLEGAL_STATE fırlatır. */
    public OfferStatus to(OfferStatus target) {
        if (!canMoveTo(target)) {
            throw ApiException.illegalState("Teklif " + this + " durumundan " + target + " durumuna geçemez.");
        }
        return target;
    }
}
