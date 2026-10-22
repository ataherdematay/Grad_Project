# BiTadilat — Kapsamlı Product Manager & QA Tester Denetim Raporu ve Uygulama Planı

**Tarih:** 22 Ekim 2026  
**Roller:** Kıdemli Product Manager (PM) & Baş QA Test Mühendisi  
**İncelenen Kapsam:** BiTadilat 33 Ekranlık UI/UX Prototipi, Google Stitch Projesi (`15188622157250602404`), `index.html` Simülatörü ve Ekran Kaynak Kodları  
**Referans Dokümanlar:** `BI_TADILAT_AI_HANDOFF.md`, `BiTadilatDESIGN.md`, `BiTadilatUI_UX_PROGRESS.md`

---

## 1. Yönetici Özeti (Executive Summary)

BiTadilat projesinin 33 ekranı üzerinde hem **Product Manager (Ürün Yöneticisi)** gözüyle ürün mimarisi, kullanıcı akışları ve rol sınırları, hem de **QA Tester (Test Mühendisi)** gözüyle buton etkileşimleri, form doğrulama mekanizmaları, tasarım sistemi kuralları ve DOM seviyesindeki script çakışmaları incelenmiştir.

### Temel Tespitler:
1. **Kritik Rol İhlali (Müşteri & Usta Karışıklığı):** Müşteri ana sayfasındaki "Profil" sekmesi müşteriyi doğrudan **Usta İş Akışına** fırlatmakta; Usta iş yürütme ekranındaki "İşi Bitirdim" butonu ise ustayı **Müşterinin Onay ve Puanlama Ekranına** taşımaktadır. Müşteri ve Usta rolleri birbirinden bağımsız iki ayrı deneyim olması gerekirken birbirine düğümlenmiştir.
2. **Kırık ve Tepkisiz Butonlar (Interaction Failures):** Telefon doğrulama ekranındaki inline `handleContinue()` scripti butonun `pointer-events-none` ile kilitlenmesine ve SMS ekranına hiç geçmemesine yol açmaktadır. Ayrıca tüm ekran dosyalarında çift enjekte edilmiş 650 satırlık scriptler bulunmakta ve gevşek metin eşleştirmeleri (`innerText.includes`) yüzünden butonlar yanlış yönlendirme yapmaktadır.
3. **Kural İhlalleri (UI/UX Violations):** Platform kuralı olarak **kesinlikle yasaklanmış** doğrudan telefon arama butonları (`call` ikonu) iki ekranda tespit edilmiştir. Ana ekran seviyesi dışında alt gezinme çubuğu (Bottom Navigation) bulunması yasak olduğu halde ara ekranlarda alt bar kalıntıları bulunmaktadır. Ayrıca 9 ekranda standart "Tesisat" yerine kural dışı "Sıhhi Tesisat" ifadesi kullanılmaktadır.
4. **Eksik 4 Kritik Ekran (Missing Pages):** Müşteri Profil Ekranı, Müşteri Taleplerim Listesi, Usta Belge Yükleme/Kayıt Ekranı ve Usta Teslim Talebi Onay Ekranı mevcut 33 ekran arasında bulunmamaktadır.

---

## 2. Kritik Mimari Hatalar ve Rol Karmaşası Analizi

```mermaid
flowchart TD
    subgraph MUSTERI_FLOW["Müşteri Deneyimi (Customer)"]
        M1["SCR-01 Rol Seçimi (Ev Sahibi)"] --> M2["SCR-02 Telefon & SMS Doğrulama"]
        M2 --> M4["SCR-04 Müşteri Ana Sayfası"]
        M4 --> M_WIZ["4 Adımlı Talep Sihirbazı"]
        M_WIZ --> M9["SCR-09 Talep Yayınlandı"]
        M9 --> M10["SCR-10 Teklifler & Karşılaştırma"]
        M10 --> M14["SCR-14 Randevu & Onay"]
        M14 --> M17["SCR-17 İş Alanı & Mesajlaşma"]
        M17 --> M21["SCR-21 Teslim Onayı & Puanlama"]
    end

    subgraph USTA_FLOW["Hizmet Profesyoneli Deneyimi (Usta)"]
        U_ONB["[EKSİK] Usta Kayıt & Belge Yükleme"] -.-> U25["SCR-25 Usta Eşleşen Talepler"]
        U25 --> U26["SCR-26 Teklif Hazırlama & Gönderim"]
        U25 --> U28["SCR-28 Profil & Müsaitlik"]
        U25 --> U29["SCR-29 Usta İş Yürütme"]
        U29 -.-> U_DONE["[EKSİK] Usta Teslim Bildirimi"]
    end

    %% BUG TRANSITIONS
    M4 -- "BUG 1: Tab 4 'Profil' tıklandığında" --> U25
    U29 -- "BUG 2: 'İşi Bitirdim' tıklandığında ustayı müşteri onayına atıyor" --> M21
    U29 -- "BUG 3: 'Müşteriye Mesaj' tıklandığında müşteri perspektifi açılıyor" --> M17

    style MUSTERI_FLOW fill:#0F4C5C15,stroke:#0F4C5C,stroke-width:2px
    style USTA_FLOW fill:#107A5B15,stroke:#107A5B,stroke-width:2px
```

