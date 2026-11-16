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


## Ayrıntılı sözleşme (wave 3)

### Wave 3 contract: payment, jobs, appointments, chat, reviews, complaints

Binding for both backend and Flutter. Wave 1 and wave 2 contracts still apply. These rules hold everywhere unless a section says otherwise:

- Base path is `/api/v1`.
- JSON keys are camelCase.
- Times are ISO 8601 UTC.
- Money is TRY with 2 decimals.
- Errors look like `{code, message, field?}`.
- A caller who is not a participant gets 404.
- An invalid state transition returns 409 `ILLEGAL_STATE`.
- Rules come from `docs/spec/STATE_MACHINES.md` §4-6. Where this file is more specific, this file wins.

#### Shared types

**`JobSummary`**:

| Field | Type / meaning |
|---|---|
| `id`, `publicCode`, `requestId`, `title`, `categoryId`, `status` | Basic job fields. `publicCode` is the request's `BD-#####`. |
| `viewerRole` | `"CUSTOMER"` or `"PRO"` |
| `counterpart` | `{id, displayName}`. The customer sees the pro's businessName; the pro sees the customer as "Ali Y." (first name and initial). |
| `totalAmount` | Money |
| `scheduledFrom`, `scheduledTo` | Nullable |
| `updatedAt` | Time |
| `unreadMessages` | Count |

`status` is one of `AWAITING_APPOINTMENT`, `SCHEDULED`, `ARRIVED`, `IN_PROGRESS`, `WORK_FINISHED`, `COMPLETED`, `DISPUTED`, `CANCELLED`, `RESOLVED`.

**`JobDetail`** is `JobSummary` plus:

| Field | Type / meaning |
|---|---|
| `offer` | `OfferDetail`. `serviceFee` and `netEarning` are filled only for the pro. |
| `address` | `{districtName, neighborhood, lineFull, doorNote}`. Both participants see the full line once a job exists. |
| `appointment` | `{scheduledFrom, scheduledTo, pendingProposal}`. `pendingProposal` is null or `{id, proposedBy ("CUSTOMER"\|"PRO"), slotFrom, slotTo, createdAt}`. |
| `timeline` | `[JobEvent]`, oldest first |
| `payment` | `{ref, status, totalAmount, refundedAmount, serviceFee, netEarning}`. `serviceFee` and `netEarning` are filled only for the pro. |
| `autoCompleteAt` | Nullable |
| `review` | `ReviewItem` or null |
| `complaint` | null or `{id, publicCode, status}` |
| `allowedActions` | `[string]`, computed for this viewer from the state machine |

`allowedActions` values: `PROPOSE_SLOT`, `ACCEPT_PROPOSAL`, `MARK_ARRIVED`, `START_WORK`, `FINISH_WORK`, `ADD_NOTE`, `CONFIRM_COMPLETION`, `CANCEL`, `COMPLAIN`, `REVIEW`, `CHAT`. The client shows buttons only from this list.

**`JobEvent`** = `{id, type, fromStatus, toStatus, note, photo, actorRole, createdAt}`.
- `type`: `STATUS_CHANGED`, `NOTE`, `PHOTO`, `APPOINTMENT_PROPOSED` or `APPOINTMENT_ACCEPTED`.
- `photo`: `MediaRef` or null.
- `actorRole`: `CUSTOMER`, `PRO`, `SYSTEM` or `ADMIN`.

**`Message`** = `{id, senderRole, mine, body, photo, createdAt}`.
- `id` is a long and doubles as the cursor.
- `senderRole`: `"CUSTOMER"` or `"PRO"`.
- `mine` is a bool.
- `photo` is a `MediaRef` or null.

**`Complaint`** = `{id, publicCode, jobId, reason, description, evidence, status, decision, decisionNote, createdAt, decidedAt}`.
- `publicCode` has the form `SK-####`.
- `evidence` is `[MediaRef]`.
- `status`: `OPEN`, `IN_REVIEW`, `RESOLVED` or `DISMISSED`.
- `decision` is nullable.

**`PaymentResult`** = `{ref, status, offerId, requestId, jobId, totalAmount, cardLast4, errorCode, errorMessage, resultUncertain}`.
- `status` is the escrow status: `INITIALIZED`, `LOCKED`, `FAILED`, `REFUNDED_TO_CUSTOMER`, `RELEASED_TO_PRO`, `DISPUTED` or `SPLIT_SETTLED`.
- `jobId` is nullable.
- `errorCode` is nullable: `PAYMENT_DECLINED`, `REQUEST_ALREADY_ASSIGNED`, `OFFER_EXPIRED` or `RESULT_UNCERTAIN`.
- `errorMessage` is a nullable, friendly Turkish message for display.

