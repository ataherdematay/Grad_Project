import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/jobs.dart';

/// Şikayetler.
class ComplaintsApi {
  ComplaintsApi(this._dio);

  final Dio _dio;

  static const _prefix = ApiConfig.prefix;

  /// Müşteri işi hakkında şikayet açar (201).
  Future<Complaint> create(String jobId, ComplaintRequest body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_prefix/jobs/$jobId/complaint',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => Complaint.fromJson(res.data!));
  }

  Future<Complaint> get(String id) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_prefix/complaints/$id'),
    );
    return decodeApi(() => Complaint.fromJson(res.data!));
  }
}
