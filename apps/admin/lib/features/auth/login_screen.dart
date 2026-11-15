import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_toggle.dart';
import 'session.dart';

/// Yönetici girişi: e-posta + şifre. Başarıda yönlendirmeyi router yapar.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(sessionProvider.notifier)
          .login(email: _email.text, password: _password.text);
    } on NotAdminException {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _password.clear();
        _error = l.loginNotAdmin;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(l, e.code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notice = ref.watch(sessionProvider.select((s) => s.notice));
    final noticeText = switch (notice) {
      SessionNotice.sessionExpired => l.noticeSessionExpired,
      SessionNotice.accountSuspended => l.noticeAccountSuspended,
      null => null,
    };
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: LanguageToggle(),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                l.loginTitle,
                                style: AppTypography.screenTitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l.loginSubtitle,
                              style: AppTypography.bodySecondary,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (noticeText != null) ...[
                              _Message(text: noticeText, error: false),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            AppTextField(
                              label: l.email,
                              controller: _email,
                              enabled: !_loading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              autofocus: true,
                              validator: (v) {
                                final t = (v ?? '').trim();
                                if (t.isEmpty || !t.contains('@')) {
                                  return l.emailInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppTextField(
                              label: l.password,
                              controller: _password,
                              enabled: !_loading,
                              isPassword: true,
                              showPasswordTooltip: l.showPassword,
                              hidePasswordTooltip: l.hidePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _submit(),
                              validator: (v) =>
                                  (v ?? '').isEmpty ? l.passwordRequired : null,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              _Message(text: _error!, error: true),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: l.login,
                              isLoading: _loading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.error});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFF8E7E5) : const Color(0xFFE6F1F6),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            error ? Icons.error_outline : Icons.info_outline,
            size: 20,
            color: error ? AppColors.error : AppColors.infoText,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.label.copyWith(
                color: error ? AppColors.error : AppColors.infoText,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
