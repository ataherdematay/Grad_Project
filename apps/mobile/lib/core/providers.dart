import 'dart:ui';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_token_store.dart';

/// `--dart-define=API_BASE_URL=...` ile değiştirilir.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8090',
);

/// `main()` içinde gerçek örnekle, testlerde sahteyle ezilir.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider ezilmeli'),
);

final tokenStoreProvider = Provider<TokenStore>((ref) => SecureTokenStore());

final apiConfigProvider = Provider<ApiConfig>((ref) => ApiConfig(kApiBaseUrl));

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    config: ref.watch(apiConfigProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
  ref.onDispose(client.dispose);
  return client;
});

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
    // Giriş yapılmışsa sunucudaki tercih de güncellenir; başarısızlık önemsiz.
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens != null) {
      try {
        await ref
            .read(apiClientProvider)
            .me
            .update(UpdateMeRequest(locale: locale.languageCode));
      } on ApiException {
        // Yerel tercih geçerli kalır.
      }
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
