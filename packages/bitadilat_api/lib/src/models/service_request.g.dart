// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestAnswer _$RequestAnswerFromJson(Map<String, dynamic> json) =>
    _RequestAnswer(
      questionKey: json['questionKey'] as String,
      answer: json['answer'] as String,
    );

Map<String, dynamic> _$RequestAnswerToJson(_RequestAnswer instance) =>
    <String, dynamic>{
      'questionKey': instance.questionKey,
      'answer': instance.answer,
    };

_RequestAddress _$RequestAddressFromJson(Map<String, dynamic> json) =>
    _RequestAddress(
      districtName: json['districtName'] as String,
      neighborhood: json['neighborhood'] as String,
      lineFull: json['lineFull'] as String?,
      doorNote: json['doorNote'] as String?,
    );

Map<String, dynamic> _$RequestAddressToJson(_RequestAddress instance) =>
    <String, dynamic>{
      'districtName': instance.districtName,
      'neighborhood': instance.neighborhood,
      'lineFull': instance.lineFull,
      'doorNote': instance.doorNote,
    };

_RequestSummary _$RequestSummaryFromJson(
  Map<String, dynamic> json,
) => _RequestSummary(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  title: json['title'] as String,
  categoryId: idFromJson(json['categoryId']),
  urgency: $enumDecode(_$RequestUrgencyEnumMap, json['urgency']),
  status: $enumDecode(_$RequestStatusEnumMap, json['status']),
  districtName: json['districtName'] as String,
  neighborhood: json['neighborhood'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
  minOfferTotal: const NullableMoneyConverter().fromJson(json['minOfferTotal']),
  maxOfferTotal: const NullableMoneyConverter().fromJson(json['maxOfferTotal']),
);

Map<String, dynamic> _$RequestSummaryToJson(_RequestSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'urgency': _$RequestUrgencyEnumMap[instance.urgency]!,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'districtName': instance.districtName,
      'neighborhood': instance.neighborhood,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'offerCount': instance.offerCount,
      'minOfferTotal': const NullableMoneyConverter().toJson(
        instance.minOfferTotal,
      ),
      'maxOfferTotal': const NullableMoneyConverter().toJson(
        instance.maxOfferTotal,
      ),
    };

const _$RequestUrgencyEnumMap = {
  RequestUrgency.urgent: 'URGENT',
  RequestUrgency.planned: 'PLANNED',
};

const _$RequestStatusEnumMap = {
  RequestStatus.open: 'OPEN',
  RequestStatus.assigned: 'ASSIGNED',
  RequestStatus.cancelled: 'CANCELLED',
  RequestStatus.expired: 'EXPIRED',
};

_RequestDetail _$RequestDetailFromJson(
  Map<String, dynamic> json,
) => _RequestDetail(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  title: json['title'] as String,
  categoryId: idFromJson(json['categoryId']),
  urgency: $enumDecode(_$RequestUrgencyEnumMap, json['urgency']),
  status: $enumDecode(_$RequestStatusEnumMap, json['status']),
  districtName: json['districtName'] as String,
  neighborhood: json['neighborhood'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  offerCount: (json['offerCount'] as num?)?.toInt() ?? 0,
  minOfferTotal: const NullableMoneyConverter().fromJson(json['minOfferTotal']),
  maxOfferTotal: const NullableMoneyConverter().fromJson(json['maxOfferTotal']),
  description: json['description'] as String,
  preferredFrom: json['preferredFrom'] == null
      ? null
      : DateTime.parse(json['preferredFrom'] as String),
  preferredTo: json['preferredTo'] == null
      ? null
      : DateTime.parse(json['preferredTo'] as String),
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
  matchedProCount: (json['matchedProCount'] as num?)?.toInt() ?? 0,
  matchFactors:
      (json['matchFactors'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$MatchFactorEnumMap, e))
          .toList() ??
      const <MatchFactor>[],
  address: json['address'] == null
      ? null
      : RequestAddress.fromJson(json['address'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RequestDetailToJson(_RequestDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'urgency': _$RequestUrgencyEnumMap[instance.urgency]!,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'districtName': instance.districtName,
      'neighborhood': instance.neighborhood,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'offerCount': instance.offerCount,
      'minOfferTotal': const NullableMoneyConverter().toJson(
        instance.minOfferTotal,
      ),
      'maxOfferTotal': const NullableMoneyConverter().toJson(
        instance.maxOfferTotal,
      ),
      'description': instance.description,
      'preferredFrom': instance.preferredFrom?.toIso8601String(),
      'preferredTo': instance.preferredTo?.toIso8601String(),
      'photos': instance.photos.map((e) => e.toJson()).toList(),
      'answers': instance.answers.map((e) => e.toJson()).toList(),
      'matchedProCount': instance.matchedProCount,
      'matchFactors': instance.matchFactors
          .map((e) => _$MatchFactorEnumMap[e]!)
          .toList(),
      'address': instance.address?.toJson(),
    };

const _$MatchFactorEnumMap = {
  MatchFactor.category: 'CATEGORY',
  MatchFactor.district: 'DISTRICT',
  MatchFactor.availability: 'AVAILABILITY',
};

_RequestInput _$RequestInputFromJson(Map<String, dynamic> json) =>
    _RequestInput(
      categoryId: idFromJson(json['categoryId']),
      urgency: $enumDecode(_$RequestUrgencyEnumMap, json['urgency']),
      preferredFrom: json['preferredFrom'] == null
          ? null
          : DateTime.parse(json['preferredFrom'] as String),
      preferredTo: json['preferredTo'] == null
          ? null
          : DateTime.parse(json['preferredTo'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      addressId: idFromJson(json['addressId']),
      photoIds: json['photoIds'] == null
          ? const <String>[]
          : idListFromJson(json['photoIds']),
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((e) => RequestAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RequestAnswer>[],
    );

Map<String, dynamic> _$RequestInputToJson(_RequestInput instance) =>
    <String, dynamic>{
      'categoryId': wireId(instance.categoryId),
      'urgency': _$RequestUrgencyEnumMap[instance.urgency]!,
      'preferredFrom': instance.preferredFrom?.toIso8601String(),
      'preferredTo': instance.preferredTo?.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'addressId': wireId(instance.addressId),
      'photoIds': idListToJson(instance.photoIds),
      'answers': instance.answers.map((e) => e.toJson()).toList(),
    };

_CancelRequestInput _$CancelRequestInputFromJson(Map<String, dynamic> json) =>
    _CancelRequestInput(
      reason: $enumDecode(_$RequestCancelReasonEnumMap, json['reason']),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CancelRequestInputToJson(_CancelRequestInput instance) =>
    <String, dynamic>{
      'reason': _$RequestCancelReasonEnumMap[instance.reason]!,
      'note': ?instance.note,
    };

const _$RequestCancelReasonEnumMap = {
  RequestCancelReason.plansChanged: 'PLANS_CHANGED',
  RequestCancelReason.solved: 'SOLVED',
  RequestCancelReason.noSuitableOffer: 'NO_SUITABLE_OFFER',
  RequestCancelReason.other: 'OTHER',
};

_QuestionOption _$QuestionOptionFromJson(Map<String, dynamic> json) =>
    _QuestionOption(
      value: json['value'] as String,
      labelTr: json['labelTr'] as String,
      labelEn: json['labelEn'] as String,
    );

Map<String, dynamic> _$QuestionOptionToJson(_QuestionOption instance) =>
    <String, dynamic>{
      'value': instance.value,
      'labelTr': instance.labelTr,
      'labelEn': instance.labelEn,
    };

_Question _$QuestionFromJson(Map<String, dynamic> json) => _Question(
  key: json['key'] as String,
  labelTr: json['labelTr'] as String,
  labelEn: json['labelEn'] as String,
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <QuestionOption>[],
);

Map<String, dynamic> _$QuestionToJson(_Question instance) => <String, dynamic>{
  'key': instance.key,
  'labelTr': instance.labelTr,
  'labelEn': instance.labelEn,
  'options': instance.options.map((e) => e.toJson()).toList(),
};
