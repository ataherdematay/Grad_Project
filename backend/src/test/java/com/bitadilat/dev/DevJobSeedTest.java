package com.bitadilat.dev;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.ApiTestBase;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.test.context.ActiveProfiles;
import tools.jackson.databind.JsonNode;

/**
 * Wave 3 dev seed'i: BD-88409 (SCHEDULED), BD-88407 (COMPLETED + 5 yıldız), BD-88398 (DISPUTED + SK-1001).
 * Craftgate burada sahte değildir: SEED emanetinde iade gateway'e gitmeden defterde işlenir.
 */
@ActiveProfiles("dev")
@org.springframework.boot.test.context.SpringBootTest(properties = {
        "spring.datasource.url=${TEST_DB_URL:jdbc:postgresql://localhost:5432/bitadilat_test}",
        "spring.datasource.username=${TEST_DB_USER:${USER}}",
        "spring.datasource.password=${TEST_DB_PASSWORD:}"
})
class DevJobSeedTest extends ApiTestBase {

    private static final String DEMO = "Demo1234!";
    private static final ZoneId ISTANBUL = ZoneId.of("Europe/Istanbul");

    @BeforeEach
    void reset() throws Exception {
        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
    }

    private String login(String email) throws Exception {
        return body(call(HttpMethod.POST, "/api/v1/auth/login", null, Map.of("identifier", email, "password", DEMO))
                .andExpect(status().isOk())).get("accessToken").asString();
    }

    private JsonNode jobs(String token, String as, String scope) throws Exception {
        return body(call(HttpMethod.GET, "/api/v1/jobs?as=" + as + "&scope=" + scope, token, null)
                .andExpect(status().isOk())).get("items");
    }

    private JsonNode jobByCode(JsonNode items, String code) {
        for (JsonNode j : items) {
            if (code.equals(j.get("publicCode").asString())) {
                return j;
            }
        }
        throw new AssertionError(code + " listede yok");
    }

    private List<String> actions(JsonNode detail) {
        List<String> out = new ArrayList<>();
        detail.get("allowedActions").forEach(n -> out.add(n.asString()));
        return out;
    }

