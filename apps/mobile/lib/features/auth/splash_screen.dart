import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';
import 'session.dart';

/// Açılış: token varsa `GET /me`, yoksa karşılama (yönlendirmeyi router yapar).
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionProvider);
    return Scaffold(
      body: SafeArea(
        child: session.status == SessionStatus.bootstrapFailed
            ? ErrorState(
                title: l.splashErrorTitle,
                message: apiErrorMessage(
                  l,
                  session.error?.code ?? ApiErrorCode.unknown,
                ),
                retryLabel: l.retry,
                onRetry: () => ref.read(sessionProvider.notifier).bootstrap(),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoText(size: 36),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      label: l.loading,
                      child: const CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
