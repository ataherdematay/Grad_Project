import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/widgets.dart';

/// Doğrulamalı e-posta değişikliği: 1) yeni adres + şifre → yeni adrese kod,
/// 2) kod → e-posta değişir. Kod girilmeden hiçbir şey değişmez. Başarıda
/// `true` döner.
Future<bool> showChangeEmailDialog(BuildContext context) async {
  final done = await showDialog<bool>(
    context: context,
    builder: (_) => const _ChangeEmailDialog(),
  );
  return done ?? false;
}

class _ChangeEmailDialog extends ConsumerStatefulWidget {
  const _ChangeEmailDialog();

  @override
  ConsumerState<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends ConsumerState<_ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  final _fieldErrors = <String, String>{};
  String? _generalError;
  String? _sentTo;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  void _clear(String key) {
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
    setState(() => _loading = true);
    try {
      if (_sentTo == null) {
        final email = _email.text.trim();
        await ref
            .read(apiClientProvider)
            .me
            .requestEmailChange(newEmail: email, password: _password.text);
        if (!mounted) return;
        setState(() {
          _sentTo = email;
          _autovalidate = AutovalidateMode.disabled;
        });
      } else {
        await ref
            .read(sessionProvider.notifier)
            .confirmEmailChange(_code.text.trim());
        if (mounted) Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'password') {
          _fieldErrors['password'] = l.emailChangeWrongPassword;
        } else if (e.code == ApiErrorCode.emailTaken) {
          _fieldErrors['newEmail'] = l.emailChangeTaken;
        } else if (e.field == 'newEmail') {
          _fieldErrors['newEmail'] = l.emailChangeSame;
        } else if (e.field == 'code') {
          _fieldErrors['code'] = l.emailChangeCodeInvalid;
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
    final sent = _sentTo;
    return AlertDialog(
      title: Text(l.emailChangeTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sent == null) ...[
                AppTextField(
                  label: l.emailChangeNewLabel,
                  controller: _email,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: v.email,
                  errorText: _fieldErrors['newEmail'],
                  onChanged: (_) => _clear('newEmail'),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l.emailChangePasswordLabel,
                  controller: _password,
                  enabled: !_loading,
                  isPassword: true,
                  showPasswordTooltip: l.showPassword,
                  hidePasswordTooltip: l.hidePassword,
                  textInputAction: TextInputAction.done,
                  validator: (x) =>
                      (x == null || x.isEmpty) ? l.errRequired : null,
                  errorText: _fieldErrors['password'],
                  onChanged: (_) => _clear('password'),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ] else ...[
                Text(l.emailChangeCodeIntro(sent), style: AppTypography.body),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l.emailChangeCodeLabel,
                  controller: _code,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textInputAction: TextInputAction.done,
                  validator: (x) =>
                      RegExp(r'^\d{6}$').hasMatch((x ?? '').trim())
                      ? null
                      : l.emailChangeCodeFormat,
                  errorText: _fieldErrors['code'],
                  onChanged: (_) => _clear('code'),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
              if (_generalError != null) ...[
                const SizedBox(height: AppSpacing.md),
                MessageBanner(_generalError!),
              ],
            ],
          ),
        ),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: Text(
            sent == null ? l.emailChangeSendCode : l.emailChangeConfirm,
          ),
        ),
      ],
    );
  }
}
