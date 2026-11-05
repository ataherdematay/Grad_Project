# BiTadilat Mobil Uygulama A-Z Denetimi

**Tarih:** 5 Kasım 2026
**Kod:** prototip ve backend için `develop` dalı (`0b3fc88`); Flutter için silinmeden önceki son hal `69607a0`.
**Durum:** yalnızca analiz. Bu çalışmada uygulama kodu değiştirilmedi.

## 1. Sonuç

**Prototip şu an gerçek ürün gibi çalışmıyor; tıklanabilir bir maket.** Tasarım kalitesi iyi. Sorun görünümde değil, akışta ve veride.

1. **Ana yolculuk kopuk.** Müşteri ekrandaki düğmelerle teslim onayına ulaşamıyor (adım 25'te bitiyor). Usta teklif gönderemiyor (adım 36'da bitiyor). Mesaj gönderme ve puanlama da çalışmıyor.
2. **Ortak iş kaydı yok.** Ödeme kaydı dışında hiçbir veri ekranlar arasında taşınmıyor. Müşteri ve usta birbirini etkilemiyor.
3. **Bilgiler ekrandan ekrana değişiyor.** Tek iş için 4 numara, 4 müşteri adı, 3 fiyat dökümü var.
4. **İngilizce mod bozuk.** 24 geçiş düğmesi çalışmıyor, metinler parçalanıyor.

Dört engelleyicinin (P1-P4) düzeltmesi küçük. Asıl büyük iş, gerçek ürün için ortak iş modeli ve backend.

### Flutter ne durumda?

Test sırasında eski `mobile/` klasörü bilinçli olarak silindi (`0b3fc88`, gerekçe: `docs/FLUTTER_RESTART_NOTES.md`). Bu nedenle Flutter bulguları **düzeltilecek hata değil, yeni yazımın kabul kriterleridir** (Bölüm 6).

## 2. Nasıl test edildi?

Ölçümler `scratch/audit/baseline/` klasöründe, scriptler `scratch/audit/` içinde. Düzeltmeden sonra aynı testler çalıştırılıp fark alınabilir.

| Test | Kapsam | Sonuç |
|---|---|---|
| Prototip tıklama, TR | 48 ekran, 436 öğe | 154 geçiş, 14 yalnız toast, 20 ekran değişikliği, 235 görünür etkisiz, 13 diğer (dil, dış bağlantı, seçim, kapalı) |
| Prototip tıklama, EN | Aynı 436 öğe | 24 geçiş düğmesi ölü, 2 düğme farklı ekrana gidiyor |
| Prototip ölçüm | 48 ekran | 5 ekranda JS hatası, yatay taşma yok, kırık görsel yok, 44 px altı 189 öğe |
| Ödeme akışı, gerçek sandbox | Başarı, iptal, serbest bırakma, tam ve %50 iade | Önceki turda geçti |
| Backend | 42 otomatik test | Geçti |
| Flutter tıklama (`69607a0`) | 33 ekran, 194 öğe, 390x844 | 96 geçiş, 7 yerel değişim, 91 görünür etkisiz |
| Flutter sıralı yolculuk | Müşteri, usta, çıkış, geçersiz adres | `baseline/journey_flutter.txt` |
| Flutter araçları | `flutter analyze`, `flutter test` | 127 uyarı, 1 smoke test geçti |
| Kod incelemesi | Prototip kontrolörü, Flutter, RAD | Rota haritası ve UC karşılaştırması |

**Etiketler:** `[T]` tıklanarak görüldü, `[K]` kodda okundu, `[Ç]` çıkarım.

**"Görünür etkisiz" her zaman hata demek değildir.** Form alanı, seçim kutusu ve metin değiştirmeyen seçimler de bu gruptadır. Sorun listesi bu sayılardan değil, ekranlar tek tek yorumlanarak çıkarıldı.

**Kanıt kısaltmaları:** `B:n` = `build_authoritative_prototype.py` satır n. `Sn:Lm` = adım n'in `preview/screens/<id>.html` dosyasında satır m (id'ler `screens_map.json` içinde). `sNN:m` = `69607a0` commit'inde `mobile/lib/features/screens/sNN_*.dart` satır m.

### Test edilemeyenler ve bilinmesi gerekenler

- Bu bilgisayarda Xcode ve Android emülatörü yok. Flutter yalnızca Chrome'da telefon boyutunda denendi; gerçek klavye, geri hareketi, çentik ve izinler denenmedi.
- Resmi başarısız test kartları denenmedi, liste Craftgate portalında giriş gerektiriyor. Kartın ilk adımda reddi yalnızca otomatik testle doğrulandı.
- Otomatik tıklamalar gerçek parmak hareketi değildir ve görsel yargılar gözlemimdir. Gerçek kullanıcı testinin yerini tutmaz.
- **Testin yan etkisi:** ilk tıklama turları 19. adımda iki kez sandbox 3DS başlattı (`3257973`, `3257977`). Banka adımı tamamlanmadığı için ödeme alınmadı; yerel veritabanında `INITIALIZED` kalan iki kayıt var. Depodaki scriptler tüm yazma isteklerini engeller, kayıtlı ölçümlerde engellenen istek sayısı sıfırdır.

## 3. Kırık yolculuklar

### Müşteri

`1 → 2 → 3 → 4 → 5-8 → 9 → 10 → 11 → 13 → 18 → 19 → banka → 21 → 22 → 23 → 25` **burada kopuyor**

| Olması gereken | Gerçekte | Etiket |
|---|---|---|
| 25 → 27 teslim onayı | Düğme yok. 27 ve 28 yalnızca simülatör listesinden açılıyor; serbest bırakma ve puanlama akışın dışında | `[T]` |
| 27 → 28 → puan ver | Yıldızlar ve "Yayınla" çalışmıyor; 28 çıkışsız | `[T]` |
| 22 → usta onayı → 23 | "Usta onayı bekleniyor"dan doğrudan "Randevun onaylandı"ya geçiyor | `[T]` |
| 23 → 24 mesaj | Gönder, ek ve kamera çalışmıyor | `[T]` |
| 26 iptal → müşteri sonucu | Müşteriyi usta ekranına (42) götürüyor | `[T]` |

### Usta

`1 → 33 → 34 → 35 → 36` **burada kopuyor**

| Olması gereken | Gerçekte | Etiket |
|---|---|---|
| 36 → 38 teklif gönder | Düğme çalışmıyor; 37 ve 38'e ulaşılamıyor | `[T]` |
| 33 belge yükleme | Yükleme düğmeleri ölü | `[T]` |
| 40 → sorun bildir | "Müşteri iptal etti" ekranına (42) gidiyor | `[T]` |
| Usta mesajlara girince | Rol müşteriye dönüyor, geri müşteri ekranına gidiyor | `[K]` |
| Teklif sonucu, işlerim listesi, kazanç | Ekranları yok | `[K]` |

