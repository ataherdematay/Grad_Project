package com.bitadilat.job;

import static com.bitadilat.job.JobStatus.ARRIVED;
import static com.bitadilat.job.JobStatus.AWAITING_APPOINTMENT;
import static com.bitadilat.job.JobStatus.CANCELLED;
import static com.bitadilat.job.JobStatus.COMPLETED;
import static com.bitadilat.job.JobStatus.DISPUTED;
import static com.bitadilat.job.JobStatus.IN_PROGRESS;
import static com.bitadilat.job.JobStatus.RESOLVED;
import static com.bitadilat.job.JobStatus.SCHEDULED;
import static com.bitadilat.job.JobStatus.WORK_FINISHED;

import com.bitadilat.common.ApiException;
import java.time.Duration;
import java.time.Instant;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;

/**
 * İş durum makinesi (docs/spec/STATE_MACHINES.md §4). İşin durumu yalnızca {@link #transition} ile değişir ve
 * "hangi düğme gösterilir" ({@link #allowedActions}) aynı tablodan hesaplanır; böylece sunucu kuralı ile istemcinin
 * gördüğü eylem listesi ayrışamaz. Tabloda olmayan geçiş 409 ILLEGAL_STATE.
 */
public final class JobStateMachine {

    /** 48 saat sonra otomatik tamamlama. */
    public static final Duration AUTO_COMPLETE_AFTER = Duration.ofHours(48);

    /** Geçişi tetikleyen olay. Müşteri onayı ve 48 saatlik otomatik tamamlama aynı geçiştir (CONFIRM). */
    public enum Trigger {
        ACCEPT_APPOINTMENT, ARRIVE, START, FINISH, CONFIRM, CANCEL, COMPLAIN,
        ADMIN_COMPLETE, ADMIN_CANCEL, ADMIN_RESOLVE
    }

    /** İstemcinin yalnızca bu listeden düğme gösterdiği eylemler (sözleşme). */
    public enum Action {
        PROPOSE_SLOT, ACCEPT_PROPOSAL, MARK_ARRIVED, START_WORK, FINISH_WORK, ADD_NOTE, CONFIRM_COMPLETION,
        CANCEL, COMPLAIN, REVIEW, CHAT
    }

    /** Bir görüntüleyen için eylem listesini belirleyen bağlam. */
    public record Context(JobStatus status, ActorRole viewer, boolean pendingProposalFromOtherSide, boolean reviewed,
                          boolean chatOpen) {
    }

    private static final Map<JobStatus, Map<Trigger, JobStatus>> TABLE = new EnumMap<>(JobStatus.class);

    static {
        TABLE.put(AWAITING_APPOINTMENT, Map.of(Trigger.ACCEPT_APPOINTMENT, SCHEDULED, Trigger.CANCEL, CANCELLED));
        TABLE.put(SCHEDULED, Map.of(Trigger.ARRIVE, ARRIVED, Trigger.CANCEL, CANCELLED, Trigger.COMPLAIN, DISPUTED));
        TABLE.put(ARRIVED, Map.of(Trigger.START, IN_PROGRESS, Trigger.CANCEL, CANCELLED, Trigger.COMPLAIN, DISPUTED));
        TABLE.put(IN_PROGRESS, Map.of(Trigger.FINISH, WORK_FINISHED, Trigger.COMPLAIN, DISPUTED));
        TABLE.put(WORK_FINISHED, Map.of(Trigger.CONFIRM, COMPLETED, Trigger.COMPLAIN, DISPUTED));
        TABLE.put(DISPUTED, Map.of(Trigger.ADMIN_COMPLETE, COMPLETED, Trigger.ADMIN_CANCEL, CANCELLED,
                Trigger.ADMIN_RESOLVE, RESOLVED));
        TABLE.put(COMPLETED, Map.of());
        TABLE.put(CANCELLED, Map.of());
        TABLE.put(RESOLVED, Map.of());
    }

    private JobStateMachine() {
    }

    public static boolean canApply(JobStatus from, Trigger trigger) {
        return TABLE.get(from).containsKey(trigger);
    }

    /** Hedef durum; tabloda yoksa 409 ILLEGAL_STATE. */
    public static JobStatus target(JobStatus from, Trigger trigger) {
        JobStatus to = TABLE.get(from).get(trigger);
        if (to == null) {
            throw ApiException.illegalState("İş " + from + " durumunda bu işlemi yapamaz.");
        }
        return to;
    }

    /**
     * Geçişi uygular ve tetikleyiciye bağlı zaman damgalarını yazar. Çağıran işi {@code FOR UPDATE} ile kilitlemiş,
     * olayı {@code job_events}'e yazmak ve kaydetmek çağıranın işidir.
     */
    public static void transition(Job job, Trigger trigger, Instant now) {
        JobStatus from = job.getStatus();
        JobStatus to = target(from, trigger);
        job.applyStatus(to);
        switch (trigger) {
            case ARRIVE -> job.setArrivedAt(now);
            case START -> job.setStartedAt(now);
            case FINISH -> {
                job.setFinishedAt(now);
                job.setAutoCompleteAt(now.plus(AUTO_COMPLETE_AFTER));
                job.setAutoCompleteRemindedAt(null);
            }
            case CONFIRM, ADMIN_COMPLETE -> {
                job.setCompletedAt(now);
                job.setAutoCompleteAt(null);
            }
            case CANCEL, ADMIN_CANCEL -> {
                job.setCancelledAt(now);
                job.setAutoCompleteAt(null);
            }
            case COMPLAIN -> {
                job.rememberStatusBeforeDispute(from);
                job.setAutoCompleteAt(null);
            }
            default -> {
            }
        }
    }

    /** Görüntüleyen için izin verilen eylemler; bu tablo müşteri ve usta ekranlarındaki düğmelerin tek kaynağıdır. */
    public static Set<Action> allowedActions(Context c) {
        Set<Action> out = EnumSet.noneOf(Action.class);
        boolean customer = c.viewer() == ActorRole.CUSTOMER;
        boolean pro = c.viewer() == ActorRole.PRO;
        JobStatus s = c.status();
        if (s == AWAITING_APPOINTMENT || s == SCHEDULED) {
            out.add(Action.PROPOSE_SLOT);
            if (c.pendingProposalFromOtherSide()) {
                out.add(Action.ACCEPT_PROPOSAL);
            }
        }
        if (pro) {
            if (s == SCHEDULED) {
                out.add(Action.MARK_ARRIVED);
            }
            if (s == ARRIVED) {
                out.add(Action.START_WORK);
            }
            if (s == IN_PROGRESS) {
                out.add(Action.FINISH_WORK);
            }
            if (s == ARRIVED || s == IN_PROGRESS) {
                out.add(Action.ADD_NOTE);
            }
        }
        if (customer) {
            if (s == WORK_FINISHED) {
                out.add(Action.CONFIRM_COMPLETION);
            }
            if (canApply(s, Trigger.COMPLAIN)) {
                out.add(Action.COMPLAIN);
            }
            if (s == COMPLETED && !c.reviewed()) {
                out.add(Action.REVIEW);
            }
        }
        if (canApply(s, Trigger.CANCEL)) {
            out.add(Action.CANCEL);
        }
        if (c.chatOpen()) {
            out.add(Action.CHAT);
        }
        return out;
    }
}
