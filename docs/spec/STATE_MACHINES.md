# Durum Makineleri

**Durum:** onaylı plan (9 Kasım 2026) üzerine yazıldı. Backend bu belgeye göre kurulur; bir geçiş burada yoksa sunucu `409 ILLEGAL_STATE` döner.

RAD'daki üç farklı durum seti (RAD:208, RAD:671/683, API:76) burada teke indirildi. Eşleme tablosu en sonda.

## 1. Kullanıcı ve usta hesabı

### Hesap (`users.status`)

| Durum | Anlamı |
|---|---|
| `ACTIVE` | Normal kullanım |
| `SUSPENDED` | Admin askıya aldı. Giriş yapılamaz, açık teklifler `WITHDRAWN` olur |
| `DELETED` | Kullanıcı hesabını sildi. Kişisel veriler anonimleştirilir, finansal kayıtlar yasal süre boyunca kalır |

Geçişler: `ACTIVE → SUSPENDED` (admin), `SUSPENDED → ACTIVE` (admin), `ACTIVE → DELETED` (kullanıcı; açık iş veya kilitli emanet varsa reddedilir).

### Usta profili (`pro_profiles.review_status`)

```
(başvuru) → PENDING_REVIEW → APPROVED
                           → NEEDS_DOCUMENTS → PENDING_REVIEW (yeniden gönderim)
                           → REJECTED
APPROVED → SUSPENDED → APPROVED (admin)
```

- Yalnızca `APPROVED` usta talep akışını görür ve teklif verir.
- `availability`: `ACTIVE` veya `ON_BREAK`. `ON_BREAK` iken yeni talep eşleşmez; mevcut işler sürer.

## 2. Talep (`service_requests.status`)

```
OPEN ──(ödeme LOCKED, teklif kabul)──▶ ASSIGNED
OPEN ──(müşteri iptal)──▶ CANCELLED
OPEN ──(7 gün kabul yok)──▶ EXPIRED
ASSIGNED ──(iş iptal: usta iptali)──▶ OPEN
ASSIGNED ──(iş iptal: müşteri iptali)──▶ CANCELLED
```

- Talep yalnızca `OPEN` iken düzenlenebilir. Düzenleme mevcut teklifleri `EXPIRED` yapar ve ustalara bildirim gider.
- Uyan usta yoksa (eşleşme 0) talep yine `OPEN` yayınlanır; müşteriye "açık tut" veya "düzenle" seçenekleri gösterilir (RAD:646).

## 3. Teklif (`offers.status`)

| Geçiş | Tetikleyen |
|---|---|
| `PENDING → ACCEPTED` | Banka dönüşünde ödeme `LOCKED` (aynı işlem) |
| `PENDING → SUPERSEDED` | Aynı talepte başka teklif kabul edildi |
| `PENDING → DECLINED` | Müşteri reddetti (gerekçeli) |
| `PENDING → WITHDRAWN` | Usta geri çekti, ya da usta askıya alındı |
| `PENDING → EXPIRED` | `valid_until` geçti, talep düzenlendi, talep `EXPIRED` / `CANCELLED` oldu |
| `SUPERSEDED → PENDING` | Kabul edilen iş usta tarafından iptal edildi ve teklifin `valid_until` süresi geçmedi |
| `ACCEPTED → WITHDRAWN` | Usta işi başlamadan iptal etti |

- Bir usta aynı talebe yalnızca bir `PENDING` teklif verebilir (kısmi benzersiz indeks).
- `valid_until`: ustanın önerdiği varış aralığının sonu; en fazla 72 saat. Kabul anında yeniden kontrol edilir (RAD:523).
- Teklif tutarı: `labor_amount + materials_amount = total_amount`, ikisi de > 0 olmalı (₺0 teklif geçmez).

## 4. İş (`jobs.status`)

İş, ödeme `LOCKED` olduğu anda aynı işlemde açılır.

