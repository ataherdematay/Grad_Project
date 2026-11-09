import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'media_ref.dart';
import 'offers.dart';
import 'service_request.dart';

part 'pro.freezed.dart';
part 'pro.g.dart';

// --- Akış ------------------------------------------------------------------

@freezed
abstract class FeedItem with _$FeedItem {
  const factory FeedItem({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required String title,
    @JsonKey(fromJson: idFromJson) required String categoryId,
    required RequestUrgency urgency,
    required String districtName,
    required String neighborhood,
    required DateTime createdAt,
    DateTime? preferredFrom,
    DateTime? preferredTo,
    @Default(0) int photoCount,
    @Default(0) int offerCount,
    @JsonKey(fromJson: idFromJsonNullable) String? myOfferId,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) =>
      _$FeedItemFromJson(json);
}

/// `GET /pro/feed` yanıtı. `onBreak` iken `items` boştur.
@freezed
abstract class FeedPage with _$FeedPage {
  const factory FeedPage({
    @Default(<FeedItem>[]) List<FeedItem> items,
    @Default(false) bool onBreak,
  }) = _FeedPage;

  factory FeedPage.fromJson(Map<String, dynamic> json) =>
      _$FeedPageFromJson(json);
}

/// `FeedItem` alanları + ayrıntı. Adres ilçe ve mahalleyle sınırlıdır.
@freezed
abstract class ProRequestDetail with _$ProRequestDetail {
  const factory ProRequestDetail({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required String title,
    @JsonKey(fromJson: idFromJson) required String categoryId,
    required RequestUrgency urgency,
    required String districtName,
    required String neighborhood,
    required DateTime createdAt,
    DateTime? preferredFrom,
    DateTime? preferredTo,
    @Default(0) int photoCount,
    @Default(0) int offerCount,
    @JsonKey(fromJson: idFromJsonNullable) String? myOfferId,
    required String description,
    @Default(<MediaRef>[]) List<MediaRef> photos,
    @Default(<RequestAnswer>[]) List<RequestAnswer> answers,
    OfferDetail? myOffer,
  }) = _ProRequestDetail;

  factory ProRequestDetail.fromJson(Map<String, dynamic> json) =>
      _$ProRequestDetailFromJson(json);
}

// --- Başvuru ---------------------------------------------------------------

@freezed
abstract class ApplicationDocument with _$ApplicationDocument {
  const factory ApplicationDocument({
    @JsonKey(fromJson: idFromJson) required String id,
    required ProDocumentType type,
    required DocumentStatus status,
    required MediaRef media,
  }) = _ApplicationDocument;

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) =>
      _$ApplicationDocumentFromJson(json);
}

@freezed
abstract class ProApplication with _$ProApplication {
  const factory ProApplication({
    required ReviewStatus reviewStatus,
    String? reviewNote,
    required String businessName,
    @Default('') String bio,
    @Default(0) int experienceYears,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> categoryIds,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> districtIds,
    @Default(<ApplicationDocument>[]) List<ApplicationDocument> documents,
    DateTime? submittedAt,
  }) = _ProApplication;

  factory ProApplication.fromJson(Map<String, dynamic> json) =>
      _$ProApplicationFromJson(json);
}

@freezed
abstract class DocumentInput with _$DocumentInput {
  const factory DocumentInput({
    required ProDocumentType type,
    @JsonKey(fromJson: idFromJson, toJson: wireId) required String mediaId,
  }) = _DocumentInput;

  factory DocumentInput.fromJson(Map<String, dynamic> json) =>
      _$DocumentInputFromJson(json);
}

@freezed
abstract class ApplicationInput with _$ApplicationInput {
  const factory ApplicationInput({
    required String businessName,
    @Default('') String bio,
    required int experienceYears,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    required List<String> categoryIds,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    required List<String> districtIds,
    required List<DocumentInput> documents,
  }) = _ApplicationInput;

  factory ApplicationInput.fromJson(Map<String, dynamic> json) =>
      _$ApplicationInputFromJson(json);
}

// --- Usta profili ------------------------------------------------------------

@freezed
abstract class WorkingHours with _$WorkingHours {
  const factory WorkingHours({
    /// 1 (pazartesi) - 7 (pazar).
    required int weekday,

    /// `HH:mm`.
    required String start,
    required String end,
    @Default(false) bool acceptsUrgent,
  }) = _WorkingHours;

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);
}

@freezed
abstract class ProProfile with _$ProProfile {
  const factory ProProfile({
    required String businessName,
    @Default('') String bio,
    @Default(0) int experienceYears,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> categoryIds,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> districtIds,
    @Default(<WorkingHours>[]) List<WorkingHours> workingHours,
    required ReviewStatus reviewStatus,
    required ProAvailability availability,
    @Default(0.0) double ratingAvg,
    @Default(0) int ratingCount,
    @Default(0) int completedJobs,
  }) = _ProProfile;

  factory ProProfile.fromJson(Map<String, dynamic> json) =>
      _$ProProfileFromJson(json);
}

@freezed
abstract class ProProfileInput with _$ProProfileInput {
  const factory ProProfileInput({
    required String businessName,
    @Default('') String bio,
    required int experienceYears,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    required List<String> categoryIds,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    required List<String> districtIds,
    required List<WorkingHours> workingHours,
  }) = _ProProfileInput;

  factory ProProfileInput.fromJson(Map<String, dynamic> json) =>
      _$ProProfileInputFromJson(json);
}

// --- Herkese açık usta profili ------------------------------------------------

@freezed
abstract class DistrictRef with _$DistrictRef {
  const factory DistrictRef({
    @JsonKey(fromJson: idFromJson) required String id,
    required String name,
  }) = _DistrictRef;

  factory DistrictRef.fromJson(Map<String, dynamic> json) =>
      _$DistrictRefFromJson(json);
}

@freezed
abstract class ProPublicProfile with _$ProPublicProfile {
  const factory ProPublicProfile({
    @JsonKey(fromJson: idFromJson) required String id,
    required String businessName,
    required String fullName,
    String? bio,
    @Default(0) int experienceYears,
    @Default(0.0) double ratingAvg,
    @Default(0) int ratingCount,
    @Default(0) int completedJobs,
    DateTime? memberSince,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> categoryIds,
    @Default(<DistrictRef>[]) List<DistrictRef> districts,
    @Default(<ProDocumentType>[]) List<ProDocumentType> verifiedDocuments,
  }) = _ProPublicProfile;

  factory ProPublicProfile.fromJson(Map<String, dynamic> json) =>
      _$ProPublicProfileFromJson(json);
}

@freezed
abstract class ReviewItem with _$ReviewItem {
  const factory ReviewItem({
    @JsonKey(fromJson: idFromJson) required String id,
    required int rating,
    @Default(<String>[]) List<String> tags,
    String? comment,
    required String authorDisplay,
    required DateTime createdAt,
  }) = _ReviewItem;

  factory ReviewItem.fromJson(Map<String, dynamic> json) =>
      _$ReviewItemFromJson(json);
}
