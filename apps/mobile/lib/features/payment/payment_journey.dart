import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../core/payment_data.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../jobs/job_ui.dart';

// =============================================================================
// Metin ve ikon eşlemeleri (saf işlevler)
// =============================================================================

/// "Para şu an:" değeri. Usta görünümünde kart müşterinindir.
String moneyLocationLabel(
  AppLocalizations l,
  MoneyLocation loc, {
  bool pro = false,
}) => switch (loc) {
  MoneyLocation.customerCard =>
    pro ? l.moneyLocCustomerCardPro : l.moneyLocCustomerCard,
  MoneyLocation.vault => l.moneyLocVault,
  MoneyLocation.pro => pro ? l.moneyLocProPro : l.moneyLocPro,
  MoneyLocation.customerRefunded =>
    pro ? l.moneyLocRefundedPro : l.moneyLocRefunded,
  MoneyLocation.split => l.moneyLocSplit,
  MoneyLocation.unknown => l.moneyLocVault,
};

String moneyLocationExplanation(
  AppLocalizations l,
  MoneyLocation loc, {
  bool pro = false,
}) => switch (loc) {
  MoneyLocation.customerCard =>
    pro ? l.journeyExplainCardPro : l.journeyExplainCard,
  MoneyLocation.vault => pro ? l.journeyExplainVaultPro : l.journeyExplainVault,
  MoneyLocation.pro => pro ? l.journeyExplainProPro : l.journeyExplainPro,
  MoneyLocation.customerRefunded =>
    pro ? l.journeyExplainRefundedPro : l.journeyExplainRefunded,
  MoneyLocation.split => pro ? l.journeyExplainSplitPro : l.journeyExplainSplit,
  MoneyLocation.unknown =>
    pro ? l.journeyExplainVaultPro : l.journeyExplainVault,
};

IconData moneyLocationIcon(MoneyLocation loc) => switch (loc) {
  MoneyLocation.customerCard => Icons.credit_card,
  MoneyLocation.vault => Icons.lock_outline,
  MoneyLocation.pro => Icons.check_circle_outline,
  MoneyLocation.customerRefunded => Icons.undo,
  MoneyLocation.split => Icons.call_split,
  MoneyLocation.unknown => Icons.help_outline,
};

StatusTone moneyLocationTone(MoneyLocation loc) => switch (loc) {
  MoneyLocation.customerCard => StatusTone.neutral,
  MoneyLocation.vault => StatusTone.info,
  MoneyLocation.pro => StatusTone.success,
  MoneyLocation.customerRefunded => StatusTone.primary,
  MoneyLocation.split => StatusTone.urgent,
  MoneyLocation.unknown => StatusTone.neutral,
};

Color _toneColor(StatusTone t) => switch (t) {
  StatusTone.info => AppColors.infoText,
  StatusTone.primary => AppColors.primary,
  StatusTone.urgent => AppColors.urgencyText,
  StatusTone.success => AppColors.success,
  StatusTone.error => AppColors.error,
  StatusTone.neutral => AppColors.textSecondary,
};

Color _toneBg(StatusTone t) => switch (t) {
  StatusTone.info => const Color(0xFFE6F1F6),
  StatusTone.primary => const Color(0xFFE3EEF0),
  StatusTone.urgent => const Color(0xFFFDF1E9),
  StatusTone.success => const Color(0xFFE7F3EF),
  StatusTone.error => const Color(0xFFF8E7E5),
  StatusTone.neutral => AppColors.neutralSurface,
};

