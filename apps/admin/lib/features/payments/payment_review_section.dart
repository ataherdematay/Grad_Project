import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/action_dialog.dart';
import '../common/widgets.dart';

String resolutionLabel(AppLocalizations l, PaymentResolution r) => switch (r) {
  PaymentResolution.markRefunded => l.resolutionMarkRefunded,
  PaymentResolution.retryRefund => l.resolutionRetryRefund,
  PaymentResolution.release => l.resolutionRelease,
};

String gatewayStateLabel(AppLocalizations l, String state) => switch (state) {
  'NOT_REFUNDED' => l.reviewStateNotRefunded,
  'PARTIALLY_REFUNDED' => l.reviewStatePartial,
  'REFUND_PENDING' => l.reviewStatePending,
  'FULLY_REFUNDED' => l.reviewStateFull,
  _ => state,
};

/// İncelemedeki ödemeler (`REFUND_NEEDS_REVIEW` / `PAYOUT_NEEDS_REVIEW`).
/// "Craftgate'e sor ve çöz": önce sunucu Craftgate'e sorar, yalnız izin
/// verilen çözümler seçilebilir; çözüm notu zorunludur. Para hesabı istemcide
/// yapılmaz.
class PaymentReviewSection extends ConsumerStatefulWidget {
  const PaymentReviewSection({super.key, this.onResolved});

  /// Çözümden sonra defteri yenilemek için.
  final VoidCallback? onResolved;

  @override
  ConsumerState<PaymentReviewSection> createState() =>
      _PaymentReviewSectionState();
}

class _PaymentReviewSectionState extends ConsumerState<PaymentReviewSection> {
  String? _checking;

  Future<void> _resolve(AdminPaymentReviewItem item) async {
    if (_checking != null) return;
    final l = AppLocalizations.of(context);
    final api = ref.read(apiClientProvider).admin;
    setState(() => _checking = item.ref);
    AdminPaymentReviewCheck check;
    try {
      check = await api.checkPaymentReview(item.ref);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _checking = null);
        if (e.code == ApiErrorCode.notFound) {
          ref.invalidate(paymentReviewsProvider);
        }
        showNotice(context, apiErrorMessage(l, e.code));
      }
      return;
    }
    if (!mounted) return;
    setState(() => _checking = null);
    final state = l.reviewGatewayState(
      gatewayStateLabel(l, check.gatewayRefundState),
      formatMoney(check.gatewayRefundedTotal, l.localeName),
    );
    final options = check.resolutions;
    if (options.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.reviewNoResolutionTitle),
          content: Text('$state\n\n${l.reviewNoResolution}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.cancel),
            ),
          ],
        ),
      );
      return;
    }
    PaymentResolution? picked = options.length == 1 ? options.single : null;
    final outcome = await showActionDialog(
      context,
      title: l.reviewResolveTitle(item.jobPublicCode ?? item.ref),
      intro: state,
      noteLabel: l.resolveNoteLabel,
      minLength: 10,
      maxLength: 1000,
      confirmLabel: l.reviewResolve,
      extraValid: () => picked != null,
      extraInvalidText: l.reviewResolutionRequired,
      extraBuilder: (ctx, rebuild) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reviewResolutionLabel, style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final r in options)
                ChoiceChip(
                  key: Key('resolution-${r.name}'),
                  label: Text(resolutionLabel(l, r)),
                  selected: picked == r,
                  onSelected: (on) {
                    picked = on ? r : null;
                    rebuild();
                  },
                ),
            ],
          ),
        ],
      ),
      onSubmit: (note) =>
          api.resolvePaymentReview(item.ref, resolution: picked!, note: note),
    );
    if (!mounted) return;
    switch (outcome) {
      case DialogOutcome.done:
        ref.invalidate(paymentReviewsProvider);
        widget.onResolved?.call();
        showNotice(context, l.reviewResolvedNotice);
      case DialogOutcome.stale:
        ref.invalidate(paymentReviewsProvider);
        widget.onResolved?.call();
        showNotice(context, l.staleNotice);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(paymentReviewsProvider);
    final now = ref.watch(nowProvider)();
    final loc = l.localeName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.reviewSectionTitle, style: AppTypography.section),
        const SizedBox(height: AppSpacing.xs),
        Text(l.reviewSectionSubtitle, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.sm),
        AsyncBody(
          value: value,
          onRetry: () => ref.invalidate(paymentReviewsProvider),
          data: (items) => items.isEmpty
              ? Text(l.reviewEmpty, style: AppTypography.body)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppCard(
                          key: Key('review-${item.ref}'),
                          child: Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.jobPublicCode ?? item.ref,
                                    style: AppTypography.cardTitle,
                                  ),
                                  Text(
                                    item.errorCode == 'PAYOUT_NEEDS_REVIEW'
                                        ? l.reviewCodePayout
                                        : l.reviewCodeRefund,
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  Text(
                                    '${item.customerName ?? '-'} · '
                                    '${item.proBusinessName ?? '-'}',
                                    style: AppTypography.bodySecondary,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(formatMoney(item.totalAmount, loc)),
                                  Text(
                                    '${l.reviewAttempts(item.attempts)} · '
                                    '${formatDate(item.createdAt, loc, now)}',
                                    style: AppTypography.bodySecondary,
                                  ),
                                ],
                              ),
                              FilledButton.icon(
                                onPressed: _checking == null
                                    ? () => _resolve(item)
                                    : null,
                                icon: _checking == item.ref
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.fact_check_outlined),
                                label: Text(l.reviewCheck),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
