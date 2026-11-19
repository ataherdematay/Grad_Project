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

Geçişler: `ACTIVE → SUSPENDED` (admin), `SUSPENDED → ACTIVE` (admin), `ACTIVE → DELETED` (kullanıcı; açık iş veya kilitli emanet varsa reddedilir). Silmede isteğe bağlı gerekçe kodu kullanıcıya bağlanmadan analiz tablosuna yazılır (`account_deletion_feedback`).

E-posta değişikliği durum değiştirmez ama doğrulama ister: yeni adrese giden 6 haneli kod onaylanmadan `users.email` değişmez. Telefon değişikliği yoktur (SMS sağlayıcısı yok; telefon salt okunur).

### Usta profili (`pro_profiles.review_status`)

```
(başvuru) → PENDING_REVIEW → APPROVED
                           → NEEDS_DOCUMENTS → PENDING_REVIEW (yeniden gönderim)
                           → REJECTED → PENDING_REVIEW (yeniden gönderim)
APPROVED → SUSPENDED → APPROVED (admin)
```

- Yeniden gönderim `POST /pro/application` ile yapılır ve `NEEDS_DOCUMENTS` ile `REJECTED` profilde izinlidir (ret kalıcı değildir; usta belgelerini düzeltip yeniden başvurabilir). `PENDING_REVIEW`, `APPROVED` ve `SUSPENDED` iken `409 ILLEGAL_STATE`.

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

İptal iadesi outbox ile yapılır: iptal işlemi iş/talep/teklif değişikliklerini ve emanete `pending_action = REFUND` niyetini birlikte yazar ve kesinleşir; Craftgate iadesi ancak bundan sonra, ayrı bir işlemde denenir. Böylece "para iade edildi ama iptal geri alındı" durumu oluşamaz. İade hemen yapılamazsa iptal yine geçerlidir (200): emanet `LOCKED` + `pending_action = REFUND` kalır, ödeme toplayıcısı öksüz iadeyle aynı artan aralık ve 8 deneme sınırıyla yeniden dener; her denemeden önce Craftgate'e ne kadar iade edildiği sorulur (zaten tam iade edildiyse yalnızca defter işlenir, kısmi iadede yalnızca kalan gider). 8 denemeden sonra veya Craftgate'te tutarsız iade görünürse `error_code = REFUND_NEEDS_REVIEW` (ERROR logu, elle inceleme). İade tamamlanınca emanet `REFUNDED_TO_CUSTOMER` olur ve `pending_action` temizlenir.

### Otomatik tamamlama

`WORK_FINISHED` üzerinden 48 saat geçer ve açık şikayet yoksa zamanlayıcı işi `COMPLETED` yapar, emaneti `RELEASED_TO_PRO` yapar. Müşteriye 24. saatte hatırlatma bildirimi gider. Zamanlayıcı idempotenttir ve satır kilidiyle çalışır.

### Ustaya aktarım öncesi iade kontrolü

Müşteri onayı ve otomatik tamamlama, emaneti `RELEASED_TO_PRO` yapmadan önce Craftgate'e bu ödemede iade olup olmadığını sorar (`provider = SEED` hariç):

