package com.bitadilat.pro;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave2TestBase;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

class ProFlowTest extends Wave2TestBase {

    private byte[] pdf() {
        return "%PDF-1.4\n1 0 obj<<>>endobj\ntrailer<<>>\n%%EOF".getBytes(StandardCharsets.US_ASCII);
    }

    private Map<String, Object> application(List<Map<String, Object>> docs) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("businessName", "Yıldız Elektrik");
        m.put("bio", "Ev elektrik tesisatı.");
        m.put("experienceYears", 6);
        m.put("categoryIds", List.of("electrical"));
        m.put("districtIds", List.of(districtId("Ümraniye")));
        m.put("documents", docs);
        return m;
    }

    private Map<String, Object> doc(String type, String mediaId) {
        return Map.of("type", type, "mediaId", mediaId);
    }

    // ─── Başvuru ────────────────────────────────────────────────────────────

    @Test
    void applicationRequiresIdentityAndTradeCertAndOwnDocumentMedia() throws Exception {
        Account hasan = register();
        String id = upload(hasan, jpeg(10, 10), "PRO_DOCUMENT").get("id").asString();
        String cert = upload(hasan, pdf(), "PRO_DOCUMENT").get("id").asString();
        String photo = upload(hasan, jpeg(10, 10), "REQUEST_PHOTO").get("id").asString();

        // Eksik belge
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), application(List.of(doc("IDENTITY", id))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.field").value("documents"));
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), application(List.of()))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("documents"));
        // Alan doğrulaması
        Map<String, Object> noCategory = application(List.of(doc("IDENTITY", id), doc("TRADE_CERT", cert)));
        noCategory.put("categoryIds", List.of());
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), noCategory)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("categoryIds"));
        Map<String, Object> shortName = application(List.of(doc("IDENTITY", id), doc("TRADE_CERT", cert)));
        shortName.put("businessName", "A");
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), shortName)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("businessName"));
        // Amaç yanlış (REQUEST_PHOTO) → 400; başkasının belgesi → 404
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(),
                application(List.of(doc("IDENTITY", id), doc("TRADE_CERT", photo))))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("documents"));
        Account thief = register();
        call(HttpMethod.POST, "/api/v1/pro/application", thief.access(),
                application(List.of(doc("IDENTITY", id), doc("TRADE_CERT", cert))))
                .andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/pro/application", hasan.access(), null).andExpect(status().isNotFound());
        assertThat(count("select count(*) from pro_profiles")).isZero();
    }

    @Test
    void applicationLifecyclePendingBlocksResubmitNeedsDocumentsAllowsIt() throws Exception {
        Account hasan = register();
        String id = upload(hasan, jpeg(10, 10), "PRO_DOCUMENT").get("id").asString();
        String cert = upload(hasan, pdf(), "PRO_DOCUMENT").get("id").asString();
        Map<String, Object> body = application(List.of(doc("IDENTITY", id), doc("TRADE_CERT", cert)));

        JsonNode created = body(call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), body)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.reviewStatus").value("PENDING_REVIEW"))
                .andExpect(jsonPath("$.documents.length()").value(2))
                .andExpect(jsonPath("$.documents[0].status").value("PENDING"))
                .andExpect(jsonPath("$.categoryIds[0]").value("electrical"))
                .andExpect(jsonPath("$.submittedAt").isNotEmpty()));
        assertThat(created.get("documents").get(0).get("media").get("url").asString()).contains("sig=");
        call(HttpMethod.GET, "/api/v1/pro/application", hasan.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.reviewStatus").value("PENDING_REVIEW"));

        // PENDING_REVIEW iken tekrar → 409
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), body)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        // Onaylı/askıdaki de 409
        for (String s : List.of("APPROVED", "SUSPENDED")) {
            jdbc.update("update pro_profiles set review_status = ? where user_id = ?::uuid", s, hasan.id());
            call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), body).andExpect(status().isConflict());
        }

        // NEEDS_DOCUMENTS → yeniden gönderim (aynı ve yeni belgelerle), PENDING_REVIEW'e döner.
        jdbc.update("update pro_profiles set review_status = 'NEEDS_DOCUMENTS', review_note = 'Vergi levhası eksik' "
                + "where user_id = ?::uuid", hasan.id());
        call(HttpMethod.GET, "/api/v1/pro/application", hasan.access(), null)
                .andExpect(jsonPath("$.reviewNote").value("Vergi levhası eksik"));
        String tax = upload(hasan, jpeg(12, 12), "PRO_DOCUMENT").get("id").asString();
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(),
                application(List.of(doc("IDENTITY", id), doc("TRADE_CERT", cert), doc("TAX", tax))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.reviewStatus").value("PENDING_REVIEW"))
                .andExpect(jsonPath("$.reviewNote").isEmpty())
                .andExpect(jsonPath("$.documents.length()").value(3));
        assertThat(count("select count(*) from pro_documents where pro_id = ?::uuid", hasan.id())).isEqualTo(3);

        // REJECTED da yeniden başvurabilir.
        jdbc.update("update pro_profiles set review_status = 'REJECTED' where user_id = ?::uuid", hasan.id());
        call(HttpMethod.POST, "/api/v1/pro/application", hasan.access(), body).andExpect(status().isCreated());
    }

    @Test
    void unapprovedProIsBlockedFromProEndpoints() throws Exception {
        Account plain = register();
        Account pending = pro("Onaysız", List.of("plumbing"), List.of("Kadıköy"));
        jdbc.update("update pro_profiles set review_status = 'PENDING_REVIEW' where user_id = ?::uuid", pending.id());
        for (Account who : List.of(plain, pending)) {
            for (String path : List.of("/api/v1/pro/feed", "/api/v1/pro/profile", "/api/v1/pro/offers",
                    "/api/v1/pro/requests/" + newKey())) {
                call(HttpMethod.GET, path, who.access(), null)
                        .andExpect(status().isForbidden())
                        .andExpect(jsonPath("$.code").value("PRO_NOT_APPROVED"));
            }
            call(HttpMethod.PUT, "/api/v1/pro/availability", who.access(), Map.of("availability", "ON_BREAK"))
                    .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("PRO_NOT_APPROVED"));
        }
        call(HttpMethod.GET, "/api/v1/pro/feed", null, null).andExpect(status().isUnauthorized());
    }

    // ─── Akış ───────────────────────────────────────────────────────────────

    @Test
    void feedShowsOnlyMatchingOpenRequestsAndHonoursUrgencyAndBreak() throws Exception {
        Account usta = pro("Mavi", List.of("plumbing", "bathroom"), List.of("Kadıköy", "Üsküdar"));
        Account ali = register();
        Account zeynep = register();
        String kadikoy = addressId(ali, "Kadıköy");
        String atasehir = addressId(ali, "Ataşehir");
        String urgent = createRequest(ali, kadikoy).get("id").asString();
        Map<String, Object> planned = requestBody(kadikoy);
        planned.put("urgency", "PLANNED");
        planned.put("categoryId", "bathroom");
        planned.put("answers", List.of());
        planned.put("preferredFrom", Instant.now().plus(2, ChronoUnit.DAYS).toString());
        planned.put("preferredTo", Instant.now().plus(2, ChronoUnit.DAYS).plus(2, ChronoUnit.HOURS).toString());
        String plannedId = body(call(HttpMethod.POST, "/api/v1/requests", zeynep.access(),
                withAddress(planned, addressId(zeynep, "Üsküdar"))).andExpect(status().isCreated())).get("id").asString();

        // Eşleşmeyenler
        Map<String, Object> wrongCategory = requestBody(kadikoy);
        wrongCategory.put("categoryId", "electrical");
        wrongCategory.put("answers", List.of());
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), wrongCategory).andExpect(status().isCreated());
        call(HttpMethod.POST, "/api/v1/requests", ali.access(), requestBody(atasehir)).andExpect(status().isCreated());
        String cancelled = createRequest(ali, kadikoy).get("id").asString();
        call(HttpMethod.POST, "/api/v1/requests/" + cancelled + "/cancel", ali.access(), Map.of("reason", "OTHER"));
        String expired = createRequest(ali, kadikoy).get("id").asString();
        jdbc.update("update service_requests set expires_at = now() - interval '1 minute' where id = ?::uuid", expired);

        JsonNode all = body(call(HttpMethod.GET, "/api/v1/pro/feed", usta.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.onBreak").value(false)));
        assertThat(ids(all.get("items"))).containsExactly(plannedId, urgent); // yeniden eskiye
        JsonNode first = all.get("items").get(1);
        assertThat(first.get("districtName").asString()).isEqualTo("Kadıköy");
        assertThat(first.get("neighborhood").asString()).isEqualTo("Caferağa");
        assertThat(first.get("photoCount").asInt()).isZero();
        assertThat(first.get("myOfferId").isNull()).isTrue();
        assertThat(first.has("description")).isFalse();
        assertThat(first.toString()).doesNotContain("Moda Cad");

        assertThat(ids(feed(usta, "?urgency=URGENT"))).containsExactly(urgent);
        assertThat(ids(feed(usta, "?urgency=PLANNED"))).containsExactly(plannedId);
        call(HttpMethod.GET, "/api/v1/pro/feed?urgency=NOW", usta.access(), null).andExpect(status().isBadRequest());

        // Teklif verince myOfferId dolar ve teklif sayısı artar.
        String offer = sendOffer(usta, urgent, offerBody("1000", "0")).get("id").asString();
        JsonNode item = feed(usta, "?urgency=URGENT").get(0);
        assertThat(item.get("myOfferId").asString()).isEqualTo(offer);
        assertThat(item.get("offerCount").asInt()).isEqualTo(1);

        // Mola: liste boş, onBreak true.
        call(HttpMethod.PUT, "/api/v1/pro/availability", usta.access(), Map.of("availability", "ON_BREAK"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.availability").value("ON_BREAK"));
        call(HttpMethod.GET, "/api/v1/pro/feed", usta.access(), null)
                .andExpect(jsonPath("$.onBreak").value(true)).andExpect(jsonPath("$.items.length()").value(0));
        call(HttpMethod.PUT, "/api/v1/pro/availability", usta.access(), Map.of("availability", "ACTIVE"))
                .andExpect(status().isOk());
        assertThat(feed(usta, "").size()).isEqualTo(2);
    }

    private Map<String, Object> withAddress(Map<String, Object> body, String addressId) {
        body.put("addressId", addressId);
        return body;
    }

    private JsonNode feed(Account usta, String query) throws Exception {
        return body(call(HttpMethod.GET, "/api/v1/pro/feed" + query, usta.access(), null).andExpect(status().isOk()))
                .get("items");
    }

    @Test
    void proRequestDetailIsMaskedAndLimitedToMatchingPros() throws Exception {
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        Account elsewhere = pro("Uzak", List.of("plumbing"), List.of("Ataşehir"));
        Account ali = register();
        String photo = upload(ali, jpeg(20, 20), "REQUEST_PHOTO").get("id").asString();
        Map<String, Object> body = requestBody(addressId(ali, "Kadıköy"));
        body.put("photoIds", List.of(photo));
        String req = body(call(HttpMethod.POST, "/api/v1/requests", ali.access(), body).andExpect(status().isCreated()))
                .get("id").asString();

        JsonNode d = body(call(HttpMethod.GET, "/api/v1/pro/requests/" + req, usta.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.photoCount").value(1))
                .andExpect(jsonPath("$.photos.length()").value(1))
                .andExpect(jsonPath("$.answers[0].questionKey").value("since"))
                .andExpect(jsonPath("$.myOffer").isEmpty())
                .andExpect(jsonPath("$.address").doesNotExist())
                .andExpect(jsonPath("$.description").isNotEmpty()));
        assertThat(d.toString()).doesNotContain("Moda Cad").doesNotContain("Zil:");
        call(HttpMethod.GET, "/api/v1/pro/requests/" + req, elsewhere.access(), null).andExpect(status().isNotFound());

        sendOffer(usta, req, offerBody("1000", "100"));
        call(HttpMethod.GET, "/api/v1/pro/requests/" + req, usta.access(), null)
                .andExpect(jsonPath("$.myOffer.totalAmount").value(1100.0))
                .andExpect(jsonPath("$.myOffer.serviceFee").value(110.0))
                .andExpect(jsonPath("$.myOfferId").isNotEmpty());

        // Kapanınca teklifi olmayan usta göremez; teklifi olan görmeye devam eder.
        Account late = pro("Geç", List.of("plumbing"), List.of("Kadıköy"));
        call(HttpMethod.POST, "/api/v1/requests/" + req + "/cancel", ali.access(), Map.of("reason", "SOLVED"));
        call(HttpMethod.GET, "/api/v1/pro/requests/" + req, late.access(), null).andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/pro/requests/" + req, usta.access(), null).andExpect(status().isOk());
    }

    // ─── Profil ─────────────────────────────────────────────────────────────

    @Test
    void profileCanBeReadAndReplaced() throws Exception {
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        call(HttpMethod.GET, "/api/v1/pro/profile", usta.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.businessName").value("Mavi"))
                .andExpect(jsonPath("$.reviewStatus").value("APPROVED"))
                .andExpect(jsonPath("$.availability").value("ACTIVE"))
                .andExpect(jsonPath("$.ratingCount").value(10))
                .andExpect(jsonPath("$.workingHours.length()").value(0));

        Map<String, Object> put = new LinkedHashMap<>();
        put.put("businessName", "Mavi Hat Tesisat");
        put.put("bio", "Yeni yazı");
        put.put("experienceYears", 12);
        put.put("categoryIds", List.of("plumbing", "bathroom"));
        put.put("districtIds", List.of(districtId("Kadıköy"), districtId("Maltepe")));
        put.put("workingHours", List.of(
                Map.of("weekday", 1, "start", "08:00", "end", "19:00", "acceptsUrgent", true),
                Map.of("weekday", 6, "start", "09:30", "end", "14:00", "acceptsUrgent", false)));
        call(HttpMethod.PUT, "/api/v1/pro/profile", usta.access(), put)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.businessName").value("Mavi Hat Tesisat"))
                .andExpect(jsonPath("$.categoryIds.length()").value(2))
                .andExpect(jsonPath("$.districtIds.length()").value(2))
                .andExpect(jsonPath("$.workingHours[0].start").value("08:00"))
                .andExpect(jsonPath("$.workingHours[1].acceptsUrgent").value(false));
        // Aynı kümeyle ikinci kez de çalışır (silme + ekleme aynı işlemde).
        call(HttpMethod.PUT, "/api/v1/pro/profile", usta.access(), put).andExpect(status().isOk());

        Map<String, Object> badHours = new LinkedHashMap<>(put);
        badHours.put("workingHours", List.of(Map.of("weekday", 1, "start", "19:00", "end", "08:00", "acceptsUrgent", true)));
        call(HttpMethod.PUT, "/api/v1/pro/profile", usta.access(), badHours)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("workingHours"));
        badHours.put("workingHours", List.of(Map.of("weekday", 8, "start", "08:00", "end", "09:00", "acceptsUrgent", true)));
        call(HttpMethod.PUT, "/api/v1/pro/profile", usta.access(), badHours).andExpect(status().isBadRequest());
        badHours.put("workingHours", List.of(Map.of("weekday", 2, "start", "8:00", "end", "09:00", "acceptsUrgent", true)));
        call(HttpMethod.PUT, "/api/v1/pro/profile", usta.access(), badHours).andExpect(status().isBadRequest());
    }

    // ─── Herkese açık profil ────────────────────────────────────────────────

    @Test
    void publicProProfileHidesContactAndOnlyShowsApproved() throws Exception {
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy", "Üsküdar"));
        Account viewer = register();
        String doc = upload(usta, jpeg(9, 9), "PRO_DOCUMENT").get("id").asString();
        jdbc.update("insert into pro_documents (pro_id, type, media_id, status) values (?::uuid, 'IDENTITY', ?::uuid, 'ACCEPTED')",
                usta.id(), doc);

        JsonNode p = body(call(HttpMethod.GET, "/api/v1/pros/" + usta.id(), viewer.access(), null)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.businessName").value("Mavi"))
                .andExpect(jsonPath("$.verifiedDocuments[0]").value("IDENTITY"))
                .andExpect(jsonPath("$.districts.length()").value(2))
                .andExpect(jsonPath("$.categoryIds[0]").value("plumbing"))
                .andExpect(jsonPath("$.memberSince").isNotEmpty()));
        assertThat(p.toString()).doesNotContain(usta.email()).doesNotContain("phone").doesNotContain("email");

        call(HttpMethod.GET, "/api/v1/pros/" + usta.id() + "/reviews", viewer.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.items.length()").value(0))
                .andExpect(jsonPath("$.nextCursor").isEmpty());

        // Değerlendirme satırı: "A.Y." ve anonim.
        String customer = viewer.id();
        jdbc.update("update users set full_name = 'Ali Yılmaz' where id = ?::uuid", customer);
        insertReview(usta, customer, "Ali", false);
        insertReview(usta, customer, "Anon", true);
        JsonNode reviews = body(call(HttpMethod.GET, "/api/v1/pros/" + usta.id() + "/reviews", viewer.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.items.length()").value(2)));
        List<String> authors = new ArrayList<>();
        reviews.get("items").forEach(i -> authors.add(i.get("authorDisplay").asString()));
        assertThat(authors).containsExactlyInAnyOrder("A.Y.", "Anonim");
        assertThat(reviews.get("items").get(0).get("tags").isArray()).isTrue();

        jdbc.update("update pro_profiles set review_status = 'PENDING_REVIEW' where user_id = ?::uuid", usta.id());
        call(HttpMethod.GET, "/api/v1/pros/" + usta.id(), viewer.access(), null).andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/pros/" + usta.id() + "/reviews", viewer.access(), null)
                .andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/pros/" + newKey(), viewer.access(), null).andExpect(status().isNotFound());
    }

    private int jobSeq = 0;

    private void insertReview(Account pro, String customerId, String comment, boolean anonymous) {
        // reviews.job_id benzersiz ve jobs'a bağlı: minimal talep + teklif + iş satırı kurulur.
        String addr = jdbc.queryForObject("""
                insert into addresses (user_id, label, district_id, neighborhood, line_full_encrypted)
                values (?::uuid, 'x', ?, 'x', 'x') returning id::text""", String.class, customerId, districtId("Kadıköy"));
        String req = jdbc.queryForObject("""
                insert into service_requests (public_code, customer_id, category_id, urgency, title, description,
                  district_id, neighborhood, address_id, status, expires_at)
                values (?, ?::uuid, 'plumbing', 'URGENT', 'Başlık deneme', 'Açıklama açıklama açıklama', ?, 'x', ?::uuid,
                  'ASSIGNED', now() + interval '1 day') returning id::text""", String.class,
                "BD-9" + String.format("%04d", ++jobSeq) + System.nanoTime() % 1000, customerId, districtId("Kadıköy"), addr);
        String offer = jdbc.queryForObject("""
                insert into offers (public_code, request_id, pro_id, labor_amount, materials_amount, total_amount,
                  arrival_from, arrival_to, warranty_months, status, valid_until)
                values (?, ?::uuid, ?::uuid, 100, 0, 100, now(), now() + interval '2 hours', 0, 'ACCEPTED',
                  now() + interval '2 hours') returning id::text""", String.class,
                "T-9" + String.format("%04d", jobSeq) + System.nanoTime() % 1000, req, pro.id());
        String job = jdbc.queryForObject("""
                insert into jobs (request_id, offer_id, customer_id, pro_id, status)
                values (?::uuid, ?::uuid, ?::uuid, ?::uuid, 'COMPLETED') returning id::text""", String.class,
                req, offer, customerId, pro.id());
        jdbc.update("""
                insert into reviews (job_id, customer_id, pro_id, rating, tags, comment, is_anonymous)
                values (?::uuid, ?::uuid, ?::uuid, 5, array['Dakik'], ?, ?)""", job, customerId, pro.id(), comment,
                anonymous);
    }
}
