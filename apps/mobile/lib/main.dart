import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/providers.dart';
import 'core/secure_token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final tokens = SecureTokenStore();
  try {
    await clearTokensOnFreshInstall(prefs, tokens);
  } catch (_) {
    // Anahtarlık şu an erişilemezse açılış engellenmez; bir sonraki açılışta
    // yeniden denenir.
  }
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        tokenStoreProvider.overrideWithValue(tokens),
      ],
      child: const BitadilatApp(),
    ),
  );
}
