package com.bitadilat.pro;

import com.bitadilat.catalog.District;
import com.bitadilat.catalog.DistrictRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.common.Paging;
import com.bitadilat.pro.dto.PublicPro;
import com.bitadilat.pro.dto.ReviewList;
import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import java.util.List;
import java.util.Locale;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Müşterinin gördüğü herkese açık usta profili ve değerlendirmeleri. Yalnızca APPROVED ustalar. */
@Service
public class ProPublicService {

    private final ProProfileRepository profiles;
    private final ProCategoryRepository proCategories;
    private final ProDistrictRepository proDistricts;
    private final ProDocumentRepository documents;
    private final DistrictRepository districts;
    private final UserRepository users;
    private final JdbcTemplate jdbc;

    public ProPublicService(ProProfileRepository profiles, ProCategoryRepository proCategories,
                            ProDistrictRepository proDistricts, ProDocumentRepository documents,
                            DistrictRepository districts, UserRepository users, JdbcTemplate jdbc) {
        this.profiles = profiles;
        this.proCategories = proCategories;
        this.proDistricts = proDistricts;
        this.documents = documents;
        this.districts = districts;
        this.users = users;
        this.jdbc = jdbc;
    }

    private ProProfile approved(UUID id) {
        return profiles.findById(id).filter(p -> p.getReviewStatus() == ReviewStatus.APPROVED)
                .orElseThrow(() -> ApiException.notFound("Usta bulunamadı."));
    }

    @Transactional(readOnly = true)
    public PublicPro get(UUID id) {
        ProProfile p = approved(id);
        User u = users.findById(id).orElseThrow(() -> ApiException.notFound("Usta bulunamadı."));
        List<PublicPro.District> ds = proDistricts.findByProId(id).stream()
                .map(pd -> districts.findById(pd.getDistrictId()).orElse(null))
                .filter(d -> d != null)
                .sorted(java.util.Comparator.comparing(District::getName))
                .map(d -> new PublicPro.District(d.getId(), d.getName())).toList();
        List<DocumentType> verified = documents.findByProId(id).stream()
                .filter(d -> d.getStatus() == DocumentStatus.ACCEPTED).map(ProDocument::getType).distinct().sorted()
                .toList();
        return new PublicPro(id, p.getBusinessName(), u.getFullName(), p.getBio(), p.getExperienceYears(),
                p.getRatingAvg(), p.getRatingCount(), p.getCompletedJobs(), u.getCreatedAt(),
                proCategories.findByProId(id).stream().map(ProCategory::getCategoryId).sorted().toList(), ds, verified);
    }

    @Transactional(readOnly = true)
    public ReviewList reviews(UUID id, String cursor, Integer limit) {
        approved(id);
        List<ReviewList.Item> all = jdbc.query("""
                select r.id, r.rating, r.tags, r.comment, r.is_anonymous, u.full_name, r.created_at
                from reviews r join users u on u.id = r.customer_id
                where r.pro_id = ? order by r.created_at desc, r.id""", (rs, i) -> {
            java.sql.Array arr = rs.getArray("tags");
            List<String> tags = arr == null ? List.of() : List.of((String[]) arr.getArray());
            return new ReviewList.Item(rs.getObject("id", UUID.class), rs.getInt("rating"), tags,
                    rs.getString("comment"),
                    rs.getBoolean("is_anonymous") ? "Anonim" : initials(rs.getString("full_name")),
                    rs.getTimestamp("created_at").toInstant());
        }, id);
        Paging.Slice<ReviewList.Item> page = Paging.slice(all, cursor, limit);
        return new ReviewList(page.items(), page.nextCursor());
    }

    /** "Ali Yılmaz" → "A.Y."; tek isim → "A."; boşsa "Anonim". */
    public static String initials(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "Anonim";
        }
        String[] parts = fullName.trim().split("\\s+");
        Locale tr = Locale.forLanguageTag("tr-TR");
        String first = parts[0].substring(0, 1).toUpperCase(tr) + ".";
        return parts.length == 1 ? first : first + parts[parts.length - 1].substring(0, 1).toUpperCase(tr) + ".";
    }
}
