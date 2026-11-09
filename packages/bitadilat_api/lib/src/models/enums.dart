import 'package:json_annotation/json_annotation.dart';

/// `tradeCert` -> `TRADE_CERT` (sorgu parametreleri ve gövdeler için).
extension EnumWire on Enum {
  String get wire => name.replaceAllMapped(
    RegExp('[A-Z]'),
    (m) => '_${m.group(0)}',
  ).toUpperCase();
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum UserMode { customer, pro }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReviewStatus {
  pendingReview,
  needsDocuments,
  approved,
  rejected,
  suspended,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ProAvailability { active, onBreak }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RequestUrgency { urgent, planned }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RequestStatus { open, assigned, cancelled, expired }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum MatchFactor { category, district, availability }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum RequestCancelReason { plansChanged, solved, noSuitableOffer, other }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OfferStatus { pending, accepted, declined, withdrawn, superseded, expired }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum OfferItemKind { labor, material }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DeclineReason { price, schedule, otherOffer, notNeeded, other }

/// `GET /requests/{id}/offers?sort=`: küçük harfle gider.
enum OfferSort {
  recommended,
  price,
  rating,
  arrival;

  String get query => name;
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ProDocumentType { identity, tradeCert, tax, criminalRecord }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum DocumentStatus { pending, accepted, rejected }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum MediaPurpose { requestPhoto, proDocument, avatar, jobPhoto, chat, complaint }
