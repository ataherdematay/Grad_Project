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
Money? parseMoney(String raw, String locale) {
  var s = raw.trim().replaceAll(RegExp(r'[\s₺]'), '');
  if (s.isEmpty) return null;
  if (locale == 'tr') {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else {
    s = s.replaceAll(',', '');
  }
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(s)) return null;
  return Money.fromJson(s);
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
