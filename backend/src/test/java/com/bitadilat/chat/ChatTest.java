package com.bitadilat.chat;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** İş sohbeti: imleç, katılımcı kuralı, salt okunur süre, okundu bilgisi, mesaj kutusu ve bildirim kısıtı. */
class ChatTest extends Wave3TestBase {

    private JsonNode send(Account who, String jobId, String text) throws Exception {
        return body(jobPost(who, jobId, "/messages", Map.of("body", text)).andExpect(status().isCreated()));
    }

    private JsonNode messages(Account who, String jobId, String query) throws Exception {
        return body(call(HttpMethod.GET, "/api/v1/jobs/" + jobId + "/messages" + query, who.access(), null)
                .andExpect(status().isOk()));
    }

    @Test
    void messagesAreCursoredAscendingAndMarkedMine() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        JsonNode m1 = send(s.customer(), jobId, "Merhaba usta bey");
        JsonNode m2 = send(s.pro(), jobId, "Merhaba, yarın geliyorum");
        JsonNode m3 = send(s.customer(), jobId, "  Tamam, teşekkürler  ");
        assertThat(m1.get("senderRole").asString()).isEqualTo("CUSTOMER");
        assertThat(m1.get("mine").asBoolean()).isTrue();
        assertThat(m1.get("photo").isNull()).isTrue();
        assertThat(m3.get("body").asString()).isEqualTo("Tamam, teşekkürler"); // kırpılır
        assertThat(m2.get("id").asLong()).isGreaterThan(m1.get("id").asLong());

        JsonNode page1 = messages(s.customer(), jobId, "?limit=2");
        assertThat(page1.get("items").size()).isEqualTo(2);
        assertThat(page1.get("items").get(0).get("id").asLong()).isEqualTo(m1.get("id").asLong());
        assertThat(page1.get("items").get(1).get("mine").asBoolean()).isFalse();
        assertThat(page1.get("items").get(1).get("senderRole").asString()).isEqualTo("PRO");
        assertThat(page1.get("otherLastReadId").asLong()).isZero();

        JsonNode page2 = messages(s.customer(), jobId, "?after=" + page1.get("items").get(1).get("id").asLong());
        assertThat(page2.get("items").size()).isEqualTo(1);
        assertThat(page2.get("items").get(0).get("id").asLong()).isEqualTo(m3.get("id").asLong());
        assertThat(messages(s.customer(), jobId, "?after=" + m3.get("id").asLong()).get("items").size()).isZero();

        // Usta aynı mesajları kendi gözünden görür.
        JsonNode proView = messages(s.pro(), jobId, "");
        assertThat(proView.get("items").size()).isEqualTo(3);
        assertThat(proView.get("items").get(1).get("mine").asBoolean()).isTrue();

