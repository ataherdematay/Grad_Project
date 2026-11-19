# BiTadilat — Test Raporu (şablon ve ilk koşu)

Bu dosya üç bölümdür: **Bölüm A** bir test turunun nasıl kaydedileceğini gösteren boş şablon, **Bölüm B** şablonun 16 Kasım 2026 tarihli ilk koşu (565bfb4) ile doldurulmuş hali, **Bölüm C** 19 Kasım 2026'da son koda (c335a10) karşı yapılan yeniden koşu ve elle uçtan uca doğrulamaların kaydı. Sonraki her tur için Bölüm A kopyalanıp doldurulur (`TEST_REPORT_2026-12-xx.md`). Plan: `TEST_PLAN.md`, senaryolar: `TEST_CASES.md`.

---

## Bölüm A — Boş şablon

### A.1 Koşu bilgisi

| Alan | Değer |
|---|---|
| Rapor tarihi | GG.AA.YYYY |
| Dal ve işlem | `feature/flutter-app` @ `<kısa işlem numarası>` (`git log --oneline -1`) |
| Çalışma ağacı temiz mi | evet / hayır (`git status --short`) |
| Koşuyu yapan | |
| İşletim sistemi | |
| Java / Flutter / Dart / PostgreSQL sürümleri | |
| Test veritabanı | `<veritabanı adı>`; Docker/Testcontainers kullanıldı mı |
| Craftgate | sandbox / sahte ağ geçidi |

### A.2 Otomatik paketler

| Paket | Komut | Toplam | Geçti | Kaldı | Atlandı | Süre | Not |
|---|---|---|---|---|---|---|---|
| backend | `cd backend && ./mvnw -q -B test` (sayılar için `-B` ile, `Tests run:` satırı) | | | | | | |
| apps/mobile | `cd apps/mobile && flutter test` | | | | | | |
| apps/admin | `cd apps/admin && flutter test` | | | | | | |
| packages/bitadilat_ui | `cd packages/bitadilat_ui && flutter test` | | | | | | |
| packages/bitadilat_api | `cd packages/bitadilat_api && flutter test` | | | | | | |
| **Toplam** | | | | | | | |

Sayıları almak için: backend için Maven çıktısının sonundaki `Tests run: N, Failures: F, Errors: E, Skipped: S` satırı; Flutter için `flutter test --reporter json` çıktısındaki gizli olmayan `testDone` olayları (ya da konsoldaki `+N: All tests passed!` satırı).

### A.3 Sınıf / dosya bazında dağılım

| Paket | Sınıf / dosya | Test sayısı | Sonuç |
|---|---|---|---|
| | | | |

### A.4 Senaryo bazında sonuç (TEST_CASES.md)

| Durum | Adet |
|---|---|
| Otomatik, geçti | |
| Kısmi | |
| Boşluk | |
| Elle, geçti | |
| Elle, kaldı | |
| Elle, bekliyor | |
| Gerçekleştirilmedi | |

Elle koşulan senaryolar:

| Senaryo kimliği | Tarih | Yapan | Ortam | Sonuç (Geçti/Kaldı) | Kanıt (ekran görüntüsü, log yolu) |
|---|---|---|---|---|---|
| | | | | | |

### A.5 Sandbox ödeme koşusu (TEST_PLAN bölüm 6)

| Adım | Sonuç | Craftgate ödeme no | Not |
|---|---|---|---|
| S1 başarılı kart | | | |
| S2 reddedilen kart | | | |
| S3 terk edilen 3DS | | | |
| S4 müşteri onayı → serbest bırakma | | | |
| S5 iptal → tam iade | | | |
| S6 şikayet → tam iade | | | |
| S7 şikayet → %50/%50 | | | |
| S8 şikayet → ustaya aktar | | | |
| S9 çift deneme | | | |

### A.6 İşlevsel olmayan ölçümler

| Ölçüt | Hedef | Ölçülen | Yöntem | Sonuç |
|---|---|---|---|---|
| API okuma gecikmesi (p95) | < 500 ms | | | |
| Erişilebilirlik | ≥ %99,5 | | | |
| İlk talep süresi | < 3 dk | | `USABILITY_STUDY.md` | |
| Teklif hazırlama süresi | < 90 sn | | `USABILITY_STUDY.md` | |
| Yardımsız görev başarısı | ≥ %80 | | `USABILITY_STUDY.md` | |

