import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../core/auth_interceptor.dart';
import '../models/enums.dart';
import '../models/media_ref.dart';

/// `POST /media` (multipart).
class MediaApi {
  MediaApi(this._dio);

  final Dio _dio;

  /// Dosyayı yükler. `onProgress(gönderilen, toplam)` yükleme ilerlemesini verir.
  /// Yetki yenilemesinde gövde baştan kurulur (multipart bir kez okunur).
  Future<UploadedMedia> upload({
    required Uint8List bytes,
    required String filename,
    required MediaPurpose purpose,
    String? contentType,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    FormData build() => FormData.fromMap({
      'purpose': purpose.wire,
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: contentType == null ? null : DioMediaType.parse(contentType),
      ),
    });
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '${ApiConfig.prefix}/media',
        data: build(),
        cancelToken: cancelToken,
        onSendProgress: onProgress,
        options: Options(extra: {rebuildBodyKey: build}),
      ),
    );
    return decodeApi(() => UploadedMedia.fromJson(res.data!));
  }
}
