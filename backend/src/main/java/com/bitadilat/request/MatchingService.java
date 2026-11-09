package com.bitadilat.request;

import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * UC03 eşleştirme: onaylı, müsait (ACTIVE), hesabı aktif; kategori ve ilçeyi kapsayan, talep sahibi olmayan ustalar.
 */
@Service
public class MatchingService {

    public static final List<String> FACTORS = List.of("CATEGORY", "DISTRICT", "AVAILABILITY");

    private final JdbcTemplate jdbc;

    public MatchingService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<UUID> matchedProIds(String categoryId, Integer districtId, UUID customerId) {
        return jdbc.queryForList("""
                select p.user_id from pro_profiles p
                join users u on u.id = p.user_id
                where p.review_status = 'APPROVED' and p.availability = 'ACTIVE' and u.status = 'ACTIVE'
                  and p.user_id <> ?
                  and exists (select 1 from pro_categories c where c.pro_id = p.user_id and c.category_id = ?)
                  and exists (select 1 from pro_districts d where d.pro_id = p.user_id and d.district_id = ?)
                order by p.user_id""", UUID.class, customerId, categoryId, districtId);
    }
}
