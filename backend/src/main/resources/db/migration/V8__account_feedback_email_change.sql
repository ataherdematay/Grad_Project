-- Hesap silme gerekçesi: yalnızca analiz için. Kullanıcıya bağlanmaz (user_id yok, serbest metin yok, gün çözünürlüğü).
CREATE TABLE account_deletion_feedback (
    id              bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reason          varchar(32) NOT NULL CHECK (reason IN ('NO_LONGER_NEEDED', 'FOUND_ALTERNATIVE', 'PRIVACY',
                                                           'BAD_EXPERIENCE', 'OTHER')),
    had_pro_profile boolean     NOT NULL,
    created_on      date        NOT NULL DEFAULT current_date
);

-- E-posta değişikliği: yeni adrese gönderilen 6 haneli kodla doğrulanır; doğrulanmadan users.email değişmez.
CREATE TABLE email_change_codes (
    id         uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    uuid         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    new_email  varchar(254) NOT NULL,
    code_hash  varchar(64)  NOT NULL,
    attempts   integer      NOT NULL DEFAULT 0,
    expires_at timestamptz  NOT NULL,
    used_at    timestamptz,
    created_at timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX ix_email_change_codes_user ON email_change_codes (user_id, created_at DESC);
