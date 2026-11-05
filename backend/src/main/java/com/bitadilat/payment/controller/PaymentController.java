package com.bitadilat.payment.controller;

import com.bitadilat.payment.dto.InitPaymentRequest;
import com.bitadilat.payment.dto.InitPaymentResponse;
import com.bitadilat.payment.dto.OfferView;
import com.bitadilat.payment.dto.PaymentView;
import com.bitadilat.payment.dto.RefundRequest;
import com.bitadilat.payment.service.OfferCatalog;
import com.bitadilat.payment.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class PaymentController {

    private final PaymentService payments;
    private final OfferCatalog offers;

    public PaymentController(PaymentService payments, OfferCatalog offers) {
        this.payments = payments;
        this.offers = offers;
    }

    @GetMapping("/offers/{offerId}")
    public OfferView offer(@PathVariable String offerId) {
        return OfferView.from(offers.require(offerId));
    }

    @PostMapping("/payments/3ds/init")
    public InitPaymentResponse init(@Valid @RequestBody InitPaymentRequest request) {
        return payments.init3ds(request);
    }

    @GetMapping("/payments/{ref}")
    public PaymentView get(@PathVariable String ref) {
        return payments.get(ref);
    }

    @PostMapping("/payments/{ref}/release")
    public PaymentView release(@PathVariable String ref) {
        return payments.release(ref);
    }

    @PostMapping("/payments/{ref}/dispute")
    public PaymentView dispute(@PathVariable String ref) {
        return payments.dispute(ref);
    }

    @PostMapping("/payments/{ref}/refund")
    public PaymentView refund(@PathVariable String ref, @Valid @RequestBody RefundRequest request) {
        return payments.refund(ref, request.type());
    }
}
