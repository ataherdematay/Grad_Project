import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/action_dialog.dart';
import '../common/labels.dart';
import '../common/media_viewer.dart';
import '../common/widgets.dart';
import 'decision_dialog.dart';

/// Şikayet detayı: kanıt, iş zaman çizelgesi, sohbet, ödeme ve taraflar.
class ComplaintDetailScreen extends ConsumerStatefulWidget {
  const ComplaintDetailScreen({
    super.key,
    required this.complaintId,
    this.openDecision = false,
  });

  final String complaintId;

  /// `/complaints/:id/decision` rotası: veri gelince karar diyaloğunu açar.
  final bool openDecision;

  @override
  ConsumerState<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  bool _busy = false;
  bool _autoOpened = false;

  AdminApi get _api => ref.read(apiClientProvider).admin;

  void _reload() => ref.invalidate(complaintProvider(widget.complaintId));

  Future<void> _run(
    Future<DialogOutcome?> Function() action,
    String doneText,
  ) async {
    if (_busy) return;
    final outcome = await action();
    if (!mounted) return;
    switch (outcome) {
      case DialogOutcome.done:
        _reload();
        showNotice(context, doneText);
      case DialogOutcome.stale:
        _reload();
        showNotice(context, AppLocalizations.of(context).staleNotice);
      case null:
        break;
    }
  }

