-- =====================================================================
-- BiTadilat database for Supabase (free plan). Run order:
--   01_schema.sql -> 02_functions.sql -> 03_security.sql -> 04_storage.sql -> 05_seed_categories.sql
-- Login: Supabase Auth (Google or email + password). Users live in auth.users;
-- public.users holds the profile. Texts shown to users are stored as codes/keys
-- (TR/EN is decided by the app), categories have name_tr and name_en.
-- =====================================================================
BEGIN;

-- ---------- Enums ----------
CREATE TYPE user_role           AS ENUM ('CUSTOMER', 'PRO', 'ADMIN');
CREATE TYPE account_status      AS ENUM ('ACTIVE', 'UNDER_REVIEW', 'SUSPENDED');
CREATE TYPE verification_status AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');
CREATE TYPE document_type       AS ENUM ('TAX_CERTIFICATE', 'MASTER_CERTIFICATE', 'CRIMINAL_RECORD', 'ID_DOCUMENT');
CREATE TYPE urgency_level       AS ENUM ('EMERGENCY_TODAY', 'THIS_WEEK', 'FLEXIBLE');
CREATE TYPE job_status          AS ENUM (
    'DRAFT', 'PENDING_OFFERS', 'ESCROW_PENDING', 'SCHEDULED',
    'PRO_EN_ROUTE', 'IN_PROGRESS', 'COMPLETED', 'RELEASED', 'DISPUTED', 'CANCELLED');
CREATE TYPE offer_status        AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED', 'WITHDRAWN');
CREATE TYPE offer_item_kind     AS ENUM ('LABOR', 'MATERIAL');
CREATE TYPE appointment_status  AS ENUM ('REQUESTED', 'CONFIRMED', 'RESCHEDULE_REQUESTED', 'CANCELLED', 'DONE');
CREATE TYPE payment_status      AS ENUM ('INITIALIZED', 'FAILED', 'LOCKED', 'RELEASED_TO_PRO', 'REFUNDED_TO_CUSTOMER', 'PARTIALLY_REFUNDED', 'DISPUTED');
CREATE TYPE dispute_type        AS ENUM ('NO_SHOW', 'WORK_MISMATCH', 'EXTRA_FEE', 'BEHAVIOR', 'OTHER');
CREATE TYPE dispute_status      AS ENUM ('OPEN', 'UNDER_REVIEW', 'RESOLVED', 'REJECTED');
CREATE TYPE dispute_decision    AS ENUM ('FULL_REFUND', 'SPLIT_50_50', 'PAY_PROFESSIONAL', 'REJECT_COMPLAINT');
CREATE TYPE notification_type   AS ENUM ('NEW_OFFER', 'OFFER_ACCEPTED', 'OFFER_REJECTED', 'PAYMENT_LOCKED', 'PAYMENT_FAILED',
                                         'APPOINTMENT_CONFIRMED', 'APPOINTMENT_CANCELLED', 'JOB_COMPLETED', 'DISPUTE_UPDATE', 'SYSTEM');

