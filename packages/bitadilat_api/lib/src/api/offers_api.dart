import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/offers.dart';

/// Müşteri tarafı teklifler: `/offers`.
class OffersApi {
  OffersApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/offers';

  Future<OfferDetail> get(String id) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/$id'),
    );
    return decodeApi(() => OfferDetail.fromJson(res.data!));
  }

  Future<OfferDetail> decline(String id, DeclineOfferRequest body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/$id/decline',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => OfferDetail.fromJson(res.data!));
  }
}
