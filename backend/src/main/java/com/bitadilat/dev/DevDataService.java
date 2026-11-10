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
import com.bitadilat.offer.ItemKind;
import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferItem;
import com.bitadilat.offer.OfferItemRepository;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.request.MatchingService;
import com.bitadilat.request.RequestParts;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import com.bitadilat.request.Urgency;
import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * docs/spec/SEED_DATA.md demo seti (hesaplar, usta profilleri, Ali'nin adresi). Yalnızca {@code dev}.
 * BD-88412 talebi ve 3 teklifi buradadır; BD-88407/09/98 işleri (emanet {@code provider = SEED}, mesajlar, değerlendirme,
 * şikayet SK-1001) {@link DevJobSeeder}'dadır.
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
            new Demo("Hasan Yıldız", "hasan@bitadilat.test", "+905379026615", false, UserMode.PRO,
                    new Pro("Yıldız Elektrik", "Ev elektrik tesisatı ve arıza giderme.", 6,
                            ReviewStatus.PENDING_REVIEW, null, List.of("electrical"),
                            List.of("Ümraniye"), null, 0, 0)),
            new Demo("Selim Aksoy", "selim@bitadilat.test", "+905383412758", false, UserMode.PRO,
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
    private final ServiceRequestRepository serviceRequests;
    private final OfferRepository offers;
    private final OfferItemRepository offerItems;
    private final RequestParts requestParts;
    private final MatchingService matching;
    private final DevJobSeeder jobSeeder;

    public DevDataService(UserRepository users, ProProfileRepository proProfiles,
                          ProCategoryRepository proCategories, ProDistrictRepository proDistricts,
                          ProWorkingHoursRepository workingHours, AddressRepository addresses,
                          DistrictRepository districts, PasswordEncoder encoder, AesGcmCrypto crypto,
                          JdbcTemplate jdbc, ServiceRequestRepository serviceRequests, OfferRepository offers,
                          OfferItemRepository offerItems, RequestParts requestParts, MatchingService matching,
                          DevJobSeeder jobSeeder) {
        this.jobSeeder = jobSeeder;
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
        this.serviceRequests = serviceRequests;
        this.offers = offers;
        this.offerItems = offerItems;
        this.requestParts = requestParts;
        this.matching = matching;
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
        // login_attempts users'a bağlı değil (yalnız tanımlayıcı özeti); açıkça boşaltılmazsa giriş kilidi taşınır.
        jdbc.execute("TRUNCATE TABLE users, media, escrow_payment, payout_ledger, admin_actions, login_attempts "
                + "RESTART IDENTITY CASCADE");
        // Herkese gösterilen kod dizileri: seed sabit kodları (BD-88412, T-10001..3) kullanır, sonrası dizidendir.
        jdbc.execute("ALTER SEQUENCE request_code_seq RESTART WITH 88413");
        jdbc.execute("ALTER SEQUENCE offer_code_seq RESTART WITH 10004");
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
        // İşler önce, BD-88412 en son: Ali'nin listesinde en yeni talep BD-88412'dir.
        jobSeeder.seedJobs();
        seedRequest88412();
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
        // Puan ve iş sayısı sabit yazılmaz: DevJobSeeder geçmiş işleri ve değerlendirmeleri yükleyip bunlardan hesaplar.
        profile.setRatingAvg(null);
        profile.setRatingCount(0);
        profile.setCompletedJobs(0);
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

    private static final ZoneId ISTANBUL = ZoneId.of("Europe/Istanbul");

    /** SEED_DATA.md: BD-88412 (Ali, Tesisat, ACİL, Kadıköy Caferağa) ve 3 teklifi. Fotoğraf yok. */
    private void seedRequest88412() {
        User ali = users.findByEmailIgnoreCase("ali@bitadilat.test").orElseThrow();
        Address address = addresses.findByUserIdOrderByDefaultAddressDescCreatedAtAsc(ali.getId()).get(0);
        Instant now = Instant.now();

        ServiceRequest r = new ServiceRequest();
        r.setPublicCode("BD-88412");
        r.setCustomerId(ali.getId());
        r.setCategoryId("plumbing");
        r.setUrgency(Urgency.URGENT);
        r.setTitle("Banyo lavabo altı su kaçağı");
        r.setDescription("Banyo lavabosunun altındaki sifon bağlantısından su damlıyor, dolabın içi ıslandı. "
                + "En kısa sürede bakılması gerekiyor.");
        r.setDistrictId(address.getDistrictId());
        r.setNeighborhood(address.getNeighborhood());
        r.setAddressId(address.getId());
        r.setExpiresAt(now.plus(Duration.ofDays(7)));
        r.setMatchedProCount(matching.matchedProIds("plumbing", address.getDistrictId(), ali.getId()).size());
        r = serviceRequests.saveAndFlush(r);
        Map<String, String> answers = new LinkedHashMap<>();
        answers.put("since", "today");
        answers.put("water_cut", "no");
        answers.put("other_rooms", "no");
        requestParts.replaceAnswers(r.getId(), answers);

        // "Bugün 14:00" geçmişse (veya başlamışsa) ertesi güne kayar; "yarın" her zaman bugünden bir sonraki gündür.
        LocalDate today = ZonedDateTime.now(ISTANBUL).toLocalDate();
        Instant mavi = at(today, 14);
        LocalDate maviDay = mavi.isAfter(now) ? today : today.plusDays(1);
        LocalDate tomorrow = today.plusDays(1);
        seedOffer(r, "mehmet@bitadilat.test", "T-10001", "1650", "800", at(maviDay, 14), at(maviDay, 17), 6,
                "Lavabo altı bağlantılar ve sifon değişimi, ek işlem onaysız yapılmaz", now, List.of(
                        new Line(ItemKind.LABOR, "İşçilik", "1650"),
                        new Line(ItemKind.MATERIAL, "Sifon ve bağlantı parçaları", "450"),
                        new Line(ItemKind.MATERIAL, "Conta ve sızdırmazlık seti", "350")));
        seedOffer(r, "ahmet@bitadilat.test", "T-10002", "1400", "800", at(tomorrow, 9), at(tomorrow, 11), 6,
                "Kadıköy'deyim; sızıntı tespiti ve parça montajı dahil", now, List.of());
        seedOffer(r, "emre@bitadilat.test", "T-10003", "1250", "600", at(tomorrow, 13), at(tomorrow, 15), 3,
                "Yalnızca bağlantı contaları; sifon gerekirse ayrıca fiyat", now, List.of());
    }

    private record Line(ItemKind kind, String description, String amount) {
    }

    private static Instant at(LocalDate day, int hour) {
        return day.atTime(hour, 0).atZone(ISTANBUL).toInstant();
    }

    private void seedOffer(ServiceRequest r, String proEmail, String code, String labor, String materials,
                           Instant from, Instant to, int warranty, String note, Instant now, List<Line> lines) {
        User pro = users.findByEmailIgnoreCase(proEmail).orElseThrow();
        Offer o = new Offer();
        o.setPublicCode(code);
        o.setRequestId(r.getId());
        o.setProId(pro.getId());
        o.setLaborAmount(new BigDecimal(labor).setScale(2));
        o.setMaterialsAmount(new BigDecimal(materials).setScale(2));
        o.setTotalAmount(o.getLaborAmount().add(o.getMaterialsAmount()));
        o.setArrivalFrom(from);
        o.setArrivalTo(to);
        o.setWarrantyMonths(warranty);
        o.setNote(note);
        Instant cap = now.plus(Duration.ofHours(72));
        o.setValidUntil(to.isBefore(cap) ? to : cap);
        o = offers.saveAndFlush(o);
        int order = 0;
        for (Line l : lines) {
            OfferItem it = new OfferItem();
            it.setOfferId(o.getId());
            it.setKind(l.kind());
            it.setDescription(l.description());
            it.setQuantity(new BigDecimal("1.00"));
            it.setUnitPrice(new BigDecimal(l.amount()).setScale(2));
            it.setSortOrder(order++);
            offerItems.save(it);
        }
        offerItems.flush();
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
