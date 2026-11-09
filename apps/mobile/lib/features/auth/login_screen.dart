import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';
import 'session.dart';

/// Giriş: e-posta veya telefon + şifre. Başarıda yönlendirmeyi router yapar
/// (`next` ya da modun ana sekmesi).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.next});

  final String? next;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _fieldErrors = <String, String>{};
  String? _generalError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _identifier.dispose();
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
          .read(sessionProvider.notifier)
          .login(
            identifier: normalizeIdentifier(_identifier.text),
            password: _password.text,
          );
    } on AdminAccountException {
      if (mounted) setState(() => _generalError = l.noticeAdmin);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'identifier' || e.field == 'password') {
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
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.loginTitle, style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(l.loginIntro, style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.lg),
              const SessionNoticeBanner(),
              AppTextField(
                label: l.fieldIdentifier,
                hintText: l.hintIdentifier,
                controller: _identifier,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                validator: v.identifier,
                errorText: _fieldErrors['identifier'],
                onChanged: (_) => _clearFieldError('identifier'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldPassword,
                hintText: l.hintPassword,
                controller: _password,
                enabled: !_loading,
                isPassword: true,
                showPasswordTooltip: l.showPassword,
                hidePasswordTooltip: l.hidePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: v.password,
                errorText: _fieldErrors['password'],
                onChanged: (_) => _clearFieldError('password'),
                onFieldSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AppButton(
                  label: l.forgotPasswordLink,
                  variant: AppButtonVariant.tertiary,
                  expand: false,
                  onPressed: () => context.push('/forgot-password'),
                ),
              ),
              if (_generalError != null) ...[
                MessageBanner(_generalError!),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: l.loginTitle,
                isLoading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.loginNoAccount,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
              AppButton(
                label: l.actionRegister,
                variant: AppButtonVariant.tertiary,
                onPressed: () =>
                    context.pushReplacement(withNext('/register', widget.next)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
