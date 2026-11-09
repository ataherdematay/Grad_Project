// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedItem _$FeedItemFromJson(Map<String, dynamic> json) => _FeedItem(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  title: json['title'] as String,
  categoryId: idFromJson(json['categoryId']),
  urgency: $enumDecode(_$RequestUrgencyEnumMap, json['urgency']),
  districtName: json['districtName'] as String,
  neighborhood: json['neighborhood'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  preferredFrom: json['preferredFrom'] == null
      ? null
      : DateTime.parse(json['preferredFrom'] as String),
  preferredTo: json['preferredTo'] == null
      ? null
      : DateTime.parse(json['preferredTo'] as String),
  photoCount: (json['photoCount'] as num?)?.toInt() ?? 0,
  offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
  myOfferId: idFromJsonNullable(json['myOfferId']),
);

Map<String, dynamic> _$FeedItemToJson(_FeedItem instance) => <String, dynamic>{
  'id': instance.id,
  'publicCode': instance.publicCode,
  'title': instance.title,
  'categoryId': instance.categoryId,
  'urgency': _$RequestUrgencyEnumMap[instance.urgency]!,
  'districtName': instance.districtName,
  'neighborhood': instance.neighborhood,
  'createdAt': instance.createdAt.toIso8601String(),
  'preferredFrom': instance.preferredFrom?.toIso8601String(),
  'preferredTo': instance.preferredTo?.toIso8601String(),
  'photoCount': instance.photoCount,
  'offerCount': instance.offerCount,
  'myOfferId': instance.myOfferId,
};

const _$RequestUrgencyEnumMap = {
  RequestUrgency.urgent: 'URGENT',
  RequestUrgency.planned: 'PLANNED',
};

_FeedPage _$FeedPageFromJson(Map<String, dynamic> json) => _FeedPage(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FeedItem>[],
  onBreak: json['onBreak'] as bool? ?? false,
);

Map<String, dynamic> _$FeedPageToJson(_FeedPage instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'onBreak': instance.onBreak,
};

