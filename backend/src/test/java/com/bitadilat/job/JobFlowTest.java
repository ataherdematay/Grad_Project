package com.bitadilat.job;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.bitadilat.Wave3TestBase;
import com.bitadilat.payment.exception.GatewayException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import tools.jackson.databind.JsonNode;

/** İş durum makinesi: randevu, usta aşamaları, teslim, iptal/iade, değerlendirme, şikayet, zamanlayıcı, kazançlar. */
class JobFlowTest extends Wave3TestBase {

    @Autowired
    private JobScheduler scheduler;

    private List<String> actions(JsonNode detail) {
        List<String> out = new ArrayList<>();
        detail.get("allowedActions").forEach(n -> out.add(n.asString()));
        return out;
    }

    private Instant slot(int days) {
        return Instant.now().plus(days, ChronoUnit.DAYS);
    }

    private Map<String, Object> slotBody(Instant from, int hours) {
        return Map.of("slotFrom", from.toString(), "slotTo", from.plus(hours, ChronoUnit.HOURS).toString());
    }

    // ─── Açılış ve görünürlük ───────────────────────────────────────────────

    @Test
    void jobIsVisibleToBothParticipantsWithRoleSpecificFields() throws Exception {
        Setup s = openRequestWithOffer("900", "300");
        String jobId = payAndOpenJob(s);

        JsonNode customer = job(s.customer(), jobId);
        assertThat(customer.get("status").asString()).isEqualTo("AWAITING_APPOINTMENT");
        assertThat(customer.get("viewerRole").asString()).isEqualTo("CUSTOMER");
        assertThat(customer.get("publicCode").asString()).isEqualTo(s.publicCode());
        assertThat(customer.get("counterpart").get("displayName").asString()).startsWith("Test Usta");
        assertThat(customer.get("totalAmount").asDouble()).isEqualTo(1200.0);
        assertThat(customer.get("offer").get("status").asString()).isEqualTo("ACCEPTED");
        // Hizmet bedeli ve net kazanç müşteriye görünmez.
        assertThat(customer.get("offer").get("serviceFee").isNull()).isTrue();
        assertThat(customer.get("offer").get("netEarning").isNull()).isTrue();
        assertThat(customer.get("payment").get("serviceFee").isNull()).isTrue();
        assertThat(customer.get("payment").get("netEarning").isNull()).isTrue();
        assertThat(customer.get("payment").get("status").asString()).isEqualTo("LOCKED");

        JsonNode pro = job(s.pro(), jobId);
        assertThat(pro.get("viewerRole").asString()).isEqualTo("PRO");
        assertThat(pro.get("counterpart").get("displayName").asString()).isEqualTo("Test K.");
        assertThat(pro.get("offer").get("serviceFee").asDouble()).isEqualTo(120.0);
        assertThat(pro.get("offer").get("netEarning").asDouble()).isEqualTo(1080.0);
        assertThat(pro.get("payment").get("serviceFee").asDouble()).isEqualTo(120.0);
        assertThat(pro.get("payment").get("netEarning").asDouble()).isEqualTo(1080.0);

        // Tam adres iş açıldığı için iki katılımcıya da görünür.
        for (JsonNode view : List.of(customer, pro)) {
            assertThat(view.get("address").get("lineFull").asString()).isEqualTo("Moda Cad. No: 14 Daire: 5");
            assertThat(view.get("address").get("doorNote").asString()).isEqualTo("Zil: Yılmaz");
            assertThat(view.get("address").get("districtName").asString()).isEqualTo("Kadıköy");
        }
        // Katılımcı olmayan 404.
        call(HttpMethod.GET, "/api/v1/jobs/" + jobId, register().access(), null).andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/jobs/" + jobId, null, null).andExpect(status().isUnauthorized());
        // Zaman çizelgesinde açılış olayı var.
        assertThat(customer.get("timeline").size()).isEqualTo(1);
        assertThat(customer.get("timeline").get(0).get("toStatus").asString()).isEqualTo("AWAITING_APPOINTMENT");
    }

