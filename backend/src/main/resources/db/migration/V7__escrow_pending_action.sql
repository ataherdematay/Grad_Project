-- Kalıcı para hareketi niyeti (outbox). İş iptalinde REFUND yazılır; teslim onayında Craftgate'e sorulamadığında
-- RELEASE yazılır. Asıl Craftgate çağrısı işlem kesinleştikten sonra yapılır; başarısızlık veya çökmede ödeme
-- toplayıcısı aynı sayaç ve bekleme süreleriyle (refund_attempts, next_refund_attempt_at, en fazla 8) yeniden dener.
ALTER TABLE escrow_payment
    ADD COLUMN pending_action varchar(10) CHECK (pending_action IN ('REFUND', 'RELEASE'));

CREATE INDEX ix_escrow_pending_action ON escrow_payment (next_refund_attempt_at)
    WHERE pending_action IS NOT NULL;
