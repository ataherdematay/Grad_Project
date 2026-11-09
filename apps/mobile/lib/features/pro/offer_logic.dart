import 'package:bitadilat_api/bitadilat_api.dart';

/// Hizmet bedeli oranı (%10, GLOSSARY).
const int kServiceFeePercent = 10;

/// Sözleşme sınırları: varış aralığı 1-12 saat, en geç 14 gün sonra.
const Duration kMinArrivalWindow = Duration(hours: 1);
const Duration kMaxArrivalWindow = Duration(hours: 12);
const Duration kMaxArrivalLead = Duration(days: 14);
const List<int> kWarrantyChoices = [0, 3, 6, 12];
const int kNoteMax = 500;

/// Metin tutarını kuruşa çevirir. TR: `1.250,50`; EN: `1,250.50`. Geçersizse
/// `null`.
///
/// Binlik ayırıcı yalnız doğru gruplamada (`1.250`, `1.250.000`) kabul edilir.
/// Diğer ayırıcıyla yazılmış kuruş (TR klavyede `1250.50`, EN'de `1250,50`)
/// ondalık sayılır; aksi hâlde tutar sessizce 100 katına çıkardı.
Money? parseMoney(String raw, String locale) {
  final s = raw.trim().replaceAll(RegExp(r'[\s₺]'), '');
  if (s.isEmpty) return null;
  final tr = locale == 'tr';
  final group = RegExp.escape(tr ? '.' : ',');
  final dec = RegExp.escape(tr ? ',' : '.');
  final grouped = RegExp('^\\d{1,3}($group\\d{3})+($dec\\d{1,2})?\$');
  final plain = RegExp('^\\d+($dec\\d{1,2})?\$');
  final otherDecimal = RegExp('^\\d+$group\\d{1,2}\$');
  final String normalized;
  if (grouped.hasMatch(s) || plain.hasMatch(s)) {
    normalized = s
        .replaceAll(tr ? '.' : ',', '')
        .replaceAll(tr ? ',' : '.', '.');
  } else if (otherDecimal.hasMatch(s)) {
    normalized = s.replaceAll(tr ? '.' : ',', '.');
  } else {
    return null;
  }
  return Money.fromJson(normalized);
}

class OfferLine {
  const OfferLine({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final int quantity;
  final Money unitPrice;

  Money get total => unitPrice.times(quantity);
}

/// Teklif toplamları (canlı özet).
class OfferTotals {
  const OfferTotals({required this.labor, required this.materials});

  factory OfferTotals.of(Money labor, Iterable<OfferLine> lines) => OfferTotals(
    labor: labor,
    materials: lines.fold(Money.zero, (a, l) => a + l.total),
  );

  final Money labor;
  final Money materials;

  Money get total => labor + materials;

  /// Hizmet bedeli: toplamın %10'u.
  Money get serviceFee => total.percent(kServiceFeePercent);

  Money get net => total - serviceFee;
}

enum ArrivalIssue { missing, past, tooShort, tooLong, tooFar }

/// Varış aralığı doğrulaması (saf işlev).
ArrivalIssue? validateArrival(DateTime? from, DateTime? to, DateTime now) {
  if (from == null || to == null) return ArrivalIssue.missing;
  if (!from.isAfter(now)) return ArrivalIssue.past;
  if (from.isAfter(now.add(kMaxArrivalLead))) return ArrivalIssue.tooFar;
  final len = to.difference(from);
  if (len < kMinArrivalWindow) return ArrivalIssue.tooShort;
  if (len > kMaxArrivalWindow) return ArrivalIssue.tooLong;
  return null;
}
