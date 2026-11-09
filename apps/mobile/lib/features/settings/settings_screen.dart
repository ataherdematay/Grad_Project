import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/widgets.dart';

/// Ayarlar: dil ve çıkış (onay diyaloğu). Çıkış sonrası yığını router
/// sıfırlar (`/welcome`).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.logoutConfirmTitle,
      message: l.logoutConfirmBody,
      confirmLabel: l.settingsLogout,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await ref.read(sessionProvider.notifier).logout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      title: l.settingsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.settingsLanguage, style: AppTypography.section),
          const SizedBox(height: AppSpacing.sm),
          const Align(alignment: Alignment.centerLeft, child: LanguageSwitch()),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l.settingsLogout,
            icon: Icons.logout,
            variant: AppButtonVariant.secondary,
            isLoading: _loggingOut,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}
