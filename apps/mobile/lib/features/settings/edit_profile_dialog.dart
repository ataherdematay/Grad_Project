import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/widgets.dart';

/// Profil düzenleme (`PATCH /me`). Sunucu yalnız ad soyadı değiştirmeye
/// izin verir; e-posta ve telefon salt okunur gösterilir. Başarıda `true`.
Future<bool> showEditProfileDialog(BuildContext context, Me me) async {
  final done = await showDialog<bool>(
    context: context,
    builder: (_) => _EditProfileDialog(me: me),
  );
  return done ?? false;
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.me});

  final Me me;

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.me.fullName,
  );
  String? _fieldError;
  String? _generalError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
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
    setState(() => _loading = true);
    try {
      await ref
          .read(sessionProvider.notifier)
          .updateFullName(_name.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'fullName') {
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
    return AlertDialog(
      title: Text(l.accountEditTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l.fieldFullName,
                hintText: l.hintFullName,
                controller: _name,
                enabled: !_loading,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: v.fullName,
                errorText: _fieldError,
                onChanged: (_) {
                  if (_fieldError != null) setState(() => _fieldError = null);
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(widget.me.email, style: AppTypography.bodySecondary),
              if ((widget.me.phone ?? '').isNotEmpty)
                Text(widget.me.phone!, style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.xs),
              Text(l.accountEditContactNote, style: AppTypography.label),
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