    @Test
    void listsFilterByRoleAndScope() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        JsonNode active = body(call(HttpMethod.GET, "/api/v1/jobs?as=CUSTOMER&scope=active", s.customer().access(), null)
                .andExpect(status().isOk()));
        assertThat(active.get("items").size()).isEqualTo(1);
        assertThat(active.get("items").get(0).get("id").asString()).isEqualTo(jobId);
        assertThat(active.get("items").get(0).get("viewerRole").asString()).isEqualTo("CUSTOMER");
        call(HttpMethod.GET, "/api/v1/jobs?as=CUSTOMER&scope=past", s.customer().access(), null)
                .andExpect(jsonPath("$.items.length()").value(0));
        call(HttpMethod.GET, "/api/v1/jobs?as=PRO&scope=active", s.pro().access(), null)
                .andExpect(jsonPath("$.items.length()").value(1))
                .andExpect(jsonPath("$.items[0].counterpart.displayName").value("Test K."));
        // Ustanın müşteri rolünde işi yok; müşterinin usta rolünde de.
        call(HttpMethod.GET, "/api/v1/jobs?as=PRO&scope=active", s.customer().access(), null)
                .andExpect(jsonPath("$.items.length()").value(0));
        call(HttpMethod.GET, "/api/v1/jobs?as=BOTH&scope=active", s.customer().access(), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("as"));
        call(HttpMethod.GET, "/api/v1/jobs?as=PRO&scope=old", s.pro().access(), null)
                .andExpect(status().isBadRequest());
    }

    // ─── Randevu ────────────────────────────────────────────────────────────

    @Test
    void appointmentProposalAcceptanceRescheduleAndCounterProposal() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        assertThat(actions(job(s.customer(), jobId))).containsExactly("PROPOSE_SLOT", "CANCEL", "CHAT");

        JsonNode afterProposal = body(jobPost(s.customer(), jobId, "/appointment/proposals", slotBody(slot(1), 2))
                .andExpect(status().isOk()));
        JsonNode pending = afterProposal.get("appointment").get("pendingProposal");
        assertThat(pending.get("proposedBy").asString()).isEqualTo("CUSTOMER");
        String firstId = pending.get("id").asString();
        assertThat(notifications(s.pro(), "APPOINTMENT_PROPOSED")).isEqualTo(1);
        // Öneriyi yapan taraf kabul düğmesini görmez, karşı taraf görür.
        assertThat(actions(job(s.customer(), jobId))).doesNotContain("ACCEPT_PROPOSAL");
        assertThat(actions(job(s.pro(), jobId))).contains("ACCEPT_PROPOSAL");

        // Aynı taraf kendi önerisini kabul edemez.
        jobPost(s.customer(), jobId, "/appointment/proposals/" + firstId + "/accept", null)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        assertThat(jobStatus(jobId)).isEqualTo("AWAITING_APPOINTMENT");

        // Aynı taraftan yeni öneri eskisini SUPERSEDED yapar.
        String secondId = body(jobPost(s.customer(), jobId, "/appointment/proposals", slotBody(slot(2), 3))
                .andExpect(status().isOk())).get("appointment").get("pendingProposal").get("id").asString();
        assertThat(jdbc.queryForObject("select status from appointment_proposals where id = ?::uuid", String.class,
                firstId)).isEqualTo("SUPERSEDED");

        // Karşı tarafın önerisi bekleyeni REJECTED yapar.
        JsonNode counter = body(jobPost(s.pro(), jobId, "/appointment/proposals", slotBody(slot(3), 2))
                .andExpect(status().isOk()));
        assertThat(jdbc.queryForObject("select status from appointment_proposals where id = ?::uuid", String.class,
                secondId)).isEqualTo("REJECTED");
        assertThat(counter.get("appointment").get("pendingProposal").get("proposedBy").asString()).isEqualTo("PRO");
        assertThat(count("select count(*) from appointment_proposals where job_id = ?::uuid and status = 'PENDING'",
                jobId)).isEqualTo(1);

        // Müşteri kabul eder: AWAITING_APPOINTMENT → SCHEDULED.
        String counterId = counter.get("appointment").get("pendingProposal").get("id").asString();
        JsonNode scheduled = body(jobPost(s.customer(), jobId, "/appointment/proposals/" + counterId + "/accept", null)
                .andExpect(status().isOk()));
        assertThat(scheduled.get("status").asString()).isEqualTo("SCHEDULED");
        assertThat(scheduled.get("appointment").get("scheduledFrom").isNull()).isFalse();
        assertThat(scheduled.get("appointment").get("pendingProposal").isNull()).isTrue();
        assertThat(notifications(s.pro(), "APPOINTMENT_ACCEPTED")).isEqualTo(1);
        assertThat(count("select count(*) from job_events where job_id = ?::uuid and type = 'APPOINTMENT_ACCEPTED'",
                jobId)).isEqualTo(1);

        // SCHEDULED iken yeniden planlama: durum aynı kalır.
        String again = body(jobPost(s.pro(), jobId, "/appointment/proposals", slotBody(slot(4), 2)))
                .get("appointment").get("pendingProposal").get("id").asString();
        JsonNode rescheduled = body(jobPost(s.customer(), jobId, "/appointment/proposals/" + again + "/accept", null)
                .andExpect(status().isOk()));
        assertThat(rescheduled.get("status").asString()).isEqualTo("SCHEDULED");
        // Kabul edilmiş öneri tekrar kabul edilemez.
        jobPost(s.customer(), jobId, "/appointment/proposals/" + again + "/accept", null)
                .andExpect(status().isConflict());
        // Başka işin önerisi 404.
        jobPost(s.pro(), jobId, "/appointment/proposals/" + java.util.UUID.randomUUID() + "/accept", null)
                .andExpect(status().isNotFound());
    }

    @Test
    void proposalWindowRules() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        jobPost(s.customer(), jobId, "/appointment/proposals", slotBody(Instant.now().minus(1, ChronoUnit.HOURS), 2))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("slotFrom"));
        jobPost(s.customer(), jobId, "/appointment/proposals", Map.of("slotFrom", slot(1).toString(),
                "slotTo", slot(1).plus(30, ChronoUnit.MINUTES).toString()))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("slotTo"));
        jobPost(s.customer(), jobId, "/appointment/proposals", slotBody(slot(1), 13))
                .andExpect(status().isBadRequest());
        jobPost(s.customer(), jobId, "/appointment/proposals", slotBody(slot(31), 2))
                .andExpect(status().isBadRequest());
        jobPost(register(), jobId, "/appointment/proposals", slotBody(slot(1), 2)).andExpect(status().isNotFound());
        assertThat(count("select count(*) from appointment_proposals")).isZero();
    }

    // ─── Usta aşamaları ─────────────────────────────────────────────────────

    @Test
    void stagesRunInOrderAndWrongStateIs409() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        // Randevu yokken usta "ulaştım" diyemez.
        jobPost(s.pro(), jobId, "/arrived", null).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        jobPost(s.pro(), jobId, "/start", null).andExpect(status().isConflict());
        jobPost(s.pro(), jobId, "/finish", Map.of("note", "Tamamlandı, her şey yolunda.")).andExpect(status().isConflict());
        jobPost(s.pro(), jobId, "/events", Map.of("note", "Parça bekleniyor")).andExpect(status().isConflict());
        schedule(s, jobId);
        assertThat(actions(job(s.pro(), jobId))).contains("MARK_ARRIVED").doesNotContain("START_WORK");

        // Müşteri usta aşamasını çalıştıramaz (403); başkası 404.
        jobPost(s.customer(), jobId, "/arrived", null).andExpect(status().isForbidden());
        jobPost(register(), jobId, "/arrived", null).andExpect(status().isNotFound());

        jobPost(s.pro(), jobId, "/start", null).andExpect(status().isConflict()); // önce ulaşmalı
        JsonNode arrived = body(jobPost(s.pro(), jobId, "/arrived", null).andExpect(status().isOk()));
        assertThat(arrived.get("status").asString()).isEqualTo("ARRIVED");
        jobPost(s.pro(), jobId, "/arrived", null).andExpect(status().isConflict()); // tekrar
        assertThat(notifications(s.customer(), "JOB_STAGE_UPDATED")).isEqualTo(1);
        assertThat(actions(job(s.pro(), jobId))).contains("START_WORK", "ADD_NOTE", "CANCEL");

        JsonNode started = body(jobPost(s.pro(), jobId, "/start", null).andExpect(status().isOk()));
        assertThat(started.get("status").asString()).isEqualTo("IN_PROGRESS");
        assertThat(actions(job(s.pro(), jobId))).contains("FINISH_WORK", "ADD_NOTE").doesNotContain("CANCEL");

        // Ara not ve fotoğraf
        jobPost(s.pro(), jobId, "/events", Map.of()).andExpect(status().isBadRequest());
        var photo = upload(s.pro(), jpeg(20, 20), "JOB_PHOTO");
        JsonNode withEvents = body(jobPost(s.pro(), jobId, "/events",
                Map.of("note", "Eski boru değiştirildi.", "photoIds", List.of(photo.get("id").asString())))
                .andExpect(status().isOk()));
        JsonNode timeline = withEvents.get("timeline");
        assertThat(timeline.get(timeline.size() - 2).get("type").asString()).isEqualTo("NOTE");
        assertThat(timeline.get(timeline.size() - 1).get("type").asString()).isEqualTo("PHOTO");
        assertThat(timeline.get(timeline.size() - 1).get("photo").get("url").asString()).contains("/content");
        assertThat(timeline.get(timeline.size() - 1).get("actorRole").asString()).isEqualTo("PRO");
        // Aynı fotoğraf ikinci kez kullanılamaz.
        jobPost(s.pro(), jobId, "/events", Map.of("photoIds", List.of(photo.get("id").asString())))
                .andExpect(status().isBadRequest());
        // Başkasının veya yanlış amaçlı medya.
        var wrongPurpose = upload(s.pro(), jpeg(20, 20), "CHAT");
        jobPost(s.pro(), jobId, "/events", Map.of("photoIds", List.of(wrongPurpose.get("id").asString())))
                .andExpect(status().isBadRequest());
        var foreign = upload(s.customer(), jpeg(20, 20), "JOB_PHOTO");
        jobPost(s.pro(), jobId, "/events", Map.of("photoIds", List.of(foreign.get("id").asString())))
                .andExpect(status().isNotFound());
    }

    @Test
    void finishSetsAutoCompleteIn48HoursAndNotifiesCustomer() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);

        jobPost(s.pro(), jobId, "/finish", Map.of("note", "kısa")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.field").value("note"));
        assertThat(jobStatus(jobId)).isEqualTo("IN_PROGRESS");

        Instant before = Instant.now();
        JsonNode finished = body(jobPost(s.pro(), jobId, "/finish",
                Map.of("note", "Sızıntı giderildi, test edildi.", "photoIds", List.of())).andExpect(status().isOk()));
        assertThat(finished.get("status").asString()).isEqualTo("WORK_FINISHED");
        Instant auto = Instant.parse(finished.get("autoCompleteAt").asString());
        assertThat(auto).isBetween(before.plus(48, ChronoUnit.HOURS).minusSeconds(5),
                Instant.now().plus(48, ChronoUnit.HOURS).plusSeconds(5));
        assertThat(notifications(s.customer(), "WORK_FINISHED")).isEqualTo(1);
        assertThat(actions(job(s.customer(), jobId))).contains("CONFIRM_COMPLETION", "COMPLAIN")
                .doesNotContain("CANCEL");
        // Bitti notu zaman çizelgesindedir.
        JsonNode timeline = job(s.customer(), jobId).get("timeline");
        assertThat(timeline.get(timeline.size() - 1).get("note").asString()).isEqualTo("Sızıntı giderildi, test edildi.");
    }

    // ─── Teslim onayı ───────────────────────────────────────────────────────

    @Test
    void confirmReleasesEscrowWritesLedgerAndCountsCompletedJob() throws Exception {
        Setup s = openRequestWithOffer("900", "300");
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        // Henüz bitmeden onay yok.
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isConflict());
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");
        finishWork(s, jobId);
        // Usta teslimi onaylayamaz.
        jobPost(s.pro(), jobId, "/confirm", null).andExpect(status().isForbidden());

        int before = jdbc.queryForObject("select completed_jobs from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id());
        JsonNode done = body(jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk()));
        assertThat(done.get("status").asString()).isEqualTo("COMPLETED");
        assertThat(done.get("autoCompleteAt").isNull()).isTrue();
        assertThat(escrowStatus(jobId)).isEqualTo("RELEASED_TO_PRO");
        assertThat(jdbc.queryForObject("select completed_jobs from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id())).isEqualTo(before + 1);

        String ref = jdbc.queryForObject("select ref from escrow_payment where job_id = ?::uuid", String.class, jobId);
        assertThat(jdbc.queryForObject("select amount from payout_ledger where payment_ref = ? and kind = 'PAYOUT'",
                java.math.BigDecimal.class, ref)).isEqualByComparingTo("1080.00");
        assertThat(jdbc.queryForObject("select amount from payout_ledger where payment_ref = ? and kind = 'COMMISSION'",
                java.math.BigDecimal.class, ref)).isEqualByComparingTo("120.00");
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", ref)).isEqualTo(2);
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isEqualTo(1);
        verify(gateway, never()).refundFully(anyLong(), anyString());
        // İkinci onay yapılamaz, defter çoğalmaz.
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isConflict());
        assertThat(count("select count(*) from payout_ledger where payment_ref = ?", ref)).isEqualTo(2);
    }

    // ─── İptal ve iade ──────────────────────────────────────────────────────

    @Test
    void customerCancelRefundsInFullAndCancelsRequest() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        // Usta gerekçesi müşteriye geçmez.
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SCHEDULE_CONFLICT"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("reason"));
        JsonNode cancelled = body(jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "PLANS_CHANGED", "note", "Vazgeçtim"))
                .andExpect(status().isOk()));
        assertThat(cancelled.get("status").asString()).isEqualTo("CANCELLED");
        assertThat(cancelled.get("payment").get("status").asString()).isEqualTo("REFUNDED_TO_CUSTOMER");
        assertThat(cancelled.get("payment").get("refundedAmount").asDouble()).isEqualTo(1200.0);
        assertThat(escrowStatus(jobId)).isEqualTo("REFUNDED_TO_CUSTOMER");
        verify(gateway).refundFully(anyLong(), anyString());
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("CANCELLED");
        assertThat(jdbc.queryForObject("select cancelled_by || '/' || cancel_reason from jobs where id = ?::uuid",
                String.class, jobId)).isEqualTo("CUSTOMER/PLANS_CHANGED");
        assertThat(notifications(s.pro(), "JOB_CANCELLED")).isEqualTo(1);
        assertThat(jdbc.queryForObject("select cancellation_count from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id())).isZero();
        assertThat(actions(job(s.customer(), jobId))).doesNotContain("CANCEL", "PROPOSE_SLOT");
        // Tekrar iptal ve iade yok.
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "OTHER")).andExpect(status().isConflict());
        // Geçmiş listesinde.
        call(HttpMethod.GET, "/api/v1/jobs?as=CUSTOMER&scope=past", s.customer().access(), null)
                .andExpect(jsonPath("$.items.length()").value(1));
    }

    @Test
    void proCancelReopensRequestRestoresOffersAndCountsCancellation() throws Exception {
        Setup s = openRequestWithOffer();
        String otherOffer = secondOffer(s, "500", "200");
        String expired = secondOffer(s, "400", "100");
        String jobId = payAndOpenJob(s);
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, otherOffer))
                .isEqualTo("SUPERSEDED");
        // Bir teklifin süresi sonradan dolmuş olsun: geri dönmez.
        jdbc.update("update offers set valid_until = now() - interval '1 hour' where id = ?::uuid", expired);

        jobPost(s.pro(), jobId, "/cancel", Map.of("reason", "PLANS_CHANGED")).andExpect(status().isBadRequest());
        JsonNode cancelled = body(jobPost(s.pro(), jobId, "/cancel", Map.of("reason", "CANNOT_DO_JOB"))
                .andExpect(status().isOk()));
        assertThat(cancelled.get("status").asString()).isEqualTo("CANCELLED");
        assertThat(cancelled.get("viewerRole").asString()).isEqualTo("PRO");
        assertThat(escrowStatus(jobId)).isEqualTo("REFUNDED_TO_CUSTOMER");
        verify(gateway).refundFully(anyLong(), anyString());

        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("OPEN");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, s.offerId()))
                .isEqualTo("WITHDRAWN");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, otherOffer))
                .isEqualTo("PENDING");
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, expired))
                .isEqualTo("SUPERSEDED");
        assertThat(jdbc.queryForObject("select cancellation_count from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id())).isEqualTo(1);
        assertThat(notifications(s.customer(), "JOB_CANCELLED")).isEqualTo(1);
        // Müşteri iptal edilen işin yerine yeni teklifi ödeyebilir ve yeni iş açılır.
        call(HttpMethod.GET, "/api/v1/requests/" + s.requestId(), s.customer().access(), null)
                .andExpect(jsonPath("$.status").value("OPEN")).andExpect(jsonPath("$.offerCount").value(1))
                .andExpect(jsonPath("$.jobId").doesNotExist());
        Setup again = new Setup(s.customer(), s.pro(), s.requestId(), otherOffer, s.addressId(), s.publicCode());
        String newJob = payAndOpenJob(again);
        assertThat(newJob).isNotEqualTo(jobId);
        assertThat(jobStatus(newJob)).isEqualTo("AWAITING_APPOINTMENT");
        assertThat(count("select count(*) from jobs where request_id = ?::uuid", s.requestId())).isEqualTo(2);
    }

    @Test
    void cancelIsRefusedFromInProgressOnward() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        for (Account who : List.of(s.customer(), s.pro())) {
            jobPost(who, jobId, "/cancel", Map.of("reason", "OTHER")).andExpect(status().isConflict())
                    .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        }
        assertThat(jobStatus(jobId)).isEqualTo("IN_PROGRESS");
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");
        verify(gateway, never()).refundFully(anyLong(), anyString());
    }

    @Test
    void refundFailureReturns502AndChangesNothing() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        doThrow(new GatewayException("Craftgate yanıt vermedi.", true)).when(gateway).refundFully(anyLong(), anyString());
        jobPost(s.customer(), jobId, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.code").value("GATEWAY_ERROR"));
        assertThat(jobStatus(jobId)).isEqualTo("SCHEDULED");
        assertThat(escrowStatus(jobId)).isEqualTo("LOCKED");
        assertThat(jdbc.queryForObject("select status from service_requests where id = ?::uuid", String.class,
                s.requestId())).isEqualTo("ASSIGNED");
        assertThat(count("select count(*) from payout_ledger")).isZero();
        assertThat(notifications(s.pro(), "JOB_CANCELLED")).isZero();
        // Pro iptalinde de aynı: talep ASSIGNED kalır, sayaç artmaz.
        jobPost(s.pro(), jobId, "/cancel", Map.of("reason", "CANNOT_DO_JOB")).andExpect(status().isBadGateway());
        assertThat(jdbc.queryForObject("select status from offers where id = ?::uuid", String.class, s.offerId()))
                .isEqualTo("ACCEPTED");
        assertThat(jdbc.queryForObject("select cancellation_count from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id())).isZero();
    }

    // ─── Değerlendirme ──────────────────────────────────────────────────────

    @Test
    void reviewOnlyWhenCompletedOnceAndUpdatesRating() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        var review = Map.of("rating", 4, "tags", List.of("ON_TIME", "POLITE"), "comment", "Memnun kaldım",
                "anonymous", false);
        jobPost(s.customer(), jobId, "/review", review).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isOk());
        assertThat(actions(job(s.customer(), jobId))).contains("REVIEW");

        jobPost(s.pro(), jobId, "/review", review).andExpect(status().isForbidden());
        jobPost(s.customer(), jobId, "/review", Map.of("rating", 6)).andExpect(status().isBadRequest());
        jobPost(s.customer(), jobId, "/review", Map.of("rating", 5, "tags", List.of("RUDE")))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("tags"));

        JsonNode reviewed = body(jobPost(s.customer(), jobId, "/review", review).andExpect(status().isOk()));
        assertThat(reviewed.get("review").get("rating").asInt()).isEqualTo(4);
        assertThat(reviewed.get("review").get("tags").size()).isEqualTo(2);
        assertThat(reviewed.get("review").get("authorDisplay").asString()).isEqualTo("T.K.");
        assertThat(actions(reviewed)).doesNotContain("REVIEW");
        assertThat(jdbc.queryForObject("select rating_avg from pro_profiles where user_id = ?::uuid",
                java.math.BigDecimal.class, s.pro().id())).isEqualByComparingTo("4.00");
        assertThat(jdbc.queryForObject("select rating_count from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id())).isEqualTo(1);
        // Bir kez.
        jobPost(s.customer(), jobId, "/review", review).andExpect(status().isConflict());

        // İkinci iş, aynı usta: ortalama yeniden hesaplanır (4 ve 5 → 4,50).
        Setup next = openRequestWithOffer(); // başka usta; aynı ustayı yeniden kullanmak için işi doğrudan ona bağla
        String nextJob = payAndOpenJob(next);
        jdbc.update("update jobs set pro_id = ?::uuid where id = ?::uuid", s.pro().id(), nextJob);
        jdbc.update("update escrow_payment set pro_id = ?::uuid where job_id = ?::uuid", s.pro().id(), nextJob);
        Setup moved = new Setup(next.customer(), s.pro(), next.requestId(), next.offerId(), next.addressId(),
                next.publicCode());
        schedule(moved, nextJob);
        startWork(moved, nextJob);
        finishWork(moved, nextJob);
        jobPost(moved.customer(), nextJob, "/confirm", null).andExpect(status().isOk());
        jobPost(moved.customer(), nextJob, "/review", Map.of("rating", 5, "anonymous", true)).andExpect(status().isOk());
        assertThat(jdbc.queryForObject("select rating_avg from pro_profiles where user_id = ?::uuid",
                java.math.BigDecimal.class, s.pro().id())).isEqualByComparingTo("4.50");
        assertThat(jdbc.queryForObject("select rating_count from pro_profiles where user_id = ?::uuid",
                Integer.class, s.pro().id())).isEqualTo(2);
    }

    // ─── Şikayet ────────────────────────────────────────────────────────────

    @Test
    void complaintDisputesJobAndEscrowAndBlocksCancelAndRefund() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        // Randevu yokken (AWAITING_APPOINTMENT) şikayet açılamaz.
        var complaint = Map.of("reason", "EXTRA_CHARGE", "description", "Teklif dışı ek ücret talep edildi, kabul etmedim.");
        jobPost(s.customer(), jobId, "/complaint", complaint).andExpect(status().isConflict());
        schedule(s, jobId);
        startWork(s, jobId);

        var evidence = upload(s.customer(), jpeg(30, 30), "COMPLAINT");
        jobPost(s.customer(), jobId, "/complaint", Map.of("reason", "EXTRA_CHARGE", "description", "kısa"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.field").value("description"));
        jobPost(s.pro(), jobId, "/complaint", complaint).andExpect(status().isForbidden());
        JsonNode created = body(jobPost(s.customer(), jobId, "/complaint", Map.of("reason", "EXTRA_CHARGE",
                "description", "Teklif dışı ek ücret talep edildi, kabul etmedim.",
                "evidenceIds", List.of(evidence.get("id").asString()))).andExpect(status().isCreated()));
        assertThat(created.get("publicCode").asString()).matches("SK-\\d{4}");
        assertThat(created.get("status").asString()).isEqualTo("OPEN");
        assertThat(created.get("reason").asString()).isEqualTo("EXTRA_CHARGE");
        assertThat(created.get("evidence").size()).isEqualTo(1);
        assertThat(created.get("decision").isNull()).isTrue();
        assertThat(created.get("jobId").asString()).isEqualTo(jobId);

        assertThat(jobStatus(jobId)).isEqualTo("DISPUTED");
        assertThat(escrowStatus(jobId)).isEqualTo("DISPUTED");
        assertThat(jdbc.queryForObject("select status_before_dispute from jobs where id = ?::uuid", String.class, jobId))
                .isEqualTo("IN_PROGRESS");
        assertThat(notifications(s.pro(), "COMPLAINT_OPENED")).isEqualTo(1);
        JsonNode detail = job(s.customer(), jobId);
        assertThat(detail.get("complaint").get("publicCode").asString()).isEqualTo(created.get("publicCode").asString());
        assertThat(actions(detail)).doesNotContain("CANCEL", "COMPLAIN", "CONFIRM_COMPLETION");

        // DISPUTED iken iptal ve iade kapalı.
        for (Account who : List.of(s.customer(), s.pro())) {
            jobPost(who, jobId, "/cancel", Map.of("reason", "OTHER")).andExpect(status().isConflict());
        }
        jobPost(s.customer(), jobId, "/confirm", null).andExpect(status().isConflict());
        verify(gateway, never()).refundFully(anyLong(), anyString());
        assertThat(escrowStatus(jobId)).isEqualTo("DISPUTED");
        // İkinci şikayet yok.
        jobPost(s.customer(), jobId, "/complaint", complaint).andExpect(status().isConflict());

        // GET /complaints/{id}: iki taraf görür, başkası 404.
        String id = created.get("id").asString();
        call(HttpMethod.GET, "/api/v1/complaints/" + id, s.customer().access(), null).andExpect(status().isOk())
                .andExpect(jsonPath("$.evidence.length()").value(1));
        call(HttpMethod.GET, "/api/v1/complaints/" + id, s.pro().access(), null).andExpect(status().isOk());
        call(HttpMethod.GET, "/api/v1/complaints/" + id, register().access(), null).andExpect(status().isNotFound());
        call(HttpMethod.GET, "/api/v1/complaints/" + java.util.UUID.randomUUID(), s.pro().access(), null)
                .andExpect(status().isNotFound());
    }

    @Test
    void adminsAreNotifiedAndCanReadComplaint() throws Exception {
        Setup s = openRequestWithOffer();
        Account admin = register();
        jdbc.update("update users set is_admin = true where id = ?::uuid", admin.id());
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        JsonNode created = body(jobPost(s.customer(), jobId, "/complaint", Map.of("reason", "NO_SHOW",
                "description", "Usta belirtilen saatte gelmedi ve aramalara dönmedi.")).andExpect(status().isCreated()));
        assertThat(notifications(admin, "COMPLAINT_OPENED")).isEqualTo(1);
        call(HttpMethod.GET, "/api/v1/complaints/" + created.get("id").asString(), admin.access(), null)
                .andExpect(status().isOk());
    }

    // ─── Zamanlayıcı ────────────────────────────────────────────────────────

    @Test
    void schedulerCompletesFinishedJobAfter48HoursExactlyOnce() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);

        // Henüz 48 saat dolmadı.
        assertThat(scheduler.run(Instant.now()).completed()).isZero();
        assertThat(jobStatus(jobId)).isEqualTo("WORK_FINISHED");

        jdbc.update("update jobs set auto_complete_at = now() - interval '1 minute' where id = ?::uuid", jobId);
        assertThat(scheduler.run(Instant.now()).completed()).isEqualTo(1);
        assertThat(jobStatus(jobId)).isEqualTo("COMPLETED");
        assertThat(escrowStatus(jobId)).isEqualTo("RELEASED_TO_PRO");
        assertThat(jdbc.queryForObject("select actor_role from job_events where job_id = ?::uuid "
                + "and to_status = 'COMPLETED'", String.class, jobId)).isEqualTo("SYSTEM");
        assertThat(count("select count(*) from payout_ledger where kind in ('PAYOUT','COMMISSION')")).isEqualTo(2);
        assertThat(notifications(s.pro(), "PAYOUT_RELEASED")).isEqualTo(1);

        // İdempotent: ikinci çalışma hiçbir şey yapmaz.
        assertThat(scheduler.run(Instant.now()).completed()).isZero();
        assertThat(count("select count(*) from payout_ledger where kind in ('PAYOUT','COMMISSION')")).isEqualTo(2);
    }

    @Test
    void schedulerDoesNotCompleteJobWithComplaint() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        jobPost(s.customer(), jobId, "/complaint", Map.of("reason", "INCOMPLETE_WORK",
                "description", "İş yarım bırakıldı, gider hâlâ tıkalı durumda.")).andExpect(status().isCreated());
        // Şikayet açılınca otomatik tamamlama zamanı temizlenir.
        assertThat(job(s.customer(), jobId).get("autoCompleteAt").isNull()).isTrue();
        // Zaman damgası yine de geçmişe yazılsa (olağandışı veri) DISPUTED iş tamamlanmaz.
        jdbc.update("update jobs set auto_complete_at = now() - interval '1 hour' where id = ?::uuid", jobId);
        assertThat(scheduler.run(Instant.now()).completed()).isZero();
        assertThat(jobStatus(jobId)).isEqualTo("DISPUTED");
        assertThat(escrowStatus(jobId)).isEqualTo("DISPUTED");
    }

    @Test
    void reminderIsSentOnceInTheLast24Hours() throws Exception {
        Setup s = openRequestWithOffer();
        String jobId = payAndOpenJob(s);
        schedule(s, jobId);
        startWork(s, jobId);
        finishWork(s, jobId);
        assertThat(scheduler.run(Instant.now()).reminded()).isZero(); // 48 saat var
        jdbc.update("update jobs set auto_complete_at = now() + interval '23 hours' where id = ?::uuid", jobId);
        assertThat(scheduler.run(Instant.now()).reminded()).isEqualTo(1);
        assertThat(scheduler.run(Instant.now()).reminded()).isZero();
        assertThat(notifications(s.customer(), "AUTO_COMPLETE_REMINDER")).isEqualTo(1);
        assertThat(jobStatus(jobId)).isEqualTo("WORK_FINISHED");
    }

    // ─── Kazançlar ──────────────────────────────────────────────────────────

    @Test
    void earningsSumReleasedPendingRefundedAndFees() throws Exception {
        // Aynı usta üç iş: biri tamamlandı (1200), biri emanette (2000), biri iade edildi (500).
        Setup a = openRequestWithOffer("900", "300");
        String done = payAndOpenJob(a);
        schedule(a, done);
        startWork(a, done);
        finishWork(a, done);
        jobPost(a.customer(), done, "/confirm", null).andExpect(status().isOk());

        Setup b = openRequestWithOffer("1500", "500");
        String pending = payAndOpenJob(b);
        Setup c = openRequestWithOffer("400", "100");
        String refunded = payAndOpenJob(c);
        for (String[] j : new String[][] {{pending, b.pro().id()}, {refunded, c.pro().id()}}) {
            jdbc.update("update jobs set pro_id = ?::uuid where id = ?::uuid", a.pro().id(), j[0]);
            jdbc.update("update escrow_payment set pro_id = ?::uuid where job_id = ?::uuid", a.pro().id(), j[0]);
        }
        jobPost(c.customer(), refunded, "/cancel", Map.of("reason", "SOLVED")).andExpect(status().isOk());

        JsonNode e = body(call(HttpMethod.GET, "/api/v1/pro/earnings", a.pro().access(), null)
                .andExpect(status().isOk()));
        assertThat(e.get("releasedTotal").asDouble()).isEqualTo(1080.0);
        assertThat(e.get("pendingTotal").asDouble()).isEqualTo(1800.0);
        assertThat(e.get("serviceFeeTotal").asDouble()).isEqualTo(120.0);
        assertThat(e.get("items").size()).isEqualTo(3);
        Map<String, JsonNode> byJob = new java.util.HashMap<>();
        e.get("items").forEach(i -> byJob.put(i.get("jobId").asString(), i));
        assertThat(byJob.get(done).get("status").asString()).isEqualTo("RELEASED");
        assertThat(byJob.get(done).get("netEarning").asDouble()).isEqualTo(1080.0);
        assertThat(byJob.get(done).get("serviceFee").asDouble()).isEqualTo(120.0);
        assertThat(byJob.get(done).get("totalAmount").asDouble()).isEqualTo(1200.0);
        assertThat(byJob.get(pending).get("status").asString()).isEqualTo("PENDING");
        assertThat(byJob.get(pending).get("netEarning").asDouble()).isEqualTo(1800.0);
        assertThat(byJob.get(refunded).get("status").asString()).isEqualTo("REFUNDED");
        assertThat(byJob.get(refunded).get("netEarning").asDouble()).isZero();
        assertThat(byJob.get(done).get("publicCode").asString()).isEqualTo(a.publicCode());

        // Müşteri veya onaysız kullanıcı kazanç göremez.
        call(HttpMethod.GET, "/api/v1/pro/earnings", a.customer().access(), null).andExpect(status().isForbidden());
    }

    @Test
    void accountWithOpenJobCannotBeDeleted() throws Exception {
        Setup s = openRequestWithOffer();
        payAndOpenJob(s);
        call(HttpMethod.DELETE, "/api/v1/me", s.customer().access(), null)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ILLEGAL_STATE"));
    }
}
