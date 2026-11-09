/// Access ve refresh token çifti.
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Token saklama arayüzü. Mobil güvenli depolama, testler bellek kullanır.
abstract class TokenStore {
  Future<TokenPair?> read();
  Future<void> write(TokenPair tokens);
  Future<void> clear();
}

/// Bellekte tutan basit uygulama (test ve geçici kullanım).
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this._tokens]);

  TokenPair? _tokens;

  @override
  Future<TokenPair?> read() async => _tokens;

  @override
  Future<void> write(TokenPair tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}
