package com.bitadilat.user;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class AccountTest extends ApiTestBase {

    private static final String ME = "/api/v1/me";
    private static final String ADDRESSES = "/api/v1/me/addresses";

    // ─── /me ────────────────────────────────────────────────────────────────

    @Test
    void meReturnsContractShape() throws Exception {
        Account a = register();
        JsonNode me = body(call(HttpMethod.GET, ME, a.access(), null).andExpect(status().isOk()));

        assertThat(me.propertyNames()).containsExactlyInAnyOrder(
                "id", "fullName", "email", "phone", "locale", "lastMode", "isAdmin", "status", "pro", "unreadNotifications");
        assertThat(me.get("id").asString()).isEqualTo(a.id());
        assertThat(me.get("phone").asString()).matches("\\+90532\\d{7}");
        assertThat(me.get("locale").asString()).isEqualTo("tr");
        assertThat(me.get("isAdmin").asBoolean()).isFalse();
        assertThat(me.get("pro").isNull()).isTrue();
        assertThat(me.get("unreadNotifications").asInt()).isZero();
    }

    @Test
    void patchUpdatesProvidedFieldsOnly() throws Exception {
        Account a = register();
        call(HttpMethod.PATCH, ME, a.access(), Map.of("fullName", "Yeni Ad", "locale", "en"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fullName").value("Yeni Ad"))
                .andExpect(jsonPath("$.locale").value("en"))
                .andExpect(jsonPath("$.lastMode").value("CUSTOMER"));
        call(HttpMethod.GET, ME, a.access(), null)
                .andExpect(jsonPath("$.fullName").value("Yeni Ad"));
    }

    @Test
    void patchRejectsBadValues() throws Exception {
        Account a = register();
        call(HttpMethod.PATCH, ME, a.access(), Map.of("locale", "de"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.field").value("locale"));
        call(HttpMethod.PATCH, ME, a.access(), Map.of("lastMode", "ADMIN"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("lastMode"));
    }

    @Test
    void proModeNeedsProProfile() throws Exception {
        Account a = register();
        call(HttpMethod.PATCH, ME, a.access(), Map.of("lastMode", "PRO"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));

        jdbc.update("insert into pro_profiles (user_id, business_name, review_status) "
                + "values (?::uuid, 'Test Tesisat', 'APPROVED')", a.id());
        call(HttpMethod.PATCH, ME, a.access(), Map.of("lastMode", "PRO"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.lastMode").value("PRO"))
                .andExpect(jsonPath("$.pro.reviewStatus").value("APPROVED"))
                .andExpect(jsonPath("$.pro.availability").value("ACTIVE"))
                .andExpect(jsonPath("$.pro.businessName").value("Test Tesisat"));
    }

    @Test
    void changePasswordRequiresCurrentPassword() throws Exception {
        Account a = register();
        call(HttpMethod.POST, ME + "/password", a.access(),
                Map.of("currentPassword", "Yanlis123", "newPassword", "YeniParola9"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("currentPassword"));
        call(HttpMethod.POST, ME + "/password", a.access(),
                Map.of("currentPassword", PASSWORD, "newPassword", "kisa"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("newPassword"));
        call(HttpMethod.POST, ME + "/password", a.access(),
                Map.of("currentPassword", PASSWORD, "newPassword", "YeniParola9"))
                .andExpect(status().isNoContent());

        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", a.email(), "password", "YeniParola9"))
                .andExpect(status().isOk());
    }

    @Test
    void changePasswordRevokesOtherSessionsButKeepsCurrentFamily() throws Exception {
        Account first = register();
        JsonNode second = body(call(HttpMethod.POST, "/api/v1/auth/login", null,
                Map.of("identifier", first.email(), "password", PASSWORD)).andExpect(status().isOk()));

        call(HttpMethod.POST, ME + "/password", second.get("accessToken").asString(),
                Map.of("currentPassword", PASSWORD, "newPassword", "YeniParola9"))
                .andExpect(status().isNoContent());

        call(HttpMethod.POST, "/api/v1/auth/refresh", null, Map.of("refreshToken", first.refresh()))
                .andExpect(status().isUnauthorized());
        call(HttpMethod.POST, "/api/v1/auth/refresh", null, Map.of("refreshToken", second.get("refreshToken").asString()))
                .andExpect(status().isOk());
    }

    @Test
    void changePasswordWithoutFamilyClaimRevokesAllSessions() throws Exception {
        Account a = register();
        String legacy = jwt.issueAccessToken(java.util.UUID.fromString(a.id()));

        call(HttpMethod.POST, ME + "/password", legacy,
                Map.of("currentPassword", PASSWORD, "newPassword", "YeniParola9"))
                .andExpect(status().isNoContent());

        call(HttpMethod.POST, "/api/v1/auth/refresh", null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void deletedAccountIsAnonymizedAndCannotLogIn() throws Exception {
        Account a = register();
        call(HttpMethod.POST, ADDRESSES, a.access(), addressBody("Ev", "Moda Cad. No: 1")).andExpect(status().isCreated());

        call(HttpMethod.DELETE, ME, a.access(), null).andExpect(status().isNoContent());

        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("BAD_CREDENTIALS"));
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", a.phone(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());
        call(HttpMethod.GET, ME, a.access(), null).andExpect(status().isUnauthorized());
        call(HttpMethod.POST, "/api/v1/auth/refresh", null, Map.of("refreshToken", a.refresh()))
                .andExpect(status().isUnauthorized());

        Map<String, Object> row = jdbc.queryForMap(
                "select email, phone, full_name, status, deleted_at from users where id = ?::uuid", a.id());
        assertThat(row.get("status")).isEqualTo("DELETED");
        assertThat(row.get("phone")).isNull();
        assertThat((String) row.get("email")).startsWith("deleted-").doesNotContain(a.email());
        assertThat(row.get("full_name")).isEqualTo("Silinmiş kullanıcı");
        assertThat(row.get("deleted_at")).isNotNull();
        assertThat(jdbc.queryForObject("select count(*) from addresses where user_id = ?::uuid", Long.class, a.id()))
                .isZero();

        // E-posta ve telefon yeniden kullanılabilir.
        call(HttpMethod.POST, "/api/v1/auth/register", null, registerBody(a.email(), a.phone()))
                .andExpect(status().isCreated());
    }

    @Test
    void deleteReasonIsStoredForAnalyticsWithoutAnyLinkToTheUser() throws Exception {
        long before = jdbc.queryForObject("select count(*) from account_deletion_feedback where reason = 'PRIVACY'",
                Long.class);
        Account a = register();
        call(HttpMethod.DELETE, ME, a.access(), Map.of("reason", "PRIVACY")).andExpect(status().isNoContent());
        assertThat(jdbc.queryForObject("select count(*) from account_deletion_feedback where reason = 'PRIVACY'",
                Long.class)).isEqualTo(before + 1);
        // Tabloda kullanıcı kimliği veya serbest metin sütunu yok.
        assertThat(jdbc.queryForList("select column_name from information_schema.columns "
                + "where table_name = 'account_deletion_feedback'", String.class))
                .containsExactlyInAnyOrder("id", "reason", "had_pro_profile", "created_on");

        Account b = register();
        call(HttpMethod.DELETE, ME, b.access(), Map.of("reason", "BECAUSE")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("reason"));
        // Geçersiz gerekçe hesabı silmez.
        call(HttpMethod.GET, ME, b.access(), null).andExpect(status().isOk());
        long all = jdbc.queryForObject("select count(*) from account_deletion_feedback", Long.class);
        call(HttpMethod.DELETE, ME, b.access(), Map.of()).andExpect(status().isNoContent());
        assertThat(jdbc.queryForObject("select count(*) from account_deletion_feedback", Long.class)).isEqualTo(all);
    }

    @Test
    void emailChangesOnlyAfterTheCodeSentToTheNewAddressIsConfirmed() throws Exception {
        Account a = register();
        String newEmail = uniqueEmail();
        call(HttpMethod.POST, ME + "/email", a.access(), Map.of("newEmail", newEmail, "password", "Yanlis1234"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("password"));
        Account other = register();
        call(HttpMethod.POST, ME + "/email", a.access(), Map.of("newEmail", other.email(), "password", PASSWORD))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("EMAIL_TAKEN"));
        call(HttpMethod.POST, ME + "/email", a.access(), Map.of("newEmail", "bozuk", "password", PASSWORD))
                .andExpect(status().isBadRequest());

        call(HttpMethod.POST, ME + "/email", a.access(), Map.of("newEmail", newEmail, "password", PASSWORD))
                .andExpect(status().isAccepted());
        String code = emails.changeCodeFor(newEmail);
        assertThat(code).matches("\\d{6}");
        // Doğrulanmadan e-posta değişmez.
        assertThat(body(call(HttpMethod.GET, ME, a.access(), null)).get("email").asString()).isEqualTo(a.email());

        String wrong = code.equals("000000") ? "111111" : "000000";
        call(HttpMethod.POST, ME + "/email/confirm", a.access(), Map.of("code", wrong))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("code"));
        JsonNode me = body(call(HttpMethod.POST, ME + "/email/confirm", a.access(), Map.of("code", code))
                .andExpect(status().isOk()));
        assertThat(me.get("email").asString()).isEqualTo(newEmail);
        assertThat(emails.sentTo("notice:" + a.email())).isEqualTo(1);
        // Kod tek kullanımlık.
        call(HttpMethod.POST, ME + "/email/confirm", a.access(), Map.of("code", code))
                .andExpect(status().isBadRequest());
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", newEmail, "password", PASSWORD))
                .andExpect(status().isOk());
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", a.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void emailChangeRevokesOtherSessionsButKeepsCurrentFamily() throws Exception {
        Account first = register();
        JsonNode second = body(call(HttpMethod.POST, "/api/v1/auth/login", null,
                Map.of("identifier", first.email(), "password", PASSWORD)).andExpect(status().isOk()));
        String access = second.get("accessToken").asString();
        String newEmail = uniqueEmail();
        call(HttpMethod.POST, ME + "/email", access, Map.of("newEmail", newEmail, "password", PASSWORD))
                .andExpect(status().isAccepted());
        call(HttpMethod.POST, ME + "/email/confirm", access, Map.of("code", emails.changeCodeFor(newEmail)))
                .andExpect(status().isOk());

        call(HttpMethod.POST, "/api/v1/auth/refresh", null, Map.of("refreshToken", first.refresh()))
                .andExpect(status().isUnauthorized());
        call(HttpMethod.POST, "/api/v1/auth/refresh", null,
                Map.of("refreshToken", second.get("refreshToken").asString())).andExpect(status().isOk());
    }

    @Test
    void emailChangeCodeLocksAfterFiveWrongAttempts() throws Exception {
        Account a = register();
        String newEmail = uniqueEmail();
        call(HttpMethod.POST, ME + "/email", a.access(), Map.of("newEmail", newEmail, "password", PASSWORD))
                .andExpect(status().isAccepted());
        String code = emails.changeCodeFor(newEmail);
        String wrong = code.equals("000000") ? "111111" : "000000";
        for (int i = 0; i < 5; i++) {
            call(HttpMethod.POST, ME + "/email/confirm", a.access(), Map.of("code", wrong))
                    .andExpect(status().isBadRequest());
        }
        call(HttpMethod.POST, ME + "/email/confirm", a.access(), Map.of("code", code))
                .andExpect(status().isBadRequest());
        assertThat(body(call(HttpMethod.GET, ME, a.access(), null)).get("email").asString()).isEqualTo(a.email());
    }

    // ─── Adresler ───────────────────────────────────────────────────────────

    private Map<String, Object> addressBody(String label, String line) {
        Map<String, Object> m = new HashMap<>();
        m.put("label", label);
        m.put("districtId", kadikoyId());
        m.put("neighborhood", "Caferağa");
        m.put("lineFull", line);
        m.put("doorNote", "Zil: Yılmaz");
        return m;
    }

    private int kadikoyId() {
        return jdbc.queryForObject("select id from districts where name = 'Kadıköy'", Integer.class);
    }

    @Test
    void addressIsEncryptedAtRestAndReadableThroughApi() throws Exception {
        Account a = register();
        String line = "Caferağa Mah. Moda Cad. No: 14 Daire: 5";
        JsonNode created = body(call(HttpMethod.POST, ADDRESSES, a.access(), addressBody("Ev", line))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.districtName").value("Kadıköy"))
                .andExpect(jsonPath("$.lineFull").value(line))
                .andExpect(jsonPath("$.doorNote").value("Zil: Yılmaz"))
                .andExpect(jsonPath("$.isDefault").value(true)));
        assertThat(created.propertyNames()).containsExactlyInAnyOrder(
                "id", "label", "districtId", "districtName", "neighborhood", "lineFull", "doorNote", "isDefault");

        Map<String, Object> row = jdbc.queryForMap(
                "select line_full_encrypted, door_note_encrypted, neighborhood from addresses where id = ?::uuid",
                created.get("id").asString());
        assertThat((String) row.get("line_full_encrypted")).doesNotContain("Moda").doesNotContain("Caferağa");
        assertThat((String) row.get("door_note_encrypted")).doesNotContain("Yılmaz");
        // Mahalle şifreli değil (talep eşleşmesi için gerekli, adresin tamamı değil).
        assertThat(row.get("neighborhood")).isEqualTo("Caferağa");

        call(HttpMethod.GET, ADDRESSES, a.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].lineFull").value(line));
    }

    @Test
    void sameTextEncryptsDifferentlyEachTime() throws Exception {
        Account a = register();
        call(HttpMethod.POST, ADDRESSES, a.access(), addressBody("Ev", "Aynı adres 1")).andExpect(status().isCreated());
        call(HttpMethod.POST, ADDRESSES, a.access(), addressBody("İş", "Aynı adres 1")).andExpect(status().isCreated());
        assertThat(jdbc.queryForObject(
                "select count(distinct line_full_encrypted) from addresses where user_id = ?::uuid", Long.class,
                a.id())).isEqualTo(2L);
    }

    @Test
    void otherUsersGetNotFoundForSomeoneElsesAddress() throws Exception {
        Account owner = register();
        Account other = register();
        String id = body(call(HttpMethod.POST, ADDRESSES, owner.access(), addressBody("Ev", "Gizli adres 7")))
                .get("id").asString();

        call(HttpMethod.GET, ADDRESSES + "/" + id, other.access(), null)
                .andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value("NOT_FOUND"));
        call(HttpMethod.PATCH, ADDRESSES + "/" + id, other.access(), Map.of("label", "Çalındı"))
                .andExpect(status().isNotFound());
        call(HttpMethod.DELETE, ADDRESSES + "/" + id, other.access(), null)
                .andExpect(status().isNotFound());
        call(HttpMethod.GET, ADDRESSES, other.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
        // Sahibi etkilenmedi.
        call(HttpMethod.GET, ADDRESSES + "/" + id, owner.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.label").value("Ev"));
    }

    @Test
    void defaultAddressMovesAndIsPromotedOnDelete() throws Exception {
        Account a = register();
        String first = body(call(HttpMethod.POST, ADDRESSES, a.access(), addressBody("Ev", "Adres bir")))
                .get("id").asString();
        JsonNode secondNode = body(call(HttpMethod.POST, ADDRESSES, a.access(), addressBody("İş", "Adres iki"))
                .andExpect(jsonPath("$.isDefault").value(false)));
        String second = secondNode.get("id").asString();

        call(HttpMethod.PATCH, ADDRESSES + "/" + second, a.access(), Map.of("isDefault", true, "label", "Ofis"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.isDefault").value(true))
                .andExpect(jsonPath("$.label").value("Ofis"))
                .andExpect(jsonPath("$.lineFull").value("Adres iki"));
        call(HttpMethod.GET, ADDRESSES + "/" + first, a.access(), null)
                .andExpect(jsonPath("$.isDefault").value(false));
        assertThat(jdbc.queryForObject(
                "select count(*) from addresses where user_id = ?::uuid and is_default", Long.class, a.id()))
                .isEqualTo(1L);

        call(HttpMethod.DELETE, ADDRESSES + "/" + second, a.access(), null).andExpect(status().isNoContent());
        call(HttpMethod.GET, ADDRESSES + "/" + first, a.access(), null)
                .andExpect(jsonPath("$.isDefault").value(true));
    }

    @Test
    void malformedAddressIdIsNotFoundNotServerError() throws Exception {
        Account a = register();
        call(HttpMethod.GET, ADDRESSES + "/uuid-degil", a.access(), null)
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
        call(HttpMethod.DELETE, ADDRESSES + "/123", a.access(), null)
                .andExpect(status().isNotFound());
    }

    @Test
    void addressValidation() throws Exception {
        Account a = register();
        Map<String, Object> bad = addressBody("Ev", "Adres");
        bad.put("districtId", 9999);
        call(HttpMethod.POST, ADDRESSES, a.access(), bad)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("districtId"));
        bad = addressBody("Ev", " ");
        call(HttpMethod.POST, ADDRESSES, a.access(), bad)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("lineFull"));
        call(HttpMethod.POST, ADDRESSES, null, addressBody("Ev", "Adres"))
                .andExpect(status().isUnauthorized());
    }
}
