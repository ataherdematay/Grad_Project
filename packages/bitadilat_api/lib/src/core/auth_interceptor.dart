import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_error.dart';
import 'token_store.dart';

/// İstek `extra` anahtarı: Bearer eklenmez ve 401'de yenileme denenmez.
const String skipAuthKey = 'skipAuth';

const String _retriedKey = 'authRetried';

/// Bearer ekler; `401 TOKEN_EXPIRED` gelince tek bir refresh çağrısı yapar,
/// paralel 401'ler aynı refresh'i bekler, başarıda isteği bir kez tekrarlar.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStore,
    required this.config,
  }) : _refreshDio = Dio(BaseOptions(baseUrl: config.baseUrl))
         ..httpClientAdapter = dio.httpClientAdapter;

  /// Ana istemci; tekrar istekleri buradan geçer.
  final Dio dio;
  final TokenStore tokenStore;
  final ApiConfig config;
  final Dio _refreshDio;
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Future<_RefreshResult>? _refreshing;

  /// Refresh başarısız olup token'lar silinince olay verir.
  Stream<void> get sessionExpired => _expired.stream;

  Future<void> dispose() => _expired.close();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] != true) {
      final tokens = await tokenStore.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        options.extra[skipAuthKey] == true ||
        options.extra[_retriedKey] == true ||
        _codeOf(err.response?.data) != ApiErrorCode.tokenExpired) {
      return handler.next(err);
    }

    final current = await tokenStore.read();
    if (current == null) return handler.next(err);

    // İstek eski token ile gittiyse ve token bu arada yenilendiyse
    // yeni refresh gerekmez; doğrudan tekrar et.
    final usedHeader = options.headers['Authorization'];
    final alreadyRefreshed =
        usedHeader is String && usedHeader != 'Bearer ${current.accessToken}';

    if (!alreadyRefreshed) {
      final result = await (_refreshing ??= _refresh(current.refreshToken)
          .whenComplete(() => _refreshing = null));
      if (result == _RefreshResult.failed) return handler.next(err);
      if (result == _RefreshResult.networkError) return handler.next(err);
    }

    try {
      options.extra[_retriedKey] = true;
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<_RefreshResult> _refresh(String refreshToken) async {
    try {
      final res = await _refreshDio.post<dynamic>(
        '${ApiConfig.prefix}/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {skipAuthKey: true}),
      );
      final data = _asMap(res.data);
      final access = data?['accessToken'];
      final refresh = data?['refreshToken'];
      if (access is String && refresh is String) {
        await tokenStore.write(
          TokenPair(accessToken: access, refreshToken: refresh),
        );
        return _RefreshResult.ok;
      }
      await _expire();
      return _RefreshResult.failed;
    } on DioException catch (e) {
      if (e.response == null) return _RefreshResult.networkError;
      await _expire();
      return _RefreshResult.failed;
    }
  }

  Future<void> _expire() async {
    await tokenStore.clear();
    if (!_expired.isClosed) _expired.add(null);
  }

  static ApiErrorCode _codeOf(Object? body) =>
      ApiErrorCode.parse(_asMap(body)?['code']);

  static Map<dynamic, dynamic>? _asMap(Object? body) {
    if (body is Map) return body;
    if (body is String) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) return decoded;
      } on FormatException {
        return null;
      }
    }
    return null;
  }
}

enum _RefreshResult { ok, failed, networkError }