### Detaylı Rol Karmaşası Maddeleri:

| No | Tespit Edilen Rol Hatası | Mevcut Davranış | Olması Gereken Doğru Davranış |
| :--- | :--- | :--- | :--- |
| **R-01** | **Müşteri Profil Sekmesi Usta Akışına Geçiyor** | `cc1f55` (Müşteri Ana Sayfa) alt barında 4. sekme olan "Profil" tıklandığında kullanıcı `11b9cb` (Usta Eşleşen Talepler Akışı) ekranına aktarılıyor. | Müşteriye ait özel `Müşteri Profil Ekranı` açılmalıdır (Ad, telefon, kayıtlı adresler, bildirimler, destek ve açıkça belirtilmiş 'Usta Moduna Geç' geçişi). |
| **R-02** | **Usta İşi Tamamladığında Kendi İşini Onaylıyor** | `8ba8c3` (Usta İş Yürütme) ekranında usta "İşi Bitirdim (Müşteriye Teslim Talebi Gönder)" butonuna bastığında `d48526` (Müşteri Teslim Onayı) ekranına yönlendiriliyor ve müşteri adına işi onaylayıp değerlendirme yapıyor. | Usta için "Teslim Talebi Müşteriye İletildi - Onay Bekleniyor" durum kartı/ekranı gösterilmeli ve usta kendi aktif işler listesine dönmelidir. Müşteri ekranına asla geçmemelidir. |
| **R-03** | **Usta İçin Onboarding ve Doğrulama Yok** | `0c06b0` ekranında "Hizmet Profesyoneli" seçilip devam edildiğinde usta hiçbir telefon doğrulaması veya belge yüklemesi yapmadan doğrudan `11b9cb` talep akışına düşüyor. | Admin ekranında (`612429`) incelenen Vergi Levhası, Ustalık Belgesi ve Adli Sicil Kaydı'nın yüklendiği bir `Usta Onboarding & Belge Yükleme` adımı bulunmalıdır. |
| **R-04** | **Mesajlaşma Ekranında Rol İhlali** | `c9aa92` mesajlaşma ekranı başlığında "Mavi Hat Tesisat (Doğrulanmış Uzman - Çevrimiçi)" yazmaktadır. Usta ekranından mesajlaşmaya girildiğinde usta kendisiyle konuşur gibi görünmekte, geri basıldığında ise müşterinin `f3e7de` ekranına dönmektedir. | Mesajlaşma ekranı usta tarafından açıldığında müşteri ismi ("Ali Yılmaz - Ev Sahibi"), müşteri tarafından açıldığında usta profili ("Mavi Hat Tesisat") gösterilmelidir. Geri butonu da geldikleri role ait ekrana dönmelidir. |
| **R-05** | **Taleplerim Sekmesi Yanlış Ekran Açıyor** | `cc1f55` ekranında alt bardaki 2. sekme ("Taleplerim") tıklandığında `94a730` (Talep Yayınlandı tebrik kartı) açılıyor. | Müşterinin aktif ve geçmiş taleplerini listeleyen bir `Taleplerim Listesi` açılmalıdır. |

---

## 3. Ekran Başına Detaylı QA ve UI/UX Denetim Matrisi (33 Ekran)

