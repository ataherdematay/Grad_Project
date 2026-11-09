package com.bitadilat.pro.dto;

import com.bitadilat.pro.DocumentType;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

/** Herkese açık usta profili. Telefon ve e-posta asla yok. */
public record PublicPro(UUID id, String businessName, String fullName, String bio, int experienceYears,
                        BigDecimal ratingAvg, int ratingCount, int completedJobs, Instant memberSince,
                        List<String> categoryIds, List<District> districts, List<DocumentType> verifiedDocuments) {

    public record District(Integer id, String name) {
    }
}
