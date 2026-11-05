package com.bitadilat.payment.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.bitadilat.payment.exception.InvalidCardException;
import com.bitadilat.payment.gateway.PaymentGateway.CardDetails;
import java.time.YearMonth;
import org.junit.jupiter.api.Test;

class CardValidatorTest {

    private static final YearMonth NOW = YearMonth.of(2026, 11);

    private static CardDetails card(String holder, String number, String month, String year, String cvc) {
        return new CardDetails(holder, number, month, year, cvc);
    }

    @Test
    void normalizesSpacesAndTwoDigitYear() {
        CardDetails result = CardValidator.normalize(
                card(" Ayşe Demir ", "5258 6400 0000 0001", "7", "44", "000"), NOW);

        assertThat(result.number()).isEqualTo("5258640000000001");
        assertThat(result.holderName()).isEqualTo("Ayşe Demir");
        assertThat(result.expireMonth()).isEqualTo("07");
        assertThat(result.expireYear()).isEqualTo("2044");
    }

    @Test
    void rejectsNumberFailingLuhn() {
        assertField(card("Ayşe Demir", "5258640000000002", "07", "2044", "000"), "number");
    }

    @Test
    void rejectsExpiredCardButAcceptsCurrentMonth() {
        assertField(card("Ayşe Demir", "5258640000000001", "10", "2026", "000"), "expiry");
        assertThat(CardValidator.normalize(card("Ayşe Demir", "5258640000000001", "11", "2026", "000"), NOW))
                .isNotNull();
    }

    @Test
    void rejectsInvalidMonth() {
        assertField(card("Ayşe Demir", "5258640000000001", "13", "2044", "000"), "expiry");
    }

    @Test
    void rejectsMissingFieldsWithoutSilentDefaults() {
        assertField(card("", "5258640000000001", "07", "2044", "000"), "holderName");
        assertField(card("Ayşe Demir", null, "07", "2044", "000"), "number");
        assertField(card("Ayşe Demir", "5258640000000001", null, null, "000"), "expiry");
        assertField(card("Ayşe Demir", "5258640000000001", "07", "2044", ""), "cvc");
    }

    @Test
    void errorMessagesNeverContainTheCardNumber() {
        assertThatThrownBy(() -> CardValidator.normalize(
                card("Ayşe Demir", "5258640000000002", "07", "2044", "000"), NOW))
                .hasMessageNotContaining("5258640000000002");
    }

    private static void assertField(CardDetails card, String field) {
        assertThatThrownBy(() -> CardValidator.normalize(card, NOW))
                .isInstanceOf(InvalidCardException.class)
                .extracting(e -> ((InvalidCardException) e).getField())
                .isEqualTo(field);
    }
}