### Yönetici

44-47'ye uygulama içinden ulaşılamıyor, giriş yok `[T]`. Reddet, eksik belge ve şikayeti kapat çalışmıyor `[T]`. Adım 45'te ₺650 olan dosyanın kararı adım 46'da ₺2.450 üzerinden işliyor `[K]`.

### Ulaşılabilirlik

Adım 1'den ekrandaki düğmelerle gidilemeyen ekranlar: **15, 27, 28, 37, 38, 44, 45, 46, 47, 48** `[T]`. Adım 48 ayrı bir tanıtım sitesi olduğu için beklenen bir durum. Adım 20, 21 ve 22 tıklama testinde ulaşılamaz görünür, ama gerçekte banka dönüşüyle açılır; ödeme testlerinde doğrulandı.

## 4. Prototip sorunları

### Engelleyici

| ID | Sorun | Kanıt | Çözüm yönü | Etiket |
|---|---|---|---|---|
| P1 | 25'ten 27'ye geçiş yok, serbest bırakma ve puanlama kopuk | S23, S25; B:1462, B:1525 | Usta bitirince adım 25'te onay düğmesi | `[T]` |
| P2 | Adım 28: yıldızlar ve "Yayınla" ölü | B:1579 geçersiz `:contains` | Yıldızları `aria-label` ile seç | `[T]` |
| P3 | Adım 36: teklif gönderme ölü, 37-38 ulaşılamıyor | B:1744 aynı hata | Seçiciyi kaldır, 37'ye bağlantı ekle | `[T]` |
| P4 | Adım 24: mesaj gönderme ölü | B:1471 aynı hata | Gönder düğmesini `aria-label` ile seç | `[T]` |

Aynı `:contains` hatası adım 34 (`S34:L351`) ve 44'te de (`S44:L444`) var. Adım 34'te kullanıcıya etkisi yok, adım 44'te reddet ve eksik belge dinleyicilerini engelliyor.

### Yüksek

| ID | Sorun | Kanıt | Çözüm yönü | Etiket |
|---|---|---|---|---|
| P5 | EN modda 24 düğme ölü, metin bozuk ("My Requestse git", "Banyo Refreshme", "Cancel Jobmeyi Approve"). Neden: çeviri düğmeler bağlanmadan önce çalışıyor, kurallar Türkçe metne bakıyor, çeviri alt metin değiştiriyor | B:638-639 | Metin yerine sabit kimlikle bağla; tam metin çevirisi | `[T]` |
| P6 | Adım 7: geri düğmesi geri gitmiyor, dosya seçiciyi açıp "2 fotoğraf yüklendi" gösteriyor | B:907-910 | Yükleme kartını doğru seç | `[T]` |
| P7 | Adım 31 ve 32: alt sekmeler ölü | B:1657, S32:L366 | `nav button` dahil et, 32'yi bağla | `[T]` |
| P8 | Karşılaştırma (15) açılmıyor, her teklif Mavi Hat, 3. teklifin düğmesi yok | B:1004, B:1011, S11 | Karşılaştır düğmesi, teklif başına kimlik | `[T]` |
| P9 | Geri biten işe dönüyor: 9→8 (yayınlanan talep), 21→18 (ödenen teklif), 28→27, 30→29, 42→40 | `screens_map.json` | Geri kuralları (Bölüm 8) | `[T]` |
| P10 | Şikayet sonrası müşteri adım 26'dan kendine iade yapıp hakemi atlayabilir; iş başladıktan sonra da iptal mümkün | `EscrowPayment.requireRefundable`, B:1543 | Durum kuralı: dava açıkken iptal yok | `[Ç]` |
| P11 | Adım 21 "ücret alınmaz" diyor, oysa ödeme az önce alındı; usta reddederse iade yolu yok | S21:L164 | Metin ve iş kuralı | `[K]` |
| P12 | Adım 46 "₺2.450 Ustaya Ödeme" diyor, aktarım ₺2.205; usta komisyonu hiçbir yerde görmüyor | B:1920, S43, S46 | Gerçek tutarı göster | `[K]` |
| P13 | Usta paylaşılan ekrana girince rol müşteriye dönüyor (sohbet, bildirim) | B:289-290, B:1516 | Paylaşılan ekran rolü ezmesin; role özel sohbet | `[K]` |
| P14 | Müşteri iptali usta ekranına (42), usta sorun bildirimi "müşteri iptal etti" ekranına gidiyor | B:1835, `screens_map.json` 26→42 | Müşteri sonuç ekranı, usta destek ekranı | `[T]` |
| P15 | Randevu kendiliğinden onaylanıyor, usta onay veya red ekranı yok | S22, S23 | Usta onayı ve red yolu | `[T]` |
| P16 | Doğrulama atlanıyor: boş OTP, boş sihirbaz adımı, seçilmemiş saat | B:754, B:848, B:899, B:1427 | Düğmeyi doğrulamaya bağla | `[K]` |
| P17 | Reddet, eksik belge, şikayeti kapat çalışmıyor | S44:L427, L432, L444; S45:L456 | Dinleyici ve sonuç durumu | `[T]` |
| P18 | Kullanıcı girdileri özet ekranlarına yansımıyor | B:927, B:932; S8, S9, S22 | Sakladığı değerleri ekranda göster | `[K]` |
| P19 | Talep iptali ve usta iptali yok (UC11); "Yeni Tarih İste" ölü | S10, S26:L168, S40 | Eksik yolları ekle | `[T]` |

### Orta

| Sorun | Kanıt | Etiket |
|---|---|---|
| Adım 21: tarih ve saat seçince gönder düğmesinin zemini kayboluyor | B:1414 | `[Ç]` |
| Adım 6: öneri metni iki kez ekleniyor | B:885 | `[Ç]` |
| Adım 2: yeniden yazınca 10. hane girilemiyor (maske ve `maxlength` uyumsuz) | S2:L59, B:702 | `[Ç]` |
| Adım 12: "Filtreleri Temizle" yalnızca kapatıyor; sıralama ve fiyat seçenekleri etkisiz | B:1022, B:1029 | `[T]` |
| Kayıtlı usta "Usta Modu" ile her seferinde başvuruya dönüyor | 31→33 | `[T]` |
| Çıkış, ayarlar: 34'te çıkış ölü; adres, KVKK, bildirim ayarları yalnız toast | S34:L175, S31 | `[T]` |
| 48 saat otomatik aktarım vaat ediliyor, uygulanmıyor | S43:L77 | `[K]` |
| Durum çelişkileri: 23 "Henüz başlamadı", 25 "Onarım Sürüyor"; 40 adreste, 41 "2.8 km kaldı" | S23:L179, S25, S40, S41 | `[K]` |
| Toast'larda ikon adları görünüyor ("location_on Kayıtlı Adreslerim") | B:1652 | `[T]` |

