# API v1 Taslağı

Mobil ve admin istemcilerinin konuşacağı uç noktalar. Uygulandıkça springdoc OpenAPI çıktısı (`/v3/api-docs`) esas alınır ve `docs/API_CONTRACT.md` ondan güncellenir.

## Genel

- Taban: `/api/v1`. JSON, UTF-8. Tarihler ISO 8601 UTC.
- Kimlik: `Authorization: Bearer <access>`. Access 15 dk, refresh 30 gün ve her kullanımda döner.
- Mod: usta uç noktaları (`/pro/...`) `APPROVED` usta profili ister; admin uç noktaları (`/admin/...`) `is_admin` ister.
- Durum değiştiren `POST` isteklerinde `Idempotency-Key` başlığı (UUID) kabul edilir; aynı anahtar aynı yanıtı döner.
- Listeler: `?cursor=&limit=` (varsayılan 20, en fazla 50); yanıt `{ items, nextCursor }`.
- Hata biçimi mevcut backend ile aynı: `{ "code": "…", "message": "…", "field"?: "…" }`. `message` geliştirici içindir; istemci metni `code` ile kendi çevirisinden alır.

| HTTP | `code` örnekleri |
|---|---|
| 400 | `VALIDATION_FAILED` (+ `field`), `INVALID_CARD` |
| 401 | `UNAUTHENTICATED`, `TOKEN_EXPIRED`, `BAD_CREDENTIALS`, `ACCOUNT_SUSPENDED` |
| 403 | `FORBIDDEN`, `PRO_NOT_APPROVED` |
| 404 | `NOT_FOUND` (yetkisiz kayıtlar için de 404; varlık sızdırılmaz) |
| 409 | `ILLEGAL_STATE`, `DUPLICATE_ATTEMPT`, `PAYMENT_IN_PROGRESS`, `OFFER_EXPIRED`, `ALREADY_OFFERED`, `EMAIL_TAKEN`, `PHONE_TAKEN` |
| 402 | `PAYMENT_DECLINED` (+ `ref`) |
| 429 | `TOO_MANY_ATTEMPTS` |
| 502 | `GATEWAY_ERROR` |

## Kimlik ve hesap

| Yöntem | Yol | Amaç |
|---|---|---|
| POST | `/auth/register` | Ad, e-posta, telefon, şifre, `wantsPro`, KVKK/koşul onayı → token çifti |
| POST | `/auth/login` | `identifier` (e-posta veya telefon) + şifre → token çifti |
| POST | `/auth/refresh` | Refresh token → yeni çift |
| POST | `/auth/logout` | Refresh ailesini iptal et |
| POST | `/auth/password/forgot` | E-posta → kod gönder (yanıt her zaman 202, hesap var mı sızdırmaz) |
| POST | `/auth/password/reset` | E-posta, kod, yeni şifre |
| GET | `/me` | Kullanıcı, modlar, usta profil durumu, okunmamış sayıları |
| PATCH | `/me` | Ad, dil, son mod |
| POST | `/me/password` | Şifre değiştir |
| DELETE | `/me` | Hesap sil (açık iş varsa 409) |
| GET/POST/PATCH/DELETE | `/me/addresses[/{id}]` | Adresler |

## Katalog

| Yöntem | Yol | Amaç |
|---|---|---|
| GET | `/categories` | Kategoriler (TR/EN ad, ikon, renk) |
| GET | `/districts` | İstanbul ilçeleri |
| GET | `/categories/{id}/questions` | Sihirbazdaki kategoriye özel sorular |

## Medya

| Yöntem | Yol | Amaç |
|---|---|---|
| POST | `/media` | `multipart` yükleme, `purpose` ile; boyut ve tür kontrolü → `{id}` |
| GET | `/media/{id}` | Yetki kontrolü sonrası kısa ömürlü imzalı adrese yönlendirme |

## Müşteri

| Yöntem | Yol | Amaç |
|---|---|---|
| POST | `/requests` | Talep yayınla → `{id, publicCode, matchedProCount, matchFactors}` |
| GET | `/requests?scope=active\|past` | Taleplerim |
| GET | `/requests/{id}` | Talep detayı ve teklif özeti |
| PATCH | `/requests/{id}` | Düzenle (yalnız `OPEN`; teklifler `EXPIRED` olur) |
| POST | `/requests/{id}/cancel` | Gerekçeyle iptal |
| GET | `/requests/{id}/offers?sort=recommended\|price\|rating\|arrival&maxPrice=&minRating=` | Teklifler |
| GET | `/offers/{id}` | Teklif detayı (kalemler dahil) |
| POST | `/offers/{id}/decline` | Gerekçeyle reddet |
| GET | `/pros/{id}` | Usta herkese açık profili |
| GET | `/pros/{id}/reviews` | Değerlendirmeler |

