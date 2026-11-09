import 'package:flutter/material.dart';

import 'tokens.dart';

/// Onay diyaloğu: başlık, sonuç metni, onay ve vazgeç. `destructive` iken
/// onay düğmesi kırmızıdır. Onaylanırsa `true`, aksi halde `false` döner.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: AppSpacing.xs,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel, textAlign: TextAlign.center),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                )
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel, textAlign: TextAlign.center),
        ),
      ],
    ),
  );
  return result ?? false;
}
