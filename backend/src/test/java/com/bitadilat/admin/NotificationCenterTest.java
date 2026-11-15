package com.bitadilat.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.job.JobScheduler;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** Bildirim merkezi uç noktaları ve her bildirim türünün params / targetRoute sözleşmesi. */
class NotificationCenterTest extends AdminTestBase {

    @Autowired
    private JobScheduler scheduler;

    private JsonNode center(Account who) throws Exception {
        return ok(get(who, "/notifications?limit=50"));
    }

    private int unread(Account who) throws Exception {
        return ok(get(who, "/me")).get("unreadNotifications").asInt();
    }

    /** Son bildirim (en yeni önce) bu türde ve çağıranın bildirimlerinde. */
    private JsonNode latest(Account who, String type) throws Exception {
        for (JsonNode n : center(who).get("items")) {
            if (n.get("type").asString().equals(type)) {
                return n;
            }
        }
        throw new AssertionError(who.email() + " için " + type + " bildirimi yok: " + center(who));
    }

    private static void assertParams(JsonNode n, String... keys) {
        List<String> actual = new ArrayList<>();
        n.get("params").propertyNames().forEach(actual::add);
        assertThat(actual).contains(keys);
        for (String key : keys) {
            JsonNode v = n.get("params").get(key);
            assertThat(v.isString() || v.isNumber()).as("params." + key + " düz değer").isTrue();
        }
    }

    // ─── Liste, okundu, sayaç ───────────────────────────────────────────────

    @Test
    void emptyCenterHasZeroUnreadAndMeCarriesTheCount() throws Exception {
        Account user = register();
        JsonNode c = center(user);
        assertThat(c.get("items")).isEmpty();
        assertThat(c.get("nextCursor").isNull()).isTrue();
        assertThat(c.get("unreadCount").asInt()).isZero();
        assertThat(unread(user)).isZero();
        get(register(), "/notifications").andExpect(status().isOk());
        call(HttpMethod.GET, "/api/v1/notifications", null, null).andExpect(status().isUnauthorized());
        call(HttpMethod.PUT, "/api/v1/devices", null, Map.of("platform", "IOS", "token", "t")).andExpect(status().isUnauthorized());
    }

