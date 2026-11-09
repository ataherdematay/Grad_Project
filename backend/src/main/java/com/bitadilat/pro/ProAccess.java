package com.bitadilat.pro;

import com.bitadilat.common.ApiException;
import com.bitadilat.request.ServiceRequest;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/** Usta uç noktalarının ortak kapısı: onaylı usta şartı ve talebe eşleşme kontrolü. */
@Component
public class ProAccess {

    private final ProProfileRepository profiles;
    private final ProCategoryRepository proCategories;
    private final ProDistrictRepository proDistricts;

    public ProAccess(ProProfileRepository profiles, ProCategoryRepository proCategories,
                     ProDistrictRepository proDistricts) {
        this.profiles = profiles;
        this.proCategories = proCategories;
        this.proDistricts = proDistricts;
    }

    /** Profil yoksa veya durumu APPROVED değilse 403 PRO_NOT_APPROVED. */
    public ProProfile requireApproved(UUID userId) {
        return profiles.findById(userId)
                .filter(p -> p.getReviewStatus() == ReviewStatus.APPROVED)
                .orElseThrow(() -> new ApiException(HttpStatus.FORBIDDEN, "PRO_NOT_APPROVED",
                        "Usta profili onaylı değil."));
    }

    /** Ustanın kategorisi ve ilçesi talebe uyuyor ve talep ustanın kendisine ait değil. Durum/müsaitlik bakılmaz. */
    public boolean matches(UUID proId, ServiceRequest r) {
        return !r.getCustomerId().equals(proId)
                && proCategories.existsByProIdAndCategoryId(proId, r.getCategoryId())
                && proDistricts.existsByProIdAndDistrictId(proId, r.getDistrictId());
    }
}
