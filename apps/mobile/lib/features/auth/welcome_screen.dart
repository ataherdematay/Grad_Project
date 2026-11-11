import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';

/// Karşılama: TR/EN anahtarı, marka, değer önerisi ve "Giriş yap" /
/// "Hesap oluştur". Butonlar ekranın altına yaslanır; içerik sığmazsa
/// (küçük ekran, büyük yazı) sayfa kayar.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, this.next});

  final String? next;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              slivers: [
                // Kenar boşluğu SliverPadding ile değil içeride verilir:
                // SliverFillRemaining alttaki boşluğu hesaba katmaz, butonlar
                // ekranın kenarına yapışıyordu.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xs,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: LanguageSwitch(),
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.lg),
                        const _BrandLockup(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.welcomeTagline,
                          style: AppTypography.screenTitle,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Point(
                          icon: Icons.edit_note_rounded,
                          text: l.welcomePointRequest,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _Point(
                          icon: Icons.verified_user_outlined,
                          text: l.welcomePointVerified,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _Point(
                          icon: Icons.lock_outline_rounded,
                          text: l.welcomePointSecureHold,
                        ),
                        const Spacer(flex: 2),
                        const SizedBox(height: AppSpacing.lg),
                        const SessionNoticeBanner(),
                        AppButton(
                          label: l.actionLogin,
                          onPressed: () =>
                              context.push(withNext('/login', next)),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l.actionRegister,
                          variant: AppButtonVariant.secondary,
                          onPressed: () =>
                              context.push(withNext('/register', next)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Marka karosu ve yazısı yan yana. Yazı büyük yazı boyutunda kırılmaz,
/// sığmazsa küçülür.
class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BrandMark(size: 52),
        SizedBox(width: AppSpacing.sm),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: LogoText(size: 30),
          ),
        ),
      ],
    );
  }
}

/// Değer önerisi satırı: açık teal kutuda ikon ve tek cümle.
class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.selectedSurface,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Icon(icon, size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(text, style: AppTypography.body),
          ),
        ),
      ],
    );
  }
}