Aşağıdaki tablo 33 ekranın tamamını satır satır incelemekte; buton durumlarını, UI tutarsızlıklarını ve yönlendirme buglarını listelemektedir:

### 3.1. Akış 1: Müşteri Giriş & Onboarding (SCR-01 .. SCR-03)

| Ekran ID / No | Ekran Adı | Butonlar & Etkileşimler | Tespit Edilen Bug & UI/UX Tutarsızlıkları | Durum |
| :--- | :--- | :--- | :--- | :--- |
| `0c06b06e`<br>(Adım 01) | Hoş Geldiniz & Rol Seçimi (SCR-01) | • `role-homeowner`<br>• `role-professional`<br>• `btn-continue`<br>• `Giriş yap` | **BUG:** Orijinal `selectRole()` fonksiyonu `btn-continue` üzerindeki `disabled` niteliğini kaldırmıyor ve rengini `#0F4C5C` yapmıyor. Çift script çakışması nedeniyle usta seçilse bile müşteri akışına gidebiliyor. | 🔴 Kritik |
| `fbbe0f40`<br>(Adım 02) | Telefon Doğrulama | • `arrow_back`<br>• `submit-btn` ("Devam Et")<br>• Geri dön linki | **BUG:** Inline `handleContinue()` fonksiyonu butonu "SMS Gönderiliyor..." animasyonuna sokup `pointer-events-none` ekliyor, ardından "Kod Gönderildi!" yazıp kalıyor; navigasyonu tetiklemiyor. Sayfa donuyor. | 🔴 Kritik |
| `42c148a1`<br>(Adım 03) | SMS Doğrulama Kodu | • `arrow_back`<br>• `verify-submit-btn` ("Doğrula")<br>• Numarayı değiştir<br>• Tekrar kod gönder | **UX SORUNU:** 6 haneli OTP kutuları manuel doldurulmadan buton `disabled` kalıyor. Prototipte kullanıcı testini kolaylaştıracak otomatik 6 hane tamamlama mekanizması yok. | 🟡 Orta |

### 3.2. Akış 2: 4 Adımlı Talep Sihirbazı (SCR-04 .. SCR-09)

| Ekran ID / No | Ekran Adı | Butonlar & Etkileşimler | Tespit Edilen Bug & UI/UX Tutarsızlıkları | Durum |
| :--- | :--- | :--- | :--- | :--- |
| `cc1f5566`<br>(Adım 04) | Müşteri Ana Sayfası (Yeni Kullanıcı) | • `Talep oluşturmaya başla`<br>• Kategori kartları (8 adet)<br>• Alt Navigasyon (4 sekme) | **BUG:** Alt bar "Profil" sekmesi Usta Feed'e (`11b9cb`) gidiyor (Rol karmaşası). Alt bar "Taleplerim" sekmesi `94a730` tebrik ekranına gidiyor. Kategori kartları doğrudan Adım 1'e seçili kategoriyi iletmiyor. | 🔴 Kritik |
| `44c003fe`<br>(Adım 05) | Talep Adım 1/4: Hizmet & Öncelik (SCR-02) | • `arrow_back`<br>• 8 Kategori butonu<br>• 2 Aciliyet butonu<br>• `wizard-primary-cta` | **ÇALIŞIYOR:** Kategori ve aciliyet seçilmeden CTA inaktif; seçildiğinde aktifleşiyor. Adım 2'ye geçiş düzgün. | 🟢 Başarılı |
| `b3c3c284`<br>(Adım 06) | Talep Adım 2/4: Konum & Detay | • `arrow_back`<br>• İlçe seç dropdown<br>• Konumumu kullan<br>• Hazır soru çipleri (3 adet)<br>• Devam Et | **UX SORUNU:** Metin alanına 20 karakter girilmediğinde butonun pasif kalması durumu prototipte görsel olarak takılabiliyor. | 🟡 Düşük |
| `585d649f`<br>(Adım 07) | Talep Adım 3/4: Fotoğraflar & Ek Bilgi | • `arrow_back`<br>• Fotoğraf Ekle kartı<br>• Devam Et | **ÇALIŞIYOR:** Fotoğraf opsiyonel olduğu için buton varsayılan olarak aktif, Adım 4'e geçiyor. | 🟢 Başarılı |
| `a0949c91`<br>(Adım 08) | Talep Adım 4/4: Talebi Gözden Geçir | • `arrow_back`<br>• 4 adet `Düzenle` butonu<br>• `Talebi yayınla` | **BUG:** 4 ayrı "Düzenle" butonunun tamamı Adım 1'e yönlendiriyor. Oysa Hizmet düzenleme Adım 1'e, Konum düzenleme Adım 2'ye, Fotoğraf düzenleme Adım 3'e gitmelidir. | 🔴 Yüksek |
| `94a730ce`<br>(Adım 09) | Talep Yayınlandı — Teklif Bekleniyor | • `arrow_back`<br>• `Taleplerime git`<br>• `Ana sayfaya dön` | **ÇALIŞIYOR:** Butonlar Gelen Teklifler (`994e3b`) veya Ana Sayfa (`cc1f55`) arasında mantıklı yönleniyor. | 🟢 Başarılı |