String eventTitle(AppLocalizations l, PaymentEvent e, {bool pro = false}) =>
    switch (e.type) {
      PaymentEventType.paymentInitialized => l.journeyEvtInitialized,
      PaymentEventType.threedsStarted => l.journeyEvtThreeds,
      PaymentEventType.paymentLocked => l.journeyEvtLocked,
      PaymentEventType.workDelivered => l.journeyEvtDelivered,
      PaymentEventType.autoReleaseScheduled => l.journeyEvtScheduled,
      PaymentEventType.disputeOpened => l.journeyEvtDispute,
      PaymentEventType.customerApproved =>
        pro ? l.journeyEvtApprovedPro : l.journeyEvtApproved,
      PaymentEventType.autoApproved => l.journeyEvtAutoApproved,
      PaymentEventType.refundRequested => l.journeyEvtRefundRequested,
      PaymentEventType.releasedToPro =>
        pro ? l.journeyEvtReleasedPro : l.journeyEvtReleased,
      PaymentEventType.refunded =>
        pro ? l.journeyEvtRefundedPro : l.journeyEvtRefunded,
      PaymentEventType.splitSettled => l.journeyEvtSplit,
      PaymentEventType.reviewRequired => l.journeyEvtReview,
      PaymentEventType.failed => l.journeyEvtFailed,
      PaymentEventType.unknown => l.journeyEvtUnknown,
    };

/// `note` bir makine kodudur; bilinen kodlar çevrilir, bilinmeyen gizlenir.
String? eventNote(AppLocalizations l, PaymentEvent e) => switch (e.note) {
  'LATE_SUCCESS' => l.journeyNoteLateSuccess,
  'ALREADY_REFUNDED_AT_GATEWAY' => l.journeyNoteAlreadyRefunded,
  'PAYOUT_NEEDS_REVIEW' => l.journeyNotePayoutReview,
  'REFUND_NEEDS_REVIEW' => l.journeyNoteRefundReview,
  'PAYMENT_DECLINED' => l.journeyNoteDeclined,
  'THREEDS_ABANDONED' => l.journeyNoteThreedsAbandoned,
  'RESULT_UNCERTAIN' => l.journeyNoteUncertain,
  _ => null,
};

(IconData, StatusTone) eventStyle(PaymentEventType t) => switch (t) {
  PaymentEventType.paymentInitialized => (
    Icons.credit_card,
    StatusTone.neutral,
  ),
  PaymentEventType.threedsStarted => (
    Icons.verified_user_outlined,
    StatusTone.neutral,
  ),
  PaymentEventType.paymentLocked => (Icons.lock_outline, StatusTone.info),
  PaymentEventType.workDelivered => (
    Icons.handyman_outlined,
    StatusTone.primary,
  ),
  PaymentEventType.autoReleaseScheduled => (Icons.schedule, StatusTone.info),
  PaymentEventType.disputeOpened => (Icons.report_outlined, StatusTone.error),
  PaymentEventType.customerApproved => (
    Icons.thumb_up_alt_outlined,
    StatusTone.success,
  ),
  PaymentEventType.autoApproved => (Icons.timer_outlined, StatusTone.success),
  PaymentEventType.refundRequested => (Icons.undo, StatusTone.urgent),
  PaymentEventType.releasedToPro => (
    Icons.check_circle_outline,
    StatusTone.success,
  ),
  PaymentEventType.refunded => (Icons.undo, StatusTone.primary),
  PaymentEventType.splitSettled => (Icons.call_split, StatusTone.urgent),
  PaymentEventType.reviewRequired => (
    Icons.support_agent_outlined,
    StatusTone.urgent,
  ),
  PaymentEventType.failed => (Icons.error_outline, StatusTone.error),
  PaymentEventType.unknown => (Icons.circle_outlined, StatusTone.neutral),
};

/// Otomatik aktarıma kalan süre: kalan sıfırın altındaysa `due`.
({int hours, int minutes, bool due}) countdownParts(
  DateTime autoReleaseAt,
  DateTime now,
) {
  final left = autoReleaseAt.difference(now);
  if (left.inSeconds <= 0) return (hours: 0, minutes: 0, due: true);
  // Dakikaya yukarı yuvarlanır: "0 sa 0 dk" görünmez.
  final totalMinutes = (left.inSeconds + 59) ~/ 60;
  return (hours: totalMinutes ~/ 60, minutes: totalMinutes % 60, due: false);
}