Wave 2 changes:
- `RequestSummary` gains `jobId` (nullable). It is set when the request is ASSIGNED.
- `GET /pro/requests/{id}` gains `status`.
- The wave 2 codes `OFFER_EXPIRED` (409) and `DUPLICATE_ATTEMPT` (409) are official.

#### Payment (app channel)

**`POST /payments/3ds/init`** (customer)
- Body: `{offerId, attemptKey (UUID), cardHolderName, cardNumber, expireMonth, expireYear (4 digits), cvc}`.
- Returns 200 `{ref, htmlContent}`.
- Preconditions:
  - The caller owns the request.
  - The request is OPEN.
  - The offer is PENDING and its `validUntil` is in the future. Otherwise 409 `OFFER_EXPIRED` / `ILLEGAL_STATE`.
- The amount always comes from the offer on the server.
- Errors:
  - An INITIALIZED payment already exists for this request → 409 `PAYMENT_IN_PROGRESS`.
  - Same `attemptKey` reused → 409 `DUPLICATE_ATTEMPT`.
  - 400 `INVALID_CARD` with `field` = `holderName` | `number` | `expiry` | `cvc`.
  - 402 `PAYMENT_DECLINED` with `ref`.
  - 502 `GATEWAY_ERROR`.
- Card data is never stored or logged. This is the existing `CardValidator` and `PaymentGateway` behaviour.

**Bank return**
- The bank posts to the existing `POST /api/payments/3ds/callback`; that path does not change.
- For `channel = APP` the result page goes to `GET /api/payments/3ds/done?ref=<ref>`. That page is minimal static HTML ("İşlem tamamlandı, uygulamaya dönülüyor…"), shows no payment data and is public.
- The `PROTOTYPE` channel behaves exactly as before.

**`GET /payments/{ref}`** returns `PaymentResult`.
- Visible to the customer who owns it, the assigned pro and admins; anyone else gets 404.
- While INITIALIZED, `resultUncertain` is true.

**Acceptance happens in the callback's own transaction**, at the moment the escrow becomes LOCKED. Lock the request row with `FOR UPDATE`, then:
- **If the request is still OPEN and the offer is PENDING and unexpired:**
  - Offer → ACCEPTED.
  - Other PENDING offers → SUPERSEDED. Notify those pros with `OFFER_SUPERSEDED`.
  - Request → ASSIGNED.
  - Job created in AWAITING_APPOINTMENT, with `offer`, `customer` and `pro` set.
  - `escrow_payment.job_id` set.
  - Notify the pro with `OFFER_ACCEPTED`.
- **Otherwise:**
  - Refund immediately through the gateway (full amount).
  - Escrow → REFUNDED_TO_CUSTOMER, with `errorCode` = `REQUEST_ALREADY_ASSIGNED` or `OFFER_EXPIRED`.
  - No job is created.

**Escrow additions (migration):** `request_id`, `customer_id`, `pro_id`, `job_id`, `channel` (`APP` | `PROTOTYPE`), `provider` (`CRAFTGATE` | `SEED`), `error_code`, and a partial unique index on `request_id` WHERE `status='INITIALIZED'`.

**Prototype:**
- The legacy `/api/offers/**` and `/api/payments/**` endpoints (callback and done excepted) stay for the HTML prototype. They use the static `OfferCatalog`, are channel PROTOTYPE, and create no job.
- They exist only in the `dev` profile. In `prod` they return 404. The callback and done endpoints exist in every profile.

**`provider = SEED`:** release and refund of seeded payments are ledger-only, with no gateway call. This is allowed only in `dev`.

#### Jobs

**`GET /jobs?as=CUSTOMER|PRO&scope=active|past`** returns `{items: [JobSummary]}`.
- `active`: every status except COMPLETED, CANCELLED and RESOLVED.
- `past`: COMPLETED, CANCELLED and RESOLVED.

**`GET /jobs/{id}`** returns `JobDetail`.

**Appointment proposals**
- **`POST /jobs/{id}/appointment/proposals`** with body `{slotFrom, slotTo}` returns `JobDetail`.
  - Allowed in AWAITING_APPOINTMENT and SCHEDULED, by either side.
  - The window must be 1 to 12 hours long, start in the future and fall within 30 days.
  - At most one proposal is PENDING:
    - A new proposal from the same side marks the old one SUPERSEDED.
    - A proposal from the other side marks the old one REJECTED.