- İade yok: aktarılır (PAYOUT + COMMISSION, `PAYOUT_RELEASED` bildirimi).
- Herhangi bir iade görünüyor: aktarılmaz. İş yine `COMPLETED` olur; emanet `LOCKED` + `pending_action = RELEASE` + `error_code = PAYOUT_NEEDS_REVIEW` kalır, ERROR logu yazılır, kayıt admin ödeme raporunda `errorCode` ile görünür. Zamanlayıcı bu kayda dokunmaz (elle inceleme).
- Craftgate yanıt vermiyor (veya sonuç bekleyen iade var): müşteri bekletilmez, iş `COMPLETED` olur; emanet `LOCKED` + `pending_action = RELEASE` kalır. Ödeme toplayıcısı (5 dk) kontrolü ve aktarımı artan aralıkla (5 dk'dan 6 saate) en fazla 8 kez yeniden dener; aktarım olunca `PAYOUT_RELEASED` gider. 8 denemede yapılamazsa `PAYOUT_NEEDS_REVIEW`.
- Ustanın `completed_jobs` sayacı iş tamamlandığında artar (aktarımın beklemesinden bağımsız).

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
- Para hareketinden önce Craftgate'teki iade durumu sorulur (zaman aşımına uğramış ama gerçekleşmiş bir iade ikinci kez gitmesin):
  - Tam iade (karar ve iş iptali): zaten tam iade edilmişse yalnızca defter işlenir; kısmen iade edilmişse yalnızca kalan (toplam − iade edilmiş) iade edilir, müşteri toplamı tam bir kez alır; iade edilmiş tutar toplama eşit/fazla ama durum tam iade değilse `409` (elle incelenir).
  - %50 / %50: aynı yarı zaten iade edilmişse yeniden gönderilmez; başka tutar görünürse `409`.
  - Ustaya aktar: Craftgate'te herhangi bir iade görünürse `409`.
  - Sonuç bekleyen iade ya da okunamayan durum: `502`, hiçbir şey değişmez.
  - Müşteri onayı ve 48 saatlik otomatik tamamlama da aktarmadan önce Craftgate'e sorar (§4 "Ustaya aktarım öncesi iade kontrolü"); farkı, Craftgate kesintisinde 502 yerine işi tamamlayıp aktarımı zamanlayıcıya bırakmalarıdır.

## 6. Emanet (`escrow_payments.status`)

Mevcut makine aynen korunur (`backend/.../EscrowPayment.java`):

```
INITIALIZED → LOCKED | FAILED
LOCKED → DISPUTED
LOCKED | DISPUTED → RELEASED_TO_PRO
LOCKED | DISPUTED → REFUNDED_TO_CUSTOMER
DISPUTED → SPLIT_SETTLED
FAILED (yalnızca error_code = THREEDS_ABANDONED) → LOCKED   (geç banka başarısı, aşağıda)
```

`pending_action` (`REFUND` | `RELEASE` | null): kaydedilmiş ama Craftgate'te henüz yapılmamış para hareketi (outbox; §4 iptal ve aktarım). Durum değişmeden `LOCKED` iken dolu olabilir; hareket tamamlanınca temizlenir. Yeniden denemeler `refund_attempts` / `next_refund_attempt_at` sütunlarını kullanır.

Eklenenler:

- Kayıtta `request_id`, `offer_id`, `customer_id`, `pro_id`, `channel` (`APP` | `PROTOTYPE`).
- Talep başına aynı anda yalnızca bir `INITIALIZED` ödeme olabilir (kısmi benzersiz indeks). İkinci deneme `409 PAYMENT_IN_PROGRESS` alır. İstisna (banka sayfasını kapatan müşteri 2 saat beklemesin): eski deneme **10 dakikadan** eskiyse yeni deneme isteği onu satır kilidiyle (`SKIP LOCKED`) okur ve Craftgate'e eşzamanlı sorar. Craftgate 3DS'in bankada hiç bitmediğini (`INIT_THREEDS`) söylerse eski deneme `FAILED` + `THREEDS_ABANDONED` olur ve yeni deneme başlar (`complete3ds` hiç çağrılmadığı için para çekilmemiştir). `CALLBACK_THREEDS`, `WAITING`, başarı, yanıt yok veya satır o an işleniyorsa `409 PAYMENT_IN_PROGRESS` kalır. Böyle terk edilen denemeye sonradan başarı gelirse aşağıdaki geç başarı kuralı geçerlidir (kabul ya da yarış iadesi; tutulan çift ödeme olmaz).
- Banka dönüşü `LOCKED` ürettiğinde, talep hâlâ `OPEN` ve teklif hâlâ `PENDING` ise **aynı işlemde**: teklif `ACCEPTED`, diğerleri `SUPERSEDED`, talep `ASSIGNED`, iş `AWAITING_APPOINTMENT`.
- Talep bu arada başka yolla `ASSIGNED` olmuşsa ödeme `LOCKED` ardından hemen `REFUNDED_TO_CUSTOMER` olur, `error_code = REQUEST_ALREADY_ASSIGNED`.
- Komisyon %10; `commission` ve `pro_payout` başlangıçta hesaplanır (mevcut kod).
- Zamanlayıcı (5 dk), işe dönüşmemiş ödemeleri satır kilidi + `SKIP LOCKED` ile, gerçek callback'le yarışmadan ve tekrar çalışmaya dayanıklı işler:
  - İadesi yapılamamış öksüz `LOCKED` kayıt: yeniden iade etmeden önce Craftgate'e ödemenin iade durumu sorulur; zaten iade edilmişse yalnızca defter düzeltilir (`REFUNDED_TO_CUSTOMER`). Kısmi iade görünürse tam iade gönderilmez, kayıt hemen `REFUND_NEEDS_REVIEW` olur; sonuç bekleyen bir iade varsa yeni iade gönderilmez, deneme sayılır ve sonraki turda yeniden sorulur. Aksi halde iade, artan aralıkla (5 dk'dan başlayıp ikiye katlanır, en çok 6 saat) en fazla 8 kez denenir (`refund_attempts`, `last_refund_attempt_at`). Sınır aşılırsa `error_code = REFUND_NEEDS_REVIEW`, ERROR logu yazılır ve zamanlayıcı kaydı bırakır (elle inceleme).
  - 30 dakikadan eski `INITIALIZED` ödeme: sonuç Craftgate'ten sorulur. Başarılıysa normal callback yolu işler (kabul ya da yarış iadesi). Kesin başarısızsa (`FAILURE`) hemen `FAILED` + `PAYMENT_DECLINED`. 3DS tamamlanmamışsa (Craftgate `INIT_THREEDS` / `CALLBACK_THREEDS`) kayıt ancak oluşturulmasından **2 saat** sonra `FAILED` + `THREEDS_ABANDONED` olur (geç bir banka başarısı bu sürede normal yoldan işlenir); o zamana kadar her turda yeniden sorulur ve talepteki tek `INITIALIZED` kısıtı yeni denemeyi `409 PAYMENT_IN_PROGRESS` ile bekletir (10 dakikalık yeni deneme istisnası yukarıda). Banka sonucu bekleniyorsa (`WAITING`) para çekilmiş olabileceği için kayıt değişmez. Craftgate yanıt vermezse kayıt değişmez, sonraki turda tekrar denenir.
  - Terk edilmiş (`FAILED` + `THREEDS_ABANDONED`) ödemeye sonradan başarılı banka dönüşü gelirse ödeme tamamlanmaz (`complete3ds` çağrılmaz), yalnızca Craftgate'e sorulur. Craftgate ödemeyi tutar ve `conversationId` uyumlu başarılı görüyorsa para çekilmiştir: kayıt `LOCKED` olur ve normal banka dönüşü yolundan geçer: talep hâlâ `OPEN` ve teklif `PENDING` ise teklif kabul edilip iş açılır, değilse yarış iadesi (`REQUEST_ALREADY_ASSIGNED` / `OFFER_EXPIRED`, iade başarısızsa öksüz iade yeniden denemesi). Craftgate başarı görmüyorsa kayıt değişmez.
  - Bekleyen emanet hareketleri (`pending_action` dolu, `error_code` `REFUND_NEEDS_REVIEW` / `PAYOUT_NEEDS_REVIEW` değil, bekleme süresi dolmuş): §4'teki iptal iadesi ve ustaya aktarım aynı sayaç ve aralıkla yeniden denenir.
