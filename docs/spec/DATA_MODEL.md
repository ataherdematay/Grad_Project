# Veri Modeli (PostgreSQL 16)

Flyway migration'larına bu belgeden geçilir. RAD'daki 10 sınıf (RAD:204) ve API taslağındaki tablolar (API:29-171) burada birleştirildi; eksik kalan randevu, şikayet, fotoğraf, ilçe ve müsaitlik tabloları eklendi.

**Genel kurallar**

- Birincil anahtar `uuid` (`gen_random_uuid()`). Kullanıcıya gösterilen numaralar ayrı sütunda (`public_code`).
- Zaman `timestamptz`, UTC. Para `numeric(12,2)`, TRY.
- Durumlar `varchar` + `CHECK` (Java `enum` ile aynı adlar). Postgres `ENUM` tipi kullanılmaz, çünkü değer eklemek migration'da zahmetli.
- Her değişen tabloda `created_at`, `updated_at`; eşzamanlı güncellenen tablolarda `version bigint` (`@Version`).
- Silme yok, durum var. Hesap silmede kişisel alanlar anonimleştirilir.

## Kimlik ve hesap

| Tablo | Sütunlar | Kısıtlar |
|---|---|---|
| `users` | id, full_name, email, phone, password_hash, locale (`tr`/`en`), status, last_mode (`CUSTOMER`/`PRO`), is_admin, kvkk_accepted_at, terms_accepted_at, deleted_at | `lower(email)` benzersiz; `phone` E.164 benzersiz |
| `refresh_tokens` | id, user_id, token_hash, family_id, expires_at, revoked_at, replaced_by, user_agent | Yeniden kullanılan token tüm aileyi iptal eder |
| `password_reset_codes` | id, user_id, code_hash, expires_at (15 dk), attempts, used_at | 5 hatalı denemede geçersiz |
| `login_attempts` | id, identifier_hash, ip, success, created_at | Kısa süreli sınırlama için |
| `addresses` | id, user_id, label, district_id, neighborhood, line_full_encrypted, door_note_encrypted, is_default | Tam adres uygulama katmanında AES-GCM ile şifreli |

## Katalog

| Tablo | Sütunlar |
|---|---|
| `categories` | id (`plumbing` …), name_tr, name_en, icon, color_hex, sort_order, is_active |
| `districts` | id, name, city (`İstanbul`), side (`ANADOLU`/`AVRUPA`), is_active. İstanbul'un 39 ilçesi |

## Usta

| Tablo | Sütunlar | Kısıtlar |
|---|---|---|
| `pro_profiles` | user_id (PK), business_name, bio, experience_years, review_status, review_note, availability, rating_avg, rating_count, completed_jobs, cancellation_count, warning_count, approved_at, version | |
| `pro_categories` | pro_id, category_id | PK ikisi |
| `pro_districts` | pro_id, district_id | PK ikisi |
| `pro_working_hours` | pro_id, weekday (1-7), start_time, end_time, accepts_urgent | |
| `pro_documents` | id, pro_id, type (`IDENTITY`, `TRADE_CERT`, `TAX`, `CRIMINAL_RECORD`), media_id, status (`PENDING`/`ACCEPTED`/`REJECTED`), reviewed_by, reviewed_at | |

## Talep, teklif, iş

| Tablo | Sütunlar | Kısıtlar |
|---|---|---|
| `service_requests` | id, public_code (`BD-#####`), customer_id, category_id, urgency (`URGENT`/`PLANNED`), preferred_from, preferred_to, title, description (≥20), district_id, neighborhood, address_id, status, matched_pro_count, expires_at, version | `public_code` benzersiz |
| `request_photos` | request_id, media_id, sort_order | en fazla 5 |
| `request_answers` | request_id, question_key, answer | Sihirbazdaki "Ne zamandır var?" gibi kategori soruları |
| `offers` | id, public_code, request_id, pro_id, labor_amount, materials_amount, total_amount, arrival_from, arrival_to, warranty_months (0/3/6/12), note, status, valid_until, decline_reason, version | Kısmi benzersiz: `(request_id, pro_id) WHERE status='PENDING'`; `total = labor + materials`; tutarlar > 0 |
| `offer_items` | id, offer_id, kind (`LABOR`/`MATERIAL`), description, quantity, unit_price | Malzeme kalemleri (P37) |
| `jobs` | id, request_id (benzersiz değil: usta iptalinden sonra yeni iş açılabilir), offer_id (benzersiz), customer_id, pro_id, status, status_before_dispute, scheduled_from, scheduled_to, arrived_at, started_at, finished_at, completed_at, cancelled_at, cancelled_by, cancel_reason, auto_complete_at, version | Kısmi benzersiz: talep başına bir aktif iş |
| `appointment_proposals` | id, job_id, proposed_by (`CUSTOMER`/`PRO`), slot_from, slot_to, status (`PENDING`/`ACCEPTED`/`SUPERSEDED`/`REJECTED`) | İş başına bir `PENDING` |
| `job_events` | id, job_id, actor_id, type (`STATUS_CHANGED`, `NOTE`, `PHOTO`), from_status, to_status, note, media_id, created_at | Aşama zaman çizelgesi ve denetim izi |

