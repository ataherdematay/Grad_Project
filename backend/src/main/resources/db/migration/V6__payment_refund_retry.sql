-- Öksüz iade yeniden denemesi: sayaç, son deneme ve sıradaki deneme zamanı. En fazla 8 deneme;
-- sınır aşılınca error_code = REFUND_NEEDS_REVIEW olur ve zamanlayıcı kaydı bırakır (elle inceleme).
ALTER TABLE escrow_payment
    ADD COLUMN refund_attempts        integer     NOT NULL DEFAULT 0,
    ADD COLUMN last_refund_attempt_at timestamptz,
    ADD COLUMN next_refund_attempt_at timestamptz;

CREATE INDEX ix_escrow_orphan_refund ON escrow_payment (next_refund_attempt_at)
    WHERE status = 'LOCKED' AND job_id IS NULL AND error_code IS NOT NULL;
