import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/address.dart';
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
}