_ProRequestDetail _$ProRequestDetailFromJson(Map<String, dynamic> json) =>
    _ProRequestDetail(
      id: idFromJson(json['id']),
      publicCode: json['publicCode'] as String,
      title: json['title'] as String,
      categoryId: idFromJson(json['categoryId']),
      urgency: $enumDecode(_$RequestUrgencyEnumMap, json['urgency']),
      districtName: json['districtName'] as String,
      neighborhood: json['neighborhood'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      preferredFrom: json['preferredFrom'] == null
          ? null
          : DateTime.parse(json['preferredFrom'] as String),
      preferredTo: json['preferredTo'] == null
          ? null
          : DateTime.parse(json['preferredTo'] as String),
      photoCount: (json['photoCount'] as num?)?.toInt() ?? 0,
      offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
      myOfferId: idFromJsonNullable(json['myOfferId']),
      description: json['description'] as String,
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => MediaRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MediaRef>[],
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((e) => RequestAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RequestAnswer>[],
      myOffer: json['myOffer'] == null
          ? null
          : OfferDetail.fromJson(json['myOffer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProRequestDetailToJson(_ProRequestDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'urgency': _$RequestUrgencyEnumMap[instance.urgency]!,
      'districtName': instance.districtName,
      'neighborhood': instance.neighborhood,
      'createdAt': instance.createdAt.toIso8601String(),
      'preferredFrom': instance.preferredFrom?.toIso8601String(),
      'preferredTo': instance.preferredTo?.toIso8601String(),
      'photoCount': instance.photoCount,
      'offerCount': instance.offerCount,
      'myOfferId': instance.myOfferId,
      'description': instance.description,
      'photos': instance.photos.map((e) => e.toJson()).toList(),
      'answers': instance.answers.map((e) => e.toJson()).toList(),
      'myOffer': instance.myOffer?.toJson(),
    };

_ApplicationDocument _$ApplicationDocumentFromJson(Map<String, dynamic> json) =>
    _ApplicationDocument(
      id: idFromJson(json['id']),
      type: $enumDecode(_$ProDocumentTypeEnumMap, json['type']),
      status: $enumDecode(_$DocumentStatusEnumMap, json['status']),
      media: MediaRef.fromJson(json['media'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ApplicationDocumentToJson(
  _ApplicationDocument instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$ProDocumentTypeEnumMap[instance.type]!,
  'status': _$DocumentStatusEnumMap[instance.status]!,
  'media': instance.media.toJson(),
};

const _$ProDocumentTypeEnumMap = {
  ProDocumentType.identity: 'IDENTITY',
  ProDocumentType.tradeCert: 'TRADE_CERT',
  ProDocumentType.tax: 'TAX',
  ProDocumentType.criminalRecord: 'CRIMINAL_RECORD',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.pending: 'PENDING',
  DocumentStatus.accepted: 'ACCEPTED',
  DocumentStatus.rejected: 'REJECTED',
};

_ProApplication _$ProApplicationFromJson(Map<String, dynamic> json) =>
    _ProApplication(
      reviewStatus: $enumDecode(_$ReviewStatusEnumMap, json['reviewStatus']),
      reviewNote: json['reviewNote'] as String?,
      businessName: json['businessName'] as String,
      bio: json['bio'] as String? ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      categoryIds: json['categoryIds'] == null
          ? const <String>[]
          : idListFromJson(json['categoryIds']),
      districtIds: json['districtIds'] == null
          ? const <String>[]
          : idListFromJson(json['districtIds']),
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map(
                (e) => ApplicationDocument.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ApplicationDocument>[],
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
    );

Map<String, dynamic> _$ProApplicationToJson(_ProApplication instance) =>
    <String, dynamic>{
      'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
      'reviewNote': instance.reviewNote,
      'businessName': instance.businessName,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'categoryIds': idListToJson(instance.categoryIds),
      'districtIds': idListToJson(instance.districtIds),
      'documents': instance.documents.map((e) => e.toJson()).toList(),
      'submittedAt': instance.submittedAt?.toIso8601String(),
    };

const _$ReviewStatusEnumMap = {
  ReviewStatus.pendingReview: 'PENDING_REVIEW',
  ReviewStatus.needsDocuments: 'NEEDS_DOCUMENTS',
  ReviewStatus.approved: 'APPROVED',
  ReviewStatus.rejected: 'REJECTED',
  ReviewStatus.suspended: 'SUSPENDED',
};

_DocumentInput _$DocumentInputFromJson(Map<String, dynamic> json) =>
    _DocumentInput(
      type: $enumDecode(_$ProDocumentTypeEnumMap, json['type']),
      mediaId: idFromJson(json['mediaId']),
    );

Map<String, dynamic> _$DocumentInputToJson(_DocumentInput instance) =>
    <String, dynamic>{
      'type': _$ProDocumentTypeEnumMap[instance.type]!,
      'mediaId': wireId(instance.mediaId),
    };

_ApplicationInput _$ApplicationInputFromJson(Map<String, dynamic> json) =>
    _ApplicationInput(
      businessName: json['businessName'] as String,
      bio: json['bio'] as String? ?? '',
      experienceYears: (json['experienceYears'] as num).toInt(),
      categoryIds: idListFromJson(json['categoryIds']),
      districtIds: idListFromJson(json['districtIds']),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => DocumentInput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApplicationInputToJson(_ApplicationInput instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'categoryIds': idListToJson(instance.categoryIds),
      'districtIds': idListToJson(instance.districtIds),
      'documents': instance.documents.map((e) => e.toJson()).toList(),
    };

_WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) =>
    _WorkingHours(
      weekday: (json['weekday'] as num).toInt(),
      start: json['start'] as String,
      end: json['end'] as String,
      acceptsUrgent: json['acceptsUrgent'] as bool? ?? false,
    );

Map<String, dynamic> _$WorkingHoursToJson(_WorkingHours instance) =>
    <String, dynamic>{
      'weekday': instance.weekday,
      'start': instance.start,
      'end': instance.end,
      'acceptsUrgent': instance.acceptsUrgent,
    };

_ProProfile _$ProProfileFromJson(Map<String, dynamic> json) => _ProProfile(
  businessName: json['businessName'] as String,
  bio: json['bio'] as String? ?? '',
  experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
  categoryIds: json['categoryIds'] == null
      ? const <String>[]
      : idListFromJson(json['categoryIds']),
  districtIds: json['districtIds'] == null
      ? const <String>[]
      : idListFromJson(json['districtIds']),
  workingHours:
      (json['workingHours'] as List<dynamic>?)
          ?.map((e) => WorkingHours.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WorkingHours>[],
  reviewStatus: $enumDecode(_$ReviewStatusEnumMap, json['reviewStatus']),
  availability: $enumDecode(_$ProAvailabilityEnumMap, json['availability']),
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProProfileToJson(_ProProfile instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'categoryIds': idListToJson(instance.categoryIds),
      'districtIds': idListToJson(instance.districtIds),
      'workingHours': instance.workingHours.map((e) => e.toJson()).toList(),
      'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
      'availability': _$ProAvailabilityEnumMap[instance.availability]!,
      'ratingAvg': instance.ratingAvg,
      'ratingCount': instance.ratingCount,
      'completedJobs': instance.completedJobs,
    };

const _$ProAvailabilityEnumMap = {
  ProAvailability.active: 'ACTIVE',
  ProAvailability.onBreak: 'ON_BREAK',
};

_ProProfileInput _$ProProfileInputFromJson(Map<String, dynamic> json) =>
    _ProProfileInput(
      businessName: json['businessName'] as String,
      bio: json['bio'] as String? ?? '',
      experienceYears: (json['experienceYears'] as num).toInt(),
      categoryIds: idListFromJson(json['categoryIds']),
      districtIds: idListFromJson(json['districtIds']),
      workingHours: (json['workingHours'] as List<dynamic>)
          .map((e) => WorkingHours.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProProfileInputToJson(_ProProfileInput instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'categoryIds': idListToJson(instance.categoryIds),
      'districtIds': idListToJson(instance.districtIds),
      'workingHours': instance.workingHours.map((e) => e.toJson()).toList(),
    };

_DistrictRef _$DistrictRefFromJson(Map<String, dynamic> json) =>
    _DistrictRef(id: idFromJson(json['id']), name: json['name'] as String);

Map<String, dynamic> _$DistrictRefToJson(_DistrictRef instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_ProPublicProfile _$ProPublicProfileFromJson(Map<String, dynamic> json) =>
    _ProPublicProfile(
      id: idFromJson(json['id']),
      businessName: json['businessName'] as String,
      fullName: json['fullName'] as String,
      bio: json['bio'] as String?,
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
      memberSince: json['memberSince'] == null
          ? null
          : DateTime.parse(json['memberSince'] as String),
      categoryIds: json['categoryIds'] == null
          ? const <String>[]
          : idListFromJson(json['categoryIds']),
      districts:
          (json['districts'] as List<dynamic>?)
              ?.map((e) => DistrictRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DistrictRef>[],
      verifiedDocuments:
          (json['verifiedDocuments'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ProDocumentTypeEnumMap, e))
              .toList() ??
          const <ProDocumentType>[],
    );

Map<String, dynamic> _$ProPublicProfileToJson(_ProPublicProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessName': instance.businessName,
      'fullName': instance.fullName,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'ratingAvg': instance.ratingAvg,
      'ratingCount': instance.ratingCount,
      'completedJobs': instance.completedJobs,
      'memberSince': instance.memberSince?.toIso8601String(),
      'categoryIds': idListToJson(instance.categoryIds),
      'districts': instance.districts.map((e) => e.toJson()).toList(),
      'verifiedDocuments': instance.verifiedDocuments
          .map((e) => _$ProDocumentTypeEnumMap[e]!)
          .toList(),
    };

_ReviewItem _$ReviewItemFromJson(Map<String, dynamic> json) => _ReviewItem(
  id: idFromJson(json['id']),
  rating: (json['rating'] as num).toInt(),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  comment: json['comment'] as String?,
  authorDisplay: json['authorDisplay'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewItemToJson(_ReviewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'tags': instance.tags,
      'comment': instance.comment,
      'authorDisplay': instance.authorDisplay,
      'createdAt': instance.createdAt.toIso8601String(),
    };
