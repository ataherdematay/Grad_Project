import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/address.dart';
import '../models/enums.dart';
import '../models/me.dart';
import '../models/requests.dart';

class MeApi {
  MeApi(this._dio);

  final Dio _dio;

  Future<Me> get() async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('${ApiConfig.prefix}/me'),
    );
    return decodeApi(() => Me.fromJson(res.data!));
  }

  Future<Me> update(UpdateMeRequest body) async {
    final res = await guardApi(
      () => _dio.patch<Map<String, dynamic>>(
        '${ApiConfig.prefix}/me',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => Me.fromJson(res.data!));
  }

  static const _addresses = '${ApiConfig.prefix}/me/addresses';

  Future<List<Address>> addresses() async {
    final res = await guardApi(() => _dio.get<List<dynamic>>(_addresses));
    return decodeApi(
      () => [
        for (final e in res.data!) Address.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  Future<Address> createAddress(AddressInput body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(_addresses, data: body.toJson()),
    );
    return decodeApi(() => Address.fromJson(res.data!));
  }

  Future<Address> updateAddress(String id, AddressInput body) async {
    final res = await guardApi(
      () => _dio.patch<Map<String, dynamic>>(
        '$_addresses/$id',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => Address.fromJson(res.data!));
  }

  Future<void> deleteAddress(String id) =>
      guardApi(() => _dio.delete<void>('$_addresses/$id'));

  Future<void> changePassword(ChangePasswordRequest body) => guardApi(
    () =>
        _dio.post<void>('${ApiConfig.prefix}/me/password', data: body.toJson()),
  );

  /// `DELETE /me`: hesabı siler (anonimleştirir) ve tüm oturumları kapatır.
  /// Açık iş ya da kilitli güvence havuzu varsa sunucu `ILLEGAL_STATE` (409)
  /// döner. [reason] isteğe bağlıdır; yalnızca analiz için, kullanıcıya
  /// bağlanmadan saklanır.
  Future<void> deleteAccount({AccountDeletionReason? reason}) => guardApi(
    () => _dio.delete<void>(
      '${ApiConfig.prefix}/me',
      data: reason == null ? null : {'reason': reason.wire},
    ),
  );

  /// `POST /me/email`: yeni adrese 6 haneli doğrulama kodu gönderir (202).
  /// E-posta, kod [confirmEmailChange] ile doğrulanmadan değişmez.
  Future<void> requestEmailChange({
    required String newEmail,
    required String password,
  }) => guardApi(
    () => _dio.post<void>(
      '${ApiConfig.prefix}/me/email',
      data: {'newEmail': newEmail, 'password': password},
    ),
  );

  /// `POST /me/email/confirm`: kodu doğrular; yeni e-postalı `Me` döner.
  Future<Me> confirmEmailChange(String code) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '${ApiConfig.prefix}/me/email/confirm',
        data: {'code': code},
      ),
    );
    return decodeApi(() => Me.fromJson(res.data!));
  }
}
