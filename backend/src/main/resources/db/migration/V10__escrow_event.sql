-- Ödeme zaman çizelgesi: emanet geçişlerinin değişmez olay kaydı (yalnızca eklenir). Olaylar EscrowEvents üzerinden,
-- geçişi yapan işlemle birlikte yazılır. İş tarafı olayları (teslim, onay, otomatik aktarım zamanı) job_events/jobs'tan
-- okunur; burada yalnızca emanete ait olaylar tutulur. payment_ref için yabancı anahtar yoktur (payout_ledger gibi):
-- olay kaydı emanet satırının silinmesini/temizlenmesini engellemez.
CREATE TABLE escrow_event (
    id          bigserial      PRIMARY KEY,
    payment_ref varchar(255)   NOT NULL,
    type        varchar(24)    NOT NULL CHECK (type IN ('PAYMENT_INITIALIZED', 'THREEDS_STARTED', 'PAYMENT_LOCKED',
                                   'FAILED', 'DISPUTE_OPENED', 'REFUND_REQUESTED', 'REFUNDED', 'RELEASED_TO_PRO',
                                   'SPLIT_SETTLED', 'REVIEW_REQUIRED')),
    amount      numeric(12, 2),
    actor_role  varchar(10)    NOT NULL DEFAULT 'SYSTEM' CHECK (actor_role IN ('CUSTOMER', 'PRO', 'SYSTEM', 'ADMIN')),
    note        varchar(500),
    created_at  timestamptz    NOT NULL DEFAULT now()
);
CREATE INDEX ix_escrow_event_payment ON escrow_event (payment_ref, created_at, id);

-- Kartın markası (VISA, MASTERCARD, TROY, AMEX); yalnızca marka, kart numarası hiçbir zaman saklanmaz.
ALTER TABLE escrow_payment ADD COLUMN card_brand varchar(16);
