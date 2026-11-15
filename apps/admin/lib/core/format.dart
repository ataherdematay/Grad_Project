import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:intl/intl.dart';

/// `₺2.450` (TR), `₺2,450` (EN); kuruş varsa `₺1.225,50`. Her zaman `intl`.
String formatMoney(Money m, String locale) {
  final f = NumberFormat.currency(
    locale: locale,
    symbol: '₺',
    decimalDigits: m.isWhole ? 0 : 2,
  );
  return f.format(m.cents / 100);
}

/// "14 Kasım" ya da yıl farklıysa "14 Kasım 2025".
String formatDate(DateTime utc, String locale, DateTime now) {
  final d = utc.toLocal();
  return d.year == now.toLocal().year
      ? DateFormat('d MMMM', locale).format(d)
      : DateFormat('d MMMM y', locale).format(d);
}

/// "14 Kasım, 14:00".
String formatDateTime(DateTime utc, String locale, DateTime now) =>
    '${formatDate(utc, locale, now)}, ${DateFormat('HH:mm').format(utc.toLocal())}';
