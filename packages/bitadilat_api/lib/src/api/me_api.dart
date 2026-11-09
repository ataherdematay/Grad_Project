import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
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

  Future<void> changePassword(ChangePasswordRequest body) => guardApi(
    () =>
        _dio.post<void>('${ApiConfig.prefix}/me/password', data: body.toJson()),
  );
}
