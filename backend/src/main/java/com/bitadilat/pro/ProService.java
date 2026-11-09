package com.bitadilat.pro;

import com.bitadilat.catalog.Category;
import com.bitadilat.catalog.CategoryRepository;
import com.bitadilat.catalog.District;
import com.bitadilat.catalog.DistrictRepository;
import com.bitadilat.common.ApiException;
import com.bitadilat.media.MediaPurpose;
import com.bitadilat.media.MediaService;
import com.bitadilat.pro.dto.ApplicationBody;
import com.bitadilat.pro.dto.ApplicationView;
import com.bitadilat.pro.dto.DocumentIn;
import com.bitadilat.pro.dto.ProfileBody;
import com.bitadilat.pro.dto.ProfileView;
import com.bitadilat.pro.dto.WorkingHourDto;
import java.time.Instant;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Usta başvurusu, profil ve müsaitlik. */
@Service
public class ProService {

    private static final Pattern HHMM = Pattern.compile("^([01]\\d|2[0-3]):[0-5]\\d$");
    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("HH:mm");

    private final ProProfileRepository profiles;
    private final ProCategoryRepository proCategories;
    private final ProDistrictRepository proDistricts;
    private final ProWorkingHoursRepository hours;
    private final ProDocumentRepository documents;
    private final CategoryRepository categories;
    private final DistrictRepository districts;
    private final MediaService media;
    private final ProAccess access;

    public ProService(ProProfileRepository profiles, ProCategoryRepository proCategories,
                      ProDistrictRepository proDistricts, ProWorkingHoursRepository hours,
                      ProDocumentRepository documents, CategoryRepository categories, DistrictRepository districts,
                      MediaService media, ProAccess access) {
        this.profiles = profiles;
        this.proCategories = proCategories;
        this.proDistricts = proDistricts;
        this.hours = hours;
        this.documents = documents;
        this.categories = categories;
        this.districts = districts;
        this.media = media;
        this.access = access;
    }

    // ─── Başvuru ────────────────────────────────────────────────────────────

    @Transactional
    public ApplicationView submit(UUID userId, ApplicationBody b) {
        ProProfile profile = profiles.findById(userId).orElse(null);
        if (profile != null && !EnumSet.of(ReviewStatus.NEEDS_DOCUMENTS, ReviewStatus.REJECTED)
                .contains(profile.getReviewStatus())) {
            throw ApiException.illegalState("Başvuru bu durumda gönderilemez: " + profile.getReviewStatus());
        }
        List<String> categoryIds = checkCategories(b.categoryIds());
        List<Integer> districtIds = checkDistricts(b.districtIds());
        String businessName = businessName(b.businessName());
        Set<DocumentType> types = EnumSet.noneOf(DocumentType.class);
        Set<UUID> mediaIds = new java.util.HashSet<>();
        for (DocumentIn d : b.documents()) {
            if (!types.add(d.type())) {
                throw ApiException.validation("documents", "Aynı belge türü birden çok kez gönderilmiş.");
            }
            if (!mediaIds.add(d.mediaId())) {
                throw ApiException.validation("documents", "Aynı dosya birden çok belge için kullanılamaz.");
            }
        }
        if (!types.contains(DocumentType.IDENTITY) || !types.contains(DocumentType.TRADE_CERT)) {
            throw ApiException.validation("documents", "Kimlik ve mesleki belge (IDENTITY, TRADE_CERT) zorunlu.");
        }
        media.requireAttachable(userId, b.documents().stream().map(DocumentIn::mediaId).distinct().toList(),
                MediaPurpose.PRO_DOCUMENT, "documents", new MediaService.Reuse(null, userId));

        if (profile == null) {
            profile = new ProProfile();
            profile.setUserId(userId);
        }
        profile.setBusinessName(businessName);
        profile.setBio(b.bio() == null || b.bio().isBlank() ? null : b.bio().trim());
        profile.setExperienceYears(b.experienceYears());
        profile.setReviewStatus(ReviewStatus.PENDING_REVIEW);
        profile.setReviewNote(null);
        profiles.saveAndFlush(profile);

        replaceCategoriesAndDistricts(userId, categoryIds, districtIds);
        documents.deleteByProId(userId);
        documents.flush();
        try {
            for (DocumentIn d : b.documents()) {
                ProDocument doc = new ProDocument();
                doc.setProId(userId);
                doc.setType(d.type());
                doc.setMediaId(d.mediaId());
                documents.save(doc);
            }
            documents.flush();
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            // ux_pro_documents_media: eşzamanlı başka bir başvuru aynı dosyayı az önce bağladı.
            throw ApiException.validation("documents", "Medya zaten kullanılmış.");
        }
        return application(userId);
    }

