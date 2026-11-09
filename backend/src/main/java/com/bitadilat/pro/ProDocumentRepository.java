package com.bitadilat.pro;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProDocumentRepository extends JpaRepository<ProDocument, UUID> {

    List<ProDocument> findByProIdOrderByCreatedAtAsc(UUID proId);

    List<ProDocument> findByProId(UUID proId);

    void deleteByProId(UUID proId);
}
