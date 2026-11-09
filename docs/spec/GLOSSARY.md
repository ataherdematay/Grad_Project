# Sözlük ve Metin Kuralları

Ekranlardaki terim karmaşasını (usta / uzman / hizmet profesyoneli, "sen" / "siz") bitirmek için. Kodda İngilizce ad, arayüzde Türkçe ve İngilizce karşılık kullanılır.

## Terimler

| Kod | Türkçe arayüz | English UI | Not |
|---|---|---|---|
| customer | Müşteri | Customer | "Ev sahibi" yalnızca karşılama ekranındaki rol açıklamasında |
| pro | Usta | Pro | "Uzman", "hizmet profesyoneli", "esnaf" kullanılmaz |
| admin | Yönetici | Admin | Yalnız web paneli |
| service request | Talep | Request | "İş talebi" değil, kısaca "talep" |
| offer | Teklif | Offer | |
| job | İş | Job | Teklif kabul edilip ödeme alındıktan sonraki kayıt |
| appointment | Randevu | Appointment | |
| milestone | Aşama | Stage | Adrese ulaşıldı, iş başladı, iş bitti |
| escrow | Güvence havuzu | Secure hold | "Escrow" ve "emanet hesabı" arayüzde kullanılmaz |
| release | Ustaya aktarım | Payout to pro | |
| refund | İade | Refund | |
| complaint | Şikayet | Complaint | "Uyuşmazlık" yalnızca admin panelinde |
| commission | Hizmet bedeli (%10) | Service fee (10%) | Usta ekranlarında görünür; "komisyonsuz" ifadesi hiçbir yerde yok |
| labor | İşçilik | Labour | |
| materials | Malzeme | Materials | |
| total | Toplam tutar (KDV dahil) | Total (VAT incl.) | HO:101 |
| urgent | Acil onarım | Urgent repair | |
| planned | Planlı iş | Planned job | |
| warranty | İşçilik garantisi | Workmanship warranty | Usta teklifte 0, 3, 6 veya 12 ay seçer; platform garanti vermez (RAD:80) |
| verified | Doğrulandı | Verified | Yalnızca admin onaylı ustada |

## Kategoriler

| Kod | Türkçe | English |
|---|---|---|
| `plumbing` | Tesisat | Plumbing |
| `electrical` | Elektrik | Electrical |
| `painting` | Boya & Badana | Painting |
| `hvac` | Klima | Air conditioning |
| `bathroom` | Banyo yenileme | Bathroom renovation |
| `kitchen` | Mutfak yenileme | Kitchen renovation |
| `carpentry` | Marangozluk | Carpentry |
| `other` | Diğer | Other |

"Sıhhi Tesisat" kullanılmaz (HO:99).

## Durum etiketleri

Renk tek başına durum anlatmaz; her etikette ikon ve metin olur (DES:36).

| Durum | Türkçe | English | Renk |
|---|---|---|---|
| Talep `OPEN` (teklif yok) | Teklif bekleniyor | Awaiting offers | Bilgi mavisi |
| Talep `OPEN` (teklif var) | N teklif geldi | N offers | Ana renk |
| Talep `CANCELLED` / `EXPIRED` | İptal edildi / Süresi doldu | Cancelled / Expired | İkincil metin |
| İş `AWAITING_APPOINTMENT` | Ustanın onayı bekleniyor | Awaiting pro confirmation | Turuncu |
| İş `SCHEDULED` | Randevun onaylandı | Appointment confirmed | Ana renk |
| İş `ARRIVED` | Usta adreste | Pro on site | Ana renk |
| İş `IN_PROGRESS` | İş sürüyor | In progress | Ana renk |
| İş `WORK_FINISHED` | Onayın bekleniyor | Awaiting your approval | Turuncu |
| İş `COMPLETED` | Tamamlandı | Completed | Yeşil |
| İş `DISPUTED` | Şikayet inceleniyor | Under review | Kırmızı |
| İş `CANCELLED` | İptal edildi | Cancelled | İkincil metin |
| Usta `PENDING_REVIEW` | İnceleniyor | Under review | Turuncu |
| Usta `APPROVED` | Doğrulandı | Verified | Yeşil |

## Yazım kuralları

- Hitap her yerde **"sen"**. Admin panelinde de aynı.
- Cümle düzeni (sentence case); büyük harf yalnızca kısa durum etiketlerinde.
- Tarih: "14 Kasım Cuma, 14:00-16:00". Göreli: "Bugün", "Yarın". Sabit tarih veya yıl metne gömülmez.
- Para: `₺2.450` (TR), `₺2,450` (EN); her zaman `intl` ile biçimlenir. Kuruş varsa `₺1.225,50`.
- Geri sayım, "garanti", "%100" ve kesin süre vaadi kullanılmaz (HO:93, HO:106, RAD:80).
- Lisans, BDDK, TCMB gibi doğrulanmamış güvence ifadeleri yok.
- Hata metni ne olduğunu ve ne yapılacağını söyler: "Kart numarası eksik. 16 haneyi kontrol et."
- Ekranda geliştirici kalıntısı yok: ekran kodu, ikon adı, "Job #", "Audit Trail".
