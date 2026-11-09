package com.bitadilat.common;

import jakarta.validation.Constraint;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.nio.charset.StandardCharsets;

/** En az 8 karakter, en az bir harf ve bir rakam. BCrypt sınırı nedeniyle en fazla 72 bayt. */
@Documented
@Constraint(validatedBy = ValidPassword.Validator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.RECORD_COMPONENT})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidPassword {

    String message() default "Şifre en az 8 karakter olmalı ve en az bir harf ile bir rakam içermeli.";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

    class Validator implements ConstraintValidator<ValidPassword, String> {
        @Override
        public boolean isValid(String value, ConstraintValidatorContext context) {
            if (value == null) {
                return false;
            }
            return PasswordRules.isValid(value);
        }
    }

    final class PasswordRules {
        private PasswordRules() {
        }

        public static boolean isValid(String value) {
            if (value.length() < 8 || value.getBytes(StandardCharsets.UTF_8).length > 72) {
                return false;
            }
            boolean letter = false;
            boolean digit = false;
            for (int i = 0; i < value.length(); i++) {
                char c = value.charAt(i);
                letter |= Character.isLetter(c);
                digit |= Character.isDigit(c);
            }
            return letter && digit;
        }
    }
}