## Ödeme

`escrow_payments`: mevcut `EscrowPayment` alanları (`ref`, `offer_id`, `job_ref`, `attempt_key`, `conversation_id`, `craftgate_payment_id`, `total_amount`, `commission`, `pro_payout`, `refunded_amount`, `status`, `card_last4`, `error_message`, `result_uncertain`, `created_at`, `locked_at`, `released_at`, `refunded_at`, `version`) ve ekler:

- `request_id`, `customer_id`, `pro_id`, `job_id`
- `channel` (`APP`/`PROTOTYPE`), `provider` (`CRAFTGATE`/`SEED`), `error_code`
- Kısmi benzersiz: `request_id WHERE status='INITIALIZED'`

`payout_ledger`: id, payment_ref, pro_id, amount, kind (`PAYOUT`/`COMMISSION`/`REFUND`), created_at. Kazançlar ekranı ve admin defteri buradan okur.

## İletişim ve değerlendirme

| Tablo | Sütunlar | Kısıtlar |
|---|---|---|
| `messages` | id (bigserial, imleç olarak), job_id, sender_id, body (≤2000), media_id, created_at | `(job_id, id)` indeksi |
| `message_reads` | job_id, user_id, last_read_id | Okunmamış sayısı |
| `reviews` | id, job_id, customer_id, pro_id, rating (1-5), tags (text[]), comment, is_anonymous, created_at | `job_id` benzersiz |
| `complaints` | id, public_code (`SK-####`), job_id, customer_id, pro_id, reason, description, status, decision (`FULL_REFUND`/`SPLIT_50_50`/`RELEASE_TO_PRO`), decision_note, decided_by, decided_at, warn_pro, suspend_pro | Açık şikayet iş başına bir |
| `complaint_evidence` | complaint_id, media_id | en fazla 5 |
| `notifications` | id, user_id, type, title_key, body_key, params (jsonb), target_route, read_at, created_at | Metin istemcide çevrilir |
| `device_tokens` | id, user_id, platform, token, updated_at | Aşama 7 |
| `admin_actions` | id, admin_id, action, target_type, target_id, note, created_at | Admin denetim izi |

## Medya

`media`: id, owner_id, purpose (`REQUEST_PHOTO`, `JOB_PHOTO`, `CHAT`, `COMPLAINT`, `PRO_DOCUMENT`, `AVATAR`), storage_key, content_type, size_bytes (≤1,5 MB; belge ≤5 MB), width, height, sha256, created_at.

- Dosya erişimi `GET /api/v1/media/{id}` üzerinden, kısa ömürlü imzalı adresle. İmza verilmeden önce erişim kuralı (`ROLE_SCREEN_MAP.md` son tablo) kontrol edilir.
- Geliştirmede `backend/data/media/`, yayında S3 uyumlu depolama. `.gitignore` zaten `backend/data/` içeriyor.
- Kabul edilen türler: JPEG, PNG, HEIC (sunucuda JPEG'e çevrilir), belge için PDF.

## Eşzamanlılık

- Teklif kabulü ve ödeme dönüşü: `service_requests` satırı `SELECT … FOR UPDATE` ile kilitlenir.
- İş durum geçişleri: `jobs` satırı kilitlenir, geçiş `JobStateMachine` sınıfında tek yerden yapılır.
- 48 saat zamanlayıcısı: `FOR UPDATE SKIP LOCKED` ile toplu işler.