### 3.3. Akış 3: Teklif Karşılaştırma, Usta Profili & Randevu (SCR-10 .. SCR-16)

| Ekran ID / No | Ekran Adı | Butonlar & Etkileşimler | Tespit Edilen Bug & UI/UX Tutarsızlıkları | Durum |
| :--- | :--- | :--- | :--- | :--- |
| `994e3b4f`<br>(Adım 10) | Gelen Teklifler Listesi (SCR-04) | • `arrow_back`<br>• `Teklifleri Karşılaştır`<br>• 3 Teklif kartı / "İncele" | **KURAL İHLALİ:** Kart başlığında "Kaya Sıhhi Tesisat" yazarak "Tesisat" standardı ihlal edilmiş. Buton yönlendirmeleri aktif. | 🟡 Orta |
| `ea7af2d7`<br>(Adım 11) | Teklif Detayı & Kapsam | • `arrow_back`<br>• `Ustaya soru sor`<br>• `Teklifi kabul et`<br>• Profil avatarı/ismi | **ÇALIŞIYOR:** Ustaya soru sor chat ekranına (`c9aa92`), Kabul et ise onay modalına (`58f999`) gidiyor. | 🟢 Başarılı |
| `1fc70722`<br>(Adım 12) | Teklifleri Karşılaştır (Matris) | • `arrow_back_ios_new`<br>• 2 Teklif İncele butonu | **KURAL İHLALİ:** Kartta "Kaya Sıhhi Tesisat" geçiyor. İncele butonu detay ekranına dönüyor. | 🟡 Düşük |
| `98cd20d6`<br>(Adım 13) | Hizmet Profesyoneli Profili (SCR-05) | • `arrow_back`<br>• `Teklife dön`<br>• `Ustaya soru sor` | **KURAL İHLALİ:** Alt unvanda "Sıhhi Tesisat ve Bakım Ustası" yazıyor (Kural: "Tesisat"). Yönlendirmeler çalışıyor. | 🟡 Düşük |
| `58f9993b`<br>(Adım 14) | Teklif Kabul Onayı (Güvence Havuzu) | • `arrow_back`<br>• `Teklifi kabul et` (x2)<br>• `Vazgeç` | **UI TUTARSIZLIĞI:** DOM içinde hem arkada kalan sayfada hem de açılan alt sayfada (bottom sheet) iki ayrı `Teklifi kabul et` butonu bulunuyor, event çakışması yaratıyor. | 🟡 Orta |
| `7c6ec3a0`<br>(Adım 15) | Randevu Zamanı Seç (SCR-06) | • `arrow_back`<br>• Gün kartları (5 adet)<br>• Saat slotları (4 adet)<br>• `Randevu talebi gönder` | **ÇALIŞIYOR:** Gün ve saat seçilmeden CTA disabled; seçim yapılınca aktifleşerek `3bd2af` ekranına geçiyor. | 🟢 Başarılı |
| `3bd2af`e8<br>(Adım 16) | Randevu Talebi İletildi | • `arrow_back`<br>• `Talep detayına git`<br>• `Ana sayfaya dön` | **ÇALIŞIYOR:** İş Alanı (`f3e7de`) veya Ana Sayfa (`cc1f55`) yönlendirmesi düzgün. | 🟢 Başarılı |

### 3.4. Akış 4: Aktif İş, Mesajlaşma, Teslim & Şikayet (SCR-17 .. SCR-24)

