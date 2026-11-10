import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/payments.dart';

/// Ödeme (uygulama kanalı): `/payments`.
class PaymentsApi {
  PaymentsApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/payments';

  /// 3-D Secure'u başlatır. Kart verisi yalnız bu çağrının gövdesinde gider;
  /// saklanmaz ve loglanmaz.
  Future<PaymentInit> init3ds(CardPaymentRequest body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_base/3ds/init',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => PaymentInit.fromJson(res.data!));
  }

  Future<PaymentResult> get(String ref) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_base/$ref'),
    );
    return decodeApi(() => PaymentResult.fromJson(res.data!));
  }
}