### Düşük

- Geliştirici kalıntıları: gövdede SCR kodları (`S44:L293`, `S45:L308`, `S47:L116`), "BR09 & BR10" (`S45:L445`), "Is Alani" (`S23:L9`), "Job #504" (`S30:L168`), "Audit Trail" (`S45:L385`), "Escrow" (`S34:L250`, `S46:L154`).
- Takvim 2024'e göre sabit ("Perşembe 16 Mayıs") `[Ç]`.
- Adım 36'da ekranın içinde sahte durum çubuğu (09:41) `[T]`.
- Google Play düğmesi ölü (`S48:L128`) `[T]`.
- Arama bağlantıları "telefon paylaşma" uyarısıyla çelişiyor (`S40`, `S41`, `S24:L225`) `[K]`.
- Dokunma alanları: 44 px altı 189 öğe, RAD:170 48 dp istiyor `[T]`.
- Metinde "sen" ve "siz" karışık; usta, uzman, hizmet profesyoneli gibi çok terim.

## 5. Ortak veri tutarsızlıkları (A3)

Hepsi `[K]`. Çözüm: tek demo veri seti, gerçek üründe tek kayıt.

| Bilgi | Değerler | Nerede |
|---|---|---|
| İş numarası | #TD-84920, #BD-88412, #501, #504 | 9, 11; 13, 18, 20, 46, backend; 25-28, 36, 38, 40-43; 29, 30, 45, 47 |
| Şikayet numarası | #CMP-104, #UYS-2026-8812 | 30, 45, 47; 46 |
| Mavi Hat fiyat dökümü (₺2.450) | 1.650+800, 1.500+950, 1.800+650 | 13, 18, 25, 27, 36, 38, 40; 11, 15; 37 |
| Kaya Tesisat fiyatı | ₺2.200, ₺2.450, ₺1.850 | 11, 15; 17; 32 |
| Müşteri | Ali Yılmaz, Ata H., Ayşe Demir, Zeynep K. | 24, 28, 31, 38, 42, 43; 40; 41, 46; 45, 47 |
| Şikayet edilen usta | Mavi Hat, Ali Kaya (Elektrik) | Akış; 29, 30, 45, 47 |
| Kaya'nın sahibi | Ahmet Usta, Mehmet Usta | 10; 17 |
| Telefon | +90 532 849 20 11, +90 532 450 88 92 | 2, 3; 31 |
| Randevu | Bugün 14-17, Bugün 14-16, Yarın 14-16, Yarın 10-12 | 13, 18; 22, 36, 38; 23, 24, 26; 42 |
| Adres | Moda Cad. 14 D:5 (zil Hakan), Şair Nefi 14 D:4 (zil Demir) | 40; 41 |
| Garanti | 3 ay, 6 ay, 12 ay; Flutter'da 30 gün | 15; 13, 15, 18, 36; 27; `s04:318` |
| Komisyon | "komisyonsuz", %10 | `S48:L399`; `EscrowPayment.java:28` |
| İş başlığı | Su kaçak tespiti, Banyo Lavabo Su Sızıntısı, Banyo Tesisat Bakımı, Su Borusu Patlağı | 13; 10, 43; 23; 35 |

Lisans iddiaları için not: prototipin görünür metinlerinde BDDK veya TCMB kalmadı.

## 6. Flutter: yeni yazımın kabul kriterleri

Temel gereksinimler `docs/FLUTTER_RESTART_NOTES.md` içinde. Bu bölüm onu test kanıtıyla destekler. Eski kodu incelemek için: `git show 69607a0:mobile/lib/core/routing/app_router.dart`.

### Yolculuk testinde görülenler `[T]`

| Eylem (eski sürüm) | Sonuç | Yeni sürümde kabul kriteri |
|---|---|---|
| Elektrik seç, sihirbazda ilerle | Sonraki ekranlar "Tesisat" diyor | Seçilen değer özette ve yayında görünür |
| 2. veya 3. teklifi aç | Hep Mavi Hat açılıyor | Detay, tıklanan teklifi gösterir |
| Teklifi kabul et | Ödeme adımı yok | Karara göre ödeme adımı |
| İşi iptal et | "Randevun onaylandı"ya dönüyor | İptal durumu ve sonuç ekranı |
| Puanlamadan sonra Taleplerim | Aynı talep hâlâ "3 teklif" | İş geçmişe geçer |
| Onaydan sonra geri bas | "Onaylanıyor..." ekranında takılıyor | Kayıttan sonra geri formu açmaz |
| Usta sohbetinden geri bas | Müşteri iş alanına düşüyor | Rol sınırı aşılmaz |
| Usta rolüyle başla | Telefon atlanıyor, belgesiz canlı akış | Ortak giriş, onay bekleme durumu |
| Çıkış yapıp `/step/4` aç | Ana sayfa açılıyor | Oturum koruması |
| Bilinmeyen adres | Hazır "Page Not Found" | Markalı hata ekranı |

### Kaçınılacak diğer sorunlar `[K]`

- **Veri:** hiçbir ekran bloc veya repository kullanmıyordu; `main.dart` blocları boşuna oluşturuyordu.
- **Rota:** `/step/N`, `PopScope` ve `redirect` yok, 8 kullanılmayan takma ad, boş yığında `context.pop` hatası.
- **Sekmeler:** 3 ve 4 sekme arasında değişiyordu; kök ekranlarda geri oku vardı.
- **Formlar:** `Form` ve doğrulayıcı yoktu; ₺0 teklif geçiyordu; alanlar önceden doluydu.
- **Boş düğmeler:** 20 boş eylem (adres, KVKK, destek, bildirim, numara değiştir).
- **Yerleşim** `[T]`: `s27` harfler alt alta, `s28` ve `s22` kesik metin, `s32` taşan düğme. Küçük ekran ve büyük yazı testi gerekir.
- **Platform:** ana manifest'te `INTERNET` yok, uygulama adı `bitadilat_mobile`, debug imza, 390 px sınırı tüm cihazlarda, yazı tipi ağdan yükleniyor.
- **Erişilebilirlik:** `Semantics` ve `tooltip` yok, 39 `IconButton` etiketsiz, 9-11 px yazılar.
- **Eksik ekranlar (15):** filtre, red, değerlendirmeler, kart ve 3DS, ödeme hatası, bildirim, belge inceleme, malzeme, navigasyon, usta iptal bildirimi, admin ekranları.

Prototipte iyi çalışan ödeme ve 3DS akışı yeniden kullanılabilir. Mobilde WebView gerekir; banka dönüşü için geri çağrı adresi cihazdan ulaşılabilir olmalıdır.

## 7. RAD karşılaştırması

RAD'da adım adım use case yok; yalnızca tablo (RAD:136-149), gereksinimler ve durum makinesi var. Karşılaştırma buna göre yapıldı.

