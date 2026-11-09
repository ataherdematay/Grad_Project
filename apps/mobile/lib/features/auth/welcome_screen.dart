import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';

/// Karşılama: logo yazısı, TR/EN anahtarı, "Giriş yap" ve "Hesap oluştur".
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, this.next});

  final String? next;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerRight, child: LanguageSwitch()),
          const SizedBox(height: AppSpacing.lg),
          const Align(alignment: Alignment.centerLeft, child: LogoText(size: 40)),
          const SizedBox(height: AppSpacing.md),
          Text(l.welcomeTagline, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(l.welcomeBody, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.lg),
          const SessionNoticeBanner(),
          AppButton(
            label: l.actionLogin,
            onPressed: () => context.push(withNext('/login', next)),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l.actionRegister,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push(withNext('/register', next)),
          ),
        ],
      ),
    );
  }
}
