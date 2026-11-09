/// İstemci yapılandırması.
class ApiConfig {
  const ApiConfig(this.baseUrl);

  /// Örn. `http://localhost:8090` (sonunda `/` olmadan).
  final String baseUrl;

  /// Tüm uç noktaların ön eki.
  static const String prefix = '/api/v1';
}