## Ödeme

| Yöntem | Yol | Amaç |
|---|---|---|
| POST | `/payments/3ds/init` | `{offerId, attemptKey, card…}` → `{ref, htmlContent}`; kanal `APP` |
| GET | `/payments/{ref}` | Sonuç; yalnız müşteri, usta (kendi payı) ve admin |
| POST | `/api/payments/3ds/callback` | Banka dönüşü (mevcut adres değişmez) |
| GET | `/api/payments/3ds/done?ref=` | APP kanalı için bitiş sayfası; WebView bunu yakalayıp kapanır |

Eski `/api/offers/{id}` ve `/api/payments/*` uç noktaları yalnızca `dev` profilinde, prototip için kalır.

## İş (müşteri ve usta ortak, katılımcı kontrolü)

| Yöntem | Yol | Kim | Amaç |
|---|---|---|---|
| GET | `/jobs?scope=active\|past` | İkisi | İşlerim |
| GET | `/jobs/{id}` | İkisi | Durum, randevu, aşamalar, tutar, adres (kurala göre) |
| POST | `/jobs/{id}/appointment/proposals` | İkisi | Aralık öner |
| POST | `/jobs/{id}/appointment/proposals/{pid}/accept` | Karşı taraf | Öneriyi kabul et |
| POST | `/jobs/{id}/arrived` | Usta | Adrese ulaştım |
| POST | `/jobs/{id}/start` | Usta | İşe başladım |
| POST | `/jobs/{id}/finish` | Usta | İşi bitirdim; not ve fotoğraflar |
| POST | `/jobs/{id}/events` | Usta | Ara not veya fotoğraf |
| POST | `/jobs/{id}/confirm` | Müşteri | Teslimi onayla → `COMPLETED`, emanet aktarılır |
| POST | `/jobs/{id}/cancel` | İkisi | Gerekçeyle iptal, kurallar `STATE_MACHINES.md` |
| POST | `/jobs/{id}/review` | Müşteri | Puan |
| POST | `/jobs/{id}/complaint` | Müşteri | Şikayet |
| GET | `/complaints/{id}` | Taraflar | Şikayet durumu |
| GET | `/jobs/{id}/messages?after=` | İkisi | Mesajlar (imleçli) |
| POST | `/jobs/{id}/messages` | İkisi | Mesaj gönder |
| POST | `/jobs/{id}/messages/read` | İkisi | Okundu |
| GET | `/conversations` | İkisi | Mesaj kutusu |

## Usta

| Yöntem | Yol | Amaç |
|---|---|---|
| POST | `/pro/application` | Başvuru (kategori, ilçe, deneyim, belge medya kimlikleri) |
| GET | `/pro/application` | Başvuru durumu ve admin notu |
| PUT | `/pro/profile` | Profil, kategoriler, ilçeler, saatler |
| PUT | `/pro/availability` | `ACTIVE` / `ON_BREAK` |
| GET | `/pro/feed?urgency=` | Eşleşen açık talepler (maskeli konum) |
| GET | `/pro/requests/{id}` | Talep detayı |
| POST | `/pro/requests/{id}/offers` | Teklif gönder |
| GET | `/pro/offers?status=` | Tekliflerim |
| POST | `/pro/offers/{id}/withdraw` | Geri çek |
| GET | `/pro/earnings` | Aktarılan, bekleyen, hizmet bedeli |

## Bildirim

| Yöntem | Yol | Amaç |
|---|---|---|
| GET | `/notifications` | Liste |
| POST | `/notifications/read` | Tümü veya seçilenler okundu |
| PUT | `/devices` | Push token kaydı (Aşama 7) |

## Admin

