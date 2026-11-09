package com.bitadilat.dev;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.ActiveProfiles;
import tools.jackson.databind.JsonNode;

/**
 * dev profili: DevSeeder ve /dev/reset. application-dev.properties'in veritabanı adresi testte ezilir,
 * böylece geliştirme veritabanına dokunulmaz.
 */
@ActiveProfiles("dev")
@org.springframework.boot.test.context.SpringBootTest(properties = {
        "spring.datasource.url=${TEST_DB_URL:jdbc:postgresql://localhost:5432/bitadilat_test}",
        "spring.datasource.username=${TEST_DB_USER:${USER}}",
        "spring.datasource.password=${TEST_DB_PASSWORD:}"
})
class DevSeedTest extends ApiTestBase {

    private static final String DEMO = "Demo1234!";

    @BeforeEach
    void reset() throws Exception {
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
    }

    private JsonNode login(String identifier) throws Exception {
        return body(call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", identifier, "password", DEMO))
                .andExpect(status().isOk()));
    }

    @Test
    void allSeedAccountsCanLogInWithDemoPassword() throws Exception {
        assertThat(login("ali@bitadilat.test").get("user").get("fullName").asString()).isEqualTo("Ali Yılmaz");
        assertThat(login("+90 532 849 20 11").get("user").get("email").asString()).isEqualTo("ali@bitadilat.test");
        for (String email : new String[] {"zeynep", "mehmet", "ahmet", "emre", "hasan", "selim", "admin"}) {
            login(email + "@bitadilat.test");
        }
        assertThat(jdbc.queryForObject("select count(*) from users", Long.class)).isEqualTo(8L);
    }

    @Test
    void proProfilesMatchSeedData() throws Exception {
        JsonNode mehmet = login("mehmet@bitadilat.test").get("user");
        assertThat(mehmet.get("pro").get("reviewStatus").asString()).isEqualTo("APPROVED");
        assertThat(mehmet.get("pro").get("availability").asString()).isEqualTo("ACTIVE");
        assertThat(mehmet.get("pro").get("businessName").asString()).isEqualTo("Mavi Hat Tesisat");

        assertThat(login("hasan@bitadilat.test").get("user").get("pro").get("reviewStatus").asString())
                .isEqualTo("PENDING_REVIEW");
        assertThat(login("selim@bitadilat.test").get("user").get("pro").get("reviewStatus").asString())
                .isEqualTo("NEEDS_DOCUMENTS");
        assertThat(login("ali@bitadilat.test").get("user").get("pro").isNull()).isTrue();
        assertThat(login("admin@bitadilat.test").get("user").get("isAdmin").asBoolean()).isTrue();

        assertThat(jdbc.queryForObject("""
                select count(*) from pro_categories pc join pro_profiles p on p.user_id = pc.pro_id
                where p.business_name = 'Mavi Hat Tesisat'""", Long.class)).isEqualTo(2L);
        assertThat(jdbc.queryForObject("""
                select count(*) from pro_districts pd join pro_profiles p on p.user_id = pd.pro_id
                where p.business_name = 'Mavi Hat Tesisat'""", Long.class)).isEqualTo(4L);
    }

    @Test
    void aliHasEncryptedDefaultAddress() throws Exception {
        String access = login("ali@bitadilat.test").get("accessToken").asString();
        call(HttpMethod.GET, "/api/v1/me/addresses", access, null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].districtName").value("Kadıköy"))
                .andExpect(jsonPath("$[0].neighborhood").value("Caferağa"))
                .andExpect(jsonPath("$[0].lineFull").value("Caferağa Mah. Moda Cad. No: 14 Daire: 5"))
                .andExpect(jsonPath("$[0].isDefault").value(true));
    }

    @Test
    void resetDeletesAllDataButKeepsCatalog() throws Exception {
        Account extra = register();
        call(HttpMethod.GET, "/api/v1/me", extra.access(), null).andExpect(status().isOk());

        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());

        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", extra.email(), "password", PASSWORD))
                .andExpect(status().isUnauthorized());
        login("ali@bitadilat.test");
        assertThat(jdbc.queryForObject("select count(*) from categories", Long.class)).isEqualTo(8L);
        assertThat(jdbc.queryForObject("select count(*) from districts", Long.class)).isEqualTo(39L);
    }

    @Test
    void resetIsRefusedFromNonLoopbackAddress() throws Exception {
        mvc.perform(post("/api/v1/dev/reset").with(request -> {
                    request.setRemoteAddr("10.1.2.3");
                    return request;
                }))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
        mvc.perform(post("/api/v1/dev/reset").header("X-Forwarded-For", "127.0.0.1").with(request -> {
                    request.setRemoteAddr("203.0.113.9");
                    return request;
                }))
                .andExpect(status().isForbidden());
    }
}
