import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/paged.dart';
import '../models/pro.dart';

/// Herkese açık usta profili: `/pros`.
class ProsApi {
  ProsApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/pros';

  Future<ProPublicProfile> get(String id) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/$id'),
    );
    return decodeApi(() => ProPublicProfile.fromJson(res.data!));
  }

  Future<Paged<ReviewItem>> reviews(
    String id, {
    String? cursor,
    int? limit,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_base/$id/reviews',
        queryParameters: {'cursor': ?cursor, 'limit': ?limit},
      ),
    );
    return decodeApi(() => Paged.fromJson(res.data!, ReviewItem.fromJson));
  }
}