/// Kullanıcıya gösterilecek "bekleyen işlem" etiketi (iade/aktarım kuyruğu ya
/// da destek incelemesi); yoksa `null`.
String? pendingLabel(
  AppLocalizations l,
  PaymentTimeline t, {
  bool pro = false,
}) {
  if (t.needsReview) return l.escrowReview;
  if (t.status == EscrowStatus.locked) {
    if (t.pendingAction == 'REFUND') {
      return pro ? l.escrowRefundPendingPro : l.escrowRefundPending;
    }
    if (t.pendingAction == 'RELEASE') return l.escrowPayoutPending;
  }
  return null;
}

// =============================================================================
// Görsel parçalar
// =============================================================================

/// "Sandbox (test)" etiketi.
class SandboxChip extends StatelessWidget {
  const SandboxChip({super.key});

  @override
  Widget build(BuildContext context) => StatusChip(
    label: AppLocalizations.of(context).journeySandboxChip,
    icon: Icons.science_outlined,
    tone: StatusTone.urgent,
  );
}

enum _NodeState { idle, passed, active }

List<_NodeState> _nodeStates(MoneyLocation loc) => switch (loc) {
  MoneyLocation.customerCard => [
    _NodeState.active,
    _NodeState.idle,
    _NodeState.idle,
  ],
  MoneyLocation.vault => [
    _NodeState.passed,
    _NodeState.active,
    _NodeState.idle,
  ],
  MoneyLocation.pro => [
    _NodeState.passed,
    _NodeState.passed,
    _NodeState.active,
  ],
  MoneyLocation.customerRefunded => [
    _NodeState.active,
    _NodeState.passed,
    _NodeState.idle,
  ],
  MoneyLocation.split => [
    _NodeState.active,
    _NodeState.passed,
    _NodeState.active,
  ],
  MoneyLocation.unknown => [_NodeState.idle, _NodeState.idle, _NodeState.idle],
};

/// Kart → Güvence kasası → Usta. Paranın bulunduğu düğüm vurgulanır, geçtiği
/// düğümler onaylı gösterilir. Renk tek başına anlam taşımaz: etkin düğümde
/// ikon dolu daire, geçilenlerde onay işareti olur.
class MoneyFlowDiagram extends StatelessWidget {
  const MoneyFlowDiagram({super.key, required this.location, this.pro = false});

  final MoneyLocation location;
  final bool pro;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final states = _nodeStates(location);
    final labels = [
      pro ? l.journeyNodeCardPro : l.journeyNodeCard,
      l.journeyNodeVault,
      pro ? l.journeyNodeProPro : l.journeyNodePro,
    ];
    final icons = [
      pro ? Icons.person_outline : Icons.credit_card,
      Icons.lock_outline,
      pro ? Icons.person : Icons.handyman_outlined,
    ];
    Widget connector(bool lit) => Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            color: lit ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      label:
          '${labels.join(' > ')}. '
          '${l.journeyNowLabel}: ${moneyLocationLabel(l, location, pro: pro)}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FlowNode(label: labels[0], icon: icons[0], state: states[0]),
          connector(states[1] != _NodeState.idle),
          _FlowNode(label: labels[1], icon: icons[1], state: states[1]),
          connector(states[2] != _NodeState.idle),
          _FlowNode(label: labels[2], icon: icons[2], state: states[2]),
        ],
      ),
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.label,
    required this.icon,
    required this.state,
  });

  final String label;
  final IconData icon;
  final _NodeState state;

  @override
  Widget build(BuildContext context) {
    final active = state == _NodeState.active;
    final passed = state == _NodeState.passed;
    final bg = active
        ? AppColors.primary
        : (passed ? const Color(0xFFE3EEF0) : AppColors.neutralSurface);
    final fg = active
        ? Colors.white
        : (passed ? AppColors.primary : AppColors.textSecondary);
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? AppColors.primaryDark : AppColors.border,
                      width: active ? 2 : 1,
                    ),
                  ),
                  child: Icon(icon, color: fg, size: 24),
                ),
                if (passed)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.weight(
              AppTypography.label.copyWith(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Büyük durum kartı: "Para şu an: …", açıklama, 3 düğümlü görsel.
class MoneyStatusCard extends StatelessWidget {
  const MoneyStatusCard({super.key, required this.timeline, this.pro = false});

  final PaymentTimeline timeline;
  final bool pro;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = timeline.moneyLocation;
    final tone = moneyLocationTone(loc);
    final pending = pendingLabel(l, timeline, pro: pro);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.journeyNowLabel,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _toneBg(tone),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  moneyLocationIcon(loc),
                  color: _toneColor(tone),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    moneyLocationLabel(l, loc, pro: pro),
                    style: AppTypography.section,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            moneyLocationExplanation(l, loc, pro: pro),
            style: AppTypography.bodySecondary,
          ),
          if (pending != null) ...[
            const SizedBox(height: AppSpacing.xs),
            StatusChip(
              label: pending,
              icon: Icons.hourglass_top,
              tone: StatusTone.urgent,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          MoneyFlowDiagram(location: loc, pro: pro),
        ],
      ),
    );
  }
}

