package com.bitadilat.payment.controller;

import com.bitadilat.payment.service.PaymentService;
import com.bitadilat.payment.service.PaymentService.CallbackOutcome;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Bankadan dönen tarayıcının geldiği adres. Yanıt her durumda kullanıcıyı prototipe geri götüren
 * bir sayfadır; ham JSON hatası gösterilmez. Sayfaya gelen parametrelerden hiçbiri yazılmaz, yalnızca
 * sunucunun ürettiği ref ve sabit ekran kimlikleri kullanılır (XSS'e kapalı).
 */
@Slf4j
@RestController
public class ThreeDsCallbackController {

    static final String SUCCESS_SCREEN_SID = "7c6ec3a02d3347a997a3fc5b1a2c91d0";
    static final String FAILURE_SCREEN_SID = "1476367258dd4a7aa4b9cbda6b0091c0";

    private final PaymentService payments;

    public ThreeDsCallbackController(PaymentService payments) {
        this.payments = payments;
    }

    @PostMapping(path = "/api/payments/3ds/callback", produces = MediaType.TEXT_HTML_VALUE + ";charset=UTF-8")
    public String callback(@RequestParam Map<String, String> params) {
        CallbackOutcome outcome;
        try {
            outcome = payments.handleCallback(params);
        } catch (RuntimeException e) {
            log.error("3DS callback işlenemedi: {}", e.getClass().getName(), e);
            outcome = new CallbackOutcome(null, false);
        }
        return resultPage(outcome);
    }

    private static String resultPage(CallbackOutcome outcome) {
        String target = outcome.locked() ? SUCCESS_SCREEN_SID : FAILURE_SCREEN_SID;
        String ref = outcome.ref() == null ? "" : outcome.ref();
        return """
                <!DOCTYPE html>
                <html lang="tr"><head><meta charset="utf-8"><title>BiTadilat Ödeme</title></head>
                <body style="font-family:sans-serif;text-align:center;padding:48px 16px;color:#102A34">
                <p>Ödeme sonucu işleniyor...</p>
                <script>
                (function () {
                  var ref = "%s", target = "%s", locked = %s;
                  try {
                    if (ref) sessionStorage.setItem('bitadilat_escrow_ref', ref);
                    if (locked) sessionStorage.setItem('bitadilat_escrow_just_locked', '1');
                  } catch (e) {}
                  window.location.replace('/preview/index.html?sid=' + target);
                })();
                </script>
                </body></html>
                """.formatted(ref, target, outcome.locked());
    }
}