        call(HttpMethod.GET, "/api/v1/jobs/" + jobId + "/messages?limit=0", s.pro().access(), null)
                .andExpect(status().isBadRequest());
    }

    @Test
    void nonParticipantGets404EverywhereAndBodyIsValidated() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        Account stranger = register();
        call(HttpMethod.GET, "/api/v1/jobs/" + jobId + "/messages", stranger.access(), null)
                .andExpect(status().isNotFound());
        jobPost(stranger, jobId, "/messages", Map.of("body", "selam")).andExpect(status().isNotFound());
        jobPost(stranger, jobId, "/messages/read", Map.of("lastReadId", 1)).andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/jobs/" + jobId + "/messages", null, null).andExpect(status().isUnauthorized());

        jobPost(s.customer(), jobId, "/messages", Map.of("body", "   ")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("body"));
        jobPost(s.customer(), jobId, "/messages", Map.of("body", "x".repeat(2001))).andExpect(status().isBadRequest());
        jobPost(s.customer(), jobId, "/messages", Map.of()).andExpect(status().isBadRequest());
        assertThat(count("select count(*) from messages")).isZero();
    }

    @Test
    void photoMessageNeedsOwnChatMedia() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        var chatPhoto = upload(s.customer(), jpeg(20, 20), "CHAT");
        JsonNode sent = body(jobPost(s.customer(), jobId, "/messages",
                Map.of("body", "Fotoğraf ekledim", "photoId", chatPhoto.get("id").asString()))
                .andExpect(status().isCreated()));
        assertThat(sent.get("photo").get("url").asString()).contains("/api/v1/media/").contains("sig=");
        // Aynı medya ikinci kez, yanlış amaçlı veya başkasının medyası olmaz.
        jobPost(s.customer(), jobId, "/messages", Map.of("body", "Tekrar", "photoId", chatPhoto.get("id").asString()))
                .andExpect(status().isBadRequest());
        var wrong = upload(s.customer(), jpeg(20, 20), "JOB_PHOTO");
        jobPost(s.customer(), jobId, "/messages", Map.of("body", "x", "photoId", wrong.get("id").asString()))
                .andExpect(status().isBadRequest());
        var foreign = upload(s.pro(), jpeg(20, 20), "CHAT");
        jobPost(s.customer(), jobId, "/messages", Map.of("body", "x", "photoId", foreign.get("id").asString()))
                .andExpect(status().isNotFound());
    }

    @Test
    void chatBecomesReadOnly30DaysAfterJobCloses() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk());
        send(s.pro(), jobId, "İyi günler dilerim"); // kapanışın hemen ardından hâlâ açık

        jdbc.update("update jobs set completed_at = now() - interval '29 days' where id = ?::uuid", jobId);
        send(s.customer(), jobId, "Teşekkürler");
        assertThat(job(s.customer(), jobId).get("allowedActions").toString()).contains("CHAT");

        jdbc.update("update jobs set completed_at = now() - interval '31 days' where id = ?::uuid", jobId);
        jobPost(s.customer(), jobId, "/messages", Map.of("body", "Geç kaldım")).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        jobPost(s.pro(), jobId, "/messages", Map.of("body", "Geç kaldım")).andExpect(status().isConflict());
        assertThat(job(s.customer(), jobId).get("allowedActions").toString()).doesNotContain("CHAT");
        // Okuma ve okundu bilgisi sürer.
        assertThat(messages(s.customer(), jobId, "").get("items").size()).isEqualTo(2);
        jobPost(s.customer(), jobId, "/messages/read", Map.of("lastReadId", 1)).andExpect(status().isNoContent());
        assertThat(count("select count(*) from messages")).isEqualTo(2);
    }

    @Test
    void cancelledJobChatClosesAfter30DaysToo() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());
        send(s.customer(), jobId, "Özür dilerim");
        jdbc.update("update jobs set cancelled_at = now() - interval '40 days' where id = ?::uuid", jobId);
        jobPost(s.customer(), jobId, "/messages", Map.of("body", "x")).andExpect(status().isConflict());
    }

    @Test
    void readReceiptsAreMonotonicClampedAndVisibleToTheOtherSide() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        long m1 = send(s.customer(), jobId, "bir").get("id").asLong();
        long m2 = send(s.customer(), jobId, "iki").get("id").asLong();

        jobPost(s.pro(), jobId, "/messages/read", Map.of("lastReadId", m1)).andExpect(status().isNoContent());
        assertThat(messages(s.customer(), jobId, "").get("otherLastReadId").asLong()).isEqualTo(m1);
        // Geriye gitmez.
        jobPost(s.pro(), jobId, "/messages/read", Map.of("lastReadId", 0)).andExpect(status().isNoContent());
        assertThat(messages(s.customer(), jobId, "").get("otherLastReadId").asLong()).isEqualTo(m1);
        // İşteki son mesajın ötesine geçmez.
        jobPost(s.pro(), jobId, "/messages/read", Map.of("lastReadId", 999_999_999L)).andExpect(status().isNoContent());
        assertThat(messages(s.customer(), jobId, "").get("otherLastReadId").asLong()).isEqualTo(m2);
        // Kendi okundu bilgisini görmez: usta tarafında diğer taraf (müşteri) henüz okumadı.
        assertThat(messages(s.pro(), jobId, "").get("otherLastReadId").asLong()).isZero();
        jobPost(s.pro(), jobId, "/messages/read", Map.of("lastReadId", -1)).andExpect(status().isBadRequest());
    }

    @Test
    void conversationsAreSortedByLastActivityWithUnreadCounts() throws Exception {
        Setup first = openRequestWithOffer();
        String job1 = payAndOpenJob(first);
        // Aynı müşteri, ikinci talep ve iş (başka usta).
        Account pro2 = pro("İkinci Usta", List.of("plumbing"), List.of("Kadıköy"));
        JsonNode request2 = createRequest(first.customer(), first.addressId());
        String offer2 = sendOffer(pro2, request2.get("id").asString(), offerBody("300", "100")).get("id").asString();
        Setup second = new Setup(first.customer(), pro2, request2.get("id").asString(), offer2, first.addressId(),
                request2.get("publicCode").asString());
        String job2 = payAndOpenJob(second);

        // job1'de eski mesaj, job2'de daha yeni.
        send(first.pro(), job1, "İlk iş mesajı");
        send(pro2, job2, "Merhaba");
        send(pro2, job2, "Adres tarifi alabilir miyim?");

        JsonNode inbox = body(call(HttpMethod.GET, "/api/v1/conversations?as=CUSTOMER", first.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(inbox.get("items").size()).isEqualTo(2);
        JsonNode top = inbox.get("items").get(0);
        assertThat(top.get("jobId").asString()).isEqualTo(job2);
        assertThat(top.get("unreadCount").asInt()).isEqualTo(2);
        assertThat(top.get("lastMessage").get("body").asString()).isEqualTo("Adres tarifi alabilir miyim?");
        assertThat(top.get("lastMessage").get("mine").asBoolean()).isFalse();
        assertThat(top.get("counterpart").get("displayName").asString()).isEqualTo("İkinci Usta");
        assertThat(top.get("jobStatus").asString()).isEqualTo("AWAITING_APPOINTMENT");
        assertThat(top.get("publicCode").asString()).isEqualTo(second.publicCode());
        assertThat(top.get("title").asString()).isEqualTo("Banyo lavabo altı su kaçağı");
        assertThat(inbox.get("items").get(1).get("jobId").asString()).isEqualTo(job1);
        assertThat(inbox.get("items").get(1).get("unreadCount").asInt()).isEqualTo(1);

        // Okundu işaretlenince unread düşer.
        long last = top.get("lastMessage").get("id").asLong();
        jobPost(first.customer(), job2, "/messages/read", Map.of("lastReadId", last)).andExpect(status().isNoContent());
        JsonNode after = body(call(HttpMethod.GET, "/api/v1/conversations?as=CUSTOMER", first.customer().access(), null));
        assertThat(after.get("items").get(0).get("unreadCount").asInt()).isZero();
        // Yeni mesaj sırayı değiştirir: job1 öne geçer.
        send(first.pro(), job1, "Yeni mesaj");
        JsonNode reordered = body(call(HttpMethod.GET, "/api/v1/conversations?as=CUSTOMER", first.customer().access(), null));
        assertThat(reordered.get("items").get(0).get("jobId").asString()).isEqualTo(job1);
        assertThat(reordered.get("items").get(0).get("unreadCount").asInt()).isEqualTo(2);

        // Usta kutusu yalnızca kendi işlerini listeler.
        JsonNode proInbox = body(call(HttpMethod.GET, "/api/v1/conversations?as=PRO", pro2.access(), null));
        assertThat(proInbox.get("items").size()).isEqualTo(1);
        assertThat(proInbox.get("items").get(0).get("unreadCount").asInt()).isEqualTo(0);
        assertThat(proInbox.get("items").get(0).get("counterpart").get("displayName").asString()).isEqualTo("Test K.");
        call(HttpMethod.GET, "/api/v1/conversations?as=ADMIN", first.customer().access(), null)
                .andExpect(status().isBadRequest());
        call(HttpMethod.GET, "/api/v1/conversations", first.customer().access(), null).andExpect(status().isBadRequest());
    }

    @Test
    void newMessageNotificationIsSentOnlyWhenNoUnreadOneExistsForTheJob() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        send(s.customer(), jobId, "bir");
        send(s.customer(), jobId, "iki");
        send(s.customer(), jobId, "üç");
        assertThat(notifications(s.pro(), "NEW_MESSAGE")).isEqualTo(1);
        assertThat(notifications(s.customer(), "NEW_MESSAGE")).isZero();
        assertThat(jdbc.queryForObject("select params ->> 'jobId' from notifications where type = 'NEW_MESSAGE'",
                String.class)).isEqualTo(jobId);
        // Karşı tarafın mesajı müşteriye kendi bildirimini üretir.
        send(s.pro(), jobId, "cevap");
        assertThat(notifications(s.customer(), "NEW_MESSAGE")).isEqualTo(1);

        // Usta okuyunca (bildirim okundu olur) sonraki mesaj yeniden bildirim üretir.
        jobPost(s.pro(), jobId, "/messages/read", Map.of("lastReadId", 3)).andExpect(status().isNoContent());
        send(s.customer(), jobId, "dört");
        assertThat(notifications(s.pro(), "NEW_MESSAGE")).isEqualTo(2);
        send(s.customer(), jobId, "beş");
        assertThat(notifications(s.pro(), "NEW_MESSAGE")).isEqualTo(2);
    }
}