/// `autoReleaseAt` geri sayımı. Dakikada bir yenilenir; zaman kaynağı
/// [nowProvider]dır.
class AutoReleaseCountdown extends ConsumerStatefulWidget {
  const AutoReleaseCountdown({
    super.key,
    required this.autoReleaseAt,
    this.pro = false,
  });

  final DateTime autoReleaseAt;
  final bool pro;

  @override
  ConsumerState<AutoReleaseCountdown> createState() => _CountdownState();
}

class _CountdownState extends ConsumerState<AutoReleaseCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = countdownParts(widget.autoReleaseAt, ref.read(nowProvider)());
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.timer_outlined, color: AppColors.urgencyText),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.journeyCountdownTitle, style: AppTypography.cardTitle),
                const SizedBox(height: 2),
                Text(
                  c.due
                      ? l.journeyCountdownDue
                      : l.journeyCountdownValue(c.hours, c.minutes),
                  style: AppTypography.section.copyWith(
                    color: AppColors.urgencyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pro
                      ? l.journeyCountdownNotePro
                      : l.journeyCountdownNote,
                  style: AppTypography.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Olay listesi: ikon, başlık, saat, tutar. Bilinmeyen tür genel satır olur.
class PaymentEventList extends ConsumerWidget {
  const PaymentEventList({super.key, required this.events, this.pro = false});

  final List<PaymentEvent> events;
  final bool pro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _EventRow(
            event: events[i],
            last: i == events.length - 1,
            title: eventTitle(l, events[i], pro: pro),
            note: eventNote(l, events[i]),
            when: formatDayTime(l, events[i].at, now),
            amount: events[i].amount == null
                ? null
                : formatMoney(events[i].amount!, l.localeName),
          ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.last,
    required this.title,
    required this.note,
    required this.when,
    required this.amount,
  });

  final PaymentEvent event;
  final bool last;
  final String title;
  final String? note;
  final String when;
  final String? amount;

  @override
  Widget build(BuildContext context) {
    final (icon, tone) = eventStyle(event.type);
    return Semantics(
      container: true,
      label: [title, ?note, when, ?amount].join(', '),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _toneBg(tone),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: _toneColor(tone)),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(width: 2, color: AppColors.border),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(title, style: AppTypography.body),
                          ),
                          if (note != null)
                            Text(note!, style: AppTypography.bodySecondary),
                          Text(when, style: AppTypography.label),
                        ],
                      ),
                    ),
                    if (amount != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(amount!, style: AppTypography.cardTitle),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Ekran: /c/jobs/:id/payment ve /p/jobs/:id/payment
// =============================================================================

/// Paranın yolculuğu. Müşteri ve usta aynı ekranı kendi alanlarıyla görür:
/// müşteri kartı ve makbuzu, usta hizmet bedelini ve net kazancı görür.
class PaymentJourneyScreen extends ConsumerWidget {
  const PaymentJourneyScreen({
    super.key,
    required this.jobId,
    this.pro = false,
  });

  final String jobId;
  final bool pro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(paymentTimelineProvider(jobId));
    final back = pro ? '/p/jobs/$jobId' : '/c/jobs/$jobId';
    return StackFallback(
      fallback: back,
      child: ListPage(
        title: l.journeyTitle,
        leading: AppBackButton(fallback: back),
        body: AsyncView<PaymentTimeline>(
          value: async,
          onRetry: () => ref.invalidate(paymentTimelineProvider(jobId)),
          builder: (context, t) =>
              _JourneyBody(timeline: t, jobId: jobId, pro: pro),
        ),
      ),
    );
  }
}

