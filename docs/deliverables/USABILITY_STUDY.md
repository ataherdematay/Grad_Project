# BiTadilat — Kullanılabilirlik Çalışması Planı

| | |
|---|---|
| Durum | **Plan.** Çalışma henüz yapılmadı; sonuç tabloları boştur |
| İlgili gereksinim | RAD hedef 6; RAD 3.3.1 "Unassisted Task Completion" ve "Learnability" |
| Sürüm | 0.2, 19 Kasım 2026 (0.1: 16 Kasım). Son kodla (c335a10) uyumlu; plan ve görevler değişmedi |
| Takvim | Plan ve pilot: 1–8 Aralık. Oturumlar: 9–15 Aralık. Bulgular ve yeniden test: 16–20 Aralık. Rapor: 22 Aralık. Testlerin teslimi: 25 Aralık 2026 (`TEST_PLAN.md`) |

## 1. Amaç ve ölçütler

RAD'daki ölçütler:

| # | Ölçüt | Kaynak |
|---|---|---|
| U1 | Çekirdek görevlerin en az **%80'i yardımsız** tamamlanır; en az **5 katılımcı** ile resmi kullanılabilirlik testi | RAD 1.3 hedef 6, 3.3.1 |
| U2 | İlk kez kullanan müşteri bir talebi **3 dakikadan kısa** sürede gönderir | RAD 3.3.1 |
| U3 | Usta yapılandırılmış bir teklifi **90 saniyeden kısa** sürede hazırlayıp gönderir | RAD 3.3.1 |

