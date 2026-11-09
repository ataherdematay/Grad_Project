import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'money.dart';

part 'offers.freezed.dart';
part 'offers.g.dart';

/// Teklifi veren usta özeti.
@freezed
abstract class ProCard with _$ProCard {
  const factory ProCard({
    @JsonKey(fromJson: idFromJson) required String id,
    required String businessName,
    required String fullName,
    required double ratingAvg,
    required int ratingCount,
    required int completedJobs,
    required bool verified,
  }) = _ProCard;

  factory ProCard.fromJson(Map<String, dynamic> json) =>
      _$ProCardFromJson(json);
}

@freezed
abstract class OfferItem with _$OfferItem {
  const factory OfferItem({
    required OfferItemKind kind,
    required String description,
    required num quantity,
    @MoneyConverter() required Money unitPrice,
    @MoneyConverter() required Money lineTotal,
  }) = _OfferItem;

  factory OfferItem.fromJson(Map<String, dynamic> json) =>
      _$OfferItemFromJson(json);
}

@freezed
abstract class OfferSummary with _$OfferSummary {
  const factory OfferSummary({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String requestId,
    required OfferStatus status,
    required ProCard pro,
    @MoneyConverter() required Money laborAmount,
    @MoneyConverter() required Money materialsAmount,
    @MoneyConverter() required Money totalAmount,
    required DateTime arrivalFrom,
    required DateTime arrivalTo,
    required int warrantyMonths,
    String? note,
    required DateTime validUntil,
    required DateTime createdAt,
  }) = _OfferSummary;

  factory OfferSummary.fromJson(Map<String, dynamic> json) =>
      _$OfferSummaryFromJson(json);
}

/// `OfferSummary` alanları + döküm. `serviceFee` ve `netEarning` yalnız teklifi
/// veren ustaya dolu gelir; müşteride `null`.
@freezed
abstract class OfferDetail with _$OfferDetail {
  const OfferDetail._();

  const factory OfferDetail({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String requestId,
    required OfferStatus status,
    required ProCard pro,
    @MoneyConverter() required Money laborAmount,
    @MoneyConverter() required Money materialsAmount,
    @MoneyConverter() required Money totalAmount,
    required DateTime arrivalFrom,
    required DateTime arrivalTo,
    required int warrantyMonths,
    String? note,
    required DateTime validUntil,
    required DateTime createdAt,
    @Default(<OfferItem>[]) List<OfferItem> items,
    @NullableMoneyConverter() Money? serviceFee,
    @NullableMoneyConverter() Money? netEarning,
    String? declineReason,
  }) = _OfferDetail;

  factory OfferDetail.fromJson(Map<String, dynamic> json) =>
      _$OfferDetailFromJson(json);

  OfferSummary get summary => OfferSummary(
    id: id,
    publicCode: publicCode,
    requestId: requestId,
    status: status,
    pro: pro,
    laborAmount: laborAmount,
    materialsAmount: materialsAmount,
    totalAmount: totalAmount,
    arrivalFrom: arrivalFrom,
    arrivalTo: arrivalTo,
    warrantyMonths: warrantyMonths,
    note: note,
    validUntil: validUntil,
    createdAt: createdAt,
  );
}

/// `GET /requests/{id}/offers` yanıtı.
@freezed
abstract class OfferList with _$OfferList {
  const factory OfferList({
    required List<OfferSummary> items,
    @Default(0) int declinedCount,
  }) = _OfferList;

  factory OfferList.fromJson(Map<String, dynamic> json) =>
      _$OfferListFromJson(json);
}

/// `GET /pro/offers` satırındaki talep özeti.
@freezed
abstract class OfferRequestRef with _$OfferRequestRef {
  const factory OfferRequestRef({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required String title,
    required String districtName,
  }) = _OfferRequestRef;

  factory OfferRequestRef.fromJson(Map<String, dynamic> json) =>
      _$OfferRequestRefFromJson(json);
}

/// `GET /pro/offers` satırı: `OfferSummary` + `request`.
class ProOfferItem {
  const ProOfferItem({required this.offer, required this.request});

  factory ProOfferItem.fromJson(Map<String, dynamic> json) => ProOfferItem(
    offer: OfferSummary.fromJson(json),
    request: OfferRequestRef.fromJson(json['request'] as Map<String, dynamic>),
  );

  final OfferSummary offer;
  final OfferRequestRef request;

  Map<String, dynamic> toJson() => {
    ...offer.toJson(),
    'request': request.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is ProOfferItem && other.offer == offer && other.request == request;

  @override
  int get hashCode => Object.hash(offer, request);
}

// --- İstek gövdeleri ---------------------------------------------------------

@freezed
abstract class OfferItemInput with _$OfferItemInput {
  const factory OfferItemInput({
    required OfferItemKind kind,
    required String description,
    required num quantity,
    @MoneyConverter() required Money unitPrice,
  }) = _OfferItemInput;

  factory OfferItemInput.fromJson(Map<String, dynamic> json) =>
      _$OfferItemInputFromJson(json);
}

@freezed
abstract class CreateOfferRequest with _$CreateOfferRequest {
  const factory CreateOfferRequest({
    @MoneyConverter() required Money laborAmount,
    @MoneyConverter() required Money materialsAmount,
    required DateTime arrivalFrom,
    required DateTime arrivalTo,
    required int warrantyMonths,
    @Default('') String note,
    @Default(<OfferItemInput>[]) List<OfferItemInput> items,
  }) = _CreateOfferRequest;

  factory CreateOfferRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOfferRequestFromJson(json);
}

@freezed
abstract class DeclineOfferRequest with _$DeclineOfferRequest {
  const factory DeclineOfferRequest({
    required DeclineReason reason,
    @JsonKey(includeIfNull: false) String? note,
    required bool keepRequestOpen,
  }) = _DeclineOfferRequest;

  factory DeclineOfferRequest.fromJson(Map<String, dynamic> json) =>
      _$DeclineOfferRequestFromJson(json);
}
