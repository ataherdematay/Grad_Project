package com.bitadilat.payment.service;

import com.bitadilat.common.ApiException;
import com.bitadilat.payment.domain.EscrowPayment;
import com.bitadilat.payment.domain.EscrowPaymentRepository;
import com.bitadilat.payment.exception.GatewayException;
import com.bitadilat.payment.gateway.PaymentGateway;
import java.math.BigDecimal;
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
     */
    @Transactional(propagation = Propagation.MANDATORY, noRollbackFor = GatewayException.class)
    public void refundFully(EscrowPayment payment) {
        payment.requireRefundable();
        BigDecimal amount = payment.getTotalAmount();
        if (payment.isSeed()) {
            requireDevForSeed();
        } else {
            gateway.refundFully(payment.getCraftgatePaymentId(), payment.getConversationId());
        }
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
            throw new IllegalStateException("SEED emaneti yalnızca dev profilinde işlenebilir.");
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