- Gecikmeli hareket tamamlanınca (zamanlayıcı denemesi veya admin çözümü; iptal anındaki ilk başarılı deneme hariç) taraflara bildirim gider: iade için müşteriye ve ustaya `REFUND_COMPLETED` (işsiz öksüz ödemede yalnızca müşteriye), aktarım için ustaya `PAYOUT_RELEASED`, müşteriye `PAYOUT_COMPLETED`.

### Elle inceleme çözümü (admin)

`error_code` `REFUND_NEEDS_REVIEW` veya `PAYOUT_NEEDS_REVIEW` olan `LOCKED` (veya `DISPUTED`) kayıt zamanlayıcı tarafından bırakılır ve admin panelinde listelenir. Admin çözümü her seferinde satır kilidi altında önce Craftgate'e iade durumunu ve iade edilmiş toplamı sorar; izin verilen çözüm yalnızca bu yanıttan hesaplanır (para iki kez hareket etmez):

| Craftgate | İzin verilen | Sonuç |
|---|---|---|
| Sonuç bekleyen iade / okunamayan durum | yok | 409 (sonra yeniden sorulur); yanıt yoksa 502 |
| Tam iade edilmiş | `MARK_REFUNDED` | Para gönderilmez; `REFUNDED_TO_CUSTOMER`, defterde tek `REFUND` |
| 0 < iade < toplam | `RETRY_REFUND` | Yalnızca kalan iade edilir; `REFUNDED_TO_CUSTOMER` |
| İade ≥ toplam ama durum tam iade değil | yok | Tutarsız; Craftgate panelinde elle düzeltilir |
| İade yok, iptal/öksüz kayıt (`REFUND`) | `RETRY_REFUND` | Tam iade |
| İade yok, tamamlanmış işin aktarımı (`RELEASE`, `LOCKED`) | `RELEASE` | `RELEASED_TO_PRO` (PAYOUT + COMMISSION) |

`DISPUTED` emanet bu ekranda listelenir ama buradan çözülmez: parası yalnızca şikayet kararıyla (§5-6) hareket eder. Kontrol izin verilen çözüm döndürmez, çözüm isteği 409 `ESCROW_DISPUTED` alır ve hiçbir şey değişmez. `LOCKED → REFUNDED_TO_CUSTOMER` ve `LOCKED → RELEASED_TO_PRO` geçişleri yeni değildir; çözüm `pending_action`'ı ve inceleme kodunu temizler. Not zorunludur (10-1000), aynı işlemde `admin_actions` satırı (`RESOLVE_PAYMENT_REVIEW`, hedef `PAYMENT`) yazılır. Craftgate hatası veya tutarsızlık her şeyi geri alır. Tam iade edilmiş ama iş `COMPLETED` olan kayıtta iş durumu değişmez (para gerçeği esastır; usta ödeme almaz).

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
