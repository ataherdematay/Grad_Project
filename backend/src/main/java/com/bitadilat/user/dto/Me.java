package com.bitadilat.user.dto;

import com.bitadilat.pro.Availability;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.user.UserMode;
import com.bitadilat.user.UserStatus;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.UUID;

/** İstemcinin gördüğü kullanıcı. {@code pro} usta profili yoksa null. */
public record Me(
        UUID id,
        String fullName,
        String email,
        String phone,
        String locale,
        UserMode lastMode,
        @JsonProperty("isAdmin") boolean isAdmin,
        UserStatus status,
        ProSummary pro) {

    public record ProSummary(ReviewStatus reviewStatus, Availability availability, String businessName) {
    }
}