- **`POST /jobs/{id}/appointment/proposals/{pid}/accept`**, by the side that did not propose, returns `JobDetail`.
  - The proposal becomes ACCEPTED and `scheduledFrom`/`scheduledTo` are set.
  - AWAITING_APPOINTMENT → SCHEDULED. In SCHEDULED it only reschedules.

**Pro stage changes**

| Endpoint | Allowed in | Result |
|---|---|---|
| `POST /jobs/{id}/arrived` | SCHEDULED | → ARRIVED |
| `POST /jobs/{id}/start` | ARRIVED | → IN_PROGRESS |
| `POST /jobs/{id}/finish` `{note (10-1000), photoIds (0-5 JOB_PHOTO)}` | IN_PROGRESS | → WORK_FINISHED, `autoCompleteAt` = now + 48 h, notify the customer with `WORK_FINISHED` |
| `POST /jobs/{id}/events` `{note?, photoIds?}` | ARRIVED, IN_PROGRESS | Adds a note or photo; at least one of the two is required |

All of these return `JobDetail` and notify the customer.

**`POST /jobs/{id}/confirm`** (customer, WORK_FINISHED)
- Job → COMPLETED.
- Escrow → RELEASED_TO_PRO.
- `payout_ledger` gets a PAYOUT row and a COMMISSION row.
- The pro's `completed_jobs` goes up by 1.
- Notify the pro with `PAYOUT_RELEASED`.

**`POST /jobs/{id}/cancel`** with body `{reason, note?}`
- Allowed in AWAITING_APPOINTMENT, SCHEDULED and ARRIVED.
- Customer reasons: `PLANS_CHANGED`, `SOLVED`, `PRO_UNREACHABLE`, `OTHER_PROVIDER`, `OTHER`.
- Pro reasons: `SCHEDULE_CONFLICT`, `CANNOT_DO_JOB`, `CUSTOMER_UNREACHABLE`, `OTHER`.
- Every cancel issues a full refund through the gateway, then sets escrow REFUNDED_TO_CUSTOMER and job CANCELLED.
- **Customer cancel:** request → CANCELLED.
- **Pro cancel:**
  - Request → OPEN.
  - The accepted offer → WITHDRAWN.
  - SUPERSEDED offers whose `validUntil` is still in the future → PENDING again.
  - The pro's `cancellation_count` goes up by 1.
- If the gateway refund fails: 502 `GATEWAY_ERROR` and nothing changes.
- Notify the other side with `JOB_CANCELLED`.

**`POST /jobs/{id}/review`** (customer, COMPLETED, once)
- Body: `{rating (1-5), tags, comment (0-1000), anonymous}`.
- `tags` is a subset of `ON_TIME`, `CLEAN_WORK`, `FAIR_PRICE`, `GOOD_COMMUNICATION`, `POLITE`.
- Returns `JobDetail`.
- The pro's `rating_avg` and `rating_count` are recomputed in the same transaction.

**`POST /jobs/{id}/complaint`** (customer)
- Allowed in SCHEDULED, ARRIVED, IN_PROGRESS and WORK_FINISHED.
- Body: `{reason, description (20-2000), evidenceIds (0-5 COMPLAINT)}`.
  - `reason` is one of `NO_SHOW`, `INCOMPLETE_WORK`, `EXTRA_CHARGE`, `RUDE_BEHAVIOUR`, `OTHER`.
- Returns 201 `Complaint`.
- In the same transaction:
  - Job → DISPUTED, with `status_before_dispute` saved.
  - Escrow → DISPUTED.
  - `autoCompleteAt` cleared.
  - Notify the pro and every admin with `COMPLAINT_OPENED`.

**`GET /complaints/{id}`** returns `Complaint`. Visible to participants and admins.

**Auto-complete scheduler** (every 5 min, `SKIP LOCKED`):
- A WORK_FINISHED job whose `autoCompleteAt` ≤ now and that has no open complaint is confirmed exactly as above; actor is `SYSTEM`.
- The customer gets `AUTO_COMPLETE_REMINDER` once, 24 h before.

#### Chat

**`GET /jobs/{id}/messages?after=<id>&limit=50`** returns `{items: [Message], otherLastReadId}`. Items come in ascending order.

