package com.bitadilat.media;

import com.bitadilat.common.ApiException;
import com.bitadilat.media.dto.MediaRef;
import com.bitadilat.media.dto.MediaUploaded;
import java.awt.Dimension;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.Instant;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

/**
 * Yükleme, imzalı adres üretimi ve imzayla içerik sunumu. Dosya baytları {@link MediaStorage}'dadır; burada yalnızca
 * meta veri ve kurallar. İmza üreten herkes erişim kontrolünü önceden yapmış olmalıdır.
 */
@Service
public class MediaService {

    public static final long PHOTO_MAX_BYTES = 1_572_864L;
    public static final long DOCUMENT_MAX_BYTES = 5_242_880L;
    private static final UUID NIL = new UUID(0, 0);

    public record Content(byte[] bytes, String contentType) {
    }

    private final MediaRepository media;
    private final MediaStorage storage;
    private final MediaSigner signer;
    private final JdbcTemplate jdbc;
    private final String urlBase;

    public MediaService(MediaRepository media, MediaStorage storage, MediaSigner signer, JdbcTemplate jdbc,
                        @Value("${bitadilat.media.url-base:}") String urlBase) {
        this.media = media;
        this.storage = storage;
        this.signer = signer;
        this.jdbc = jdbc;
        this.urlBase = urlBase == null ? "" : urlBase.trim().replaceAll("/+$", "");
    }

    // ─── Yükleme ────────────────────────────────────────────────────────────

    @Transactional
    public MediaUploaded upload(UUID ownerId, MultipartFile file, String purposeRaw) {
        MediaPurpose purpose = parsePurpose(purposeRaw);
        if (file == null || file.isEmpty()) {
            throw ApiException.validation("file", "Dosya gerekli.");
        }
        long limit = purpose == MediaPurpose.PRO_DOCUMENT ? DOCUMENT_MAX_BYTES : PHOTO_MAX_BYTES;
        if (file.getSize() > limit) {
            throw ApiException.validation("file", "Dosya çok büyük (en fazla " + limit + " bayt).");
        }
        byte[] bytes;
        try {
            bytes = file.getBytes();
        } catch (IOException e) {
            throw ApiException.validation("file", "Dosya okunamadı.");
        }
        if (bytes.length > limit) {
            throw ApiException.validation("file", "Dosya çok büyük (en fazla " + limit + " bayt).");
        }
        String type = FileTypes.detect(bytes);
        boolean allowed = type != null && (purpose == MediaPurpose.PRO_DOCUMENT
                ? !FileTypes.HEIC.equals(type)
                : !FileTypes.PDF.equals(type));
        if (!allowed) {
            throw ApiException.validation("file", purpose == MediaPurpose.PRO_DOCUMENT
                    ? "Yalnızca PDF, JPEG veya PNG kabul edilir."
                    : "Yalnızca JPEG, PNG veya HEIC fotoğraf kabul edilir.");
        }
        Dimension size = dimensions(bytes, type);
        Media m = new Media();
        m.setOwnerId(ownerId);
        m.setPurpose(purpose);
        m.setStorageKey(UUID.randomUUID() + FileTypes.extension(type));
        m.setContentType(type);
        m.setSizeBytes(bytes.length);
        m.setWidth(size == null ? null : size.width);
        m.setHeight(size == null ? null : size.height);
        m.setSha256(sha256(bytes));
        storage.store(m.getStorageKey(), bytes);
        try {
            m = media.saveAndFlush(m);
        } catch (RuntimeException e) {
            storage.delete(m.getStorageKey());
            throw e;
        }
        return new MediaUploaded(m.getId(), m.getContentType(), m.getSizeBytes(), m.getWidth(), m.getHeight());
    }

    private static MediaPurpose parsePurpose(String raw) {
        if (raw == null || raw.isBlank()) {
            throw ApiException.validation("purpose", "purpose gerekli.");
        }
        try {
            return MediaPurpose.valueOf(raw.trim());
        } catch (IllegalArgumentException e) {
            throw ApiException.validation("purpose", "Geçersiz purpose.");
        }
    }

    /** JPEG/PNG için başlıktan boyut; çözülemezse veya HEIC/PDF ise null. */
    private static Dimension dimensions(byte[] bytes, String type) {
        if (!FileTypes.JPEG.equals(type) && !FileTypes.PNG.equals(type)) {
            return null;
        }
        try (ImageInputStream in = ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(in);
            if (!readers.hasNext()) {
                return null;
            }
            ImageReader reader = readers.next();
            try {
                reader.setInput(in, true, true);
                return new Dimension(reader.getWidth(0), reader.getHeight(0));
            } finally {
                reader.dispose();
            }
        } catch (IOException | RuntimeException e) {
            return null;
        }
    }