    @Test
    void aliSeesBd88409ScheduledTomorrowAndBd88407Completed() throws Exception {
        String ali = login("ali@bitadilat.test");
        JsonNode active = jobs(ali, "CUSTOMER", "active");
        assertThat(active.size()).isEqualTo(1);
        JsonNode j = jobByCode(active, "BD-88409");
        assertThat(j.get("status").asString()).isEqualTo("SCHEDULED");
        assertThat(j.get("counterpart").get("displayName").asString()).isEqualTo("Mavi Hat Tesisat");
        assertThat(j.get("totalAmount").asDouble()).isEqualTo(1200.0);
        assertThat(j.get("title").asString()).isEqualTo("Kombi petek bakımı");
        assertThat(j.get("unreadMessages").asInt()).isEqualTo(1);

        JsonNode detail = body(call(HttpMethod.GET, "/api/v1/jobs/" + j.get("id").asString(), ali, null)
                .andExpect(status().isOk()));
        LocalDate tomorrow = ZonedDateTime.now(ISTANBUL).toLocalDate().plusDays(1);
        assertThat(java.time.Instant.parse(detail.get("scheduledFrom").asString()).atZone(ISTANBUL))
                .isEqualTo(tomorrow.atTime(10, 0).atZone(ISTANBUL));
        assertThat(java.time.Instant.parse(detail.get("scheduledTo").asString()).atZone(ISTANBUL))
                .isEqualTo(tomorrow.atTime(12, 0).atZone(ISTANBUL));
        assertThat(detail.get("offer").get("laborAmount").asDouble()).isEqualTo(900.0);
        assertThat(detail.get("offer").get("materialsAmount").asDouble()).isEqualTo(300.0);
        assertThat(detail.get("offer").get("publicCode").asString()).isEqualTo("T-10005");
        assertThat(detail.get("payment").get("status").asString()).isEqualTo("LOCKED");
        assertThat(detail.get("address").get("lineFull").asString()).isEqualTo("Caferağa Mah. Moda Cad. No: 14 Daire: 5");
        assertThat(detail.get("timeline").size()).isGreaterThanOrEqualTo(3);

        JsonNode past = jobs(ali, "CUSTOMER", "past");
        assertThat(past.size()).isEqualTo(6); // BD-88407 + Ali'nin 5 geçmiş işi
        JsonNode done = jobByCode(past, "BD-88407");
        assertThat(done.get("status").asString()).isEqualTo("COMPLETED");
        assertThat(done.get("counterpart").get("displayName").asString()).isEqualTo("Kaya Tesisat");
        assertThat(done.get("totalAmount").asDouble()).isEqualTo(1400.0);
        JsonNode doneDetail = body(call(HttpMethod.GET, "/api/v1/jobs/" + done.get("id").asString(), ali, null));
        assertThat(doneDetail.get("review").get("rating").asInt()).isEqualTo(5);
        assertThat(doneDetail.get("review").get("tags").toString()).contains("ON_TIME").contains("CLEAN_WORK");
        assertThat(doneDetail.get("payment").get("status").asString()).isEqualTo("RELEASED_TO_PRO");
        assertThat(actions(doneDetail)).doesNotContain("REVIEW"); // zaten değerlendirildi

        // Talep tarafı: BD-88409 ASSIGNED + jobId, BD-88407 geçmişte.
        JsonNode requests = body(call(HttpMethod.GET, "/api/v1/requests?scope=active", ali, null)).get("items");
        assertThat(requests.size()).isEqualTo(2);
        JsonNode r88409 = jobByCode(requests, "BD-88409");
        assertThat(r88409.get("status").asString()).isEqualTo("ASSIGNED");
        assertThat(r88409.get("jobId").asString()).isEqualTo(j.get("id").asString());
        assertThat(jobByCode(body(call(HttpMethod.GET, "/api/v1/requests?scope=past", ali, null)).get("items"),
                "BD-88407").get("jobId").asString()).isEqualTo(done.get("id").asString());
    }

    @Test
    void mehmetSeesTheSameJobAsProWithMarkArrivedAndFeeBreakdown() throws Exception {
        String mehmet = login("mehmet@bitadilat.test");
        JsonNode j = jobByCode(jobs(mehmet, "PRO", "active"), "BD-88409");
        assertThat(j.get("viewerRole").asString()).isEqualTo("PRO");
        assertThat(j.get("counterpart").get("displayName").asString()).isEqualTo("Ali Y.");
        JsonNode detail = body(call(HttpMethod.GET, "/api/v1/jobs/" + j.get("id").asString(), mehmet, null)
                .andExpect(status().isOk()));
        assertThat(actions(detail)).contains("MARK_ARRIVED", "CHAT", "CANCEL");
        assertThat(detail.get("offer").get("serviceFee").asDouble()).isEqualTo(120.0);
        assertThat(detail.get("offer").get("netEarning").asDouble()).isEqualTo(1080.0);
        assertThat(detail.get("payment").get("netEarning").asDouble()).isEqualTo(1080.0);
        assertThat(detail.get("address").get("lineFull").asString()).contains("Moda Cad.");

        JsonNode earnings = body(call(HttpMethod.GET, "/api/v1/pro/earnings", mehmet, null).andExpect(status().isOk()));
        assertThat(earnings.get("pendingTotal").asDouble()).isEqualTo(1080.0);
        assertThat(earnings.get("releasedTotal").asDouble()).isGreaterThan(0.0); // geçmiş işler
    }

