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

Binding for both backend and Flutter. Field names, enums and status codes are exact.

**General rules**
- Base path `/api/v1`. JSON in camelCase.
- Times are ISO 8601 UTC.
- Money is a JSON number with 2 decimals (TRY).
- Errors are `{code, message, field?}`, as in wave 1.
- Lists are `{items, nextCursor}`; `nextCursor` is null on the last page. Paging uses `?cursor=&limit=` (default 20, max 50).

#### Shared types

- **`MediaRef`** = `{id, url, expiresAt}`.
  - `url` is a signed URL valid for 10 minutes. It works without an auth header (e.g. `Image.network`).
  - The server checks access before signing.
- **`ProCard`** = `{id, businessName, fullName, ratingAvg, ratingCount, completedJobs, verified}`.
  - `verified` means review status APPROVED.
- **`RequestSummary`** = `{id, publicCode, title, categoryId, urgency, status, districtName, neighborhood, createdAt, expiresAt, offerCount, minOfferTotal, maxOfferTotal}`.
  - `urgency`: `"URGENT"` or `"PLANNED"`.
  - `status`: `"OPEN"`, `"ASSIGNED"`, `"CANCELLED"` or `"EXPIRED"`.
  - `minOfferTotal` and `maxOfferTotal` are nullable.
  - `offerCount`, `minOfferTotal` and `maxOfferTotal` count PENDING offers only.
- **`RequestDetail`** = `RequestSummary` + `{description, preferredFrom, preferredTo, photos, answers, matchedProCount, matchFactors, address}`.
  - `photos`: `[MediaRef]`.
  - `answers`: `[{questionKey, answer}]`.
  - `matchFactors`: `["CATEGORY","DISTRICT","AVAILABILITY"]`.
  - `address`: `{districtName, neighborhood, lineFull, doorNote}`. `lineFull` and `doorNote` are filled only for the owner and are null for anyone else.
- **`OfferItem`** = `{kind, description, quantity, unitPrice, lineTotal}`, where `kind` is `"LABOR"` or `"MATERIAL"`.
- **`OfferSummary`** = `{id, publicCode, requestId, status, pro, laborAmount, materialsAmount, totalAmount, arrivalFrom, arrivalTo, warrantyMonths, note, validUntil, createdAt}`.
  - `status`: `"PENDING"`, `"ACCEPTED"`, `"DECLINED"`, `"WITHDRAWN"`, `"SUPERSEDED"` or `"EXPIRED"`.
  - `pro`: `ProCard`.
  - `warrantyMonths`: 0, 3, 6 or 12.
- **`OfferDetail`** = `OfferSummary` + `{items, serviceFee, netEarning, declineReason}`.
  - `items`: `[OfferItem]`.
  - `serviceFee` (10% of total) and `netEarning` (total − fee) are filled ONLY when the viewer is the offering pro. For the customer they are null.
  - `declineReason` is nullable.

#### Media

**`POST /media`** (multipart, fields `file` and `purpose`) → 201 `{id, contentType, sizeBytes, width, height}`.
- `purpose` is one of `REQUEST_PHOTO`, `PRO_DOCUMENT`, `AVATAR`, `JOB_PHOTO`, `CHAT`, `COMPLAINT`.
- Photos: JPEG, PNG or HEIC, at most 1.5 MB (1 572 864 bytes).
- `PRO_DOCUMENT`: PDF, JPEG or PNG, at most 5 MB.
- File type is checked by magic bytes, not by filename.
- Over the size limit → 400 `VALIDATION_FAILED` with field `file`.
- Uploaded media belongs to the uploader and stays unattached until used. Attaching someone else's media id → 404.

**`GET /media/{id}/content?exp=&sig=`** serves the bytes when the signature is valid; no auth needed.
- Invalid or expired signature → 403 `FORBIDDEN`.

#### Catalog

**`GET /categories/{id}/questions`** → `[{key, labelTr, labelEn, options: [{value, labelTr, labelEn}]}]`. All questions are single choice.
- `plumbing` has three questions:
  - `since`: Bugün / Birkaç gün / 1 haftadan fazla.
  - `water_cut`: Evet / Hayır.
  - `other_rooms`: Evet / Hayır.
- Every other category has only `since`.

#### Customer

**`POST /requests`** → 201 `RequestDetail`.
- Body: `{categoryId, urgency, preferredFrom?, preferredTo?, title, description, addressId, photoIds, answers}`.
  - `title`: 5-150 characters.
  - `description`: 20-2000 characters.
  - `photoIds`: 0-5 ids, each a `REQUEST_PHOTO` of the caller's own that is not yet attached.
  - `answers`: `[{questionKey, answer}]`.
- `PLANNED` requires `preferredFrom` < `preferredTo`, both in the future and within 30 days. `URGENT` ignores both and stores null.
- District and neighbourhood come from the address. The address must be the caller's, else 404.
- `expiresAt` = createdAt + 7 days.
- Matching (UC03): `matchedProCount` counts pros that meet all of these:
  - review status APPROVED;
  - availability ACTIVE;
  - the request's category and district;
  - not the customer themself.
