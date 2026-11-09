import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

bool isValidEmail(String v) => _emailRe.hasMatch(v.trim());

/// Yalnız rakamlar.
String digitsOf(String v) => v.replaceAll(RegExp(r'\D'), '');

/// `+90`, `90` ve baştaki `0` atılır; en fazla 10 hane döner.
String nationalPhoneDigits(String raw) {
  var d = digitsOf(raw);
  if (d.length >= 11 && d.startsWith('90')) {
    d = d.substring(2);
  } else if (d.startsWith('0')) {
    d = d.substring(1);
  }
  return d.length > 10 ? d.substring(0, 10) : d;
}

/// TR cep numarası: 5 ile başlayan 10 hane.
bool isValidTrMobile(String raw) {
  final d = nationalPhoneDigits(raw);
  return d.length == 10 && d.startsWith('5');
}

/// `+905XXXXXXXXX` biçimi.
String normalizePhone(String raw) => '+90${nationalPhoneDigits(raw)}';

/// `5XX XXX XX XX` maskesi.
String formatTrPhone(String raw) {
  final d = nationalPhoneDigits(raw);
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i == 3 || i == 6 || i == 8) b.write(' ');
    b.write(d[i]);
  }
  return b.toString();
}

class TrPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = formatTrPhone(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Giriş alanı: e-posta ya da telefon. Telefon `+90…` olarak normalleşir.
bool isValidIdentifier(String v) {
  final t = v.trim();
  return t.contains('@') ? isValidEmail(t) : isValidTrMobile(t);
}

String normalizeIdentifier(String v) {
  final t = v.trim();
  return t.contains('@') ? t : normalizePhone(t);
}

bool isStrongPassword(String v) =>
    v.length >= 8 &&
    RegExp(r'\p{L}', unicode: true).hasMatch(v) &&
    RegExp(r'\d').hasMatch(v);

/// Form doğrulayıcıları (yerelleştirilmiş).
class Validators {
  Validators(this.l);

  final AppLocalizations l;

  String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? l.errRequired : null;

  String? identifier(String? v) {
    if (v == null || v.trim().isEmpty) return l.errRequired;
    return isValidIdentifier(v) ? null : l.errIdentifierInvalid;
  }

  String? email(String? v) {
    if (v == null || v.trim().isEmpty) return l.errRequired;
    return isValidEmail(v) ? null : l.errEmailInvalid;
  }

  String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return l.errRequired;
    return isValidTrMobile(v) ? null : l.errPhoneInvalid;
  }

  String? fullName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return l.errRequired;
    return (t.length >= 3 && t.contains(RegExp(r'\s+\S')))
        ? null
        : l.errNameInvalid;
  }

  /// Girişte yalnız doluluk; kayıtta `newPassword` kullanılır.
  String? password(String? v) =>
      (v == null || v.isEmpty) ? l.errRequired : null;

  String? newPassword(String? v) {
    if (v == null || v.isEmpty) return l.errRequired;
    if (v.length < 8) return l.errPasswordShort;
    return isStrongPassword(v) ? null : l.errPasswordWeak;
  }

  String? code(String? v) {
    if (v == null || v.trim().isEmpty) return l.errRequired;
    return RegExp(r'^\d{6}$').hasMatch(v.trim()) ? null : l.errCodeInvalid;
  }
}
