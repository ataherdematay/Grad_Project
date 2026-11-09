import 'package:dio/dio.dart';

import '../api/auth_api.dart';
import '../api/catalog_api.dart';
import '../api/me_api.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import 'token_store.dart';

/// Dio, kimlik doğrulama araya girenini ve API sınıflarını bir arada tutar.
class ApiClient {
  ApiClient({
    required this.config,
    required this.tokenStore,
    HttpClientAdapter? adapter,
    Dio? dio,
  }) : dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      headers: {'Accept': 'application/json'},
    );
    if (adapter != null) this.dio.httpClientAdapter = adapter;
    _auth = AuthInterceptor(
      dio: this.dio,
      tokenStore: tokenStore,
      config: config,
    );
    this.dio.interceptors.add(_auth);
    auth = AuthApi(this.dio, tokenStore);
    me = MeApi(this.dio);
    catalog = CatalogApi(this.dio);
  }

  final ApiConfig config;
  final TokenStore tokenStore;
  final Dio dio;
  late final AuthInterceptor _auth;
  late final AuthApi auth;
  late final MeApi me;
  late final CatalogApi catalog;

  /// Oturum yenilenemeyince (token'lar silindikten sonra) olay verir.
  Stream<void> get sessionExpired => _auth.sessionExpired;

  Future<void> dispose() async {
    await _auth.dispose();
    dio.close();
  }
}