Ek (RAD'da yok, öneri): SUS puanı ≥ 68 (ortalama üstü) ve görev sonrası kolaylık puanı (SEQ) ≥ 5/7. Bunlar bu çalışmanın kendi hedefidir, RAD gereksinimi değildir.

"Çekirdek görev" tanımı: aşağıdaki G1–G8. Tamamlama oranı = (yardımsız başarıyla biten görev denemesi sayısı) / (denenen görev sayısı), tüm katılımcılar ve görevler üzerinden. Görev başına oran da raporlanır.

## 2. Katılımcılar

- **En az 5, hedef 6** kişi (bir kişinin oturumu bozulursa yedek).
- Karışım: en az 3 kişi "müşteri" bakışıyla (ev tadilatı yaptırmış ya da yaptıracak yetişkin), en az 2 kişi tadilat/onarım işiyle ilgili ya da ustalarla çalışmış (usta görevleri için). Herkes tüm görevleri yapar; usta görevlerinde "usta rolü" senaryosu okunur.
- En az 1 kişi 50 yaş üstü, en az 1 kişi daha önce hiç hizmet pazaryeri uygulaması kullanmamış olmalı.
- Ekip üyeleri ve ekibin yakın aile üyeleri **katılamaz**.
- Katılımcılar uygulamayı önceden görmemiş olmalı.
- Bir pilot oturum (ayrı kişi, sayıma dahil değil) görev metinlerini ve ölçüm düzenini sınamak için yapılır.

Katılımcı kayıt tablosu (kimlik yerine **K1…K6** kodu kullanılır):

| Kod | Yaş aralığı | Meslek grubu | Akıllı telefon deneyimi (1–5) | Pazaryeri uygulaması deneyimi | Bakış (müşteri / usta) |
|---|---|---|---|---|---|
| K1 | | | | | |
| K2 | | | | | |
| K3 | | | | | |
| K4 | | | | | |
| K5 | | | | | |
| K6 | | | | | |

## 3. Ortam ve donanım

- Uygulama **iOS Simulator** içinde çalışır (Apple geliştirici hesabı yok, gerçek cihaza kurulum yok). Katılımcı, büyük ekranlı bir Mac üzerinde Simulator'ü fare ile kullanır; dokunma hedefleri ve kaydırma gerçek parmakla birebir aynı değildir. Bu **bir sınırlamadır** ve raporda belirtilir. Mümkünse dokunmatik ekranlı iPad Simulator'ü ya da geliştirici bir cihaz kullanılır.
- Backend yerelde (`dev` profili), PostgreSQL ve tohum veri ile çalışır (JVM ile ya da `docker compose up --build`; Docker yolu bu makinede denenmedi, bkz. `docs/RUNNING.md`). Katılımcı e-posta kodu gerektiren akışlara (şifre sıfırlama, e-posta değişikliği) sokulmaz: `dev` profilinde kodlar e-posta yerine sunucu log'una yazılır. Her oturum öncesi `POST /api/v1/dev/reset` ile veri sıfırlanır (`docs/spec/SEED_DATA.md`).
- Ödeme (G3): Craftgate **sandbox** ve moderatörün verdiği **test kartı**. Sandbox erişilemezse G3 "ödeme ekranına kadar" ölçülür ve notlanır.
- Yönetici panelinde işlem gerektiren adımlar (usta onayı) moderatör tarafından yapılır; katılımcı yönetici görevi yapmaz.
- Ekran kaydı: yalnızca açık rıza ile (bölüm 8). Ses kaydı yapılmaz; moderatör notları yazılı alınır.
- Zaman ölçümü: moderatör ya da ikinci gözlemci kronometre ile; başlangıç "başla" komutu, bitiş görevin başarı ekranı.

## 4. Görevler

Her görev bir **senaryo metni** olarak okunur; uygulamadaki düğme adları söylenmez. Önkoşullar tohum veri ile sağlanır.

| ID | Rol | Görev (katılımcıya söylenen) | Başarı ölçütü | Süre hedefi | Bağlı gereksinim |
|---|---|---|---|---|---|
| G1 | Müşteri | "Uygulamaya yeni müşteri olarak kayıt ol." | Kayıt tamamlanır, ana ekran görünür (KVKK/koşul onayı işaretlenir; "KVKK metnini oku" artık TASLAK işaretli gerçek metni açar, hukukçu incelemesinden geçmemiştir) | ≤ 2 dk | UC01 |
| G2 | Müşteri | "Mutfağındaki musluk damlatıyor. Bunun için bir usta bulmak üzere acil bir talep oluştur." (kategori, adres, açıklama, en az 1 fotoğraf) | Talep yayımlanır ve talep listesinde görünür | **≤ 3 dk** | UC02, U2 |
| G3 | Müşteri | "Sana gelen teklifleri incele, birini seç ve ödemeyi yap." | Bir teklif kabul edilir ve ödeme sonucu `LOCKED` olur (sandbox) | ≤ 4 dk | UC05 |
| G4 | Müşteri | "Ustaya adresi bulabilmesi için bir mesaj yaz." | Mesaj gönderilir ve sohbette görünür | ≤ 1 dk | UC07 |
| G5 | Müşteri | "İş bitti. İşi onayla ve ustaya puan ver." | Onay verilir, puan gönderilir | ≤ 2 dk | UC09, UC10 |
| G6 | Usta | "Usta olarak giriş yaptın. Akışta gördüğün bir talebe, malzeme ve işçilikle ayrı kalemli bir teklif ver." | Teklif gönderilir, "tekliflerim"de görünür | **≤ 90 sn** | UC04, U3 |
| G7 | Usta | "Müşteri randevu saati önerdi. Başka bir saat öner." | Yeni aralık önerilir | ≤ 1 dk | UC06 |
| G8 | Usta | "İşe gittin. Uygulamada işin durumunu 'adrese ulaştım', 'başladım', 'bitirdim' olarak işle." | Üç adım sırayla tamamlanır | ≤ 1 dk 30 sn | UC08 |

İsteğe bağlı (başarı oranına dahil değil, gözlem için): G9 müşteri bir şikayet açar (UC13); G10 dili İngilizce'ye çevirir (TR/EN).

## 5. Yardım tanımı ve puanlama

Her görev denemesi şu üç sınıftan birine girer:

| Sınıf | Tanım | %80 hesabında |
|---|---|---|
| **Yardımsız başarı** | Katılımcı görevi ipucu almadan tamamladı | Başarı |
| **Yardımlı başarı** | Moderatör ipucu verdi, sözlü yönlendirdi, düğmeyi gösterdi ya da katılımcı 3. kez "ne yapacağımı bilmiyorum" dedi, sonra tamamladı | **Başarısız** |
| **Başarısız** | Görev tamamlanmadı ya da katılımcı vazgeçti ya da süre hedefinin iki katı aşıldı | Başarısız |

Moderatör yalnızca **tarafsız** yönlendirme yapabilir ("Ne düşünüyorsun?", "Sizce nereden devam edilir?"). Yönlendirme sayısı not edilir. Katılımcı 90 sn hiçbir ilerleme yapmazsa moderatör ipucu verir ve deneme "yardımlı" sayılır.

## 6. Ölçümler

Her görev için kaydedilenler: sınıf (yardımsız / yardımlı / başarısız), süre (sn), hata sayısı (yanlış dokunuş, geri dönüş, doğrulama hatası), dikkat çeken yorum.

Her görevden sonra **SEQ** ("Bu görev ne kadar kolaydı?", 1 çok zor … 7 çok kolay).

Oturum sonunda **SUS** (10 madde, 5'li Likert). Türkçe madde metni taslağı (resmi Türkçe uyarlama kullanılacaksa onunla değiştirilmelidir):

1. Bu uygulamayı sık sık kullanmak isteyeceğimi düşünüyorum.
2. Uygulamayı gereksiz yere karmaşık buldum.
3. Uygulamanın kullanımı kolaydı.
4. Bu uygulamayı kullanabilmek için teknik bir kişinin desteğine ihtiyaç duyacağımı düşünüyorum.
5. Uygulamadaki işlevlerin iyi bütünleştirildiğini gördüm.
6. Uygulamada çok fazla tutarsızlık olduğunu düşündüm.
7. Çoğu insanın bu uygulamayı çok çabuk öğreneceğini düşünüyorum.
8. Uygulamayı kullanması çok zahmetliydi.
9. Uygulamayı kullanırken kendimi çok güvende hissettim.
10. Uygulamayı kullanmaya başlamadan önce pek çok şey öğrenmem gerekti.

SUS puanı: tek numaralı maddeler için (yanıt − 1), çift numaralı maddeler için (5 − yanıt); toplam × 2,5 (0–100).

Ek sorular: "En zorlandığın an?", "Beğendiğin bir şey?", "Para/emanet akışını anladın mı (kısaca anlat)?", "Adresinin ustaya ne zaman gösterildiğini biliyor musun?".

## 7. Oturum akışı (yaklaşık 45 dakika)

| Süre | Adım |
|---|---|
| 0–5 dk | Karşılama, amaç ("uygulamayı sınıyoruz, sizi değil"), **onam formu** (bölüm 8), ön anket |
| 5–8 dk | Sesli düşünme açıklaması ve ısınma (uygulama dışı örnek) |
| 8–35 dk | G1–G8 (rol değişimlerinde veriyi sıfırlamadan hesabı değiştir), her görev sonrası SEQ |
| 35–42 dk | SUS ve ek sorular |
| 42–45 dk | Teşekkür, sorular, kayıt silme/anonimleştirme hatırlatması |

Moderatör betiği ilkeleri: görevleri kelimesi kelimesine oku; ekrandaki etiketleri söyleme; sessiz kal; ipucu verdiğinde saati ve içeriği yaz.

## 8. Onam metni (taslak)

> **Gönüllü Katılım ve Kişisel Verilerin İşlenmesine İlişkin Aydınlatma / Açık Rıza Metni (TASLAK)**
>
> Bu çalışma, [Üniversite adı] Yazılım Mühendisliği Bölümü COMP/SOFT4902 Bitirme Projesi kapsamında geliştirilen **BiTadilat** mobil uygulamasının kullanılabilirliğini değerlendirmek amacıyla yapılmaktadır. Sizi değil, uygulamayı değerlendiriyoruz; yapamadığınız bir şey sizin hatanız değildir.
>
> **Ne yapacaksınız?** Yaklaşık 45 dakika sürecek bir oturumda, uygulamayla ilgili birkaç görevi (ör. talep oluşturmak, teklif vermek) yapmanızı ve düşüncelerinizi paylaşmanızı isteyeceğiz. Uygulamada **gerçek ödeme yapılmayacak**; ödeme adımında yalnızca bir test kartı ve sandbox ortamı kullanılacaktır. Lütfen gerçek kişisel bilgilerinizi (kimlik, adres, banka/kart bilgisi) uygulamaya **girmeyin**; size uydurma bilgiler verilecektir.
>
> **Hangi verileri topluyoruz?** Yaş aralığı, meslek grubu, deneyim düzeyi; görevlerdeki başarı, süre, hata ve yorumlarınız; SUS anket yanıtlarınız. Yalnızca sizin **ayrıca onay vermeniz hâlinde** ekran kaydı alınır (ses kaydı alınmaz). Adınız sonuç raporlarında **yer almaz**; katılımcılar K1, K2… kodlarıyla anılır.
>
> **Veri sorumlusu ve amaç:** [Proje sahibi adı]. Veriler yalnızca kullanılabilirlik değerlendirmesi ve bitirme tezinin yazımı için işlenir, üçüncü kişilerle paylaşılmaz.
>
> **Saklama:** Ekran kayıtları tez teslimi (en geç [tarih]) sonrası silinir. Anonim sonuç tabloları tezde kalabilir.
>
> **Haklarınız:** Katılım gönüllüdür; istediğiniz an gerekçe göstermeden çekilebilir, verilerinizin silinmesini isteyebilirsiniz (6698 sayılı KVKK madde 11). Başvuru: [e-posta adresi].
>
> ☐ Okudum, gönüllü olarak katılıyorum.
> ☐ Ekran kaydı alınmasına izin veriyorum. (İsteğe bağlı)
>
> Ad Soyad: ____________  Tarih: ____________  İmza: ____________

Not: bu metin bir taslaktır; hukuki inceleme yapılmamıştır. 18 yaşından küçük katılımcı alınmaz. Köşeli parantezli alanlar doldurulmalıdır.

## 9. Sonuç tabloları (boş)

### 9.1 Görev bazında deneme sonuçları

Her hücreye **Y** (yardımsız başarı), **H** (yardımlı), **B** (başarısız) ve süre (sn) yazılır, ör. `Y 142`.

| Görev | K1 | K2 | K3 | K4 | K5 | K6 | Yardımsız başarı oranı | Medyan süre | Süre hedefi | Hedef karşılandı |
|---|---|---|---|---|---|---|---|---|---|---|
| G1 Kayıt | | | | | | | | | ≤ 120 sn | |
| G2 İlk talep | | | | | | | | | **≤ 180 sn** | |
| G3 Teklif kabul + ödeme | | | | | | | | | ≤ 240 sn | |
| G4 Mesaj | | | | | | | | | ≤ 60 sn | |
| G5 Onay + puan | | | | | | | | | ≤ 120 sn | |
| G6 Teklif ver | | | | | | | | | **≤ 90 sn** | |
| G7 Randevu önerisi | | | | | | | | | ≤ 60 sn | |
| G8 İş aşamaları | | | | | | | | | ≤ 90 sn | |
| **Genel** | | | | | | | **(hedef ≥ %80)** | | | |

### 9.2 Özet ölçüler

| Ölçü | Hedef | Sonuç | Karşılandı mı |
|---|---|---|---|
| Yardımsız tamamlama oranı (tüm görev denemeleri) | ≥ %80 | | |
| Katılımcı sayısı | ≥ 5 | | |
| G2 ilk talep süresi (medyan ve en uzun) | < 3 dk | | |
| G6 teklif süresi (medyan ve en uzun) | < 90 sn | | |
| SUS ortalaması | ≥ 68 (öneri) | | |
| SEQ ortalaması | ≥ 5 (öneri) | | |

### 9.3 SUS puanları

| Kod | M1 | M2 | M3 | M4 | M5 | M6 | M7 | M8 | M9 | M10 | SUS (0–100) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| K1 | | | | | | | | | | | |
| K2 | | | | | | | | | | | |
| K3 | | | | | | | | | | | |
| K4 | | | | | | | | | | | |
| K5 | | | | | | | | | | | |
| K6 | | | | | | | | | | | |
| Ortalama | | | | | | | | | | | |

### 9.4 Kullanılabilirlik sorunları

Önem: **4** engel (görev tamamlanamaz), **3** büyük (yardım gerekir), **2** küçük (yavaşlatır), **1** kozmetik.

| Sorun no | Görev | Gözlem (kaç kişide) | Önem | Öneri | Kusur günlüğü no | Düzeltildi mi | Yeniden test sonucu |
|---|---|---|---|---|---|---|---|
| U-001 | | | | | | | |
| U-002 | | | | | | | |

### 9.5 Yeniden test

Önem 3–4 sorunlar düzeltildikten sonra, en az 2 yeni katılımcı ile ilgili görevler tekrarlanır (RAD D5.3: "bulgular ve yeniden test").

| Görev | Düzeltme | Yeni katılımcı | Sonuç | Süre |
|---|---|---|---|---|
| | | | | |

## 10. Çözümleme kuralları

- Yardımsız tamamlama oranı **tüm katılımcı × görev** denemeleri üzerinden hesaplanır; 5 katılımcı ve 8 görevde 40 deneme olur. Her başarısızlık oranı yaklaşık 2,5 puan düşürür; ölçüt anlamlı ama küçük örneklemlidir. Rapora hem oran hem sayılar yazılır (ör. 34/40 = %85) ve örneklemin küçük olduğu belirtilir.
- Süreler için ortalama yerine **medyan ve en uzun değer** raporlanır; yardımlı ve başarısız denemeler süre hedefi hesabına katılmaz, ayrıca listelenir.
- Hedefin altında kalan görevler için sorun tablosu (9.4) doldurulur; çözüm önerisi ve yeniden test planı yazılır.
- Sonuç, 25 Aralık'ta `TEST_REPORT` içindeki "İşlevsel olmayan ölçümler" tablosuna (A.6) işlenir.

## 11. Riskler ve sınırlamalar

| Risk | Önlem |
|---|---|
| Katılımcı bulunamaz | Aralık başında davet; yedek 6. katılımcı |
| Simulator fare kullanımı gerçek dokunmayı yansıtmaz | Raporda sınırlama olarak belirt; mümkünse iPad Simulator / dokunmatik ekran |
| Sandbox ödeme çalışmaz | G3'ü ödeme ekranına kadar ölç, notla |
| Moderatör etkisi | Betik, tarafsız ipuçları, ikinci gözlemci |
| Tohum veri adreslerinin gerçek kişisel veri sanılması | Uydurma veri; onam metni uyarısı |
| Çalışmanın RAD hedefini kanıtlamaya yetmemesi (n = 5) | Küçük örneklem uyarısı, yeniden test, nitel bulgular |

## 12. Teslim edilecekler

1. Doldurulmuş sonuç tabloları (9.1–9.5) ve katılımcı kayıt tablosu (kodlu).
2. İmzalı onam formları (basılı, **depoya girmez**, ayrı güvenli yerde saklanır).
3. Sorun listesi ve düzeltme/yeniden test kaydı.
4. Özet: `TEST_REPORT` içinde bir sayfa ve tezin değerlendirme bölümüne tablo.