- The request is always published, even with 0 matches.

**`GET /requests?scope=active|past`** → `{items: [RequestSummary]}`.
- `active` = OPEN, plus ASSIGNED while the job is not finished (in wave 2: every ASSIGNED).
- `past` = CANCELLED and EXPIRED.

**`GET /requests/{id}`** → `RequestDetail`. Owner only, else 404.

**`PATCH /requests/{id}`** takes the same fields as POST, all optional.
- Only allowed while OPEN.
- All PENDING offers become EXPIRED.
- `matchedProCount` is recomputed.

**`POST /requests/{id}/cancel`** `{reason, note?}` → `RequestDetail`.
- `reason`: `"PLANS_CHANGED"`, `"SOLVED"`, `"NO_SUITABLE_OFFER"` or `"OTHER"`.
- The request becomes CANCELLED and its PENDING offers become EXPIRED.
- Only allowed while OPEN, else 409 `ILLEGAL_STATE`.

**`GET /requests/{id}/offers?sort=recommended|price|rating|arrival&maxPrice=&minRating=`** → `{items: [OfferSummary], declinedCount}`.
- Returns PENDING offers only.
- `recommended` sorts by rating descending, then price ascending.

**`GET /offers/{id}`** → `OfferDetail`. Allowed for the request owner and the offering pro, else 404.

**`POST /offers/{id}/decline`** `{reason, note?, keepRequestOpen}` → `OfferDetail`.
- `reason`: `"PRICE"`, `"SCHEDULE"`, `"OTHER_OFFER"`, `"NOT_NEEDED"` or `"OTHER"`.
- `keepRequestOpen` is a bool. When false, the request is cancelled too (only with reason `NOT_NEEDED` or `OTHER`).
- Owner only, PENDING offers only.

**`GET /pros/{id}`** → `{id, businessName, fullName, bio, experienceYears, ratingAvg, ratingCount, completedJobs, memberSince, categoryIds, districts, verifiedDocuments}`.
- `districts`: `[{id, name}]`.
- `verifiedDocuments`: any of `"IDENTITY"`, `"TRADE_CERT"`, `"TAX"`, `"CRIMINAL_RECORD"`.
- APPROVED pros only, else 404.
- Never returns phone or email.

**`GET /pros/{id}/reviews`** → `{items: [{id, rating, tags, comment, authorDisplay, createdAt}]}`.
- `authorDisplay` is initials such as "A.Y.", or "Anonim".
- No reviews exist yet in wave 2, but the endpoint must still work.

#### Pro

All `/pro/*` endpoints except the application endpoints require review status APPROVED, else 403 `PRO_NOT_APPROVED`.

**`POST /pro/application`** → 201 `ProApplication`.
- Body: `{businessName, bio, experienceYears, categoryIds, districtIds, documents}`.
  - `businessName`: 2-100 characters.
  - `bio`: 0-1000 characters.
  - `experienceYears`: 0-60.
  - `categoryIds` and `districtIds`: at least one each.
  - `documents`: `[{type, mediaId}]`.
- Requires at least `IDENTITY` and `TRADE_CERT`, each a `PRO_DOCUMENT` media of the caller's own.
- Allowed when there is no profile, or the profile is NEEDS_DOCUMENTS or REJECTED. The profile then becomes PENDING_REVIEW.
- When the profile is PENDING_REVIEW, APPROVED or SUSPENDED → 409 `ILLEGAL_STATE`.

**`GET /pro/application`** → `ProApplication`, or 404 when there is none.
- `ProApplication` = `{reviewStatus, reviewNote, businessName, bio, experienceYears, categoryIds, districtIds, documents, submittedAt}`.
- `documents`: `[{id, type, status, media}]`, where `status` is `"PENDING"`, `"ACCEPTED"` or `"REJECTED"` and `media` is a `MediaRef`.

**`GET /pro/profile`** → `ProProfile`.
- `ProProfile` = `{businessName, bio, experienceYears, categoryIds, districtIds, workingHours, reviewStatus, availability, ratingAvg, ratingCount, completedJobs}`.
- `workingHours`: `[{weekday, start, end, acceptsUrgent}]`, where `weekday` is 1-7 and `start`/`end` are `"HH:mm"`.

**`PUT /pro/profile`** `{businessName, bio, experienceYears, categoryIds, districtIds, workingHours}` → `ProProfile`.

**`PUT /pro/availability`** `{availability}` → `ProProfile`. `availability` is `"ACTIVE"` or `"ON_BREAK"`.

**`GET /pro/feed?urgency=URGENT|PLANNED`** → `{items: [FeedItem], onBreak}`.
- Returns OPEN, unexpired requests that match the pro's categories and districts, excluding the pro's own requests.
- When `onBreak` is true, `items` is empty.
- `FeedItem` = `{id, publicCode, title, categoryId, urgency, districtName, neighborhood, createdAt, preferredFrom, preferredTo, photoCount, offerCount, myOfferId}`; `myOfferId` is nullable.

