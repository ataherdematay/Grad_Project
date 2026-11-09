package com.bitadilat.offer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave2TestBase;
import com.bitadilat.request.ExpiryJob;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class OfferFlowTest extends Wave2TestBase {

    @Autowired
    ExpiryJob expiryJob;

    private Instant in(long hours) {
        return Instant.now().plus(hours, ChronoUnit.HOURS);
    }

    // ─── Müşteri: liste, sıralama, filtre ───────────────────────────────────

    @Test
    void offerListSortsFiltersAndCountsDeclined() throws Exception {
        Account ali = register();
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        Account p1 = pro("Bir", List.of("plumbing"), List.of("Kadıköy"));
        Account p2 = pro("İki", List.of("plumbing"), List.of("Kadıköy"));
        Account p3 = pro("Üç", List.of("plumbing"), List.of("Kadıköy"));
        Account p4 = pro("Dört", List.of("plumbing"), List.of("Kadıköy"));
        setProRating(p1, "4.90");
        setProRating(p2, "4.90");
        setProRating(p3, "4.00");
        setProRating(p4, "3.00");
        String o1 = sendOffer(p1, req, offerBody("1800", "200", in(30), in(33))).get("id").asString(); // 2000
        String o2 = sendOffer(p2, req, offerBody("1600", "200", in(28), in(31))).get("id").asString(); // 1800
        String o3 = sendOffer(p3, req, offerBody("1500", "0", in(10), in(13))).get("id").asString();   // 1500
        String o4 = sendOffer(p4, req, offerBody("900", "100", in(50), in(53))).get("id").asString();  // 1000
        String url = "/api/v1/requests/" + req + "/offers";

        assertThat(ids(list(ali, url).get("items"))).containsExactly(o2, o1, o3, o4);              // varsayılan: recommended
        assertThat(ids(list(ali, url + "?sort=recommended").get("items"))).containsExactly(o2, o1, o3, o4);
        assertThat(ids(list(ali, url + "?sort=price").get("items"))).containsExactly(o4, o3, o2, o1);
        assertThat(ids(list(ali, url + "?sort=rating").get("items"))).containsExactly(o2, o1, o3, o4);
        assertThat(ids(list(ali, url + "?sort=arrival").get("items"))).containsExactly(o3, o2, o1, o4);
        assertThat(ids(list(ali, url + "?maxPrice=1800").get("items"))).containsExactly(o2, o3, o4);
        assertThat(ids(list(ali, url + "?minRating=4.5").get("items"))).containsExactly(o2, o1);
        assertThat(ids(list(ali, url + "?sort=price&maxPrice=1800&minRating=3.5").get("items"))).containsExactly(o3, o2);
        call(HttpMethod.GET, url + "?sort=bogus", ali.access(), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("sort"));

        JsonNode first = list(ali, url).get("items").get(0);
        assertThat(first.get("pro").get("businessName").asString()).isEqualTo("İki");
        assertThat(first.get("pro").get("verified").asBoolean()).isTrue();
        assertThat(first.get("serviceFee")).isNull(); // özet kalemlere ve ücrete sahip değil

        // Reddedilen liste dışına çıkar, declinedCount artar. Talep özeti de PENDING'leri sayar.
        call(HttpMethod.POST, "/api/v1/offers/" + o4 + "/decline", ali.access(),
                Map.of("reason", "PRICE", "keepRequestOpen", true)).andExpect(status().isOk());
        JsonNode after = list(ali, url);
        assertThat(ids(after.get("items"))).containsExactly(o2, o1, o3);
        assertThat(after.get("declinedCount").asInt()).isEqualTo(1);
        call(HttpMethod.GET, "/api/v1/requests/" + req, ali.access(), null)
                .andExpect(jsonPath("$.offerCount").value(3))
                .andExpect(jsonPath("$.minOfferTotal").value(1500.0))
                .andExpect(jsonPath("$.maxOfferTotal").value(2000.0));
    }

    private JsonNode list(Account who, String url) throws Exception {
        return body(call(HttpMethod.GET, url, who.access(), null).andExpect(status().isOk()));
    }

    // ─── Müşteri: ayrıntı ve reddetme ───────────────────────────────────────

    @Test
    void feeAndNetEarningAreOnlyVisibleToTheOfferingPro() throws Exception {
        Account ali = register();
        Account other = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        Map<String, Object> body = offerBody("1650", "800");
        body.put("items", List.of(
                Map.of("kind", "LABOR", "description", "İşçilik", "quantity", 1, "unitPrice", 1650),
                Map.of("kind", "MATERIAL", "description", "Sifon", "quantity", 1, "unitPrice", 450),
                Map.of("kind", "MATERIAL", "description", "Conta", "quantity", 2, "unitPrice", 175)));

        JsonNode created = sendOffer(usta, req, body);
        String id = created.get("id").asString();
        assertThat(created.get("serviceFee").asDouble()).isEqualTo(245.0);
        assertThat(created.get("netEarning").asDouble()).isEqualTo(2205.0);
        assertThat(created.get("totalAmount").asDouble()).isEqualTo(2450.0);
        assertThat(created.get("publicCode").asString()).matches("T-\\d{5,}");
        assertThat(created.get("items").size()).isEqualTo(3);
        assertThat(created.get("items").get(2).get("lineTotal").asDouble()).isEqualTo(350.0);

        call(HttpMethod.GET, "/api/v1/offers/" + id, usta.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.serviceFee").value(245.0));
        call(HttpMethod.GET, "/api/v1/offers/" + id, ali.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.serviceFee").isEmpty())
                .andExpect(jsonPath("$.netEarning").isEmpty())
                .andExpect(jsonPath("$.items.length()").value(3))
                .andExpect(jsonPath("$.items[0].kind").value("LABOR"))
                .andExpect(jsonPath("$.declineReason").isEmpty());
        // Başka müşteri ve başka usta 404.
        call(HttpMethod.GET, "/api/v1/offers/" + id, other.access(), null).andExpect(status().isNotFound());
        Account rival = pro("Rakip", List.of("plumbing"), List.of("Kadıköy"));
        call(HttpMethod.GET, "/api/v1/offers/" + id, rival.access(), null).andExpect(status().isNotFound());
        call(HttpMethod.POST, "/api/v1/offers/" + id + "/decline", other.access(),
                Map.of("reason", "PRICE", "keepRequestOpen", true)).andExpect(status().isNotFound());
        // Müşteri bu talebin tekliflerinde de yalnız kendi talebini görür.
        call(HttpMethod.GET, "/api/v1/requests/" + req + "/offers", other.access(), null)
                .andExpect(status().isNotFound());
    }

    @Test
    void declineKeepsOrClosesTheRequestAndNotifiesThePro() throws Exception {
        Account ali = register();
        Account p1 = pro("Bir", List.of("plumbing"), List.of("Kadıköy"));
        Account p2 = pro("İki", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String o1 = sendOffer(p1, req, offerBody("1000", "0")).get("id").asString();
        String o2 = sendOffer(p2, req, offerBody("1100", "0")).get("id").asString();

        // keepRequestOpen=true: yalnız teklif DECLINED, talep OPEN, diğer teklif PENDING.
        call(HttpMethod.POST, "/api/v1/offers/" + o1 + "/decline", ali.access(),
                Map.of("reason", "SCHEDULE", "note", "Saat uymuyor", "keepRequestOpen", true))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("DECLINED"))
                .andExpect(jsonPath("$.declineReason").value("SCHEDULE"));
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class, req))
                .isEqualTo("OPEN");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, o2))
                .isEqualTo("PENDING");
        assertThat(count("select count(*) from notifications where type = 'OFFER_DECLINED' and user_id = ?::uuid",
                p1.id())).isEqualTo(1);
        assertThat(count("select count(*) from notifications where type = 'OFFER_DECLINED' and user_id = ?::uuid",
                p2.id())).isEqualTo(0);
        // Tekrar reddedilemez.
        call(HttpMethod.POST, "/api/v1/offers/" + o1 + "/decline", ali.access(),
                Map.of("reason", "PRICE", "keepRequestOpen", true))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        // Talep kapatılacaksa gerekçe NOT_NEEDED veya OTHER.
        call(HttpMethod.POST, "/api/v1/offers/" + o2 + "/decline", ali.access(),
                Map.of("reason", "PRICE", "keepRequestOpen", false))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("reason"));
        call(HttpMethod.POST, "/api/v1/offers/" + o2 + "/decline", ali.access(), Map.of("reason", "PRICE"))
                .andExpect(status().isBadRequest());

        // keepRequestOpen=false: talep de CANCELLED.
        call(HttpMethod.POST, "/api/v1/offers/" + o2 + "/decline", ali.access(),
                Map.of("reason", "NOT_NEEDED", "keepRequestOpen", false))
                .andExpect(status().isOk()).andExpect(jsonPath("$.status").value("DECLINED"));
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class, req))
                .isEqualTo("CANCELLED");
    }

    // ─── Usta: teklif verme ─────────────────────────────────────────────────

    @Test
    void offerValidationRules() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String url = "/api/v1/pro/requests/" + req + "/offers";

        // Kalem toplamı uyuşmazlığı
        Map<String, Object> mismatch = offerBody("1000", "200");
        mismatch.put("items", List.of(
                Map.of("kind", "LABOR", "description", "İşçilik", "quantity", 1, "unitPrice", 900),
                Map.of("kind", "MATERIAL", "description", "Parça", "quantity", 1, "unitPrice", 200)));
        call(HttpMethod.POST, url, usta.access(), mismatch)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("items"));

        // Pencere sınırları
        Instant from = in(24);
        expectBadField(usta, url, offerBody("1000", "0", from, from.plus(30, ChronoUnit.MINUTES)), "arrivalTo");
        expectBadField(usta, url, offerBody("1000", "0", from, from.plus(13, ChronoUnit.HOURS)), "arrivalTo");
        expectBadField(usta, url, offerBody("1000", "0", from, from.minus(1, ChronoUnit.HOURS)), "arrivalTo");
        expectBadField(usta, url, offerBody("1000", "0", in(-1), in(3)), "arrivalFrom");
        expectBadField(usta, url, offerBody("1000", "0", in(15 * 24), in(15 * 24 + 3)), "arrivalFrom");
        // Tutarlar ve garanti
        expectBadField(usta, url, offerBody("0", "100"), "laborAmount");
        expectBadField(usta, url, offerBody("100", "-1"), "materialsAmount");
        Map<String, Object> warranty = offerBody("1000", "0");
        warranty.put("warrantyMonths", 5);
        expectBadField(usta, url, warranty, "warrantyMonths");
        Map<String, Object> longNote = offerBody("1000", "0");
        longNote.put("note", "x".repeat(501));
        expectBadField(usta, url, longNote, "note");

        // Sınır değerler geçer: 1 saat ve 12 saat.
        Account u2 = pro("İki", List.of("plumbing"), List.of("Kadıköy"));
        call(HttpMethod.POST, url, usta.access(), offerBody("1000", "0", from, from.plus(1, ChronoUnit.HOURS)))
                .andExpect(status().isCreated());
        call(HttpMethod.POST, url, u2.access(), offerBody("500", "0", from, from.plus(12, ChronoUnit.HOURS)))
                .andExpect(status().isCreated());
        assertThat(count("select count(*) from offers where request_id = ?::uuid", req)).isEqualTo(2);
    }

    private void expectBadField(Account usta, String url, Map<String, Object> body, String field) throws Exception {
        call(HttpMethod.POST, url, usta.access(), body)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.field").value(field));
    }

    @Test
    void validUntilIsMinOfArrivalEndAnd72Hours() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        Account usta2 = pro("İki", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        Instant soonTo = in(5);
        JsonNode near = sendOffer(usta, req, offerBody("100", "0", in(2), soonTo));
        assertThat(Instant.parse(near.get("validUntil").asString())).isBetween(soonTo.minusMillis(1), soonTo.plusMillis(1));
        JsonNode far = sendOffer(usta2, req, offerBody("100", "0", in(10 * 24), in(10 * 24 + 3)));
        long hours = ChronoUnit.HOURS.between(Instant.now(), Instant.parse(far.get("validUntil").asString()));
        assertThat(hours).isBetween(71L, 72L);
    }

    @Test
    void alreadyOfferedClosedRequestAndNonMatchingPro() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        Account elsewhere = pro("Uzak", List.of("plumbing"), List.of("Ataşehir"));
        Account notApproved = pro("Onaysız", List.of("plumbing"), List.of("Kadıköy"));
        jdbc.update("update pro_profiles set review_status = 'PENDING_REVIEW' where user_id = ?::uuid", notApproved.id());
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String url = "/api/v1/pro/requests/" + req + "/offers";

        sendOffer(usta, req, offerBody("1000", "0"));
        call(HttpMethod.POST, url, usta.access(), offerBody("900", "0"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ALREADY_OFFERED"));
        call(HttpMethod.POST, url, elsewhere.access(), offerBody("900", "0")).andExpect(status().isNotFound());
        call(HttpMethod.POST, url, notApproved.access(), offerBody("900", "0"))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("PRO_NOT_APPROVED"));
        call(HttpMethod.POST, "/api/v1/pro/requests/" + newKey() + "/offers", usta.access(), offerBody("900", "0"))
                .andExpect(status().isNotFound());

        // Kapanmış talebe 409.
        Account second = pro("İki", List.of("plumbing"), List.of("Kadıköy"));
        call(HttpMethod.POST, "/api/v1/requests/" + req + "/cancel", ali.access(), Map.of("reason", "SOLVED"))
                .andExpect(status().isOk());
        call(HttpMethod.POST, url, second.access(), offerBody("900", "0"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        // Süresi dolmuş ama işlenmemiş talebe de 409.
        String other = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        jdbc.update("update service_requests set expires_at = now() - interval '1 second' where id = ?::uuid", other);
        call(HttpMethod.POST, "/api/v1/pro/requests/" + other + "/offers", second.access(), offerBody("900", "0"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
    }

    @Test
    void ownerCannotOfferOnOwnRequestEvenIfAPro() throws Exception {
        Account ali = register();
        jdbc.update("insert into pro_profiles (user_id, business_name, review_status) values (?::uuid, 'Ali Usta', 'APPROVED')",
                ali.id());
        jdbc.update("insert into pro_categories values (?::uuid, 'plumbing')", ali.id());
        jdbc.update("insert into pro_districts values (?::uuid, ?)", ali.id(), districtId("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        call(HttpMethod.POST, "/api/v1/pro/requests/" + req + "/offers", ali.access(), offerBody("900", "0"))
                .andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/pro/feed", ali.access(), null)
                .andExpect(jsonPath("$.items.length()").value(0));
    }

    @Test
    void idempotencyKeyReplaysSameResponseWithSingleRow() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String url = "/api/v1/pro/requests/" + req + "/offers";
        String key = newKey();
        Map<String, Object> body = offerBody("1000", "200");

        String first = send(usta, url, key, body).andExpect(status().isCreated()).andReturn().getResponse()
                .getContentAsString();
        String second = send(usta, url, key, body).andExpect(status().isCreated()).andReturn().getResponse()
                .getContentAsString();
        assertThat(second).isEqualTo(first);
        assertThat(count("select count(*) from offers where request_id = ?::uuid", req)).isEqualTo(1);
        assertThat(count("select count(*) from notifications where type = 'OFFER_RECEIVED'")).isEqualTo(1);

        // Anahtarsız tekrar ALREADY_OFFERED; aynı anahtar başka talepte DUPLICATE_ATTEMPT.
        call(HttpMethod.POST, url, usta.access(), body).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ALREADY_OFFERED"));
        String req2 = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        send(usta, "/api/v1/pro/requests/" + req2 + "/offers", key, body)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("DUPLICATE_ATTEMPT"));
        send(usta, url, "boşluk var!", body).andExpect(status().isBadRequest());
    }

    private org.springframework.test.web.servlet.ResultActions send(Account pro, String url, String key,
                                                                    Map<String, Object> body) throws Exception {
        return mvc.perform(org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post(url)
                .header("Authorization", "Bearer " + pro.access())
                .header("Idempotency-Key", key)
                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(body)));
    }

    @Test
    void offerReceivedNotificationGoesToTheCustomer() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String offerId = sendOffer(usta, req, offerBody("1000", "0")).get("id").asString();
        Map<String, Object> row = jdbc.queryForMap(
                "select type, params::text as params, target_route from notifications where user_id = ?::uuid and type = 'OFFER_RECEIVED'",
                ali.id());
        assertThat(row.get("params").toString()).contains(offerId);
        assertThat(row.get("target_route")).isEqualTo("/c/requests/" + req + "/offers");
    }

    // ─── Usta: geri çekme, Tekliflerim ──────────────────────────────────────

    @Test
    void withdrawIsOwnPendingOnlyAndAllowsNewOffer() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        Account rival = pro("Rakip", List.of("plumbing"), List.of("Kadıköy"));
        String req = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String id = sendOffer(usta, req, offerBody("1000", "0")).get("id").asString();

        call(HttpMethod.POST, "/api/v1/pro/offers/" + id + "/withdraw", rival.access(), null)
                .andExpect(status().isNotFound());
        call(HttpMethod.POST, "/api/v1/pro/offers/" + id + "/withdraw", ali.access(), null)
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("PRO_NOT_APPROVED"));
        call(HttpMethod.POST, "/api/v1/pro/offers/" + id + "/withdraw", usta.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("WITHDRAWN"))
                .andExpect(jsonPath("$.serviceFee").isNotEmpty());
        call(HttpMethod.POST, "/api/v1/pro/offers/" + id + "/withdraw", usta.access(), null)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        call(HttpMethod.GET, "/api/v1/requests/" + req + "/offers", ali.access(), null)
                .andExpect(jsonPath("$.items.length()").value(0));
        // Geri çekildikten sonra yeniden teklif verilebilir.
        sendOffer(usta, req, offerBody("900", "0"));
    }

    @Test
    void myOffersListFiltersByStatus() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String addr = addressId(ali, "Kadıköy");
        String r1 = createRequest(ali, addr).get("id").asString();
        String r2 = createRequest(ali, addr).get("id").asString();
        String o1 = sendOffer(usta, r1, offerBody("1000", "0")).get("id").asString();
        String o2 = sendOffer(usta, r2, offerBody("1100", "0")).get("id").asString();
        call(HttpMethod.POST, "/api/v1/pro/offers/" + o2 + "/withdraw", usta.access(), null).andExpect(status().isOk());

        JsonNode all = list(usta, "/api/v1/pro/offers");
        assertThat(ids(all.get("items"))).containsExactly(o2, o1);
        JsonNode pending = list(usta, "/api/v1/pro/offers?status=PENDING");
        assertThat(ids(pending.get("items"))).containsExactly(o1);
        assertThat(pending.get("items").get(0).get("request").get("publicCode").asString()).startsWith("BD-");
        assertThat(pending.get("items").get(0).get("request").get("districtName").asString()).isEqualTo("Kadıköy");
        assertThat(ids(list(usta, "/api/v1/pro/offers?status=WITHDRAWN").get("items"))).containsExactly(o2);
        call(HttpMethod.GET, "/api/v1/pro/offers?status=NOPE", usta.access(), null).andExpect(status().isBadRequest());
        // Süresi geçen teklif okuma anında EXPIRED görünür.
        jdbc.update("update offers set valid_until = now() - interval '1 minute' where id = ?::uuid", o1);
        assertThat(ids(list(usta, "/api/v1/pro/offers?status=EXPIRED").get("items"))).containsExactly(o1);
        call(HttpMethod.POST, "/api/v1/pro/offers/" + o1 + "/withdraw", usta.access(), null)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("OFFER_EXPIRED"));
        // Müşteri tarafı da süresi geçeni göstermez.
        call(HttpMethod.GET, "/api/v1/requests/" + r1 + "/offers", ali.access(), null)
                .andExpect(jsonPath("$.items.length()").value(0));
    }

    // ─── Zamanlayıcı ────────────────────────────────────────────────────────

    @Test
    void schedulerExpiresDueRequestsAndOffers() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        Account usta2 = pro("İki", List.of("plumbing"), List.of("Kadıköy"));
        String addr = addressId(ali, "Kadıköy");
        String dueReq = createRequest(ali, addr).get("id").asString();
        String liveReq = createRequest(ali, addr).get("id").asString();
        String dueReqOffer = sendOffer(usta, dueReq, offerBody("1000", "0")).get("id").asString();
        String dueOffer = sendOffer(usta, liveReq, offerBody("1000", "0")).get("id").asString();
        String liveOffer = sendOffer(usta2, liveReq, offerBody("1000", "0")).get("id").asString();
        jdbc.update("update service_requests set expires_at = now() - interval '1 minute' where id = ?::uuid", dueReq);
        jdbc.update("update offers set valid_until = now() - interval '1 minute' where id = ?::uuid", dueOffer);

        ExpiryJob.Result result = expiryJob.run(Instant.now());
        assertThat(result.requests()).isEqualTo(1);
        assertThat(result.offers()).isGreaterThanOrEqualTo(1);
        assertThat(statusOf("service_requests", dueReq)).isEqualTo("EXPIRED");
        assertThat(statusOf("offers", dueReqOffer)).isEqualTo("EXPIRED");
        assertThat(statusOf("offers", dueOffer)).isEqualTo("EXPIRED");
        assertThat(statusOf("service_requests", liveReq)).isEqualTo("OPEN");
        assertThat(statusOf("offers", liveOffer)).isEqualTo("PENDING");
        // İkinci çalışma boştur (idempotent).
        ExpiryJob.Result again = expiryJob.run(Instant.now());
        assertThat(again.requests() + again.offers()).isZero();
    }

    private String statusOf(String table, String id) {
        return jdbc.queryForObject("select status from " + table + " where id = ?::uuid", String.class, id);
    }

    @Test
    void stateMachinesRejectIllegalTransitions() {
        List<String> failures = new ArrayList<>();
        try {
            OfferStatus.DECLINED.to(OfferStatus.PENDING);
            failures.add("DECLINED->PENDING");
        } catch (com.bitadilat.common.ApiException e) {
            assertThat(e.getCode()).isEqualTo("ILLEGAL_STATE");
        }
        try {
            com.bitadilat.request.RequestStatus.CANCELLED.to(com.bitadilat.request.RequestStatus.OPEN);
            failures.add("CANCELLED->OPEN");
        } catch (com.bitadilat.common.ApiException e) {
            assertThat(e.getStatus().value()).isEqualTo(409);
        }
        assertThat(failures).isEmpty();
        assertThat(OfferStatus.SUPERSEDED.canMoveTo(OfferStatus.PENDING)).isTrue();
        assertThat(com.bitadilat.request.RequestStatus.ASSIGNED.canMoveTo(com.bitadilat.request.RequestStatus.OPEN))
                .isTrue();
    }
}