| Ekran ID / No | Ekran Adı | Butonlar & Etkileşimler | Tespit Edilen Bug & UI/UX Tutarsızlıkları | Durum |
| :--- | :--- | :--- | :--- | :--- |
| `f3e7de80`<br>(Adım 17) | İş Alanı — Randevu Onaylandı | • `arrow_back`<br>• `Mesajlar`<br>• `İş ilerlemesi`<br>• `Randevuyu değiştir/iptal`<br>• `Ustaya mesaj gönder` | **KURAL İHLALİ:** Kartta "Sıhhi Tesisat" ifadesi geçiyor. Yönlendirmeler çalışıyor. | 🟡 Düşük |
| `c9aa92f5`<br>(Adım 18) | Usta ile Mesajlaşma (SCR-07) | • `arrow_back`<br>• `attach_file`<br>• `photo_camera`<br>• `send` | **KURAL İHLALİ & ROL BUGI:** Başlıkta "Sıhhi Tesisat" geçiyor. Usta tarafından girildiğinde de müşteri başlığı görünüyor. Back butonu usta için usta ekranına değil müşteri iş alanına dönüyor. | 🔴 Yüksek |
| `b89d998c`<br>(Adım 19) | İş Aşamaları ve İlerleme Takibi (SCR-08) | • `arrow_back`<br>• `call` (Telefon ikonu)<br>• `Ustaya Mesaj Gönder`<br>• `Sorun bildir`<br>• Alt bar | **KESİNLİKLE YASAK KURAL İHLALİ:** 1) Ekranda platform dışı iletişime yol açan doğrudan **telefon arama butonu (`call`)** bulunmaktadır!<br>2) Ana ekran seviyesi dışında **Alt Bar (Bottom Nav)** kalıntısı bulunmaktadır! | 🔴 Kritik |
| `6acc9307`<br>(Adım 20) | Randevu İptal / Değişiklik (SCR-09) | • `arrow_back`<br>• `Randevuyu İptal Et`<br>• `Yeni Tarih İste`<br>• `İptal Etmeyi Onayla` | **UX SORUNU:** İptal ve tarih değişikliği akışı aynı ekranda sıkışmış durumda. Yeni tarih iste butonunun gideceği randevu ekranı bağlantısı eksik. | 🟡 Orta |
| `d485263b`<br>(Adım 21) | İş Tamamlama ve Teslim Onayı (SCR-10) | • `arrow_back`<br>• `İşi Onayla ve Değerlendirmeye Geç`<br>• `Sorun bildir`<br>• Alt bar | **KURAL İHLALİ:** Ara onay ekranında **Alt Navigasyon Çubuğu (Bottom Nav)** bulunmaktadır. Bu kurala aykırıdır. | 🔴 Yüksek |
| `db8a1b36`<br>(Adım 22) | Hizmet Değerlendirme ve Puanlama (SCR-11) | • `arrow_back`<br>• 5 Yıldız puanlama<br>• Çipler (Temiz işçilik vb.)<br>• `Değerlendirmeyi Gönder` | **ÇALIŞIYOR:** Değerlendirme gönderildiğinde müşteri ana sayfasına dönüyor. | 🟢 Başarılı |
| `488f3698`<br>(Adım 23) | Şikayet ve Uyuşmazlık Bildirimi (SCR-12) | • `arrow_back`<br>• Kategori seçimi<br>• Kanıt ekle<br>• `Şikayet Dosyasını Oluştur` | **UX EKSİKLİĞİ:** Dosya yükleme çipi tıklanamıyor. Şikayet oluştur butonu durumu `3bb4b9` ekranına başarıyla iletiyor. | 🟡 Düşük |
| `3bb4b954`<br>(Adım 24) | Şikayet İletildi ve Durum Takibi (SCR-13) | • `arrow_back`<br>• `Taleplerime ve Ana Sayfaya Dön`<br>• `Mesaj Kayıtlarını Görüntüle` | **ÇALIŞIYOR:** Yönlendirmeler sorunsuz çalışıyor. | 🟢 Başarılı |

### 3.5. Akış 5: Hizmet Profesyoneli (Usta) Akışı (SCR-14 .. SCR-18)

