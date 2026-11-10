package com.bitadilat.common;

import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Yalnızca test sınıf yolunda bulunan uç nokta: eşzamanlı iki yazmanın sürüm çakışmasını taklit eder.
 * Üretim koduna girmez; sözleşme davranışı (global 409 ILLEGAL_STATE) {@link Wave3CarryOverTest}'te sınanır.
 */
@RestController
class OptimisticConflictController {

    @GetMapping("/api/v1/test/optimistic-conflict")
    String conflict() {
        throw new org.springframework.orm.ObjectOptimisticLockingFailureException(
                com.bitadilat.job.Job.class, UUID.randomUUID());
    }
}
