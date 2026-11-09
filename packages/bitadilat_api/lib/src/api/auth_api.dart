import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../core/auth_interceptor.dart';
import '../core/token_store.dart';
import '../models/auth_response.dart';
import '../models/requests.dart';

/// `/auth/*` uç noktaları. Başarılı giriş, kayıt ve yenilemede token'ları
/// `TokenStore`a yazar.
class AuthApi {
  AuthApi(this._dio, this._store);

  final Dio _dio;
  final TokenStore _store;

  static final Options _open = Options(extra: {skipAuthKey: true});

  Future<AuthResponse> register(RegisterRequest body) =>
      _tokens('register', body.toJson());

  Future<AuthResponse> login(LoginRequest body) =>
      _tokens('login', body.toJson());

  Future<AuthResponse> refresh(String refreshToken) =>
      _tokens('refresh', RefreshRequest(refreshToken: refreshToken).toJson());

  /// Sunucuda refresh ailesini iptal eder; yerel token'ları her durumda siler.
  Future<void> logout(String refreshToken) async {
    try {
      await guardApi(
        () => _dio.post<void>(
          '${ApiConfig.prefix}/auth/logout',
          data: RefreshRequest(refreshToken: refreshToken).toJson(),
          options: _open,
        ),
      );
    } finally {
      await _store.clear();
    }
  }

  Future<void> forgotPassword(String email) => guardApi(
    () => _dio.post<void>(
      '${ApiConfig.prefix}/auth/password/forgot',
      data: ForgotPasswordRequest(email: email).toJson(),
      options: _open,
    ),
  );

  Future<void> resetPassword(ResetPasswordRequest body) => guardApi(
    () => _dio.post<void>(
      '${ApiConfig.prefix}/auth/password/reset',
      data: body.toJson(),
      options: _open,
    ),
  );

  Future<AuthResponse> _tokens(String path, Map<String, dynamic> body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '${ApiConfig.prefix}/auth/$path',
        data: body,
        options: _open,
      ),
    );
    final auth = AuthResponse.fromJson(res.data!);
    await _store.write(
      TokenPair(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      ),
    );
    return auth;
  }
}
