package com.bitadilat.pro;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProProfileRepository extends JpaRepository<ProProfile, UUID> {
}