| Ekran ID / No | Ekran Adı | Butonlar & Etkileşimler | Tespit Edilen Bug & UI/UX Tutarsızlıkları | Durum |
| :--- | :--- | :--- | :--- | :--- |
| `11b9cb02`<br>(Adım 25) | Usta Eşleşen Talepler Akışı (SCR-14) | • Filtreler (Tümü, Acil, Planlı)<br>• Konum seçici<br>• Talep kartları ("Teklif Hazırla")<br>• Usta Alt Barı (4 sekme) | **ÇALIŞIYOR & KISMİ ROL HATASI:** Usta alt barındaki sekmeler (İşlerim, Müsaitlik) çalışıyor. Ancak müşteri profilinden yanlışlıkla buraya geçilebiliyor. | 🟡 Orta |
| `b9086f10`<br>(Adım 26) | Usta Teklif Hazırlama (SCR-15) | • `arrow_back`<br>• Saat aralığı seçici<br>• `Yapılandırılmış Teklifi Gönder` | **KURAL İHLALİ:** Hizmet alanında "Sıhhi Tesisat Onarımı" yazıyor (Kural: "Tesisat"). Gönderim butonu Teklif Gönderildi (`82f9d7`) ekranına gidiyor. | 🟡 Düşük |
| `82f9d783`<br>(Adım 27) | Usta Teklif Gönderildi Onayı (SCR-16) | • `close` (X ikonu)<br>• `Talepler Akışına Dön`<br>• `Profil ve Müsaitlik Ayarları` | **EKSİK BUTON:** Başlıkta standart geri butonu (`arrow_back`) yok, yalnızca `close` ikonu var. | 🟡 Düşük |
| `fc6f0f8e`<br>(Adım 28) | Usta Profil ve Müsaitlik (SCR-17) | • `arrow_back`<br>• İlçe sil/ekle etiketleri<br>• Haftalık saat dilimi butonları | **KURAL İHLALİ:** Açıklama metninde "sıhhi tesisat tecrübesi" geçiyor. Etkileşimler çalışıyor. | 🟡 Düşük |
| `8ba8c346`<br>(Adım 29) | Usta İş Yürütme ve Aşama Yönetimi (SCR-18) | • `arrow_back`<br>• `call` (Telefon ikonu)<br>• Harita Yol Tarifi<br>• Müşteriye Mesaj Yaz<br>• `İşi Bitirdim` | **KRİTİK KURAL VE ROL İHLALİ:**<br>1) Ekranda yasaklanmış doğrudan **telefon arama butonu** var!<br>2) "İşi Bitirdim" butonu ustayı **Müşteri Teslim Onay Ekranına (`d48526`)** gönderiyor (Kendi işini onaylama bugı)! | 🔴 Kritik |

### 3.6. Akış 6: Yönetici Web Portalı & Tanıtım Web (SCR-19 .. SCR-22)

| Ekran ID / No | Ekran Adı | Butonlar & Etkileşimler | Tespit Edilen Bug & UI/UX Tutarsızlıkları | Durum |
| :--- | :--- | :--- | :--- | :--- |
| `612429fd`<br>(Adım 30) | Yönetici Web: Belge İnceleme (SCR-19) | • Sol menü (Belgeler, Şikayetler, Hesaplar)<br>• Filtreler<br>• `Tam Ekran Belge`<br>• `Profili Onayla` / `Reddet` | **KURAL İHLALİ:** "Sıhhi Tesisat & Isıtma Sistemleri" yazıyor. Masaüstü görünümü düzgün çalışıyor. | 🟡 Düşük |
| `cb00d677`<br>(Adım 31) | Yönetici Web: Şikayet Merkezi (SCR-20) | • Sol menü<br>• Şikayet listesi<br>• `Uyuşmazlığı Çöz`<br>• `Şikayeti Kapat` | **KURAL İHLALİ:** "Kemal Usta (Sıhhi Tesisat)" ifadesi geçiyor. Masaüstü görünümü düzgün. | 🟡 Düşük |
| `5ce8968e`<br>(Adım 32) | Yönetici Web: Hesap Yönetimi (SCR-21) | • Sol menü<br>• Kullanıcı/Usta tablosu<br>• `Detay Gör`<br>• `Askıya Al` | **ÇALIŞIYOR:** Tablo ve aksiyon butonları yerinde. | 🟢 Başarılı |
| `164cd336`<br>(Adım 33) | BiTadilat Tanıtım ve Karşılama Sitesi (SCR-22) | • `Usta Çağır` (Müşteri Başlat)<br>• `Usta Olarak Katıl` (Usta Başlat)<br>• Dil butonu (TR/EN) | **ÇALIŞIYOR:** Butonlar rol ayrımına göre sırasıyla SCR-01 veya Usta akışına yönlendiriyor. | 🟢 Başarılı |

