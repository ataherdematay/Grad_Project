package com.bitadilat.media;

import java.util.Optional;

/** Dosya baytlarının saklandığı yer. Şimdilik yerel disk; ileride nesne deposu aynı arayüzle eklenir. */
public interface MediaStorage {

    void store(String key, byte[] content);

    Optional<byte[]> load(String key);

    void delete(String key);
}
