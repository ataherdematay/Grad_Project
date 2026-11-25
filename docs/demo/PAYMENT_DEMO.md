# Ödeme sistemi canlı demosu (10-15 dakika)

[English version](PAYMENT_DEMO.en.md)

Bu doküman, BiTadilat ödeme sistemini hocaya canlı göstermek için adım adım senaryodur. Ödemeler **gerçek Craftgate sandbox** ortamından geçer: kart formu, bankanın 3D Secure (SMS) sayfası, Craftgate ödeme numarası ve iade gerçek sandbox çağrılarıdır. Gerçek para çekilmez.

Gösterilenler:

- müşteri tarafında **Paranın yolculuğu** zaman çizelgesi,
- **Makbuz**,
- **Ödemelerim**,
- usta tarafındaki zaman çizelgesi (kart bilgisi görünmez, hizmet bedeli ve net kazanç görünür),
- admin panelinde **güvence havuzu özeti** ve **ödeme zaman çizelgesi**,
- 48 saatlik otomatik aktarımı saniyeler içinde gösteren **demo saati** (fast-forward).

Bu senaryo 26 Kasım 2026'da iPhone 18 Pro simülatöründe ve admin web derlemesinde baştan sona çalıştırıldı. Ekran görüntüleri o çalıştırmadan alındı ([img/](img/)).

Kavramsal anlatım için sunum sayfalarına bakın:

- [docs/sunum/1-odeme-akisi.html](../sunum/1-odeme-akisi.html): akış tablosu ve sahtekârlık önlemleri.
- [docs/sunum/2-para-haritasi.html](../sunum/2-para-haritasi.html): etkileşimli para haritası. Demonun açılışında 1 dakikalık giriş için uygun.
- [docs/sunum/3-odeme-animasyonu.html](../sunum/3-odeme-animasyonu.html): 11 sahnelik animasyon.

## Kısa akış

| Dakika | Adım | Para nerede |
|---|---|---|
| 0-1 | Para haritası sayfasıyla giriş | - |
| 1-6 | **A. Mutlu yol:** teklif kabul, gerçek 3DS ödeme, makbuz, teslim, müşteri onayı | Kart, sonra güvence havuzu, sonra usta |
| 6-9 | **B. 48 saat:** ikinci ödeme, teslim, müşteri onaylamıyor, demo saati | Güvence havuzu, sonra otomatik olarak usta |
| 9-12 | **C. İptal ve iade:** üçüncü ödeme, iptal, gerçek Craftgate iadesi | Güvence havuzu, sonra müşterinin kartı |
| 12-15 | **D. Admin paneli:** özet kartları, ödeme zaman çizelgesi, sorular | - |

## 1. Hazırlık (derse gelmeden önce, yaklaşık 15 dakika)

### 1.1 Backend

PostgreSQL açık olmalı. Kurulum ve diğer seçenekler için [docs/RUNNING.md](../RUNNING.md).

```bash
cd backend
export CRAFTGATE_API_KEY=<sandbox API anahtarı>        # değeri dokümana veya depoya yazmayın
export CRAFTGATE_SECRET_KEY=<sandbox gizli anahtarı>
./mvnw spring-boot:run                                  # dev profili, http://127.0.0.1:8090
```

- Log'da `Started BitadilatApplication` görünmeli.
- `CRAFTGATE_CALLBACK_KEY tanımlı değil` uyarısı dev ortamında normaldir. Ödeme sonucu yine Craftgate API'sinden doğrulanır.
- Anahtar `sandbox-demo` ile başlıyorsa Craftgate'e hiç gidilmez (sahte mod). Bu demo için gerçek sandbox anahtarı kullanın; o zaman zaman çizelgesinde sağlayıcı `CRAFTGATE` görünür.

### 1.2 Demo verisini sıfırla

```bash
curl -X POST http://localhost:8090/api/v1/dev/reset     # 204 döner
```

### 1.3 Hesaplar

