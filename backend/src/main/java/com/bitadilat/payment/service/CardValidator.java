package com.bitadilat.payment.service;

import com.bitadilat.payment.exception.InvalidCardException;
import com.bitadilat.payment.gateway.PaymentGateway.CardDetails;
import java.time.YearMonth;

/** Kartı sağlayıcıya göndermeden önce doğrular. Hata mesajları girilen değeri içermez. */
final class CardValidator {

    private CardValidator() {
    }

    /** Boşlukları temizlenmiş, dört haneli yıllı kartı döner. */
    static CardDetails normalize(CardDetails card, YearMonth now) {
        String holder = card.holderName() == null ? "" : card.holderName().trim();
        if (holder.length() < 3 || !holder.contains(" ")) {
            throw new InvalidCardException("holderName", "Kart üzerindeki adı ve soyadı girin.");
        }

        String number = card.number() == null ? "" : card.number().replaceAll("[\\s-]", "");
        if (!number.matches("\\d{15,16}") || !passesLuhn(number)) {
            throw new InvalidCardException("number", "Kart numarası geçersiz.");
        }

        String month = card.expireMonth() == null ? "" : card.expireMonth().trim();
        String year = card.expireYear() == null ? "" : card.expireYear().trim();
        if (year.matches("\\d{2}")) {
            year = "20" + year;
        }
        if (!month.matches("\\d{1,2}") || !year.matches("\\d{4}")) {
            throw new InvalidCardException("expiry", "Son kullanma tarihi geçersiz.");
        }
        int monthNumber = Integer.parseInt(month);
        if (monthNumber < 1 || monthNumber > 12) {
            throw new InvalidCardException("expiry", "Son kullanma tarihi geçersiz.");
        }
        if (YearMonth.of(Integer.parseInt(year), monthNumber).isBefore(now)) {
            throw new InvalidCardException("expiry", "Kartın son kullanma tarihi geçmiş.");
        }

        String cvc = card.cvc() == null ? "" : card.cvc().trim();
        if (!cvc.matches("\\d{3,4}")) {
            throw new InvalidCardException("cvc", "Güvenlik kodu (CVC) geçersiz.");
        }

        return new CardDetails(holder, number, String.format("%02d", monthNumber), year, cvc);
    }

    static boolean passesLuhn(String digits) {
        int sum = 0;
        boolean doubleIt = false;
        for (int i = digits.length() - 1; i >= 0; i--) {
            int digit = digits.charAt(i) - '0';
            if (doubleIt) {
                digit *= 2;
                if (digit > 9) {
                    digit -= 9;
                }
            }
            sum += digit;
            doubleIt = !doubleIt;
        }
        return sum % 10 == 0;
    }
}