**`POST /jobs/{id}/messages`** with body `{body (1-2000 trimmed), photoId?}` returns 201 `Message`.
- `photoId` must be a CHAT media item.
- 30 days after COMPLETED, CANCELLED or RESOLVED → 409 `ILLEGAL_STATE` (the chat becomes read-only).
- Notify the other side with `NEW_MESSAGE`, but only when they have no unread `NEW_MESSAGE` for this job already.

**`POST /jobs/{id}/messages/read`** with body `{lastReadId}` returns 204.

**`GET /conversations?as=CUSTOMER|PRO`** returns `{items: [{jobId, publicCode, title, counterpart, lastMessage, unreadCount, jobStatus}]}`.
- `lastMessage` is a `Message` or null.
- Items are sorted by last activity, newest first.

#### Pro earnings

**`GET /pro/earnings`** returns `{releasedTotal, pendingTotal, serviceFeeTotal, items}`.
- `pendingTotal` is the net of LOCKED and DISPUTED escrow.
- `items` is `[{jobId, publicCode, title, totalAmount, serviceFee, netEarning, status, date}]`, where `status` is `PENDING`, `RELEASED`, `REFUNDED` or `SPLIT`.

#### Seed (dev only, per `docs/spec/SEED_DATA.md`)

| Request | Customer / pro | State |
|---|---|---|
| BD-88409 | Ali / Mavi Hat | Job SCHEDULED tomorrow 10:00-12:00. SEED escrow LOCKED for ₺1.200 (labor 900, materials 300). 4 messages. |
| BD-88407 | Ali / Kaya | Job COMPLETED. SEED escrow RELEASED for ₺1.400. 5-star review with tags ON_TIME and CLEAN_WORK. |
| BD-88398 | Zeynep / Usta Eller | Job DISPUTED, ₺2.200. Complaint SK-1001: EXTRA_CHARGE, OPEN. 6 messages. |

`POST /api/v1/dev/reset` reloads all of these.

#### Carry-overs from earlier audits

**Backend:**
- Upload quota: 60 uploads per user per 24 h, then 429 `TOO_MANY_ATTEMPTS`.
- PDFs are served with `Content-Disposition: attachment`.
- Optimistic-lock conflicts map to 409 `ILLEGAL_STATE` globally.
- Pros with a PENDING offer are notified with `REQUEST_UPDATED` when the request is edited.

**Flutter:**
- Refetch data when returning to a tab (NAVIGATION_RULES §4).
- Fix the always-passing test at `apps/mobile/test/pro_wave2_test.dart:388`.

#### Not in this wave

The admin panel and its decisions, notification endpoints, push notifications, and the promo site.

#### Uygulama notları (backend, wave 3)

- Şema: `V5__wave3_payment_jobs_chat.sql`. Kilit sırası iş, emanet, talep; iş durumu yalnızca `JobStateMachine` ile değişir ve `allowedActions` aynı tablodan üretilir.
- Yanlış rolün çağırdığı usta/müşteri uç noktası 403 `FORBIDDEN`; kendi önerisini kabul etmek 409 `ILLEGAL_STATE`.
- Sözleşmede tür adı verilmeyen bildirimler: `APPOINTMENT_PROPOSED`, `APPOINTMENT_ACCEPTED`, `JOB_STAGE_UPDATED` (varış, başlangıç, not, fotoğraf).
- `GET /jobs` ve `GET /conversations` `limit` verilmezse tüm listeyi döner (`nextCursor` null).
- Usta iptalinde yeniden açılan talebin `expiresAt` değeri en az 7 gün sonrasına çekilir.
- Banka dönüşünde otomatik iade yapılamazsa kayıt `LOCKED` + `resultUncertain` + hata koduyla kalır; zamanlayıcı (5 dk) iadeyi yeniden dener. 30 dakikadan eski `INITIALIZED` kayıtlar Craftgate'e sorularak kapatılır.
- Prototip uç noktaları `bitadilat.prototype-api.enabled=true` ayarına bağlıdır; yalnızca `application-dev.properties` açar, `prod`'da 404.
- `GET /requests?scope=active`: `ASSIGNED` talep, işi `COMPLETED`/`RESOLVED` olana kadar etkindir.
- `rating_avg`/`rating_count` `reviews` satırlarından yeniden hesaplanır.



## Ayrıntılı sözleşme (wave 4)

### Wave 4 contract: admin panel and notification centre

