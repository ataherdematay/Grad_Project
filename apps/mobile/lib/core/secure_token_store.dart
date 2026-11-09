import 'dart:convert';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token'ları iOS Keychain / Android Keystore üzerinde saklar.
///
/// - Çift tek anahtarda JSON olarak yazılır: iki ayrı yazma arasında uygulama
///   kapanırsa yeni access + eski (dönmüş) refresh token kalmaz.
/// - Okunan değer bellekte tutulur; her istekte anahtarlığa gidilmez.
/// - iOS: `first_unlock_this_device`. Açılıştan sonraki ilk kilit açmadan
///   itibaren arka planda da okunur; yedekle başka cihaza taşınmaz.
class SecureTokenStore implements TokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage(iOptions: iosOptions);

  static const IOSOptions iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static const storageKey = 'bt_tokens';

  final FlutterSecureStorage _storage;
  TokenPair? _cache;
  bool _loaded = false;

  @override
  Future<TokenPair?> read() async {
    if (_loaded) return _cache;
    final raw = await _storage.read(key: storageKey);
    // Okuma sürerken yazma/silme olduysa bellekteki değer daha yenidir.
    if (_loaded) return _cache;
    _cache = _decode(raw);
    _loaded = true;
    return _cache;
  }

  @override
  Future<void> write(TokenPair tokens) async {
    _cache = tokens;
    _loaded = true;
    await _storage.write(
      key: storageKey,
      value: jsonEncode({'a': tokens.accessToken, 'r': tokens.refreshToken}),
    );
  }

  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _storage.delete(key: storageKey);
  }

  static TokenPair? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map && map['a'] is String && map['r'] is String) {
        return TokenPair(
          accessToken: map['a'] as String,
          refreshToken: map['r'] as String,
        );
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}

const _installedKey = 'bt_installed';

/// iOS anahtarlığı uygulama silinince temizlenmez; yeniden kurulumda eski
/// oturum sessizce açılmasın diye ilk açılışta token'lar silinir.
Future<void> clearTokensOnFreshInstall(
  SharedPreferences prefs,
  TokenStore store,
) async {
  if (prefs.getBool(_installedKey) ?? false) return;
  await store.clear();
  await prefs.setBool(_installedKey, true);
}
