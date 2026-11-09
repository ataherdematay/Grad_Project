// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Me _$MeFromJson(Map<String, dynamic> json) => _Me(
  id: idFromJson(json['id']),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  locale: json['locale'] as String,
  lastMode: $enumDecode(_$UserModeEnumMap, json['lastMode']),
  isAdmin: json['isAdmin'] as bool,
  status: json['status'] as String,
  pro: json['pro'] == null
      ? null
      : ProSummary.fromJson(json['pro'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MeToJson(_Me instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phone': instance.phone,
  'locale': instance.locale,
  'lastMode': _$UserModeEnumMap[instance.lastMode]!,
  'isAdmin': instance.isAdmin,
  'status': instance.status,
  'pro': instance.pro?.toJson(),
};

const _$UserModeEnumMap = {UserMode.customer: 'CUSTOMER', UserMode.pro: 'PRO'};
