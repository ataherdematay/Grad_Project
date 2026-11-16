import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';

/// Şifre değiştirme formu (`POST /me/password`). Başarıda `true` döner;
/// sunucu diğer cihazlardaki oturumları kapatır, bu oturum açık kalır.
Future<bool> showChangePasswordDialog(BuildContext context) async {
  final done = await showDialog<bool>(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
  return done ?? false;
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _fieldErrors = <String, String>{};
  String? _generalError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
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
      await ref
          .read(apiClientProvider)
          .me
          .changePassword(
            ChangePasswordRequest(
              currentPassword: _current.text,
              newPassword: _new.text,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'currentPassword') {
          _fieldErrors['currentPassword'] = l.errCurrentPasswordWrong;
        } else if (e.field == 'newPassword') {
          _fieldErrors['newPassword'] = apiFieldMessage(l, e);
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
    return AlertDialog(
      title: Text(l.changePasswordTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l.fieldCurrentPassword,
                controller: _current,
                enabled: !_loading,
                isPassword: true,
                showPasswordTooltip: l.showPassword,
                hidePasswordTooltip: l.hidePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                validator: v.password,
                errorText: _fieldErrors['currentPassword'],
                onChanged: (_) => _clear('currentPassword'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldNewPassword,
                controller: _new,
                enabled: !_loading,
                isPassword: true,
                showPasswordTooltip: l.showPassword,
                hidePasswordTooltip: l.hidePassword,
                helperText: l.helperPassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: v.newPassword,
                errorText: _fieldErrors['newPassword'],
                onChanged: (_) => _clear('newPassword'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldConfirmPassword,
                controller: _confirm,
                enabled: !_loading,
                isPassword: true,
                showPasswordTooltip: l.showPassword,
                hidePasswordTooltip: l.hidePassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) return l.errRequired;
                  return value == _new.text ? null : l.errPasswordMismatch;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
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
        FilledButton(onPressed: _loading ? null : _submit, child: Text(l.save)),
      ],
    );
  }
}
