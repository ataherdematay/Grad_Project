package com.bitadilat.payment.dto;

import jakarta.validation.constraints.NotNull;

public record RefundRequest(@NotNull Type type) {

    public enum Type {
        FULL,
        SPLIT_50_50
    }
}