    @Test
    void listIsNewestFirstPagedAndUnreadCountTracksReadState() throws Exception {
        Account customer = register();
        for (int i = 0; i < 5; i++) {
            jdbc.update("""
                    insert into notifications (user_id, type, title_key, body_key, params, target_route, created_at)
                    values (?::uuid, 'PRO_APPROVED', 'a', 'b', cast(? as jsonb), '/p/feed', now() - (? * interval '1 minute'))""",
                    customer.id(), "{\"n\": " + i + "}", 10 - i);
        }
        JsonNode all = center(customer);
        assertThat(all.get("items")).hasSize(5);
        assertThat(all.get("unreadCount").asInt()).isEqualTo(5);
        assertThat(unread(customer)).isEqualTo(5);
        // En yeni önce: n=4 en yeni.
        assertThat(all.get("items").get(0).get("params").get("n").asInt()).isEqualTo(4);
        assertThat(all.get("items").get(4).get("params").get("n").asInt()).isZero();
        JsonNode first = all.get("items").get(0);
        assertThat(first.get("type").asString()).isEqualTo("PRO_APPROVED");
        assertThat(first.get("targetRoute").asString()).isEqualTo("/p/feed");
        assertThat(first.get("read").asBoolean()).isFalse();
        assertThat(first.get("createdAt").asString()).isNotBlank();
        assertThat(first.get("id").asString()).isNotBlank();

        // Sayfalama: limit=2 → imleçle devam, üçüncü sayfa son.
        JsonNode p1 = ok(get(customer, "/notifications?limit=2"));
        assertThat(p1.get("items")).hasSize(2);
        assertThat(p1.get("nextCursor").asString()).isNotBlank();
        assertThat(p1.get("unreadCount").asInt()).isEqualTo(5); // sayaç sayfadan bağımsız
        JsonNode p2 = ok(get(customer, "/notifications?limit=2&cursor=" + p1.get("nextCursor").asString()));
        assertThat(p2.get("items").get(0).get("params").get("n").asInt()).isEqualTo(2);
        JsonNode p3 = ok(get(customer, "/notifications?limit=2&cursor=" + p2.get("nextCursor").asString()));
        assertThat(p3.get("items")).hasSize(1);
        assertThat(p3.get("nextCursor").isNull()).isTrue();
        get(customer, "/notifications?limit=0").andExpect(status().isBadRequest());
        get(customer, "/notifications?cursor=abc").andExpect(status().isBadRequest());

        // Seçilenleri okundu yap.
        String a = all.get("items").get(0).get("id").asString();
        String b = all.get("items").get(1).get("id").asString();
        post(customer, "/notifications/read", Map.of("ids", List.of(a, b))).andExpect(status().isNoContent());
        assertThat(unread(customer)).isEqualTo(3);
        JsonNode after = center(customer);
        assertThat(after.get("unreadCount").asInt()).isEqualTo(3);
        assertThat(after.get("items").get(0).get("read").asBoolean()).isTrue();
        assertThat(after.get("items").get(2).get("read").asBoolean()).isFalse();
        // Boş liste hiçbir şeyi değiştirmez; bozuk kimlik 400.
        post(customer, "/notifications/read", Map.of("ids", List.of())).andExpect(status().isNoContent());
        assertThat(unread(customer)).isEqualTo(3);
        post(customer, "/notifications/read", Map.of("ids", List.of("nope"))).andExpect(status().isBadRequest());
        // ids yoksa (gövde de yoksa) hepsi okundu.
        post(customer, "/notifications/read", null).andExpect(status().isNoContent());
        assertThat(unread(customer)).isZero();
        assertThat(center(customer).get("unreadCount").asInt()).isZero();
    }

    @Test
    void markAllReadWorksWithAnEmptyJsonObject() throws Exception {
        Account user = register();
        jdbc.update("insert into notifications (user_id, type, title_key, body_key) values (?::uuid, 'PRO_APPROVED', 'a', 'b')",
                user.id());
        post(user, "/notifications/read", Map.of()).andExpect(status().isNoContent());
        assertThat(unread(user)).isZero();
    }

    @Test
    void nobodyCanMarkSomeoneElsesNotificationRead() throws Exception {
        Account owner = register();
        Account intruder = register();
        jdbc.update("insert into notifications (user_id, type, title_key, body_key) values (?::uuid, 'PRO_APPROVED', 'a', 'b')",
                owner.id());
        String id = center(owner).get("items").get(0).get("id").asString();
        post(intruder, "/notifications/read", Map.of("ids", List.of(id))).andExpect(status().isNoContent());
        assertThat(unread(owner)).isEqualTo(1);
        assertThat(center(owner).get("items").get(0).get("read").asBoolean()).isFalse();
        // "Hepsini okundu yap" da yalnız kendi bildirimlerine dokunur.
        post(intruder, "/notifications/read", null).andExpect(status().isNoContent());
        assertThat(unread(owner)).isEqualTo(1);
        // Başkasının bildirimi listede de görünmez.
        assertThat(center(intruder).get("items")).isEmpty();
    }

    // ─── Cihaz token'ı ──────────────────────────────────────────────────────

