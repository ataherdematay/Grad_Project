import 'package:dio/dio.dart';

/// Sunucunun döndürdüğü hata kodları (API_V1.md). Bilinmeyen kod `unknown`,
/// bağlantı sorunu `networkError` olur.
enum ApiErrorCode {
  validationFailed('VALIDATION_FAILED'),
  unauthenticated('UNAUTHENTICATED'),
  tokenExpired('TOKEN_EXPIRED'),
  badCredentials('BAD_CREDENTIALS'),
  accountSuspended('ACCOUNT_SUSPENDED'),
  forbidden('FORBIDDEN'),
  proNotApproved('PRO_NOT_APPROVED'),
  notFound('NOT_FOUND'),
  illegalState('ILLEGAL_STATE'),
  emailTaken('EMAIL_TAKEN'),
  phoneTaken('PHONE_TAKEN'),
  tooManyAttempts('TOO_MANY_ATTEMPTS'),
  paymentDeclined('PAYMENT_DECLINED'),
  invalidCard('INVALID_CARD'),
  duplicateAttempt('DUPLICATE_ATTEMPT'),
  paymentInProgress('PAYMENT_IN_PROGRESS'),
  offerExpired('OFFER_EXPIRED'),
  alreadyOffered('ALREADY_OFFERED'),
  gatewayError('GATEWAY_ERROR'),
  internalError('INTERNAL_ERROR'),
  networkError('NETWORK_ERROR'),
  unknown('UNKNOWN');

  const ApiErrorCode(this.wire);

  /// Sunucudaki `code` değeri.
  final String wire;

  static ApiErrorCode parse(Object? raw) {
    if (raw is! String) return ApiErrorCode.unknown;
    for (final c in ApiErrorCode.values) {
      if (c == ApiErrorCode.networkError || c == ApiErrorCode.unknown) continue;
      if (c.wire == raw) return c;
    }
    return ApiErrorCode.unknown;
  }
}

/// API çağrılarının tek hata türü.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    this.message = '',
    this.field,
    this.statusCode,
    this.ref,
  });

  final ApiErrorCode code;

  /// Geliştirici mesajı; kullanıcıya gösterilmez, `code` çevrilir.
  final String message;

  /// Doğrulama hatasında ilgili alan adı.
  final String? field;
  final int? statusCode;

  /// `PAYMENT_DECLINED` yanıtındaki ödeme referansı.
  final String? ref;

  bool get isNetworkError => code == ApiErrorCode.networkError;

  /// `{code, message, field?}` gövdesini ve HTTP durumunu çözer.
  factory ApiException.fromResponse(int? statusCode, Object? body) {
    if (body is Map) {
      return ApiException(
        code: ApiErrorCode.parse(body['code']),
        message: (body['message'] ?? '').toString(),
        field: body['field'] is String ? body['field'] as String : null,
        statusCode: statusCode,
        ref: body['ref'] is String ? body['ref'] as String : null,
      );
    }
    return ApiException(code: ApiErrorCode.unknown, statusCode: statusCode);
  }

  /// Dio hatasını `ApiException`a çevirir.
  factory ApiException.fromDio(DioException e) {
    final inner = e.error;
    if (inner is ApiException) return inner;
    final response = e.response;
    if (response != null) {
      return ApiException.fromResponse(response.statusCode, response.data);
    }
    return ApiException(
      code: ApiErrorCode.networkError,
      message: e.message ?? e.type.name,
    );
  }

  @override
  String toString() => 'ApiException($code, $statusCode, $field, $message)';
}

/// Dio çağrısını sarar; her hatayı `ApiException` olarak fırlatır.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}

/// Yanıt gövdesini modele çevirir. Sözleşmeye uymayan gövde (eksik alan,
/// bilinmeyen enum, boş yanıt) uygulamayı çökertmez; `ApiException(unknown)`
/// olur.
T decodeApi<T>(T Function() parse) {
  try {
    return parse();
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(
      code: ApiErrorCode.unknown,
      message: 'Yanıt çözülemedi: ${e.runtimeType}',
    );
  }
}
