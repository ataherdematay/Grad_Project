package com.bitadilat.dev;

import com.bitadilat.common.ApiException;
import jakarta.servlet.http.HttpServletRequest;
import java.net.InetAddress;
import java.net.UnknownHostException;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Tüm verileri siler ve seed'i yeniden yükler. Yalnızca dev profilinde bean olarak vardır, yalnızca loopback'ten çalışır. */
@RestController
@Profile("dev")
@RequestMapping("/api/v1/dev")
public class DevResetController {

    private final DevDataService data;

    public DevResetController(DevDataService data) {
        this.data = data;
    }

    @PostMapping("/reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reset(HttpServletRequest request) {
        if (!isLoopback(request.getRemoteAddr())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bu uç nokta yalnızca 127.0.0.1'den çağrılabilir.");
        }
        data.resetAndSeed();
    }

    // X-Forwarded-For dikkate alınmaz; yalnızca doğrudan bağlantının adresine bakılır.
    private static boolean isLoopback(String remoteAddr) {
        try {
            return remoteAddr != null && InetAddress.getByName(remoteAddr).isLoopbackAddress();
        } catch (UnknownHostException e) {
            return false;
        }
    }
}
