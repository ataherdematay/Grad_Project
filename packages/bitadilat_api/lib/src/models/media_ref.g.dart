// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaRef _$MediaRefFromJson(Map<String, dynamic> json) => _MediaRef(
  id: idFromJson(json['id']),
  url: json['url'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$MediaRefToJson(_MediaRef instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'expiresAt': instance.expiresAt.toIso8601String(),
};

_UploadedMedia _$UploadedMediaFromJson(Map<String, dynamic> json) =>
    _UploadedMedia(
      id: idFromJson(json['id']),
      contentType: json['contentType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UploadedMediaToJson(_UploadedMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contentType': instance.contentType,
      'sizeBytes': instance.sizeBytes,
      'width': instance.width,
      'height': instance.height,
    };