```
AWAITING_APPOINTMENT ─(usta onaylar)─▶ SCHEDULED ─(usta "adrese ulaştım")─▶ ARRIVED
ARRIVED ─(usta "başladım")─▶ IN_PROGRESS ─(usta "işi bitirdim")─▶ WORK_FINISHED
WORK_FINISHED ─(müşteri onaylar | 48 saat dolar)─▶ COMPLETED

AWAITING_APPOINTMENT | SCHEDULED | ARRIVED ─(müşteri veya usta iptal)─▶ CANCELLED
SCHEDULED | ARRIVED | IN_PROGRESS | WORK_FINISHED ─(müşteri şikayet)─▶ DISPUTED
DISPUTED ─(admin karar)─▶ COMPLETED | CANCELLED | RESOLVED
```

### Randevu (`appointments`)

- Ödemeden sonra müşteri bir zaman aralığı seçer. Teklifteki aralık önceden seçili gelir.
- Usta **onaylar** (iş `SCHEDULED`) ya da **yeni aralık önerir**. Öneriyi müşteri kabul eder veya başka aralık seçer.
- Bekleyen öneri en fazla bir tanedir. Her öneri kayıt olarak saklanır (kim, ne zaman, hangi aralık).
- `SCHEDULED` iken her iki taraf da yeni tarih isteyebilir; karşı taraf onaylayana kadar eski randevu geçerlidir.

### İptal kuralları

| Kim | Ne zaman | Sonuç |
|---|---|---|
| Müşteri | `AWAITING_APPOINTMENT`, `SCHEDULED`, `ARRIVED` | İş `CANCELLED`, emanet tam iade, talep `CANCELLED` |
| Usta | `AWAITING_APPOINTMENT`, `SCHEDULED`, `ARRIVED` | İş `CANCELLED`, emanet tam iade, teklif `WITHDRAWN`, talep yeniden `OPEN`, ustaya iptal kaydı |
| Herkes | `IN_PROGRESS` ve sonrası | Doğrudan iptal yok; müşteri şikayet açar |
| Herkes | `DISPUTED` | İptal ve iade kapalı; karar admin'de (P10) |

İptal gerekçe ister (liste + isteğe bağlı not) ve onay diyaloğu gösterir (RAD:169). Karşı tarafa bildirim gider.

### Otomatik tamamlama

`WORK_FINISHED` üzerinden 48 saat geçer ve açık şikayet yoksa zamanlayıcı işi `COMPLETED` yapar, emaneti `RELEASED_TO_PRO` yapar. Müşteriye 24. saatte hatırlatma bildirimi gider. Zamanlayıcı idempotenttir ve satır kilidiyle çalışır.

### Puan

Yalnızca `COMPLETED` işte, yalnızca müşteri, iş başına bir kez. 1-5 yıldız zorunlu, etiketler ve yorum isteğe bağlı, anonim seçeneği var. Usta puan ortalaması ve sayısı aynı işlemde güncellenir.

## 5. Şikayet (`complaints.status`)

```
OPEN ─(admin açar)─▶ IN_REVIEW ─(karar)─▶ RESOLVED
                               └─(reddet)─▶ DISMISSED
```

- Şikayet açılınca iş `DISPUTED`, emanet `DISPUTED` olur (aynı işlem).
- Kanıt: en fazla 5 fotoğraf, açıklama en az 20 karakter.
- Admin kararları:

| Karar | Emanet | İş | Komisyon |
|---|---|---|---|
| Tam iade | `REFUNDED_TO_CUSTOMER` | `CANCELLED` | Yok |
| %50 / %50 | `SPLIT_SETTLED` | `RESOLVED` | Yok |
| Şikayeti reddet, ustaya aktar | `RELEASED_TO_PRO` | `COMPLETED` | %10 |

- Admin ek olarak ustaya uyarı kaydı düşebilir veya hesabı askıya alabilir.
- Karar gerekçesi zorunludur ve iki tarafa bildirilir. Ekranlarda gerçek tutarlar gösterilir (P12).

## 6. Emanet (`escrow_payments.status`)

Mevcut makine aynen korunur (`backend/.../EscrowPayment.java`):

