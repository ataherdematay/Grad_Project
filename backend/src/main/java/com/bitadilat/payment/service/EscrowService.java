package com.bitadilat.payment.service;

import com.bitadilat.common.ApiException;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway;
import java.math.BigDecimal;
import java.math.RoundingMode;
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
 * {@code GatewayException} olarak yayılır ve çağıranın işlemi geri alınır (durum değişmez, 502).
 *
 * <p>{@code provider = SEED} kayıtlarında iade ve aktarım yalnızca defterde işlenir; bu yalnızca {@code dev}
 * profilinde izinlidir.
 */
@Slf4j
@Service
public class EscrowService {

    private final EscrowPaymentRepository repository;
    private final PaymentGateway gateway;
    private final JdbcTemplate jdbc;
    private final Environment environment;

    public EscrowService(EscrowPaymentRepository repository, PaymentGateway gateway, JdbcTemplate jdbc,
                         Environment environment) {
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
                        payment.getRef(), already);
                throw ApiException.illegalState("Bu ödemede Craftgate'te "
                        + already.setScale(2, RoundingMode.HALF_UP).toPlainString()
                        + " TL iade görünüyor; karar elle incelenmeli.");
            }
        }
        release(payment);
    }

    /** Teslim onayı: emanet ustaya aktarılır, PAYOUT ve COMMISSION defter satırları yazılır. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void release(EscrowPayment payment) {
        payment.release();
        repository.saveAndFlush(payment);
        ledger(payment, payment.getProPayout(), "PAYOUT");
        ledger(payment, payment.getCommission(), "COMMISSION");
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
     * Sonuç bekleyen iade varsa yeniden denenebilir 502; kısmi iade görünürse 409 (elle incelenir).
     */
    @Transactional(propagation = Propagation.MANDATORY, noRollbackFor = GatewayException.class)
    public void refundFully(EscrowPayment payment) {
        payment.requireRefundable();
        BigDecimal amount = payment.getTotalAmount();
        if (payment.isSeed()) {
            requireDevForSeed();
        } else {
            PaymentGateway.RefundState state = gateway.refundState(payment.getCraftgatePaymentId());
            if (state == PaymentGateway.RefundState.FULLY_REFUNDED) {
                log.warn("Ödeme Craftgate'te zaten tam iade edilmiş; yeniden gönderilmedi, yalnızca defter işlendi. ref={}",
                        payment.getRef());
            } else if (state == PaymentGateway.RefundState.REFUND_PENDING) {
                throw new GatewayException("Önceki iade isteği sonuç bekliyor. Lütfen biraz sonra tekrar deneyin.", true);
            } else if (state == PaymentGateway.RefundState.PARTIALLY_REFUNDED) {
                log.error("Ödeme Craftgate'te kısmen iade edilmiş; tam iade gönderilmedi, elle incelenmeli. ref={}",
                        payment.getRef());
                throw ApiException.illegalState("Bu ödemede Craftgate'te kısmi iade görünüyor; işlem elle incelenmeli.");
            } else {
                gateway.refundFully(payment.getCraftgatePaymentId(), payment.getConversationId());
            }
        }
        payment.refundFully();
        repository.saveAndFlush(payment);
        ledger(payment, amount, "REFUND");
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
                        + " tutar={}", payment.getRef(), already);
            } else {
                log.error("Craftgate'te beklenmeyen iade tutarı; %50/%50 kararı uygulanmadı. ref={} iade={} beklenen={}",
                        payment.getRef(), already, refund);
                throw ApiException.illegalState("Bu ödemede Craftgate'te "
                        + already.setScale(2, RoundingMode.HALF_UP).toPlainString()
                        + " TL iade görünüyor; karar elle incelenmeli.");
            }
        }
        payment.settleSplit();
        repository.saveAndFlush(payment);
        ledger(payment, refund, "REFUND");
        ledger(payment, payment.getProPayout(), "PAYOUT");
    }

    /**
     * Craftgate ödemeyi zaten iade etmiş (iade yanıtı bize ulaşmamıştı): yeniden iade göndermeden yalnızca defteri
     * düzeltir.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public void recordRefundAlreadyDone(EscrowPayment payment) {
        payment.requireRefundable();
        BigDecimal amount = payment.getTotalAmount();
        payment.refundFully();
        repository.saveAndFlush(payment);
        ledger(payment, amount, "REFUND");
    }

    /** Şikayet: emanet DISPUTED olur. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void dispute(EscrowPayment payment) {
        payment.dispute();
        repository.saveAndFlush(payment);
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
