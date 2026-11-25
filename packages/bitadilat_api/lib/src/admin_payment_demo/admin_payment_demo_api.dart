import '../core/api_client.dart';
import '../core/api_config.dart';
import '../core/api_error.dart';
import 'admin_payment_demo_models.dart';

/// Admin ödeme demosu uçları. `AdminApi` yerine istemciye eklenir
/// (`client.adminPaymentVaultSummary()`).
extension AdminPaymentDemoApi on ApiClient {
  /// `GET /admin/payments/summary`.
  Future<AdminVaultSummary> adminPaymentVaultSummary() async {
    final res = await guardApi(
      () => dio.get<Map<String, dynamic>>(
        '${ApiConfig.prefix}/admin/payments/summary',
      ),
    );
    return decodeApi(() => AdminVaultSummary.fromJson(res.data!));
  }

  /// `GET /admin/payments/{ref}/timeline`.
  Future<AdminPaymentTimeline> adminPaymentTimeline(String ref) async {
    final res = await guardApi(
      () => dio.get<Map<String, dynamic>>(
        '${ApiConfig.prefix}/admin/payments/${Uri.encodeComponent(ref)}/timeline',
      ),
    );
    return decodeApi(() => AdminPaymentTimeline.fromJson(res.data!));
  }
}
