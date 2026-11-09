// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: idFromJson(json['id']),
  nameTr: json['nameTr'] as String,
  nameEn: json['nameEn'] as String,
  icon: json['icon'] as String,
  colorHex: json['colorHex'] as String,
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'nameTr': instance.nameTr,
  'nameEn': instance.nameEn,
  'icon': instance.icon,
  'colorHex': instance.colorHex,
  'sortOrder': instance.sortOrder,
};
