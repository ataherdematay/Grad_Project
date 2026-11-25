import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/paged.dart';
import 'payment_demo_models.dart';

/// Ödeme demosu müşteri/usta uçları (salt okunur).
class PaymentDemoApi {
  PaymentDemoApi(this._dio);

  final Dio _dio;

  static const _prefix = ApiConfig.prefix;

  /// Müşteri, usta ve yönetici; ödeme kaydı yoksa 404.
  Future<PaymentTimeline> timeline(String jobId) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_prefix/jobs/$jobId/payment/timeline',
      ),
    );
    return decodeApi(() => PaymentTimeline.fromJson(res.data!));
  }

  /// Müşteri ve yönetici; usta 403.
  Future<PaymentReceipt> receipt(String jobId) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_prefix/jobs/$jobId/payment/receipt',
      ),
    );
    return decodeApi(() => PaymentReceipt.fromJson(res.data!));
  }

  /// Müşterinin ödeme geçmişi, yeniden eskiye.
  Future<Paged<PaymentHistoryItem>> myPayments({
    String? cursor,
    int? limit,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_prefix/me/payments',
        queryParameters: {'cursor': ?cursor, 'limit': ?limit},
      ),
    );
    return decodeApi(
      () => Paged.fromJson(res.data!, PaymentHistoryItem.fromJson),
    );
  }
}

/// [ApiClient]e ödeme demosu uçlarını ekler (mevcut sınıf değişmez).
extension PaymentDemoApiClient on ApiClient {
  PaymentDemoApi get paymentDemo => PaymentDemoApi(dio);
}
