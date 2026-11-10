import 'package:json_annotation/json_annotation.dart';

/// `tradeCert` -> `TRADE_CERT` (sorgu parametreleri ve gövdeler için).
extension EnumWire on Enum {
  String get wire => name
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m.group(0)}')
      .toUpperCase();
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
enum MediaPurpose {
  requestPhoto,
  proDocument,
  avatar,
  jobPhoto,
  chat,
  complaint,
}

// --- Dalga 3: iş, ödeme, sohbet, şikayet -----------------------------------

/// İş durumu (STATE_MACHINES §4).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum JobStatus {
  awaitingAppointment,
  scheduled,
  arrived,
  inProgress,
  workFinished,
  completed,
  disputed,
  cancelled,
  resolved,
}

/// İşin tarafı: bakan kişinin rolü, öneriyi yapan, mesajı gönderen.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PartyRole { customer, pro }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ActorRole { customer, pro, system, admin }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum JobEventType {
  statusChanged,
  note,
  photo,
  appointmentProposed,
  appointmentAccepted,
}

/// `JobDetail.allowedActions` değerleri. İstemci düğmeleri yalnız bundan çizer.
enum JobAction {
  proposeSlot,
  acceptProposal,
  markArrived,
  startWork,
  finishWork,
  addNote,
  confirmCompletion,
  cancel,
  complain,
  review,
  chat,
}

/// Emanet (güvence havuzu) durumu.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum EscrowStatus {
  initialized,
  locked,
  failed,
  refundedToCustomer,
  releasedToPro,
  disputed,
  splitSettled,
}

/// `PaymentResult.errorCode`. Bilinmeyen kod `unknown` olur.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PaymentErrorCode {
  paymentDeclined,
  requestAlreadyAssigned,
  offerExpired,
  resultUncertain,
  @JsonValue('UNKNOWN')
  unknown,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum CustomerCancelReason {
  plansChanged,
  solved,
  proUnreachable,
  otherProvider,
  other,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ProCancelReason { scheduleConflict, cannotDoJob, customerUnreachable, other }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ComplaintReason {
  noShow,
  incompleteWork,
  extraCharge,
  rudeBehaviour,
  other,
}

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ComplaintStatus { open, inReview, resolved, dismissed }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReviewTag { onTime, cleanWork, fairPrice, goodCommunication, polite }

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum EarningStatus { pending, released, refunded, split }