Binding for backend, the admin web app and the mobile app. The contracts from waves 1-3 still apply. Field names, enum values and status codes below are exact. General rules:

- Base path is `/api/v1`. JSON keys are camelCase.
- Errors use `{code, message, field?}`.
- Lists use `{items, nextCursor}` unless a list below says `{items}` only.
- Money is TRY with 2 decimals.
- State rules come from `docs/spec/STATE_MACHINES.md` (§1 accounts and pros, §5 complaints, §6 escrow).

#### Admin

Every `/admin/**` endpoint requires `isAdmin = true`. Anyone else gets 403 `FORBIDDEN`. Each state-changing admin call writes an `admin_actions` row (admin, action, target type, target id, note, time) in the same transaction. Admins can open `PRO_DOCUMENT` and `COMPLAINT` media through `MediaRef` signed URLs.

##### Stats

`GET /admin/stats` returns `{pendingApplications, openComplaints, activeJobs, lockedEscrowTotal}`.

##### Pro applications

`GET /admin/applications?status=&q=` returns `{items: [AdminApplicationSummary]}`.
- `status` is one of `PENDING_REVIEW`, `NEEDS_DOCUMENTS`, `REJECTED`, `APPROVED`, `SUSPENDED`. The default is `PENDING_REVIEW`.
- `q` searches the name, business name, email and phone.
- `AdminApplicationSummary` = `{proId, fullName, businessName, categoryIds, districtNames, submittedAt, reviewStatus, documentCount}`.
- Items are ordered oldest first, so the earliest submitted application is reviewed first.

`GET /admin/applications/{proId}` returns `AdminApplicationDetail`:
- every summary field, plus
- `email`, `phone`, `bio`, `experienceYears`, `reviewNote`
- `documents`: `[{id, type, status, media}]`, where `media` is a `MediaRef`
- `history`: `[AdminAction {id, action, note, adminName, createdAt}]`

Review actions:

| Endpoint | Body | Allowed from | Result | Notifies the pro with |
|---|---|---|---|---|
| `POST /admin/applications/{proId}/approve` | `{note?}` | `PENDING_REVIEW` | `APPROVED`; every document `ACCEPTED`; `approved_at` set | `PRO_APPROVED` |
| `POST /admin/applications/{proId}/reject` | `{note (10-1000)}` | `PENDING_REVIEW` | `REJECTED`; `review_note` set | `PRO_REJECTED` |
| `POST /admin/applications/{proId}/request-documents` | `{note (10-1000), documentTypes (≥1)}` | `PENDING_REVIEW` | `NEEDS_DOCUMENTS`; the listed document types become `REJECTED` | `PRO_NEEDS_DOCUMENTS` |

- Each action returns `AdminApplicationDetail`.
- Any other starting state returns 409 `ILLEGAL_STATE`.

##### Complaints

`GET /admin/complaints?status=` returns `{items}`.
- `status` is `OPEN`, `IN_REVIEW`, `RESOLVED` or `DISMISSED`. The default is "OPEN and IN_REVIEW".
- Each item is `{id, publicCode, jobId, jobPublicCode, reason, status, customerName, proBusinessName, amount, createdAt}`.
- Items are ordered oldest first.

`GET /admin/complaints/{id}` returns `AdminComplaintDetail`:
- every `Complaint` field (wave 3), plus
- `warnPro`, `suspendPro`
- `job`: `{id, publicCode, title, status, statusBeforeDispute, timeline [JobEvent], offer OfferDetail, districtName}`
- `payment`: `{ref, status, provider, totalAmount, commission, proPayout, refundedAmount}`
- `messages`: `[{id, senderRole, body, photo, createdAt}]`, the whole job chat
- `customer`: `{id, fullName}`
- `pro`: `{id, businessName, fullName, warningCount, cancellationCount}`

`POST /admin/complaints/{id}/review` moves `OPEN` to `IN_REVIEW` and returns the detail.

`POST /admin/complaints/{id}/decision` decides an `OPEN` or `IN_REVIEW` complaint.
- Body: `{decision, note (10-2000), warnPro (bool), suspendPro (bool)}`.
- `decision` is one of:

| `decision` | Escrow | Job | Complaint | Fee |
|---|---|---|---|---|
| `FULL_REFUND` | `REFUNDED_TO_CUSTOMER`; full refund through the gateway | `CANCELLED`; request `CANCELLED` | `RESOLVED` | none |
| `SPLIT_50_50` | `SPLIT_SETTLED`; 50% refund through the gateway, 50% to the pro | `RESOLVED` | `RESOLVED` | none |
| `RELEASE_TO_PRO` | `RELEASED_TO_PRO`; 10% fee kept | `COMPLETED` | `DISMISSED` | 10% |