    @Test
    void chatsAreSeededWithFourAndSixMessages() throws Exception {
        String ali = login("ali@bitadilat.test");
        String id = jobByCode(jobs(ali, "CUSTOMER", "active"), "BD-88409").get("id").asString();
        JsonNode msgs = body(call(HttpMethod.GET, "/api/v1/jobs/" + id + "/messages", ali, null)
                .andExpect(status().isOk()));
        assertThat(msgs.get("items").size()).isEqualTo(4);
        assertThat(msgs.get("items").get(0).get("senderRole").asString()).isEqualTo("PRO");
        assertThat(msgs.get("items").get(2).get("body").asString()).contains("park yeri");
        assertThat(msgs.get("otherLastReadId").asLong()).isEqualTo(msgs.get("items").get(3).get("id").asLong());

        String zeynep = login("zeynep@bitadilat.test");
        JsonNode disputed = jobByCode(jobs(zeynep, "CUSTOMER", "active"), "BD-88398");
        JsonNode chat = body(call(HttpMethod.GET, "/api/v1/jobs/" + disputed.get("id").asString() + "/messages",
                zeynep, null).andExpect(status().isOk()));
        assertThat(chat.get("items").size()).isEqualTo(6);
        assertThat(chat.get("items").get(5).get("senderRole").asString()).isEqualTo("PRO");
        assertThat(chat.get("items").get(5).get("body").asString()).contains("600 TL");

        JsonNode inbox = body(call(HttpMethod.GET, "/api/v1/conversations?as=CUSTOMER", ali, null));
        assertThat(inbox.get("items").size()).isEqualTo(7); // BD-88409 + 6 geçmiş iş
    }

    @Test
    void zeynepJobIsDisputedWithComplaintSk1001() throws Exception {
        String zeynep = login("zeynep@bitadilat.test");
        JsonNode j = jobByCode(jobs(zeynep, "CUSTOMER", "active"), "BD-88398");
        assertThat(j.get("status").asString()).isEqualTo("DISPUTED");
        assertThat(j.get("counterpart").get("displayName").asString()).isEqualTo("Usta Eller Tesisat");
        assertThat(j.get("totalAmount").asDouble()).isEqualTo(2200.0);
        JsonNode detail = body(call(HttpMethod.GET, "/api/v1/jobs/" + j.get("id").asString(), zeynep, null));
        assertThat(detail.get("payment").get("status").asString()).isEqualTo("DISPUTED");
        assertThat(detail.get("complaint").get("publicCode").asString()).isEqualTo("SK-1001");
        assertThat(detail.get("complaint").get("status").asString()).isEqualTo("OPEN");
        assertThat(actions(detail)).doesNotContain("CANCEL", "COMPLAIN", "CONFIRM_COMPLETION");
        assertThat(detail.get("address").get("districtName").asString()).isEqualTo("Ataşehir");

        JsonNode complaint = body(call(HttpMethod.GET, "/api/v1/complaints/" + detail.get("complaint").get("id").asString(),
                zeynep, null).andExpect(status().isOk()));
        assertThat(complaint.get("reason").asString()).isEqualTo("EXTRA_CHARGE");
        assertThat(complaint.get("description").asString()).contains("Teklif dışı fazladan ücret talep edildi");
        assertThat(complaint.get("evidence").size()).isEqualTo(2);
        assertThat(complaint.get("decision").isNull()).isTrue();
        // Kanıt dosyaları gerçekten sunulur.
        String url = complaint.get("evidence").get(0).get("url").asString();
        mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders
                        .get(url.substring(url.indexOf("/api/v1"))))
                .andExpect(status().isOk());

