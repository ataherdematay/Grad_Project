import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/enums.dart';
import '../models/offers.dart';
import '../models/paged.dart';
import '../models/pro.dart';

/// Usta tarafı: `/pro/*`. Başvuru uç noktaları dışında `APPROVED` ister.
class ProApi {
  ProApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/pro';

  Future<ProApplication> submitApplication(ApplicationInput body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/application',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => ProApplication.fromJson(res.data!));
  }

  Future<ProApplication> application() async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/application'),
    );
    return decodeApi(() => ProApplication.fromJson(res.data!));
  }

  Future<ProProfile> profile() async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/profile'),
    );
    return decodeApi(() => ProProfile.fromJson(res.data!));
  }

  Future<ProProfile> updateProfile(ProProfileInput body) async {
    final res = await guardApi(
      () =>
          _dio.put<Map<String, dynamic>>('$_base/profile', data: body.toJson()),
    );
    return decodeApi(() => ProProfile.fromJson(res.data!));
  }

  Future<ProProfile> setAvailability(ProAvailability value) async {
    final res = await guardApi(
      () => _dio.put<Map<String, dynamic>>(
        '$_base/availability',
        data: {'availability': value.wire},
      ),
    );
    return decodeApi(() => ProProfile.fromJson(res.data!));
  }

  /// `limit` verilmezse sunucu varsayılanı (20) uygulanır.
  Future<FeedPage> feed({
    RequestUrgency? urgency,
    String? cursor,
    int? limit,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_base/feed',
        queryParameters: {
          if (urgency != null) 'urgency': urgency.wire,
          'cursor': ?cursor,
          'limit': ?limit,
        },
      ),
    );
    return decodeApi(() => FeedPage.fromJson(res.data!));
  }

  Future<ProRequestDetail> request(String id) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/requests/$id'),
    );
    return decodeApi(() => ProRequestDetail.fromJson(res.data!));
  }

  /// Aynı `idempotencyKey` aynı yanıtı döndürür (çift basışa karşı).
  Future<OfferDetail> createOffer(
    String requestId,
    CreateOfferRequest body, {
    required String idempotencyKey,
  }) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/requests/$requestId/offers',
        data: body.toJson(),
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      ),
    );
    return decodeApi(() => OfferDetail.fromJson(res.data!));
  }

  Future<Paged<ProOfferItem>> offers({
    OfferStatus? status,
    String? cursor,
    int? limit,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_base/offers',
        queryParameters: {
          if (status != null) 'status': status.wire,
          'cursor': ?cursor,
          'limit': ?limit,
        },
      ),
    );
    return decodeApi(() => Paged.fromJson(res.data!, ProOfferItem.fromJson));
  }

  Future<OfferDetail> withdraw(String offerId) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>('$_base/offers/$offerId/withdraw'),
    );
    return decodeApi(() => OfferDetail.fromJson(res.data!));
  }

  /// Teklif detayı (usta kendi teklifini `GET /offers/{id}` ile de açabilir).
  Future<OfferDetail> offer(String offerId) async {
    final res = await guardApi(
      () =>
          _dio.get<Map<String, dynamic>>('${ApiConfig.prefix}/offers/$offerId'),
    );
    return decodeApi(() => OfferDetail.fromJson(res.data!));
  }
}
