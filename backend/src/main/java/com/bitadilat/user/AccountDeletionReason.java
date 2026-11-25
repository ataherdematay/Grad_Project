package com.bitadilat.user;

/** Hesap silme gerekçesi (yalnızca analiz; kullanıcıya bağlanmaz). */
public enum AccountDeletionReason {
    NO_LONGER_NEEDED,
    FOUND_ALTERNATIVE,
    PRIVACY,
    BAD_EXPERIENCE,
    OTHER
}