```
INITIALIZED → LOCKED | FAILED
LOCKED → DISPUTED
LOCKED | DISPUTED → RELEASED_TO_PRO
LOCKED | DISPUTED → REFUNDED_TO_CUSTOMER
DISPUTED → SPLIT_SETTLED
```

Eklenenler:

- Kayıtta `request_id`, `offer_id`, `customer_id`, `pro_id`, `channel` (`APP` | `PROTOTYPE`).
- Talep başına aynı anda yalnızca bir `INITIALIZED` ödeme olabilir (kısmi benzersiz indeks). İkinci deneme `409 PAYMENT_IN_PROGRESS` alır.
- Banka dönüşü `LOCKED` ürettiğinde, talep hâlâ `OPEN` ve teklif hâlâ `PENDING` ise **aynı işlemde**: teklif `ACCEPTED`, diğerleri `SUPERSEDED`, talep `ASSIGNED`, iş `AWAITING_APPOINTMENT`.
- Talep bu arada başka yolla `ASSIGNED` olmuşsa ödeme `LOCKED` ardından hemen `REFUNDED_TO_CUSTOMER` olur, `error_code = REQUEST_ALREADY_ASSIGNED`.
- Komisyon %10; `commission` ve `pro_payout` başlangıçta hesaplanır (mevcut kod).
- Zamanlayıcı (5 dk), işe dönüşmemiş ödemeleri satır kilidi + `SKIP LOCKED` ile, gerçek callback'le yarışmadan ve tekrar çalışmaya dayanıklı işler:
  - İadesi yapılamamış öksüz `LOCKED` kayıt: yeniden iade etmeden önce Craftgate'e ödemenin iade durumu sorulur; zaten iade edilmişse yalnızca defter düzeltilir (`REFUNDED_TO_CUSTOMER`). Aksi halde iade, artan aralıkla (5 dk'dan başlayıp ikiye katlanır, en çok 6 saat) en fazla 8 kez denenir (`refund_attempts`, `last_refund_attempt_at`). Sınır aşılırsa `error_code = REFUND_NEEDS_REVIEW`, ERROR logu yazılır ve zamanlayıcı kaydı bırakır (elle inceleme).
  - 30 dakikadan eski `INITIALIZED` ödeme: sonuç Craftgate'ten sorulur. Başarılıysa normal callback yolu işler (kabul ya da yarış iadesi). Başarısızsa `FAILED` + `PAYMENT_DECLINED`; hâlâ 3DS'te/tamamlanmamışsa `FAILED` + `THREEDS_ABANDONED`; böylece talepteki tek `INITIALIZED` kısıtı kalkar ve müşteri yeniden dener. Craftgate yanıt vermezse kayıt değişmez, sonraki turda tekrar denenir.

## 7. Eski adlarla eşleme

| Bu belge | RAD:208 | RAD:671/683 | API:76 |
|---|---|---|---|
| Talep `OPEN` | `OPEN` | `OPEN` | `PENDING_OFFERS` |
| Ödeme sürüyor | — | — | `ESCROW_PENDING` |
| İş `AWAITING_APPOINTMENT` | `OFFER_ACCEPTED` | `AGREED` | — |
| İş `SCHEDULED` | `APPOINTMENT_SCHEDULED` | `SCHEDULED` | `SCHEDULED` |
| İş `ARRIVED` | — | — | `PRO_EN_ROUTE` |
| İş `IN_PROGRESS` | `IN_PROGRESS` | `IN_PROGRESS` | `IN_PROGRESS` |
| İş `WORK_FINISHED` | `WORK_FINISHED` | `WORK_FINISHED` | `COMPLETED` |
| İş `COMPLETED` | `COMPLETED` | `COMPLETED` | `RELEASED` |
| Puan verildi | `REVIEWED` | — | — |
| İş `DISPUTED` | — | — | `DISPUTED` |
| İş `CANCELLED` | — | `CANCELLED` | `CANCELLED` |

`REVIEWED` ayrı bir durum değildir; `reviews` kaydının varlığıyla anlaşılır.
