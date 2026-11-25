package com.bitadilat.dev;

import com.bitadilat.common.ApiException;
import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.payment.dto.PaymentDemoDtos.FastForwardResult;
import jakarta.servlet.http.HttpServletRequest;
import java.util.UUID;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Demo saati: 48 saatlik otomatik aktarımı canlı göstermek için. Yalnızca dev profilinde bean olarak vardır
 * (prod'da yoktur, 404), yalnızca loopback'ten çalışır ve kimlik ister (işin müşterisi, ustası veya admin).
 */
@RestController
@Profile("dev")
@RequestMapping("/api/v1/dev")
public class DevPaymentClockController {

    private final DevPaymentClock clock;

    public DevPaymentClockController(DevPaymentClock clock) {
        this.clock = clock;
    }

    @PostMapping("/jobs/{jobId}/payment/fast-forward")
    public FastForwardResult fastForward(HttpServletRequest request, @AuthenticationPrincipal AuthPrincipal me,
                                         @PathVariable UUID jobId) {
        if (!DevResetController.isLoopback(request.getRemoteAddr())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "FORBIDDEN", "Bu uç nokta yalnızca 127.0.0.1'den çağrılabilir.");
        }
        return clock.fastForward(me.userId(), me.admin(), jobId);
    }
}