| Yöntem | Yol | Amaç |
|---|---|---|
| GET | `/admin/applications?status=` | Usta başvuruları |
| POST | `/admin/applications/{proId}/approve` | Onayla |
| POST | `/admin/applications/{proId}/reject` | Reddet (gerekçe) |
| POST | `/admin/applications/{proId}/request-documents` | Eksik belge iste (not) |
| GET | `/admin/complaints?status=` | Şikayetler |
| GET | `/admin/complaints/{id}` | Detay: iş, sohbet, aşamalar, kanıt |
| POST | `/admin/complaints/{id}/review` | İncelemeye al |
| POST | `/admin/complaints/{id}/decision` | `FULL_REFUND` / `SPLIT_50_50` / `RELEASE_TO_PRO`, not, uyarı, askı |
| GET | `/admin/users?q=&role=&status=&district=` | Hesaplar |
| POST | `/admin/users/{id}/suspend` · `/reactivate` | Hesap durumu |
| GET | `/admin/payments?status=` | Emanet defteri |

## Geliştirme

| Yöntem | Yol | Amaç |
|---|---|---|
| POST | `/dev/reset` | Seed'i yeniden yükle (yalnız `dev`, yalnız 127.0.0.1) |


## Ayrıntılı sözleşme (wave 2)

### Wave 2 contract: requests, matching, offers, pro application, media

Binding for both backend and Flutter. Field names, enums and status codes are exact. Base `/api/v1`, JSON camelCase, times ISO 8601 UTC, money as JSON numbers with 2 decimals (TRY). Errors `{code, message, field?}` as in wave 1. Lists: `{items, nextCursor}` (`nextCursor` null when done; `?cursor=&limit=` default 20, max 50).

#### Shared types

- `MediaRef` = `{id, url, expiresAt}`. `url` is a short-lived signed URL (10 min) usable WITHOUT auth header (e.g. `Image.network`). Server checks access before signing.
- `ProCard` = `{id, businessName, fullName, ratingAvg, ratingCount, completedJobs, verified}` (`verified` = review status APPROVED).
- `RequestSummary` = `{id, publicCode, title, categoryId, urgency ("URGENT"|"PLANNED"), status ("OPEN"|"ASSIGNED"|"CANCELLED"|"EXPIRED"), districtName, neighborhood, createdAt, expiresAt, offerCount, minOfferTotal (nullable), maxOfferTotal (nullable)}`. `offerCount` and min/max count PENDING offers only.
- `RequestDetail` = `RequestSummary` + `{description, preferredFrom, preferredTo, photos: [MediaRef], answers: [{questionKey, answer}], matchedProCount, matchFactors: ["CATEGORY","DISTRICT","AVAILABILITY"], address: {districtName, neighborhood, lineFull, doorNote}}`. `lineFull`/`doorNote` only for the owner (null for anyone else).
- `OfferItem` = `{kind ("LABOR"|"MATERIAL"), description, quantity, unitPrice, lineTotal}`.
- `OfferSummary` = `{id, publicCode, requestId, status ("PENDING"|"ACCEPTED"|"DECLINED"|"WITHDRAWN"|"SUPERSEDED"|"EXPIRED"), pro: ProCard, laborAmount, materialsAmount, totalAmount, arrivalFrom, arrivalTo, warrantyMonths (0|3|6|12), note, validUntil, createdAt}`.
- `OfferDetail` = `OfferSummary` + `{items: [OfferItem], serviceFee (nullable), netEarning (nullable), declineReason (nullable)}`. `serviceFee` = 10% of total and `netEarning` = total − fee, filled ONLY when the viewer is the offering pro; null for the customer.

#### Media

- `POST /media` multipart: `file`, `purpose` (`REQUEST_PHOTO`|`PRO_DOCUMENT`|`AVATAR`|`JOB_PHOTO`|`CHAT`|`COMPLAINT`) → 201 `{id, contentType, sizeBytes, width, height}`.
  - Photos: JPEG/PNG/HEIC, ≤ 1.5 MB (1 572 864 bytes). `PRO_DOCUMENT`: PDF/JPEG/PNG ≤ 5 MB. Type is checked by magic bytes, not by the filename. Over limit → 400 `VALIDATION_FAILED` field `file`.
  - Uploaded media is owned by the uploader and unattached until used. Attaching someone else's media id → 404.
- `GET /media/{id}/content?exp=&sig=` serves bytes when the signature is valid (no auth). Invalid/expired → 403 `FORBIDDEN`.

#### Catalog

- `GET /categories/{id}/questions` → `[{key, labelTr, labelEn, options: [{value, labelTr, labelEn}]}]` (single choice). `plumbing`: `since` (Bugün / Birkaç gün / 1 haftadan fazla), `water_cut` (Evet / Hayır), `other_rooms` (Evet / Hayır). Every other category: only `since`.