    private static String sha256(byte[] bytes) {
        try {
            return java.util.HexFormat.of().formatHex(java.security.MessageDigest.getInstance("SHA-256").digest(bytes));
        } catch (java.security.NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }

    // ─── Bir kayda iliştirme kuralı ─────────────────────────────────────────

    /** Talep veya başvuruyu düzenlerken kendi eski iliştirmeleri "boşta" sayılır. */
    public record Reuse(UUID requestId, UUID proId) {
        public static final Reuse NONE = new Reuse(null, null);
    }

    /**
     * Kimlikler çağıranın, doğru amaçlı ve henüz bir kayda iliştirilmemiş medyası olmalı. Başkasının veya olmayan
     * medya 404 (varlık sızmaz); kendi ama uygunsuz medya 400 (alan adıyla).
     */
    @Transactional(readOnly = true)
    public void requireAttachable(UUID ownerId, List<UUID> ids, MediaPurpose purpose, String field, Reuse reuse) {
        for (UUID id : ids) {
            Media m = media.findById(id).filter(x -> x.getOwnerId().equals(ownerId))
                    .orElseThrow(() -> ApiException.notFound("Medya bulunamadı."));
            if (m.getPurpose() != purpose) {
                throw ApiException.validation(field, "Medya bu alan için uygun değil.");
            }
            if (isAttached(id, reuse)) {
                throw ApiException.validation(field, "Medya zaten kullanılmış.");
            }
        }
    }

    private boolean isAttached(UUID mediaId, Reuse reuse) {
        UUID exceptRequest = reuse.requestId() == null ? NIL : reuse.requestId();
        UUID exceptPro = reuse.proId() == null ? NIL : reuse.proId();
        Long n = jdbc.queryForObject("""
                select count(*) from (
                  select 1 from request_photos where media_id = ? and request_id <> ?
                  union all select 1 from pro_documents where media_id = ? and pro_id <> ?
                  union all select 1 from job_events where media_id = ?
                  union all select 1 from messages where media_id = ?
                  union all select 1 from complaint_evidence where media_id = ?
                ) x""", Long.class, mediaId, exceptRequest, mediaId, exceptPro, mediaId, mediaId, mediaId);
        return n != null && n > 0;
    }

    // ─── İmzalı adres ───────────────────────────────────────────────────────

    /** Erişim kontrolü çağıran tarafta yapılmış olmalı. Kayıt yoksa 404. */
    @Transactional(readOnly = true)
    public MediaRef ref(UUID mediaId) {
        if (!media.existsById(mediaId)) {
            throw ApiException.notFound("Medya bulunamadı.");
        }
        return sign(mediaId);
    }

    @Transactional(readOnly = true)
    public List<MediaRef> refs(List<UUID> ids) {
        return ids.stream().map(this::ref).toList();
    }

    /** Sıra korunur, aynı kimlik tek kez imzalanır. */
    @Transactional(readOnly = true)
    public Map<UUID, MediaRef> refMap(List<UUID> ids) {
        Map<UUID, MediaRef> out = new LinkedHashMap<>();
        ids.forEach(id -> out.computeIfAbsent(id, this::ref));
        return out;
    }

    private MediaRef sign(UUID mediaId) {
        Instant expires = Instant.now().plus(MediaSigner.TTL);
        long exp = expires.getEpochSecond();
        String path = "/api/v1/media/" + mediaId + "/content?exp=" + exp + "&sig=" + signer.sign(mediaId, exp);
        return new MediaRef(mediaId, base() + path, expires);
    }

    private String base() {
        if (!urlBase.isEmpty()) {
            return urlBase;
        }
        return ServletUriComponentsBuilder.fromCurrentContextPath().build().toUriString().replaceAll("/+$", "");
    }

    // ─── İçerik ─────────────────────────────────────────────────────────────

    /** Geçerli ve süresi dolmamış imza gerekir; aksi halde 403 FORBIDDEN. */
    @Transactional(readOnly = true)
    public Content content(UUID mediaId, Long exp, String sig) {
        if (exp == null || sig == null || exp < Instant.now().getEpochSecond() || !signer.verify(mediaId, exp, sig)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Adres geçersiz veya süresi dolmuş.");
        }
        Media m = media.findById(mediaId).orElseThrow(() -> ApiException.notFound("Medya bulunamadı."));
        byte[] bytes = storage.load(m.getStorageKey()).orElseThrow(() -> ApiException.notFound("Medya bulunamadı."));
        return new Content(bytes, m.getContentType());
    }
}
