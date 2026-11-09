package com.bitadilat;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.imageio.ImageIO;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.http.HttpMethod;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import tools.jackson.databind.JsonNode;

/** Talep, teklif, usta ve medya testlerinin ortak yardımcıları. Her testten önce talep/usta verisi temizlenir. */
public abstract class Wave2TestBase extends ApiTestBase {

    @BeforeEach
    void cleanWave2Data() {
        jdbc.execute("TRUNCATE TABLE service_requests, pro_profiles, notifications CASCADE");
    }

    protected int districtId(String name) {
        return jdbc.queryForObject("select id from districts where name = ?", Integer.class, name);
    }

    protected String addressId(Account customer, String district) throws Exception {
        Map<String, Object> body = Map.of("label", "Ev", "districtId", districtId(district), "neighborhood", "Caferağa",
                "lineFull", "Moda Cad. No: 14 Daire: 5", "doorNote", "Zil: Yılmaz");
        return body(call(HttpMethod.POST, "/api/v1/me/addresses", customer.access(), body)
                .andExpect(status().isCreated())).get("id").asString();
    }

    /** Onaylı, ACTIVE usta: kayıtlı kullanıcı + profil + kategori/ilçe satırları. */
    protected Account pro(String business, List<String> categories, List<String> districts) throws Exception {
        Account a = register();
        jdbc.update("insert into pro_profiles (user_id, business_name, experience_years, review_status, approved_at, "
                        + "rating_avg, rating_count, completed_jobs) values (?::uuid, ?, 5, 'APPROVED', now(), 4.50, 10, 20)",
                a.id(), business);
        for (String c : categories) {
            jdbc.update("insert into pro_categories (pro_id, category_id) values (?::uuid, ?)", a.id(), c);
        }
        for (String d : districts) {
            jdbc.update("insert into pro_districts (pro_id, district_id) values (?::uuid, ?)", a.id(), districtId(d));
        }
        return a;
    }

    protected void setProRating(Account pro, String rating) {
        jdbc.update("update pro_profiles set rating_avg = ?::numeric where user_id = ?::uuid", rating, pro.id());
    }

    protected Map<String, Object> requestBody(String addressId) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("categoryId", "plumbing");
        m.put("urgency", "URGENT");
        m.put("title", "Banyo lavabo altı su kaçağı");
        m.put("description", "Lavabo altındaki sifondan su damlıyor, dolabın içi ıslandı.");
        m.put("addressId", addressId);
        m.put("photoIds", List.of());
        m.put("answers", List.of(Map.of("questionKey", "since", "answer", "today")));
        return m;
    }

    protected JsonNode createRequest(Account customer, String addressId) throws Exception {
        return body(call(HttpMethod.POST, "/api/v1/requests", customer.access(), requestBody(addressId))
                .andExpect(status().isCreated()));
    }

    protected Map<String, Object> offerBody(String labor, String materials, Instant from, Instant to) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("laborAmount", new java.math.BigDecimal(labor));
        m.put("materialsAmount", new java.math.BigDecimal(materials));
        m.put("arrivalFrom", from.toString());
        m.put("arrivalTo", to.toString());
        m.put("warrantyMonths", 6);
        m.put("note", "Test teklifi");
        m.put("items", List.of());
        return m;
    }

    /** Yarından başlayan 3 saatlik varış aralığı. */
    protected Map<String, Object> offerBody(String labor, String materials) {
        Instant from = Instant.now().plus(1, ChronoUnit.DAYS);
        return offerBody(labor, materials, from, from.plus(3, ChronoUnit.HOURS));
    }

    protected JsonNode sendOffer(Account pro, String requestId, Map<String, Object> body) throws Exception {
        return body(call(HttpMethod.POST, "/api/v1/pro/requests/" + requestId + "/offers", pro.access(), body)
                .andExpect(status().isCreated()));
    }

    protected byte[] jpeg(int w, int h) throws Exception {
        BufferedImage img = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(img, "jpg", out);
        return out.toByteArray();
    }

    protected JsonNode upload(Account owner, byte[] data, String purpose) throws Exception {
        return body(uploadRaw(owner, data, purpose).andExpect(status().isCreated()));
    }

    protected org.springframework.test.web.servlet.ResultActions uploadRaw(Account owner, byte[] data, String purpose)
            throws Exception {
        return mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/media")
                .file(new MockMultipartFile("file", "x.bin", "application/octet-stream", data))
                .param("purpose", purpose)
                .header("Authorization", "Bearer " + owner.access()));
    }

    protected List<String> ids(JsonNode items) {
        List<String> out = new ArrayList<>();
        items.forEach(n -> out.add(n.get("id").asString()));
        return out;
    }

    protected long count(String sql, Object... args) {
        return jdbc.queryForObject(sql, Long.class, args);
    }

    protected static String newKey() {
        return UUID.randomUUID().toString();
    }
}
