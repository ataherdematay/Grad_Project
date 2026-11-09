import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// Testlerde sabitlenebilen "şimdi".
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// `₺2.450` (TR), `₺2,450` (EN); kuruş varsa `₺1.225,50`. Her zaman `intl`.
String formatMoney(Money m, String locale) {
  final f = NumberFormat.currency(
    locale: locale,
    symbol: '₺',
    decimalDigits: m.isWhole ? 0 : 2,
  );
  return f.format(m.cents / 100);
}

String _day(DateTime d, String locale) => locale == 'tr'
    ? DateFormat('d MMMM EEEE', locale).format(d)
    : DateFormat('EEEE d MMMM', locale).format(d);

String _hm(DateTime d) => DateFormat('HH:mm').format(d);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "Bugün" / "Yarın" ya da "14 Kasım Cuma".
String formatDay(AppLocalizations l, DateTime utc, DateTime now) {
  final d = utc.toLocal();
  final diff = _dateOnly(d).difference(_dateOnly(now.toLocal())).inDays;
  if (diff == 0) return l.dateToday;
  if (diff == 1) return l.dateTomorrow;
  return _day(d, l.localeName);
}

/// "Bugün, 14:00-16:00" ya da "14 Kasım Cuma, 14:00-16:00".
String formatWindow(
  AppLocalizations l,
  DateTime fromUtc,
  DateTime toUtc,
  DateTime now,
) {
  final from = fromUtc.toLocal();
  final to = toUtc.toLocal();
  final day = formatDay(l, fromUtc, now);
  if (_dateOnly(from) == _dateOnly(to)) {
    return '$day, ${_hm(from)}-${_hm(to)}';
  }
  return '$day ${_hm(from)} - ${formatDay(l, toUtc, now)} ${_hm(to)}';
}

/// Tek zaman damgası: "Bugün, 14:00".
String formatDayTime(AppLocalizations l, DateTime utc, DateTime now) =>
    '${formatDay(l, utc, now)}, ${_hm(utc.toLocal())}';

/// Yalnız tarih (göreli): bitiş tarihi gibi alanlar için.
String formatDateOnly(AppLocalizations l, DateTime utc, DateTime now) =>
    formatDay(l, utc, now);

/// "Ocak 2026" biçimi (üyelik tarihi gibi yıl gösteren yerler için dinamik).
String formatMonthYear(DateTime utc, String locale) =>
    DateFormat('MMMM y', locale).format(utc.toLocal());

String formatRating(double v, String locale) =>
    NumberFormat('0.0', locale).format(v);

extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
