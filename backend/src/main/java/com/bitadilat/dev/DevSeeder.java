package com.bitadilat.dev;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/** Açılışta veritabanı boşsa demo setini yükler. Yalnızca {@code dev}; {@code prod}'da bean oluşmaz. */
@Component
@Profile("dev")
public class DevSeeder implements ApplicationRunner {

    private final DevDataService data;

    public DevSeeder(DevDataService data) {
        this.data = data;
    }

    @Override
    public void run(ApplicationArguments args) {
        data.seedIfEmpty();
    }
}
