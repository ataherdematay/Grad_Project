// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Notification _$NotificationFromJson(Map<String, dynamic> json) =>
    _Notification(
      id: idFromJson(json['id']),
      type: json['type'] as String,
      params: json['params'] == null
          ? const <String, dynamic>{}
          : _paramsFromJson(json['params']),
      targetRoute: json['targetRoute'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationToJson(_Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'params': instance.params,
      'targetRoute': instance.targetRoute,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
    };
