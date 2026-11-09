package com.bitadilat.dev;

import java.util.Set;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * dev profili sabit sırlar, seeder ve sıfırlama uç noktası taşır; bu yüzden yalnızca loopback adresine bağlanabilir.
 * Aksi halde uygulama açılışta durur.
 */
@Component
@Profile("dev")
public class DevProfileGuard {

    static final String MESSAGE =
            "dev profili yalnızca 127.0.0.1 üzerinde çalışır; sunucuda SPRING_PROFILES_ACTIVE=prod kullanın";
    private static final Set<String> LOOPBACK = Set.of("127.0.0.1", "::1", "[::1]", "localhost");

    public DevProfileGuard(@Value("${server.address:}") String serverAddress) {
        check(serverAddress);
    }

    static void check(String serverAddress) {
        String value = serverAddress == null ? "" : serverAddress.trim().toLowerCase();
        if (!LOOPBACK.contains(value)) {
            throw new IllegalStateException(MESSAGE + " (server.address='" + serverAddress + "')");
        }
    }
}
