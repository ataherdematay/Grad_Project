import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';
import 'widgets.dart';

/// Eylem diyaloğunun sonucu.
enum DialogOutcome {
  /// İstek başarılı.
  done,

  /// Sunucu `ILLEGAL_STATE` döndü: kayıt değişmiş, ekran yenilenmeli.
  stale,
}

/// Gerekçe (not) isteyen onay diyaloğu. Düğme gönderirken kilitlenir; hata
/// diyalogda kalır ve not korunur. `ILLEGAL_STATE`te diyalog kapanır ve
/// [DialogOutcome.stale] döner.
Future<DialogOutcome?> showActionDialog(
  BuildContext context, {
  required String title,
  String? intro,
  required String noteLabel,
  required int minLength,
  required int maxLength,
  required String confirmLabel,
  required Future<void> Function(String note) onSubmit,
  bool destructive = false,
  Widget Function(BuildContext context, VoidCallback rebuild)? extraBuilder,
  bool Function()? extraValid,
  String? extraInvalidText,
}) => showDialog<DialogOutcome>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _ActionDialog(
    title: title,
    intro: intro,
    noteLabel: noteLabel,
    minLength: minLength,
    maxLength: maxLength,
    confirmLabel: confirmLabel,
    onSubmit: onSubmit,
    destructive: destructive,
    extraBuilder: extraBuilder,
    extraValid: extraValid,
    extraInvalidText: extraInvalidText,
  ),
);

class _ActionDialog extends StatefulWidget {
  const _ActionDialog({
    required this.title,
    required this.intro,
    required this.noteLabel,
    required this.minLength,
    required this.maxLength,
    required this.confirmLabel,
    required this.onSubmit,
    required this.destructive,
    required this.extraBuilder,
    required this.extraValid,
    required this.extraInvalidText,
  });

  final String title;
  final String? intro;
  final String noteLabel;
  final int minLength;
  final int maxLength;
  final String confirmLabel;
  final Future<void> Function(String note) onSubmit;
  final bool destructive;
  final Widget Function(BuildContext, VoidCallback)? extraBuilder;
  final bool Function()? extraValid;
  final String? extraInvalidText;

  @override
  State<_ActionDialog> createState() => _ActionDialogState();
}

class _ActionDialogState extends State<_ActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  bool _busy = false;
  bool _showExtraError = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final extraOk = widget.extraValid?.call() ?? true;
    final formOk = _formKey.currentState!.validate();
    if (!extraOk) setState(() => _showExtraError = true);
    if (!formOk || !extraOk) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_note.text.trim());
      if (mounted) Navigator.of(context).pop(DialogOutcome.done);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == ApiErrorCode.illegalState) {
        Navigator.of(context).pop(DialogOutcome.stale);
        return;
      }
      setState(() {
        _busy = false;
        _error = apiErrorMessage(l, e.code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        title: Text(widget.title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, minWidth: 320),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.intro != null) ...[
                    Text(widget.intro!, style: AppTypography.bodySecondary),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (widget.extraBuilder != null) ...[
                    widget.extraBuilder!(context, () => setState(() {})),
                    if (_showExtraError &&
                        !(widget.extraValid?.call() ?? true) &&
                        widget.extraInvalidText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.extraInvalidText!,
                          style: AppTypography.label.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppTextField(
                    label: widget.noteLabel,
                    controller: _note,
                    enabled: !_busy,
                    minLines: 3,
                    helperText: l.noteHelper(
                      widget.minLength,
                      widget.maxLength,
                    ),
                    validator: (v) =>
                        validateNote(l, v, widget.minLength, widget.maxLength),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        style: AppTypography.label.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
          SizedBox(
            height: 44,
            child: FilledButton(
              style: widget.destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(96, 44),
                    )
                  : FilledButton.styleFrom(minimumSize: const Size(96, 44)),
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(widget.confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

/// Basit onay + istek: onaylanırsa [run] çağrılır. Dönen sonuç yok sayılırsa
/// `null` (vazgeçildi).
Future<DialogOutcome?> confirmAndRun(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function() run,
  bool destructive = false,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showConfirmDialog(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: l.cancel,
    destructive: destructive,
  );
  if (!ok) return null;
  try {
    await run();
    return DialogOutcome.done;
  } on ApiException catch (e) {
    if (e.code == ApiErrorCode.illegalState) return DialogOutcome.stale;
    if (context.mounted) showNotice(context, apiErrorMessage(l, e.code));
    return null;
  }
}
