import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/secure_token_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yazma/okuma sayısını ve gönderilen platform seçeneklerini kaydeder.
class RecordingPlatform extends TestFlutterSecureStoragePlatform {
  RecordingPlatform(super.data);

  final List<Map<String, String>> writeOptions = [];
  int reads = 0;
  int writes = 0;

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) {
    reads++;
    return super.read(key: key, options: options);
  }

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) {
    writes++;
    writeOptions.add(options);
    return super.write(key: key, value: value, options: options);
  }
}

void main() {
  late Map<String, String> data;
  late RecordingPlatform platform;

  setUp(() {
    data = {};
    platform = RecordingPlatform(data);
    FlutterSecureStoragePlatform.instance = platform;
  });

  const pair = TokenPair(accessToken: 'A1', refreshToken: 'R1');

  test('çift tek yazmada tek anahtara gider (yarım yazma olmaz)', () async {
    final store = SecureTokenStore();
    await store.write(pair);
    expect(platform.writes, 1);
    expect(data.keys, [SecureTokenStore.storageKey]);
    final again = await SecureTokenStore().read();
    expect(again?.accessToken, 'A1');
    expect(again?.refreshToken, 'R1');
  });

  test('çıkışta depoda hiçbir token kalmaz', () async {
    final store = SecureTokenStore();
    await store.write(pair);
    await store.clear();
    expect(data, isEmpty);
    expect(await store.read(), isNull);
    expect(await SecureTokenStore().read(), isNull);
  });

  test(
    'okunan değer bellekte tutulur: her istekte anahtarlığa gidilmez',
    () async {
      data[SecureTokenStore.storageKey] = '{"a":"A1","r":"R1"}';
      final store = SecureTokenStore();
      for (var i = 0; i < 5; i++) {
        await store.read();
      }
      expect(platform.reads, 1);
    },
  );

  test('bozuk kayıt oturumsuz sayılır', () async {
    data[SecureTokenStore.storageKey] = 'bozuk';
    expect(await SecureTokenStore().read(), isNull);
  });

  test('iOS: first_unlock_this_device, iCloud eşitlemesi kapalı', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await SecureTokenStore().write(pair);
    final options = platform.writeOptions.single;
    expect(options['accessibility'], 'first_unlock_this_device');
    expect(options['synchronizable'], 'false');
  });

  group('ilk kurulum', () {
    test('ilk açılışta anahtarlıkta kalan eski token silinir, sonra '
        'dokunulmaz', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = MemoryTokenStore(pair);

      await clearTokensOnFreshInstall(prefs, store);
      expect(await store.read(), isNull);

      await store.write(pair);
      await clearTokensOnFreshInstall(prefs, store);
      expect(await store.read(), isNotNull);
    });
  });
}
