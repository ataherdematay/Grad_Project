-- Wave 4: bildirim uç noktaları, cihaz anahtarları (device_tokens) ve yönetici (admin) işlemleri için sorgu indeksleri.

CREATE INDEX IF NOT EXISTS ix_pro_profiles_review_status
    ON pro_profiles (review_status, updated_at DESC);

CREATE INDEX IF NOT EXISTS ix_complaints_status_created
    ON complaints (status, created_at DESC);

CREATE INDEX IF NOT EXISTS ix_admin_actions_created
    ON admin_actions (created_at DESC);

CREATE INDEX IF NOT EXISTS ix_escrow_status_created
    ON escrow_payment (status, created_at DESC);
