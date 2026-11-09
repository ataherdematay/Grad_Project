package com.bitadilat.user;

import java.util.UUID;
import org.springframework.stereotype.Component;

/** Bu dalgada iş yok; her zaman izin verir. İş modülü eklendiğinde gerçek kural ayrı bir guard olarak gelir. */
@Component
class PermissiveAccountDeletionGuard implements AccountDeletionGuard {

    @Override
    public void assertCanDelete(UUID userId) {
        // açık iş / kilitli emanet kontrolü yok
    }
}
