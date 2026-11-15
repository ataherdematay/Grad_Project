import 'dart:ui';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// `--dart-define=API_BASE_URL=...` ile değiştirilir.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8090',
);

/// `main()` içinde gerçek örnekle, testlerde sahteyle ezilir.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider ezilmeli'),
);

/// Token'lar yalnız bellekte tutulur; sayfa yenilenince oturum biter.
final tokenStoreProvider = Provider<TokenStore>((ref) => MemoryTokenStore());

final apiConfigProvider = Provider<ApiConfig>(
  (ref) => const ApiConfig(kApiBaseUrl),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    config: ref.watch(apiConfigProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
  ref.onDispose(client.dispose);
  return client;
});

/// Testlerde sabitlenebilen "şimdi".
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Bağlantıyı yeni sekmede açar (PDF belgeler). Testlerde ezilir.
final urlOpenerProvider = Provider<Future<void> Function(String url)>(
  (ref) =>
      (url) => launchUrl(Uri.parse(url), webOnlyWindowName: '_blank'),
);

/// Dil tercihi (kalıcı).
class LocaleController extends Notifier<Locale> {
  static const _key = 'locale';

  @override
  Locale build() {
    final stored = ref.watch(sharedPreferencesProvider).getString(_key);
    if (stored == 'en' || stored == 'tr') return Locale(stored!);
    final device = PlatformDispatcher.instance.locale.languageCode;
    return Locale(device == 'en' ? 'en' : 'tr');
  }

  Future<void> set(Locale locale) async {
    if (locale.languageCode == state.languageCode) return;
    state = Locale(locale.languageCode);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
