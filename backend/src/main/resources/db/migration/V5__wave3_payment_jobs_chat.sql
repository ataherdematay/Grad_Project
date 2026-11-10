-- Wave 3: uygulama kanalı ödemesi, iş durum makinesi, sohbet, değerlendirme, şikayet ve kazançlar.

-- ─── Emanet (escrow_payment) ────────────────────────────────────────────────

ALTER TABLE escrow_payment
    ADD COLUMN request_id  uuid REFERENCES service_requests (id),
    ADD COLUMN customer_id uuid REFERENCES users (id),
    ADD COLUMN pro_id      uuid REFERENCES users (id),
    ADD COLUMN job_id      uuid REFERENCES jobs (id),
    ADD COLUMN channel     varchar(10) NOT NULL DEFAULT 'PROTOTYPE' CHECK (channel IN ('APP', 'PROTOTYPE')),
    ADD COLUMN provider    varchar(10) NOT NULL DEFAULT 'CRAFTGATE' CHECK (provider IN ('CRAFTGATE', 'SEED')),
    ADD COLUMN error_code  varchar(32);

-- Talep başına aynı anda tek INITIALIZED ödeme (ikinci deneme 409 PAYMENT_IN_PROGRESS).
CREATE UNIQUE INDEX ux_escrow_one_initialized_per_request ON escrow_payment (request_id) WHERE status = 'INITIALIZED';
-- Bir işin tek emaneti vardır.
CREATE UNIQUE INDEX ux_escrow_job ON escrow_payment (job_id) WHERE job_id IS NOT NULL;
CREATE INDEX ix_escrow_pro ON escrow_payment (pro_id, status);
CREATE INDEX ix_escrow_customer ON escrow_payment (customer_id);
CREATE INDEX ix_escrow_request ON escrow_payment (request_id);
-- Zamanlayıcı: eski INITIALIZED kayıtları ve iadesi yapılamamış öksüz LOCKED kayıtlar.
CREATE INDEX ix_escrow_initialized_created ON escrow_payment (created_at) WHERE status = 'INITIALIZED';

-- ─── İş ─────────────────────────────────────────────────────────────────────

ALTER TABLE jobs
    ADD COLUMN cancel_note              varchar(500),
    ADD COLUMN auto_complete_reminded_at timestamptz;

CREATE INDEX ix_jobs_request ON jobs (request_id);
-- 24. saat hatırlatması taraması.
CREATE INDEX ix_jobs_reminder ON jobs (auto_complete_at) WHERE status = 'WORK_FINISHED' AND auto_complete_reminded_at IS NULL;

-- Zaman çizelgesi: randevu olayları, eylemi yapanın rolü ve aynı anda yazılan olaylar için kararlı sıra.
ALTER TABLE job_events DROP CONSTRAINT job_events_type_check;
ALTER TABLE job_events ADD CONSTRAINT job_events_type_check
    CHECK (type IN ('STATUS_CHANGED', 'NOTE', 'PHOTO', 'APPOINTMENT_PROPOSED', 'APPOINTMENT_ACCEPTED'));
ALTER TABLE job_events
    ADD COLUMN actor_role varchar(10) NOT NULL DEFAULT 'SYSTEM' CHECK (actor_role IN ('CUSTOMER', 'PRO', 'SYSTEM', 'ADMIN')),
    ADD COLUMN seq        bigserial;
CREATE INDEX ix_job_events_seq ON job_events (job_id, seq);

-- Bir medya en fazla bir kayda bağlanır (V4 ile aynı ilke).
CREATE UNIQUE INDEX ux_job_events_media ON job_events (media_id) WHERE media_id IS NOT NULL;
CREATE UNIQUE INDEX ux_messages_media ON messages (media_id) WHERE media_id IS NOT NULL;
CREATE UNIQUE INDEX ux_complaint_evidence_media ON complaint_evidence (media_id);

CREATE INDEX ix_appointment_job ON appointment_proposals (job_id, created_at);

-- ─── Şikayet ────────────────────────────────────────────────────────────────

ALTER TABLE complaints ADD CONSTRAINT complaints_reason_check
    CHECK (reason IN ('NO_SHOW', 'INCOMPLETE_WORK', 'EXTRA_CHARGE', 'RUDE_BEHAVIOUR', 'OTHER'));
CREATE INDEX ix_complaints_job ON complaints (job_id);
CREATE INDEX ix_complaints_pro ON complaints (pro_id);
-- SK-1001 seed'dir; sonraki şikayetler 1002'den devam eder.
CREATE SEQUENCE complaint_code_seq START WITH 1002;

-- ─── Sohbet ve bildirim ─────────────────────────────────────────────────────

-- Mesaj okunmamış sayısı: gönderen ve imleç filtresi.
CREATE INDEX ix_messages_job_sender ON messages (job_id, sender_id, id);
-- NEW_MESSAGE tekilleştirmesi ve okundu işaretleme.
CREATE INDEX ix_notifications_unread_type ON notifications (user_id, type) WHERE read_at IS NULL;

-- ─── Değerlendirme ──────────────────────────────────────────────────────────

-- Etiket kümesi (ON_TIME, CLEAN_WORK, FAIR_PRICE, GOOD_COMMUNICATION, POLITE) uygulama katmanında doğrulanır.

-- Yükleme kotası yükleme kotası sorgusu (sahip + zaman).
CREATE INDEX ix_media_owner_created ON media (owner_id, created_at);
