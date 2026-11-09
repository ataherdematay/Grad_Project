import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/enums.dart';
import '../models/money.dart';
import '../models/offers.dart';
import '../models/paged.dart';
import '../models/service_request.dart';

/// Müşteri tarafı talepler: `/requests`.
class RequestsApi {
  RequestsApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/requests';

  Future<RequestDetail> create(
    RequestInput body, {
    String? idempotencyKey,
  }) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        _base,
        data: body.toJson(),
        options: idempotencyKey == null
            ? null
            : Options(headers: {'Idempotency-Key': idempotencyKey}),
      ),
    );
    return decodeApi(() => RequestDetail.fromJson(res.data!));
  }

  /// `scope`: `active` ya da `past`.
  Future<Paged<RequestSummary>> list({
    required String scope,
    String? cursor,
    int? limit,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {'scope': scope, 'cursor': ?cursor, 'limit': ?limit},
      ),
    );
    return decodeApi(() => Paged.fromJson(res.data!, RequestSummary.fromJson));
  }

  Future<RequestDetail> get(String id) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/$id'),
    );
    return decodeApi(() => RequestDetail.fromJson(res.data!));
  }

  Future<RequestDetail> update(String id, RequestInput body) async {
    final res = await guardApi(
      () => _dio.patch<Map<String, dynamic>>('$_base/$id', data: body.toJson()),
    );
    return decodeApi(() => RequestDetail.fromJson(res.data!));
  }

  Future<RequestDetail> cancel(String id, CancelRequestInput body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/$id/cancel',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => RequestDetail.fromJson(res.data!));
  }

  /// Sıralama ve filtre sorguya gider: `sort`, `maxPrice`, `minRating`.
  Future<OfferList> offers(
    String id, {
    OfferSort sort = OfferSort.recommended,
    Money? maxPrice,
    double? minRating,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_base/$id/offers',
        queryParameters: {
          'sort': sort.query,
          if (maxPrice != null) 'maxPrice': _plain(maxPrice),
          'minRating': ?minRating,
        },
      ),
    );
    return decodeApi(() => OfferList.fromJson(res.data!));
  }

  static String _plain(Money m) =>
      m.isWhole ? '${m.lira}' : (m.cents / 100).toStringAsFixed(2);
}
