import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'media_ref.dart';
import 'money.dart';
import 'offers.dart';
import 'pro.dart';

part 'jobs.freezed.dart';
part 'jobs.g.dart';

/// Karşı taraf: müşteri ustanın işletme adını, usta müşteriyi "Ali Y." görür.
@freezed
abstract class JobCounterpart with _$JobCounterpart {
  const factory JobCounterpart({
    @JsonKey(fromJson: idFromJson) required String id,
    required String displayName,
  }) = _JobCounterpart;

  factory JobCounterpart.fromJson(Map<String, dynamic> json) =>
      _$JobCounterpartFromJson(json);
}

@freezed
abstract class JobSummary with _$JobSummary {
  const factory JobSummary({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String requestId,
    required String title,
    @JsonKey(fromJson: idFromJson) required String categoryId,
    required JobStatus status,
    required PartyRole viewerRole,
    required JobCounterpart counterpart,
    @MoneyConverter() required Money totalAmount,
    DateTime? scheduledFrom,
    DateTime? scheduledTo,
    required DateTime updatedAt,
    @Default(0) int unreadMessages,
  }) = _JobSummary;

  factory JobSummary.fromJson(Map<String, dynamic> json) =>
      _$JobSummaryFromJson(json);
}

/// İş adresi: iş açılınca iki taraf da tam satırı görür.
@freezed
abstract class JobAddress with _$JobAddress {
  const factory JobAddress({
    required String districtName,
    required String neighborhood,
    String? lineFull,
    String? doorNote,
  }) = _JobAddress;

  factory JobAddress.fromJson(Map<String, dynamic> json) =>
      _$JobAddressFromJson(json);
}

/// Bekleyen randevu önerisi (en fazla bir tane).
@freezed
abstract class AppointmentProposal with _$AppointmentProposal {
  const factory AppointmentProposal({
    @JsonKey(fromJson: idFromJson) required String id,
    required PartyRole proposedBy,
    required DateTime slotFrom,
    required DateTime slotTo,
    required DateTime createdAt,
  }) = _AppointmentProposal;

  factory AppointmentProposal.fromJson(Map<String, dynamic> json) =>
      _$AppointmentProposalFromJson(json);
}

@freezed
abstract class JobAppointment with _$JobAppointment {
  const factory JobAppointment({
    DateTime? scheduledFrom,
    DateTime? scheduledTo,
    AppointmentProposal? pendingProposal,
  }) = _JobAppointment;

  factory JobAppointment.fromJson(Map<String, dynamic> json) =>
      _$JobAppointmentFromJson(json);
}

@freezed
abstract class JobEvent with _$JobEvent {
  const factory JobEvent({
    @JsonKey(fromJson: idFromJson) required String id,
    required JobEventType type,
    JobStatus? fromStatus,
    JobStatus? toStatus,
    String? note,
    MediaRef? photo,
    required ActorRole actorRole,
    required DateTime createdAt,
  }) = _JobEvent;

  factory JobEvent.fromJson(Map<String, dynamic> json) =>
      _$JobEventFromJson(json);
}

/// İşin ödeme özeti. `serviceFee` ve `netEarning` yalnız ustaya dolu gelir.
@freezed
abstract class JobPayment with _$JobPayment {
  const factory JobPayment({
    required String ref,
    required EscrowStatus status,
    @MoneyConverter() required Money totalAmount,
    @MoneyConverter() @Default(Money.zero) Money refundedAmount,
    @NullableMoneyConverter() Money? serviceFee,
    @NullableMoneyConverter() Money? netEarning,
  }) = _JobPayment;

  factory JobPayment.fromJson(Map<String, dynamic> json) =>
      _$JobPaymentFromJson(json);
}

@freezed
abstract class ComplaintRef with _$ComplaintRef {
  const factory ComplaintRef({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required ComplaintStatus status,
  }) = _ComplaintRef;

  factory ComplaintRef.fromJson(Map<String, dynamic> json) =>
      _$ComplaintRefFromJson(json);
}

@freezed
abstract class JobDetail with _$JobDetail {
  const JobDetail._();

