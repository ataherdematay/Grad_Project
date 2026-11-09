package com.bitadilat.pro;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProWorkingHoursRepository extends JpaRepository<ProWorkingHours, UUID> {

    List<ProWorkingHours> findByProIdOrderByWeekdayAscStartTimeAsc(UUID proId);
}