    @Transactional(readOnly = true)
    public ApplicationView application(UUID userId) {
        ProProfile p = profiles.findById(userId).orElseThrow(() -> ApiException.notFound("Başvuru bulunamadı."));
        List<ProDocument> docs = documents.findByProIdOrderByCreatedAtAsc(userId);
        Instant submitted = docs.stream().map(ProDocument::getCreatedAt).max(Comparator.naturalOrder())
                .orElse(p.getCreatedAt());
        return new ApplicationView(p.getReviewStatus(), p.getReviewNote(), p.getBusinessName(), p.getBio(),
                p.getExperienceYears(), categoryIds(userId), districtIds(userId),
                docs.stream().map(d -> new ApplicationView.Doc(d.getId(), d.getType(), d.getStatus(),
                        media.ref(d.getMediaId()))).toList(),
                submitted);
    }

    // ─── Profil ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public ProfileView profile(UUID userId) {
        return view(access.requireApproved(userId));
    }

    @Transactional
    public ProfileView updateProfile(UUID userId, ProfileBody b) {
        ProProfile p = access.requireApproved(userId);
        String businessName = businessName(b.businessName());
        List<String> categoryIds = checkCategories(b.categoryIds());
        List<Integer> districtIds = checkDistricts(b.districtIds());
        List<ProWorkingHours> rows = parseHours(userId, b.workingHours());
        p.setBusinessName(businessName);
        p.setBio(b.bio() == null || b.bio().isBlank() ? null : b.bio().trim());
        p.setExperienceYears(b.experienceYears());
        profiles.saveAndFlush(p);
        replaceCategoriesAndDistricts(userId, categoryIds, districtIds);
        hours.deleteByProId(userId);
        hours.flush();
        hours.saveAll(rows);
        hours.flush();
        return view(p);
    }

    @Transactional
    public ProfileView setAvailability(UUID userId, Availability availability) {
        ProProfile p = access.requireApproved(userId);
        p.setAvailability(availability);
        profiles.saveAndFlush(p);
        return view(p);
    }

    private ProfileView view(ProProfile p) {
        List<WorkingHourDto> wh = hours.findByProIdOrderByWeekdayAscStartTimeAsc(p.getUserId()).stream()
                .map(h -> new WorkingHourDto(h.getWeekday(), h.getStartTime().format(FMT), h.getEndTime().format(FMT),
                        h.isAcceptsUrgent()))
                .toList();
        return new ProfileView(p.getBusinessName(), p.getBio(), p.getExperienceYears(), categoryIds(p.getUserId()),
                districtIds(p.getUserId()), wh, p.getReviewStatus(), p.getAvailability(), p.getRatingAvg(),
                p.getRatingCount(), p.getCompletedJobs());
    }

    // ─── Yardımcılar ────────────────────────────────────────────────────────

    private List<String> categoryIds(UUID proId) {
        return proCategories.findByProId(proId).stream().map(ProCategory::getCategoryId).sorted().toList();
    }

    private List<Integer> districtIds(UUID proId) {
        return proDistricts.findByProId(proId).stream().map(ProDistrict::getDistrictId).sorted().toList();
    }

    private void replaceCategoriesAndDistricts(UUID proId, List<String> categoryIds, List<Integer> districtIds) {
        proCategories.deleteByProId(proId);
        proDistricts.deleteByProId(proId);
        proCategories.flush();
        proDistricts.flush();
        categoryIds.forEach(c -> proCategories.save(new ProCategory(proId, c)));
        districtIds.forEach(d -> proDistricts.save(new ProDistrict(proId, d)));
        proCategories.flush();
        proDistricts.flush();
    }

    /** 2-100 karakter kuralı kırpılmış ada uygulanır. */
    private static String businessName(String raw) {
        String t = raw.trim();
        if (t.length() < 2 || t.length() > 100) {
            throw ApiException.validation("businessName", "İşletme adı 2-100 karakter olmalı.");
        }
        return t;
    }

    private List<String> checkCategories(List<String> ids) {
        List<String> distinct = ids.stream().distinct().toList();
        for (String id : distinct) {
            if (!categories.findById(id).map(Category::isActive).orElse(false)) {
                throw ApiException.validation("categoryIds", "Kategori bulunamadı: " + id);
            }
        }
        return distinct;
    }

    private List<Integer> checkDistricts(List<Integer> ids) {
        List<Integer> distinct = ids.stream().distinct().toList();
        for (Integer id : distinct) {
            if (!districts.findById(id).map(District::isActive).orElse(false)) {
                throw ApiException.validation("districtIds", "İlçe bulunamadı: " + id);
            }
        }
        return distinct;
    }

    private static List<ProWorkingHours> parseHours(UUID proId, List<WorkingHourDto> input) {
        return input.stream().map(w -> {
            if (!HHMM.matcher(w.start()).matches() || !HHMM.matcher(w.end()).matches()) {
                throw ApiException.validation("workingHours", "Saat HH:mm biçiminde olmalı.");
            }
            LocalTime start = LocalTime.parse(w.start());
            LocalTime end = LocalTime.parse(w.end());
            if (!end.isAfter(start)) {
                throw ApiException.validation("workingHours", "Bitiş saati başlangıçtan sonra olmalı.");
            }
            ProWorkingHours h = new ProWorkingHours();
            h.setProId(proId);
            h.setWeekday(w.weekday());
            h.setStartTime(start);
            h.setEndTime(end);
            h.setAcceptsUrgent(w.acceptsUrgent());
            return h;
        }).toList();
    }
}
