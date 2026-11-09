package com.bitadilat.user;

import java.util.UUID;

/**
 * Hesap silmeden önce çağrılır. Açık iş veya kilitli emanet varsa uygulama
 * {@code ApiException.illegalState(...)} (409 ILLEGAL_STATE) fırlatmalıdır. Birden çok bean olabilir; hepsi geçmeli.
 * İş modülü geldiğinde kendi uygulamasını ekler.
 */
public interface AccountDeletionGuard {

    void assertCanDelete(UUID userId);
}
