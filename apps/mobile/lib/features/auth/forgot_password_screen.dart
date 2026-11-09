import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';

/// Şifre sıfırlama isteği: e-posta gir, 6 haneli kod gönderilir.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _fieldError;
  String? _generalError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _generalError = null;
      _fieldError = null;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final email = _email.text.trim();
    try {
      await ref.read(apiClientProvider).auth.forgotPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.forgotSent)),
      );
      // E-posta URL'ye değil `extra` ile taşınır.
      context.push('/reset-password', extra: email);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'email') {
          _fieldError = apiFieldMessage(l, e);
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
            Text(l.forgotTitle, style: AppTypography.screenTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(l.forgotIntro, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l.fieldEmail,
              hintText: l.hintEmail,
              controller: _email,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: v.email,
              errorText: _fieldError,
              onChanged: (_) {
                if (_fieldError != null) setState(() => _fieldError = null);
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_generalError != null) ...[
              MessageBanner(_generalError!),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: l.forgotSubmit,
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