| UC | Prototip | Eksik veya yanlış |
|---|---|---|
| UC01 Giriş | Kısmi | Sahte OTP, admin girişi yok; RAD e-posta ve şifre de tanımlıyor (RAD:220-236) |
| UC02 Talep | Kısmi | Doğrulama atlanıyor, veri taşınmıyor, planlı iş için tarih yok, 1,5 MB sınırı yok |
| UC03 Eşleştirme | **Yok** | Ekran yok (RAD:258) |
| UC04 Teklif | **Kırık** | Gönderilemiyor (P3) |
| UC05 Kabul | Kısmi | Tek teklif, rakipleri düşürme yok; ödeme RAD:75 ile çelişiyor |
| UC06 Randevu | Kısmi | Usta tarafı ve yeni tarih yok |
| UC07 Mesaj | **Kırık** | Gönderilemiyor (P4), tek konuşma |
| UC08 İlerleme | Sabit | Aşama değişmiyor |
| UC09 Tamamlama | **Kopuk** | Akıştan ulaşılamıyor (P1) |
| UC10 Puan | **Kırık** | Çalışmıyor (P2) |
| UC11 İptal | Kısmi | İş iptali iade yapıyor; talep ve usta iptali yok |
| UC12 Usta onayı | Görsel | Yalnız toast, sonucu kimse görmüyor |
| UC13 Hakem | Kısmi | Para hareketi var; dosya uyuşmuyor, sonuç müşteriye yansımıyor |
| UC14 Tanıtım | Büyük ölçüde tamam | "komisyonsuz", Google Play düğmesi |

**Diğer gereksinimler:** RAD:168 (TR/EN) bozuk (P5), RAD:169 (onay diyaloğu) kısmen var, RAD:170 (48 dp) karşılanmıyor, RAD:186 (push) yalnız statik liste, RAD:190 (KVKK) bağlantılar ölü, RAD:191 (adres gizliliği) ekranlar çelişiyor.

## 8. Kararlar ve yol haritası

### Verilen karar

Flutter sıfırdan yazılacak, prototip akış referansı (`docs/FLUTTER_RESTART_NOTES.md`).

### Bekleyen kararlar

1. **Emanet modeli:** para gerçekten havuzda tutulacak mı? Ekran sırasını, RAD'ı ve hukuki yükü belirliyor. Fon tutmak lisans gerektirebilir, hukuki danışmanlık alınmalı. Craftgate pazaryeri bir seçenek olabilir; hesabınızda açık olup olmadığı doğrulanmadı.
2. **Kurallar:** ödeme randevudan önce mi sonra mı? İptal ve iade penceresi? Komisyon oranı ve kimin göreceği? 48 saat otomatik aktarım? %50/%50 kararında komisyon?
3. **Admin paneli:** web mi, Flutter mı? UC12 ve UC13 buna bağlı.
4. **Backend:** `backend/` genişletilip H2 yerine PostgreSQL önerilir. Jüriye kadar hedef tutarlı sahte veri mi, gerçek API mi?
5. **Takvim:** jüri tarihi nedir? Bu hedef ile canlıya çıkış aynı şey değil.
6. **RAD:** `docs/PAYMENT_RAD_CHANGE_NOTE.md` onayı.

### Önerilen sıra

| Aşama | İş | Bitti sayılması için |
|---|---|---|
| 0 | Yukarıdaki kararlar | Kararlar yazılı |
| 1 | Prototip: P1-P4, sonra P5-P19 ve tek demo veri seti (A3) | Müşteri ve usta tıklayarak uçtan uca gidiyor; `compare.mjs` farkı beklenen |
| 2 | Şartname: iş durum makinesi, rol-ekran haritası, sözlük, geri kuralları | Prototip buna göre geçiyor |
| 3 | Backend: iş, teklif, randevu, mesaj API'leri, oturum, PostgreSQL | API testleri geçiyor |
| 4 | Flutter temeli: tema, yönlendirme, oturum, API katmanı, yolculuk testleri | Bölüm 6 kriterleri test edilir halde |
| 5 | Flutter işlevleri: yolculuklar, ödeme WebView, mesaj, bildirim, fotoğraf | Tüm UC'ler geçiyor |
| 6 | Kalite: i18n, küçük ekran, erişilebilirlik, gerçek cihaz testi | Android ve iOS'ta geçti |
| 7 | Canlıya hazırlık | Hukuki ve güvenlik onayı |

**Geri kuralı önerisi:** bir işlem kaydedildikten sonra geri o formu açmaz, işin bulunduğu ekrana döner. Sekme köklerinde geri oku olmaz. Roller arası geçiş yalnızca bilinçli mod değiştirmeyle olur.

### Canlıya çıkmadan olmazsa olmaz

- **Ödeme:** şu anki kart akışı yalnızca sandbox içindir, kart verisi backend'den geçiyor. Canlıda Craftgate ortak ödeme formu ve canlı anahtarlar gerekir.
- **Yetki:** backend'de kimlik doğrulama yok; `ref` bilen herkes iade tetikleyebilir.
- **Altyapı:** PostgreSQL, HTTPS, yedekleme, izleme.
- **Yasal:** KVKK aydınlatma ve açık rıza, kullanım sözleşmesi, mesafeli satış ve iade koşulları, kimlik ve adli sicil belgelerinin güvenli saklanması.
- **Dağıtım:** gerçek SMS sağlayıcısı, push bildirim, imzalı Android ve iOS derlemeleri, mağaza hesapları.

## Ek A. Tıklama matrisleri

Otomatik üretildi, kaynak `scratch/audit/baseline/`. `→n` adım n'e gider, `T` toast, `E` ekran değişir, `—` görünür etki yok, `dil` / `dış` / `seçim` / `dosya` tıklanmadı, `kapalı` düğme devre dışı.

### Prototip, Türkçe mod (`0b3fc88`)

