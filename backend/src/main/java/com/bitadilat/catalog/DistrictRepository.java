package com.bitadilat.catalog;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DistrictRepository extends JpaRepository<District, Integer> {

    List<District> findByActiveTrueOrderByNameAsc();

    Optional<District> findByNameAndActiveTrue(String name);
}
