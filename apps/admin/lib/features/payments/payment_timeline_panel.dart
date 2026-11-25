import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

/// Sağlayıcı rozeti: CRAFTGATE (gerçek sandbox çağrısı), SEED (yalnız defter),
/// DEMO (sahte ağ geçidi). Bilinmeyen değer olduğu gibi gösterilir.
Widget providerBadge(AppLocalizations l, String raw) => StatusChip(
  key: Key('provider-badge-$raw'),
  label: switch (raw) {
    'CRAFTGATE' => l.tlProviderCraftgate,
    'SEED' => l.tlProviderSeed,
    'DEMO' => l.tlProviderDemo,
    _ => raw,
  },
  icon: switch (raw) {
    'CRAFTGATE' => Icons.credit_score_outlined,
    'SEED' => Icons.dataset_outlined,
    'DEMO' => Icons.science_outlined,
    _ => Icons.help_outline,
  },
  tone: switch (raw) {
    'CRAFTGATE' => StatusTone.primary,
    'SEED' => StatusTone.neutral,
    'DEMO' => StatusTone.urgent,
    _ => StatusTone.neutral,
  },
);

/// Yan paneli açar (dar ekranda tam genişlik).
Future<void> showPaymentTimelinePanel(BuildContext context, String paymentRef) {
  final l = AppLocalizations.of(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: l.tlClose,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (ctx, _, _) => Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: MediaQuery.sizeOf(ctx).width < 560 ? double.infinity : 520,
        child: Material(
          color: AppColors.canvas,
          elevation: 8,
          child: SafeArea(child: PaymentTimelinePanel(paymentRef: paymentRef)),
        ),
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

/// Bir ödemenin tam zaman çizelgesi: para nerede, tutarlar, ayrıntılar, olaylar.
class PaymentTimelinePanel extends ConsumerWidget {
  const PaymentTimelinePanel({super.key, required this.paymentRef});

  final String paymentRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(paymentTimelineProvider(paymentRef));
    return Column(
      key: const Key('timeline-panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l.tlTitle, style: AppTypography.section),
                ),
              ),
              IconButton(
                key: const Key('timeline-close'),
                tooltip: l.tlClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AsyncBody(
              value: value,
              onRetry: () =>
                  ref.invalidate(paymentTimelineProvider(paymentRef)),
              data: (t) => _TimelineBody(timeline: t),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineBody extends ConsumerWidget {
  const _TimelineBody({required this.timeline});

  final AdminPaymentTimeline timeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final loc = l.localeName;
    final now = ref.watch(nowProvider)();
    final t = timeline;
    final dash = '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.jobPublicCode ?? t.paymentRef,
          key: const Key('timeline-heading'),
          style: AppTypography.cardTitle,
        ),
        if (t.jobTitle != null)
          Text(t.jobTitle!, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            escrowChip(l, t.status),
            providerBadge(l, t.provider),
            if (t.sandbox)
              StatusChip(
                key: const Key('sandbox-badge'),
                label: l.tlSandbox,
                icon: Icons.science_outlined,
                tone: StatusTone.info,
              ),
            if (t.pendingAction != null)
              StatusChip(
                label: t.pendingAction == 'RELEASE'
                    ? l.tlPendingRelease
                    : t.pendingAction == 'REFUND'
                    ? l.tlPendingRefund
                    : t.pendingAction!,
                icon: Icons.schedule,
                tone: StatusTone.urgent,
              ),
            if (t.errorCode != null)
              StatusChip(
                key: const Key('timeline-error'),
                label: t.errorCode!,
                icon: Icons.error_outline,
                tone: StatusTone.error,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        MoneyFlow(location: t.moneyLocation),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: l.tlAmounts,
          child: Column(
            children: [
              InfoRow(
                label: l.tlGross,
                value: Text(
                  formatMoney(t.amounts.gross, loc),
                  key: const Key('amount-gross'),
                ),
              ),
              InfoRow(
                label: l.tlServiceFee,
                value: Text(
                  t.amounts.commission == null
                      ? dash
                      : formatMoney(t.amounts.commission!, loc),
                  key: const Key('amount-commission'),
                ),
              ),
              InfoRow(
                label: l.tlProNet,
                value: Text(
                  t.amounts.proNet == null
                      ? dash
                      : formatMoney(t.amounts.proNet!, loc),
                  key: const Key('amount-pro-net'),
                ),
              ),
              InfoRow(
                label: l.tlRefunded,
                value: Text(
                  formatMoney(t.amounts.refunded, loc),
                  key: const Key('amount-refunded'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: l.tlDetails,
          child: Column(
            children: [
              InfoRow(
                label: l.tlPaymentRef,
                value: SelectableText(t.paymentRef),
              ),
              InfoRow(
                label: l.tlCraftgateId,
                value: Text(
                  t.craftgatePaymentId?.toString() ?? dash,
                  key: const Key('craftgate-id'),
                ),
              ),
              InfoRow(
                label: l.tlCard,
                value: Text(_cardText(t.card, dash), key: const Key('card')),
              ),
              InfoRow(
                label: l.tlAutoRelease,
                value: Text(
                  t.autoReleaseAt == null
                      ? dash
                      : formatDateTime(t.autoReleaseAt!, loc, now),
                  key: const Key('auto-release'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.tlEvents, style: AppTypography.cardTitle),
        const SizedBox(height: AppSpacing.xs),
        if (t.events.isEmpty)
          Text(
            l.tlNoEvents,
            key: const Key('timeline-empty'),
            style: AppTypography.bodySecondary,
          )
        else
          for (var i = 0; i < t.events.length; i++)
            _EventTile(
              event: t.events[i],
              last: i == t.events.length - 1,
              now: now,
            ),
      ],
    );
  }

  static String _cardText(AdminPaymentTimelineCard? c, String dash) {
    if (c == null) return dash;
    final masked = c.masked ?? (c.last4 == null ? null : '**** ${c.last4}');
    if (masked == null) return c.brand ?? dash;
    return c.brand == null ? masked : '${c.brand} $masked';
  }
}

/// "Para şu an nerede": Kart → Güvence havuzu → Usta / İade.
class MoneyFlow extends StatelessWidget {
  const MoneyFlow({super.key, required this.location});

  /// `CUSTOMER_CARD`, `BITADILAT_VAULT`, `PRO`, `CUSTOMER_REFUNDED`, `SPLIT`.
  final String location;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (active, endLabel, where) = switch (location) {
      'CUSTOMER_CARD' => (0, l.tlStageRefundOrPro, l.tlWhereCard),
      'BITADILAT_VAULT' => (1, l.tlStageRefundOrPro, l.tlWhereVault),
      'PRO' => (2, l.tlStagePro, l.tlWherePro),
      'CUSTOMER_REFUNDED' => (2, l.tlStageRefund, l.tlWhereRefunded),
      'SPLIT' => (2, l.tlStageSplit, l.tlWhereSplit),
      _ => (-1, l.tlStageRefundOrPro, l.tlWhereUnknown(location)),
    };
    final stages = [
      (Icons.credit_card, l.tlStageCard),
      (Icons.lock_outline, l.tlStageVault),
      (Icons.account_balance_wallet_outlined, endLabel),
    ];
    return AppCard(
      key: const Key('money-flow'),
      semanticLabel: '${l.tlMoneyNow}: $where',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.tlMoneyNow,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            where,
            key: const Key('money-where'),
            style: AppTypography.cardTitle.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < stages.length; i++) ...[
                if (i > 0)
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: i <= active
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                Expanded(
                  child: _Stage(
                    key: Key('stage-$i${i == active ? '-active' : ''}'),
                    icon: stages[i].$1,
                    label: stages[i].$2,
                    active: i == active,
                    passed: i < active,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.passed,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool passed;

  @override
  Widget build(BuildContext context) {
    final color = active || passed
        ? AppColors.primary
        : AppColors.textSecondary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.selectedSurface : Colors.transparent,
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
          width: active ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        children: [
          Icon(passed ? Icons.check_circle : icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String eventLabel(AppLocalizations l, String type) => switch (type) {
  'PAYMENT_INITIALIZED' => l.tlEvPaymentInitialized,
  'THREEDS_STARTED' => l.tlEvThreeds,
  'PAYMENT_LOCKED' => l.tlEvLocked,
  'WORK_DELIVERED' => l.tlEvWorkDelivered,
  'AUTO_RELEASE_SCHEDULED' => l.tlEvAutoReleaseScheduled,
  'DISPUTE_OPENED' => l.tlEvDispute,
  'CUSTOMER_APPROVED' => l.tlEvCustomerApproved,
  'AUTO_APPROVED' => l.tlEvAutoApproved,
  'REFUND_REQUESTED' => l.tlEvRefundRequested,
  'RELEASED_TO_PRO' => l.tlEvReleased,
  'REFUNDED' => l.tlEvRefunded,
  'SPLIT_SETTLED' => l.tlEvSplit,
  'REVIEW_REQUIRED' => l.tlEvReview,
  'FAILED' => l.tlEvFailed,
  _ => l.tlEvUnknown(type),
};

IconData _eventIcon(String type) => switch (type) {
  'PAYMENT_INITIALIZED' => Icons.play_circle_outline,
  'THREEDS_STARTED' => Icons.shield_outlined,
  'PAYMENT_LOCKED' => Icons.lock_outline,
  'WORK_DELIVERED' => Icons.handyman_outlined,
  'AUTO_RELEASE_SCHEDULED' => Icons.schedule,
  'DISPUTE_OPENED' => Icons.flag_outlined,
  'CUSTOMER_APPROVED' || 'AUTO_APPROVED' => Icons.thumb_up_outlined,
  'REFUND_REQUESTED' => Icons.undo,
  'RELEASED_TO_PRO' => Icons.north_east,
  'REFUNDED' => Icons.undo,
  'SPLIT_SETTLED' => Icons.call_split,
  'REVIEW_REQUIRED' => Icons.fact_check_outlined,
  'FAILED' => Icons.error_outline,
  _ => Icons.circle_outlined,
};

Color _eventColor(String type) => switch (type) {
  'FAILED' || 'REVIEW_REQUIRED' => AppColors.error,
  'DISPUTE_OPENED' => AppColors.urgencyText,
  'RELEASED_TO_PRO' => AppColors.success,
  _ => AppColors.primary,
};

String? _noteText(AppLocalizations l, String? note, String loc, DateTime now) {
  if (note == null) return null;
  if (note.startsWith('autoReleaseAt=')) {
    final at = DateTime.tryParse(note.substring('autoReleaseAt='.length));
    return at == null
        ? note
        : l.tlNoteAutoRelease(formatDateTime(at, loc, now));
  }
  return switch (note) {
    'LATE_SUCCESS' => l.tlNoteLateSuccess,
    'ALREADY_REFUNDED_AT_GATEWAY' => l.tlNoteAlreadyRefunded,
    'PAYOUT_NEEDS_REVIEW' => l.tlNotePayoutReview,
    'REFUND_NEEDS_REVIEW' => l.tlNoteRefundReview,
    'PAYMENT_DECLINED' => l.tlNoteDeclined,
    'THREEDS_ABANDONED' => l.tlNote3dsAbandoned,
    'RESULT_UNCERTAIN' => l.tlNoteUncertain,
    _ => note,
  };
}

String? _actorText(AppLocalizations l, String? actor) => switch (actor) {
  null => null,
  'CUSTOMER' => l.roleCustomer,
  'PRO' => l.rolePro,
  'SYSTEM' => l.actorSystem,
  'ADMIN' => l.roleAdmin,
  _ => actor,
};

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.last,
    required this.now,
  });

  final AdminPaymentTimelineEvent event;
  final bool last;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = l.localeName;
    final color = _eventColor(event.type);
    final actor = _actorText(l, event.actor);
    final note = _noteText(l, event.note, loc, now);
    final meta = [formatDateTime(event.at, loc, now), ?actor].join(' · ');
    return IntrinsicHeight(
      key: Key('event-${event.type}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(_eventIcon(event.type), size: 22, color: color),
                if (!last)
                  const Expanded(
                    child: VerticalDivider(width: 1, color: AppColors.border),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          eventLabel(l, event.type),
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (event.amount != null)
                        Text(
                          formatMoney(event.amount!, loc),
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  Text(meta, style: AppTypography.bodySecondary),
                  if (note != null)
                    Text(note, style: AppTypography.bodySecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
