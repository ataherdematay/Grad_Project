package com.bitadilat.payment.controller;

import com.bitadilat.common.security.AuthPrincipal;
import com.bitadilat.payment.dto.AppInitResponse;
import com.bitadilat.payment.dto.InitPaymentRequest;
import com.bitadilat.payment.dto.PaymentResult;
import com.bitadilat.payment.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Uygulama kanalı ödemesi (v1, kimlik ister, her profilde açık). Prototip uç noktaları ayrıdır ve yalnız dev'dedir. */
@RestController
@RequestMapping("/api/v1/payments")
public class PaymentV1Controller {

    private final PaymentService payments;

    public PaymentV1Controller(PaymentService payments) {
        this.payments = payments;
    }

    @PostMapping("/3ds/init")
    public AppInitResponse init(@AuthenticationPrincipal AuthPrincipal p, @Valid @RequestBody InitPaymentRequest body) {
        return payments.initApp(p.userId(), body);
    }

    @GetMapping("/{ref}")
    public PaymentResult get(@AuthenticationPrincipal AuthPrincipal p, @PathVariable String ref) {
        return payments.result(p.userId(), p.admin(), ref);
    }
}
