package com.bitadilat.media;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave2TestBase;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import tools.jackson.databind.JsonNode;

class MediaTest extends Wave2TestBase {

    @Autowired
    MediaSigner signer;

    private static byte[] padded(byte[] head, int size) {
        byte[] out = new byte[size];
        System.arraycopy(head, 0, out, 0, head.length);
        return out;
    }

    private static final byte[] JPEG_HEAD = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0};
    private static final byte[] PDF_HEAD = "%PDF-1.4".getBytes(StandardCharsets.US_ASCII);
    private static final byte[] HEIC_HEAD = {0, 0, 0, 24, 'f', 't', 'y', 'p', 'h', 'e', 'i', 'c', 0, 0, 0, 0};

    private void expectBadFile(Account who, byte[] data, String purpose) throws Exception {
        uploadRaw(who, data, purpose).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED")).andExpect(jsonPath("$.field").value("file"));
    }

    @Test
    void uploadReturnsMetadataForJpegPngAndHeic() throws Exception {
        Account a = register();
        JsonNode jpg = body(uploadRaw(a, jpeg(30, 20), "REQUEST_PHOTO").andExpect(status().isCreated())
                .andExpect(jsonPath("$.contentType").value("image/jpeg")));
        assertThat(jpg.get("width").asInt()).isEqualTo(30);
        assertThat(jpg.get("height").asInt()).isEqualTo(20);
        assertThat(jpg.get("sizeBytes").asLong()).isGreaterThan(0);
        assertThat(jpg.get("id").asString()).isNotBlank();

        java.awt.image.BufferedImage img = new java.awt.image.BufferedImage(4, 5, java.awt.image.BufferedImage.TYPE_INT_RGB);
        java.io.ByteArrayOutputStream png = new java.io.ByteArrayOutputStream();
        javax.imageio.ImageIO.write(img, "png", png);
        uploadRaw(a, png.toByteArray(), "AVATAR").andExpect(status().isCreated())
                .andExpect(jsonPath("$.contentType").value("image/png")).andExpect(jsonPath("$.width").value(4));
        uploadRaw(a, HEIC_HEAD, "REQUEST_PHOTO").andExpect(status().isCreated())
                .andExpect(jsonPath("$.contentType").value("image/heic")).andExpect(jsonPath("$.width").isEmpty());
        uploadRaw(a, padded(PDF_HEAD, 200), "PRO_DOCUMENT").andExpect(status().isCreated())
                .andExpect(jsonPath("$.contentType").value("application/pdf"));
    }

    @Test
    void typeIsCheckedByMagicBytesNotByNameOrPurpose() throws Exception {
        Account a = register();
        // "x.bin" adlı gerçek JPEG kabul edilir (ad önemsiz); sahte içerik reddedilir.
        expectBadFile(a, "bu bir fotoğraf değil".getBytes(StandardCharsets.UTF_8), "REQUEST_PHOTO");
        expectBadFile(a, "<html><script>alert(1)</script></html>".getBytes(StandardCharsets.UTF_8), "REQUEST_PHOTO");
        expectBadFile(a, padded(PDF_HEAD, 100), "REQUEST_PHOTO");      // PDF yalnız belge için
        expectBadFile(a, HEIC_HEAD, "PRO_DOCUMENT");                    // HEIC belge için değil
        expectBadFile(a, new byte[] {(byte) 0xFF, (byte) 0xD8}, "CHAT"); // kesik başlık
        uploadRaw(a, new byte[0], "REQUEST_PHOTO").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("file"));
    }

    @Test
    void sizeLimitsAre1_5MbForPhotosAnd5MbForDocuments() throws Exception {
        Account a = register();
        uploadRaw(a, padded(JPEG_HEAD, 1_572_864), "REQUEST_PHOTO").andExpect(status().isCreated());
        expectBadFile(a, padded(JPEG_HEAD, 1_572_865), "REQUEST_PHOTO");
        expectBadFile(a, padded(JPEG_HEAD, 1_572_865), "AVATAR");
        // Belgede 5 MB'a kadar
        uploadRaw(a, padded(JPEG_HEAD, 2_000_000), "PRO_DOCUMENT").andExpect(status().isCreated());
        uploadRaw(a, padded(PDF_HEAD, 5_242_880), "PRO_DOCUMENT").andExpect(status().isCreated());
        expectBadFile(a, padded(PDF_HEAD, 5_242_881), "PRO_DOCUMENT");
    }

    @Test
    void purposeAndFileAreRequiredAndAuthIsNeeded() throws Exception {
        Account a = register();
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/media")
                        .file(new MockMultipartFile("file", "a.jpg", "image/jpeg", jpeg(5, 5)))
                        .header("Authorization", "Bearer " + a.access()))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("purpose"));
        uploadRaw(a, jpeg(5, 5), "NOPE").andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("purpose"));
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/media").param("purpose", "AVATAR")
                        .header("Authorization", "Bearer " + a.access()))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("file"));
        mvc.perform(MockMvcRequestBuilders.multipart("/api/v1/media")
                        .file(new MockMultipartFile("file", "a.jpg", "image/jpeg", jpeg(5, 5)))
                        .param("purpose", "AVATAR"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void signedUrlServesBytesWithoutAuthAndRejectsBadOrExpiredSignatures() throws Exception {
        Account ali = register();
        byte[] original = jpeg(16, 16);
        String photo = upload(ali, original, "REQUEST_PHOTO").get("id").asString();
        Map<String, Object> body = requestBody(addressId(ali, "Kadıköy"));
        body.put("photoIds", List.of(photo));
        JsonNode req = body(call(HttpMethod.POST, "/api/v1/requests", ali.access(), body).andExpect(status().isCreated()));
        JsonNode ref = req.get("photos").get(0);
        assertThat(ref.get("id").asString()).isEqualTo(photo);
        assertThat(Instant.parse(ref.get("expiresAt").asString())).isAfter(Instant.now().plusSeconds(9 * 60))
                .isBefore(Instant.now().plusSeconds(10 * 60 + 5));

        URI uri = URI.create(ref.get("url").asString());
        String path = uri.getRawPath();
        String query = uri.getRawQuery();
        // Authorization başlığı olmadan açılır.
        byte[] served = mvc.perform(get(path + "?" + query))
                .andExpect(status().isOk())
                .andExpect(org.springframework.test.web.servlet.result.MockMvcResultMatchers.content().contentType("image/jpeg"))
                .andReturn().getResponse().getContentAsByteArray();
        assertThat(served).isEqualTo(original);
        // Bozuk/eski Authorization başlığı yine de engellemez.
        mvc.perform(get(path + "?" + query).header("Authorization", "Bearer eskimis.token.degeri"))
                .andExpect(status().isOk());

        // İmzasız, bozuk imzalı, değiştirilmiş exp, başka kimlik, süresi geçmiş → 403 FORBIDDEN
        mvc.perform(get(path)).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
        mvc.perform(get(path + "?exp=" + exp(query))).andExpect(status().isForbidden());
        mvc.perform(get(path + "?exp=" + exp(query) + "&sig=AAAA")).andExpect(status().isForbidden());
        mvc.perform(get(path + "?exp=" + (Long.parseLong(exp(query)) + 600) + "&sig=" + sig(query)))
                .andExpect(status().isForbidden());
        mvc.perform(get(path + "?exp=abc&sig=" + sig(query))).andExpect(status().isForbidden());
        String otherPath = "/api/v1/media/" + UUID.randomUUID() + "/content";
        mvc.perform(get(otherPath + "?" + query)).andExpect(status().isForbidden());
        long past = Instant.now().getEpochSecond() - 5;
        mvc.perform(get(path + "?exp=" + past + "&sig=" + signer.sign(UUID.fromString(photo), past)))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    private static String exp(String query) {
        return Arrays.stream(query.split("&")).filter(s -> s.startsWith("exp=")).findFirst().orElseThrow().substring(4);
    }

    private static String sig(String query) {
        return Arrays.stream(query.split("&")).filter(s -> s.startsWith("sig=")).findFirst().orElseThrow().substring(4);
    }

    @Test
    void signaturesAreOnlyIssuedAfterAccessChecks() throws Exception {
        Account ali = register();
        Account stranger = register();
        Account usta = pro("Mavi", List.of("plumbing"), List.of("Kadıköy"));
        String photo = upload(ali, jpeg(8, 8), "REQUEST_PHOTO").get("id").asString();
        Map<String, Object> body = requestBody(addressId(ali, "Kadıköy"));
        body.put("photoIds", List.of(photo));
        String req = this.body(call(HttpMethod.POST, "/api/v1/requests", ali.access(), body)).get("id").asString();

        // Sahibi olmayan müşteri talebi, dolayısıyla fotoğraf adresini, hiç göremez.
        String denied = call(HttpMethod.GET, "/api/v1/requests/" + req, stranger.access(), null)
                .andExpect(status().isNotFound()).andReturn().getResponse().getContentAsString();
        assertThat(denied).doesNotContain("sig=");
        // Eşleşen usta görür.
        call(HttpMethod.GET, "/api/v1/pro/requests/" + req, usta.access(), null)
                .andExpect(status().isOk()).andExpect(jsonPath("$.photos[0].url").value(org.hamcrest.Matchers.containsString("sig=")));
    }
}
