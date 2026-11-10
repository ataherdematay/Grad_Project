package com.bitadilat.job;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppointmentProposalRepository extends JpaRepository<AppointmentProposal, UUID> {

    Optional<AppointmentProposal> findByJobIdAndStatus(UUID jobId, ProposalStatus status);

    Optional<AppointmentProposal> findByIdAndJobId(UUID id, UUID jobId);
}
