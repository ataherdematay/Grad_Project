// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProCard _$ProCardFromJson(Map<String, dynamic> json) => _ProCard(
  id: idFromJson(json['id']),
  businessName: json['businessName'] as String,
  fullName: json['fullName'] as String,
  ratingAvg: (json['ratingAvg'] as num).toDouble(),
  ratingCount: (json['ratingCount'] as num).toInt(),
  completedJobs: (json['completedJobs'] as num).toInt(),
  verified: json['verified'] as bool,
);

Map<String, dynamic> _$ProCardToJson(_ProCard instance) => <String, dynamic>{
  'id': instance.id,
  'businessName': instance.businessName,
  'fullName': instance.fullName,
  'ratingAvg': instance.ratingAvg,
  'ratingCount': instance.ratingCount,
  'completedJobs': instance.completedJobs,
  'verified': instance.verified,
};

_OfferItem _$OfferItemFromJson(Map<String, dynamic> json) => _OfferItem(
  kind: $enumDecode(_$OfferItemKindEnumMap, json['kind']),
  description: json['description'] as String,
  quantity: json['quantity'] as num,
  unitPrice: const MoneyConverter().fromJson(json['unitPrice']),
  lineTotal: const MoneyConverter().fromJson(json['lineTotal']),
);

Map<String, dynamic> _$OfferItemToJson(_OfferItem instance) =>
    <String, dynamic>{
      'kind': _$OfferItemKindEnumMap[instance.kind]!,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': const MoneyConverter().toJson(instance.unitPrice),
      'lineTotal': const MoneyConverter().toJson(instance.lineTotal),
    };

const _$OfferItemKindEnumMap = {
  OfferItemKind.labor: 'LABOR',
  OfferItemKind.material: 'MATERIAL',
};

