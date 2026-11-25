package com.bitadilat.payment.controller;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentHistory;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentReceipt;
import com.bitadilat.payment.dto.PaymentDemoDtos.PaymentTimeline;
import com.bitadilat.payment.service.PaymentTimelineService;
import java.util.UUID;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Ödeme zaman çizelgesi, makbuz ve müşteri ödeme geçmişi (salt okunur, her profilde açık, kimlik ister). */
@RestController
@RequestMapping("/api/v1")
public class PaymentDemoController {

    private final PaymentTimelineService timelines;

    public PaymentDemoController(PaymentTimelineService timelines) {
        this.timelines = timelines;
    }

    @GetMapping("/jobs/{jobId}/payment/timeline")
    public PaymentTimeline timeline(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID jobId) {
        return timelines.timelineForJob(p.userId(), p.admin(), jobId);
    }

    @GetMapping("/jobs/{jobId}/payment/receipt")
    public PaymentReceipt receipt(@AuthenticationPrincipal AuthPrincipal p, @PathVariable UUID jobId) {
        return timelines.receipt(p.userId(), p.admin(), jobId);
    }

    @GetMapping("/me/payments")
    public PaymentHistory myPayments(@AuthenticationPrincipal AuthPrincipal p,
                                     @RequestParam(required = false) String cursor,
                                     @RequestParam(required = false) Integer limit) {
        return timelines.history(p.userId(), cursor, limit);
    }
}