  const factory JobDetail({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String requestId,
    required String title,
    @JsonKey(fromJson: idFromJson) required String categoryId,
    required JobStatus status,
    required PartyRole viewerRole,
    required JobCounterpart counterpart,
    @MoneyConverter() required Money totalAmount,
    DateTime? scheduledFrom,
    DateTime? scheduledTo,
    required DateTime updatedAt,
    @Default(0) int unreadMessages,
    required OfferDetail offer,
    required JobAddress address,
    required JobAppointment appointment,
    @Default(<JobEvent>[]) List<JobEvent> timeline,
    required JobPayment payment,
    DateTime? autoCompleteAt,
    ReviewItem? review,
    ComplaintRef? complaint,
    @Default(<String>[]) List<String> allowedActions,
  }) = _JobDetail;

  factory JobDetail.fromJson(Map<String, dynamic> json) =>
      _$JobDetailFromJson(json);

  /// Bu bakan için eylem açık mı? (Bilinmeyen eylemler yok sayılır.)
  bool can(JobAction action) => allowedActions.contains(action.wire);

  JobSummary get summary => JobSummary(
    id: id,
    publicCode: publicCode,
    requestId: requestId,
    title: title,
    categoryId: categoryId,
    status: status,
    viewerRole: viewerRole,
    counterpart: counterpart,
    totalAmount: totalAmount,
    scheduledFrom: scheduledFrom,
    scheduledTo: scheduledTo,
    updatedAt: updatedAt,
    unreadMessages: unreadMessages,
  );
}

// --- İstek gövdeleri ---------------------------------------------------------

@freezed
abstract class ProposeSlotRequest with _$ProposeSlotRequest {
  const factory ProposeSlotRequest({
    required DateTime slotFrom,
    required DateTime slotTo,
  }) = _ProposeSlotRequest;

  factory ProposeSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$ProposeSlotRequestFromJson(json);
}

@freezed
abstract class FinishJobRequest with _$FinishJobRequest {
  const factory FinishJobRequest({
    required String note,
    @JsonKey(toJson: idListToJson, fromJson: idListFromJson)
    @Default(<String>[])
    List<String> photoIds,
  }) = _FinishJobRequest;

  factory FinishJobRequest.fromJson(Map<String, dynamic> json) =>
      _$FinishJobRequestFromJson(json);
}

/// `POST /jobs/{id}/events`: not ya da fotoğraftan en az biri.
@freezed
abstract class JobNoteRequest with _$JobNoteRequest {
  const factory JobNoteRequest({
    @JsonKey(includeIfNull: false) String? note,
    @JsonKey(toJson: idListToJson, fromJson: idListFromJson)
    @Default(<String>[])
    List<String> photoIds,
  }) = _JobNoteRequest;

  factory JobNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$JobNoteRequestFromJson(json);
}

/// `reason` metin olarak gider (müşteri ve usta listeleri farklıdır):
/// [CustomerCancelReason] ya da [ProCancelReason] değerinin `wire`ı.
@freezed
abstract class CancelJobRequest with _$CancelJobRequest {
  const factory CancelJobRequest({
    required String reason,
    @JsonKey(includeIfNull: false) String? note,
  }) = _CancelJobRequest;

  factory CancelJobRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelJobRequestFromJson(json);
}

@freezed
abstract class ReviewRequest with _$ReviewRequest {
  const factory ReviewRequest({
    required int rating,
    @Default(<ReviewTag>[]) List<ReviewTag> tags,
    @Default('') String comment,
    @Default(false) bool anonymous,
  }) = _ReviewRequest;

  factory ReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestFromJson(json);
}

@freezed
abstract class ComplaintRequest with _$ComplaintRequest {
  const factory ComplaintRequest({
    required ComplaintReason reason,
    required String description,
    @JsonKey(toJson: idListToJson, fromJson: idListFromJson)
    @Default(<String>[])
    List<String> evidenceIds,
  }) = _ComplaintRequest;

  factory ComplaintRequest.fromJson(Map<String, dynamic> json) =>
      _$ComplaintRequestFromJson(json);
}

/// Şikayet kaydı.
@freezed
abstract class Complaint with _$Complaint {
  const factory Complaint({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String jobId,
    required ComplaintReason reason,
    required String description,
    @Default(<MediaRef>[]) List<MediaRef> evidence,
    required ComplaintStatus status,
    String? decision,
    String? decisionNote,
    required DateTime createdAt,
    DateTime? decidedAt,
  }) = _Complaint;

  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);
}