  /// İstek sürerken sayfadaki eylem düğmeleri kilitlenir.
  Future<T> _track<T>(Future<T> Function() call) async {
    setState(() => _busy = true);
    try {
      return await call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(AdminComplaintDetail d) {
    final l = AppLocalizations.of(context);
    return _run(
      () => confirmAndRun(
        context,
        title: l.reviewComplaintTitle,
        message: l.reviewComplaintMessage(d.publicCode),
        confirmLabel: l.reviewComplaint,
        run: () => _track(() => _api.reviewComplaint(d.id)),
      ),
      l.reviewComplaintDone,
    );
  }

  Future<void> _decide(AdminComplaintDetail d) {
    final l = AppLocalizations.of(context);
    return _run(
      () => showDecisionDialog(
        context,
        complaint: d,
        onSubmit: (req) => _track(() => _api.decideComplaint(d.id, req)),
      ),
      l.decisionDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(complaintProvider(widget.complaintId));
    final detail = value.asData?.value;
    if (widget.openDecision && !_autoOpened && detail != null) {
      _autoOpened = true;
      if (detail.status == ComplaintStatus.open ||
          detail.status == ComplaintStatus.inReview) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _decide(detail);
        });
      }
    }
    return PageScroll(
      title: detail == null
          ? l.complaintDetailTitle
          : l.complaintDetailHeading(detail.publicCode),
      subtitle: detail?.job.title,
      leading: AppIconButton(
        icon: Icons.arrow_back,
        tooltip: l.back,
        onPressed: () => context.go(Routes.complaints),
      ),
      children: [
        AsyncBody(
          value: value,
          onRetry: _reload,
          data: (d) => LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final main = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComplaintCard(detail: d),
                  const SizedBox(height: AppSpacing.md),
                  _TimelineCard(detail: d),
                  const SizedBox(height: AppSpacing.md),
                  _ChatCard(detail: d),
                ],
              );
              final side = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionCard(
                    detail: d,
                    busy: _busy,
                    onReview: () => _review(d),
                    onDecide: () => _decide(d),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PaymentCard(detail: d),
                  const SizedBox(height: AppSpacing.md),
                  _PartiesCard(detail: d),
                ],
              );
              if (!wide) {
                return Column(
                  children: [
                    side,
                    const SizedBox(height: AppSpacing.md),
                    main,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: main),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: side),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ComplaintCard extends ConsumerWidget {
  const _ComplaintCard({required this.detail});

  final AdminComplaintDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    return SectionCard(
      title: l.complaintSection,
      trailing: complaintStatusChip(l, detail.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            label: l.colReason,
            value: Text(complaintReasonLabel(l, detail.reason)),
          ),
          InfoRow(
            label: l.colDate,
            value: Text(formatDateTime(detail.createdAt, l.localeName, now)),
          ),
          InfoRow(label: l.descriptionLabel, value: Text(detail.description)),
          const SizedBox(height: AppSpacing.xs),
          Text(l.evidenceTitle, style: AppTypography.label),
          const SizedBox(height: 6),
          if (detail.evidence.isEmpty)
            Text(l.evidenceEmpty, style: AppTypography.bodySecondary)
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final m in detail.evidence)
                  SizedBox(
                    width: 140,
                    child: InkWell(
                      key: Key('evidence-${m.id}'),
                      onTap: () => showMediaViewer(context, m, l.evidenceTitle),
                      child: MediaThumbnail(media: m, height: 100),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TimelineCard extends ConsumerWidget {
  const _TimelineCard({required this.detail});

  final AdminComplaintDetail detail;

  String _eventText(AppLocalizations l, JobEvent e) {
    switch (e.type) {
      case JobEventType.statusChanged:
        final to = e.toStatus == null ? '' : jobStatusLabel(l, e.toStatus!);
        return e.fromStatus == null
            ? to
            : '${jobStatusLabel(l, e.fromStatus!)} → $to';
      case JobEventType.note:
        return e.note ?? l.eventNote;
      case JobEventType.photo:
        return e.note ?? l.eventPhoto;
      case JobEventType.appointmentProposed:
        return l.eventAppointmentProposed;
      case JobEventType.appointmentAccepted:
        return l.eventAppointmentAccepted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    final job = detail.job;
    return SectionCard(
      title: l.timelineTitle,
      trailing: Text(job.publicCode, style: AppTypography.label),
      child: job.timeline.isEmpty
          ? Text(l.timelineEmpty, style: AppTypography.bodySecondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in job.timeline)
                  Padding(
                    key: Key('event-${e.id}'),
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            top: 3,
                            right: AppSpacing.xs,
                          ),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_eventText(l, e), style: AppTypography.body),
                              Text(
                                '${actorRoleLabel(l, e.actorRole)} · '
                                '${formatDateTime(e.createdAt, l.localeName, now)}',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (e.photo != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: SizedBox(
                                    width: 140,
                                    child: InkWell(
                                      onTap: () => showMediaViewer(
                                        context,
                                        e.photo!,
                                        l.eventPhoto,
                                      ),
                                      child: MediaThumbnail(
                                        media: e.photo!,
                                        height: 90,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ChatCard extends ConsumerWidget {
  const _ChatCard({required this.detail});

  final AdminComplaintDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    return SectionCard(
      title: l.chatTitle,
      child: detail.messages.isEmpty
          ? Text(l.chatEmpty, style: AppTypography.bodySecondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final m in detail.messages)
                  Padding(
                    key: Key('message-${m.id}'),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: m.senderRole == PartyRole.pro
                            ? AppColors.selectedSurface
                            : AppColors.neutralSurface,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${partyRoleLabel(l, m.senderRole)} · '
                            '${formatDateTime(m.createdAt, l.localeName, now)}',
                            style: AppTypography.label.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (m.body.isNotEmpty) Text(m.body),
                          if (m.photo != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: SizedBox(
                                width: 140,
                                child: InkWell(
                                  onTap: () => showMediaViewer(
                                    context,
                                    m.photo!,
                                    l.eventPhoto,
                                  ),
                                  child: MediaThumbnail(
                                    media: m.photo!,
                                    height: 90,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ActionCard extends ConsumerWidget {
  const _ActionCard({
    required this.detail,
    required this.busy,
    required this.onReview,
    required this.onDecide,
  });

  final AdminComplaintDetail detail;
  final bool busy;
  final VoidCallback onReview;
  final VoidCallback onDecide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    final decided =
        detail.status == ComplaintStatus.resolved ||
        detail.status == ComplaintStatus.dismissed;
    if (decided) {
      final d = ComplaintDecision.tryParse(detail.decision);
      return SectionCard(
        title: l.decisionResultTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              d == null ? (detail.decision ?? '-') : decisionLabel(l, d),
              style: AppTypography.cardTitle,
            ),
            if (detail.decidedAt != null)
              Text(
                formatDateTime(detail.decidedAt!, l.localeName, now),
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (detail.refundAmount != null)
              InfoRow(
                label: l.outcomeCustomerRefund,
                value: Text(
                  formatMoney(detail.refundAmount!, l.localeName),
                  key: const Key('result-refund'),
                ),
              ),
            if (detail.proAmount != null)
              InfoRow(
                label: l.outcomeProPayout,
                value: Text(
                  formatMoney(detail.proAmount!, l.localeName),
                  key: const Key('result-pro'),
                ),
              ),
            if (detail.warnPro)
              Text(
                l.decisionResultWarned,
                key: const Key('result-warned'),
                style: AppTypography.bodySecondary,
              ),
            if (detail.suspendPro)
              Text(
                l.decisionResultSuspended,
                key: const Key('result-suspended'),
                style: AppTypography.bodySecondary,
              ),
            if (detail.decisionNote != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(detail.decisionNote!, style: AppTypography.bodySecondary),
            ],
          ],
        ),
      );
    }
    return SectionCard(
      title: l.decisionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (detail.status == ComplaintStatus.open) ...[
            AppButton(
              key: const Key('review-complaint'),
              label: l.reviewComplaint,
              icon: Icons.manage_search,
              variant: AppButtonVariant.secondary,
              isLoading: busy,
              onPressed: onReview,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          AppButton(
            key: const Key('decide-complaint'),
            label: l.decide,
            icon: Icons.gavel,
            onPressed: busy ? null : onDecide,
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.detail});

  final AdminComplaintDetail detail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = detail.payment;
    final loc = l.localeName;
    if (p == null) {
      return SectionCard(
        title: l.paymentSummaryTitle,
        child: Text(
          l.paymentMissing,
          key: const Key('payment-missing'),
          style: AppTypography.bodySecondary,
        ),
      );
    }
    return SectionCard(
      title: l.paymentSummaryTitle,
      trailing: escrowChip(l, p.status),
      child: Column(
        children: [
          InfoRow(label: l.colRef, value: SelectableText(p.ref)),
          InfoRow(label: l.colProvider, value: Text(p.provider)),
          InfoRow(
            label: l.colTotal,
            value: Text(formatMoney(p.totalAmount, loc)),
          ),
          InfoRow(
            label: l.colServiceFee,
            value: Text(formatMoney(p.commission, loc)),
          ),
          InfoRow(
            label: l.colProPayout,
            value: Text(formatMoney(p.proPayout, loc)),
          ),
          InfoRow(
            label: l.colRefunded,
            value: Text(formatMoney(p.refundedAmount, loc)),
          ),
        ],
      ),
    );
  }
}

class _PartiesCard extends StatelessWidget {
  const _PartiesCard({required this.detail});

  final AdminComplaintDetail detail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pro = detail.pro;
    return SectionCard(
      title: l.partiesTitle,
      child: Column(
        children: [
          InfoRow(label: l.roleCustomer, value: Text(detail.customer.fullName)),
          InfoRow(
            label: l.rolePro,
            value: Text('${pro.businessName} (${pro.fullName})'),
          ),
          InfoRow(
            label: l.warningCount,
            value: Text('${pro.warningCount}', key: const Key('pro-warnings')),
          ),
          InfoRow(
            label: l.cancellationCount,
            value: Text(
              '${pro.cancellationCount}',
              key: const Key('pro-cancellations'),
            ),
          ),
        ],
      ),
    );
  }
}