#### Customer

- `POST /requests` body `{categoryId, urgency, preferredFrom?, preferredTo?, title (5-150), description (20-2000), addressId, photoIds (0-5, REQUEST_PHOTO, own, unattached), answers: [{questionKey, answer}]}` → 201 `RequestDetail`.
  - `PLANNED` requires `preferredFrom` < `preferredTo`, both in the future, within 30 days. `URGENT` ignores them (null).
  - District and neighbourhood come from the address (must be the caller's; else 404).
  - `expiresAt` = createdAt + 7 days.
  - Matching (UC03): `matchedProCount` = pros with review status APPROVED, availability ACTIVE, the category and the district, excluding the customer themself. Always publish, even with 0 matches.
- `GET /requests?scope=active|past` → `{items: [RequestSummary]}`. Active = OPEN, plus ASSIGNED while the job is not finished (wave 2: all ASSIGNED). Past = CANCELLED, EXPIRED.
- `GET /requests/{id}` → `RequestDetail` (owner only; else 404).
- `PATCH /requests/{id}` same fields as POST, all optional; only OPEN; all PENDING offers → EXPIRED; matchedProCount recomputed.
- `POST /requests/{id}/cancel` `{reason ("PLANS_CHANGED"|"SOLVED"|"NO_SUITABLE_OFFER"|"OTHER"), note?}` → `RequestDetail` (CANCELLED; PENDING offers → EXPIRED). Only OPEN, else 409 `ILLEGAL_STATE`.
- `GET /requests/{id}/offers?sort=recommended|price|rating|arrival&maxPrice=&minRating=` → `{items: [OfferSummary], declinedCount}`. PENDING only. `recommended` = rating desc, then price asc.
- `GET /offers/{id}` → `OfferDetail` (request owner or offering pro; else 404).
- `POST /offers/{id}/decline` `{reason ("PRICE"|"SCHEDULE"|"OTHER_OFFER"|"NOT_NEEDED"|"OTHER"), note?, keepRequestOpen (bool)}` → `OfferDetail`. Owner only, PENDING only. `keepRequestOpen=false` also cancels the request (reason `NOT_NEEDED` or `OTHER`).
- `GET /pros/{id}` → `{id, businessName, fullName, bio, experienceYears, ratingAvg, ratingCount, completedJobs, memberSince, categoryIds, districts: [{id, name}], verifiedDocuments: ["IDENTITY"|"TRADE_CERT"|"TAX"|"CRIMINAL_RECORD"]}`. APPROVED pros only, else 404. Never phone or email.
- `GET /pros/{id}/reviews` → `{items: [{id, rating, tags, comment, authorDisplay, createdAt}]}`. `authorDisplay` = initials "A.Y." or "Anonim". (No reviews exist yet in wave 2; endpoint must still work.)

#### Pro

All `/pro/*` except the application endpoints require review status APPROVED (else 403 `PRO_NOT_APPROVED`).

- `POST /pro/application` `{businessName (2-100), bio (0-1000), experienceYears (0-60), categoryIds (≥1), districtIds (≥1), documents: [{type, mediaId}]}` → 201 `ProApplication`. Requires at least `IDENTITY` and `TRADE_CERT` (PRO_DOCUMENT media, own). Allowed when there is no profile or it is NEEDS_DOCUMENTS/REJECTED (→ PENDING_REVIEW). PENDING_REVIEW/APPROVED/SUSPENDED → 409 `ILLEGAL_STATE`.
- `GET /pro/application` → `ProApplication` = `{reviewStatus, reviewNote, businessName, bio, experienceYears, categoryIds, districtIds, documents: [{id, type, status ("PENDING"|"ACCEPTED"|"REJECTED"), media: MediaRef}], submittedAt}`. 404 when none.
- `GET /pro/profile` → `ProProfile` = `{businessName, bio, experienceYears, categoryIds, districtIds, workingHours: [{weekday (1-7), start "HH:mm", end "HH:mm", acceptsUrgent}], reviewStatus, availability, ratingAvg, ratingCount, completedJobs}`.
- `PUT /pro/profile` `{businessName, bio, experienceYears, categoryIds, districtIds, workingHours}` → `ProProfile`.
- `PUT /pro/availability` `{availability ("ACTIVE"|"ON_BREAK")}` → `ProProfile`.
- `GET /pro/feed?urgency=URGENT|PLANNED` → `{items: [FeedItem], onBreak}`. OPEN, not expired requests matching the pro's categories and districts, not the pro's own. `onBreak=true` → items empty.
  - `FeedItem` = `{id, publicCode, title, categoryId, urgency, districtName, neighborhood, createdAt, preferredFrom, preferredTo, photoCount, offerCount, myOfferId (nullable)}`.
- `GET /pro/requests/{id}` → `FeedItem` + `{description, photos: [MediaRef], answers, myOffer: OfferDetail|null}`. Address never beyond district + neighbourhood. Not matching → 404.
- `POST /pro/requests/{id}/offers` (optional `Idempotency-Key` header: same key → same response) `{laborAmount (>0), materialsAmount (≥0), arrivalFrom, arrivalTo, warrantyMonths (0|3|6|12), note (0-500), items: [{kind, description, quantity (>0), unitPrice (≥0)}]}` → 201 `OfferDetail`.
  - When `items` is non-empty, the LABOR item sum must equal `laborAmount` and the MATERIAL sum `materialsAmount` (else 400 field `items`).
  - `arrivalFrom` > now; `arrivalTo` − `arrivalFrom` between 1 h and 12 h; `arrivalFrom` within 14 days.
  - `validUntil` = min(`arrivalTo`, now + 72 h).
  - Request must be OPEN and matching → else 409 `ILLEGAL_STATE` / 404. Existing PENDING offer by the same pro → 409 `ALREADY_OFFERED`.
- `GET /pro/offers?status=` → `{items: [OfferSummary + request: {id, publicCode, title, districtName}]}`.
- `POST /pro/offers/{id}/withdraw` → `OfferDetail` (PENDING only, own).

#### Server-side jobs and side effects

- A scheduler (every 5 min, `FOR UPDATE SKIP LOCKED`) expires OPEN requests past `expiresAt` (→ EXPIRED, PENDING offers → EXPIRED) and PENDING offers past `validUntil` (→ EXPIRED). Reads also treat past-due items as expired.
- `NotificationService.notify(userId, type, params, targetRoute)` inserts a row in `notifications` (no endpoints yet). Types this wave: `NEW_MATCHING_REQUEST` (to matched pros), `OFFER_RECEIVED` (to customer), `OFFER_DECLINED` (to pro).

#### Not in this wave

Offer acceptance and payment, jobs, chat, reviews creation, complaints, admin endpoints, push.

#### Uygulama notları (backend)

- Soru seçenek `value` kodları: `since` = `today` / `few_days` / `over_week`; `water_cut` ve `other_rooms` = `yes` / `no`. Talep cevabı bu kodları taşır; geçersiz soru veya seçenek 400 `answers`.
- Liste imleci (`cursor`) opak bir dizedir; yalnızca `nextCursor` değeri geri verilir. Sözleşmede `{items}` diye geçen yanıtlar ek olarak `nextCursor` taşır.
- `MediaRef.url` mutlak adrestir: `bitadilat.media.url-base` doluysa (prod: `APP_PUBLIC_BASE_URL`) o taban, boşsa isteğin kendi adresi kullanılır. `MEDIA_SIGNING_KEY` (en az 32 bayt) ve `MEDIA_DIR` prod'da zorunludur; dev varsayılanı `./data/media`.
- `Idempotency-Key` (en fazla 64 karakter, `A-Za-z0-9._:-`) teklif satırına yazılır; tekrar, teklifin güncel halini 201 ile döner. Aynı anahtar başka talepte 409 `DUPLICATE_ATTEMPT`.
- `decline` ile `keepRequestOpen=false` kullanılırsa `reason` yalnızca `NOT_NEEDED` veya `OTHER` olabilir (aksi 400 `reason`); talep `PLANS_CHANGED` (`NOT_NEEDED`) veya `OTHER` gerekçesiyle iptal edilir.
- Süresi dolmuş `PENDING` teklifte `decline`/`withdraw` 409 `OFFER_EXPIRED` döner.
- Mola (`ON_BREAK`) modundaki usta teklif gönderemez (409 `ILLEGAL_STATE`).
- Şema: `V3__wave2_requests_offers_media.sql` (başlık 150, iptal gerekçesi, ret notu, idempotency anahtarı, kalem sırası, HEIC, kod dizileri).
