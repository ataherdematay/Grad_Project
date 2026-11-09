package com.bitadilat.request;

import com.bitadilat.common.ApiException;
import java.util.EnumSet;
import java.util.Set;

/**
 * Talep durum makinesi (docs/spec/STATE_MACHINES.md §2). Geçişler yalnızca {@link #to} ile yapılır; tabloda olmayan
 * geçiş 409 ILLEGAL_STATE.
 */
public enum RequestStatus {
    OPEN, ASSIGNED, CANCELLED, EXPIRED;

    private Set<RequestStatus> allowed() {
        return switch (this) {
            case OPEN -> EnumSet.of(ASSIGNED, CANCELLED, EXPIRED);
            case ASSIGNED -> EnumSet.of(OPEN, CANCELLED);
            case CANCELLED, EXPIRED -> EnumSet.noneOf(RequestStatus.class);
        };
    }

    public boolean canMoveTo(RequestStatus target) {
        return allowed().contains(target);
    }

    /** Geçerliyse hedefi döner, değilse 409 ILLEGAL_STATE fırlatır. */
    public RequestStatus to(RequestStatus target) {
        if (!canMoveTo(target)) {
            throw ApiException.illegalState("Talep " + this + " durumundan " + target + " durumuna geçemez.");
        }
        return target;
    }
}
