import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Hesap silme onayı. Geri alınamayan işlem olduğu için "Hesabı sil" düğmesi
/// kullanıcı onay kutusunu işaretlemeden açılmaz. Onaylanırsa `true`.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final done = await showDialog<bool>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return done ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _ack = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.deleteAccountTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.deleteAccountBody),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              value: _ack,
              onChanged: (v) => setState(() => _ack = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(l.deleteAccountAck, style: AppTypography.body),
            ),
          ],
        ),
      ),
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: AppSpacing.xs,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.cancel, textAlign: TextAlign.center),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: _ack ? () => Navigator.of(context).pop(true) : null,
          child: Text(l.deleteAccountConfirm, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
