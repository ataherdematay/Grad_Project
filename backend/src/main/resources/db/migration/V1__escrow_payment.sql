-- Mevcut ödeme servisinin tablosu. EscrowPayment.java ile birebir; ddl-auto=validate bunu kontrol eder.
CREATE TABLE escrow_payment (
    ref                  varchar(255)   PRIMARY KEY,
    offer_id             varchar(255)   NOT NULL,
    job_ref              varchar(255)   NOT NULL,
    attempt_key          varchar(255)   NOT NULL UNIQUE,
    conversation_id      varchar(255)   NOT NULL UNIQUE,
    craftgate_payment_id bigint         UNIQUE,
    total_amount         numeric(12, 2) NOT NULL,
    commission           numeric(12, 2) NOT NULL,
    pro_payout           numeric(12, 2) NOT NULL,
    refunded_amount      numeric(12, 2) NOT NULL,
    status               varchar(32)    NOT NULL CHECK (status IN (
                             'INITIALIZED', 'LOCKED', 'DISPUTED', 'RELEASED_TO_PRO',
                             'REFUNDED_TO_CUSTOMER', 'SPLIT_SETTLED', 'FAILED')),
    card_last4           varchar(255),
    error_message        varchar(255),
    result_uncertain     boolean        NOT NULL,
    created_at           timestamptz    NOT NULL,
    locked_at            timestamptz,
    released_at          timestamptz,
    refunded_at          timestamptz,
    version              bigint         NOT NULL
);