Tüm demo şifreleri `Demo1234!` (yalnızca dev seed'i, [docs/spec/SEED_DATA.md](../spec/SEED_DATA.md)).

| Rol | E-posta | Nerede |
|---|---|---|
| Müşteri | `ali@bitadilat.test` | iOS simülatörü |
| Usta (Mavi Hat Tesisat) | `mehmet@bitadilat.test` | Simülatör veya terminal |
| Admin | `admin@bitadilat.test` | Yalnızca web paneli |

### 1.4 Mobil uygulama (iOS simülatörü)

```bash
cd apps/mobile
flutter build ios --simulator --debug --dart-define=API_BASE_URL=http://localhost:8090
xcrun simctl boot "iPhone 18 Pro"          # açık değilse
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted com.bitadilat.app
```

- Giriş ekranında **Türkçe**'yi seçin ve Ali ile giriş yapın.
- iOS "Save Password?" sorarsa **Not Now** deyin.

### 1.5 Admin paneli

```bash
cd apps/admin
flutter build web --dart-define=API_BASE_URL=http://localhost:8090
python3 -m http.server 8093 --bind 127.0.0.1 --directory build/web
```

Tarayıcıda `http://127.0.0.1:8093` açın ve admin ile giriş yapın. 3000 numaralı portu kullanmayın, başka bir projeye ait.

### 1.6 Teklifleri önceden hazırla (terminal yardımcıları)

Talep sihirbazı ve usta teklif ekranı derste zaman alır. Üç senaryonun taleplerini ve tekliflerini önceden API ile açın. Aşağıdaki blok bir terminale bir kez yapıştırılır:

```bash
B=http://localhost:8090/api/v1
tok(){ curl -s $B/auth/login -H 'content-type: application/json' \
  -d "{\"identifier\":\"$1@bitadilat.test\",\"password\":\"Demo1234!\"}" | python3 -c 'import sys,json;print(json.load(sys.stdin)["accessToken"])'; }
api(){ local t=$1 m=$2 p=$3; shift 3; curl -s -X $m "$B$p" -H "authorization: Bearer $t" -H 'content-type: application/json' "$@"; }
# teklif <başlık> <işçilik> <malzeme>: Ali talep açar, Mehmet teklif verir
teklif(){ local A=$(tok ali) M=$(tok mehmet)
  local addr=$(api $A GET /me/addresses | python3 -c 'import sys,json;print(json.load(sys.stdin)[0]["id"])')
  local req=$(api $A POST /requests -d "{\"categoryId\":\"plumbing\",\"urgency\":\"URGENT\",\"title\":\"$1\",\"description\":\"Lavabonun altindan surekli su damliyor, dolap islandi.\",\"addressId\":\"$addr\",\"photoIds\":[],\"answers\":[]}" | python3 -c 'import sys,json;print(json.load(sys.stdin)["id"])')
  local f=$(python3 -c 'import datetime as d;print((d.datetime.now(d.timezone.utc)+d.timedelta(hours=3)).strftime("%Y-%m-%dT%H:00:00Z"))')
  local t=$(python3 -c 'import datetime as d;print((d.datetime.now(d.timezone.utc)+d.timedelta(hours=6)).strftime("%Y-%m-%dT%H:00:00Z"))')
  api $M POST /pro/requests/$req/offers -d "{\"laborAmount\":$2,\"materialsAmount\":$3,\"arrivalFrom\":\"$f\",\"arrivalTo\":\"$t\",\"warrantyMonths\":6,\"note\":\"Sifon ve conta degisimi.\",\"items\":[]}" >/dev/null
  echo "talep $req hazır"; }
# isler: Ali'nin aktif işleri (id, kod, başlık, durum)
isler(){ api $(tok ali) GET "/jobs?as=CUSTOMER&scope=active" | python3 -c 'import sys,json;[print(j["id"],j["publicCode"],j["title"],j["status"]) for j in json.load(sys.stdin)["items"]]'; }
# usta_bitir <jobId>: usta randevu önerisini kabul eder, adrese varır, başlar, bitirir
usta_bitir(){ local M=$(tok mehmet)
  local p=$(api $M GET /jobs/$1 | python3 -c 'import sys,json;print(json.load(sys.stdin)["appointment"]["pendingProposal"]["id"])')
  api $M POST /jobs/$1/appointment/proposals/$p/accept >/dev/null; api $M POST /jobs/$1/arrived >/dev/null; api $M POST /jobs/$1/start >/dev/null
  api $M POST /jobs/$1/finish -d '{"note":"Sifon ve conta degistirildi, kacak giderildi.","photoIds":[]}' | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["status"],"otomatik onay:",d["autoCompleteAt"])'; }
# hizlandir <jobId>: 48 saati şimdi doldurur (yalnızca dev profili, yalnızca 127.0.0.1)
hizlandir(){ api $(tok ali) POST /dev/jobs/$1/payment/fast-forward; echo; }
```

Sonra:

```bash
teklif "Mutfak lavabosu su kacagi" 900 300        # A: 1.200 TL
teklif "Banyo bataryasi damlatiyor" 650 150       # B: 800 TL
teklif "Klozet rezervuari su kaciriyor" 400 100   # C: 500 TL
```

### 1.7 Kontrol listesi

- [ ] `curl -s -o /dev/null -w '%{http_code}' -X POST localhost:8090/api/v1/dev/reset` 204 verdi, ardından teklifler açıldı.
- [ ] Simülatörde Ali'nin ana sayfasında üç açık talep var, her birinde "1 teklif geldi" yazıyor.
- [ ] Admin panelinde **Ödemeler** sayfası açılıyor.
- [ ] İnternet var (Craftgate sandbox ve 3DS sayfası dışarıda).

**Başlangıç değerleri (reset sonrası, admin özetinde):** güvence havuzunda ₺3.400, ustalara aktarılan ₺7.785, müşterilere iade edilen ₺0, kazanılan hizmet bedeli ₺865, toplam ödeme 13, tohum veri 13. Bunlar seed ödemeleridir (sağlayıcı `SEED`, Craftgate'e gitmez).

## 2. Senaryo A: mutlu yol (5-6 dakika)

| # | Ne tıklanır | Ekranda ne görülür | Para nerede |
|---|---|---|---|
| A1 | Ana sayfa, "Mutfak lavabosu su kacagi" kartında **Teklifleri gör (1)**, sonra Mavi Hat Tesisat teklifi | Teklif dökümü: İşçilik ₺900, Malzeme ₺300, Toplam ₺1.200 | Müşterinin kartında |
| A2 | **Teklifi kabul et** | "Ödemen güvence havuzunda tutulur" açıklaması ve iptal politikası ([img/01](img/01-teklif-kabul.png)) | Kartında |
| A3 | **Ödemeye geç**, sonra **Test kartını doldur** (yalnızca debug derlemesinde görünür) | Kart: `5258 6400 0000 0001`, `07/44`, CVC `000` ([img/02](img/02-kart-formu.png)) | Kartında |
| A4 | **₺1.200 öde** | Craftgate'in sandbox SMS sayfası açılır. Kod sayfada parantez içinde yazar ([img/03](img/03-3ds-banka.png)) | Banka doğruluyor |
| A5 | Sayfadaki 6 haneli kodu yazın (6. hanede kendiliğinden gönderilir) | Uygulama **Randevu** ekranına geçer. **Randevu iste** deyin | **Güvence havuzunda** |
| A6 | İş detayını aşağı kaydırın, **Paranın yolculuğu** kartına dokunun | "Para şu an: Güvence havuzunda", üç düğüm (Kart ✓, Güvence havuzu, Usta) ve Hareketler: Ödeme başlatıldı, Banka doğrulaması başladı, Tutar güvence havuzuna alındı ([img/04](img/04-yolculuk-havuzda.png)) | Güvence havuzunda |
| A7 | **Makbuzu gör** | Sandbox uyarısı, makbuz no `BT-yyyyMMdd-XXXXXX`, kalemler, `Mastercard •••• 0001`, "Para şu an" ([img/09](img/09-makbuz.png)) | Güvence havuzunda |
| A8 | Terminal: `isler`, sonra `usta_bitir <A'nın jobId'si>` | İş detayında aşağı çekip yenileyin: "Onayın bekleniyor", "Onaylamazsan ... tarihinde otomatik onaylanır". Yolculukta **Otomatik aktarıma kalan süre 48 sa 0 dk** ([img/05](img/05-geri-sayim.png)) | Güvence havuzunda |
| A9 | **Teslimi onayla**, **Onayla**, **Onayla ve aktar** ([img/06](img/06-teslim-onayi.png)). Puanlama ekranında **Şimdi değil** | İş "Tamamlandı" | **Ustada** |
| A10 | Profil, **Ödemelerim**, "Mutfak lavabosu" | "Para şu an: Ustada"; hareketlerin sonunda İşi onayladın, Tutar ustaya aktarıldı ([img/07](img/07-yolculuk-ustada.png), [img/08](img/08-hareketler.png), [img/10](img/10-odemelerim.png)) | Ustada |

Hocaya söylenecekler:

- Tutar sunucuda tekliften alınır; uygulama tutar göndermez. Kart numarası saklanmaz, yalnızca marka ve son 4 hane tutulur.
- Müşteri hizmet bedelini ve ustanın payını görmez (GLOSSARY kuralı). Makbuzda hizmet bedeli dökümü yoktur.
- Ustaya aktarmadan önce sunucu Craftgate'e "bu ödemede iade var mı?" diye sorar. İade varsa para çıkmaz ve ödeme incelemeye düşer.

**Usta tarafı (isteğe bağlı, yaklaşık 1 dakika):** Profil, Ayarlar, **Çıkış yap**; Mehmet ile giriş yapın; İşlerim, Geçmiş, "Mutfak lavabosu", Paranın yolculuğu.

- "Para şu an: **Sende**". Düğümler: Müşteri, Güvence havuzu, Sen.
- Tutarlar: Toplam ₺1.200, **Hizmet bedeli (%10) ₺120**, **Net kazancın ₺1.080**.
- **Kart satırı ve makbuz düğmesi yoktur** ([img/14](img/14-usta-yolculuk.png), [img/15](img/15-usta-hareketler.png)).
- Usta makbuzu API'den isterse `403 FORBIDDEN` alır.

Admin panelinde bu ödemenin satırına tıklayın: sağlayıcı **Craftgate**, **Craftgate ödeme no** (ör. `3302829`) ve maskeli kart görünür ([img/17](img/17-admin-zaman-cizelgesi.png)).

## 3. Senaryo B: müşteri onaylamazsa, 48 saat (3 dakika)

| # | Ne yapılır | Ne görülür | Para nerede |
|---|---|---|---|
| B1 | Simülatörde Ali ile "Banyo bataryasi damlatiyor" teklifini A1-A5'teki gibi ödeyin (₺800) ve randevu isteyin | Randevu ekranı | Güvence havuzunda |
| B2 | Terminal: `isler`, sonra `usta_bitir <B'nin jobId'si>` | `WORK_FINISHED otomatik onay: <48 saat sonrası>` | Güvence havuzunda |
| B3 | Yolculuk ekranını gösterin | "Otomatik aktarıma kalan süre 48 sa 0 dk" | Güvence havuzunda |
| B4 | Terminal: `hizlandir <B'nin jobId'si>` | `{"jobStatus":"COMPLETED","escrowStatus":"RELEASED_TO_PRO","moneyLocation":"PRO","released":true,...}` | **Ustada** |
| B5 | Yolculuğu aşağı çekip yenileyin | Hareketlerin sonunda **48 saat doldu, sistem onayladı** ve **Tutar ustaya aktarıldı** ([img/11](img/11-otomatik-aktarim.png)) | Ustada |

Hocaya söylenecekler:

- Demo saati yalnızca o işin "otomatik onay zamanı"nı şimdiye çeker ve gerçek 48 saat zamanlayıcısının yolunu çalıştırır (`JobScheduler`, `releaseChecked`). Craftgate iade kontrolü atlanmaz.
- Uç nokta yalnızca `dev` profilinde ve 127.0.0.1'den çalışır. Prod'da yoktur (404).
- İkinci çağrı `409 ILLEGAL_STATE` döner; para iki kez aktarılmaz.

## 4. Senaryo C: iptal ve gerçek Craftgate iadesi (3 dakika)

| # | Ne yapılır | Ne görülür | Para nerede |
|---|---|---|---|
| C1 | "Klozet rezervuari su kaciriyor" teklifini ödeyin (₺500). Randevu ekranında geri çıkın | İş "Randevu bekleniyor" | Güvence havuzunda |
| C2 | İş detayının en altında **İşi iptal et**, bir gerekçe seçip onaylayın | İş "İptal edildi" | **Kartına iade edildi** |
| C3 | Paranın yolculuğu | "Para şu an: Sana iade edildi". Tutarlar: Toplam ₺500, **İade edilen ₺500**. Hareketler: İade talep edildi ₺500, Tutar kartına iade edildi ₺500 ([img/12](img/12-iade.png), [img/13](img/13-iade-hareketleri.png)) | Müşterinin kartında |
| C4 | Ödemelerim | Satırda "Kartına iade edildi", "İade edilen: ₺500" | Kartında |

Terminalden göstermek isterseniz iptal şu komutla da yapılabilir:

```bash
api $(tok ali) POST /jobs/<jobId>/cancel -d '{"reason":"PLANS_CHANGED"}'
```

Backend log'unda gerçek iade satırı görünür:

```
Tam iade yapıldı. paymentId=... refundId=... type=CANCEL status=SUCCESS amount=500.00
```

Hocaya söylenecekler:

- İptal ve iade niyeti tek işlemde kaydedilir. Craftgate'e iade çağrısı işlem kaydedildikten sonra yapılır (outbox).
- Craftgate cevap vermezse iade arka planda yeniden denenir (5 dakikadan 6 saate kadar artan aralıkla). Her denemede önce "ne kadarı zaten iade edildi" sorulur, böylece iade iki kez yapılmaz.

## 5. Senaryo D: admin paneli (2-3 dakika)

**Ödemeler** sayfasının üstünde **Güvence havuzu özeti** vardır ([img/16](img/16-admin-ozet.png)). A, B ve C'den sonra beklenen değerler:

| Kart | Hesap | Beklenen |
|---|---|---|
| Güvence havuzunda bekleyen | Seed LOCKED ₺1.200 + seed DISPUTED ₺2.200 | **₺3.400** (Kilitli + itirazlı: 1 + 1) |
| Ustalara aktarılan | Seed ₺7.785 + A ₺1.080 + B ₺720 | **₺9.585** |
| Müşterilere iade edilen | C ₺500 | **₺500** |
| Kazanılan hizmet bedeli | Seed ₺865 + A ₺120 + B ₺80 | **₺1.065** |
| Çipler | | Toplam ödeme 16, Havuzda 2, Aktarılan 13, İade 1, Başarısız 0, Tohum veri 13 |

- Bir 3DS denemesi yarıda kaldıysa ya da yanlış SMS kodu girildiyse "Başarısız" çipi 1 artar. Bu beklenen bir durumdur; toplamlar değişmez.
- Satıra tıklayınca sağda **Ödeme zaman çizelgesi** paneli açılır: para şu an nerede, brüt, hizmet bedeli, usta net, iade, Craftgate ödeme no, maskeli kart ve tüm olaylar (hangi rol, ne zaman, ne kadar). İade örneği: [img/18](img/18-admin-iade.png).
- Durum süzgeci (ör. "Ustaya aktarıldı") seçilince o duruma ait defter toplamları da görünür.

## 6. Paranın yeri, tek bakışta

| Durum (`status`) | Para nerede (`moneyLocation`) | Müşteri ekranı | Usta ekranı |
|---|---|---|---|
| Ödeme öncesi | `CUSTOMER_CARD` | Kartında | Müşterinin kartında |
| `LOCKED` | `BITADILAT_VAULT` | Güvence havuzunda | Güvence havuzunda |
| `DISPUTED` (şikayet) | `BITADILAT_VAULT` | Güvence havuzunda (şikayet nedeniyle bekliyor) | Aynı |
| `RELEASED_TO_PRO` | `PRO` | Ustada | Sende |
| `REFUNDED_TO_CUSTOMER` | `CUSTOMER_REFUNDED` | Sana iade edildi | Müşteriye iade edildi |
| `SPLIT_SETTLED` (admin 50/50 kararı) | `SPLIT` | Bölüşüldü | Bölüşüldü |

## 7. Olası sorunlar ve çözümleri

| Belirti | Neden | Çözüm |
|---|---|---|
| Backend açılmıyor, "CRAFTGATE_API_KEY" hatası | Anahtar ortam değişkeni yok | Terminalde iki anahtarı `export` edin. Değerleri dokümana yazmayın |
| **₺… öde**'den sonra hata, `GATEWAY_ERROR` | İnternet yok ya da Craftgate sandbox erişilemiyor | Bağlantıyı kontrol edin, tekrar deneyin |
| `PAYMENT_IN_PROGRESS` (409) | Aynı talepte yarım kalmış 3DS denemesi var | 10 dakika sonra yeni deneme kabul edilir. Ya da `teklif` ile yeni talep açın |
| Ödeme "başarısız / PAYMENT_DECLINED" | SMS kodu yanlış girildi ya da sayfa kapatıldı | Aynı tekliften tekrar ödeyin; talep açık kalır |
| SMS sayfası boş ya da dönmüyor | WebView dış ağa çıkamıyor | Simülatörün internetini kontrol edin; Safari'de `https://sandbox-api.craftgate.io` açılıyor mu bakın |
| Simülatörde tıklama ya da yazı gecikiyor | Simülatör girdileri gecikmeli | Adımlar arasında 1-2 saniye bekleyin, alanlara tek tek yazın |
| Ekran eski durumu gösteriyor | Önbellek | Sayfayı aşağı çekip yenileyin |
| `hizlandir` `409 ILLEGAL_STATE` | İş `WORK_FINISHED` değil, ikinci kez çağrıldı ya da şikayet açık | Önce `usta_bitir`; her iş için bir kez çağrılır |
| `hizlandir` `404` | Yanlış jobId ya da backend dev profilinde değil | `isler` ile id'yi alın; backend'i `./mvnw spring-boot:run` ile (dev) açın |
| `usta_bitir` "pendingProposal" hatası | Müşteri randevu istemedi | Simülatörde Randevu ekranında **Randevu iste**'ye basın |
| Admin girişi açılmıyor | Admin hesabı yalnızca web panelinde çalışır; CORS yalnızca localhost/127.0.0.1 | `http://127.0.0.1:8093` üzerinden açın |
| Zaman çizelgesinde sağlayıcı `DEMO` | Backend `sandbox-demo...` anahtarıyla açıldı | Gerçek sandbox anahtarlarıyla yeniden başlatın. Demo modunda yeniden başlatma iadeyi bozar |
| Özet kartları beklenenden farklı | Reset sonrası başka ödeme yapıldı | `dev/reset` ve `teklif` adımlarını tekrarlayın |

## 8. Teknik notlar

- Uç noktalar: `GET /jobs/{id}/payment/timeline`, `GET /jobs/{id}/payment/receipt`, `GET /me/payments`, `GET /admin/payments/summary`, `GET /admin/payments/{ref}/timeline`, `POST /dev/jobs/{id}/payment/fast-forward`. Sözleşme: [docs/spec/API_V1.md](../spec/API_V1.md), "payment demo" bölümü.
- Makbuz numarası `BT-<gün>-<ödeme ref'inin ilk 6 hanesi>` biçimindedir. Gün İstanbul saatine göredir, böylece makbuzdaki tarihle aynıdır.
- Rol görünürlüğü:
  - müşteri hizmet bedelini ve usta payını görmez,
  - usta kart bilgisini ve makbuzu görmez,
  - admin her şeyi görür.
