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
    void resetClearsLoginThrottling() throws Exception {
        for (int i = 0; i < 5; i++) {
            call(HttpMethod.POST, "/api/v1/auth/login", null,
                    Map.of("identifier", "ali@bitadilat.test", "password", "Yanlis123"))
                    .andExpect(status().isUnauthorized());
        }
        call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", "ali@bitadilat.test", "password", DEMO))
                .andExpect(status().isTooManyRequests());

        // Entegrasyon testleri her senaryodan önce reset çağırır; önceki senaryonun kilidi taşınmamalı.
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
        login("ali@bitadilat.test");
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

    @Test
    void request88412AndItsThreeOffersAreSeeded() throws Exception {
        String access = login("ali@bitadilat.test").get("accessToken").asString();
        JsonNode active = body(call(HttpMethod.GET, "/api/v1/requests?scope=active", access, null)
                // Wave 3: BD-88409 (iş SCHEDULED) de etkin; BD-88407 (iş COMPLETED) geçmişte. En yeni talep BD-88412.
                .andExpect(status().isOk()).andExpect(jsonPath("$.items.length()").value(2)));
        JsonNode r = active.get("items").get(0);
        assertThat(r.get("publicCode").asString()).isEqualTo("BD-88412");
        assertThat(r.get("title").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(r.get("urgency").asString()).isEqualTo("URGENT");
        assertThat(r.get("categoryId").asString()).isEqualTo("plumbing");
        assertThat(r.get("districtName").asString()).isEqualTo("Kadıköy");
        assertThat(r.get("neighborhood").asString()).isEqualTo("Caferağa");
        assertThat(r.get("offerCount").asInt()).isEqualTo(3);
        assertThat(r.get("minOfferTotal").asDouble()).isEqualTo(1850.0);
        assertThat(r.get("maxOfferTotal").asDouble()).isEqualTo(2450.0);

        String id = r.get("id").asString();
        call(HttpMethod.GET, "/api/v1/requests/" + id, access, null)
                .andExpect(jsonPath("$.matchedProCount").value(3))
                .andExpect(jsonPath("$.photos.length()").value(0))
                .andExpect(jsonPath("$.address.lineFull").value("Caferağa Mah. Moda Cad. No: 14 Daire: 5"));

        JsonNode offers = body(call(HttpMethod.GET, "/api/v1/requests/" + id + "/offers?sort=price", access, null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.items.length()").value(3))
                .andExpect(jsonPath("$.declinedCount").value(0)));
        assertThat(offers.get("items").get(0).get("pro").get("businessName").asString()).isEqualTo("Usta Eller Tesisat");
        assertThat(offers.get("items").get(0).get("totalAmount").asDouble()).isEqualTo(1850.0);
        assertThat(offers.get("items").get(0).get("warrantyMonths").asInt()).isEqualTo(3);
        JsonNode mavi = offers.get("items").get(2);
        assertThat(mavi.get("pro").get("businessName").asString()).isEqualTo("Mavi Hat Tesisat");
        assertThat(mavi.get("publicCode").asString()).isEqualTo("T-10001");
        assertThat(mavi.get("laborAmount").asDouble()).isEqualTo(1650.0);
        assertThat(mavi.get("materialsAmount").asDouble()).isEqualTo(800.0);
        assertThat(mavi.get("note").asString()).startsWith("Lavabo altı bağlantılar");

        JsonNode detail = body(call(HttpMethod.GET, "/api/v1/offers/" + mavi.get("id").asString(), access, null)
                .andExpect(status().isOk()));
        assertThat(detail.get("items").size()).isEqualTo(3);
        assertThat(detail.get("items").get(1).get("description").asString()).isEqualTo("Sifon ve bağlantı parçaları");
        assertThat(detail.get("serviceFee").isNull()).isTrue();

        // Varış aralıkları geçerli ve geleceğe dönük; "bugün 14:00" geçmişse yarına kaymış olur.
        assertThat(jdbc.queryForObject("select count(*) from offers where status = 'PENDING' and (arrival_from <= now() or valid_until <= now())",
                Long.class)).isZero();
        assertThat(jdbc.queryForObject("select count(*) from offers where status = 'PENDING' and arrival_to - arrival_from = interval '3 hours'",
                Long.class)).isEqualTo(1L);
    }

    @Test
    void seededProSeesOwnOfferInFeedAndFeeBreakdown() throws Exception {
        String access = login("mehmet@bitadilat.test").get("accessToken").asString();
        JsonNode feed = body(call(HttpMethod.GET, "/api/v1/pro/feed", access, null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.onBreak").value(false))
                .andExpect(jsonPath("$.items.length()").value(1)));
        JsonNode item = feed.get("items").get(0);
        assertThat(item.get("publicCode").asString()).isEqualTo("BD-88412");
        assertThat(item.get("myOfferId").isNull()).isFalse();
        assertThat(item.get("offerCount").asInt()).isEqualTo(3);
        call(HttpMethod.GET, "/api/v1/offers/" + item.get("myOfferId").asString(), access, null)
                .andExpect(jsonPath("$.totalAmount").value(2450.0))
                .andExpect(jsonPath("$.serviceFee").value(245.0))
                .andExpect(jsonPath("$.netEarning").value(2205.0));
        // Elektrik/boya ustaları bu talebi görmez.
        String hasan = login("hasan@bitadilat.test").get("accessToken").asString();
        call(HttpMethod.GET, "/api/v1/pro/feed", hasan, null).andExpect(status().isForbidden());
    }

    @Test
    void resetReloadsRequestAndOffersWithStableCodes() throws Exception {
        String access = login("ali@bitadilat.test").get("accessToken").asString();
        call(HttpMethod.POST, "/api/v1/requests/" + body(call(HttpMethod.GET, "/api/v1/requests?scope=active", access, null))
                .get("items").get(0).get("id").asString() + "/cancel", access, Map.of("reason", "OTHER"))
                .andExpect(status().isOk());
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
        assertThat(jdbc.queryForObject("select count(*) from service_requests where public_code = 'BD-88412' and status = 'OPEN'",
                Long.class)).isEqualTo(1L);
        assertThat(jdbc.queryForObject("select count(*) from offers where status = 'PENDING'", Long.class)).isEqualTo(3L);
        assertThat(jdbc.queryForObject("select string_agg(public_code, ',' order by public_code) from offers where public_code < 'T-20000'",
                String.class)).isEqualTo("T-10001,T-10002,T-10003,T-10004,T-10005,T-10006");
    }
}