---

## 4. Eksik Ekranlar Kataloğu (Missing Screens)

Mevcut prototipte iki ana rol arasındaki geçişleri ve gerçek bir uygulama deneyimini tamamlamak için üretilmesi gereken **4 kritik ekran** şunlardır:

```mermaid
graph LR
    subgraph EKSIK_EKRANLAR["Üretilmesi Gereken 4 Eksik Ekran"]
        S_NEW1["1. Müşteri Profil Ekranı (SCR-C-PROF)"]
        S_NEW2["2. Müşteri Taleplerim Listesi (SCR-C-REQ)"]
        S_NEW3["3. Usta Onboarding & Belge Yükleme (SCR-P-ONB)"]
        S_NEW4["4. Usta Teslim Talebi İletildi Onayı (SCR-P-DONE)"]
    end
    
    M_HOME["cc1f55 Müşteri Ana Sayfa"] --> |Tab 4: Profil| S_NEW1
    M_HOME --> |Tab 2: Taleplerim| S_NEW2
    ROLE_SEL["0c06b0 Rol Seçimi: Usta"] --> S_NEW3
    P_EXEC["8ba8c3 Usta İşi Bitirdim"] --> S_NEW4
    
    style EKSIK_EKRANLAR fill:#E8752515,stroke:#E87525,stroke-width:2px
```

1. **Müşteri Profil Ekranı (`SCR-C-PROF`):**
   - **Gerekçe:** Müşteri ana sayfasındaki alt barın 4. sekmesi tıklandığında usta ekranına geçilmesini engeller.
   - **İçerik:** Kullanıcı adı/soyadı, telefon numarası, kayıtlı ev adresleri, bildirim ayarları, BiTadilat Güvence Havuzu bilgilendirmesi, yardım merkezi, "Hizmet Profesyoneli Moduna Geç" geçiş butonu ve çıkış yap aksiyonu.
2. **Müşteri Taleplerim & Aktif İşler Listesi (`SCR-C-REQ`):**
   - **Gerekçe:** Müşteri ana sayfasındaki alt barın 2. sekmesi tıklandığında tebrik ekranı (`94a730`) yerine gerçek taleplerin listelenmesi gerekir.
   - **İçerik:** "Aktif Talepler (1)" ve "Geçmiş İşler (2)" sekmeleri; aktif olan "Banyo Lavabo Su Sızıntısı - 3 Teklif Geldi" kartı (tıklandığında teklif listesine götürür), tamamlanmış işler arşivi.
3. **Usta Onboarding & Belge Yükleme Ekranı (`SCR-P-ONB`):**
   - **Gerekçe:** Rol seçiminde usta seçildiğinde doğrudan talep havuzuna atlamak ürün mantığına aykırıdır; ayrıca Admin panelindeki `SCR-19` Belge İnceleme ekranının incelediği belgelerin yüklendiği yer burasıdır.
   - **İçerik:** Uzmanlık alanı seçimi (Tesisat), hizmet verilen ilçeler, Vergi Levhası yükleme alanı, Mesleki Yeterlilik Belgesi yükleme alanı, Adli Sicil onay beyanı ve "Doğrulamaya Gönder" butonu.
4. **Usta Teslim Talebi Gönderildi Onay Ekranı (`SCR-P-DONE`):**
   - **Gerekçe:** Usta `8ba8c3` ekranında "İşi Bitirdim" butonuna bastığında müşterinin ekranına geçip kendi işini onaylamasını engeller.
   - **İçerik:** "Teslim Bildirimi İletildi", "Müşterinin onay vermesi ve güvence havuzunun aktarılması bekleniyor", tamamlanan iş özeti, fotoğraf kanıtları ve "İşlerime / Talep Akışına Dön" ana butonu.

---

## 5. Adım Adım İyileştirme ve Uygulama Planı (Remediation Plan)

