package com.bitadilat.common;

import java.util.regex.Pattern;

/** Yalnızca Türkiye cep numaraları (+905xxxxxxxxx) kabul edilir. */
public final class PhoneNumbers {

    private static final Pattern SEPARATORS = Pattern.compile("[\\s().\\-]");
    private static final Pattern E164_TR_MOBILE = Pattern.compile("\\+905\\d{9}");

    private PhoneNumbers() {
    }

    /**
     * "0532 849 20 11", "5328492011", "+90 532 849 20 11" gibi girdileri "+905328492011" yapar.
     *
     * @return normalleştirilmiş numara; geçersizse {@code null}
     */
    public static String normalize(String raw) {
        if (raw == null) {
            return null;
        }
        String s = SEPARATORS.matcher(raw.trim()).replaceAll("");
        if (s.startsWith("+")) {
            // +90... olduğu gibi
        } else if (s.startsWith("0090")) {
            s = "+" + s.substring(2);
        } else if (s.startsWith("90") && s.length() == 12) {
            s = "+" + s;
        } else if (s.startsWith("0") && s.length() == 11) {
            s = "+9" + s;
        } else if (s.length() == 10) {
            s = "+90" + s;
        }
        return E164_TR_MOBILE.matcher(s).matches() ? s : null;
    }
}
