import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';
import 'session.dart';

/// Açılış görselindeki karo boyutu (`tool/brand_assets.py` `LAUNCH_PT`).
const double kLaunchMarkSize = 96;

/// Açılış: token varsa `GET /me`, yoksa karşılama (yönlendirmeyi router yapar).
///
/// iOS açılış ekranının devamıdır: aynı zemin, aynı marka karosu, ekranın tam
/// ortasında ve aynı boyutta. Böylece yerel açılıştan Flutter'a geçişte
/// görüntü kıpırdamaz. Yükleme göstergesi yalnız bekleme uzarsa belirir.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _spinnerOpacity = CurvedAnimation(
    parent: _reveal,
    curve: const Interval(0.6, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    if (session.status == SessionStatus.bootstrapFailed) {
      return Scaffold(
        body: SafeArea(
          child: ErrorState(
            title: l.splashErrorTitle,
            message: apiErrorMessage(
              l,
              session.error?.code ?? ApiErrorCode.unknown,
            ),
            retryLabel: l.retry,
            onRetry: () => ref.read(sessionProvider.notifier).bootstrap(),
          ),
        ),
      );
    }
    // Gövde gevşek kısıt verir; Stack tam ekrana yayılmazsa karo sol üstte
    // çizilir. Karo ekranın tam ortasında, yerel açılış görseliyle aynı yerde.
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Semantics(
              label: l.appName,
              child: const BrandMark(size: kLaunchMarkSize),
            ),
            Transform.translate(
              offset: const Offset(0, kLaunchMarkSize / 2 + 40),
              child: FadeTransition(
                opacity: _spinnerOpacity,
                alwaysIncludeSemantics: true,
                child: Semantics(
                  label: l.loading,
                  child: const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