### A.7 Kusur günlüğü

Önem: **Kritik** (para/veri kaybı, güvenlik), **Yüksek** (ana akış kırık), **Orta** (geçici çözümü var), **Düşük** (kozmetik). Durum: Açık / Düzeltildi / Kapalı / Düzeltilmeyecek.

| Kusur no | Tarih | İşlem | Bileşen | İlgili senaryo | Adımlar | Beklenen | Gerçekleşen | Önem | Durum | Düzeltme işlemi | Doğrulayan test |
|---|---|---|---|---|---|---|---|---|---|---|---|
| D-001 | | | | | | | | | | | |
| D-002 | | | | | | | | | | | |

### A.8 Sonuç ve çıkış kriterleri

| Çıkış kriteri (`TEST_PLAN.md` 4) | Karşılandı mı | Kanıt / not |
|---|---|---|
| Tüm otomatik paketler yeşil | | |
| Yüksek öncelikli UC'lerin her biri için test ya da kanıtlı elle koşu | | |
| Açık Kritik/Yüksek kusur yok | | |
| Sandbox senaryoları koşuldu | | |
| Kullanılabilirlik çalışması yapıldı ve ≥ %80 ya da gerekçeli sapma | | |

Bilinen sınırlamalar ve riskler:

1.
2.

---

## Bölüm B — İlk koşu: 16 Kasım 2026

### B.1 Koşu bilgisi

