import 'package:flutter/services.dart';

import '../../core/forms.dart';

/// Kart formundaki alanlar (sunucudaki `field` değerleriyle aynı adlar).
enum CardField { holderName, number, expiry, cvc }

/// Yerel doğrulama sonucu: hangi alanda hangi hata.
enum CardError {
  holderInvalid,
  numberInvalid,
  expiryInvalid,
  expiryPast,
  cvcInvalid,
}

/// Sunucunun `INVALID_CARD` hatasındaki `field` değerini alana çevirir.
CardField? cardFieldFromServer(String? field) {
  for (final f in CardField.values) {
    if (f.name == field) return f;
  }
  return null;
}

/// Luhn sağlama toplamı. Boş ya da rakam dışı içerik geçersizdir.
bool passesLuhn(String digits) {
  if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) return false;
  var sum = 0;
  var doubleIt = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var d = digits.codeUnitAt(i) - 48;
    if (doubleIt) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
    doubleIt = !doubleIt;
  }
  return sum % 10 == 0;
}

/// `5258 6400 0000 0001`: 4'lü gruplar, en çok 16 hane.
String formatCardNumber(String raw) {
  final d = digitsOf(raw);
  final digits = d.length > 16 ? d.substring(0, 16) : d;
  final b = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && i % 4 == 0) b.write(' ');
    b.write(digits[i]);
  }
  return b.toString();
}

/// `07/44`: iki hane, eğik çizgi, iki hane.
String formatExpiry(String raw) {
  final d = digitsOf(raw);
  final digits = d.length > 4 ? d.substring(0, 4) : d;
  return digits.length > 2
      ? '${digits.substring(0, 2)}/${digits.substring(2)}'
      : digits;
}

TextEditingValue _collapsed(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue v) =>
      _collapsed(formatCardNumber(v.text));
}

class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue v) {
    // Silerken eğik çizgide takılmasın: "07/" -> "07" yerine "0".
    final deleting = v.text.length < old.text.length;
    var text = formatExpiry(v.text);
    if (deleting && text.endsWith('/')) {
      text = text.substring(0, text.length - 1);
    }
    return _collapsed(text);
  }
}

class CvcFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue v) {
    final d = digitsOf(v.text);
    return _collapsed(d.length > 4 ? d.substring(0, 4) : d);
  }
}

/// Ay (1-12) ve dört haneli yıl; çözülemezse `null`.
({int month, int year})? parseExpiry(String raw) {
  final d = digitsOf(raw);
  if (d.length != 4) return null;
  final month = int.parse(d.substring(0, 2));
  final year = 2000 + int.parse(d.substring(2));
  if (month < 1 || month > 12) return null;
  return (month: month, year: year);
}

/// Yerel kart doğrulaması (sunucu aynı kontrolleri yineler). Hatasız ise
/// boş harita döner.
Map<CardField, CardError> validateCard({
  required String holderName,
  required String number,
  required String expiry,
  required String cvc,
  required DateTime now,
}) {
  final errors = <CardField, CardError>{};
  final holder = holderName.trim();
  if (holder.length < 3 || !holder.contains(RegExp(r'\s+\S'))) {
    errors[CardField.holderName] = CardError.holderInvalid;
  }
  final n = digitsOf(number);
  if ((n.length != 15 && n.length != 16) || !passesLuhn(n)) {
    errors[CardField.number] = CardError.numberInvalid;
  }
  final exp = parseExpiry(expiry);
  if (exp == null) {
    errors[CardField.expiry] = CardError.expiryInvalid;
  } else if (exp.year < now.year ||
      (exp.year == now.year && exp.month < now.month)) {
    errors[CardField.expiry] = CardError.expiryPast;
  }
  final c = digitsOf(cvc);
  if (c.length < 3 || c.length > 4) {
    errors[CardField.cvc] = CardError.cvcInvalid;
  }
  return errors;
}

/// Yalnız yerelde (debug) görünen test kartı.
const String kTestCardHolder = 'Test Kullanici';
const String kTestCardNumber = '5258 6400 0000 0001';
const String kTestCardExpiry = '07/44';
const String kTestCardCvc = '000';
