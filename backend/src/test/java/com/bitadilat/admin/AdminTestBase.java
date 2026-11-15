package com.bitadilat.admin;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpMethod;
import org.springframework.test.web.servlet.ResultActions;
import org.junit.jupiter.api.BeforeEach;
import tools.jackson.databind.JsonNode;

/** Admin ve bildirim testlerinin ortak yardımcıları (Craftgate sahte, gerçek PostgreSQL). */
public abstract class AdminTestBase extends Wave3TestBase {

    /** Açık şikayetli iş: iş ve emanet DISPUTED. */
    protected record Disputed(Setup s, String jobId, String complaintId, String complaintCode, String ref) {
    }

    /** Defter ve denetim toplamları testten teste taşınmasın (prototip emanetleri talebe bağlı olmadığı için kalır). */
    @BeforeEach
    void cleanAdminData() {
        jdbc.execute("TRUNCATE TABLE admin_actions, escrow_payment, payout_ledger");
    }

    protected Account admin() throws Exception {
        Account a = register();
        jdbc.update("update users set is_admin = true where id = ?::uuid", a.id());
        return a;
    }

    protected ResultActions get(Account who, String path) throws Exception {
        return call(HttpMethod.GET, "/api/v1" + path, who.access(), null);
    }

    protected ResultActions post(Account who, String path, Object body) throws Exception {
        return call(HttpMethod.POST, "/api/v1" + path, who.access(), body);
    }

    protected JsonNode ok(ResultActions r) throws Exception {
        return body(r.andExpect(status().isOk()));
    }

    protected static byte[] pdf() {
        return "%PDF-1.4\n1 0 obj<<>>endobj\ntrailer<<>>\n%%EOF".getBytes(StandardCharsets.US_ASCII);
    }

    /** Gerçek başvuru uç noktasıyla PENDING_REVIEW usta (kimlik + meslek belgesi + vergi levhası). */
    protected Account pendingPro(String business) throws Exception {
        Account pro = register();
        String id = upload(pro, jpeg(10, 10), "PRO_DOCUMENT").get("id").asString();
        String cert = upload(pro, pdf(), "PRO_DOCUMENT").get("id").asString();
        String tax = upload(pro, jpeg(12, 12), "PRO_DOCUMENT").get("id").asString();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("businessName", business);
        m.put("bio", "Ev elektrik tesisatı.");
        m.put("experienceYears", 6);
        m.put("categoryIds", List.of("electrical"));
        m.put("districtIds", List.of(districtId("Ümraniye")));
        m.put("documents", List.of(Map.of("type", "IDENTITY", "mediaId", id), Map.of("type", "TRADE_CERT", "mediaId", cert),
                Map.of("type", "TAX", "mediaId", tax)));
        call(HttpMethod.POST, "/api/v1/pro/application", pro.access(), m).andExpect(status().isCreated());
        return pro;
    }

    /** Ödenmiş, randevulu, başlamış iş + açık şikayet. */
    protected Disputed disputedJob() throws Exception {
        return disputedJob("900", "300");
    }

    protected Disputed disputedJob(String labor, String materials) throws Exception {
        Setup s = openRequestWithOffer(labor, materials);
        String ref = pay(s);
        String jobId = jdbc.queryForObject("select job_id::text from escrow_payment where ref = ?", String.class, ref);
        schedule(s, jobId);
        startWork(s, jobId);
        JsonNode c = body(jobPost(s.customer(), jobId, "/complaint", Map.of("reason", "EXTRA_CHARGE",
                "description", "Teklif dışı ek ücret talep edildi, kabul etmedim.")).andExpect(status().isCreated()));
        return new Disputed(s, jobId, c.get("id").asString(), c.get("publicCode").asString(), ref);
    }

    protected ResultActions decide(Account admin, Disputed d, String decision, boolean warn, boolean suspend)
            throws Exception {
        return post(admin, "/admin/complaints/" + d.complaintId() + "/decision", Map.of("decision", decision,
                "note", "Mesajlar ve kanıtlar incelendi, karar bu yönde.", "warnPro", warn, "suspendPro", suspend));
    }

    protected ResultActions decide(Account admin, Disputed d, String decision) throws Exception {
        return decide(admin, d, decision, false, false);
    }

    protected long adminActions(String action, String targetId) {
        return count("select count(*) from admin_actions where action = ? and target_id = ?", action, targetId);
    }

    protected java.math.BigDecimal ledger(String ref, String kind) {
        return jdbc.queryForObject("select coalesce(sum(amount), 0) from payout_ledger where payment_ref = ? and kind = ?",
                java.math.BigDecimal.class, ref, kind);
    }

    protected long ledgerRows(String ref) {
        return count("select count(*) from payout_ledger where payment_ref = ?", ref);
    }
}