class _JourneyBody extends ConsumerWidget {
  const _JourneyBody({
    required this.timeline,
    required this.jobId,
    required this.pro,
  });

  final PaymentTimeline timeline;
  final String jobId;
  final bool pro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = timeline;
    String m(Money v) => formatMoney(v, l.localeName);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(paymentTimelineProvider(jobId).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if ((t.jobTitle ?? '').isNotEmpty)
            Text(t.jobTitle!, style: AppTypography.section),
          if ((t.jobPublicCode ?? '').isNotEmpty)
            Text(t.jobPublicCode!, style: AppTypography.bodySecondary),
          if (t.sandbox) ...[
            const SizedBox(height: AppSpacing.xs),
            const Align(alignment: Alignment.centerLeft, child: SandboxChip()),
          ],
          const SizedBox(height: AppSpacing.md),
          MoneyStatusCard(timeline: t, pro: pro),
          if (t.autoReleaseAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AutoReleaseCountdown(autoReleaseAt: t.autoReleaseAt!, pro: pro),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.journeyAmountsTitle, style: AppTypography.cardTitle),
                const SizedBox(height: 4),
                InfoRow(l.totalVatIncluded, m(t.amounts.gross), bold: true),
                if (t.amounts.refunded.isPositive)
                  InfoRow(l.refundedLabel, m(t.amounts.refunded)),
                if (pro && t.amounts.commission != null)
                  InfoRow(l.serviceFeeLabel, m(t.amounts.commission!)),
                if (pro && t.amounts.proNet != null)
                  InfoRow(l.netEarningLabel, m(t.amounts.proNet!)),
                if (!pro && t.card != null)
                  InfoRow(
                    l.journeyCardLabel,
                    [?t.card!.brand, t.card!.masked].join(' '),
                  ),
              ],
            ),
          ),
          if (!pro) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l.journeyViewReceipt,
              icon: Icons.receipt_long_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/c/jobs/$jobId/receipt'),
            ),
          ],
          sectionTitle(l.journeyEventsTitle),
          PaymentEventList(events: t.events, pro: pro),
        ],
      ),
    );
  }
}

// =============================================================================
// İş detayı kartı
// =============================================================================

/// İş detayında kısa "Paranın yolculuğu" kartı. Veri gelene kadar ya da
/// hata durumunda yalnız başlık ve ok görünür; dokununca tam ekran açılır.
class MoneyJourneyCard extends ConsumerWidget {
  const MoneyJourneyCard({super.key, required this.jobId, this.pro = false});

  final String jobId;
  final bool pro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = ref.watch(paymentTimelineProvider(jobId)).value;
    final path = pro ? '/p/jobs/$jobId/payment' : '/c/jobs/$jobId/payment';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          onTap: () => context.push(path),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.route_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(l.journeyTitle, style: AppTypography.cardTitle),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (t != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${l.journeyNowLabel}: '
                  '${moneyLocationLabel(l, t.moneyLocation, pro: pro)}',
                  style: AppTypography.body,
                ),
                if (t.autoReleaseAt != null) ...[
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final c = countdownParts(
                        t.autoReleaseAt!,
                        ref.read(nowProvider)(),
                      );
                      return Text(
                        c.due
                            ? l.journeyCountdownDue
                            : '${l.journeyCountdownTitle}: '
                                  '${l.journeyCountdownValue(c.hours, c.minutes)}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.urgencyText,
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                MoneyFlowDiagram(location: t.moneyLocation, pro: pro),
              ],
            ],
          ),
        ),
        if (!pro) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: l.journeyViewReceipt,
            icon: Icons.receipt_long_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/c/jobs/$jobId/receipt'),
          ),
        ],
      ],
    );
  }
}
