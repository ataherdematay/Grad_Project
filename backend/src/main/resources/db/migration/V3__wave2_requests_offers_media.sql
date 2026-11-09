-- Wave 2: talep, teklif, usta başvurusu ve medya uç noktalarının ihtiyaç duyduğu küçük şema eklemeleri.

-- Sözleşme: talep başlığı 5-150 karakter (V2 120'ydi).
ALTER TABLE service_requests ALTER COLUMN title TYPE varchar(150);

-- Müşteri iptal gerekçesi (CANCELLED talepler).
ALTER TABLE service_requests
    ADD COLUMN cancel_reason varchar(24),
    ADD COLUMN cancel_note   varchar(500);

-- Teklif reddi: gerekçe kodu decline_reason sütununda, serbest not ayrı.
ALTER TABLE offers
    ADD COLUMN decline_note    varchar(500),
    ADD COLUMN idempotency_key varchar(64);
-- Aynı usta + aynı anahtar tek satır üretir (Idempotency-Key tekrarı aynı teklifi döner).
CREATE UNIQUE INDEX ux_offers_idempotency ON offers (pro_id, idempotency_key) WHERE idempotency_key IS NOT NULL;

-- Kalem sırası istemcinin gönderdiği sıradır.
ALTER TABLE offer_items ADD COLUMN sort_order integer NOT NULL DEFAULT 0;

-- Sözleşme: HEIC fotoğraf kabul edilir.
ALTER TABLE media DROP CONSTRAINT media_content_type_check;
ALTER TABLE media ADD CONSTRAINT media_content_type_check
    CHECK (content_type IN ('image/jpeg', 'image/png', 'image/heic', 'application/pdf'));

-- Herkese gösterilen kodlar: BD-##### ve T-#####. Dizi çakışmasız ve yarışsız numara verir.
-- Başlangıç değerleri dev seed'in sabit kodlarının (BD-88412, T-10001..T-10003) hemen ardındadır.
CREATE SEQUENCE request_code_seq START WITH 88413;
CREATE SEQUENCE offer_code_seq START WITH 10004;

-- Zamanlayıcı ve akış sorguları için.
CREATE INDEX ix_service_requests_expiry ON service_requests (expires_at) WHERE status = 'OPEN';
CREATE INDEX ix_offers_valid_until ON offers (valid_until) WHERE status = 'PENDING';
