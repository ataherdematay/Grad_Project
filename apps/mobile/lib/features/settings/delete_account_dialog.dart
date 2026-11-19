import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Hesap silme diyaloğunun sonucu: [confirmed] false ise hiçbir şey yapılmaz.
/// [reason] isteğe bağlıdır (yalnızca analiz, hesaba bağlanmaz).
typedef DeleteAccountChoice = ({bool confirmed, AccountDeletionReason? reason});

String deletionReasonLabel(AppLocalizations l, AccountDeletionReason r) =>
    switch (r) {
      AccountDeletionReason.noLongerNeeded => l.deleteReasonNoLongerNeeded,
      AccountDeletionReason.foundAlternative => l.deleteReasonFoundAlternative,
      AccountDeletionReason.privacy => l.deleteReasonPrivacy,
      AccountDeletionReason.badExperience => l.deleteReasonBadExperience,
      AccountDeletionReason.other => l.deleteReasonOther,
    };

/// Hesap silme onayı. Geri alınamayan işlem olduğu için "Hesabı sil" düğmesi
/// kullanıcı onay kutusunu işaretlemeden açılmaz. Gerekçe seçimi isteğe
/// bağlıdır.
Future<DeleteAccountChoice> showDeleteAccountDialog(
  BuildContext context,
) async {
  final done = await showDialog<DeleteAccountChoice>(
    context: context,
    builder: (_) => const _DeleteAccountDialog(),
  );
  return done ?? (confirmed: false, reason: null);
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _ack = false;
  AccountDeletionReason? _reason;

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
            Text(l.deleteAccountReasonTitle, style: AppTypography.label),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final r in AccountDeletionReason.values)
                  ChoiceChip(
                    label: Text(deletionReasonLabel(l, r)),
                    selected: _reason == r,
                    onSelected: (on) =>
                        setState(() => _reason = on ? r : null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.deleteAccountReasonNote,
              style: AppTypography.bodySecondary,
            ),
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
          onPressed: () =>
              Navigator.of(context).pop((confirmed: false, reason: null)),
          child: Text(l.cancel, textAlign: TextAlign.center),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: _ack
              ? () => Navigator.of(context).pop((
                  confirmed: true,
                  reason: _reason,
                ))
              : null,
          child: Text(l.deleteAccountConfirm, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