_OfferSummary _$OfferSummaryFromJson(Map<String, dynamic> json) =>
    _OfferSummary(
      id: idFromJson(json['id']),
      publicCode: json['publicCode'] as String,
      requestId: idFromJson(json['requestId']),
      status: $enumDecode(_$OfferStatusEnumMap, json['status']),
      pro: ProCard.fromJson(json['pro'] as Map<String, dynamic>),
      laborAmount: const MoneyConverter().fromJson(json['laborAmount']),
      materialsAmount: const MoneyConverter().fromJson(json['materialsAmount']),
      totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
      arrivalFrom: DateTime.parse(json['arrivalFrom'] as String),
      arrivalTo: DateTime.parse(json['arrivalTo'] as String),
      warrantyMonths: (json['warrantyMonths'] as num).toInt(),
      note: json['note'] as String?,
      validUntil: DateTime.parse(json['validUntil'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OfferSummaryToJson(
  _OfferSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'publicCode': instance.publicCode,
  'requestId': instance.requestId,
  'status': _$OfferStatusEnumMap[instance.status]!,
  'pro': instance.pro.toJson(),
  'laborAmount': const MoneyConverter().toJson(instance.laborAmount),
  'materialsAmount': const MoneyConverter().toJson(instance.materialsAmount),
  'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
  'arrivalFrom': instance.arrivalFrom.toIso8601String(),
  'arrivalTo': instance.arrivalTo.toIso8601String(),
  'warrantyMonths': instance.warrantyMonths,
  'note': instance.note,
  'validUntil': instance.validUntil.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$OfferStatusEnumMap = {
  OfferStatus.pending: 'PENDING',
  OfferStatus.accepted: 'ACCEPTED',
  OfferStatus.declined: 'DECLINED',
  OfferStatus.withdrawn: 'WITHDRAWN',
  OfferStatus.superseded: 'SUPERSEDED',
  OfferStatus.expired: 'EXPIRED',
};

_OfferDetail _$OfferDetailFromJson(Map<String, dynamic> json) => _OfferDetail(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  requestId: idFromJson(json['requestId']),
  status: $enumDecode(_$OfferStatusEnumMap, json['status']),
  pro: ProCard.fromJson(json['pro'] as Map<String, dynamic>),
  laborAmount: const MoneyConverter().fromJson(json['laborAmount']),
  materialsAmount: const MoneyConverter().fromJson(json['materialsAmount']),
  totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
  arrivalFrom: DateTime.parse(json['arrivalFrom'] as String),
  arrivalTo: DateTime.parse(json['arrivalTo'] as String),
  warrantyMonths: (json['warrantyMonths'] as num).toInt(),
  note: json['note'] as String?,
  validUntil: DateTime.parse(json['validUntil'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OfferItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OfferItem>[],
  serviceFee: const NullableMoneyConverter().fromJson(json['serviceFee']),
  netEarning: const NullableMoneyConverter().fromJson(json['netEarning']),
  declineReason: json['declineReason'] as String?,
);

Map<String, dynamic> _$OfferDetailToJson(
  _OfferDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'publicCode': instance.publicCode,
  'requestId': instance.requestId,
  'status': _$OfferStatusEnumMap[instance.status]!,
  'pro': instance.pro.toJson(),
  'laborAmount': const MoneyConverter().toJson(instance.laborAmount),
  'materialsAmount': const MoneyConverter().toJson(instance.materialsAmount),
  'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
  'arrivalFrom': instance.arrivalFrom.toIso8601String(),
  'arrivalTo': instance.arrivalTo.toIso8601String(),
  'warrantyMonths': instance.warrantyMonths,
  'note': instance.note,
  'validUntil': instance.validUntil.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'items': instance.items.map((e) => e.toJson()).toList(),
  'serviceFee': const NullableMoneyConverter().toJson(instance.serviceFee),
  'netEarning': const NullableMoneyConverter().toJson(instance.netEarning),
  'declineReason': instance.declineReason,
};

_OfferList _$OfferListFromJson(Map<String, dynamic> json) => _OfferList(
  items: (json['items'] as List<dynamic>)
      .map((e) => OfferSummary.fromJson(e as Map<String, dynamic>))
      .toList(),
  declinedCount: (json['declinedCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OfferListToJson(_OfferList instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'declinedCount': instance.declinedCount,
    };

_OfferRequestRef _$OfferRequestRefFromJson(Map<String, dynamic> json) =>
    _OfferRequestRef(
      id: idFromJson(json['id']),
      publicCode: json['publicCode'] as String,
      title: json['title'] as String,
      districtName: json['districtName'] as String,
    );

Map<String, dynamic> _$OfferRequestRefToJson(_OfferRequestRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'title': instance.title,
      'districtName': instance.districtName,
    };

_OfferItemInput _$OfferItemInputFromJson(Map<String, dynamic> json) =>
    _OfferItemInput(
      kind: $enumDecode(_$OfferItemKindEnumMap, json['kind']),
      description: json['description'] as String,
      quantity: json['quantity'] as num,
      unitPrice: const MoneyConverter().fromJson(json['unitPrice']),
    );

Map<String, dynamic> _$OfferItemInputToJson(_OfferItemInput instance) =>
    <String, dynamic>{
      'kind': _$OfferItemKindEnumMap[instance.kind]!,
      'description': instance.description,
      'quantity': instance.quantity,
      'unitPrice': const MoneyConverter().toJson(instance.unitPrice),
    };

_CreateOfferRequest _$CreateOfferRequestFromJson(Map<String, dynamic> json) =>
    _CreateOfferRequest(
      laborAmount: const MoneyConverter().fromJson(json['laborAmount']),
      materialsAmount: const MoneyConverter().fromJson(json['materialsAmount']),
      arrivalFrom: DateTime.parse(json['arrivalFrom'] as String),
      arrivalTo: DateTime.parse(json['arrivalTo'] as String),
      warrantyMonths: (json['warrantyMonths'] as num).toInt(),
      note: json['note'] as String? ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => OfferItemInput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <OfferItemInput>[],
    );

Map<String, dynamic> _$CreateOfferRequestToJson(
  _CreateOfferRequest instance,
) => <String, dynamic>{
  'laborAmount': const MoneyConverter().toJson(instance.laborAmount),
  'materialsAmount': const MoneyConverter().toJson(instance.materialsAmount),
  'arrivalFrom': instance.arrivalFrom.toIso8601String(),
  'arrivalTo': instance.arrivalTo.toIso8601String(),
  'warrantyMonths': instance.warrantyMonths,
  'note': instance.note,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

_DeclineOfferRequest _$DeclineOfferRequestFromJson(Map<String, dynamic> json) =>
    _DeclineOfferRequest(
      reason: $enumDecode(_$DeclineReasonEnumMap, json['reason']),
      note: json['note'] as String?,
      keepRequestOpen: json['keepRequestOpen'] as bool,
    );

Map<String, dynamic> _$DeclineOfferRequestToJson(
  _DeclineOfferRequest instance,
) => <String, dynamic>{
  'reason': _$DeclineReasonEnumMap[instance.reason]!,
  'note': ?instance.note,
  'keepRequestOpen': instance.keepRequestOpen,
};

const _$DeclineReasonEnumMap = {
  DeclineReason.price: 'PRICE',
  DeclineReason.schedule: 'SCHEDULE',
  DeclineReason.otherOffer: 'OTHER_OFFER',
  DeclineReason.notNeeded: 'NOT_NEEDED',
  DeclineReason.other: 'OTHER',
};