**`GET /pro/requests/{id}`** → `FeedItem` + `{description, photos, answers, myOffer}`.
- `photos`: `[MediaRef]`.
- `myOffer`: `OfferDetail` or null.
- The address is never shown beyond district and neighbourhood.
- A request that does not match the pro → 404.

**`POST /pro/requests/{id}/offers`** → 201 `OfferDetail`.
- Optional `Idempotency-Key` header: the same key returns the same response.
- Body: `{laborAmount, materialsAmount, arrivalFrom, arrivalTo, warrantyMonths, note, items}`.
  - `laborAmount` > 0; `materialsAmount` ≥ 0.
  - `warrantyMonths`: 0, 3, 6 or 12.
  - `note`: 0-500 characters.
  - `items`: `[{kind, description, quantity, unitPrice}]`, with `quantity` > 0 and `unitPrice` ≥ 0.
- When `items` is non-empty, the LABOR items must sum to `laborAmount` and the MATERIAL items to `materialsAmount`, else 400 with field `items`.
- Arrival window rules:
  - `arrivalFrom` > now and within 14 days;
  - `arrivalTo` − `arrivalFrom` is between 1 h and 12 h.
- `validUntil` = min(`arrivalTo`, now + 72 h).
- Request not OPEN → 409 `ILLEGAL_STATE`; request not matching → 404.
- The same pro already has a PENDING offer → 409 `ALREADY_OFFERED`.

**`GET /pro/offers?status=`** → `{items: [OfferSummary + request]}`, where `request` = `{id, publicCode, title, districtName}`.

**`POST /pro/offers/{id}/withdraw`** → `OfferDetail`. Own PENDING offers only.

#### Server-side jobs and side effects

- **Expiry scheduler:** runs every 5 minutes with `FOR UPDATE SKIP LOCKED`.
  - OPEN requests past `expiresAt` become EXPIRED, and their PENDING offers become EXPIRED.
  - PENDING offers past `validUntil` become EXPIRED.
  - Reads also treat past-due items as expired.
- **Notifications:** `NotificationService.notify(userId, type, params, targetRoute)` inserts a row in `notifications`. There are no notification endpoints yet. Types this wave:
  - `NEW_MATCHING_REQUEST`, to matched pros.
  - `OFFER_RECEIVED`, to the customer.
  - `OFFER_DECLINED`, to the pro.

#### Not in this wave

Offer acceptance and payment, jobs, chat, creating reviews, complaints, admin endpoints and push notifications.

#### Uygulama notları (backend)

- Soru seçenek `value` kodları: `since` = `today` / `few_days` / `over_week`; `water_cut` ve `other_rooms` = `yes` / `no`. Talep cevabı bu kodları taşır; geçersiz soru veya seçenek 400 `answers`.
- Liste imleci (`cursor`) opak bir dizedir; yalnızca `nextCursor` değeri geri verilir. Sözleşmede `{items}` diye geçen yanıtlar ek olarak `nextCursor` taşır.
- `MediaRef.url` mutlak adrestir: `bitadilat.media.url-base` doluysa (prod: `APP_PUBLIC_BASE_URL`) o taban, boşsa isteğin kendi adresi kullanılır. `MEDIA_SIGNING_KEY` (en az 32 bayt) ve `MEDIA_DIR` prod'da zorunludur; dev varsayılanı `./data/media`.
- `Idempotency-Key` (en fazla 64 karakter, `A-Za-z0-9._:-`) teklif satırına yazılır; tekrar, teklifin güncel halini 201 ile döner. Aynı anahtar başka talepte 409 `DUPLICATE_ATTEMPT`.
- `decline` ile `keepRequestOpen=false` kullanılırsa `reason` yalnızca `NOT_NEEDED` veya `OTHER` olabilir (aksi 400 `reason`); talep `PLANS_CHANGED` (`NOT_NEEDED`) veya `OTHER` gerekçesiyle iptal edilir.
- Süresi dolmuş `PENDING` teklifte `decline`/`withdraw` 409 `OFFER_EXPIRED` döner.
- Mola (`ON_BREAK`) modundaki usta teklif gönderemez (409 `ILLEGAL_STATE`).
- Şema: `V3__wave2_requests_offers_media.sql` (başlık 150, iptal gerekçesi, ret notu, idempotency anahtarı, kalem sırası, HEIC, kod dizileri) ve `V4__media_single_attachment.sql` (bir medya tek kayda bağlanır).
- Uzunluk kuralları (başlık, açıklama, işletme adı) kırpılmış metne uygulanır.
- `GET /pro/requests/{id}` yalnız talep `OPEN` iken açılır (eşleşen veya bekleyen teklifi olan usta); kapanan talep her usta için 404 (ROLE_SCREEN_MAP erişim kuralı).
- Süresi geçmiş ama zamanlayıcının henüz işlemediği `PENDING` teklif, aynı ustanın yeni teklifine engel olmaz; yeni teklif verilirken `EXPIRED` yapılır.
