package com.bitadilat.job;

/** docs/spec/STATE_MACHINES.md §4. Geçişler yalnızca {@link JobStateMachine} üzerinden yapılır. */
public enum JobStatus {
    AWAITING_APPOINTMENT, SCHEDULED, ARRIVED, IN_PROGRESS, WORK_FINISHED, COMPLETED, DISPUTED, CANCELLED, RESOLVED;

    /** Sözleşme: etkin iş = COMPLETED, CANCELLED ve RESOLVED dışındakiler. */
    public boolean isActive() {
        return this != COMPLETED && this != CANCELLED && this != RESOLVED;
    }

    /** Sohbetin 30 gün sonra salt okunur olduğu kapanmış durumlar. */
    public boolean isClosed() {
        return !isActive();
    }
}
