import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/category.dart';
import '../models/district.dart';
import '../models/service_request.dart';

class CatalogApi {
  CatalogApi(this._dio);

  final Dio _dio;

  Future<List<Category>> categories() async {
    final res = await guardApi(
      () => _dio.get<List<dynamic>>('${ApiConfig.prefix}/categories'),
    );
    return decodeApi(
      () => [
        for (final e in res.data!) Category.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  /// Kategoriye özel sihirbaz soruları (tek seçimli).
  Future<List<Question>> questions(String categoryId) async {
    final res = await guardApi(
      () => _dio.get<List<dynamic>>(
        '${ApiConfig.prefix}/categories/$categoryId/questions',
      ),
    );
    return decodeApi(
      () => [
        for (final e in res.data!) Question.fromJson(e as Map<String, dynamic>),
      ],
    );
  }

  Future<List<District>> districts() async {
    final res = await guardApi(
      () => _dio.get<List<dynamic>>('${ApiConfig.prefix}/districts'),
    );
    return decodeApi(
      () => [
        for (final e in res.data!) District.fromJson(e as Map<String, dynamic>),
      ],
    );
  }
}