        // Emre (usta) şikayeti görür; Ali göremez.
        String emre = login("emre@bitadilat.test");
        call(HttpMethod.GET, "/api/v1/complaints/" + detail.get("complaint").get("id").asString(), emre, null)
                .andExpect(status().isOk());
        call(HttpMethod.GET, "/api/v1/complaints/" + detail.get("complaint").get("id").asString(),
                login("ali@bitadilat.test"), null).andExpect(status().isNotFound());
    }

    @Test
    void seededEscrowsAreSeedProviderLedgerOnly() throws Exception {
        // 3 sözleşme işi + 10 geçmiş tamamlanmış iş.
        assertThat(jdbc.queryForObject("select count(*) from escrow_payment", Long.class)).isEqualTo(13L);
        assertThat(jdbc.queryForObject("select count(*) from escrow_payment where provider = 'SEED' and channel = 'APP'",
                Long.class)).isEqualTo(13L);
        assertThat(jdbc.queryForObject("""
                select string_agg(e.status || ':' || e.total_amount, ',') from escrow_payment e
                join service_requests r on r.id = e.request_id
                where r.public_code in ('BD-88398', 'BD-88407', 'BD-88409')""", String.class))
                .contains("DISPUTED:2200.00").contains("RELEASED_TO_PRO:1400.00").contains("LOCKED:1200.00");
        assertThat(jdbc.queryForObject("select count(*) from escrow_payment where status = 'RELEASED_TO_PRO'",
                Long.class)).isEqualTo(11L);
        assertThat(jdbc.queryForObject("""
                select l.amount from payout_ledger l join escrow_payment e on e.ref = l.payment_ref
                join service_requests r on r.id = e.request_id
                where r.public_code = 'BD-88407' and l.kind = 'PAYOUT'""", java.math.BigDecimal.class))
                .isEqualByComparingTo("1260.00");
        assertThat(jdbc.queryForObject("""
                select l.amount from payout_ledger l join escrow_payment e on e.ref = l.payment_ref
                join service_requests r on r.id = e.request_id
                where r.public_code = 'BD-88407' and l.kind = 'COMMISSION'""", java.math.BigDecimal.class))
                .isEqualByComparingTo("140.00");
        assertThat(jdbc.queryForObject("select count(*) from users", Long.class)).isEqualTo(8L);
        assertThat(jdbc.queryForObject("select count(*) from offers where public_code ~ '^T-[0-9]{5}$'", Long.class))
                .isEqualTo(16L);
    }

    @Test
    void cancellingSeededJobRefundsWithoutTouchingCraftgateAndResetRestoresIt() throws Exception {
        String ali = login("ali@bitadilat.test");
        String id = jobByCode(jobs(ali, "CUSTOMER", "active"), "BD-88409").get("id").asString();
        // Gerçek Craftgate istemcisi sandbox anahtarlarıyla ağa çıkamaz; SEED kaydı gateway'e gitmediği için başarılı olur.
        call(HttpMethod.POST, "/api/v1/jobs/" + id + "/cancel", ali, Map.of("reason", "PLANS_CHANGED"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.status").value("CANCELLED"))
                .andExpect(jsonPath("$.payment.status").value("REFUNDED_TO_CUSTOMER"));
        assertThat(jdbc.queryForObject("select count(*) from payout_ledger where kind = 'REFUND'", Long.class))
                .isEqualTo(1L);

        mvc.perform(post("/api/v1/dev/reset")).andExpect(status().isNoContent());
        String again = login("ali@bitadilat.test");
        JsonNode restored = jobByCode(jobs(again, "CUSTOMER", "active"), "BD-88409");
        assertThat(restored.get("status").asString()).isEqualTo("SCHEDULED");
        assertThat(jdbc.queryForObject("select count(*) from jobs", Long.class)).isEqualTo(13L);
        assertThat(jdbc.queryForObject("select count(*) from messages", Long.class)).isEqualTo(10L);
        assertThat(jdbc.queryForObject("select count(*) from complaints", Long.class)).isEqualTo(1L);
        assertThat(jdbc.queryForObject("select count(*) from reviews", Long.class)).isEqualTo(11L);
        assertThat(jdbc.queryForObject("select count(*) from payout_ledger", Long.class)).isEqualTo(22L);
    }

    @Test
    void proAccountsStartInProModeAndCustomersInCustomerMode() throws Exception {
        assertThat(jdbc.queryForList("select email from users where last_mode = 'PRO' order by email", String.class))
                .containsExactly("ahmet@bitadilat.test", "emre@bitadilat.test", "hasan@bitadilat.test",
                        "mehmet@bitadilat.test", "selim@bitadilat.test");
        assertThat(jdbc.queryForObject("select count(*) from users where last_mode = 'CUSTOMER'", Long.class))
                .isEqualTo(3L);
        // Admin telefonu null kalır (sözleşmeye uygun).
        assertThat(jdbc.queryForObject("select phone from users where email = 'admin@bitadilat.test'", String.class))
                .isNull();
    }

    @Test
    void proDocumentsMatchReviewStatus() throws Exception {
        for (String who : new String[] {"mehmet", "ahmet", "emre"}) {
            assertThat(jdbc.queryForList("""
                    select d.type || ':' || d.status from pro_documents d join users u on u.id = d.pro_id
                    where u.email = ? order by d.type""", String.class, who + "@bitadilat.test"))
                    .containsExactly("IDENTITY:ACCEPTED", "TRADE_CERT:ACCEPTED");
        }
        assertThat(jdbc.queryForList("""
                select d.status from pro_documents d join users u on u.id = d.pro_id where u.email = 'hasan@bitadilat.test'""",
                String.class)).containsOnly("PENDING").hasSize(2);
        assertThat(jdbc.queryForList("""
                select d.status from pro_documents d join users u on u.id = d.pro_id
                where u.email = 'selim@bitadilat.test' order by d.type""", String.class))
                .containsExactly("ACCEPTED", "REJECTED");
        assertThat(jdbc.queryForObject("select review_note from pro_profiles p join users u on u.id = p.user_id "
                + "where u.email = 'selim@bitadilat.test'", String.class)).isNotBlank();
        assertThat(jdbc.queryForObject("select count(*) from media where purpose = 'PRO_DOCUMENT' "
                + "and content_type = 'image/png'", Long.class)).isEqualTo(10L);

        // Herkese açık profilde doğrulanmış belgeler rozetle tutarlı.
        String ali = login("ali@bitadilat.test");
        String mehmetId = jdbc.queryForObject("select id::text from users where email = 'mehmet@bitadilat.test'",
                String.class);
        JsonNode pub = body(call(HttpMethod.GET, "/api/v1/pros/" + mehmetId, ali, null).andExpect(status().isOk()));
        assertThat(pub.get("verifiedDocuments").toString()).contains("IDENTITY").contains("TRADE_CERT");
    }

    @Test
    void ratingsAndJobCountsAreComputedFromSeededReviews() throws Exception {
        for (String who : new String[] {"mehmet", "ahmet", "emre"}) {
            Map<String, Object> row = jdbc.queryForMap("""
                    select p.rating_avg, p.rating_count, p.completed_jobs,
                           (select round(avg(rating)::numeric, 2) from reviews where pro_id = p.user_id) as avg,
                           (select count(*) from reviews where pro_id = p.user_id) as cnt,
                           (select count(*) from jobs where pro_id = p.user_id and status = 'COMPLETED') as done
                    from pro_profiles p join users u on u.id = p.user_id where u.email = ?""", who + "@bitadilat.test");
            assertThat(row.get("rating_avg")).isEqualTo(row.get("avg"));
            assertThat(((Number) row.get("rating_count")).longValue()).isEqualTo(((Number) row.get("cnt")).longValue())
                    .isBetween(3L, 5L);
            assertThat(((Number) row.get("completed_jobs")).longValue()).isEqualTo(((Number) row.get("done")).longValue());
        }
        assertThat(jdbc.queryForObject("select count(*) from reviews where is_anonymous", Long.class))
                .isGreaterThanOrEqualTo(3L);
        assertThat(jdbc.queryForObject("select count(distinct customer_id) from reviews", Long.class)).isEqualTo(2L);
        assertThat(jdbc.queryForObject("select count(distinct created_at::date) from reviews", Long.class))
                .isGreaterThan(5L);
        // BD-88407 değerlendirmesi Kaya'nın geçmişinden biridir.
        assertThat(jdbc.queryForObject("""
                select r.rating from reviews r join jobs j on j.id = r.job_id
                join service_requests q on q.id = j.request_id where q.public_code = 'BD-88407'""", Integer.class))
                .isEqualTo(5);
        assertThat(jdbc.queryForObject("select rating_count from pro_profiles p join users u on u.id = p.user_id "
                + "where u.email = 'hasan@bitadilat.test'", Integer.class)).isZero();
    }
}
