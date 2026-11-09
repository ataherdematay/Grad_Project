package com.bitadilat.common;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Para tutarları: TRY, 2 ondalık. */
public final class Money {

    public static final BigDecimal FEE_RATE = new BigDecimal("0.10");

    private Money() {
    }

    public static BigDecimal of(BigDecimal value) {
        return value == null ? null : value.setScale(2, RoundingMode.HALF_UP);
    }

    public static BigDecimal of(String value) {
        return of(new BigDecimal(value));
    }
}
