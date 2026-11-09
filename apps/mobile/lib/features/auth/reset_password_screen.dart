import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';

/// 6 haneli kod ve yeni şifre. Bitince giriş ekranı açılır; yığın sıfırlanır,
/// geri tuşu forma dönmez.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail ?? '',
  );
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _fieldErrors = <String, String>{};
  String? _generalError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearFieldError(String key) {
    if (_fieldErrors.containsKey(key)) {
      setState(() => _fieldErrors.remove(key));
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _generalError = null;
      _fieldErrors.clear();
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ref
          .read(apiClientProvider)
          .auth
          .resetPassword(
            ResetPasswordRequest(
              email: _email.text.trim(),
              code: _code.text.trim(),
              newPassword: _password.text,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.resetDone)),
      );
      // `go`: yığın sıfırlanır, geri tuşu forma dönmez.
      context.go('/login');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (const {'email', 'code', 'newPassword'}.contains(e.field)) {
          _fieldErrors[e.field!] = apiFieldMessage(l, e);
        } else {
          _generalError = apiErrorMessage(l, e.code);
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = Validators(l);
    return PageScaffold(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.resetTitle, style: AppTypography.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(l.resetIntro, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l.fieldEmail,
              hintText: l.hintEmail,
              controller: _email,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: v.email,
              errorText: _fieldErrors['email'],
              onChanged: (_) => _clearFieldError('email'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldCode,
              hintText: l.hintCode,
              controller: _code,
              enabled: !_loading,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              maxLength: 6,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: v.code,
              errorText: _fieldErrors['code'],
              onChanged: (_) => _clearFieldError('code'),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l.fieldNewPassword,
              controller: _password,
              enabled: !_loading,
              isPassword: true,
              showPasswordTooltip: l.showPassword,
              hidePasswordTooltip: l.hidePassword,
              helperText: l.helperPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: v.newPassword,
              errorText: _fieldErrors['newPassword'],
              onChanged: (_) => _clearFieldError('newPassword'),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_generalError != null) ...[
              MessageBanner(_generalError!),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: l.resetSubmit,
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