Bu plan kullanıcı tarafından onaylandığında aşağıdaki sıralı fazlarla hayata geçirilecektir:

### Faz 1: Kod Temizliği & Çift Scriptlerin Kaldırılması
- Tüm 33 ekran HTML dosyasındaki yinelenen (`duplicate`) script blokları temizlenecektir.
- Inline yazılmış ve ekranı kilitleyen fonksiyonlar (`handleContinue()`, kısıtlı `selectRole()`) temizlenip yerine deterministic (hatasız) event-delegation yapısı kurulacaktır.
- Metin araması (`innerText.includes`) yerine `data-nav-target` ve belirgin element ID'leri üzerinden çalışan robust bir yönlendirme motoru kurulacaktır.

### Faz 2: UI/UX Kural İhlallerinin Düzeltilmesi
- **Telefon Arama İkonları:** `b89d99` (SCR-08) ve `8ba8c3` (SCR-18) ekranlarındaki yasaklı `call` butonları tamamen kaldırılacaktır.
- **Yasak Alt Barlar:** `b89d99` ve `d48526` ara ekranlarındaki alt navigasyon çubukları kaldırılacak; yalnızca tek bir sabit ana CTA (Fixed Primary Action) bırakılacaktır.
- **Kategori Standardı:** 9 ekranda geçen "Sıhhi Tesisat" ifadeleri tasarım sistemi kuralı gereğince "Tesisat" olarak normalize edilecektir.
- **Düzenle Butonları:** `a0949c` (SCR-04 Gözden Geçir) ekranındaki 4 ayrı "Düzenle" butonu ilgili Adım 1, Adım 2 ve Adım 3 ekranlarına bağlanacaktır.

### Faz 3: Eksik Ekranların Stitch MCP ile Üretilmesi
- Google Stitch MCP aracı (`generate_screen_from_text`) kullanılarak:
  1. `SCR-C-PROF`: Müşteri Profil Ekranı
  2. `SCR-C-REQ`: Müşteri Taleplerim Listesi
  3. `SCR-P-ONB`: Usta Onboarding & Belge Yükleme
  4. `SCR-P-DONE`: Usta Teslim Talebi İletildi Ekranı  
  tasarım sistemi kurallarına tam uyumlu olarak (Manrope, `#0F4C5C`, `#107A5B`, `#F7F8F6`, 390x844) üretilecek ve projeye eklenecektir.

### Faz 4: Rol Ayrımının ve Simülatörün (`index.html`) Yenilenmesi
- `index.html` simülatörüne üst barda belirgin bir **Rol Göstergesi ve Filtresi** eklenecektir:
  - 🏠 **Müşteri Akışı** (Onboarding → Talep Sihirbazı → Teklifler → Randevu → İş Takibi → Teslim → Puanlama)
  - 🛠️ **Usta Akışı** (Usta Kayıt → Eşleşen Talepler → Teklif Verme → Profil & Müsaitlik → İş Yürütme → Teslim Bildirimi)
  - 💻 **Yönetici & Tanıtım Web** (Belge İnceleme → Uyuşmazlık Merkezi → Hesap Yönetimi → Tanıtım Sitesi)
- Kullanıcı hangi rolde olduğunu ekranda net görecek; müşteri asla bir usta ekranına, usta da asla bir müşteri ekranına izinsiz sızmayacaktır.
- Ekran geçişleri iPhone çerçevesi içinde animasyonlu, pürüzsüz ve sıfır hata ile çalışacaktır.

### Faz 5: Uçtan Uca Doğrulama ve Teslimat
- MacBook üzerinde yerel tarayıcıda (`open preview/index.html`) tüm akış baştan sona tıklanarak test edilecektir.
- Tüm butonların hedef ekranlara tam olarak geçiş yaptığı doğrulanıp kullanıcıya teslim edilecektir.

---

> [!IMPORTANT]
> **Onay Bekleniyor:**  
> Kullanıcı talebi doğrultusunda şu anda kodlarda hiçbir değişiklik yapılmamış, yalnızca kapsamlı PM ve QA analizi tamamlanmıştır.  
> Yukarıdaki raporu ve çözüm planını onaylamanız durumunda Faz 1'den başlanarak düzeltmeler sırayla hayata geçirilecek ve Stitch üzerinden eksik ekranlar tamamlanacaktır.
