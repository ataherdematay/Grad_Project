package com.bitadilat.job;

import java.util.EnumSet;
import java.util.Set;

/** Müşteri ve usta iptal gerekçeleri (sözleşme). */
public enum JobCancelReason {
    PLANS_CHANGED, SOLVED, PRO_UNREACHABLE, OTHER_PROVIDER, OTHER,
    SCHEDULE_CONFLICT, CANNOT_DO_JOB, CUSTOMER_UNREACHABLE;

    private static final Set<JobCancelReason> CUSTOMER = EnumSet.of(PLANS_CHANGED, SOLVED, PRO_UNREACHABLE,
            OTHER_PROVIDER, OTHER);
    private static final Set<JobCancelReason> PRO = EnumSet.of(SCHEDULE_CONFLICT, CANNOT_DO_JOB,
            CUSTOMER_UNREACHABLE, OTHER);

    public boolean allowedFor(ActorRole role) {
        return role == ActorRole.CUSTOMER ? CUSTOMER.contains(this) : PRO.contains(this);
    }
}
