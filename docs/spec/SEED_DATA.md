# Tek Demo Veri Seti

Denetimdeki A3 tutarsızlıklarını (4 iş numarası, 4 müşteri adı, 3 fiyat dökümü) kapatır. Uygulama, admin paneli, testler ve sunum yalnızca bu veriyi kullanır.

## Nasıl yüklenir?

- Yalnızca `dev` profilinde, Java `DevSeeder` ile. SQL yerine Java seçildi, çünkü tarihler "bugün" ve "yarın" gibi göreli olmalı; aksi halde teklifler birkaç gün içinde süresi dolmuş görünür.
- `POST /api/v1/dev/reset` (yalnız `dev` profili, yalnız 127.0.0.1) veritabanını boşaltıp seti yeniden yükler. Entegrasyon testleri her senaryodan önce bunu çağırır.
- `prod` profilinde seeder ve reset uç noktası hiç oluşturulmaz.
- Demo şifrelerinin hepsi `Demo1234!`. Bu şifre yalnızca dev seed'inde var; `prod` ilk açılışta admin şifresini ortam değişkeninden ister.

## Hesaplar

| Kişi | Rol | E-posta | Telefon | Not |
|---|---|---|---|---|
| Ali Yılmaz | Müşteri | `ali@bitadilat.test` | +90 532 849 20 11 | Ana demo müşterisi |
| Zeynep Kaya | Müşteri | `zeynep@bitadilat.test` | +90 533 210 45 67 | Şikayet senaryosu; yetki testlerinde "başka müşteri" |
| Mehmet Demir | Usta, `APPROVED` | `mehmet@bitadilat.test` | +90 532 450 88 92 | Mavi Hat Tesisat |
| Ahmet Kaya | Usta, `APPROVED` | `ahmet@bitadilat.test` | +90 535 118 32 40 | Kaya Tesisat |
| Emre Çelik | Usta, `APPROVED` | `emre@bitadilat.test` | +90 536 774 19 03 | Usta Eller Tesisat |
| Hasan Yıldız | Usta, `PENDING_REVIEW` | `hasan@bitadilat.test` | +90 537 902 66 15 | Yıldız Elektrik; admin onay senaryosu |
| Selim Aksoy | Usta, `NEEDS_DOCUMENTS` | `selim@bitadilat.test` | +90 538 341 27 58 | Aksoy Boya & Badana |
| Yönetici | Admin | `admin@bitadilat.test` | — | Yalnız web paneli |

Telefonlar ve e-postalar uydurmadır; `.test` alan adı gerçek posta almaz.

## Usta profilleri

| İşletme | Kategoriler | İlçeler | Puan | İş sayısı | Durum |
|---|---|---|---|---|---|
| Mavi Hat Tesisat | Tesisat, Banyo yenileme | Kadıköy, Üsküdar, Ataşehir, Maltepe | 4,8 (126) | 214 | Aktif |
| Kaya Tesisat | Tesisat, Mutfak yenileme | Kadıköy, Üsküdar | 4,9 (84) | 131 | Aktif |
| Usta Eller Tesisat | Tesisat | Kadıköy, Ataşehir | 4,7 (62) | 88 | Aktif |
| Yıldız Elektrik | Elektrik | Ümraniye | — | — | İnceleniyor |
| Aksoy Boya & Badana | Boya & Badana | Beşiktaş | — | — | Eksik belge |

Puan ve iş sayısı, seed'de üretilen geçmiş iş ve yorumlardan hesaplanır; elle yazılmaz.

## Talepler ve işler

Numara biçimi: talep `BD-` + 5 hane; iş aynı numarayı kullanır. Şikayet `SK-` + 4 hane.

| No | Müşteri | Başlık | Kategori, aciliyet | Konum | Durum |
|---|---|---|---|---|---|
| BD-88412 | Ali Yılmaz | Banyo lavabo altı su kaçağı | Tesisat, acil | Kadıköy, Caferağa | `OPEN`, 3 teklif |
| BD-88407 | Ali Yılmaz | Mutfak bataryası değişimi | Mutfak yenileme, planlı | Kadıköy, Caferağa | `ASSIGNED`, iş `COMPLETED`, Kaya Tesisat, 5 yıldız |
| BD-88409 | Ali Yılmaz | Kombi petek bakımı | Tesisat, planlı | Kadıköy, Caferağa | `ASSIGNED`, iş `SCHEDULED` (yarın 10:00-12:00), Mavi Hat |
| BD-88398 | Zeynep Kaya | Mutfak gider tıkanıklığı | Tesisat, acil | Ataşehir, Atatürk | `ASSIGNED`, iş `DISPUTED`, Usta Eller, şikayet SK-1001 |

**Ali Yılmaz adresi:** Caferağa Mah. Moda Cad. No: 14 Daire: 5, Kadıköy (zil: Yılmaz). Teklif kabul edilmeden ustalar yalnızca "Kadıköy, Caferağa" görür.

## BD-88412 teklifleri

| Usta | İşçilik | Malzeme | Toplam | Varış aralığı | Garanti | Not |
|---|---|---|---|---|---|---|
| Mavi Hat Tesisat | ₺1.650 | ₺800 | **₺2.450** | Bugün 14:00-17:00 | 6 ay | Lavabo altı bağlantılar ve sifon değişimi, ek işlem onaysız yapılmaz |
| Kaya Tesisat | ₺1.400 | ₺800 | **₺2.200** | Yarın 09:00-11:00 | 6 ay | Kadıköy'deyim; sızıntı tespiti ve parça montajı dahil |
| Usta Eller Tesisat | ₺1.250 | ₺600 | **₺1.850** | Yarın 13:00-15:00 | 3 ay | Yalnızca bağlantı contaları; sifon gerekirse ayrıca fiyat |

"Bugün" seçeneği saat 14:00'ten sonra yüklenirse ertesi güne kayar; seeder geçerli bir aralık üretir.

Mavi Hat teklifinin usta ekranındaki dökümü: toplam ₺2.450, hizmet bedeli ₺245, net kazanç ₺2.205.

## Ödemeler

- BD-88407 ve BD-88409 için emanet kayıtları seed'de oluşturulur: `provider = SEED`. Bu kayıtlarda iade ve aktarım Craftgate'e gitmez, yalnızca defterde işlenir. Bu davranış yalnızca `dev` profilinde ve yalnızca `SEED` kayıtlarında vardır.
- BD-88398: ₺2.200, emanet `DISPUTED`.
- BD-88412 için ödeme yoktur; demo sırasında gerçek sandbox 3DS ile alınır.

## Sohbet, bildirim, şikayet

- BD-88409: Ali ile Mehmet arasında 4 mesaj (adres tarifi, park yeri).
- BD-88398: Zeynep ile Emre arasında 6 mesaj; sonuncusu fazladan ücret talebi.
- **SK-1001:** neden "Teklif dışı fazladan ücret talep edildi"; açıklama ve 2 kanıt fotoğrafı; durum `OPEN`.
- Ali için 3 okunmamış bildirim: "3 teklif geldi", "Randevun onaylandı", "Değerlendirmen yayınlandı".

## Prototip uyumu

Prototipin sabit teklif kimliği `OFFER-BD-88412`, seed'deki Mavi Hat teklifinin `public_code` değeridir. Böylece `preview/` ödeme akışı aynı veriyle çalışmaya devam eder (PROTOTYPE kanalı, yalnızca `dev`).
