package com.bitadilat.dev;

import com.bitadilat.catalog.District;
import com.bitadilat.catalog.DistrictRepository;
import com.bitadilat.common.AesGcmCrypto;
import com.bitadilat.job.ActorRole;
import com.bitadilat.job.AppointmentProposal;
import com.bitadilat.job.AppointmentProposalRepository;
import com.bitadilat.job.EventType;
import com.bitadilat.job.Job;
import com.bitadilat.job.JobEvents;
import com.bitadilat.job.JobFlow;
import com.bitadilat.job.JobOpening;
import com.bitadilat.job.JobRepository;
import com.bitadilat.job.JobStateMachine.Trigger;
import com.bitadilat.job.ProposalStatus;
import com.bitadilat.media.Media;
import com.bitadilat.media.MediaPurpose;
import com.bitadilat.media.MediaRepository;
import com.bitadilat.media.MediaStorage;
import com.bitadilat.offer.Offer;
import com.bitadilat.offer.OfferRepository;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.domain.EscrowProvider;
import com.bitadilat.payment.service.EscrowService;
import com.bitadilat.request.MatchingService;
import com.bitadilat.request.RequestParts;
import com.bitadilat.request.ServiceRequest;
import com.bitadilat.request.ServiceRequestRepository;
import com.bitadilat.request.Urgency;
import com.bitadilat.user.Address;
import com.bitadilat.user.AddressRepository;
import com.bitadilat.user.User;
import com.bitadilat.user.UserRepository;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.imageio.ImageIO;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * SEED_DATA.md'nin üç işi: BD-88409 (Ali / Mavi Hat, SCHEDULED), BD-88407 (Ali / Kaya, COMPLETED, 5 yıldız) ve
 * BD-88398 (Zeynep / Usta Eller, DISPUTED, şikayet SK-1001). İşler gerçek alan kodundan geçirilir (teklif kabulü, durum
 * makinesi, olay kaydı); yalnızca emanet {@code provider = SEED} ile yazılır, yani iade ve aktarım Craftgate'e gitmez.
 * Yalnızca {@code dev}.
 *
 * <p>Ustaların puan ve iş sayıları seed'in ana tablosundaki toplamlardır; buradaki geçmiş iş o toplamlara dahildir ve
 * yeniden hesaplanmaz.
 */
@Component
@Profile("dev")
class DevJobSeeder {

    private static final ZoneId ISTANBUL = ZoneId.of("Europe/Istanbul");

    private final UserRepository users;
    private final AddressRepository addresses;
    private final DistrictRepository districts;
    private final AesGcmCrypto crypto;
    private final ServiceRequestRepository requests;
    private final RequestParts requestParts;
    private final MatchingService matching;
    private final OfferRepository offers;
    private final JobOpening opening;
    private final JobFlow flow;
    private final JobEvents events;
    private final JobRepository jobs;
    private final AppointmentProposalRepository proposals;
    private final EscrowPaymentRepository escrows;
    private final EscrowService escrowService;
    private final MediaRepository mediaRepository;
    private final MediaStorage storage;
    private final JdbcTemplate jdbc;