    @Test
    void putDevicesUpsertsByTokenAndMovesItToTheNewOwner() throws Exception {
        Account first = register();
        Account second = register();
        String token = "fcm-token-" + UUID.randomUUID();
        call(HttpMethod.PUT, "/api/v1/devices", first.access(), Map.of("platform", "IOS", "token", token))
                .andExpect(status().isNoContent());
        assertThat(count("select count(*) from device_tokens where token = ?", token)).isEqualTo(1);
        // Aynı kullanıcı aynı token'ı tekrar gönderirse satır çoğalmaz; platform güncellenir.
        call(HttpMethod.PUT, "/api/v1/devices", first.access(), Map.of("platform", "ANDROID", "token", token))
                .andExpect(status().isNoContent());
        assertThat(count("select count(*) from device_tokens where token = ?", token)).isEqualTo(1);
        assertThat(jdbc.queryForObject("select platform from device_tokens where token = ?", String.class, token))
                .isEqualTo("ANDROID");
        // Cihaz el değiştirdi: token yeni kullanıcıya geçer.
        call(HttpMethod.PUT, "/api/v1/devices", second.access(), Map.of("platform", "WEB", "token", token))
                .andExpect(status().isNoContent());
        assertThat(count("select count(*) from device_tokens where token = ?", token)).isEqualTo(1);
        assertThat(jdbc.queryForObject("select user_id::text from device_tokens where token = ?", String.class, token))
                .isEqualTo(second.id());
        // Doğrulama.
        call(HttpMethod.PUT, "/api/v1/devices", first.access(), Map.of("platform", "SYMBIAN", "token", "x"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("platform"));
        call(HttpMethod.PUT, "/api/v1/devices", first.access(), Map.of("platform", "IOS", "token", " "))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("token"));
        call(HttpMethod.PUT, "/api/v1/devices", first.access(), Map.of("platform", "IOS", "token", "x".repeat(513)))
                .andExpect(status().isBadRequest());
    }

    // ─── Tür başına params ve targetRoute ───────────────────────────────────