| Adım | Öğeler |
|---|---|
| 1 Hoş Geldiniz & Rol Seçimi | TR dil; EN dil; Ev sahibi / Müşteri Onarım veya yenileme —; Hizmet profesyoneli Yeni iş fırsatları arıyo —; Telefon numarasıyla devam et kapalı; Giriş yap →2; Kullanım Koşulları —; Gizlilik Politikası — |
| 2 Telefon Doğrulama | arrow_back →1; Cep Telefonu Numaranız Zorunlu —; 🇹🇷 +90 keyboard_arrow_down —; Devam Et →3; Gizlilik Politikası —; Aydınlatma Metni —; Numaranı mı değiştirmek istiyorsun? Geri dön →1 |
| 3 SMS Doğrulama Kodu | arrow_back →2; SMS Güvenlik Kodu —; Telefon numarasını değiştir →2; Doğrula →4 |
| 4 Müşteri Ana Sayfası | notifications →32; Talep oluşturmaya başla →5; Ana sayfa →4; Taleplerim →10; Mesajlar →24; Profil →31 |
| 5 Talep Adım 1/4: Hizmet & Öncelik | arrow_back →4; Tesisat Su, kaçak, tıkanıklık E; Elektrik Sigorta, hat, montaj E; Boya & Badana İç cephe, alçı tamir E; Klima Bakım, gaz, arıza E; Banyo Yenileme Fayans, duşakabin E; Mutfak Yenileme Tezgah, dolap montaj E; Marangozluk Ahşap kapı, mobilya E; Diğer Farklı uzmanlıklar E; Acil onarım Hızlı Usta Bugün veya en kısa sü —; Planlı yenileme Randevulu Tarih belirleyerek —; Devam Et →6 |
| 6 Talep Adım 2/4: Konum & İş Detayı | arrow_back →5; İl —; İlçe —; İlçe seç —; İlçe seçin Kadıköy Üsküdar Beşiktaş Şişli At seçim; Mevcut konumumu kullan T; Ne zamandır var? —; Su akışı kesildi mi? —; Farklı odaları etkiledi mi? —; Devam Et →7 |
| 7 Talep Adım 3/4: Fotoğraflar & Ek Bilgi | arrow_back T; Fotoğraf ekle Galeriden seç veya kamera ile  —; Ekle —; Ek bilgi —; Devam Et →8 |
| 8 Talep Adım 4/4: Talebi Gözden Geçir | arrow_back →7; Düzenle →5; Düzenle →6; Düzenle →7; Düzenle →7; Talebi yayınla →9 |
| 9 Talep Yayınlandı — Teklif Bekleniyor | arrow_back →8; Taleplerime git →10; Ana sayfaya dön →4 |
| 10 Müşteri Taleplerim Listesi | arrow_back →4; help_outline —; Aktif Talepler 1 —; Geçmiş İşler 2 —; Gelen Teklifleri Gör (3) →11; + Yeni Onarım Talebi Başlat Usta tekliflerin →5; Tümünü Gör (2) —; Detayları İncele —; Ana Sayfa →4; Taleplerim →10; Mesajlar →24; Profil →31; Acil Onarım Tesisat 3 Teklif Geldi Banyo Lav →11 |
| 11 Gelen Teklifler Listesi | arrow_back →10; notifications →32; Önerilen sıralama →12; tune →12; Teklifi İncele →13; Teklifi İncele →13 |
| 12 Gelen Teklifleri Filtrele ve Sırala Modalı | Filtreleri Temizle →11; close →11; Sıralama Ölçütü —; Önerilen Sıralama —; En Düşük Fiyat —; En Yüksek Puan —; En Hızlı Varış —; ₺1.500 altı —; ₺1.500 - ₺3.000 —; ₺3.000 üzeri —; Usta Nitelikleri & Güvenilirlik —; Sonuçları Uygula (3 Teklif Listele) →11; div —; Yalnızca Doğrulanmış Usta Rozetliler verifie —; En az 4.5 ve üzeri müşteri puanı ★ 4.5+ Yaln —; Bugün acil gelebilecekler 14:00 - 18:00 saat —; Malzeme dahil anahtar teslim teklifler İşçil — |
| 13 Teklif Detayı & Kapsam | arrow_back →11; Profili görüntüle →16; Ustaya soru sor →24; Teklifi kabul et →18; Teklifi Reddet →14 |
| 14 Müşteri Teklif Reddetme & Geri Bildirim | arrow_back →13; help_outline —; Fiyat bütçeme uygun değil Beklentimin üzerin —; price —; Ustanın önerdiği tarih/saat uygun değil Zama —; schedule —; Başka bir teklifle ilerlemeye karar verdim B —; another_offer —; Artık bu hizmete ihtiyacım kalmadı Sorunu çö —; no_longer_needed —; Diğer Farklı bir gerekçe belirtmek istiyorum —; other —; DETAYLI AÇIKLAMA (İSTEĞE BAĞLI) —; Talebim teklif havuzunda açık kalsın Bu tekl —; on —; Teklifi Reddet →11; Vazgeç, Teklife Dön →13 |
| 15 Teklifleri Karşılaştır (Matris) | arrow_back_ios_new →11; Teklifleri düzenle (2/3) —; Teklifi incele →13; Teklifi incele →13 |
| 16 Hizmet Profesyoneli Profili | arrow_back →13; Tüm değerlendirmeleri gör →17; Teklife dön →13; Ustaya soru sor →24 |
| 17 Müşteri Değerlendirmeleri ve İş Fotoğrafla | arrow_back →16; share —; Tümünü Gör (18) —; Tümü (42) —; Fotoğraflı (18) —; 5 Yıldız (37) —; Tesisat & Onarım (31) —; Teklife Geri Dön ve Kabul Et →13; div —; div — |
| 18 Teklif Kabul Onayı (Güvence Havuzu) | arrow_back →13; Profili görüntüle —; Ustaya soru sor —; Teklifi kabul et →19; Teklifi kabul et ve ödemeye geç →19; Vazgeç →13 |
| 19 Güvenli Ödeme: Kart Bilgileri & 3D Secure | arrow_back →18; Test Kartını Yaz —; Kart Üzerindeki Ad Soyad —; Kart Numarası —; Son Kullanma (AA/YY) —; Güvenlik Kodu (CVC) —; Güvenli Öde ve 3D Secure Adımına Geç E; İşlemi İptal Et ve Teklife Geri Dön →18 |
| 20 Güvence Havuzu Ödeme Hatası & 3D Secure | arrow_back →18; help_outline —; Farklı Bir Kartla Tekrar Dene →19; Teklif Detayına Geri Dön →13; Bankanızla veya BiTadilat Destek ile Görüşün — |
| 21 Randevu Zamanı Seç | arrow_back →18; Bugün 14 Mayıs E; Yarın 15 Mayıs E; Perşembe 16 Mayıs E; Cuma 17 Mayıs E; Cumartesi 18 Mayıs E; 09:00 – 11:00 E; 11:00 – 13:00 E; 14:00 – 16:00 E; 16:00 – 18:00 E; Randevu talebi gönder →22 |
| 22 Randevu Talebi İletildi | arrow_back →21; Talep detayına git →23; Ana sayfaya dön →4 |
| 23 İş Alanı — Randevu Onaylandı | arrow_back →10; more_vert —; Mesajlar Mavi Hat Tesisat ile uygulama içind →24; İş ilerlemesi Henüz başlamadı Usta mekana ul →25; Randevuyu değiştir veya iptal et →26; Ustaya mesaj gönder →24 |
| 24 Usta ile Mesajlaşma | arrow_back →23; more_vert —; İş Detayı —; attach_file —; photo_camera —; send — |
| 25 İş Aşamaları ve İlerleme Takibi | arrow_back →23; more_vert —; visibility —; Usta ile ilgili bir sorun mu var? Destek eki →29; Ustaya Mesaj Gönder →24 |
| 26 Randevu İptal / Değişiklik Talebi | arrow_back →23; more_vert —; Randevuyu İptal Et —; Yeni Tarih İste —; Planlarım değişti / Takvim uyuşmazlığı —; schedule_conflict —; Sorun bağımsız olarak çözüldü / Onarım gerek —; solved_independently —; Usta ile iletişim kurulamadı / Gecikme yaşan —; communication_issue —; Başka bir hizmet sağlayıcı tercih edildi —; other_provider —; Beklenmeyen acil durum / Diğer —; emergency_other —; Ek Açıklama (Opsiyonel) —; İşi İptal Etmeyi Onayla →42; Vazgeç, Randevuyu Koru →23 |
| 27 İş Tamamlama ve Teslim Onayı | arrow_back →23; more_vert —; İşi Onayla ve Değerlendirmeye Geç →28; İşte eksik veya sızıntı mı var? Sorun bildir →29; Usta tarafından eklendi • 14:55 visibility Ö — |
| 28 Hizmet Değerlendirme ve Puanlama | arrow_back →27; more_vert —; star —; star —; star —; star —; star —; NELERİ BEĞENDİN? —; Zamanında geldi —; Temiz işçilik —; Şeffaf fiyat —; Hızlı iletişim —; Güler yüzlü & Saygılı —; Deneyimini Detaylandır (Opsiyonel) Diğer kom —; Anonim Değerlendirme —; Değerlendirmeyi Yayınla — |
| 29 Şikayet ve Uyuşmazlık Bildirimi | arrow_back →23; more_vert —; Usta randevuya gelmedi / Ulaşılamıyor (No-Sh —; on —; Anlaşılandan farklı veya eksik iş yapıldı —; on —; Teklif dışı fazladan ücret talep edildi —; on —; İletişimde saygısız / uygunsuz tutum —; on —; Diğer uyuşmazlık —; on —; Durumu Detaylandırın Açık ve net ifadeler ku —; close —; Kanıt Ekle —; Şikayet Dosyasını Oluştur (Destek Ekibine İl →30 |
| 30 Şikayet İletildi ve Durum Takibi | arrow_back →29; more_vert —; Canlı Destek Başlat —; Taleplerime ve Ana Sayfaya Dön →4; Mesaj Kayıtlarını Görüntüle →24 |
| 31 Müşteri Profil & Ayarlar | arrow_back →4; notifications →32; edit —; Kayıtlı Adreslerim Ev: Kadıköy, Caferağa Mah T; BiTadilat Güvence Havuzu Ödeme ve güvence si T; Bildirim Tercihleri SMS ve Uygulama İçi T; Yardım & Destek Merkezi SSS, canlı destek ve —; Gizlilik ve KVKK Veri güvenliği ve aydınlatm T; Usta Modu →33; Çıkış Yap →1; Ana Sayfa —; Taleplerim —; Mesajlar —; Profil — |
| 32 Bildirim Merkezi ve Aktivite Paneli | arrow_back →4; Tümünü Okundu Say T; Tümü 4 —; Teklifler 2 —; İşlerim 1 —; Sistem 1 —; Teklifi İncele →11; İş Alanına Git →23; Detay —; Bildirim Ayarlarını Düzenle SMS, e-post —; Ana Sayfa —; Taleplerim —; Mesajlar —; Profil — |
| 33 Usta Kayıt & Belge Yükleme | arrow_back →1; Değiştir —; edit —; delete —; Belge Yükle (PDF / JPG) —; Belge Yükle (PDF / JPG) —; Başvuruyu İncelemeye Gönder →34; BiTadilat Usta Hizmet Sözleşmesi — |
| 34 Usta Belge İncelemede Bekleme | support_agent —; logout —; Örnek Taleplere Göz At (Demo Modu) →35; Müşteri Moduna Geç →4; Sorularınız için Usta Destek Hattı ile görüş — |
| 35 Usta Eşleşen Talepler Akışı | notifications →32; Kadıköy, Üsküdar keyboard_arrow_down —; Tümü 4 —; Acil (1) —; Planlı (3) —; Sırala —; Teklif Hazırla →36; Detayları İncele —; Detayları İncele —; Talepler →35; 1 İşlerim →40; Mesajlar →24; Profil →39; Müsait —; Acil Onarım location_on 1.2 km · Moda schedu →36 |
| 36 Usta Teklif Hazırlama | arrow_back →35; 1. İşçilik Bedeli (TL) —; 2. Tahmini Malzeme Bedeli (TL) —; 3. Taahhüt Edilen Varış Saati —; Bugün, 14:00 – 16:00 arası Randevu aralığı m —; 4. İşçilik Garantisi ve Kapsam Notu —; Yapılandırılmış Teklifi Gönder (₺2.450) — |
| 37 Usta Yapılandırılmış Maliyet Modalı | close →36; delete_outline —; delete_outline —; delete_outline —; Yeni Malzeme Kalemi Ekle —; Kalemleri Kaydet ve Teklife Ekle ₺2.450 arro →36 |
| 38 Usta Teklif Gönderildi Onayı | close →35; Eşleşen Talepler Akışına Dön →35; Profil ve Müsaitlik Ayarlarını Aç →39 |
| 39 Usta Profil & Müsaitlik Yönetimi | arrow_back →35; Aktif İş Alıyor —; Mola Kapalı —; Tesisat (Temiz & pis su) —; Tıkanıklık Açma & Gider —; Banyo & Eviye Montajı —; Elektrik Tesisatı —; Petek & Kalorifer Bakımı —; close —; close —; close —; close —; + İlçe Ekle veya Çıkar —; label —; on —; Müşterilere Gösterilen Profil Yazısı —; Ayarları ve Müsaitliği Güncelle T; Müşteri Moduna Geç →4; Çıkış Yap →1 |
| 40 Usta İş Yürütme & Aşama Yönetimi | arrow_back →35; call dış; Haritada Yol Tarifi Al →41; Müşteriye Mesaj Yaz →24; Yükle —; İşi Bitirdim (Müşteriye Teslim Talebi Gönder →43; Sahada bir anlaşmazlık mı var? Durum Bildir  →42 |
| 41 Mobil Usta Canlı Navigasyon ve Adrese Varı | arrow_back →40; call dış; explore —; my_location —; Adresi Kopyala —; Haritada Aç dış; Adrese Ulaştım (Müşteriyi Bilgilendir) →40; Müşteriye Mesaj Yaz →24 |
| 42 Usta Randevu İptali Bildirimi | arrow_back →40; help_outline —; Yeni İş Fırsatlarına Git →35; Müşteri ile Mesajlaş →24 |
| 43 Usta Teslim Bildirimi İletildi | close →35; Eşleşen Talepler Akışına Dön →35; Müsaitlik ve Profil Ayarlarını Aç →39 |
| 44 Yönetici Web: Belge İnceleme | Profil İnceleme Sırası 3 —; Uyuşmazlık ve Şikayetler 1 →45; Kullanıcı ve Usta Hesapları →47; Çıkış Yap →1; refresh —; Tümü (3) —; Acil Tesisat —; Elektrik —; Tam Ekran —; Profili Onayla ve Yayına Al T; Başvuruyu Reddet —; Eksik Belge Talebi İlet —; Mehmet Demir verified Mavi Hat Tesisat İncel —; Hasan Yıldız Yıldız Elektrik Sırada bolt Ele —; Selim Aksoy Aksoy Boya & Badana Sırada forma — |
| 45 Yönetici Web: Şikayet Merkezi | Profil İnceleme Sırası 3 →44; Uyuşmazlık ve Şikayetler 1 —; Kullanıcı ve Usta Hesapları →47; Çıkış Yap →1; refresh —; Tümü (3) —; No-Show (1) —; Ücret İtirazı —; Şikayeti Reddet / Kapat —; Ustaya Resmi İhtar Gönder T; İşi İptal Et (Uyuşmazlığı Müşteri Lehine Kap →46 |
| 46 Yönetici Web: Uyuşmazlık Karar Modalı | close →45; %100 Müşteriye İade (Tam Haklılık) price_che —; full_refund —; %50 / %50 Kısmi Uzlaşma ₺1.225 / ₺1.225 Taks —; split_settlement —; %100 Ustaya Aktarım (Şikayet Reddi) ₺2.450,0 E; full_payout_artisan E; Resmi Gerekçeli Karar Raporu (İdari Arşiv &  —; Ustaya resmi sistem ihtarı ilet ve ceza puan —; on —; Ustanın acil iş alımını 48 saat süreyle askı —; on —; Vazgeç / İncelemeye Dön →45; Nihai Kararı Onayla ve ₺2.450 İadeyi Başlat →45; Panel —; Uyuşmazlık Çözüm Havuzu (32) —; Emanet Hesaplar (Escrow) —; Esnaf Sicilleri — |
| 47 Yönetici Web: Hesap Yönetimi | Profil İnceleme Sırası 3 →44; Uyuşmazlık ve Şikayetler 1 →45; Kullanıcı ve Usta Hesapları —; Çıkış Yap →1; Rol: Tümü Müşteri Hizmet Profesyoneli seçim; Durum: Tümü Aktif Askıda İncelemede seçim; Bölge: İstanbul (Tümü) Kadıköy Üsküdar Ataşe seçim; refresh —; Detay Gör —; Askıya Al T; Detay Gör —; Askıya Al T; İncele —; Yeniden Aktifleştir T; Detay Gör —; Askıya Al T; chevron_left kapalı; 1 —; 2 —; 3 —; 72 —; chevron_right — |
| 48 BiTadilat Tanıtım ve Karşılama Sitesi | BiTadilat PRO GÜVENİLİR USTA AĞI —; Özellikler —; Nasıl Çalışır? —; Usta Ol / Başvur →33; Sıkça Sorulan Sorular (SSS) —; TR dil; EN dil; Uygulamayı İndir →1; APP STORE'DAN İndirin (iOS) →1; GOOGLE PLAY'DEN Alın (Android) —; Usta Olarak Başvur →33 |

### Prototip, İngilizce modda bozulan düğmeler

| Adım | Türkçe metin | TR | EN metni | EN |
|---|---|---|---|---|
| 1 | Giriş yap | →2 | Log in | ölü |
| 9 | Taleplerime git | →10 | My Requestse git | ölü |
| 11 | Teklifi İncele | →13 | View Offer | ölü |
| 11 | Teklifi İncele | →13 | View Offer | ölü |
| 12 | Filtreleri Temizle | →11 | Clear Filters | ölü |
| 12 | Sonuçları Uygula (3 Teklif Listele) | →11 | Apply Results (3 Teklif Listele) | ölü |
| 13 | Profili görüntüle | →16 | Profilei görüntüle | ölü |
| 14 | Teklifi Reddet | →11 | Reject Offer | ölü |
| 16 | Ustaya soru sor | →24 | Ask the Pro a question | ölü |
| 18 | Teklifi kabul et ve ödemeye geç | →19 | Accept offer and continue to payment | ölü |
| 18 | Vazgeç | →13 | Cancel | ölü |
| 20 | Farklı Bir Kartla Tekrar Dene | →19 | Try Again with Another Card | ölü |
| 20 | Teklif Detayına Geri Dön | →13 | Back to Offer Details | →18 |
| 22 | Talep detayına git | →23 | Request detayına git | ölü |
| 23 | Mesajlar Mavi Hat Tesisat ile uygulama içind | →24 | Messages Mavi Hat Plumbing ile uygulama için | ölü |
| 26 | İşi İptal Etmeyi Onayla | →42 | Cancel Jobmeyi Approve | ölü |
| 30 | Taleplerime ve Ana Sayfaya Dön | →4 | My Requestse ve Homeya Dön | →29 |
| 31 | Çıkış Yap | →1 | Log Out | ölü |
| 32 | Teklifi İncele | →11 | View Offer | ölü |
| 33 | Başvuruyu İncelemeye Gönder | →34 | Başvuruyu İncelemeye Submit | ölü |
| 34 | Müşteri Moduna Geç | →4 | Switch to Customer Mode | ölü |
| 40 | Haritada Yol Tarifi Al | →41 | Get Directions on Map | ölü |
| 44 | Çıkış Yap | →1 | Log Out | ölü |
| 45 | Çıkış Yap | →1 | Log Out | ölü |
| 46 | Nihai Kararı Onayla ve ₺2.450 İadeyi Başlat | →45 | Confirm Final Decision and Refund ₺2,450 | ölü |
| 47 | Çıkış Yap | →1 | Log Out | ölü |

### Flutter, silinen sürüm (`69607a0`)

`→n` Flutter ekran numarasıdır, prototip adımıyla aynı değildir. Her ekran doğrudan adresle açıldığı için `s02`, `s03`, `s05`-`s08` geri okları burada etkisiz görünür; normal kullanımda çalışırlar.

| Ekran | Öğeler |
|---|---|
| s01 | TR —; EN —; Ev sahibi / Müşteri Onarım veya yenileme iht —; Hizmet profesyoneli Yeni iş fırsatları arıyo —; Telefon numarasıyla devam et →2; Giriş yap →2 |
| s02 | (ikon) —; Doğrulama kodu gönder →3 |
| s03 | (ikon) —; Numarayı Değiştir —; Kodu Doğrula ve Giriş Yap →4 |
| s04 | (ikon) —; Talep oluşturmaya başla →5; Taleplerim ve İşlerim Aktif işleri ve gelen  →10; Ana Sayfa Tab 1 of 3 —; Taleplerim Tab 2 of 3 →10; Profilim Tab 3 of 3 →26 |
| s05 | (ikon) —; Tesisat Su, kaçak, tıkanıklık —; Elektrik Sigorta, hat, montaj —; Boya & Badana İç cephe, alçı tamir —; Klima Bakım, gaz, arıza —; Banyo Yenileme Fayans, duşakabin —; Mutfak Yenileme Tezgah, dolap montaj —; Marangoz & Montaj Kapı, kilit, mobilya —; Küçük Onarım Genel ev tamiratı —; Acil Onarım Bugün Bugün / En kısa sürede müd —; Planlı Tadilat Bu Hafta Bu hafta içinde uygu —; Esnek Zamanlı Esnek Fiyat ve usta uygunluğun —; Devam Et →6 |
| s06 | (ikon) —; Devam Et →7 |
| s07 | (ikon) —; Fotoğraf ekle Galeriden seç veya kamera ile  E; (ikon) E; Devam Et →8; Fotoğrafsız Devam Et →8 |
| s08 | (ikon) —; Düzenle →5; Düzenle →6; Düzenle →6; Düzenle →7; Talebi Onayla ve Yayınla →9 |
| s09 | (ikon) →4; Taleplerime Git →10; Ana Sayfaya Dön →4 |
| s10 | (ikon) →4; (ikon) —; Aktif Talepler (1) —; Geçmiş / Tamamlanan E; Gelen Teklifleri İncele (3) →11 |
| s11 | (ikon) →10; (ikon) —; Teklifleri Yan Yana Karşılaştır (Matris Görü →13; Teklifi İncele →12; Teklifi İncele →12; Teklifi İncele →12 |
| s12 | (ikon) →11; Profili görüntüle →14; Ustaya soru sor →19; Teklifi kabul et →15 |
| s13 | (ikon) →11; Teklifi incele →12; Teklifi incele →12 |
| s14 | (ikon) →12; Tüm değerlendirmeleri gör —; Teklife dön →12; Ustaya soru sor →19 |
| s15 | Teklifi kabul et →16; Vazgeç →12 |
| s16 | (ikon) →15; Bugün 14 Mayıs —; Yarın 15 Mayıs —; Perşembe 16 Mayıs —; Cuma 17 Mayıs —; Cumartesi 18 Mayıs —; 09:00 – 11:00 —; 11:00 – 13:00 —; 14:00 – 16:00 —; 16:00 – 18:00 —; Randevu talebini gönder →17 |
| s17 | (ikon) →4; Talep detayına git →18; Ana sayfaya dön →4 |
| s18 | (ikon) →4; Mesajlar Mavi Hat Tesisat ile uygulama içind →19; İş ilerlemesi Henüz başlamadı Usta mekana ul →20; Randevuyu değiştir veya iptal et →21; Ustaya mesaj gönder →19 |
| s19 | (ikon) →18; İş Detayı →18; (ikon) —; (ikon) —; (ikon) — |
| s20 | (ikon) →18; Onayla > →22; Usta ile ilgili bir sorun mu var? Destek eki →24; Ustaya Mesaj Gönder →19 |
| s21 | (ikon) →18; Randevuyu İptal Et —; Yeni Tarih İste —; Planlarım değişti / Takvim uyuşmazlığı —; Sorun bağımsız olarak çözüldü / Onarım gerek —; Usta ile iletişim kurulamadı / Gecikme yaşan —; Başka bir hizmet sağlayıcı tercih edildi —; Beklenmeyen acil durum / Diğer —; İşi İptal Etmeyi Onayla →18; Vazgeç, Randevuyu Koru →18 |
| s22 | (ikon) →20; İşi Onayla ve Değerlendirmeye Geç →23; İşte eksik veya sızıntı mı var? Sorun bildir →24 |
| s23 | (ikon) →4; (ikon) —; (ikon) —; (ikon) —; (ikon) —; (ikon) —; Zamanında geldi —; Temiz işçilik —; Şeffaf fiyat —; Hızlı iletişim —; Güler yüzlü & Saygılı —; Değerlendirmeyi Gönder ve Tamamla →4 |
| s24 | (ikon) →20; Usta randevuya gelmedi / Ulaşılamıyor (No-Sh —; Anlaşılandan farklı veya eksik iş yapıldı Te —; Teklif dışı fazladan ücret talep edildi Önce —; İletişimde saygısız / uygunsuz tutum Profesy —; Diğer uyuşmazlık Yukarıdaki maddeler dışında —; Şikayet Kaydı Oluştur →25 |
| s25 | (ikon) →4; Ana Sayfaya Dön →4; Mesajlaşmaya Dön →19 |
| s26 | (ikon) →4; (ikon) —; (ikon) —; Kayıtlı Adreslerim Ev: Kadıköy, Caferağa Mah —; BiTadilat Güvence Havuzu Ödeme ve güvence si —; Bildirim Tercihleri SMS ve Uygulama İçi —; Yardım & Destek Merkezi SSS, canlı destek ve —; Gizlilik ve KVKK Veri güvenliği ve aydınlatm —; Usta Modu →27; Çıkış Yap →1; Ana Sayfa →4; Taleplerim →10; Mesajlar →19; Profil — |
| s27 | (ikon) →26; Tesisat (Seçildi) —; Elektrik E; Boya E; Klima E; İlçe Ekle —; Değiştir —; Dosya Seç —; Dosya Seç —; Başvuruyu İncelemeye Gönder →28 |
| s28 | Müsait →31; (ikon) —; Tümü 4 —; Acil (1) —; Planlı (3) —; Teklif Hazırla →29; Teklif Hazırla →29; Talepler —; İşlerim →32; Mesajlar →19; Müsaitlik →31 |
| s29 | (ikon) →28; Bugün (Önerilen) 14:00 – 17:00 Arası —; Yarın Sabah 09:00 – 12:00 Arası —; 6 Ay Garanti —; 12 Ay Garanti —; Teklifi Müşteriye Gönder →30 |
| s30 | (ikon) →28; Talepler Akışına Dön →28; Müsaitlik Takvimimi Düzenle →31 |
| s31 | (ikon) →28; (ikon) E; Delete —; Delete —; Delete —; Delete —; Yeni Bölge Ekle —; Değişiklikleri Kaydet →28 |
| s32 | (ikon) →28; Haritada Yol Tarifi Al —; Müşteriye Mesaj Yaz →19; Yükle —; İşi Bitirdim (Müşteriye Teslim Talebi Gönder →33; Sahada bir anlaşmazlık mı var? Durum Bildir  →24 |
| s33 | (ikon) →28; Eşleşen Talepler Akışına Dön →28; Müsaitlik ve Profil Ayarlarını Aç →31 |

Yolculuk testinin tam çıktısı: `scratch/audit/baseline/journey_flutter.txt`.
