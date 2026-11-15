package com.bitadilat.admin;

import com.bitadilat.admin.AdminDtos.ProBrief;
import com.bitadilat.admin.AdminDtos.UserItem;
import com.bitadilat.admin.AdminDtos.UserList;
import com.bitadilat.auth.RefreshTokenRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.user.UserStatus;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Hesap listesi, askıya alma ve yeniden etkinleştirme (STATE_MACHINES §1). Askı: tüm oturumlar kapanır
 * ({@code revokeAllForUser}), bekleyen teklifler {@code WITHDRAWN} olur, açık işlere dokunulmaz. Admin hesabı
 * (kendisi dahil) askıya alınamaz.
 */
@Service
public class AdminAccountService {

    static final int MAX_ITEMS = 500;

    private static final String SELECT = """
            select u.id, u.full_name, u.email, u.phone, u.is_admin, u.status, u.created_at,
                   p.business_name, p.review_status
            from users u left join pro_profiles p on p.user_id = u.id""";

    private final JdbcTemplate jdbc;
    private final RefreshTokenRepository refreshTokens;
    private final AdminAudit audit;

    public AdminAccountService(JdbcTemplate jdbc, RefreshTokenRepository refreshTokens, AdminAudit audit) {
        this.jdbc = jdbc;
        this.refreshTokens = refreshTokens;
        this.audit = audit;
    }

    /**
     * {@code role}: ADMIN = admin bayrağı, PRO = usta profili olanlar, CUSTOMER = ne admin ne usta olanlar.
     * En yeni hesap önce; en çok {@value #MAX_ITEMS} satır.
     */
    @Transactional(readOnly = true)
    public UserList list(String q, String role, String status) {
        List<Object> args = new ArrayList<>();
        StringBuilder sql = new StringBuilder(SELECT).append(" where true");
        if (q != null && !q.isBlank()) {
            sql.append(" and (u.full_name ilike ? escape '\\' or u.email ilike ? escape '\\'"
                    + " or u.phone ilike ? escape '\\' or p.business_name ilike ? escape '\\')");
            String like = AdminAudit.likePattern(q);
            args.add(like);
            args.add(like);
            args.add(AdminAudit.likePattern(q.replaceAll("\\s+", "")));
            args.add(like);
        }
        if (role != null && !role.isBlank()) {
            switch (role.trim()) {
                case "ADMIN" -> sql.append(" and u.is_admin");
                case "PRO" -> sql.append(" and p.user_id is not null");
                case "CUSTOMER" -> sql.append(" and not u.is_admin and p.user_id is null");
                default -> throw ApiException.validation("role", "role CUSTOMER, PRO veya ADMIN olmalı.");
            }
        }
        if (status != null && !status.isBlank()) {
            args.add(AdminAudit.parseEnum(UserStatus.class, status, "status").name());
            sql.append(" and u.status = ?");
        }
        sql.append(" order by u.created_at desc, u.id desc limit ").append(MAX_ITEMS);
        return new UserList(jdbc.query(sql.toString(), (rs, i) -> item(rs, null), args.toArray()));
    }

    @Transactional
    public UserItem suspend(UUID adminId, UUID userId, String rawNote) {
        String note = AdminAudit.requiredNote(rawNote, 10, 1000);
        Boolean isAdmin = jdbc.queryForList("select is_admin from users where id = ?", Boolean.class, userId)
                .stream().findFirst().orElseThrow(() -> ApiException.notFound("Kullanıcı bulunamadı."));
        if (isAdmin || adminId.equals(userId)) {
            throw ApiException.illegalState("Admin hesabı askıya alınamaz.");
        }
        int changed = jdbc.update("update users set status = 'SUSPENDED', updated_at = now() "
                + "where id = ? and status = 'ACTIVE'", userId);
        if (changed == 0) {
            throw ApiException.illegalState("Hesap yalnızca ACTIVE iken askıya alınır.");
        }
        refreshTokens.revokeAllForUser(userId, Instant.now());
        jdbc.update("update offers set status = 'WITHDRAWN', updated_at = now(), version = version + 1 "
                + "where pro_id = ? and status = 'PENDING'", userId);
        Integer activeJobs = jdbc.queryForObject("""
                select count(*) from jobs where (customer_id = ? or pro_id = ?)
                  and status not in ('COMPLETED', 'CANCELLED', 'RESOLVED')""", Integer.class, userId, userId);
        audit.record(adminId, "SUSPEND_USER", AdminAudit.USER, userId, note);
        return fetch(userId, activeJobs == null ? 0 : activeJobs);
    }

    @Transactional
    public UserItem reactivate(UUID adminId, UUID userId) {
        boolean exists = Boolean.TRUE.equals(jdbc.queryForObject(
                "select exists (select 1 from users where id = ?)", Boolean.class, userId));
        if (!exists) {
            throw ApiException.notFound("Kullanıcı bulunamadı.");
        }
        int changed = jdbc.update("update users set status = 'ACTIVE', updated_at = now() "
                + "where id = ? and status = 'SUSPENDED'", userId);
        if (changed == 0) {
            throw ApiException.illegalState("Yalnızca SUSPENDED hesap yeniden etkinleştirilir.");
        }
        audit.record(adminId, "REACTIVATE_USER", AdminAudit.USER, userId, null);
        return fetch(userId, null);
    }

    private UserItem fetch(UUID userId, Integer activeJobCount) {
        return jdbc.queryForObject(SELECT + " where u.id = ?", (rs, i) -> item(rs, activeJobCount), userId);
    }

    private static UserItem item(java.sql.ResultSet rs, Integer activeJobCount) throws java.sql.SQLException {
        String business = rs.getString("business_name");
        ProBrief pro = business == null ? null
                : new ProBrief(business, ReviewStatus.valueOf(rs.getString("review_status")));
        return new UserItem(rs.getObject("id", UUID.class), rs.getString("full_name"), rs.getString("email"),
                rs.getString("phone"), rs.getBoolean("is_admin"), UserStatus.valueOf(rs.getString("status")),
                rs.getTimestamp("created_at").toInstant(), pro, activeJobCount);
    }
}
