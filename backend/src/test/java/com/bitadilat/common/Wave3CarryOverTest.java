package com.bitadilat.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import com.bitadilat.media.MediaSigner;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Arrays;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.databind.JsonNode;

/** Önceki denetimlerden devreden backend maddeleri. */
class Wave3CarryOverTest extends Wave3TestBase {

    @Autowired
    private MediaSigner signer;

    private void insertMedia(String ownerId, int count, String createdAt) {
        for (int i = 0; i < count; i++) {
            jdbc.update("insert into media (owner_id, purpose, storage_key, content_type, size_bytes, created_at) "
                    + "values (?::uuid, 'REQUEST_PHOTO', ?, 'image/jpeg', 100, " + createdAt + ")", ownerId,
                    "quota-" + UUID.randomUUID() + ".jpg");
        }
    }

    @Test
    void uploadQuotaIs60Per24HoursThen429() throws Exception {
        Account a = register();
        Account b = register();
        insertMedia(a.id(), 59, "now()");
        uploadRaw(a, jpeg(10, 10), "REQUEST_PHOTO").andExpect(status().isCreated()); // 60.
        uploadRaw(a, jpeg(10, 10), "REQUEST_PHOTO").andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.code").value("TOO_MANY_ATTEMPTS"));
        assertThat(count("select count(*) from media where owner_id = ?::uuid", a.id())).isEqualTo(60);
        // Kota kullanıcı başınadır.
        uploadRaw(b, jpeg(10, 10), "REQUEST_PHOTO").andExpect(status().isCreated());
    }

    @Test
    void uploadsOlderThan24HoursDoNotCountAgainstQuota() throws Exception {
        Account a = register();
        insertMedia(a.id(), 60, "now() - interval '25 hours'");
        uploadRaw(a, jpeg(10, 10), "REQUEST_PHOTO").andExpect(status().isCreated());
    }

    @Test
    void pdfIsServedAsAttachmentWhilePhotosStayInline() throws Exception {
        Account a = register();
        byte[] pdf = Arrays.copyOf("%PDF-1.4".getBytes(StandardCharsets.US_ASCII), 300);
        String pdfId = upload(a, pdf, "PRO_DOCUMENT").get("id").asString();
        String photoId = upload(a, jpeg(10, 10), "REQUEST_PHOTO").get("id").asString();

        long exp = Instant.now().plusSeconds(300).getEpochSecond();
        mvc.perform(get("/api/v1/media/" + pdfId + "/content").param("exp", String.valueOf(exp))
                        .param("sig", signer.sign(UUID.fromString(pdfId), exp)))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "application/pdf"))
                .andExpect(header().string("Content-Disposition", org.hamcrest.Matchers.startsWith("attachment")))
                .andExpect(header().string("X-Content-Type-Options", "nosniff"));
        mvc.perform(get("/api/v1/media/" + photoId + "/content").param("exp", String.valueOf(exp))
                        .param("sig", signer.sign(UUID.fromString(photoId), exp)))
                .andExpect(status().isOk())
                .andExpect(header().doesNotExist("Content-Disposition"));
    }

    @Test
    void optimisticLockConflictIs409IllegalStateGlobally() throws Exception {
        Account a = register();
        call(HttpMethod.GET, "/api/v1/test/optimistic-conflict", a.access(), null)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
    }

    @Test
    void editingARequestNotifiesProsWithAPendingOffer() throws Exception {
        Setup s = openRequestWithOffer();
        Account other = pro("Teklifsiz Usta", java.util.List.of("plumbing"), java.util.List.of("Kadıköy"));
        assertThat(notifications(s.pro(), "REQUEST_UPDATED")).isZero();

        JsonNode updated = body(call(HttpMethod.PATCH, "/api/v1/requests/" + s.requestId(), s.customer().access(),
                Map.of("title", "Banyo lavabosu su kaçırıyor")).andExpect(status().isOk()));
        assertThat(updated.get("title").asString()).isEqualTo("Banyo lavabosu su kaçırıyor");

        assertThat(notifications(s.pro(), "REQUEST_UPDATED")).isEqualTo(1);
        assertThat(notifications(other, "REQUEST_UPDATED")).isZero();
        assertThat(jdbc.queryForObject("select params ->> 'requestId' from notifications where type = 'REQUEST_UPDATED'",
                String.class)).isEqualTo(s.requestId());
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, s.offerId()))
                .isEqualTo("EXPIRED");
        // Teklifi kalmamış ustaya ikinci düzenleme bildirim göndermez.
        call(HttpMethod.PATCH, "/api/v1/requests/" + s.requestId(), s.customer().access(),
                Map.of("title", "Banyo lavabosu su kaçırıyor!")).andExpect(status().isOk());
        assertThat(notifications(s.pro(), "REQUEST_UPDATED")).isEqualTo(1);
    }

    @Test
    void proRequestDetailCarriesStatus() throws Exception {
        Setup s = openRequestWithOffer();
        call(HttpMethod.GET, "/api/v1/pro/requests/" + s.requestId(), s.pro().access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.status").value("OPEN"));
    }
}
