import 'package:freezed_annotation/freezed_annotation.dart';

import 'json_helpers.dart';

part 'media_ref.freezed.dart';
part 'media_ref.g.dart';

/// İmzalı kısa ömürlü adres (10 dk); `Image.network` ile doğrudan açılır.
@freezed
abstract class MediaRef with _$MediaRef {
  const factory MediaRef({
    @JsonKey(fromJson: idFromJson) required String id,
    required String url,
    required DateTime expiresAt,
  }) = _MediaRef;

  factory MediaRef.fromJson(Map<String, dynamic> json) =>
      _$MediaRefFromJson(json);
}

/// `POST /media` yanıtı.
@freezed
abstract class UploadedMedia with _$UploadedMedia {
  const factory UploadedMedia({
    @JsonKey(fromJson: idFromJson) required String id,
    required String contentType,
    required int sizeBytes,
    int? width,
    int? height,
  }) = _UploadedMedia;

  factory UploadedMedia.fromJson(Map<String, dynamic> json) =>
      _$UploadedMediaFromJson(json);
}