    @Test
    void requestAndOfferNotificationsCarryTheContractParamsAndTargets() throws Exception {
        Account customer = register();
        Account mavi = pro("Mavi Hat", List.of("plumbing"), List.of("Kadıköy"));
        Account kaya = pro("Kaya Tesisat", List.of("plumbing"), List.of("Kadıköy"));
        String requestId = createRequest(customer, addressId(customer, "Kadıköy")).get("id").asString();
        String code = jdbc.queryForObject("select public_code from service_requests where id = ?::uuid", String.class,
                requestId);

        JsonNode matching = latest(mavi, "NEW_MATCHING_REQUEST");
        assertParams(matching, "publicCode", "title", "districtName");
        assertThat(matching.get("params").get("publicCode").asString()).isEqualTo(code);
        assertThat(matching.get("params").get("title").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(matching.get("params").get("districtName").asString()).isEqualTo("Kadıköy");
        assertThat(matching.get("targetRoute").asString()).isEqualTo("/p/requests/" + requestId);
        assertThat(matching.get("read").asBoolean()).isFalse();

        String maviOffer = sendOffer(mavi, requestId, offerBody("900", "300")).get("id").asString();
        String kayaOffer = sendOffer(kaya, requestId, offerBody("700", "100")).get("id").asString();
        JsonNode received = latest(customer, "OFFER_RECEIVED");
        assertParams(received, "publicCode", "title", "proBusinessName", "amount");
        assertThat(received.get("params").get("proBusinessName").asString()).isEqualTo("Kaya Tesisat");
        assertThat(received.get("params").get("amount").asString()).isEqualTo("800.00");
        assertThat(received.get("params").get("title").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(received.get("targetRoute").asString()).isEqualTo("/c/requests/" + requestId + "/offers");
        assertThat(unread(customer)).isEqualTo(2);

        // Talep düzenlenince bekleyen teklifli ustalar haberdar edilir; hedef talebin kendisidir.
        call(HttpMethod.PATCH, "/api/v1/requests/" + requestId, customer.access(),
                Map.of("title", "Banyo lavabosu su kaçırıyor")).andExpect(status().isOk());
        JsonNode updated = latest(mavi, "REQUEST_UPDATED");
        assertParams(updated, "publicCode", "title");
        assertThat(updated.get("params").get("title").asString()).isEqualTo("Banyo lavabosu su kaçırıyor");
        assertThat(updated.get("targetRoute").asString()).isEqualTo("/p/requests/" + requestId);

        // Yeni teklifler; biri reddedilir, diğeri kabul edilince üçüncü SUPERSEDED olur.
        String third = sendOffer(mavi, requestId, offerBody("950", "50")).get("id").asString();
        String fourth = sendOffer(kaya, requestId, offerBody("600", "0")).get("id").asString();
        call(HttpMethod.POST, "/api/v1/offers/" + fourth + "/decline", customer.access(),
                Map.of("reason", "SCHEDULE", "keepRequestOpen", true)).andExpect(status().isOk());
        JsonNode declined = latest(kaya, "OFFER_DECLINED");
        assertParams(declined, "publicCode", "title");
        assertThat(declined.get("targetRoute").asString()).isEqualTo("/p/offers");

        Setup s = new Setup(customer, mavi, requestId, third, null, code);
        String jobId = payAndOpenJob(s);
        JsonNode accepted = latest(mavi, "OFFER_ACCEPTED");
        assertParams(accepted, "publicCode", "title", "amount");
        assertThat(accepted.get("params").get("amount").asString()).isEqualTo("1000.00");
        assertThat(accepted.get("targetRoute").asString()).isEqualTo("/p/jobs/" + jobId);
        // Kaya'nın bekleyen teklifi yoktu (reddedildi, ilki EXPIRED); yeni talep üzerinden SUPERSEDED doğrula.
        assertThat(maviOffer).isNotEqualTo(kayaOffer);
    }

    @Test
    void supersededNotificationGoesToLosingPros() throws Exception {
        Setup s = openRequestWithOffer("900", "300");
        Account loser = pro("Kaybeden Usta", List.of("plumbing"), List.of("Kadıköy"));
        sendOffer(loser, s.requestId(), offerBody("500", "0"));
        payAndOpenJob(s);
        JsonNode n = latest(loser, "OFFER_SUPERSEDED");
        assertParams(n, "publicCode", "title");
        assertThat(n.get("params").get("publicCode").asString()).isEqualTo(s.publicCode());
        assertThat(n.get("targetRoute").asString()).isEqualTo("/p/offers");
    }

    @Test
    void jobLifecycleNotificationsCarryTheContractParamsAndTargets() throws Exception {
        Setup s = openRequestWithOffer("900", "300");
        String jobId = payAndOpenJob(s);
        // Müşteri aralık önerir → usta APPOINTMENT_PROPOSED alır (usta rotası).
        Instant from = Instant.now().plusSeconds(86_400);
        JsonNode proposed = body(jobPost(s.customer(), jobId, "/appointment/proposals",
                Map.of("slotFrom", from.toString(), "slotTo", from.plusSeconds(7200).toString())).andExpect(status().isOk()));
        JsonNode proposal = latest(s.pro(), "APPOINTMENT_PROPOSED");
        assertParams(proposal, "publicCode", "slotFrom", "slotTo");
        assertThat(proposal.get("params").get("publicCode").asString()).isEqualTo(s.publicCode());
        assertThat(Instant.parse(proposal.get("params").get("slotFrom").asString())).isEqualTo(from);
        assertThat(proposal.get("targetRoute").asString()).isEqualTo("/p/jobs/" + jobId);

        // Usta kabul eder → müşteri APPOINTMENT_CONFIRMED alır (müşteri rotası).
        String pid = proposed.get("appointment").get("pendingProposal").get("id").asString();
        jobPost(s.pro(), jobId, "/appointment/proposals/" + pid + "/accept", null).andExpect(status().isOk());
        JsonNode confirmed = latest(s.customer(), "APPOINTMENT_CONFIRMED");
        assertParams(confirmed, "publicCode", "slotFrom", "slotTo");
        assertThat(confirmed.get("targetRoute").asString()).isEqualTo("/c/jobs/" + jobId);

        // Aşamalar → JOB_STAGE_CHANGED (status), yalnız müşteriye.
        jobPost(s.pro(), jobId, "/arrived", null).andExpect(status().isOk());
        JsonNode arrived = latest(s.customer(), "JOB_STAGE_CHANGED");
        assertParams(arrived, "publicCode", "status");
        assertThat(arrived.get("params").get("status").asString()).isEqualTo("ARRIVED");
        assertThat(arrived.get("targetRoute").asString()).isEqualTo("/c/jobs/" + jobId);
        jobPost(s.pro(), jobId, "/start", null).andExpect(status().isOk());
        assertThat(latest(s.customer(), "JOB_STAGE_CHANGED").get("params").get("status").asString())
                .isEqualTo("IN_PROGRESS");
        assertThat(notifications(s.customer(), "JOB_STAGE_CHANGED")).isEqualTo(2);

        // Sohbet → NEW_MESSAGE (senderName, sohbet rotası).
        call(HttpMethod.POST, "/api/v1/jobs/" + jobId + "/messages", s.pro().access(), Map.of("body", "Geliyorum."))
                .andExpect(status().isCreated());
        JsonNode message = latest(s.customer(), "NEW_MESSAGE");
        assertParams(message, "publicCode", "senderName");
        assertThat(message.get("params").get("senderName").asString()).startsWith("Test Usta");
        assertThat(message.get("targetRoute").asString()).isEqualTo("/jobs/" + jobId + "/chat");
        call(HttpMethod.POST, "/api/v1/jobs/" + jobId + "/messages", s.customer().access(), Map.of("body", "Bekliyorum."))
                .andExpect(status().isCreated());
        JsonNode reply = latest(s.pro(), "NEW_MESSAGE");
        assertThat(reply.get("params").get("senderName").asString()).isEqualTo("Test K.");

        // Teslim → WORK_FINISHED (autoCompleteAt), hatırlatma, ödeme.
        finishWork(s, jobId);
        JsonNode finished = latest(s.customer(), "WORK_FINISHED");
        assertParams(finished, "publicCode", "autoCompleteAt");
        assertThat(finished.get("targetRoute").asString()).isEqualTo("/c/jobs/" + jobId);
        jdbc.update("update jobs set auto_complete_at = now() + interval '23 hours' where id = ?::uuid", jobId);
        assertThat(scheduler.run(Instant.now()).reminded()).isEqualTo(1);
        JsonNode reminder = latest(s.customer(), "AUTO_COMPLETE_REMINDER");
        assertParams(reminder, "publicCode", "autoCompleteAt");
        assertThat(reminder.get("targetRoute").asString()).isEqualTo("/c/jobs/" + jobId);

        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk());
        JsonNode payout = latest(s.pro(), "PAYOUT_RELEASED");
        assertParams(payout, "publicCode", "amount");
        assertThat(payout.get("params").get("amount").asString()).isEqualTo("1080.00");
        assertThat(payout.get("targetRoute").asString()).isEqualTo("/p/earnings");
    }

    @Test
    void cancellationNotificationsNameWhoCancelledAndTheRefund() throws Exception {
        // Müşteri iptal eder → usta bilgilendirilir (usta rotası).
        Setup byCustomer = openRequestWithOffer("900", "300");
        String job1 = payAndOpenJob(byCustomer);
        jobPost(byCustomer.customer(), job1, "/cancel", Map.of("reason", "PLANS_CHANGED")).andExpect(status().isOk());
        JsonNode toPro = latest(byCustomer.pro(), "JOB_CANCELLED");
        assertParams(toPro, "publicCode", "byRole", "refundAmount");
        assertThat(toPro.get("params").get("byRole").asString()).isEqualTo("CUSTOMER");
        assertThat(toPro.get("params").get("refundAmount").asString()).isEqualTo("1200.00");
        assertThat(toPro.get("targetRoute").asString()).isEqualTo("/p/jobs/" + job1);

        // Usta iptal eder → müşteri bilgilendirilir (müşteri rotası).
        Setup byPro = openRequestWithOffer("500", "0");
        String job2 = payAndOpenJob(byPro);
        jobPost(byPro.pro(), job2, "/cancel", Map.of("reason", "CANNOT_DO_JOB")).andExpect(status().isOk());
        JsonNode toCustomer = latest(byPro.customer(), "JOB_CANCELLED");
        assertThat(toCustomer.get("params").get("byRole").asString()).isEqualTo("PRO");
        assertThat(toCustomer.get("params").get("refundAmount").asString()).isEqualTo("500.00");
        assertThat(toCustomer.get("targetRoute").asString()).isEqualTo("/c/jobs/" + job2);
    }

    @Test
    void complaintNotificationsOpenedAndDecidedReachTheRightPeopleWithTheRightRoutes() throws Exception {
        Account admin = admin();
        Disputed d = disputedJob("900", "300");
        JsonNode toPro = latest(d.s().pro(), "COMPLAINT_OPENED");
        assertParams(toPro, "publicCode", "complaintCode");
        assertThat(toPro.get("params").get("complaintCode").asString()).isEqualTo(d.complaintCode());
        assertThat(toPro.get("targetRoute").asString()).isEqualTo("/p/jobs/" + d.jobId());
        JsonNode toAdmin = latest(admin, "COMPLAINT_OPENED");
        assertThat(toAdmin.get("params").get("complaintCode").asString()).isEqualTo(d.complaintCode());
        assertThat(toAdmin.get("targetRoute").asString()).isEqualTo("/complaints/" + d.complaintId());

        ok(decide(admin, d, "SPLIT_50_50"));
        JsonNode customerNote = latest(d.s().customer(), "COMPLAINT_DECIDED");
        assertParams(customerNote, "complaintCode", "decision", "amount");
        assertThat(customerNote.get("params").get("decision").asString()).isEqualTo("SPLIT_50_50");
        assertThat(customerNote.get("params").get("amount").asString()).isEqualTo("600.00");
        assertThat(customerNote.get("targetRoute").asString()).isEqualTo("/c/complaints/" + d.complaintId());
        JsonNode proNote = latest(d.s().pro(), "COMPLAINT_DECIDED");
        assertThat(proNote.get("params").get("amount").asString()).isEqualTo("600.00");
        assertThat(proNote.get("targetRoute").asString()).isEqualTo("/p/jobs/" + d.jobId());
        // Karar bildirimi admin'e gitmez.
        assertThat(notifications(admin, "COMPLAINT_DECIDED")).isZero();
        // Müşterinin rotası gerçekten açılabilir: şikayet kendi görünümünde.
        get(d.s().customer(), "/complaints/" + d.complaintId()).andExpect(status().isOk())
                .andExpect(jsonPath("$.decision").value("SPLIT_50_50"));
    }

    @Test
    void proReviewNotificationsCarryNoteAndRoute() throws Exception {
        Account admin = admin();
        Account approved = pendingPro("Onay Elektrik");
        Account rejected = pendingPro("Red Elektrik");
        Account needs = pendingPro("Belge Elektrik");
        ok(post(admin, "/admin/applications/" + approved.id() + "/approve", Map.of()));
        ok(post(admin, "/admin/applications/" + rejected.id() + "/reject", Map.of("note", "Belgeler sahte görünüyor.")));
        ok(post(admin, "/admin/applications/" + needs.id() + "/request-documents",
                Map.of("note", "Vergi levhası eksik, yükleyin.", "documentTypes", List.of("TAX"))));

        JsonNode a = latest(approved, "PRO_APPROVED");
        assertThat(a.get("params")).isEmpty();
        assertThat(a.get("targetRoute").asString()).isEqualTo("/p/feed");
        JsonNode r = latest(rejected, "PRO_REJECTED");
        assertParams(r, "note");
        assertThat(r.get("params").get("note").asString()).isEqualTo("Belgeler sahte görünüyor.");
        assertThat(r.get("targetRoute").asString()).isEqualTo("/p/application");
        JsonNode n = latest(needs, "PRO_NEEDS_DOCUMENTS");
        assertThat(n.get("params").get("note").asString()).isEqualTo("Vergi levhası eksik, yükleyin.");
        assertThat(n.get("targetRoute").asString()).isEqualTo("/p/application");
        assertThat(unread(approved)).isEqualTo(1);
        // Başkasının bildirimi başkasında görünmez.
        assertThat(notifications(approved, "PRO_REJECTED")).isZero();
    }
}
