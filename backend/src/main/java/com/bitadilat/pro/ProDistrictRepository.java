package com.bitadilat.pro;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProDistrictRepository extends JpaRepository<ProDistrict, ProDistrict.Key> {

    List<ProDistrict> findByProId(UUID proId);

    boolean existsByProIdAndDistrictId(UUID proId, Integer districtId);

    void deleteByProId(UUID proId);
}