- `payout_ledger` rows are written for every outcome.
- `warnPro` adds 1 to `warning_count`.
- `suspendPro` sets the pro profile to `SUSPENDED` and withdraws their PENDING offers. The user account itself is not suspended.
- The decision fields are recorded on the complaint.
- Both sides are notified with `COMPLAINT_DECIDED`.
- If the gateway fails: 502 `GATEWAY_ERROR`, and nothing changes.
- A `provider=SEED` payment is ledger-only, and only in `dev`.
- Returns the detail.

##### Accounts

`GET /admin/users?q=&role=&status=` returns `{items}`.
- `role` is `CUSTOMER`, `PRO` or `ADMIN`.
- `status` is `ACTIVE`, `SUSPENDED` or `DELETED`.
- Each item is `{id, fullName, email, phone, isAdmin, status, createdAt, pro}`, where `pro` is `{businessName, reviewStatus}` or null.

`POST /admin/users/{id}/suspend` with `{note (10-1000)}`:
- sets the user to `SUSPENDED`;
- calls `revokeAllForUser`, which ends every session;
- withdraws their PENDING offers;
- leaves active jobs untouched; they are listed in the response warning field `activeJobCount`.
- An admin can't suspend themself or another admin: 409 `ILLEGAL_STATE`.

`POST /admin/users/{id}/reactivate` sets `SUSPENDED` back to `ACTIVE`. (Lead decision, wave 4 audit: if the user's pro profile is `SUSPENDED` by an admin, the same call also sets it back to `APPROVED` in the same transaction, with its own `REACTIVATE_PRO` admin action; it also works when only the profile is suspended. Neither suspended: 409 `ILLEGAL_STATE`.)

##### Payments ledger

`GET /admin/payments?status=` returns `{items, totals}`.
- Each item is `{ref, jobPublicCode, status, provider, totalAmount, commission, proPayout, refundedAmount, customerName, proBusinessName, createdAt, lockedAt, releasedAt, refundedAt, errorCode}`.
- `totals` is `{lockedTotal, releasedTotal, commissionTotal, refundedTotal}`.

#### Complaint amounts (leader addendum)

`Complaint` (`GET /complaints/{id}` and the admin detail) gains two nullable fields: `refundAmount` (refunded to the customer) and `proAmount` (net amount transferred to the pro). Both are null before a decision. `FULL_REFUND` → refund = total, pro = 0; `SPLIT_50_50` → refund = half (HALF_UP), pro = the rest, no fee; `RELEASE_TO_PRO` → refund = 0, pro = total − 10%. Values are read from the escrow row (`refunded_amount`, `pro_payout`).

#### Notifications

`Notification` = `{id, type, params, targetRoute, read, createdAt}`.
- `params` is a flat JSON object of strings and numbers that the client needs to build the text, such as `publicCode`, `title`, `amount`, `proBusinessName`, `customerName` and `slotFrom`.
- `targetRoute` is an in-app route such as `/c/jobs/<id>`, `/p/jobs/<id>`, `/c/requests/<id>/offers`, `/p/requests/<id>`, `/p/application`, `/c/complaints/<id>` or `/jobs/<id>/chat`, or it is null.
- The client builds the TR or EN text from `type` and `params`.

Endpoints:
- `GET /notifications?cursor=&limit=` returns `{items: [Notification], nextCursor, unreadCount}`, newest first.
- `POST /notifications/read` takes `{ids?: [..]}`. Without `ids` it marks everything read. Returns 204.
- `GET /me` gains `unreadNotifications` (int).
- `PUT /devices` takes `{platform ("IOS"|"ANDROID"|"WEB"), token}` and returns 204. The token is only stored; push is not sent yet.

Types, with the params each one must carry:

| Type | Params | Target |
|---|---|---|
| `NEW_MATCHING_REQUEST` | `publicCode`, `title`, `districtName` | `/p/requests/<id>` |
| `OFFER_RECEIVED` | `publicCode`, `title`, `proBusinessName`, `amount` | `/c/requests/<id>/offers` |
| `OFFER_DECLINED` | `publicCode`, `title` | `/p/offers` |
| `OFFER_SUPERSEDED` | `publicCode`, `title` | `/p/offers` |
| `OFFER_ACCEPTED` | `publicCode`, `title`, `amount` | `/p/jobs/<id>` |
| `REQUEST_UPDATED` | `publicCode`, `title` | `/p/requests/<id>` |
| `APPOINTMENT_PROPOSED` | `publicCode`, `slotFrom`, `slotTo` | job route for that side |
| `APPOINTMENT_CONFIRMED` | `publicCode`, `slotFrom`, `slotTo` | job route for that side |
| `JOB_STAGE_CHANGED` | `publicCode`, `status` | `/c/jobs/<id>` |
| `WORK_FINISHED` | `publicCode`, `autoCompleteAt` | `/c/jobs/<id>` |
| `AUTO_COMPLETE_REMINDER` | `publicCode`, `autoCompleteAt` | `/c/jobs/<id>` |
| `PAYOUT_RELEASED` | `publicCode`, `amount` | `/p/earnings` |
| `JOB_CANCELLED` | `publicCode`, `byRole`, `refundAmount` | job route for that side |
| `NEW_MESSAGE` | `publicCode`, `senderName` | `/jobs/<id>/chat` |
| `COMPLAINT_OPENED` | `publicCode`, `complaintCode` | `/p/jobs/<id>` for the pro; the admin web for admins |
| `COMPLAINT_DECIDED` | `complaintCode`, `decision`, `amount` (sıfırsa yok) | `/c/complaints/<id>` or `/p/jobs/<id>` |
| `PRO_APPROVED` | none | `/p/feed` |
| `PRO_REJECTED` | `note` | `/p/application` |
| `PRO_NEEDS_DOCUMENTS` | `note` | `/p/application` |

Existing notify calls get the missing params and targets. `APPOINTMENT_PROPOSED`, `APPOINTMENT_CONFIRMED` and `JOB_STAGE_CHANGED` are emitted where they were not emitted before.

#### Seed (dev)

- Hasan's application stays `PENDING_REVIEW`.
- Selim stays `NEEDS_DOCUMENTS` with a note.
- SK-1001 stays `OPEN`.
- Each seeded account gets a few notifications of the new types, with correct params and targets (Hasan, whose application is still pending, has none).
- The admin account is `admin@bitadilat.test` with password `Demo1234!`.

#### Uygulama notları (backend, wave 4)

- Kod: `com.bitadilat.admin` (denetleyici + dört servis + `AdminAudit`), `com.bitadilat.notification` (`NotificationController`, `NotificationQueryService`). Şema değişikliği yok (`admin_actions`, `notifications`, `device_tokens` V2'de vardı). Güvenlik zinciri `/api/v1/admin/**` için `ROLE_ADMIN` ister; denetleyici `isAdmin` bayrağını ayrıca kontrol eder.
- `admin_actions.action` değerleri: `APPROVE_APPLICATION`, `REJECT_APPLICATION`, `REQUEST_DOCUMENTS`, `REVIEW_COMPLAINT`, `DECIDE_COMPLAINT`, `WARN_PRO`, `SUSPEND_PRO`, `SUSPEND_USER`, `REACTIVATE_USER`, `REACTIVATE_PRO`. Hedef türleri `PRO_PROFILE`, `COMPLAINT`, `USER`; `AdminApplicationDetail.history` bir ustanın tüm `PRO_PROFILE` eylemlerini (şikayetten gelen `WARN_PRO`/`SUSPEND_PRO` dahil) yeniden eskiye listeler.
- Başvuru kararında profil satırı `FOR UPDATE` ile kilitlenir. `request-documents`: başvuruda olmayan bir belge türü 400 `VALIDATION_FAILED` (`documentTypes`); listede olmayan belgelere dokunulmaz.
- Şikayet kararında kilit sırası iş, şikayet satırı, emanet, talep. Craftgate çağrısı tüm veritabanı yazımlarından sonra, işlem kesinleşmeden hemen önce yapılır: gateway hatası (502 `GATEWAY_ERROR`) bildirim, denetim satırı, uyarı/askı dahil her şeyi geri alır. Eşzamanlı iki karardan biri 200, diğeri 409 alır. Yanıttaki ayrıntı, karar işlemi kesinleştikten sonra ayrı bir okuma işleminde kurulur (para hareketinden sonraki bir okuma hatası kararı geri almaz). `SPLIT_50_50` kısmi iadeyi göndermeden önce Craftgate'teki başarılı iade toplamını sorar: tam yarı zaten iade edilmişse (önceki deneme 502 almış ama para gitmiş) iade yeniden gönderilmez, yalnızca defter işlenir; başka bir tutar görünürse 409 `ILLEGAL_STATE` (elle inceleme); sonuç bekleyen iade varsa 502.
- Tutarlar: `FULL_REFUND` müşteriye toplamın tamamı (`REFUND` defter satırı); `SPLIT_50_50` müşteriye `round(total/2, HALF_UP)` (`REFUND`), kalan usta payı (`PAYOUT`), komisyon yok; `RELEASE_TO_PRO` `PAYOUT` (%90) ve `COMMISSION` (%10), ustanın `completed_jobs` sayacı bir artar. `COMPLAINT_DECIDED.amount` alıcıya göredir: müşteride iade edilen, ustada aktarılan tutar; tutar sıfırsa (müşteride `RELEASE_TO_PRO`, ustada `FULL_REFUND`) `amount` gönderilmez. `FULL_REFUND`, Craftgate'te kısmen iade edilmiş (ör. panelden elle) bir ödemede yalnızca kalanı (toplam − iade edilmiş) iade eder; müşteri toplamı tam bir kez almış olur, `refundAmount` = toplam, defterde tek `REFUND` satırı toplamla yazılır. Craftgate'te sonuç bekleyen iade veya okunamayan iade durumu 502 verir, hiçbir şey değişmez. Karar bildirimi admin'e gitmez. `warnPro`/`suspendPro` verilmezse `false` sayılır; `suspendPro` ustanın profilini `SUSPENDED` yapar ve `review_note`'u karar notuyla yazar.
- `SEED` emaneti dev dışında iade edilemez (409 `ILLEGAL_STATE`, hiçbir şey değişmez); dev'de iade yalnızca defterde işlenir.
- Hesap listesi: `role=PRO` usta profili olanlar, `ADMIN` admin bayrağı olanlar, `CUSTOMER` ikisi de olmayanlar; en yeni önce, en çok 500 satır. Ödeme defteri de en yeni önce en çok 500 satırdır; `totals` süzgece uyan tüm satırlardan hesaplanır: `lockedTotal` LOCKED/DISPUTED tutarı, `releasedTotal` ustalara yazılan pay (RELEASED_TO_PRO ve SPLIT_SETTLED), `commissionTotal` RELEASED_TO_PRO komisyonu, `refundedTotal` müşteriye iade edilen. Bu değerler `payout_ledger` ile birebir tutar.
- `stats.activeJobs` COMPLETED, CANCELLED ve RESOLVED dışındaki işlerdir (DISPUTED dahil); `lockedEscrowTotal` LOCKED + DISPUTED emanet toplamıdır.
- Bildirimler: tür adları yukarıdaki sözleşme tablosundadır (`APPOINTMENT_CONFIRMED`, `JOB_STAGE_CHANGED`; wave 3'teki geçici `APPOINTMENT_ACCEPTED` / `JOB_STAGE_UPDATED` adları kalktı; mobil istemci de sözleşme adlarını kullanır). `JOB_STAGE_CHANGED` wave 3'teki gibi varışta, başlangıçta ve ustanın notu/fotoğrafında müşteriye gider; `status` işin o anki durumudur (`ARRIVED` / `IN_PROGRESS`), ek `event` anahtarı `STATUS_CHANGED`, `NOTE` veya `PHOTO` olur (sözleşmede not/fotoğraf için ayrı tür yok). Sözleşmedeki parametrelere ek olarak kimlik anahtarları (`jobId`, `requestId`, `offerId`, `complaintId`) taşınır; para tutarları iki ondalıklı dizedir (`"1200.00"`). `NEW_MESSAGE.senderName` ustada işletme adı, müşteride kısa addır ("Ali Y."). Admin'e giden `COMPLAINT_OPENED` hedefi `/complaints/<id>`'dir.
- `GET /notifications` imleci sıra numarasıdır (opak dize), varsayılan `limit` 20, en çok 50. `POST /notifications/read` başkasının kimliklerini sessizce yok sayar, boş `ids` listesi hiçbir şeyi değiştirmez, 500'den fazla kimlik 400 `VALIDATION_FAILED` (`ids`), gövdesiz çağrı ve `{}` hepsini okundu yapar. `PUT /devices` token'a göre upsert eder; token başka kullanıcıdaysa yeni sahibine taşınır.