| Alan | Değer |
|---|---|
| Rapor tarihi | 16.11.2026 |
| Dal ve işlem | `feature/flutter-app` @ `565bfb4` ("fix(mobile): complaint wording only after a decided complaint; login hides only a duplicate error") |
| Çalışma ağacı temiz mi | evet (belge çalışması yeni bir worktree'de, kod değişmedi) |
| Koşuyu yapan | Belge yazım çalışması sırasında otomatik koşu |
| İşletim sistemi | macOS 27.2.1 (Darwin 27.2.0) |
| Sürümler | OpenJDK 21.0.12.1, Spring Boot 4.1.2, PostgreSQL 16.13, Flutter 3.47.3 (stable; `flutter --version` çıktısı) |
| Test veritabanı | Yerel PostgreSQL üzerinde bu koşu için açılan boş veritabanı (`TEST_DB_URL` ile verildi); Docker yok, Testcontainers kullanılmadı |
| Craftgate | **Sahte ağ geçidi** (Mockito); gerçek sandbox bu koşuda çağrılmadı |

### B.2 Otomatik paketler

| Paket | Komut | Toplam | Geçti | Kaldı | Atlandı | Süre | Not |
|---|---|---|---|---|---|---|---|
| backend | `cd backend && TEST_DB_URL=... ./mvnw -B test` | 308 | 308 | 0 | 0 | 2 dk 59 sn | `BUILD SUCCESS` |
| apps/mobile | `cd apps/mobile && flutter test` | 525 | 525 | 0 | 0 | ölçülmedi | |
| apps/admin | `cd apps/admin && flutter test` | 87 | 87 | 0 | 0 | ölçülmedi | |
| packages/bitadilat_ui | `cd packages/bitadilat_ui && flutter test` | 27 | 27 | 0 | 0 | ölçülmedi | |
| packages/bitadilat_api | `cd packages/bitadilat_api && flutter test` | 101 | 101 | 0 | 0 | ölçülmedi | |
| **Toplam** | | **1048** | **1048** | **0** | **0** | | |

> Not: backend testleri her bağlamda veritabanını `flyway.clean()` ile sıfırlar; bu yüzden koşu, geliştirme veritabanından ayrı, boş bir veritabanına yönlendirilmiştir.

### B.3 Sınıf / dosya bazında dağılım

**backend (308)**

| Sınıf | Test | Sınıf | Test |
|---|---|---|---|
| `admin.AdminAccountPaymentTest` | 8 | `payment.PaymentAppTest` | 21 |
| `admin.AdminApplicationTest` | 9 | `payment.PaymentFlowTest` | 37 |
| `admin.AdminComplaintTest` | 22 | `payment.PaymentSweeperTest` | 16 |
| `admin.AdminDevSeedTest` | 3 | `payment.PrototypeApiDisabledTest` | 4 |
| `admin.NotificationCenterTest` | 11 | `payment.gateway.CraftgateGatewayTest` | 4 |
| `auth.AuthFlowTest` | 27 | `payment.service.CardValidatorTest` | 6 |
| `auth.AuthHardeningTest` | 10 | `pro.ProFlowTest` | 8 |
| `catalog.CatalogTest` | 4 | `request.RequestFlowTest` | 13 |
| `chat.ChatTest` | 9 | `user.AccountTest` | 14 |
| `common.CommonRulesTest` | 5 | `job.JobFlowTest` | 21 |
| `common.ProdProfileConfigTest` | 5 | `media.MediaTest` | 6 |
| `common.Wave3CarryOverTest` | 6 | `offer.OfferFlowTest` | 17 |
| `dev.DevJobSeedTest` | 9 | `dev.DevProfileGuardTest` | 4 |
| `dev.DevSeedTest` | 9 | | |

**apps/mobile (525)**: `audit_wave2_test` 21, `auth_screens_test` 43, `chat_wave3_test` 24, `customer_wave2_test` 45, `jobs_wave3_test` 113, `notifications_wave4_test` 116, `payment_wave3_test` 43, `platform_config_test` 10, `pro_wave2_test` 35, `router_guards_test` 26, `secure_token_store_test` 6, `session_audit_test` 9, `typography_guard_test` 1, `ui_fixes_wave5_test` 14, `wave3_extras_test` 19.

**apps/admin (87)**: `accounts_payments_test` 16, `applications_test` 18, `auth_test` 10, `complaints_test` 20, `labels_test` 2, `layout_l10n_test` 21.

**packages/bitadilat_ui (27)**: `components_test` 14, `contrast_test` 3, `prefix_field_test` 3, `typography_theme_test` 7.

**packages/bitadilat_api (101)**: `admin_test` 15, `api_test` 14, `auth_interceptor_audit_test` 14, `notifications_test` 10, `wave2_test` 30, `wave3_test` 18.

### B.4 Senaryo bazında durum (TEST_CASES.md, 16.11.2026 itibarıyla)

| Durum | Adet |
|---|---|
| Otomatik, geçti | 118 |
| Kısmi | 7 |
| Boşluk | 7 |
| Elle, bekliyor | 11 |
| Gerçekleştirilmedi | 4 |
| **Toplam senaryo** | **147** |

(Sayılar `TEST_CASES.md` satırlarından sayılmıştır; satır durumları değiştikçe güncellenmelidir. Elle senaryoların hiçbiri bu koşuda yapılmadı.)

### B.5 Sandbox ödeme koşusu

Bu koşuda yapılmadı (bkz. A.5). Proje sahibi 16 Kasım 2026'da gerçek Craftgate sandbox ile uçtan uca bir koşu yaptığını bildirmiştir; depoda bunun kanıtı yoktur. Kanıtlı koşu 25 Aralık'a kadar tekrarlanacaktır.

### B.6 İşlevsel olmayan ölçümler

| Ölçüt | Hedef | Ölçülen | Sonuç |
|---|---|---|---|
| API okuma gecikmesi (p95) | < 500 ms | ölçülmedi (betik yok) | Boşluk |
| Erişilebilirlik | ≥ %99,5 | ölçülmedi (sağlık uç noktası yok) | Boşluk |
| İlk talep / teklif süresi | 3 dk / 90 sn | ölçülmedi | Boşluk |
| Yardımsız görev başarısı | ≥ %80 | çalışma yapılmadı | Boşluk |

### B.7 Kusur günlüğü

Bu koşuda otomatik testlerde **kusur çıkmadı**. Aşağıdakiler test başarısızlığı değil, belge yazımı sırasında koddan gözlenen noktalardır; düzeltme kararı proje sahibine aittir.

| No | Gözlem | Konum | Önem (öneri) | Durum |
|---|---|---|---|---|
| G-001 | 3DS callback imza doğrulaması `craftgate.callback-key` boşsa atlanıyor (`isCallbackAuthentic` `true` döner). Karar yine Craftgate sorgusuna dayanıyor (`forgedSuccessIsDecidedByCraftgateNotByParams`), ama anahtar tanımlı değilse ek savunma katmanı yok. Üretimde anahtarın zorunlu olması önerilir | `backend/.../payment/gateway/CraftgateGateway.java` | Orta | Açık |
| G-002 | `REJECTED → PENDING_REVIEW` (yeniden başvuru) kodda ve testte var, `docs/spec/STATE_MACHINES.md`'de yok | `ProService.submit`, `ProFlowTest` | Düşük (belge) | Açık |
| G-003 | Mobilde hesap silme ekranı ve geçmeyi doğrulayan widget testi yok (sunucu testi var) | `apps/mobile/test` | Orta (test boşluğu) | Açık |
| G-004 | Müşteri onayı ve 48 saat otomatik tamamlama Craftgate'e danışmadan defter kaydı yapar; bu bilinçli tasarım ama testi yok | `JobSettlement.complete` | Düşük (test boşluğu) | Açık |

### B.8 Sonuç

| Çıkış kriteri | Karşılandı mı | Not |
|---|---|---|
| Tüm otomatik paketler yeşil | Evet | 1048/1048 |
| Yüksek öncelikli UC'ler için test | Kısmen | UC14 yok; UC01–UC13 otomatik testli; elle ve sandbox koşuları bekliyor |
| Açık Kritik/Yüksek kusur yok | Evet | Bilinen kusur yok |
| Sandbox senaryoları koşuldu | Hayır | Kanıtlı koşu yok |
| Kullanılabilirlik çalışması | Hayır | Çalışma yapılmadı |

Bilinen sınırlamalar: otomatik testlerde ağ geçidi sahtedir; depoda otomatik uçtan uca test yoktur; Android ve Docker doğrulanmadı; gerçek cihaz yok, yalnızca Simulator.

---

## Bölüm C — Yeniden koşu: 19 Kasım 2026 (son kod)

Bölüm B'deki G-001, G-002, G-003 ve G-004 gözlemleri bu arada kapatıldı (aşağıda C.6).

### C.1 Koşu bilgisi

| Alan | Değer |
|---|---|
| Rapor tarihi | 19.11.2026 |
| Dal ve işlem | `feature/flutter-app` @ `c335a10` ("Merge worktree-agent-addbc2258b5721551: follow-up features and audit fixes") |
| Çalışma ağacı temiz mi | Evet; yalnızca izlenmeyen `.claude/` dizini var (`git status --short`) |
| Koşuyu yapan | Belge güncelleme çalışması sırasında otomatik koşu |
| İşletim sistemi | macOS 27.2.1 (Darwin 27.2.0) |
| Sürümler | OpenJDK 21.0.12.1, Spring Boot 4.1.2, PostgreSQL 16.13, Flutter 3.47.3 (Dart 3.13.3) |
| Test veritabanı | Bu koşu için açılan boş yerel veritabanı (`createdb`, `TEST_DB_URL` ile verildi), koşudan sonra silindi; Docker kurulu değil, Testcontainers kullanılmadı. Çalışan geliştirme veritabanına ve 8090 numaralı sunucuya dokunulmadı |
| Craftgate | **Sahte ağ geçidi**; gerçek sandbox bu otomatik koşuda çağrılmadı |

### C.2 Otomatik paketler

| Paket | Komut | Toplam | Geçti | Kaldı | Atlandı | Süre | Not |
|---|---|---|---|---|---|---|---|
| backend | `cd backend && TEST_DB_URL=... ./mvnw -q -B test` | 354 | 354 | 0 | 0 | Surefire toplamı 76 sn | çıkış kodu 0; 32 test sınıfı |
| apps/mobile | `cd apps/mobile && flutter test` | 567 | 567 | 0 | 0 | ölçülmedi | |
| apps/admin | `cd apps/admin && flutter test` | 95 | 95 | 0 | 0 | ölçülmedi | |
| packages/bitadilat_ui | `cd packages/bitadilat_ui && flutter test` | 27 | 27 | 0 | 0 | ölçülmedi | |
| packages/bitadilat_api | `cd packages/bitadilat_api && dart test` | 112 | 112 | 0 | 0 | ölçülmedi | |
| **Toplam** | | **1155** | **1155** | **0** | **0** | | Bölüm B'ye göre +107 test |

Backend sayıları `target/surefire-reports/TEST-*.xml` dosyalarından, Flutter ve Dart sayıları `--reporter json` çıktısındaki gizli olmayan `testDone` olaylarından alındı. `flutter analyze` bu koşuda yeniden çalıştırılmadı (CI iş akışında var).

### C.3 Sınıf / dosya bazında dağılım

**backend (354)**

| Sınıf | Test | Sınıf | Test |
|---|---|---|---|
| `admin.AdminAccountPaymentTest` | 8 | `payment.PaymentAppTest` | 21 |
| `admin.AdminApplicationTest` | 9 | `payment.PaymentFlowTest` | 37 |
| `admin.AdminComplaintTest` | 22 | `payment.PaymentSweeperTest` | 23 |
| `admin.AdminDevSeedTest` | 3 | `payment.PrototypeApiDisabledTest` | 4 |
| `admin.AdminPaymentReviewTest` | 10 | `payment.gateway.CraftgateGatewayTest` | 4 |
| `admin.NotificationCenterTest` | 11 | `payment.service.CardValidatorTest` | 6 |
| `auth.AuthFlowTest` | 27 | `pro.ProFlowTest` | 8 |
| `auth.AuthHardeningTest` | 10 | `prod.AdminBootstrapTest` | 3 |
| `catalog.CatalogTest` | 4 | `prod.ProdProfileContextTest` | 4 |
| `chat.ChatTest` | 9 | `prod.ProdReadinessUnitTest` | 4 |
| `common.CommonRulesTest` | 5 | `request.RequestFlowTest` | 13 |
| `common.ProdProfileConfigTest` | 5 | `user.AccountTest` | 22 |
| `common.Wave3CarryOverTest` | 6 | `job.JobFlowTest` | 20 |
| `dev.DevJobSeedTest` | 9 | `job.EscrowSafetyTest` | 11 |
| `dev.DevProfileGuardTest` | 4 | `media.MediaTest` | 6 |
| `dev.DevSeedTest` | 9 | `offer.OfferFlowTest` | 17 |

**apps/mobile (567)**: `account_features_test` 16, `audit_wave2_test` 21, `auth_screens_test` 43, `chat_wave3_test` 24, `customer_wave2_test` 45, `followup_test` 18, `jobs_wave3_test` 113, `notifications_wave4_test` 120, `payment_wave3_test` 43, `platform_config_test` 14, `pro_wave2_test` 35, `router_guards_test` 26, `secure_token_store_test` 6, `session_audit_test` 9, `typography_guard_test` 1, `ui_fixes_wave5_test` 14, `wave3_extras_test` 19.

**apps/admin (95)**: `accounts_payments_test` 16, `applications_test` 18, `auth_test` 12, `complaints_test` 20, `labels_test` 2, `layout_l10n_test` 21, `payment_review_test` 6.

**packages/bitadilat_ui (27)**: `components_test` 14, `contrast_test` 3, `prefix_field_test` 3, `typography_theme_test` 7.

**packages/bitadilat_api (112)**: `admin_test` 15, `api_test` 17, `auth_interceptor_audit_test` 14, `followup_test` 8, `notifications_test` 10, `wave2_test` 30, `wave3_test` 18.

### C.4 Senaryo bazında durum (TEST_CASES.md, 19.11.2026 itibarıyla)

| Durum | Adet |
|---|---|
| Otomatik, geçti | 139 |
| Kısmi | 8 |
| Boşluk | 4 |
| Elle, yapıldı (kanıt: bu bölüm) | 5 |
| Elle, bekliyor | 11 |
| Gerçekleştirilmedi | 3 |
| Gerçekleştirildi, otomatik test yok (tanıtım sitesi) | 1 |
| **Toplam senaryo** | **171** |

(Sayılar `TEST_CASES.md` satırlarından sayılmıştır; satır durumları değiştikçe güncellenmelidir.)

### C.5 Uçtan uca doğrulamalar (elle)

Bu doğrulamalar otomatik değildir; yalnızca yapıldıklarının ve sonucun kaydıdır. Ekran görüntüsü ve ayrıntılı işlem kaydı **depoda yoktur**; 25 Aralık'a kadar kanıtla tekrarlanacaktır.

| No | Doğrulama | Ortam | Tarih | Sonuç |
|---|---|---|---|---|
| E1 | Yönetim paneli (Flutter Web) başsız Chromium'da, yerel backend ile | başsız Chromium, backend `dev` profili | Kasım 2026 | Yapıldı |
| E2 | Mobil bildirimler (bildirim merkezi) iOS Simulator'da | iOS Simulator | Kasım 2026 | Yapıldı |
| E3 | Gerçek Craftgate sandbox iade senaryoları: bölüşüm (%50/%50), tam iade, kısmi iade + kalanın iadesi, iadeden sonra ustaya aktarımın reddi | Craftgate sandbox; ödeme numaraları 3275432, 3275434, 3275436, 3281697 | Kasım 2026 | Yapıldı; beklenen davranış gözlendi (iade edilmiş ödeme ustaya aktarılmadı, kalan tutar bir kez iade edildi) |

Kapsam sınırı: sandbox'ta ret, 3DS terk ve çift deneme (`TEST_PLAN.md` S2, S3, S9) bu doğrulamalarda **koşulmadı**. Docker imajı derlenmedi ve çalıştırılmadı (Docker bu makinede kurulu değil), Android APK derlenmedi, GitHub Actions uzak depoda koşturulmadı, `prod` profili gerçek SMTP ile denenmedi.

### C.6 Kusur günlüğü

Bu koşuda otomatik testlerde **kusur çıkmadı**. Bölüm B gözlemlerinin durumu:

| No | Gözlem | Durum |
|---|---|---|
| G-001 | Callback imza doğrulaması anahtar boşsa atlanıyordu | **Düzeltildi** (prod'da `CRAFTGATE_CALLBACK_KEY` zorunlu, boşsa açılış reddedilir; `ProdReadinessUnitTest#validatorRequiresCallbackKeyAndRejectsWildcardCors`). `dev` profilinde hâlâ isteğe bağlı |
| G-002 | `REJECTED → PENDING_REVIEW` spec'te yoktu | **Kapandı** (`STATE_MACHINES.md` güncellendi) |
| G-003 | Mobil hesap silme testi yoktu | **Kapandı** (`account_features_test` "Ayarlar: hesap silme") |
| G-004 | Onay ve otomatik tamamlama Craftgate'e danışmıyordu | **Kapandı** (aktarım öncesi iade kontrolü; `EscrowSafetyTest`) |

Yeni gözlemler: yasal metin kopyaları (`docs/legal`, `website/legal`, uygulama varlıkları) elle eşitleniyor; uygulama kopyası testle korunuyor (`followup_test`), site kopyası için denetim yok (Düşük). **Açık:** bu güncellemede `docs/legal/*.md` düzeltildi ama `apps/mobile/assets/legal/*.md` kopyaları kod alanı olduğu için eşitlenmedi; eşitlenene kadar mobilde `followup_test` "uygulamadaki kopyalar docs/legal ile aynı" testi **kırmızı** olur (C.2'deki sayılar bu eşitlemeden önceki koşuya aittir). Eşitleme: `cp docs/legal/*.md apps/mobile/assets/legal/`. İnceleme sırasında yasal metin ve tanıtım sitesinde şu olgusal hatalar bulunup düzeltildi: kart bilgilerinin Craftgate'in sayfasında girildiği (kart uygulamadaki formdan sunucu üzerinden Craftgate'e iletilir, saklanmaz), cihaz belirtecinin bildirim göndermek için kullanıldığı (push yok), "bildirim hizmeti sağlayıcısı" ifadesi (yok; e-posta sağlayıcısı var) ve iptalin "usta adrese ulaşana kadar" olduğu (iş başlayana kadar).

### C.7 Sonuç

| Çıkış kriteri | Karşılandı mı | Not |
|---|---|---|
| Tüm otomatik paketler yeşil | Evet | 1155/1155 |
| Yüksek öncelikli UC'ler için test | Evet | UC01–UC13 otomatik testli; UC14 (site) otomatik testsiz, elle gözden geçirildi |
| Açık Kritik/Yüksek kusur yok | Evet | Bilinen kusur yok |
| Sandbox senaryoları koşuldu | Kısmen | İade ve aktarım senaryoları koşuldu; ret, terk, çift deneme koşulmadı |
| Kullanılabilirlik çalışması | Hayır | Çalışma yapılmadı |
