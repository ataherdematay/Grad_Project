import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/widgets.dart';
import 'change_password_dialog.dart';

/// Ayarlar: dil, şifre değiştirme, çıkış (onay diyaloğu) ve hesap silme.
/// Çıkış ve silme sonrası yığını router sıfırlar (`/welcome`).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loggingOut = false;
  bool _deleting = false;

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

  Future<void> _changePassword() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showChangePasswordDialog(context);
    if (!ok) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.changePasswordDone)));
  }

  /// Onaydan sonra `DELETE /me`. Açık iş ya da kilitli ödeme varsa sunucu
  /// 409 döner; hesap silinmez ve nedeni açıkça gösterilir.
  Future<void> _deleteAccount() async {
    if (_deleting) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.deleteAccountTitle,
      message: l.deleteAccountBody,
      confirmLabel: l.deleteAccountConfirm,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _deleting = true);
    try {
      await ref.read(apiClientProvider).me.deleteAccount();
      await ref.read(sessionProvider.notifier).accountDeleted();
    } on ApiException catch (e) {
      final text = e.code == ApiErrorCode.illegalState
          ? l.deleteAccountBlocked
          : apiErrorMessage(l, e.code);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    } finally {
      if (mounted) setState(() => _deleting = false);
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
            label: l.settingsChangePassword,
            icon: Icons.lock_outline,
            variant: AppButtonVariant.secondary,
            onPressed: _changePassword,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l.settingsLogout,
            icon: Icons.logout,
            variant: AppButtonVariant.secondary,
            isLoading: _loggingOut,
            onPressed: _logout,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l.settingsDeleteAccount,
            icon: Icons.delete_outline,
            variant: AppButtonVariant.secondary,
            isLoading: _deleting,
            onPressed: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