-- ---------- Users (login itself is handled by Supabase Auth) ----------
CREATE TABLE users (
    id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,   -- same id as the login account
    phone_number  VARCHAR(15) UNIQUE CHECK (phone_number IS NULL OR phone_number ~ '^\+90[0-9]{10}$'),  -- optional contact number
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    role          user_role NOT NULL DEFAULT 'CUSTOMER',
    status        account_status NOT NULL DEFAULT 'ACTIVE',
    preferred_lang CHAR(2) NOT NULL DEFAULT 'tr' CHECK (preferred_lang IN ('tr', 'en')),
    avatar_url    TEXT,
    kvkk_accepted_at TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE saved_addresses (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label         VARCHAR(40) NOT NULL DEFAULT 'Home',
    city          VARCHAR(50) NOT NULL DEFAULT 'İstanbul',
    district      VARCHAR(50) NOT NULL,
    neighborhood  VARCHAR(100) NOT NULL,
    address_full_encrypted TEXT NOT NULL
);

-- ---------- Categories, professionals ----------
CREATE TABLE service_categories (
    id            VARCHAR(50) PRIMARY KEY,           -- 'plumbing', 'electrical', ...
    name_tr       VARCHAR(100) NOT NULL,
    name_en       VARCHAR(100) NOT NULL,
    description_tr TEXT,
    description_en TEXT,
    icon_name     VARCHAR(50) NOT NULL,
    color_hex     VARCHAR(10) NOT NULL,
    base_inspection_fee NUMERIC(10,2) NOT NULL DEFAULT 250.00,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE pro_profiles (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(120),
    primary_category_id VARCHAR(50) NOT NULL REFERENCES service_categories(id),
    experience_years INT NOT NULL DEFAULT 1 CHECK (experience_years >= 0),
    bio           TEXT,
    verification  verification_status NOT NULL DEFAULT 'PENDING',
    identity_verified        BOOLEAN NOT NULL DEFAULT FALSE,
    tax_verified             BOOLEAN NOT NULL DEFAULT FALSE,
    criminal_record_verified BOOLEAN NOT NULL DEFAULT FALSE,
    iban_encrypted TEXT,
    rating_avg    NUMERIC(3,2) NOT NULL DEFAULT 0.00,
    total_reviews_count   INT NOT NULL DEFAULT 0,
    completed_jobs_count  INT NOT NULL DEFAULT 0,
    accepting_jobs BOOLEAN NOT NULL DEFAULT TRUE,
    emergency_calls BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE pro_categories (
    pro_id        UUID NOT NULL REFERENCES pro_profiles(id) ON DELETE CASCADE,
    category_id   VARCHAR(50) NOT NULL REFERENCES service_categories(id),
    PRIMARY KEY (pro_id, category_id)
);

CREATE TABLE pro_service_areas (
    pro_id        UUID NOT NULL REFERENCES pro_profiles(id) ON DELETE CASCADE,
    district      VARCHAR(50) NOT NULL,
    PRIMARY KEY (pro_id, district)
);

-- Documents reviewed by the admin (screens: professional registration, admin document review)
CREATE TABLE pro_documents (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pro_id        UUID NOT NULL REFERENCES pro_profiles(id) ON DELETE CASCADE,
    doc_type      document_type NOT NULL,
    file_url      TEXT NOT NULL,
    file_size_bytes INT NOT NULL CHECK (file_size_bytes <= 2621440),   -- 2.5 MB limit (RAD)
    status        verification_status NOT NULL DEFAULT 'PENDING',
    reviewed_by   UUID REFERENCES users(id),
    review_note   TEXT,
    uploaded_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at   TIMESTAMPTZ
);

-- Last known position of the professional (live navigation; kept only during an active job)
CREATE TABLE pro_locations (
    pro_id        UUID PRIMARY KEY REFERENCES pro_profiles(id) ON DELETE CASCADE,
    lat           NUMERIC(10,7) NOT NULL,
    lng           NUMERIC(10,7) NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------- Requests and offers ----------
CREATE TABLE job_requests (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id   UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    category_id   VARCHAR(50) NOT NULL REFERENCES service_categories(id),
    title         VARCHAR(150) NOT NULL,
    description   TEXT NOT NULL CHECK (char_length(description) >= 10),
    urgency       urgency_level NOT NULL DEFAULT 'THIS_WEEK',
    preferred_date DATE,
    preferred_date_label VARCHAR(60),       -- date as shown in the app (e.g. '25 Ekim Cuma')
    preferred_time_slot VARCHAR(50),
    city          VARCHAR(50) NOT NULL DEFAULT 'İstanbul',
    district      VARCHAR(50) NOT NULL,
    neighborhood  VARCHAR(100) NOT NULL,
    address_line_masked    TEXT,            -- visible to everyone
    address_full_encrypted TEXT,            -- revealed to the pro only after the appointment is confirmed
    geo_lat       NUMERIC(10,7),
    geo_lng       NUMERIC(10,7),
    status        job_status NOT NULL DEFAULT 'PENDING_OFFERS',
    selected_offer_id UUID,                 -- FK added below (circular reference)
    completion_pin VARCHAR(6),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_jobs_customer      ON job_requests (customer_id, created_at DESC);
CREATE INDEX idx_jobs_feed          ON job_requests (district, category_id, created_at DESC) WHERE status = 'PENDING_OFFERS';

CREATE TABLE job_photos (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL REFERENCES job_requests(id) ON DELETE CASCADE,
    file_url      TEXT NOT NULL,
    file_size_bytes INT NOT NULL CHECK (file_size_bytes <= 2621440),   -- 2.5 MB limit (RAD)
    position      SMALLINT NOT NULL DEFAULT 1 CHECK (position BETWEEN 1 AND 5)  -- max 5 photos
);
CREATE UNIQUE INDEX uq_job_photo_pos ON job_photos (job_id, position);

CREATE TABLE offers (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL REFERENCES job_requests(id) ON DELETE CASCADE,
    pro_id        UUID NOT NULL REFERENCES pro_profiles(id) ON DELETE CASCADE,
    labor_amount     NUMERIC(10,2) NOT NULL CHECK (labor_amount >= 0),
    materials_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (materials_amount >= 0),
    total_amount     NUMERIC(10,2) NOT NULL,
    warranty_months  INT NOT NULL DEFAULT 6 CHECK (warranty_months >= 0),
    estimated_arrival_minutes INT,
    available_from   TIMESTAMPTZ,
    note          TEXT,
    status        offer_status NOT NULL DEFAULT 'PENDING',
    rejection_reason VARCHAR(60),          -- reason chosen on the "reject offer" screen
    rejection_note   TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT offers_total_matches CHECK (total_amount = labor_amount + materials_amount),
    CONSTRAINT one_offer_per_pro_per_job UNIQUE (job_id, pro_id)
);
-- Core rule: a request can have at most ONE accepted offer
CREATE UNIQUE INDEX uq_one_accepted_offer_per_job ON offers (job_id) WHERE status = 'ACCEPTED';
CREATE INDEX idx_offers_job ON offers (job_id, status);
CREATE INDEX idx_offers_pro ON offers (pro_id, created_at DESC);

ALTER TABLE job_requests
    ADD CONSTRAINT fk_selected_offer FOREIGN KEY (selected_offer_id) REFERENCES offers(id) DEFERRABLE INITIALLY DEFERRED;

-- Itemized breakdown (screen: structured cost modal)
CREATE TABLE offer_items (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    offer_id      UUID NOT NULL REFERENCES offers(id) ON DELETE CASCADE,
    kind          offer_item_kind NOT NULL,
    description   VARCHAR(200) NOT NULL,
    quantity      NUMERIC(8,2) NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price    NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- ---------- Appointments ----------
CREATE TABLE appointments (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL REFERENCES job_requests(id) ON DELETE CASCADE,
    starts_at     TIMESTAMPTZ NOT NULL,
    ends_at       TIMESTAMPTZ NOT NULL,
    status        appointment_status NOT NULL DEFAULT 'REQUESTED',
    cancel_reason VARCHAR(80),
    cancel_note   TEXT,
    cancelled_by  UUID REFERENCES users(id),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);
CREATE UNIQUE INDEX uq_active_appointment ON appointments (job_id) WHERE status IN ('REQUESTED', 'CONFIRMED', 'RESCHEDULE_REQUESTED');

-- ---------- Payments (guarantee pool) ----------
-- Card data never stored here; only the provider's reference (e.g. iyzico).
CREATE TABLE payments (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL UNIQUE REFERENCES job_requests(id),
    offer_id      UUID NOT NULL REFERENCES offers(id),
    customer_id   UUID NOT NULL REFERENCES users(id),
    pro_id        UUID NOT NULL REFERENCES pro_profiles(id),
    total_amount  NUMERIC(10,2) NOT NULL CHECK (total_amount > 0),
    platform_commission NUMERIC(10,2) NOT NULL CHECK (platform_commission >= 0),   -- 10%
    pro_payout_amount   NUMERIC(10,2) NOT NULL CHECK (pro_payout_amount >= 0),
    status        payment_status NOT NULL DEFAULT 'INITIALIZED',
    provider_ref  VARCHAR(100),
    failure_code  VARCHAR(20),             -- e.g. ERR-51 (3D Secure failure)
    card_last4    CHAR(4),
    locked_at     TIMESTAMPTZ,
    released_at   TIMESTAMPTZ,
    refunded_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT payment_split_matches CHECK (total_amount = platform_commission + pro_payout_amount)
);

-- ---------- Messaging ----------
CREATE TABLE chat_messages (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL REFERENCES job_requests(id) ON DELETE CASCADE,
    sender_id     UUID NOT NULL REFERENCES users(id),
    message_text  TEXT NOT NULL,
    attachment_url TEXT,
    is_read       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_chat_job ON chat_messages (job_id, created_at);

-- ---------- Reviews ----------
CREATE TABLE reviews (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id        UUID NOT NULL UNIQUE REFERENCES job_requests(id),
    customer_id   UUID NOT NULL REFERENCES users(id),
    pro_id        UUID NOT NULL REFERENCES pro_profiles(id),
    rating        INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    tags          TEXT[] NOT NULL DEFAULT '{}',
    comment       TEXT,
    show_full_name BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_reviews_pro ON reviews (pro_id, created_at DESC);

-- ---------- Disputes and admin ----------
CREATE TABLE disputes (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_no       VARCHAR(20) NOT NULL UNIQUE,         -- e.g. CMP-104
    job_id        UUID NOT NULL REFERENCES job_requests(id),
    opened_by     UUID NOT NULL REFERENCES users(id),
    against_pro_id UUID NOT NULL REFERENCES pro_profiles(id),
    type          dispute_type NOT NULL,
    description   TEXT NOT NULL,
    status        dispute_status NOT NULL DEFAULT 'OPEN',
    decision      dispute_decision,
    decision_reason TEXT,
    decided_by    UUID REFERENCES users(id),
    opened_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    decided_at    TIMESTAMPTZ,
    CHECK ((status IN ('RESOLVED', 'REJECTED')) = (decision IS NOT NULL))
);
CREATE INDEX idx_disputes_status ON disputes (status, opened_at DESC);

CREATE TABLE dispute_evidence (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id    UUID NOT NULL REFERENCES disputes(id) ON DELETE CASCADE,
    file_url      TEXT NOT NULL,
    file_size_bytes INT NOT NULL CHECK (file_size_bytes <= 2621440),
    uploaded_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audit log for every admin action (suspend, approve, decide dispute)
CREATE TABLE admin_actions (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id      UUID NOT NULL REFERENCES users(id),
    action        VARCHAR(40) NOT NULL,
    target_type   VARCHAR(30) NOT NULL,
    target_id     UUID NOT NULL,
    details       JSONB NOT NULL DEFAULT '{}',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------- Notifications and history ----------
CREATE TABLE notifications (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type          notification_type NOT NULL,
    data          JSONB NOT NULL DEFAULT '{}',          -- the app turns type + data into TR/EN text
    job_id        UUID REFERENCES job_requests(id) ON DELETE SET NULL,
    is_read       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_notif_user ON notifications (user_id, is_read, created_at DESC);

CREATE TABLE job_status_history (
    id            BIGSERIAL PRIMARY KEY,
    job_id        UUID NOT NULL REFERENCES job_requests(id) ON DELETE CASCADE,
    from_status   job_status,
    to_status     job_status NOT NULL,
    changed_by    UUID REFERENCES users(id),
    changed_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------- Triggers ----------
CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS trigger AS $$
BEGIN NEW.updated_at := NOW(); RETURN NEW; END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_users_touch BEFORE UPDATE ON users        FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER trg_jobs_touch  BEFORE UPDATE ON job_requests FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

CREATE OR REPLACE FUNCTION log_job_status() RETURNS trigger AS $$
BEGIN
    IF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO job_status_history (job_id, from_status, to_status) VALUES (NEW.id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_jobs_history AFTER UPDATE ON job_requests FOR EACH ROW EXECUTE FUNCTION log_job_status();

-- Messaging is allowed only after an offer has been accepted (RAD rule)
CREATE OR REPLACE FUNCTION chat_only_after_acceptance() RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM job_requests WHERE id = NEW.job_id
                   AND status NOT IN ('DRAFT', 'PENDING_OFFERS', 'CANCELLED')) THEN
        RAISE EXCEPTION 'Messaging opens only after an offer is accepted (job %)', NEW.job_id USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_chat_rule BEFORE INSERT ON chat_messages FOR EACH ROW EXECUTE FUNCTION chat_only_after_acceptance();

-- Keep the professional's rating summary up to date
CREATE OR REPLACE FUNCTION refresh_pro_rating() RETURNS trigger AS $$
BEGIN
    UPDATE pro_profiles p SET
        rating_avg = COALESCE((SELECT ROUND(AVG(rating)::numeric, 2) FROM reviews WHERE pro_id = NEW.pro_id), 0),
        total_reviews_count = (SELECT COUNT(*) FROM reviews WHERE pro_id = NEW.pro_id)
    WHERE p.id = NEW.pro_id;
    RETURN NEW;
END $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_review_rating AFTER INSERT OR UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION refresh_pro_rating();

COMMIT;
