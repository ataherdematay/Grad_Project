import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'media_ref.dart';
import 'money.dart';

part 'service_request.freezed.dart';
part 'service_request.g.dart';

@freezed
abstract class RequestAnswer with _$RequestAnswer {
  const factory RequestAnswer({
    required String questionKey,
    required String answer,
  }) = _RequestAnswer;

  factory RequestAnswer.fromJson(Map<String, dynamic> json) =>
      _$RequestAnswerFromJson(json);
}

/// Talepteki adres. `lineFull` ve `doorNote` yalnız sahibine dolu gelir.
@freezed
abstract class RequestAddress with _$RequestAddress {
  const factory RequestAddress({
    required String districtName,
    required String neighborhood,
    String? lineFull,
    String? doorNote,
  }) = _RequestAddress;

  factory RequestAddress.fromJson(Map<String, dynamic> json) =>
      _$RequestAddressFromJson(json);
}

@freezed
abstract class RequestSummary with _$RequestSummary {
  const factory RequestSummary({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required String title,
    @JsonKey(fromJson: idFromJson) required String categoryId,
    required RequestUrgency urgency,
    required RequestStatus status,
    required String districtName,
    required String neighborhood,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(0) int offerCount,
    @NullableMoneyConverter() Money? minOfferTotal,
    @NullableMoneyConverter() Money? maxOfferTotal,
  }) = _RequestSummary;

  factory RequestSummary.fromJson(Map<String, dynamic> json) =>
      _$RequestSummaryFromJson(json);
}

/// `RequestSummary` alanları + ayrıntı.
@freezed
abstract class RequestDetail with _$RequestDetail {
  const RequestDetail._();

  const factory RequestDetail({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required String title,
    @JsonKey(fromJson: idFromJson) required String categoryId,
    required RequestUrgency urgency,
    required RequestStatus status,
    required String districtName,
    required String neighborhood,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(0) int offerCount,
    @NullableMoneyConverter() Money? minOfferTotal,
    @NullableMoneyConverter() Money? maxOfferTotal,
    required String description,
    DateTime? preferredFrom,
    DateTime? preferredTo,
    @Default(<MediaRef>[]) List<MediaRef> photos,
    @Default(<RequestAnswer>[]) List<RequestAnswer> answers,
    @Default(0) int matchedProCount,
    @Default(<MatchFactor>[]) List<MatchFactor> matchFactors,
    RequestAddress? address,
  }) = _RequestDetail;

  factory RequestDetail.fromJson(Map<String, dynamic> json) =>
      _$RequestDetailFromJson(json);

  RequestSummary get summary => RequestSummary(
    id: id,
    publicCode: publicCode,
    title: title,
    categoryId: categoryId,
    urgency: urgency,
    status: status,
    districtName: districtName,
    neighborhood: neighborhood,
    createdAt: createdAt,
    expiresAt: expiresAt,
    offerCount: offerCount,
    minOfferTotal: minOfferTotal,
    maxOfferTotal: maxOfferTotal,
  );
}

/// `POST /requests` ve `PATCH /requests/{id}` gövdesi.
@freezed
abstract class RequestInput with _$RequestInput {
  const factory RequestInput({
    @JsonKey(fromJson: idFromJson, toJson: wireId) required String categoryId,
    required RequestUrgency urgency,
    DateTime? preferredFrom,
    DateTime? preferredTo,
    required String title,
    required String description,
    @JsonKey(fromJson: idFromJson, toJson: wireId) required String addressId,
    @JsonKey(toJson: idListToJson, fromJson: idListFromJson)
    @Default(<String>[])
    List<String> photoIds,
    @Default(<RequestAnswer>[]) List<RequestAnswer> answers,
  }) = _RequestInput;

  factory RequestInput.fromJson(Map<String, dynamic> json) =>
      _$RequestInputFromJson(json);
}

@freezed
abstract class CancelRequestInput with _$CancelRequestInput {
  const factory CancelRequestInput({
    required RequestCancelReason reason,
    @JsonKey(includeIfNull: false) String? note,
  }) = _CancelRequestInput;

  factory CancelRequestInput.fromJson(Map<String, dynamic> json) =>
      _$CancelRequestInputFromJson(json);
}

// --- Katalog soruları --------------------------------------------------------

@freezed
abstract class QuestionOption with _$QuestionOption {
  const factory QuestionOption({
    required String value,
    required String labelTr,
    required String labelEn,
  }) = _QuestionOption;

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      _$QuestionOptionFromJson(json);
}

@freezed
abstract class Question with _$Question {
  const factory Question({
    required String key,
    required String labelTr,
    required String labelEn,
    @Default(<QuestionOption>[]) List<QuestionOption> options,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}
