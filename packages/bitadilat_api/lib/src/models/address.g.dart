// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  id: idFromJson(json['id']),
  label: json['label'] as String,
  districtId: idFromJson(json['districtId']),
  districtName: json['districtName'] as String,
  neighborhood: json['neighborhood'] as String,
  lineFull: json['lineFull'] as String,
  doorNote: json['doorNote'] as String?,
  isDefault: json['isDefault'] as bool,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'districtId': instance.districtId,
  'districtName': instance.districtName,
  'neighborhood': instance.neighborhood,
  'lineFull': instance.lineFull,
  'doorNote': instance.doorNote,
  'isDefault': instance.isDefault,
};

_AddressInput _$AddressInputFromJson(Map<String, dynamic> json) =>
    _AddressInput(
      label: json['label'] as String,
      districtId: idFromJson(json['districtId']),
      neighborhood: json['neighborhood'] as String,
      lineFull: json['lineFull'] as String,
      doorNote: json['doorNote'] as String?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$AddressInputToJson(_AddressInput instance) =>
    <String, dynamic>{
      'label': instance.label,
      'districtId': wireId(instance.districtId),
      'neighborhood': instance.neighborhood,
      'lineFull': instance.lineFull,
      'doorNote': ?instance.doorNote,
      'isDefault': ?instance.isDefault,
    };
