import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_error.dart';
import 'token_store.dart';

/// İstek `extra` anahtarı: Bearer eklenmez ve 401'de yenileme denenmez.
/// `Options.extra` anahtarı: gövdeyi yeniden üreten işlev (multipart için).
const String rebuildBodyKey = 'rebuildBody';

const String skipAuthKey = 'skipAuth';

const String _retriedKey = 'authRetried';
const String _authHeader = 'Authorization';

/// Oturumun istemci tarafında kapanma nedeni.
enum SessionEndReason {
  /// Refresh token geçersiz ya da süresi dolmuş.
  expired,

  /// Sunucu `401 ACCOUNT_SUSPENDED` döndü.
  suspended,
}

/// Bearer ekler; `401 TOKEN_EXPIRED` gelince tek bir refresh çağrısı yapar.
///
/// - Paralel 401'ler aynı refresh'i bekler; refresh bittikten sonra gelen
///   (eski token'la gitmiş) 401'ler yeni refresh başlatmaz, doğrudan tekrarlanır.
/// - Refresh sürerken başlayan istekler refresh bitene kadar bekletilir.
/// - Refresh isteği ayrı, araya gireni olmayan bir Dio ile gider (döngü yok).
/// - Token'lar yalnız sunucu refresh token'ı reddederse (400/401/403) silinir;
///   ağ hatası, 429 ve 5xx geçicidir, oturum korunur.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.tokenStore,
    required this.config,
  }) : _refreshDio = Dio(
         BaseOptions(
           baseUrl: config.baseUrl,
           connectTimeout: dio.options.connectTimeout,
           receiveTimeout: dio.options.receiveTimeout,
           sendTimeout: dio.options.sendTimeout,
           contentType: Headers.jsonContentType,
           headers: {'Accept': 'application/json'},
         ),
       )..httpClientAdapter = dio.httpClientAdapter;

  /// Ana istemci; tekrar istekleri buradan geçer.
  final Dio dio;
  final TokenStore tokenStore;
  final ApiConfig config;
  final Dio _refreshDio;
  final StreamController<SessionEndReason> _ended =
      StreamController<SessionEndReason>.broadcast();

  Future<_RefreshResult>? _refreshing;

  /// Token'lar silinip oturum kapanınca nedeniyle birlikte olay verir.
  Stream<SessionEndReason> get sessionEnded => _ended.stream;

  /// Yalnız refresh başarısız olunca (süre doldu) olay verir.
  Stream<void> get sessionExpired =>
      sessionEnded.where((r) => r == SessionEndReason.expired);

  Future<void> dispose() async {
    _refreshDio.close();
    await _ended.close();
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] != true) {
      // Refresh sürüyorsa eski token'la gidip 401 almak yerine bekle.
      final pending = _refreshing;
      if (pending != null) await pending;
      final tokens = await tokenStore.read();
      if (tokens != null) {
        options.headers[_authHeader] = 'Bearer ${tokens.accessToken}';
      } else {
        options.headers.remove(_authHeader);
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
    if (err.response?.statusCode != 401 || options.extra[skipAuthKey] == true) {
      return handler.next(err);
    }
    final code = _codeOf(err.response?.data);

    if (code == ApiErrorCode.accountSuspended) {
      if (options.headers[_authHeader] != null) {
        await _end(SessionEndReason.suspended);
      }
      return handler.next(err);
    }
    if (code != ApiErrorCode.tokenExpired ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final result = await _ensureFresh(_bearerOf(options.headers[_authHeader]));
    if (result != _RefreshResult.ok) return handler.next(err);

    try {
      options.extra[_retriedKey] = true;
      // Multipart gövde bir kez okunabilir; yeniden denemede baştan kurulur.
      final rebuild = options.extra[rebuildBodyKey];
      if (rebuild is Object Function()) options.data = rebuild();
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Tek uçuşta refresh: süren varsa ona katılır, yoksa yenisini başlatır.
  Future<_RefreshResult> _ensureFresh(String? usedAccess) =>
      _refreshing ??= _refreshIfStale(usedAccess)
          .whenComplete(() => _refreshing = null);

  Future<_RefreshResult> _refreshIfStale(String? usedAccess) async {
    // Depo, önceki bir refresh tamamen bittikten sonra okunur.
    final current = await tokenStore.read();
    if (current == null) return _RefreshResult.failed;
    // İstek eski token'la gittiyse ve token bu arada yenilendiyse yeni refresh
    // gerekmez (dönen refresh token'ı ikinci kez kullanmak oturumu düşürür).
    if (usedAccess != current.accessToken) return _RefreshResult.ok;
    return _refresh(current.refreshToken);
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
      if (access is! String || refresh is! String) {
        return _RefreshResult.transient;
      }
      // Refresh sürerken çıkış yapıldıysa token'lar geri yazılmaz.
      final now = await tokenStore.read();
      if (now?.refreshToken != refreshToken) return _RefreshResult.failed;
      await tokenStore.write(
        TokenPair(accessToken: access, refreshToken: refresh),
      );
      return _RefreshResult.ok;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        final suspended =
            _codeOf(e.response?.data) == ApiErrorCode.accountSuspended;
        await _end(
          suspended ? SessionEndReason.suspended : SessionEndReason.expired,
        );
        return _RefreshResult.failed;
      }
      return _RefreshResult.transient;
    }
  }

  Future<void> _end(SessionEndReason reason) async {
    await tokenStore.clear();
    if (!_ended.isClosed) _ended.add(reason);
  }

  static String? _bearerOf(Object? header) {
    if (header is! String || !header.startsWith('Bearer ')) return null;
    return header.substring('Bearer '.length);
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

enum _RefreshResult { ok, failed, transient }
