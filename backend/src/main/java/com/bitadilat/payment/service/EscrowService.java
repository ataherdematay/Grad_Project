package com.bitadilat.payment.service;

import com.bitadilat.common.ApiException;
import com.bitadilat.payment.domain.EscrowEventType;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * İş modülünün emanet üzerindeki işlemleri: serbest bırakma, tam iade, itiraz ve defter. Hepsi çağıranın işlemine
 * katılır ve emanet satırını kilitli bekler (kilit sırası: iş, emanet, talep). Gerçek iade Craftgate'e gider; hata
 * {@code GatewayException} olarak yayılır ve çağıranın işlemi geri alınır (durum değişmez, 502). İş iptali bunun
 * yerine outbox kullanır ({@link #queueRefund}, {@link #refundPending}): iade, iptal kesinleştikten sonra yapılır.
 * Ustaya aktarım öncesi Craftgate'te iade sorulur ({@link #releaseChecked}).
 *
 * <p>{@code provider = SEED} kayıtlarında iade ve aktarım yalnızca defterde işlenir; bu yalnızca {@code dev}
 * profilinde izinlidir.
 */
@Slf4j
@Service
public class EscrowService {

    private static final String REFUND_PENDING_MESSAGE =
            "Önceki iade isteği sonuç bekliyor. Lütfen biraz sonra tekrar deneyin.";

    private final EscrowPaymentRepository repository;
    private final PaymentGateway gateway;
    private final JdbcTemplate jdbc;
    private final Environment environment;
    private final EscrowEvents events;

    public EscrowService(EscrowPaymentRepository repository, PaymentGateway gateway, JdbcTemplate jdbc,
                         Environment environment, EscrowEvents events) {
        this.events = events;
        this.repository = repository;
        this.gateway = gateway;
        this.jdbc = jdbc;
        this.environment = environment;
    }

    /** İşin emanetini kilitleyerek getirir; yoksa iş tutarsızdır (409). */
    @Transactional(propagation = Propagation.MANDATORY)
    public EscrowPayment lockForJob(UUID jobId) {
        return repository.findByJobIdForUpdate(jobId)
                .orElseThrow(() -> ApiException.illegalState("İşin emanet kaydı bulunamadı."));
    }

    /**
     * Hakem kararıyla ustaya aktarım. Önce Craftgate'te bu ödemeye iade yapılmış mı diye sorulur: önceki bir iade kararı
     * Craftgate'te gerçekleşip bizde geri alındıysa (zaman aşımı) müşteri parasını almıştır; ustaya da aktarılırsa
     * para iki kez dağıtılır. İade görünürse 409 (elle incelenir), sonuç bekleyen iade varsa 502.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public void releaseAfterDispute(EscrowPayment payment) {
        payment.requireRefundable();
        if (!payment.isSeed()) {
            BigDecimal already = gateway.refundedTotal(payment.getCraftgatePaymentId());
            if (already != null && already.signum() > 0) {
                log.error("Craftgate'te iade görünen ödeme ustaya aktarılmadı; elle incelenmeli. ref={} iade={}",
                        payment.getRef(), money(already).toPlainString());
                throw ApiException.illegalState("Bu ödemede Craftgate'te "
                        + already.setScale(2, RoundingMode.HALF_UP).toPlainString()
                        + " TL iade görünüyor; karar elle incelenmeli.");
            }
        }
        release(payment);
    }

    /** {@link #releaseChecked} sonucu. */
    public enum ReleaseOutcome {
        /** Emanet ustaya aktarıldı. */
        RELEASED,
        /** Craftgate'e sorulamadı: aktarım bekliyor, ödeme toplayıcısı yeniden dener. */
        QUEUED,
        /** Craftgate'te iade görünüyor (veya denemeler bitti): aktarılmadı, elle incelenir. */
        REVIEW
    }

    /**
     * Teslim onayı ve 48 saatlik otomatik tamamlama (ve onların yeniden denemesi): ustaya aktarmadan önce Craftgate'te bu
     * ödemeye iade yapılmış mı diye sorulur. İade görünürse aktarılmaz; kayıt {@code PAYOUT_NEEDS_REVIEW} olur (ERROR
     * logu, admin raporunda görünür). Craftgate yanıt vermezse aktarım {@code pending_action = RELEASE} olarak bekler ve
     * ödeme toplayıcısı artan aralıkla en fazla 8 kez yeniden dener; iş yine de tamamlanır (müşteri bekletilmez).
     * SEED kaydı yalnızca defterde aktarılır.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public ReleaseOutcome releaseChecked(EscrowPayment payment, Instant now) {
        payment.requireRefundable();
        if (!payment.isSeed()) {
            BigDecimal already;
            try {
                already = gateway.refundedTotal(payment.getCraftgatePaymentId());
            } catch (GatewayException e) {
                if (payment.getPendingAction() == null) {
                    payment.queueRelease(now);
                }
                boolean exhausted = payment.recordRefundFailure(now);
                if (exhausted) {
                    events.record(payment, EscrowEventType.REVIEW_REQUIRED, null, "SYSTEM", payment.getErrorCode());
                    log.error("Ustaya aktarım öncesi iade kontrolü {} denemede yapılamadı; elle incelenmeli. ref={}",
                            payment.getRefundAttempts(), payment.getRef());
                } else {
                    log.warn("Ustaya aktarım öncesi Craftgate'e sorulamadı; aktarım yeniden denenecek. ref={} deneme={}",
                            payment.getRef(), payment.getRefundAttempts());
                }
                repository.saveAndFlush(payment);
                return exhausted ? ReleaseOutcome.REVIEW : ReleaseOutcome.QUEUED;
            }
            if (already != null && already.signum() > 0) {
                if (payment.getPendingAction() == null) {
                    payment.queueRelease(now);
                }
                payment.sendToPayoutReview(now);
                repository.saveAndFlush(payment);
                events.record(payment, EscrowEventType.REVIEW_REQUIRED, null, "SYSTEM", payment.getErrorCode());
                log.error("Craftgate'te iade görünen ödeme ustaya aktarılmadı; elle incelenmeli. ref={} iade={}",
                        payment.getRef(), money(already).toPlainString());
                return ReleaseOutcome.REVIEW;
            }
        }
        release(payment);
        return ReleaseOutcome.RELEASED;
    }

    /**
     * İş iptali: tam iade niyeti kaydedilir (outbox), Craftgate'e bu işlemde gidilmez. İade işlem kesinleştikten sonra
     * {@link #refundPending} ile yapılır. SEED kaydı dev dışında reddedilir (409) ve iptal de geri alınır.
     * {@code actor}: iptali yapan taraf (CUSTOMER, PRO veya ADMIN); olay kaydına yazılır.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public void queueRefund(EscrowPayment payment, Instant now, String actor) {
        payment.requireRefundable();
        if (payment.isSeed()) {
            requireDevForSeed();
        }
        payment.queueRefund(now);
        repository.saveAndFlush(payment);
        events.record(payment, EscrowEventType.REFUND_REQUESTED, payment.getTotalAmount(), actor);
    }

    /**
     * Bekleyen tam iadeyi yapar (iptal sonrası ilk deneme ve zamanlayıcı denemeleri). {@link #refundFully} önce
     * Craftgate'e ne kadar iade edildiğini sorar; böylece yeniden deneme asla ikinci kez iade göndermez. Craftgate hatası
     * deneme sayılır (artan aralık, en fazla 8, sonra {@code REFUND_NEEDS_REVIEW}); Craftgate'te tutarsız iade görünürse
     * kayıt hemen elle incelemeye düşer. Dönüş: iade tamamlandı mı.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public boolean refundPending(EscrowPayment payment, Instant now) {
        try {
            refundFully(payment);
            log.info("Bekleyen iptal iadesi yapıldı. ref={}", payment.getRef());
            return true;
        } catch (GatewayException e) {
            if (payment.recordRefundFailure(now)) {
                events.record(payment, EscrowEventType.REVIEW_REQUIRED, null, "SYSTEM", payment.getErrorCode());
                log.error("İptal iadesi {} denemede yapılamadı, elle incelenmeli. ref={} paymentId={}",
                        payment.getRefundAttempts(), payment.getRef(), payment.getCraftgatePaymentId());
            } else {
                log.warn("İptal iadesi başarısız, yeniden denenecek. ref={} deneme={}", payment.getRef(),
                        payment.getRefundAttempts());
            }
        } catch (ApiException e) {
            log.error("İptal iadesi güvenle yapılamadı, elle incelenmeli. ref={} neden={}", payment.getRef(),
                    e.getMessage());
            payment.sendToRefundReview(now);
            events.record(payment, EscrowEventType.REVIEW_REQUIRED, null, "SYSTEM", payment.getErrorCode());
        }
        repository.saveAndFlush(payment);
        return false;
    }

    /** Teslim onayı: emanet ustaya aktarılır, PAYOUT ve COMMISSION defter satırları yazılır. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void release(EscrowPayment payment) {
        payment.release();
        repository.saveAndFlush(payment);
        ledger(payment, payment.getProPayout(), "PAYOUT");
        ledger(payment, payment.getCommission(), "COMMISSION");
        events.record(payment, EscrowEventType.RELEASED_TO_PRO, payment.getProPayout(), "SYSTEM");
        log.info("Emanet serbest bırakıldı. ref={} usta={} komisyon={}", payment.getRef(), payment.getProPayout(),
                payment.getCommission());
    }

    /**
     * Tam iade. Craftgate hatasında GatewayException fırlar ve emanet kaydı değişmez. {@code noRollbackFor}: çağıranın
     * işlemi bu çağrı yüzünden "yalnızca geri al" işaretlenmez; çağıran istisnayı yakalayıp devam edebilir (banka
     * dönüşündeki otomatik iade) veya yayarak kendi işlemini geri alabilir (iş iptali, 502).
     *
     * <p>İade göndermeden önce Craftgate'teki iade durumu sorulur. Önceki deneme zaman aşımına uğramış ama Craftgate'te
     * gerçekleşmiş olabilir (bizde işlem geri alındı): ödeme zaten tam iade edildiyse yeniden gönderilmez, yalnızca defter
     * işlenir. Aksi halde Craftgate ikinci isteği "önceden iptal edilmiş" diye reddeder ve karar her denemede 502 alır.
     * Sonuç bekleyen iade varsa yeniden denenebilir 502. Kısmi iade görünürse (ör. panelden elle) yalnızca kalan tutar
     * iade edilir (toplam − iade edilmiş, asla fazlası değil): müşteri toplamı tam bir kez almış olur. Defterde tek REFUND
     * satırı toplam tutarla yazılır; {@code refundedAmount} = toplam.
     */
    @Transactional(propagation = Propagation.MANDATORY, noRollbackFor = GatewayException.class)
    public void refundFully(EscrowPayment payment) {
        refundFully(payment, "SYSTEM");
    }

    /** {@link #refundFully(EscrowPayment)}; {@code actor} (SYSTEM veya ADMIN) olay kaydına yazılır. */
    @Transactional(propagation = Propagation.MANDATORY, noRollbackFor = GatewayException.class)
    public void refundFully(EscrowPayment payment, String actor) {
        payment.requireRefundable();
        BigDecimal amount = payment.getTotalAmount();
        if (payment.isSeed()) {
            requireDevForSeed();
        } else {
            refundRemainderOnCraftgate(payment, amount);
        }
        payment.refundFully();
        repository.saveAndFlush(payment);
        ledger(payment, amount, "REFUND");
        events.record(payment, EscrowEventType.REFUNDED, amount, actor);
    }

    /**
     * Hakem kararı %50/%50: yarısı Craftgate üzerinden müşteriye iade edilir, yarısı ustaya yazılır (komisyon yok).
     * Yalnızca DISPUTED emanette; hata durumunda GatewayException fırlar ve emanet kaydı değişmez. Defter: müşteri
     * yarısı REFUND, usta yarısı PAYOUT. İade göndermeden önce Craftgate'teki iade toplamı sorulur: tam bu yarı zaten
     * iade edilmişse (önceki deneme 502 almış ama para gitmiş) yeniden gönderilmez; başka bir tutar görünürse 409.
     */
    @Transactional(propagation = Propagation.MANDATORY, noRollbackFor = GatewayException.class)
    public void settleSplit(EscrowPayment payment) {
        payment.requireSplittable();
        BigDecimal refund = payment.splitRefundAmount();
        if (payment.isSeed()) {
            requireDevForSeed();
        } else {
            // Önceki deneme zaman aşımına uğramış ama Craftgate'te gerçekleşmiş olabilir: kısmi iade iki kez gitmesin.
            BigDecimal already = gateway.refundedTotal(payment.getCraftgatePaymentId());
            if (already == null || already.signum() == 0) {
                gateway.refundPartially(payment.getCraftgatePaymentId(), refund, payment.getConversationId());
            } else if (already.compareTo(refund) == 0) {
                log.warn("Kısmi iade Craftgate'te zaten yapılmış; yeniden gönderilmedi, yalnızca defter işlendi. ref={}"
                        + " tutar={}", payment.getRef(), money(already).toPlainString());
            } else {
                log.error("Craftgate'te beklenmeyen iade tutarı; %50/%50 kararı uygulanmadı. ref={} iade={} beklenen={}",
                        payment.getRef(), money(already).toPlainString(), refund.toPlainString());
                throw ApiException.illegalState("Bu ödemede Craftgate'te "
                        + already.setScale(2, RoundingMode.HALF_UP).toPlainString()
                        + " TL iade görünüyor; karar elle incelenmeli.");
            }
        }
        payment.settleSplit();
        repository.saveAndFlush(payment);
        ledger(payment, refund, "REFUND");
        ledger(payment, payment.getProPayout(), "PAYOUT");
        events.record(payment, EscrowEventType.SPLIT_SETTLED, refund, "ADMIN");
    }

    /**
     * Craftgate ödemeyi zaten iade etmiş (iade yanıtı bize ulaşmamıştı): yeniden iade göndermeden yalnızca defteri
     * düzeltir.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public void recordRefundAlreadyDone(EscrowPayment payment, String actor) {
        payment.requireRefundable();
        BigDecimal amount = payment.getTotalAmount();
        payment.refundFully();
        repository.saveAndFlush(payment);
        ledger(payment, amount, "REFUND");
        events.record(payment, EscrowEventType.REFUNDED, amount, actor, "ALREADY_REFUNDED_AT_GATEWAY");
    }

    /** Şikayet: emanet DISPUTED olur. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void dispute(EscrowPayment payment) {
        payment.dispute();
        repository.saveAndFlush(payment);
        events.record(payment, EscrowEventType.DISPUTE_OPENED, null, "CUSTOMER");
    }

    /**
     * Craftgate'teki duruma göre tam iadeyi tamamlar; emanet kaydına dokunmaz. Hiçbir yol toplamdan fazlasını iade etmez:
     * <ul>
     *   <li>FULLY_REFUNDED: yeni iade yok (önceki deneme gerçekleşmiş).</li>
     *   <li>REFUND_PENDING veya kalemde sonuç bekleyen iade: 502, yeniden denenebilir.</li>
     *   <li>İade yok: tam iade.</li>
     *   <li>0 &lt; iade edilmiş &lt; toplam: kalan tutar kalem iadesiyle gönderilir.</li>
     *   <li>iade edilmiş ≥ toplam ama durum "tam iade" değil, ya da durum kısmi ama tutar okunamıyor: tutarsız, para
     *       gönderilmez (409 / 502).</li>
     * </ul>
     */
    private void refundRemainderOnCraftgate(EscrowPayment payment, BigDecimal total) {
        Long paymentId = payment.getCraftgatePaymentId();
        PaymentGateway.RefundState state = gateway.refundState(paymentId);
        if (state == PaymentGateway.RefundState.FULLY_REFUNDED) {
            log.warn("Ödeme Craftgate'te zaten tam iade edilmiş; yeniden gönderilmedi, yalnızca defter işlendi. ref={}"
                    + " paymentId={}", payment.getRef(), paymentId);
            return;
        }
        if (state == PaymentGateway.RefundState.REFUND_PENDING) {
            throw new GatewayException(REFUND_PENDING_MESSAGE, true);
        }
        // Kalem düzeyindeki iadeler de sayılır; kalemde sonuç bekleyen iade varsa burada 502 fırlar.
        BigDecimal already = money(gateway.refundedTotal(paymentId));
        if (already.signum() == 0) {
            if (state == PaymentGateway.RefundState.PARTIALLY_REFUNDED) {
                log.error("Craftgate kısmi iade diyor ama başarılı iade tutarı okunamadı; iade gönderilmedi. ref={}"
                        + " paymentId={}", payment.getRef(), paymentId);
                throw new GatewayException("Craftgate'teki iade durumu doğrulanamadı; para hareketi yapılmadı. "
                        + "Lütfen biraz sonra tekrar deneyin.", true);
            }
            gateway.refundFully(paymentId, payment.getConversationId());
            return;
        }
        if (already.compareTo(total) >= 0) {
            log.error("Craftgate'te toplam kadar veya fazla iade görünüyor ama durum tam iade değil; iade gönderilmedi,"
                    + " elle incelenmeli. ref={} paymentId={} iade={} toplam={} durum={}",
                    payment.getRef(), paymentId, already.toPlainString(), total.toPlainString(), state);
            throw ApiException.illegalState("Bu ödemede Craftgate'te " + already.toPlainString()
                    + " TL iade görünüyor; tam iade elle incelenmeli.");
        }
        BigDecimal remainder = money(total.subtract(already));
        log.warn("Ödeme Craftgate'te kısmen iade edilmiş; yalnızca kalan tutar iade ediliyor. ref={} paymentId={}"
                + " toplam={} iadeEdilmiş={} kalan={}", payment.getRef(), paymentId, total.toPlainString(),
                already.toPlainString(), remainder.toPlainString());
        gateway.refundPartially(paymentId, remainder, payment.getConversationId());
    }

    private static BigDecimal money(BigDecimal value) {
        return (value == null ? BigDecimal.ZERO : value).setScale(2, RoundingMode.HALF_UP);
    }

    private void requireDevForSeed() {
        if (!environment.acceptsProfiles(Profiles.of("dev"))) {
            throw ApiException.illegalState("SEED emaneti yalnızca dev profilinde işlenebilir.");
        }
    }

    private void ledger(EscrowPayment payment, BigDecimal amount, String kind) {
        if (amount == null || amount.signum() <= 0 || payment.getProId() == null) {
            return;
        }
        jdbc.update("insert into payout_ledger (payment_ref, pro_id, amount, kind) values (?, ?, ?, ?)",
                payment.getRef(), payment.getProId(), amount, kind);
    }
}
