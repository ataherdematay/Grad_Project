import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';

import '../../core/error_messages.dart';
import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../common/action_dialog.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

/// Karar diyaloğu: üç seçenek, zorunlu not, "ustaya uyarı" ve "usta profilini
/// askıya al". Kesinleştirmeden önce geri alınamazlığı yazan ikinci bir onay
/// gelir. İade, usta payı ve hizmet bedeli istemcide hesaplanmaz ve
/// gönderilmez: sunucu hesaplar, karar sonrası `refundAmount`/`proAmount`
/// detay ekranında gösterilir. Burada yalnız sunucunun döndüğü emanet toplamı
/// yazılır.
Future<DialogOutcome?> showDecisionDialog(
  BuildContext context, {
  required AdminComplaintDetail complaint,
  required Future<void> Function(ComplaintDecisionRequest request) onSubmit,
}) => showDialog<DialogOutcome>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _DecisionDialog(complaint: complaint, onSubmit: onSubmit),
);

class _DecisionDialog extends StatefulWidget {
  const _DecisionDialog({required this.complaint, required this.onSubmit});

  final AdminComplaintDetail complaint;
  final Future<void> Function(ComplaintDecisionRequest) onSubmit;

  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  ComplaintDecision? _decision;
  bool _warnPro = false;
  bool _suspendPro = false;
  bool _showPickError = false;
  bool _busy = false;
  String? _error;

  /// Sunucunun döndüğü emanet toplamı; emanet kaydı yoksa `null`.
  Money? get _total => widget.complaint.payment?.totalAmount;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final formOk = _formKey.currentState!.validate();
    if (_decision == null) setState(() => _showPickError = true);
    if (!formOk || _decision == null) return;
    final decision = _decision!;
    final extras = [
      if (_warnPro) l.decisionConfirmWarn,
      if (_suspendPro) l.decisionConfirmSuspend,
    ];
    final ok = await showConfirmDialog(
      context,
      title: l.decisionConfirmTitle,
      message: [
        l.decisionConfirmMessage(decisionLabel(l, decision)),
        ...extras,
      ].join('\n\n'),
      confirmLabel: l.decisionConfirmAction,
      cancelLabel: l.back,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        ComplaintDecisionRequest(
          decision: decision,
          note: _note.text.trim(),
          warnPro: _warnPro,
          suspendPro: _suspendPro,
        ),
      );
      if (mounted) Navigator.of(context).pop(DialogOutcome.done);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == ApiErrorCode.illegalState) {
        Navigator.of(context).pop(DialogOutcome.stale);
        return;
      }
      setState(() {
        _busy = false;
        // Ödeme sistemi hatasında hiçbir şey değişmez; bunu açıkça söyle.
        _error = e.code == ApiErrorCode.gatewayError
            ? l.decisionGatewayFailed
            : apiErrorMessage(l, e.code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.localeName;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        key: const Key('decision-dialog'),
        title: Text(l.decisionDialogTitle(widget.complaint.publicCode)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, minWidth: 320),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _total == null
                        ? l.decisionDialogIntroNoPayment
                        : l.decisionDialogIntro(formatMoney(_total!, locale)),
                    key: const Key('decision-intro'),
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final d in ComplaintDecision.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _OptionCard(
                        decision: d,
                        selected: _decision == d,
                        enabled: !_busy,
                        onTap: () => setState(() {
                          _decision = d;
                          _showPickError = false;
                        }),
                      ),
                    ),
                  if (_showPickError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        l.decisionPickOne,
                        style: AppTypography.label.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    label: l.decisionNoteLabel,
                    controller: _note,
                    enabled: !_busy,
                    minLines: 3,
                    helperText: l.noteHelper(10, 2000),
                    validator: (v) => validateNote(l, v, 10, 2000),
                  ),
                  CheckboxListTile(
                    key: const Key('warn-pro'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l.warnPro),
                    subtitle: Text(l.warnProHint),
                    value: _warnPro,
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _warnPro = v ?? false),
                  ),
                  CheckboxListTile(
                    key: const Key('suspend-pro'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l.suspendProProfile),
                    subtitle: Text(l.suspendProProfileHint),
                    value: _suspendPro,
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _suspendPro = v ?? false),
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
              key: const Key('decision-submit'),
              style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
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
                  : Text(l.decisionSubmit),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.decision,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ComplaintDecision decision;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final description = switch (decision) {
      ComplaintDecision.fullRefund => l.decisionFullRefundDesc,
      ComplaintDecision.split5050 => l.decisionSplitDesc,
      ComplaintDecision.releaseToPro => l.decisionReleaseDesc,
    };
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: decisionLabel(l, decision),
      child: Material(
        color: selected ? AppColors.selectedSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: Key('decision-${decision.name}'),
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        decisionLabel(l, decision),
                        style: AppTypography.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(description, style: AppTypography.bodySecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
