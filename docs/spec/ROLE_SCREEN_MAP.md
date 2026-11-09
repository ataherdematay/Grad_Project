# Rol ve Ekran Haritası

Her ekranın rotası, kim açabildiği, prototipteki karşılığı (`P` = `screens_map.json` adım numarası) ve ana eylemleri. Rota korumaları ve geri davranışı için: `NAVIGATION_RULES.md`. Durumlar için: `STATE_MACHINES.md`.

**Erişim kısaltmaları:** `*` herkes, `G` oturumsuz, `C` müşteri modu, `P` usta modu (`APPROVED` usta), `Pp` başvurusu süren usta, `A` admin (yalnız web). "Katılımcı" = işin müşterisi veya atanmış ustası.

## Ortak ve giriş

| Rota | Ekran | Erişim | P | Ana eylemler |
|---|---|---|---|---|
| `/` | Açılış (oturum kontrolü) | * | — | Oturuma göre yönlendirir |
| `/welcome` | Karşılama ve dil | G | 1 | TR/EN, "Giriş yap", "Hesap oluştur" |
| `/login` | Giriş | G | 1, 2 | E-posta veya telefon + şifre |
| `/register` | Kayıt | G | 2, 3 | Rol (müşteri / usta), ad soyad, e-posta, telefon, şifre, KVKK ve koşullar onayı |
| `/forgot-password` | Şifre sıfırlama isteği | G | — | E-posta gir |
| `/reset-password` | Kod ve yeni şifre | G | — | 6 haneli kod, yeni şifre |
| `/legal/:doc` | KVKK, koşullar, gizlilik | * | — | Okuma |
| `/notifications` | Bildirim merkezi | C, P | 32 | Okundu say, ilgili ekrana git |
| `/settings` | Ayarlar | C, P | 31 | Dil, bildirim tercihleri, şifre değiştir, hesap sil, çıkış |
| `/jobs/:id/chat` | İş sohbeti | Katılımcı | 24 | Mesaj, fotoğraf eki |
| `*` | Bulunamadı | * | — | Markalı hata, ana sayfaya dön |

## Müşteri (`/c/...`, alt sekmeler: Ana sayfa, Taleplerim, Mesajlar, Profil)

| Rota | Ekran | P | Veri | Ana eylemler |
|---|---|---|---|---|
| `/c/home` | Ana sayfa | 4 | Aktif iş özeti, son talep | Talep oluştur, aktif işe git |
| `/c/requests` | Taleplerim (Aktif / Geçmiş) | 10 | Talepler + iş durumu | Talebe veya işe git, yeni talep |
| `/c/messages` | Mesaj kutusu | — | İş başına konuşmalar | Sohbete git |
| `/c/profile` | Profil | 31 | Kullanıcı, adresler | Düzenle, adresler, ayarlar, "Usta moduna geç" |
| `/c/addresses` | Kayıtlı adresler | 31 | Adresler | Ekle, düzenle, sil, varsayılan yap |
| `/c/requests/new` | Talep sihirbazı 1-4 | 5-8 | Taslak (yerel) | Kategori ve aciliyet, konum ve detay, fotoğraf, gözden geçir ve yayınla |
| `/c/requests/:id/published` | Yayınlandı | 9 | Talep, eşleşen usta sayısı | Taleplerime git, ana sayfa |
| `/c/requests/:id` | Talep detayı | 10 | Talep, teklif sayısı | Teklifleri gör, düzenle, iptal et |
| `/c/requests/:id/offers` | Teklifler | 11 | Teklif listesi | Filtre ve sıralama (12), karşılaştır (15), teklife git |
| `/c/requests/:id/compare` | Karşılaştırma | 15 | 2-3 teklif | Teklife git |
| `/c/offers/:id` | Teklif detayı | 13 | Teklif, usta özeti | Kabul et, reddet (14), ustaya soru sor, profil |
| `/c/pros/:id` | Usta profili | 16 | Profil, puan, belgeler | Değerlendirmeler (17) |
| `/c/pros/:id/reviews` | Değerlendirmeler | 17 | Yorumlar | Filtre |
| `/c/offers/:id/accept` | Kabul onayı | 18 | Teklif, tutar dökümü | Ödemeye geç, vazgeç |
| `/c/offers/:id/pay` | Kart bilgileri | 19 | Teklif | Öde (3DS başlar) |
| `/c/payments/:ref/3ds` | Banka doğrulama (WebView) | — | `htmlContent` | Banka formu; dönüşte kapanır |
| `/c/payments/:ref/result` | Ödeme sonucu | 20 | Ödeme kaydı | Başarı: randevuya geç; hata: tekrar dene, teklife dön |
| `/c/jobs/:id` | İş alanı | 23, 25 | İş, randevu, aşamalar | Sohbet, randevu değiştir, iptal, teslim onayı, şikayet |
| `/c/jobs/:id/appointment` | Randevu seç | 21, 22 | Teklifteki aralık, öneriler | Aralık seç ve gönder, ustanın önerisini kabul et |
| `/c/jobs/:id/cancel` | İptal veya yeni tarih | 26 | İş | Gerekçe seç, onayla |
| `/c/jobs/:id/complete` | Teslim onayı | 27 | Ustanın notu ve fotoğrafları | Onayla (puana geçer), sorun bildir |
| `/c/jobs/:id/review` | Puanlama | 28 | İş | Yıldız, etiket, yorum, yayınla |
| `/c/jobs/:id/complaint` | Şikayet oluştur | 29 | İş | Neden, açıklama, kanıt |
| `/c/complaints/:id` | Şikayet durumu | 30 | Şikayet | Durum takibi, sohbete git |

