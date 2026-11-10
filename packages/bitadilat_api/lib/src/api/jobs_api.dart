import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/enums.dart';
import '../models/jobs.dart';
import '../models/paged.dart';

/// İşler: `/jobs`.
class JobsApi {
  JobsApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/jobs';

  /// `as`: bakan rol; `scope`: `active` ya da `past`. Cevap sayfasızdır
  /// (`{items}`); `Paged.nextCursor` her zaman `null` olur.
  Future<Paged<JobSummary>> list({
    required PartyRole role,
    required String scope,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {'as': role.wire, 'scope': scope},
      ),
    );
    return decodeApi(() => Paged.fromJson(res.data!, JobSummary.fromJson));
  }

  Future<JobDetail> get(String id) => _detail(
    () => _dio.get<Map<String, dynamic>>('$_base/$id'),
  );

  Future<JobDetail> proposeSlot(String id, ProposeSlotRequest body) => _detail(
    () => _dio.post<Map<String, dynamic>>(
      '$_base/$id/appointment/proposals',
      data: body.toJson(),
    ),
  );

  Future<JobDetail> acceptProposal(String id, String proposalId) => _detail(
    () => _dio.post<Map<String, dynamic>>(
      '$_base/$id/appointment/proposals/$proposalId/accept',
    ),
  );

  Future<JobDetail> arrived(String id) => _detail(
    () => _dio.post<Map<String, dynamic>>('$_base/$id/arrived'),
  );

  Future<JobDetail> start(String id) => _detail(
    () => _dio.post<Map<String, dynamic>>('$_base/$id/start'),
  );

  Future<JobDetail> finish(String id, FinishJobRequest body) => _detail(
    () => _dio.post<Map<String, dynamic>>(
      '$_base/$id/finish',
      data: body.toJson(),
    ),
  );

  Future<JobDetail> addEvent(String id, JobNoteRequest body) => _detail(
    () => _dio.post<Map<String, dynamic>>(
      '$_base/$id/events',
      data: body.toJson(),
    ),
  );

  Future<JobDetail> confirm(String id) => _detail(
    () => _dio.post<Map<String, dynamic>>('$_base/$id/confirm'),
  );

  Future<JobDetail> cancel(String id, CancelJobRequest body) => _detail(
    () => _dio.post<Map<String, dynamic>>(
      '$_base/$id/cancel',
      data: body.toJson(),
    ),
  );

  Future<JobDetail> review(String id, ReviewRequest body) => _detail(
    () => _dio.post<Map<String, dynamic>>(
      '$_base/$id/review',
      data: body.toJson(),
    ),
  );

  Future<JobDetail> _detail(
    Future<Response<Map<String, dynamic>>> Function() call,
  ) async {
    final res = await guardApi(call);
    return decodeApi(() => JobDetail.fromJson(res.data!));
  }
}
