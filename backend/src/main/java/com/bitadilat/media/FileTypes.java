package com.bitadilat.media;

import java.nio.charset.StandardCharsets;
import java.util.Set;

/** Dosya türü uzantıdan veya istemcinin söylediği türden değil, baştaki sihirli baytlardan anlaşılır. */
final class FileTypes {

    static final String JPEG = "image/jpeg";
    static final String PNG = "image/png";
    static final String HEIC = "image/heic";
    static final String PDF = "application/pdf";

    private static final Set<String> HEIF_BRANDS =
            Set.of("heic", "heix", "hevc", "hevx", "heim", "heis", "hevm", "hevs", "mif1", "msf1");

    private FileTypes() {
    }

    /** Tanınmazsa null. */
    static String detect(byte[] b) {
        if (b.length >= 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF) {
            return JPEG;
        }
        if (b.length >= 8 && (b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G'
                && b[4] == 0x0D && b[5] == 0x0A && b[6] == 0x1A && b[7] == 0x0A) {
            return PNG;
        }
        if (b.length >= 5 && b[0] == '%' && b[1] == 'P' && b[2] == 'D' && b[3] == 'F' && b[4] == '-') {
            return PDF;
        }
        if (b.length >= 12 && b[4] == 'f' && b[5] == 't' && b[6] == 'y' && b[7] == 'p'
                && HEIF_BRANDS.contains(new String(b, 8, 4, StandardCharsets.US_ASCII))) {
            return HEIC;
        }
        return null;
    }

    static String extension(String contentType) {
        return switch (contentType) {
            case JPEG -> ".jpg";
            case PNG -> ".png";
            case HEIC -> ".heic";
            default -> ".pdf";
        };
    }
}
