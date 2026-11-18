# BiTadilat — Postman Üzerinden Craftgate 3D Secure Ödeme & Güvence Havuzu Rehberi

Trello'daki **"Providing information to Hakan on how to make the payment via Postman"** görevi için projedeki (`backend/src/main/java/com/bitadilat/payment`) Craftgate ödeme akışının tüm detayları aşağıdadır.

---

## 1. Önemli Ön Bilgi: Craftgate Sandbox API Anahtarları

Backend (`CraftgateConfig.java`), gerçek **Craftgate Sandbox** sunucusuna (`https://sandbox-api.craftgate.io`) bağlanır. Gerçek 3D Secure banka sayfasının oluşması için Ata'daki **Craftgate Sandbox Merchant** anahtarlarının ortam değişkeni olarak verilmesi gerekir:

```powershell
$env:CRAFTGATE_API_KEY = "api-key-..."       # Ata'dan veya Craftgate Sandbox panelinden alınan API Key
$env:CRAFTGATE_SECRET_KEY = "secret-key-..." # Ata'dan veya Craftgate Sandbox panelinden alınan Secret Key
```
*(Masaüstündeki `BiTadilat_Demo_Baslat.bat` dosyasını sağ tıklayıp Düzenle diyerek `CRAFTGATE_API_KEY` ve `CRAFTGATE_SECRET_KEY` satırlarına Ata'nın vereceği anahtarları yapıştırabilirsin.)*

---

## 2. Craftgate Test Kartı Bilgileri (Sandbox)

Projede (`API_CONTRACT.md` §3.3 ve `Wave3TestBase.java`) kullanılan resmi Craftgate Sandbox test kartı:

| Alan | Değer |
|---|---|
| **Kart Numarası (`cardNumber`)** | `5258640000000001` |
| **Kart Sahibi (`cardHolderName`)** | `Hakan Kuvan` (veya `Ali Yılmaz`) |
| **Son Kullanma Ay (`expireMonth`)** | `07` |
| **Son Kullanma Yıl (`expireYear`)** | `2044` |
| **CVC (`cvc`)** | `000` |

---

## 3. Postman Üzerinden Adım Adım Ödeme Yapma (`0A` Klasörü)

Masaüstündeki güncel **`BiTadilat_Spring_Postman_Collection.json`** dosyasını Postman'e **Import** ettiğinde en üstte **`0A. Craftgate 3D Secure & Güvence Havuzu`** klasörü gelir:

### Adım 1: Teklif Özetini Gör (`GET /api/offers/OFFER-BD-88412`)
- **İstek:** `GET http://localhost:8090/api/offers/OFFER-BD-88412`
- **Yanıt (`200 OK`):**
```json
{
  "id": "OFFER-BD-88412",
  "jobRef": "BD-88412",
  "jobTitle": "Su kaçak tespiti ve onarım",
  "proName": "Mavi Hat Tesisat",
  "laborAmount": 1650.00,
  "materialsAmount": 800.00,
  "totalAmount": 2450.00
}
```
> **Mimari Kural:** Tutar istemciden (Postman'den) gönderilmez; güvenlik gereği her zaman sunucudaki tekliften (`2450.00 TL`) okunur.

---

### Adım 2: Craftgate 3D Secure Ödemesini Başlat (`POST /api/payments/3ds/init`)
- **İstek:** `POST http://localhost:8090/api/payments/3ds/init`
- **Body (`application/json`):**
```json
{
  "offerId": "OFFER-BD-88412",
  "attemptKey": "{{$guid}}",
  "cardHolderName": "Hakan Kuvan",
  "cardNumber": "5258640000000001",
  "expireMonth": "07",
  "expireYear": "2044",
  "cvc": "000"
}
```
- **Ne Yapar?**
  1. Kart numarasını Luhn algoritması ile doğrular (kart numarası ve CVC veritabanına **asla kaydedilmez**, yalnızca son 4 hane `0001` tutulur).
  2. `escrow_payment` tablosunda `status = INITIALIZED` olarak kayıt açar.
  3. Craftgate SDK (`craftgate.payment().init3DSPayment(...)`) ile 3D Secure oturumu başlatır.
- **Yanıt (`200 OK`):**
```json
{
  "ref": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "htmlContent": "<!DOCTYPE html><html>... (Craftgate 3DS Banka Doğrulama Sayfası) ...</html>",
  "redirectUrl": "https://sandbox-api.craftgate.io/..."
}
```
*(Postman bu yanıttaki `ref` değerini otomatik olarak `{{paymentRef}}` değişkenine kaydeder.)*

---

### Adım 3: 3D Secure Banka Onayı (Callback)
- `init` yanıtındaki `redirectUrl` tarayıcıda açıldığında (veya HTML prototipte `http://localhost:8090/preview/index.html` üzerinden kart girildiğinde) Craftgate Sandbox SMS doğrulama ekranı açılır.
- Ekranda yazan SMS kodu girildiğinde banka otomatik olarak `POST http://localhost:8090/api/payments/3ds/callback` adresine döner.
- Backend gelen callback'e körü körüne güvenmez; `craftgate.payment().complete3DSPayment(paymentId)` ile Craftgate API'sinden ödemenin gerçekten çekildiğini doğrular ve havuz kaydını **`LOCKED` (Güvence Havuzunda Kilitli)** durumuna geçirir.

---

### Adım 4: Havuzdaki Ödemeyi Sorgula (`GET /api/payments/{{paymentRef}}`)
- **İstek:** `GET http://localhost:8090/api/payments/{{paymentRef}}`
- **Yanıt (`200 OK`):**
```json
{
  "ref": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "status": "LOCKED",
  "offerId": "OFFER-BD-88412",
  "jobRef": "BD-88412",
  "proName": "Mavi Hat Tesisat",
  "totalAmount": 2450.00,
  "commission": 245.00,
  "proPayout": 2205.00,
  "refundedAmount": 0.00,
  "cardLast4": "0001"
}
```

---

### Adım 5: Havuz Üzerindeki Karar İşlemleri (Release / Dispute / Refund)

1. **İşi Onayla ve Ustaya Aktar (`POST /api/payments/{{paymentRef}}/release`):**
   - Durum `LOCKED` -> **`RELEASED_TO_PRO`** olur.
   - `2.450,00 TL` içinden `%10` komisyon (`245,00 TL`) düşülür, `2.205,00 TL` usta hakedişi olarak kaydedilir.

2. **Şikayet Aç ve Havuzu Dondur (`POST /api/payments/{{paymentRef}}/dispute`):**
   - Durum `LOCKED` -> **`DISPUTED`** olur. Hakem kararı verilene kadar para dondurulur.

3. **Craftgate Üzerinden İade Yap (`POST /api/payments/{{paymentRef}}/refund`):**
   - **Tam İade (`{"type": "FULL"}`):** Craftgate `refundPayment` API'sini çağırır, `2.450,00 TL` müşterinin kartına iade edilir, durum **`REFUNDED_TO_CUSTOMER`** olur.
   - **%50 / %50 Uzlaşı (`{"type": "SPLIT_50_50"}`):** Yalnızca `DISPUTED` durumunda çalışır. Craftgate `refundPaymentTransaction` API'si ile `1.225,00 TL` müşteriye kısmi iade edilir, kalan `1.225,00 TL` komisyonsuz olarak ustaya yazılır, durum **`SPLIT_SETTLED`** olur.
