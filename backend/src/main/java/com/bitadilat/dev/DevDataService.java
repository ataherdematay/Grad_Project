package com.bitadilat.dev;

import com.bitadilat.catalog.District;
import com.bitadilat.catalog.DistrictRepository;
import com.bitadilat.common.AesGcmCrypto;
import com.bitadilat.pro.Availability;
import com.bitadilat.pro.ProCategory;
import com.bitadilat.pro.ProCategoryRepository;
import com.bitadilat.pro.ProDistrict;
import com.bitadilat.pro.ProDistrictRepository;
import com.bitadilat.pro.ProProfile;
import com.bitadilat.pro.ProProfileRepository;
import com.bitadilat.pro.ProWorkingHours;
import com.bitadilat.pro.ProWorkingHoursRepository;
import com.bitadilat.pro.ReviewStatus;
import com.bitadilat.user.Address;
import com.bitadilat.user.AddressRepository;
import com.bitadilat.user.User;
import com.bitadilat.user.UserMode;
import com.bitadilat.user.UserRepository;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalTime;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * docs/spec/SEED_DATA.md demo seti (hesaplar, usta profilleri, Ali'nin adresi). Yalnızca {@code dev}.
 * Talep, teklif, iş ve ödeme kayıtları sonraki dalgada eklenecek.
 */
@Slf4j
@Service
@Profile("dev")
public class DevDataService {

    public static final String DEMO_PASSWORD = "Demo1234!";

    private record Demo(String name, String email, String phone, boolean admin, UserMode mode, Pro pro) {
    }

    private record Pro(String business, String bio, int years, ReviewStatus status, String note,
                       List<String> categories, List<String> districts, String rating, int ratingCount, int jobs) {
    }

    private static final List<Demo> DEMOS = List.of(
            new Demo("Ali Yılmaz", "ali@bitadilat.test", "+905328492011", false, UserMode.CUSTOMER, null),
            new Demo("Zeynep Kaya", "zeynep@bitadilat.test", "+905332104567", false, UserMode.CUSTOMER, null),
            new Demo("Mehmet Demir", "mehmet@bitadilat.test", "+905324508892", false, UserMode.PRO,
                    new Pro("Mavi Hat Tesisat", "Kaçak tespiti, tesisat yenileme ve banyo işleri.", 12,
                            ReviewStatus.APPROVED, null, List.of("plumbing", "bathroom"),
                            List.of("Kadıköy", "Üsküdar", "Ataşehir", "Maltepe"), "4.80", 126, 214)),
            new Demo("Ahmet Kaya", "ahmet@bitadilat.test", "+905351183240", false, UserMode.PRO,
                    new Pro("Kaya Tesisat", "Mutfak ve tesisat işlerinde hızlı servis.", 15,
                            ReviewStatus.APPROVED, null, List.of("plumbing", "kitchen"),
                            List.of("Kadıköy", "Üsküdar"), "4.90", 84, 131)),
            new Demo("Emre Çelik", "emre@bitadilat.test", "+905367741903", false, UserMode.PRO,
                    new Pro("Usta Eller Tesisat", "Tıkanıklık açma ve küçük tesisat onarımları.", 9,
                            ReviewStatus.APPROVED, null, List.of("plumbing"),
                            List.of("Kadıköy", "Ataşehir"), "4.70", 62, 88)),
            new Demo("Hasan Yıldız", "hasan@bitadilat.test", "+905379026615", false, UserMode.CUSTOMER,
                    new Pro("Yıldız Elektrik", "Ev elektrik tesisatı ve arıza giderme.", 6,
                            ReviewStatus.PENDING_REVIEW, null, List.of("electrical"),
                            List.of("Ümraniye"), null, 0, 0)),
            new Demo("Selim Aksoy", "selim@bitadilat.test", "+905383412758", false, UserMode.CUSTOMER,
                    new Pro("Aksoy Boya & Badana", "İç cephe boya ve badana.", 8,
                            ReviewStatus.NEEDS_DOCUMENTS, "Vergi levhası eksik. Belgeyi yükleyip yeniden gönder.",
                            List.of("painting"), List.of("Beşiktaş"), null, 0, 0)),
            new Demo("Yönetici", "admin@bitadilat.test", null, true, UserMode.CUSTOMER, null));

    private final UserRepository users;
    private final ProProfileRepository proProfiles;
    private final ProCategoryRepository proCategories;
    private final ProDistrictRepository proDistricts;
    private final ProWorkingHoursRepository workingHours;
    private final AddressRepository addresses;
    private final DistrictRepository districts;
    private final PasswordEncoder encoder;
    private final AesGcmCrypto crypto;
    private final JdbcTemplate jdbc;

    public DevDataService(UserRepository users, ProProfileRepository proProfiles,
                          ProCategoryRepository proCategories, ProDistrictRepository proDistricts,
                          ProWorkingHoursRepository workingHours, AddressRepository addresses,
                          DistrictRepository districts, PasswordEncoder encoder, AesGcmCrypto crypto,
                          JdbcTemplate jdbc) {
        this.users = users;
        this.proProfiles = proProfiles;
        this.proCategories = proCategories;
        this.proDistricts = proDistricts;
        this.workingHours = workingHours;
        this.addresses = addresses;
        this.districts = districts;
        this.encoder = encoder;
        this.crypto = crypto;
        this.jdbc = jdbc;
    }

    @Transactional
    public void seedIfEmpty() {
        if (users.count() == 0) {
            seed();
        }
    }

    /** Katalog (kategori, ilçe) hariç tüm verileri siler ve seti yeniden yükler. */
    @Transactional
    public void resetAndSeed() {
        jdbc.execute("TRUNCATE TABLE users, media, escrow_payment, payout_ledger, admin_actions "
                + "RESTART IDENTITY CASCADE");
        seed();
    }

    private void seed() {
        String hash = encoder.encode(DEMO_PASSWORD);
        Instant now = Instant.now();
        for (Demo d : DEMOS) {
            User u = new User();
            u.setFullName(d.name());
            u.setEmail(d.email());
            u.setPhone(d.phone());
            u.setPasswordHash(hash);
            u.setAdmin(d.admin());
            u.setLastMode(d.mode());
            u.setKvkkAcceptedAt(now);
            u.setTermsAcceptedAt(now);
            u = users.saveAndFlush(u);
            if (d.pro() != null) {
                seedPro(u, d.pro(), now);
            }
            if (d.email().startsWith("ali@")) {
                seedAddress(u);
            }
        }
        log.info("Demo verisi yüklendi: {} hesap (şifre {}).", DEMOS.size(), DEMO_PASSWORD);
    }

    private void seedPro(User user, Pro p, Instant now) {
        ProProfile profile = new ProProfile();
        profile.setUserId(user.getId());
        profile.setBusinessName(p.business());
        profile.setBio(p.bio());
        profile.setExperienceYears(p.years());
        profile.setReviewStatus(p.status());
        profile.setReviewNote(p.note());
        profile.setAvailability(Availability.ACTIVE);
        // Not: puan/iş sayısı geçmiş iş ve yorumlar seed'lenince onlardan hesaplanacak; şimdilik tablodaki değerler.
        profile.setRatingAvg(p.rating() == null ? null : new BigDecimal(p.rating()));
        profile.setRatingCount(p.ratingCount());
        profile.setCompletedJobs(p.jobs());
        profile.setApprovedAt(p.status() == ReviewStatus.APPROVED ? now : null);
        proProfiles.saveAndFlush(profile);

        p.categories().forEach(c -> proCategories.save(new ProCategory(user.getId(), c)));
        for (String name : p.districts()) {
            District d = districts.findByNameAndActiveTrue(name).orElseThrow();
            proDistricts.save(new ProDistrict(user.getId(), d.getId()));
        }
        if (p.status() == ReviewStatus.APPROVED) {
            for (int weekday = 1; weekday <= 6; weekday++) {
                ProWorkingHours h = new ProWorkingHours();
                h.setProId(user.getId());
                h.setWeekday(weekday);
                h.setStartTime(LocalTime.of(8, 0));
                h.setEndTime(LocalTime.of(19, 0));
                h.setAcceptsUrgent(true);
                workingHours.save(h);
            }
        }
        proCategories.flush();
    }

    private void seedAddress(User ali) {
        District kadikoy = districts.findByNameAndActiveTrue("Kadıköy").orElseThrow();
        String aad = "addr:" + ali.getId();
        Address a = new Address();
        a.setUserId(ali.getId());
        a.setLabel("Ev");
        a.setDistrictId(kadikoy.getId());
        a.setNeighborhood("Caferağa");
        a.setLineFullEncrypted(crypto.encrypt("Caferağa Mah. Moda Cad. No: 14 Daire: 5", aad));
        a.setDoorNoteEncrypted(crypto.encrypt("Zil: Yılmaz", aad));
        a.setDefaultAddress(true);
        addresses.saveAndFlush(a);
    }
}
