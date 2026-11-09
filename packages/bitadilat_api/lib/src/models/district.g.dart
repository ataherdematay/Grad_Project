// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'district.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_District _$DistrictFromJson(Map<String, dynamic> json) => _District(
  id: idFromJson(json['id']),
  name: json['name'] as String,
  side: json['side'] as String,
);

Map<String, dynamic> _$DistrictToJson(_District instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'side': instance.side,
};