    DevJobSeeder(UserRepository users, AddressRepository addresses, DistrictRepository districts, AesGcmCrypto crypto,
                 ServiceRequestRepository requests, RequestParts requestParts, MatchingService matching,
                 OfferRepository offers, JobOpening opening, JobFlow flow, JobEvents events, JobRepository jobs,
                 AppointmentProposalRepository proposals, EscrowPaymentRepository escrows,
                 EscrowService escrowService, MediaRepository mediaRepository, MediaStorage storage,
                 JdbcTemplate jdbc) {
        this.users = users;
        this.addresses = addresses;
        this.districts = districts;
        this.crypto = crypto;
        this.requests = requests;
        this.requestParts = requestParts;
        this.matching = matching;
        this.offers = offers;
        this.opening = opening;
        this.flow = flow;
        this.events = events;
        this.jobs = jobs;
        this.proposals = proposals;
        this.escrows = escrows;
        this.escrowService = escrowService;
        this.mediaRepository = mediaRepository;
        this.storage = storage;
        this.jdbc = jdbc;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    void seedJobs() {
        User ali = user("ali@bitadilat.test");
        User zeynep = user("zeynep@bitadilat.test");
        Address aliAddress = addresses.findByUserIdOrderByDefaultAddressDescCreatedAtAsc(ali.getId()).get(0);
        Address zeynepAddress = seedZeynepAddress(zeynep);
        seedDocuments();
        seedHistory(Map.of("ali", ali, "zeynep", zeynep), Map.of("ali", aliAddress, "zeynep", zeynepAddress));
        seed88409(ali, aliAddress);
        seed88398(zeynep, zeynepAddress);
        // Seed kodları T-10001..T-10006'dır; sonraki teklifler diziden devam eder.
        jdbc.queryForObject("select setval('offer_code_seq', 10006)", Long.class);
        jdbc.queryForObject("select setval('complaint_code_seq', 1001)", Long.class);
    }

    // ─── BD-88409: Ali / Mavi Hat, SCHEDULED yarın 10:00-12:00 ───────────────

    private void seed88409(User ali, Address address) {
        Instant now = Instant.now();
        LocalDate tomorrow = ZonedDateTime.now(ISTANBUL).toLocalDate().plusDays(1);
        Instant from = at(tomorrow, 10);
        Instant to = at(tomorrow, 12);
        ServiceRequest r = request(ali, address, "BD-88409", "plumbing", Urgency.PLANNED, "Kombi petek bakımı",
                "Kombinin ve peteklerin yıllık bakımı yapılacak. İki petek ısınmıyor, hava almış olabilir.",
                from, to, now.minus(Duration.ofHours(5)));
        User mehmet = user("mehmet@bitadilat.test");
        Offer offer = offer(r, mehmet, "T-10005", "900", "300", from, to, 6,
                "Petek temizliği ve hava alma dahil", now);
        Job job = openJob(r, offer, ali.getId());
        EscrowPayment pay = escrow(r, offer, job, ali);

        Instant t0 = now.minus(Duration.ofHours(4));
        schedule(job, ali, mehmet, from, to, t0);
        message(job, mehmet, "Merhaba, yarın 10:00-12:00 arasında geleceğim. Adres tarifini paylaşır mısınız?",
                now.minus(Duration.ofHours(3)));
        message(job, ali, "Merhaba, Moda Cad. üzerinde, Moda İlkokulu'nun karşısındaki apartman. Zil: Yılmaz.",
                now.minus(Duration.ofHours(3)).plusSeconds(240));
        long m3 = message(job, ali, "Binanın önünde park yeri zor, yan sokağa park edebilirsiniz.",
                now.minus(Duration.ofHours(2)));
        long m4 = message(job, mehmet, "Tamam, teşekkürler. Yarın görüşürüz.", now.minus(Duration.ofHours(1)));
        // Ali son mesajı henüz görmedi (okunmamış 1); Mehmet hepsini okudu.
        read(job, ali, m3);
        read(job, mehmet, m4);
        touch(job, pay, now.minus(Duration.ofHours(5)), now.minus(Duration.ofHours(1)));
    }

    // ─── Geçmiş tamamlanmış işler ve değerlendirmeler (BD-88407 dahil) ──────

    private record History(String customer, String pro, String code, String offerCode, String category, String title,
                           String description, String labor, String materials, int daysAgo, int rating, String tags,
                           String comment, boolean anonymous) {
    }

    private static final List<History> HISTORY = List.of(
            new History("ali", "ahmet", "BD-88407", "T-10004", "kitchen", "Mutfak bataryası değişimi",
                    "Mutfak bataryası damlatıyor, yenisiyle değiştirilecek. Yeni batarya hazır, sadece montaj gerekiyor.",
                    "1000", "400", 12, 5, "ON_TIME,CLEAN_WORK", "Zamanında geldi, işi temiz bitirdi. Teşekkürler.", false),
            new History("zeynep", "ahmet", "BD-88301", "T-20001", "plumbing", "Banyo gideri tıkanıklığı",
                    "Banyo giderinden su çekmiyor, koku yapıyor. Gider açılması gerekiyor.",
                    "500", "100", 60, 5, "ON_TIME,POLITE", "Çok kibar ve hızlıydı.", false),
            new History("ali", "ahmet", "BD-88302", "T-20002", "kitchen", "Evye sifonu değişimi",
                    "Evye altındaki sifon çatlak, su damlatıyor. Sifon değişimi yapılacak.",
                    "400", "150", 95, 4, "FAIR_PRICE", "Fiyat makuldü, iş sağlam.", false),
            new History("zeynep", "ahmet", "BD-88303", "T-20003", "plumbing", "Şofben musluğu arızası",
                    "Şofbenin musluğu kapanmıyor, sürekli damlatıyor. Musluk takımı değişecek.",
                    "450", "200", 140, 5, "GOOD_COMMUNICATION,CLEAN_WORK", "Süreç boyunca bilgi verdi.", true),
            new History("ali", "mehmet", "BD-88311", "T-20011", "plumbing", "Kombi su basıncı düşüyor",
                    "Kombinin su basıncı sürekli düşüyor, her hafta doldurmam gerekiyor.",
                    "700", "300", 30, 5, "ON_TIME,GOOD_COMMUNICATION", "Sorunu hemen buldu.", false),
            new History("zeynep", "mehmet", "BD-88312", "T-20012", "bathroom", "Banyo bataryası değişimi",
                    "Banyo bataryasını yeniletmek istiyorum, batarya hazır.",
                    "600", "400", 70, 5, "CLEAN_WORK,POLITE", "Ortalığı topladı, çok memnunum.", false),
            new History("ali", "mehmet", "BD-88313", "T-20013", "plumbing", "Klozet rezervuarı tamiri",
                    "Rezervuar sürekli su akıtıyor, şamandıra değişimi gerekli.",
                    "350", "150", 110, 4, "FAIR_PRICE,ON_TIME", "Biraz geç geldi ama iş temiz.", false),
            new History("zeynep", "mehmet", "BD-88314", "T-20014", "bathroom", "Duş teknesi sızıntısı",
                    "Duş teknesinin altından sızıntı var, alt komşuya su gidiyor.",
                    "900", "600", 150, 5, "ON_TIME,CLEAN_WORK,POLITE", "Kimseyi mağdur etmeden çözdü.", true),
            new History("ali", "emre", "BD-88321", "T-20021", "plumbing", "Lavabo gideri tıkanıklığı",
                    "Lavabo giderinden su gitmiyor, açılması gerekiyor.",
                    "300", "50", 45, 5, "ON_TIME", "Hızlı ve temiz çalıştı.", false),
            new History("zeynep", "emre", "BD-88322", "T-20022", "plumbing", "Petek vanası değişimi",
                    "Salon peteğinin vanası takılı kaldı, değişmesi gerekiyor.",
                    "400", "200", 85, 4, "FAIR_PRICE", "İşini biliyor, fiyat uygun.", false),
            new History("ali", "emre", "BD-88323", "T-20023", "plumbing", "Mutfak musluğu sızıntısı",
                    "Mutfak musluğunun altından su sızıyor.",
                    "350", "150", 125, 4, "POLITE,GOOD_COMMUNICATION", "Gayet ilgiliydi.", true));

    private void seedHistory(Map<String, User> customers, Map<String, Address> addressesBy) {
        for (History h : HISTORY) {
            completedJob(customers.get(h.customer()), addressesBy.get(h.customer()), user(h.pro() + "@bitadilat.test"), h);
        }
        // Puan ve iş sayısı bu kayıtlardan hesaplanır; elle yazılmaz.
        jdbc.update("""
                update pro_profiles p set
                  rating_avg = (select round(avg(rating)::numeric, 2) from reviews where pro_id = p.user_id),
                  rating_count = (select count(*) from reviews where pro_id = p.user_id),
                  completed_jobs = (select count(*) from jobs where pro_id = p.user_id and status = 'COMPLETED')
                where p.user_id in (select pro_id from reviews)""");
    }

    /** Tamamlanmış geçmiş iş: gerçek durum makinesi, SEED emanet RELEASED_TO_PRO, defter ve değerlendirme. */
    private void completedJob(User customer, Address address, User pro, History h) {
        Instant now = Instant.now();
        Instant base = now.minus(Duration.ofDays(h.daysAgo()));
        Instant day = base.plus(Duration.ofDays(1));
        ServiceRequest r = request(customer, address, h.code(), h.category(), Urgency.PLANNED, h.title(),
                h.description(), day, day.plus(Duration.ofHours(3)), base);
        Offer offer = offer(r, pro, h.offerCode(), h.labor(), h.materials(), now.plus(Duration.ofHours(1)),
                now.plus(Duration.ofHours(3)), 6, "Malzeme ve işçilik dahil", now);
        Job job = openJob(r, offer, customer.getId());
        // Teklifin varış aralığı geçmişte kalsın.
        offer.setArrivalFrom(day);
        offer.setArrivalTo(day.plus(Duration.ofHours(3)));
        offer.setValidUntil(day.plus(Duration.ofHours(3)));
        offers.saveAndFlush(offer);
        EscrowPayment pay = escrow(r, offer, job, customer);

        schedule(job, customer, pro, day, day.plus(Duration.ofHours(3)), base.plus(Duration.ofHours(2)));
        flow.move(job, Trigger.ARRIVE, pro.getId(), ActorRole.PRO, null, day.plus(Duration.ofMinutes(5)));
        flow.move(job, Trigger.START, pro.getId(), ActorRole.PRO, null, day.plus(Duration.ofMinutes(20)));
        flow.move(job, Trigger.FINISH, pro.getId(), ActorRole.PRO,
                "İş tamamlandı, bağlantılar kontrol edildi, kaçak testi temiz.", day.plus(Duration.ofHours(2)));
        Instant confirmed = day.plus(Duration.ofHours(8));
        flow.move(job, Trigger.CONFIRM, customer.getId(), ActorRole.CUSTOMER, null, confirmed);
        escrowService.release(pay); // SEED: yalnızca defter

        jdbc.update("""
                insert into reviews (job_id, customer_id, pro_id, rating, tags, comment, is_anonymous, created_at)
                values (?, ?, ?, ?, ?::text[], ?, ?, ?)""", job.getId(), customer.getId(), pro.getId(), h.rating(),
                "{" + h.tags() + "}", h.comment(), h.anonymous(), Timestamp.from(confirmed.plus(Duration.ofHours(3))));
        touch(job, pay, base, confirmed);
        jdbc.update("update escrow_payment set released_at = ? where ref = ?", Timestamp.from(confirmed),
                pay.getRef());
    }

    // ─── Usta belgeleri ──────────────────────────────────────────────────────

    private void seedDocuments() {
        UUID admin = user("admin@bitadilat.test").getId();
        for (String email : List.of("mehmet", "ahmet", "emre")) {
            document(email, "IDENTITY", "ACCEPTED", admin);
            document(email, "TRADE_CERT", "ACCEPTED", admin);
        }
        document("hasan", "IDENTITY", "PENDING", null);
        document("hasan", "TRADE_CERT", "PENDING", null);
        document("selim", "IDENTITY", "ACCEPTED", admin);
        document("selim", "TRADE_CERT", "REJECTED", admin);
    }

    private void document(String who, String type, String status, UUID reviewer) {
        User pro = user(who + "@bitadilat.test");
        UUID media = png(pro, MediaPurpose.PRO_DOCUMENT);
        jdbc.update("""
                insert into pro_documents (pro_id, type, media_id, status, reviewed_by, reviewed_at)
                values (?, ?, ?, ?, ?, ?)""", pro.getId(), type, media, status, reviewer,
                reviewer == null ? null : Timestamp.from(Instant.now()));
    }

    // ─── BD-88398: Zeynep / Usta Eller, DISPUTED, SK-1001 ────────────────────

    private void seed88398(User zeynep, Address address) {
        Instant now = Instant.now();
        Instant base = now.minus(Duration.ofDays(3));
        Instant day = base.plus(Duration.ofHours(4));
        ServiceRequest r = request(zeynep, address, "BD-88398", "plumbing", Urgency.URGENT,
                "Mutfak gider tıkanıklığı", "Mutfak giderinden su geri geliyor, lavabo hiç akmıyor. Acil bakılması gerekiyor.",
                null, null, base);
        User emre = user("emre@bitadilat.test");
        Offer offer = offer(r, emre, "T-10006", "1600", "600", now.plus(Duration.ofHours(1)),
                now.plus(Duration.ofHours(3)), 3, "Gider açma makinesiyle temizlik", now);
        Job job = openJob(r, offer, zeynep.getId());
        offer.setArrivalFrom(day);
        offer.setArrivalTo(day.plus(Duration.ofHours(3)));
        offer.setValidUntil(day.plus(Duration.ofHours(3)));
        offers.saveAndFlush(offer);
        EscrowPayment pay = escrow(r, offer, job, zeynep);

        schedule(job, zeynep, emre, day, day.plus(Duration.ofHours(3)), base.plus(Duration.ofMinutes(30)));
        flow.move(job, Trigger.ARRIVE, emre.getId(), ActorRole.PRO, null, day.plus(Duration.ofMinutes(10)));
        flow.move(job, Trigger.START, emre.getId(), ActorRole.PRO, null, day.plus(Duration.ofMinutes(30)));

        Instant c = day.plus(Duration.ofHours(1));
        message(job, zeynep, "Usta bey, gider açıldı mı?", c);
        message(job, emre, "Açtım ama borunun bir kısmı çürümüş, değişmesi lazım.", c.plusSeconds(300));
        message(job, zeynep, "Teklifte böyle bir şey yoktu, ne kadar tutar?", c.plusSeconds(600));
        message(job, emre, "Ek malzeme ve işçilik 600 TL daha tutar.", c.plusSeconds(900));
        message(job, zeynep, "Teklif dışı ücret ödemem, işi teklifteki fiyata bitirin lütfen.", c.plusSeconds(1200));
        message(job, emre, "O zaman 600 TL'yi elden vermezseniz işi bırakırım.", c.plusSeconds(1500));

        // Şikayet: iş ve emanet DISPUTED olur (aynı işlem), SK-1001 açık.
        Instant complained = c.plus(Duration.ofHours(1));
        escrowService.dispute(pay);
        flow.move(job, Trigger.COMPLAIN, zeynep.getId(), ActorRole.CUSTOMER, "EXTRA_CHARGE", complained);
        UUID complaintId = jdbc.queryForObject("""
                insert into complaints (public_code, job_id, customer_id, pro_id, reason, description, created_at, updated_at)
                values ('SK-1001', ?, ?, ?, 'EXTRA_CHARGE', ?, ?, ?) returning id""", UUID.class, job.getId(),
                zeynep.getId(), emre.getId(),
                "Teklif dışı fazladan ücret talep edildi. Ustanın istediği 600 TL ek ödemeyi kabul etmediğimde "
                        + "işi bırakacağını söyledi.", Timestamp.from(complained), Timestamp.from(complained));
        for (int i = 1; i <= 2; i++) {
            UUID media = evidencePhoto(zeynep, i);
            jdbc.update("insert into complaint_evidence (complaint_id, media_id) values (?, ?)", complaintId, media);
        }
        touch(job, pay, base, complained);
    }

    // ─── Ortak yardımcılar ───────────────────────────────────────────────────

    private User user(String email) {
        return users.findByEmailIgnoreCase(email).orElseThrow();
    }

    private Address seedZeynepAddress(User zeynep) {
        District atasehir = districts.findByNameAndActiveTrue("Ataşehir").orElseThrow();
        String aad = "addr:" + zeynep.getId();
        Address a = new Address();
        a.setUserId(zeynep.getId());
        a.setLabel("Ev");
        a.setDistrictId(atasehir.getId());
        a.setNeighborhood("Atatürk");
        a.setLineFullEncrypted(crypto.encrypt("Atatürk Mah. Ihlamur Sok. No: 7 Daire: 3", aad));
        a.setDoorNoteEncrypted(crypto.encrypt("Zil: Kaya", aad));
        a.setDefaultAddress(true);
        return addresses.saveAndFlush(a);
    }

    private ServiceRequest request(User customer, Address address, String code, String category, Urgency urgency,
                                   String title, String description, Instant preferredFrom, Instant preferredTo,
                                   Instant createdAt) {
        ServiceRequest r = new ServiceRequest();
        r.setPublicCode(code);
        r.setCustomerId(customer.getId());
        r.setCategoryId(category);
        r.setUrgency(urgency);
        r.setPreferredFrom(preferredFrom);
        r.setPreferredTo(preferredTo);
        r.setTitle(title);
        r.setDescription(description);
        r.setDistrictId(address.getDistrictId());
        r.setNeighborhood(address.getNeighborhood());
        r.setAddressId(address.getId());
        r.setExpiresAt(Instant.now().plus(Duration.ofDays(7)));
        r.setMatchedProCount(matching.matchedProIds(category, address.getDistrictId(), customer.getId()).size());
        r = requests.saveAndFlush(r);
        Map<String, String> answers = new LinkedHashMap<>();
        answers.put("since", "few_days");
        requestParts.replaceAnswers(r.getId(), answers);
        jdbc.update("update service_requests set created_at = ?, updated_at = ? where id = ?",
                Timestamp.from(createdAt), Timestamp.from(createdAt), r.getId());
        return r;
    }

    private Offer offer(ServiceRequest r, User pro, String code, String labor, String materials, Instant from,
                        Instant to, int warranty, String note, Instant now) {
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
        return offers.saveAndFlush(o);
    }

    /** Teklifi gerçek kabul koduyla kabul eder: teklif ACCEPTED, talep ASSIGNED, iş AWAITING_APPOINTMENT. */
    private Job openJob(ServiceRequest r, Offer offer, UUID customerId) {
        JobOpening.Result result = opening.open(r.getId(), offer.getId(), customerId);
        if (!result.opened()) {
            throw new IllegalStateException("Seed işi açılamadı: " + result.errorCode());
        }
        return result.job();
    }

    private EscrowPayment escrow(ServiceRequest r, Offer offer, Job job, User customer) {
        EscrowPayment p = EscrowPayment.startApp(offer.getId(), r.getPublicCode(), offer.getTotalAmount(), r.getId(),
                customer.getId(), offer.getProId(), UUID.randomUUID().toString(), "4242", EscrowProvider.SEED);
        p.lock();
        p.attachJob(job.getId());
        return escrows.saveAndFlush(p);
    }

    /** Müşteri aralığı önerir, usta kabul eder: iş SCHEDULED. */
    private void schedule(Job job, User customer, User pro, Instant from, Instant to, Instant at) {
        AppointmentProposal p = new AppointmentProposal();
        p.setJobId(job.getId());
        p.setProposedBy(ActorRole.CUSTOMER);
        p.setSlotFrom(from);
        p.setSlotTo(to);
        p.setStatus(ProposalStatus.ACCEPTED);
        proposals.saveAndFlush(p);
        events.record(job.getId(), customer.getId(), ActorRole.CUSTOMER, EventType.APPOINTMENT_PROPOSED, null, null,
                from + "/" + to, null, at);
        job.setScheduledFrom(from);
        job.setScheduledTo(to);
        events.record(job.getId(), pro.getId(), ActorRole.PRO, EventType.APPOINTMENT_ACCEPTED, null, null,
                from + "/" + to, null, at.plusSeconds(60));
        flow.move(job, Trigger.ACCEPT_APPOINTMENT, pro.getId(), ActorRole.PRO, null, at.plusSeconds(60));
    }

    private long message(Job job, User sender, String body, Instant at) {
        return jdbc.queryForObject("""
                insert into messages (job_id, sender_id, body, created_at) values (?, ?, ?, ?) returning id""",
                Long.class, job.getId(), sender.getId(), body, Timestamp.from(at));
    }

    private void read(Job job, User user, long lastReadId) {
        jdbc.update("insert into message_reads (job_id, user_id, last_read_id) values (?, ?, ?)", job.getId(),
                user.getId(), lastReadId);
    }

    /** İş ve emanet kayıt zamanlarını seed'in anlatısına (geçmişte açıldı) çeker; açılış olayı da aynı zamanda. */
    private void touch(Job job, EscrowPayment pay, Instant created, Instant updated) {
        jdbc.update("update jobs set created_at = ?, updated_at = ? where id = ?", Timestamp.from(created),
                Timestamp.from(updated), job.getId());
        jdbc.update("update job_events set created_at = ? where job_id = ? and from_status is null and type = 'STATUS_CHANGED'",
                Timestamp.from(created), job.getId());
        jdbc.update("update escrow_payment set created_at = ?, locked_at = ? where ref = ?", Timestamp.from(created),
                Timestamp.from(created), pay.getRef());
    }

    private UUID png(User owner, MediaPurpose purpose) {
        BufferedImage img = new BufferedImage(120, 80, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setColor(new Color(0xE8EEF2));
        g.fillRect(0, 0, 120, 80);
        g.setColor(new Color(0x102A34));
        g.drawRect(4, 4, 111, 71);
        g.dispose();
        byte[] bytes;
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            ImageIO.write(img, "png", out);
            bytes = out.toByteArray();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        Media m = new Media();
        m.setOwnerId(owner.getId());
        m.setPurpose(purpose);
        m.setStorageKey(UUID.randomUUID() + ".png");
        m.setContentType("image/png");
        m.setSizeBytes(bytes.length);
        m.setWidth(120);
        m.setHeight(80);
        storage.store(m.getStorageKey(), bytes);
        return mediaRepository.saveAndFlush(m).getId();
    }

    private UUID evidencePhoto(User owner, int n) {
        BufferedImage img = new BufferedImage(320, 240, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setColor(n == 1 ? new Color(0x9CB4C4) : new Color(0xC4B49C));
        g.fillRect(0, 0, 320, 240);
        g.dispose();
        byte[] bytes;
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            ImageIO.write(img, "jpg", out);
            bytes = out.toByteArray();
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        Media m = new Media();
        m.setOwnerId(owner.getId());
        m.setPurpose(MediaPurpose.COMPLAINT);
        m.setStorageKey(UUID.randomUUID() + ".jpg");
        m.setContentType("image/jpeg");
        m.setSizeBytes(bytes.length);
        m.setWidth(320);
        m.setHeight(240);
        storage.store(m.getStorageKey(), bytes);
        return mediaRepository.saveAndFlush(m).getId();
    }

    private static Instant at(LocalDate day, int hour) {
        return day.atTime(hour, 0).atZone(ISTANBUL).toInstant();
    }
}
