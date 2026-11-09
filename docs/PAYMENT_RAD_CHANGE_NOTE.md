# RAD Değişiklik Notu: Craftgate Sandbox Ödeme Entegrasyonu

**Durum:** Takım ve danışman onayı bekliyor. RAD belgesine henüz dokunulmadı.

## Neden gerekli?

RAD, online ödeme ve emaneti kapsam dışı sayıyor (`BiTadilat_Requirements_Analysis_Document.md:75`, `.docx` için `build_docx.py:192`). Prototip ise artık Craftgate sandbox üzerinden gerçek 3-D Secure ödemesi ve iade yapıyor. README ve API sözleşmesi zaten emaneti anlatıyordu. Bu çelişki jüride sorulabilir, bu yüzden aşağıdaki kararların verilmesi gerekiyor.

## Önerilen RAD değişiklikleri

### 1. Kapsam (RAD:75)

Mevcut madde:

> Online payment transactions or escrow holding.

Önerilen madde:

> Live payment processing. Payments run only against the Craftgate sandbox with test cards. The escrow is a ledger kept by the BiTadilat backend, and payouts to professionals are recorded but not transferred.

### 2. Use case'ler (RAD:136-149)

Yeni use case numarası açmak yerine mevcutları genişletmeyi öneriyorum:

| UC | Eklenecek davranış |
|---|---|
| UC05 Compare & Accept Single Offer | Kabulden sonra kart girişi ve 3-D Secure. Ödeme başarısız olursa teklif kabul edilmiş sayılmaz |
| UC09 Confirm Completion | Müşteri onayı havuzu serbest bırakır: %10 komisyon, %90 usta payı |
| UC11 Cancel Service Request / Job | Havuzdaki ödeme için tam iade |
| UC13 Arbitrate Customer Complaints | Şikayet havuzu dondurur. Hakem kararı: tam iade, %50/%50 veya ustaya aktarım |

### 3. Sınıf modeli (RAD:204)

Yeni sınıf: `EscrowPayment`. Alanlar: `ref`, `offerId`, `jobRef`, `totalAmount`, `commission`, `proPayout`, `refundedAmount`, `status`, `craftgatePaymentId`, `conversationId`, `cardLast4`, `errorMessage`. Yeniden yazımla eklenecekler: `requestId`, `customerId`, `proId`, `jobId`, `channel` (`docs/spec/DATA_MODEL.md`).

Kart numarası ve CVC modele dahil değildir, hiçbir yerde saklanmaz.

### 4. Durum makinesi (RAD:208)

Yeni emanet durumları:

```
INITIALIZED → LOCKED → RELEASED_TO_PRO
INITIALIZED → FAILED
LOCKED → DISPUTED
LOCKED veya DISPUTED → REFUNDED_TO_CUSTOMER
DISPUTED → SPLIT_SETTLED veya RELEASED_TO_PRO
```

### 5. Mock-up'lar (D1.3)

Adım 19 artık sahte banka ekranı değil, kart formudur. Banka adımı Craftgate'in gerçek sandbox sayfasında, tam sayfa olarak açılır. RAD'daki ekran görüntüsü ve navigasyon diyagramı buna göre güncellenmeli.

### 6. Yeniden yazımla gelen diğer değişiklikler (9 Kasım 2026)

Flutter uygulaması ve backend sıfırdan yazılıyor (`docs/FLUTTER_RESTART_NOTES.md`). Aşağıdakiler RAD'a işlenmeli; ayrıntı `docs/spec/` altında.

| RAD yeri | Değişiklik | Şartname |
|---|---|---|
| RAD:208, 671, 683 | Üç farklı durum seti teke indirildi; eski adlarla eşleme tablosu var | `STATE_MACHINES.md` §7 |
| RAD:220-236 (UC01) | E-posta veya telefon + şifre korunuyor. Kayıt, şifre sıfırlama (e-posta kodu) ve hesap silme eklendi | `API_V1.md` |
| UC06 | Usta randevuyu onaylar ya da yeni aralık önerir | `STATE_MACHINES.md` §4 |
| UC08 | Aşamalar: adrese ulaşıldı, iş başladı, iş bitti | `STATE_MACHINES.md` §4 |
| UC11 | İptal yalnızca iş başlamadan; şikayet açıkken iptal ve iade kapalı | `STATE_MACHINES.md` §4 |
| RAD:204 | Sınıf modeli tablo düzeyinde tanımlandı | `DATA_MODEL.md` |
| RAD:182 | Teknoloji: Flutter, Spring Boot 4.1, PostgreSQL 16 | — |
| RAD:170 | Dokunma alanı 48 dp (tasarım belgesindeki 44 pt yerine RAD esas alındı) | — |

## Kurallar için verilen kararlar

Takımın itirazı yoksa aşağıdaki gibi uygulanır.

| Konu | Karar |
|---|---|
| %50/%50 uzlaşmada komisyon | Alınmaz; 1.225 ₺ iade, 1.225 ₺ usta |
| Hakem "ustaya aktarım" kararı | Normal %10 hizmet bedeli kesilir (2.205 ₺ usta). Ekranlar gerçek tutarı gösterir; adım 46'daki "₺2.450,00 Ustaya Ödeme" metni yeni uygulamada yok |
| 48 saat sonra otomatik serbest bırakma | Uygulanacak: usta işi bitirdikten 48 saat sonra, açık şikayet yoksa |

## Ekranlarda kalan çelişkili metinler

Ödeme akışına dahil olmayan ekranlarda değiştirilmedi. Sunumdan önce karar verilmesini öneririm:

| Metin | Yer | Sorun |
|---|---|---|
| "komisyonsuz" | Adım 48, `preview/screens/164cd336…html:399` | Backend %10 komisyon hesaplıyor |
| Güvence iddiaları | "%100 Garantili" (adım 34), adım 13 ve 27'deki garanti süreleri | Doğrulanmamış güvence iddiası, RAD:80 ile çelişiyor. Prototipin görünür metinlerinde BDDK veya TCMB iddiası kalmadı |
| Garanti süreleri: 3, 6 ve 12 ay | Adım 13, 15, 18, 27, 36 | Süreler birbirini tutmuyor |
| Adım 43 sabit ₺2.450 | `preview/screens/c6ebf06d…html` | Canlı veriye bağlı değil |

Adım 19, 20 ve 46'daki lisans iddiaları kaldırıldı, çünkü bu ekranlar artık gerçek akışın parçası.

## Sunumda açıkça söylenebilecek sınırlar

- Yalnızca sandbox ve test kartları kullanılıyor. Servis, sandbox dışı bir adresle başlamayı reddeder.
- Usta aktarımı defter kaydıdır, gerçek para hareketi olmaz.
- Kart verisi tarayıcıdan backend'e geçer. Canlıya çıkılsaydı PCI kapsamı nedeniyle Craftgate'in ortak ödeme formu kullanılmalıydı.
- Prototipte gerçek kimlik doğrulama yoktur. Ödeme kaydına erişim tahmin edilemez bir UUID ile yapılır ve sunucu yalnızca yerelde dinler.
- Ödeme şu an HTML prototipte çalışıyor. Yeni Flutter uygulaması aynı servisi 3-D Secure WebView ile kullanacak (`docs/FLUTTER_RESTART_NOTES.md`).
