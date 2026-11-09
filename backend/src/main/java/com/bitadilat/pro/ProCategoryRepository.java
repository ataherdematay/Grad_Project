package com.bitadilat.pro;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProCategoryRepository extends JpaRepository<ProCategory, ProCategory.Key> {

    List<ProCategory> findByProId(UUID proId);

    boolean existsByProIdAndCategoryId(UUID proId, String categoryId);

    void deleteByProId(UUID proId);
}