## Usta (`/p/...`, alt sekmeler: Talepler, İşlerim, Mesajlar, Profil)

| Rota | Ekran | Erişim | P | Ana eylemler |
|---|---|---|---|---|
| `/p/apply` | Başvuru ve belgeler | C, Pp | 33 | İşletme adı, kategoriler, ilçeler, deneyim, kimlik ve mesleki belge yükle, gönder |
| `/p/application` | Başvuru durumu | Pp | 34 | Durum (inceleniyor, eksik belge, reddedildi), belgeyi yeniden yükle, müşteri moduna dön |
| `/p/feed` | Eşleşen talepler | P | 35 | Acil / planlı filtre, talebe git |
| `/p/requests/:id` | Talep detayı | P | 35 | Fotoğraflar, maskeli konum, teklif hazırla |
| `/p/requests/:id/offer` | Teklif formu | P | 36, 37 | İşçilik, malzeme kalemleri, varış aralığı, garanti, not; komisyon ve net kazanç görünür |
| `/p/offers/:id/sent` | Teklif gönderildi | P | 38 | Tekliflerime git, akışa dön |
| `/p/offers` | Tekliflerim | P | — (yeni) | Bekleyen, kabul edilen, reddedilen; geri çek |
| `/p/jobs` | İşlerim | P | — (yeni) | Aktif ve geçmiş işler |
| `/p/jobs/:id` | İş yürütme | P, atanmış | 40 | Randevu onayı veya öneri, haritada aç, adrese ulaştım, başladım, işi bitirdim (not + fotoğraf), iptal, sohbet |
| `/p/jobs/:id/appointment` | Randevu onayı | P, atanmış | — (yeni) | Onayla, yeni aralık öner |
| `/p/jobs/:id/cancelled` | İptal bildirimi | P, atanmış | 42 | Akışa dön |
| `/p/jobs/:id/finished` | Teslim gönderildi | P, atanmış | 43 | İşlerime dön |
| `/p/earnings` | Kazançlar | P | — (yeni) | Aktarılan, bekleyen (emanette), komisyon dökümü |
| `/p/profile` | Profil ve müsaitlik | P | 39 | Aktif / mola, kategoriler, ilçeler, çalışma saatleri, profil yazısı, "Müşteri moduna geç" |

Kapsam dışı: canlı GPS takibi (P41), RAD:76. Yerine iş ekranında "Haritada aç" (sistem harita uygulaması) ve "Adrese ulaştım" var.

## Admin Web (`apps/admin`)

| Rota | Ekran | P | Ana eylemler |
|---|---|---|---|
| `/login` | Admin girişi | — | E-posta + şifre |
| `/applications` | Usta başvuruları | 44 | Listele, belge görüntüle, onayla, reddet (gerekçe), eksik belge iste |
| `/complaints` | Şikayetler | 45 | Listele, incelemeye al, sohbet ve aşama geçmişini gör |
| `/complaints/:id/decision` | Karar | 46 | Tam iade, %50/%50, ustaya aktar; gerekçe; uyarı / askı |
| `/accounts` | Hesaplar | 47 | Ara, rol ve durum filtresi, askıya al, yeniden aktifleştir |
| `/payments` | Emanet defteri | — (yeni) | Ödeme kayıtları, durum, komisyon toplamı |

## Rol modu

- Hesap her zaman müşteri olarak kullanılabilir. Usta profili varsa Profil'den "Usta moduna geç" görünür; yoksa aynı yerden başvuruya gidilir.
- Uygulama son seçilen modu hatırlar. Mod değişince yığın tamamen sıfırlanır ve o modun ilk sekmesi açılır.
- Admin hesabı mobil uygulamaya giriş yapamaz; web paneline yönlendirilir.

## Erişim kuralları (sunucu tarafında da uygulanır)

| Veri | Kim görür |
|---|---|
| Talep detayı ve fotoğrafları | Sahibi; `OPEN` iken eşleşen onaylı ustalar; admin |
| Tam adres ve kapı bilgisi | Sahibi; iş açıldıktan sonra atanmış usta; admin. Diğerleri yalnızca ilçe ve mahalle görür (RAD:191) |
| Müşteri telefonu | Hiç kimseye gösterilmez; iletişim uygulama içi sohbetten (DES:62) |
| Teklif | Talebin sahibi ve teklifi veren usta |
| Sohbet | Yalnızca iş katılımcıları; iş kapandıktan 30 gün sonra salt okunur |
| Usta belgeleri | Usta ve admin |
| Emanet kaydı | Müşteri, atanmış usta (yalnızca kendi payı), admin |
