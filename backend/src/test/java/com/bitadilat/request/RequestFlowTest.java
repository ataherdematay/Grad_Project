package com.bitadilat.request;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave2TestBase;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class RequestFlowTest extends Wave2TestBase {

    @Test
    void urgentRequestIsPublishedWithServerComputedFields() throws Exception {
        Account ali = register();
        String addr = addressId(ali, "Kadıköy");
        Map<String, Object> body = requestBody(addr);
        body.put("preferredFrom", Instant.now().plus(2, ChronoUnit.DAYS).toString()); // URGENT'te yok sayılır
        body.put("preferredTo", Instant.now().plus(3, ChronoUnit.DAYS).toString());

        JsonNode r = body(call(HttpMethod.POST, "/api/v1/requests", ali.access(), body)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("OPEN"))
                .andExpect(jsonPath("$.urgency").value("URGENT"))
                .andExpect(jsonPath("$.preferredFrom").isEmpty())
                .andExpect(jsonPath("$.districtName").value("Kadıköy"))
                .andExpect(jsonPath("$.neighborhood").value("Caferağa"))
                .andExpect(jsonPath("$.offerCount").value(0))
                .andExpect(jsonPath("$.minOfferTotal").isEmpty())
                .andExpect(jsonPath("$.matchedProCount").value(0))
                .andExpect(jsonPath("$.matchFactors[0]").value("CATEGORY"))
                .andExpect(jsonPath("$.matchFactors.length()").value(3))
                .andExpect(jsonPath("$.address.lineFull").value("Moda Cad. No: 14 Daire: 5"))
                .andExpect(jsonPath("$.address.doorNote").value("Zil: Yılmaz"))
                .andExpect(jsonPath("$.answers[0].questionKey").value("since")));
        assertThat(r.get("publicCode").asString()).matches("BD-\\d{5,}");
        Instant created = Instant.parse(r.get("createdAt").asString());
        Instant expires = Instant.parse(r.get("expiresAt").asString());
        assertThat(Math.abs(ChronoUnit.SECONDS.between(created.plus(7, ChronoUnit.DAYS), expires))).isLessThan(10);
    }

    @Test
    void plannedRequestNeedsValidFutureWindowWithin30Days() throws Exception {
        Account ali = register();
        String addr = addressId(ali, "Kadıköy");
        Instant now = Instant.now();
        record Case(Instant from, Instant to, String field) {
        }
        List<Case> bad = List.of(
                new Case(null, null, "preferredFrom"),
                new Case(now.plus(2, ChronoUnit.DAYS), null, "preferredTo"),
                new Case(now.minus(1, ChronoUnit.HOURS), now.plus(1, ChronoUnit.DAYS), "preferredFrom"),
                new Case(now.plus(3, ChronoUnit.DAYS), now.plus(2, ChronoUnit.DAYS), "preferredTo"),
                new Case(now.plus(3, ChronoUnit.DAYS), now.plus(3, ChronoUnit.DAYS), "preferredTo"),
                new Case(now.plus(31, ChronoUnit.DAYS), now.plus(32, ChronoUnit.DAYS), "preferredFrom"),
                new Case(now.plus(29, ChronoUnit.DAYS), now.plus(31, ChronoUnit.DAYS), "preferredTo"));
        for (Case c : bad) {
            Map<String, Object> body = requestBody(addr);
            body.put("urgency", "PLANNED");
            body.put("preferredFrom", c.from() == null ? null : c.from().toString());
            body.put("preferredTo", c.to() == null ? null : c.to().toString());
            call(HttpMethod.POST, "/api/v1/requests", ali.access(), body)
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                    .andExpect(jsonPath("$.field").value(c.field()));
        }
        Map<String, Object> ok = requestBody(addr);
        ok.put("urgency", "PLANNED");
        ok.put("preferredFrom", now.plus(2, ChronoUnit.DAYS).toString());
        ok.put("preferredTo", now.plus(2, ChronoUnit.DAYS).plus(3, ChronoUnit.HOURS).toString());
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), ok)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.urgency").value("PLANNED"))
                .andExpect(jsonPath("$.preferredFrom").isNotEmpty());
    }

    @Test
    void fieldValidationAndOwnershipOfAddressAndMedia() throws Exception {
        Account ali = register();
        Account other = register();
        String addr = addressId(ali, "Kadıköy");
        String foreignAddr = addressId(other, "Üsküdar");

        Map<String, Object> shortTitle = requestBody(addr);
        shortTitle.put("title", "abc");
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), shortTitle)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("title"));
        Map<String, Object> shortDesc = requestBody(addr);
        shortDesc.put("description", "çok kısa");
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), shortDesc)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("description"));
        Map<String, Object> badCategory = requestBody(addr);
        badCategory.put("categoryId", "yok");
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), badCategory)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("categoryId"));
        Map<String, Object> badAnswer = requestBody(addr);
        badAnswer.put("answers", List.of(Map.of("questionKey", "water_cut", "answer", "maybe")));
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), badAnswer)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("answers"));

        // Başkasının adresi: varlık sızmaz, 404.
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), requestBody(foreignAddr))
                .andExpect(status().isNotFound()).andExpect(jsonPath("$.code").value("NOT_FOUND"));

        // 6 fotoğraf: 400 (alan photoIds).
        List<String> six = new ArrayList<>();
        for (int i = 0; i < 6; i++) {
            six.add(upload(ali, jpeg(8 + i, 8), "REQUEST_PHOTO").get("id").asString());
        }
        Map<String, Object> tooMany = requestBody(addr);
        tooMany.put("photoIds", six);
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), tooMany)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("photoIds"));

        // Başkasının medyası: 404.
        String foreignPhoto = upload(other, jpeg(8, 8), "REQUEST_PHOTO").get("id").asString();
        Map<String, Object> foreign = requestBody(addr);
        foreign.put("photoIds", List.of(foreignPhoto));
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), foreign).andExpect(status().isNotFound());
        // Olmayan medya da 404.
        foreign.put("photoIds", List.of(newKey()));
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), foreign).andExpect(status().isNotFound());

        // Kendi medyası eklenir; aynı medya ikinci talebe bağlanamaz.
        Map<String, Object> withPhotos = requestBody(addr);
        withPhotos.put("photoIds", six.subList(0, 5));
        JsonNode created = body(call(HttpMethod.POST, "/api/v1/requests", ali.access(), withPhotos)
                .andExpect(status().isCreated()).andExpect(jsonPath("$.photos.length()").value(5)));
        assertThat(created.get("photos").get(0).get("url").asString()).contains("/api/v1/media/").contains("sig=");
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), withPhotos)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("photoIds"));
    }

    @Test
    void matchedProCountUsesCategoryDistrictAvailabilityApprovalAndExcludesOwner() throws Exception {
        Account ali = register();
        String addr = addressId(ali, "Kadıköy");
        Account match = pro("Eşleşen", List.of("plumbing"), List.of("Kadıköy", "Üsküdar"));
        Account onBreak = pro("Molada", List.of("plumbing"), List.of("Kadıköy"));
        jdbc.update("update pro_profiles set availability = 'ON_BREAK' where user_id = ?::uuid", onBreak.id());
        Account pending = pro("Onaysız", List.of("plumbing"), List.of("Kadıköy"));
        jdbc.update("update pro_profiles set review_status = 'PENDING_REVIEW' where user_id = ?::uuid", pending.id());
        pro("Başka ilçe", List.of("plumbing"), List.of("Ataşehir"));
        pro("Başka kategori", List.of("electrical"), List.of("Kadıköy"));
        // Sahibin kendisi de usta ve kapsıyor: sayılmaz.
        jdbc.update("insert into pro_profiles (user_id, business_name, review_status) values (?::uuid, 'Ali Usta', 'APPROVED')",
                ali.id());
        jdbc.update("insert into pro_categories values (?::uuid, 'plumbing')", ali.id());
        jdbc.update("insert into pro_districts values (?::uuid, ?)", ali.id(), districtId("Kadıköy"));

        JsonNode r = createRequest(ali, addr);
        assertThat(r.get("matchedProCount").asInt()).isEqualTo(1);
        // Eşleşen ustaya bildirim yazıldı, diğerlerine yazılmadı.
        assertThat(count("select count(*) from notifications where type = 'NEW_MATCHING_REQUEST' and user_id = ?::uuid",
                match.id())).isEqualTo(1);
        assertThat(count("select count(*) from notifications where type = 'NEW_MATCHING_REQUEST'")).isEqualTo(1);
        String params = jdbc.queryForObject("select params::text from notifications where user_id = ?::uuid",
                String.class, match.id());
        assertThat(params).contains(r.get("publicCode").asString());
    }

    @Test
    void requestWithZeroMatchesIsStillPublished() throws Exception {
        Account ali = register();
        createRequest(ali, addressId(ali, "Kadıköy"));
        call(HttpMethod.GET, "/api/v1/requests?scope=active", ali.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items.length()").value(1))
                .andExpect(jsonPath("$.items[0].status").value("OPEN"))
                .andExpect(jsonPath("$.nextCursor").isEmpty());
    }

    @Test
    void activeAndPastListsSplitByStatusAndExpiry() throws Exception {
        Account ali = register();
        String addr = addressId(ali, "Kadıköy");
        String open = createRequest(ali, addr).get("id").asString();
        String cancelled = createRequest(ali, addr).get("id").asString();
        String expired = createRequest(ali, addr).get("id").asString();
        String assigned = createRequest(ali, addr).get("id").asString();
        call(HttpMethod.POST, "/api/v1/requests/" + cancelled + "/cancel", ali.access(),
                Map.of("reason", "SOLVED")).andExpect(status().isOk());
        // Süresi geçmiş ama zamanlayıcı henüz çalışmamış: okuma anında EXPIRED sayılır, geçmişte listelenir.
        jdbc.update("update service_requests set expires_at = now() - interval '1 minute' where id = ?::uuid", expired);
        jdbc.update("update service_requests set status = 'ASSIGNED' where id = ?::uuid", assigned);

        JsonNode active = body(call(HttpMethod.GET, "/api/v1/requests?scope=active", ali.access(), null)
                .andExpect(status().isOk()));
        assertThat(ids(active.get("items"))).containsExactlyInAnyOrder(open, assigned);
        JsonNode past = body(call(HttpMethod.GET, "/api/v1/requests?scope=past", ali.access(), null)
                .andExpect(status().isOk()));
        assertThat(ids(past.get("items"))).containsExactlyInAnyOrder(cancelled, expired);
        past.get("items").forEach(i -> assertThat(i.get("status").asString()).isIn("CANCELLED", "EXPIRED"));
        call(HttpMethod.GET, "/api/v1/requests/" + expired, ali.access(), null)
                .andExpect(jsonPath("$.status").value("EXPIRED"));
        call(HttpMethod.GET, "/api/v1/requests?scope=bogus", ali.access(), null).andExpect(status().isBadRequest());

        // Başka müşteri listede görmez.
        Account other = register();
        call(HttpMethod.GET, "/api/v1/requests?scope=active", other.access(), null)
                .andExpect(jsonPath("$.items.length()").value(0));
    }

    @Test
    void cursorPagingWalksTheList() throws Exception {
        Account ali = register();
        String addr = addressId(ali, "Kadıköy");
        for (int i = 0; i < 3; i++) {
            createRequest(ali, addr);
        }
        JsonNode first = body(call(HttpMethod.GET, "/api/v1/requests?scope=active&limit=2", ali.access(), null)
                .andExpect(jsonPath("$.items.length()").value(2)));
        String next = first.get("nextCursor").asString();
        call(HttpMethod.GET, "/api/v1/requests?scope=active&limit=2&cursor=" + next, ali.access(), null)
                .andExpect(jsonPath("$.items.length()").value(1))
                .andExpect(jsonPath("$.nextCursor").isEmpty());
    }

    @Test
    void patchEditsOpenRequestAndExpiresPendingOffers() throws Exception {
        Account ali = register();
        String addr = addressId(ali, "Kadıköy");
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String id = createRequest(ali, addr).get("id").asString();
        String offerId = sendOffer(usta, id, offerBody("1000", "200")).get("id").asString();
        call(HttpMethod.GET, "/api/v1/requests/" + id, ali.access(), null)
                .andExpect(jsonPath("$.offerCount").value(1))
                .andExpect(jsonPath("$.minOfferTotal").value(1200.0));

        call(HttpMethod.PATCH, "/api/v1/requests/" + id, ali.access(), Map.of("title", "Yeni başlık burada"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Yeni başlık burada"))
                .andExpect(jsonPath("$.offerCount").value(0))
                .andExpect(jsonPath("$.matchedProCount").value(1));
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, offerId))
                .isEqualTo("EXPIRED");

        // Kategori değişince eşleşme yeniden hesaplanır.
        call(HttpMethod.PATCH, "/api/v1/requests/" + id, ali.access(), Map.of("categoryId", "electrical"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.matchedProCount").value(0))
                .andExpect(jsonPath("$.answers.length()").value(0));
        // Planlıya geçerken tarih şart.
        call(HttpMethod.PATCH, "/api/v1/requests/" + id, ali.access(), Map.of("urgency", "PLANNED"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("preferredFrom"));

        // Kapalı talep düzenlenemez.
        call(HttpMethod.POST, "/api/v1/requests/" + id + "/cancel", ali.access(), Map.of("reason", "OTHER"))
                .andExpect(status().isOk());
        call(HttpMethod.PATCH, "/api/v1/requests/" + id, ali.access(), Map.of("title", "Yine yeni başlık"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
    }

    @Test
    void cancelExpiresOffersAndRejectsRepeat() throws Exception {
        Account ali = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String id = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();
        String offerId = sendOffer(usta, id, offerBody("1000", "0")).get("id").asString();

        call(HttpMethod.POST, "/api/v1/requests/" + id + "/cancel", ali.access(),
                Map.of("reason", "PLANS_CHANGED", "note", "Vazgeçtim"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"))
                .andExpect(jsonPath("$.offerCount").value(0));
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, offerId))
                .isEqualTo("EXPIRED");
        assertThat(jdbc.queryForObject("select cancel_reason from service_requests where id = ?::uuid", String.class, id))
                .isEqualTo("PLANS_CHANGED");
        call(HttpMethod.POST, "/api/v1/requests/" + id + "/cancel", ali.access(), Map.of("reason", "OTHER"))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        call(HttpMethod.POST, "/api/v1/requests/" + id + "/cancel", ali.access(), Map.of("reason", "BOGUS"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void otherUsersGet404ForRequestAndNeverSeeFullAddress() throws Exception {
        Account ali = register();
        Account other = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String id = createRequest(ali, addressId(ali, "Kadıköy")).get("id").asString();

        call(HttpMethod.GET, "/api/v1/requests/" + id, other.access(), null).andExpect(status().isNotFound());
        call(HttpMethod.PATCH, "/api/v1/requests/" + id, other.access(), Map.of("title", "Ele geçirme denemesi"))
                .andExpect(status().isNotFound());
        call(HttpMethod.POST, "/api/v1/requests/" + id + "/cancel", other.access(), Map.of("reason", "OTHER"))
                .andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/requests/" + id + "/offers", other.access(), null).andExpect(status().isNotFound());
        // Usta müşteri uç noktasından da göremez.
        call(HttpMethod.GET, "/api/v1/requests/" + id, usta.access(), null).andExpect(status().isNotFound());
        // Ve kendi uç noktasında tam adres yok.
        String body = call(HttpMethod.GET, "/api/v1/pro/requests/" + id, usta.access(), null)
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        assertThat(body).doesNotContain("Moda Cad").doesNotContain("Zil").doesNotContain("lineFull");
        call(HttpMethod.GET, "/api/v1/requests/" + newKey(), ali.access(), null).andExpect(status().isNotFound());
    }

    @Test
    void anonymousRequestsAreRejected() throws Exception {
        call(HttpMethod.GET, "/api/v1/requests", null, null).andExpect(status().isUnauthorized());
    }
}
