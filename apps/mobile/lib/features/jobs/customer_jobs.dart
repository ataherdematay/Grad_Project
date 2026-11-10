import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/formatters.dart';
import '../../core/photos.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import 'job_ui.dart';

// =============================================================================
// 23, 25: İş alanı
// =============================================================================

/// `/c/jobs/:id`
class CustomerJobScreen extends ConsumerWidget {
  const CustomerJobScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(id));
    return StackFallback(
      fallback: '/c/requests',
      child: ListPage(
        title: l.jobScreenTitle,
        leading: const AppBackButton(fallback: '/c/requests'),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(id)),
          builder: (context, job) => _CustomerJobBody(job: job),
        ),
      ),
    );
  }
}

class _CustomerJobBody extends ConsumerStatefulWidget {
  const _CustomerJobBody({required this.job});

  final JobDetail job;

  @override
  ConsumerState<_CustomerJobBody> createState() => _CustomerJobBodyState();
}

class _CustomerJobBodyState extends ConsumerState<_CustomerJobBody> {
  bool _busy = false;

  JobDetail get job => widget.job;

  Future<void> _go(String path) async {
    await context.push(path);
    if (mounted) invalidateJobData(ref);
  }

  Future<void> _acceptProposal() async {
    final p = job.appointment.pendingProposal;
    if (_busy || p == null) return;
    setState(() => _busy = true);
    final refresh = jobDataInvalidator(ref);
    try {
      await ref.read(apiClientProvider).jobs.acceptProposal(job.id, p.id);
      refresh();
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    final p = job.appointment.pendingProposal;
    final canAccept = job.can(JobAction.acceptProposal) && p != null;
    final scheduled = job.appointment.scheduledFrom != null;
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(jobProvider(job.id).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(job.title, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              jobStatusChip(l, job.status, job.viewerRole),
              StatusChip(
                label: job.counterpart.displayName,
                icon: Icons.handyman_outlined,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(job.publicCode, style: AppTypography.bodySecondary),
          if (job.status == JobStatus.workFinished &&
              job.autoCompleteAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.completeAutoNote(formatDayTime(l, job.autoCompleteAt!, now)),
              style: AppTypography.label,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppointmentCard(job: job),
          const SizedBox(height: AppSpacing.md),
          if (canAccept)
            AppButton(
              label: l.proposalAccept,
              isLoading: _busy,
              onPressed: _acceptProposal,
            ),
          if (job.can(JobAction.proposeSlot))
            AppButton(
              label: canAccept
                  ? l.proposalOther
                  : (scheduled ? l.appointmentChange : l.appointmentChoose),
              variant: canAccept || scheduled
                  ? AppButtonVariant.secondary
                  : AppButtonVariant.primary,
              onPressed: () => _go('/c/jobs/${job.id}/appointment'),
            ),
          if (job.can(JobAction.confirmCompletion))
            AppButton(
              label: l.confirmCompletion,
              onPressed: () async {
                await context.push('/c/jobs/${job.id}/complete');
                if (mounted) invalidateJobData(ref);
              },
            ),
          if (job.can(JobAction.review))
            AppButton(
              label: l.reviewAction,
              onPressed: () => _go('/c/jobs/${job.id}/review'),
            ),
          const SizedBox(height: AppSpacing.xs),
          if (job.can(JobAction.chat))
            ChatEntryCard(job: job, onReturn: () => invalidateJobData(ref)),
          if (job.complaint != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              onTap: () => _go('/c/complaints/${job.complaint!.id}'),
              child: Row(
                children: [
                  const Icon(Icons.report_outlined, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.complaintCardTitle(job.complaint!.publicCode),
                          style: AppTypography.cardTitle,
                        ),
                        Text(
                          complaintStatusLabel(l, job.complaint!.status),
                          style: AppTypography.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ],
          sectionTitle(l.addressTitle),
          AddressCard(address: job.address),
          const SizedBox(height: AppSpacing.sm),
          OfferSummaryCard(job: job),
          const SizedBox(height: AppSpacing.sm),
          PaymentSummaryCard(job: job),
          if (job.review != null) ...[
            sectionTitle(l.yourReview),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: l.starsCount(job.review!.rating),
                    child: Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          Icon(
                            i <= job.review!.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.urgency,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                  if ((job.review!.comment ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        job.review!.comment!,
                        style: AppTypography.body,
                      ),
                    ),
                ],
              ),
            ),
          ],
          TimelineView(job: job),
          const SizedBox(height: AppSpacing.md),
          if (job.can(JobAction.complain))
            AppButton(
              label: l.complainAction,
              variant: AppButtonVariant.secondary,
              onPressed: () => _go('/c/jobs/${job.id}/complaint'),
            ),
          if (job.can(JobAction.cancel))
            AppButton(
              label: l.cancelJobAction,
              variant: AppButtonVariant.tertiary,
              onPressed: () => _go('/c/jobs/${job.id}/cancel'),
            ),
        ],
      ),
    );
  }
}

String complaintStatusLabel(AppLocalizations l, ComplaintStatus s) =>
    switch (s) {
      ComplaintStatus.open => l.complaintStatusOpen,
      ComplaintStatus.inReview => l.complaintStatusInReview,
      ComplaintStatus.resolved => l.complaintStatusResolved,
      ComplaintStatus.dismissed => l.complaintStatusDismissed,
    };

// =============================================================================
// 21, 22: Randevu (müşteri ve usta ortak)
// =============================================================================

/// `/c/jobs/:id/appointment` ve `/p/jobs/:id/appointment`.
class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key, required this.jobId, this.pro = false});

  final String jobId;
  final bool pro;

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentState();
}

class _AppointmentState extends ConsumerState<AppointmentScreen> {
  DateTime? _day;
  SlotWindow? _selected;
  bool _initialised = false;
  bool _busy = false;

  String get _jobPath =>
      widget.pro ? '/p/jobs/${widget.jobId}' : '/c/jobs/${widget.jobId}';

  /// Gün → aralıklar. Teklifteki varış aralığı kendi gününe eklenir.
  List<MapEntry<DateTime, List<SlotWindow>>> _days(
    JobDetail job,
    DateTime now,
  ) {
    final map = <DateTime, List<SlotWindow>>{
      for (final e in upcomingSlotDays(now)) e.key: [...e.value],
    };
    final w = _offerWindow(job, now);
    if (w != null) {
      final key = DateTime(w.from.year, w.from.month, w.from.day);
      final list = map.putIfAbsent(key, () => []);
      if (!list.contains(w)) list.add(w);
      list.sort((a, b) => a.from.compareTo(b.from));
    }
    return map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  SlotWindow? _offerWindow(JobDetail job, DateTime now) {
    final from = job.offer.arrivalFrom.toLocal();
    final to = job.offer.arrivalTo.toLocal();
    if (!from.isAfter(now)) return null;
    if (to.difference(from) > const Duration(hours: 12)) return null;
    return SlotWindow(from, to);
  }

  void _init(JobDetail job, DateTime now) {
    if (_initialised) return;
    _initialised = true;
    final w = _offerWindow(job, now);
    if (w != null) {
      _selected = w;
      _day = DateTime(w.from.year, w.from.month, w.from.day);
    } else {
      final days = _days(job, now);
      _day = days.isEmpty ? null : days.first.key;
    }
  }

  /// Kayıttan sonra: veri yenilenir; ekran hâlâ açıksa iş ekranına gidilir.
  void _done(VoidCallback refresh) {
    refresh();
    if (mounted) context.go(_jobPath);
  }

  Future<void> _propose(JobDetail job) async {
    final s = _selected;
    if (_busy || s == null) return;
    setState(() => _busy = true);
    final refresh = jobDataInvalidator(ref);
    try {
      await ref
          .read(apiClientProvider)
          .jobs
          .proposeSlot(
            job.id,
            ProposeSlotRequest(slotFrom: s.from.toUtc(), slotTo: s.to.toUtc()),
          );
      _done(refresh);
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _accept(JobDetail job) async {
    final p = job.appointment.pendingProposal;
    if (_busy || p == null) return;
    setState(() => _busy = true);
    final refresh = jobDataInvalidator(ref);
    try {
      await ref.read(apiClientProvider).jobs.acceptProposal(job.id, p.id);
      _done(refresh);
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(widget.jobId));
    final now = ref.read(nowProvider)();
    return StackFallback(
      fallback: _jobPath,
      child: ListPage(
        title: widget.pro ? l.appointmentProTitle : l.appointmentTitle,
        leading: AppBackButton(fallback: _jobPath),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(widget.jobId)),
          builder: (context, job) {
            _init(job, now);
            final p = job.appointment.pendingProposal;
            final canAccept = job.can(JobAction.acceptProposal) && p != null;
            final canPropose = job.can(JobAction.proposeSlot);
            final days = _days(job, now);
            final offerWindow = _offerWindow(job, now);
            final slots = days
                .where((e) => e.key == _day)
                .expand((e) => e.value)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  widget.pro ? l.appointmentProIntro : l.appointmentIntro,
                  style: AppTypography.body,
                ),
                if (p != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.proposedBy == job.viewerRole
                              ? l.proposalMine
                              : (widget.pro
                                    ? l.proposalFromCustomer
                                    : l.proposalFromPro),
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatWindow(l, p.slotFrom, p.slotTo, now),
                          style: AppTypography.cardTitle,
                        ),
                        if (canAccept) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            label: l.proposalAccept,
                            isLoading: _busy,
                            onPressed: () => _accept(job),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (!canPropose && !canAccept) ...[
                  const SizedBox(height: AppSpacing.md),
                  MessageBanner(l.appointmentClosed),
                ],
                if (canPropose) ...[
                  sectionTitle(l.appointmentPickDay),
                  SizedBox(
                    height: AppSizes.minTouch + 8,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (_, i) {
                        final d = days[i].key;
                        final sel = d == _day;
                        return Center(
                          child: ChoiceChip(
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            label: Text(formatDay(l, d.toUtc(), now)),
                            selected: sel,
                            onSelected: _busy
                                ? null
                                : (_) => setState(() => _day = d),
                          ),
                        );
                      },
                    ),
                  ),
                  sectionTitle(l.appointmentPickSlot),
                  for (final s in slots)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: ChoiceCard(
                        title: slotLabel(s),
                        subtitle: s == offerWindow
                            ? (widget.pro
                                  ? l.appointmentYourWindow
                                  : l.appointmentOfferWindow)
                            : null,
                        selected: _selected == s,
                        onTap: _busy
                            ? null
                            : () => setState(() => _selected = s),
                      ),
                    ),
                  if (slots.isEmpty)
                    Text(
                      l.appointmentNoSlots,
                      style: AppTypography.bodySecondary,
                    ),
                  const SizedBox(height: AppSpacing.md),
                  if (_selected == null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        l.appointmentSelectHint,
                        style: AppTypography.label,
                      ),
                    ),
                  AppButton(
                    label: widget.pro
                        ? l.appointmentProSubmit
                        : l.appointmentSubmit,
                    isLoading: _busy,
                    onPressed: _selected == null ? null : () => _propose(job),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 26: İptal (müşteri ve usta ortak)
// =============================================================================

/// İptalde iade edilecek tutar: ödenen − zaten iade edilen.
Money refundAmount(JobDetail job) =>
    job.payment.totalAmount - job.payment.refundedAmount;

/// İptal onay diyaloğunun metni (iadenin tutarı açıkça yazılır).
String cancelConfirmMessage(AppLocalizations l, JobDetail job, bool pro) {
  final amount = formatMoney(refundAmount(job), l.localeName);
  return pro ? l.cancelConfirmPro(amount) : l.cancelConfirmCustomer(amount);
}

/// `/c/jobs/:id/cancel` ve `/p/jobs/:id/cancel`
class CancelJobScreen extends ConsumerStatefulWidget {
  const CancelJobScreen({super.key, required this.jobId, this.pro = false});

  final String jobId;
  final bool pro;

  @override
  ConsumerState<CancelJobScreen> createState() => _CancelState();
}

class _CancelState extends ConsumerState<CancelJobScreen> {
  String? _reason;
  bool _attempted = false;
  bool _busy = false;
  final _note = TextEditingController();

  String get _jobPath =>
      widget.pro ? '/p/jobs/${widget.jobId}' : '/c/jobs/${widget.jobId}';

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit(JobDetail job) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _attempted = true);
    if (_reason == null) return;
    final ok = await showConfirmDialog(
      context,
      title: l.jobCancelConfirmTitle,
      message: cancelConfirmMessage(l, job, widget.pro),
      confirmLabel: l.cancelConfirmAction,
      cancelLabel: l.cancelConfirmKeep,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final refresh = jobDataInvalidator(ref);
    try {
      final note = _note.text.trim();
      await ref
          .read(apiClientProvider)
          .jobs
          .cancel(
            job.id,
            CancelJobRequest(
              reason: _reason!,
              note: note.isEmpty ? null : note,
            ),
          );
      refresh();
      // İstek sürerken ekrandan çıkıldıysa kullanıcı olduğu yerde kalır.
      if (!mounted) return;
      router.go(widget.pro ? '/p/jobs/${job.id}/cancelled' : '/c/requests');
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(widget.jobId));
    final reasons = widget.pro
        ? [
            for (final r in ProCancelReason.values)
              (r.wire, proCancelReasonLabel(l, r)),
          ]
        : [
            for (final r in CustomerCancelReason.values)
              (r.wire, customerCancelReasonLabel(l, r)),
          ];
    return StackFallback(
      fallback: _jobPath,
      child: ListPage(
        title: l.cancelTitle,
        leading: AppBackButton(fallback: _jobPath),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(widget.jobId)),
          builder: (context, job) {
            final amount = formatMoney(refundAmount(job), l.localeName);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!job.can(JobAction.cancel)) ...[
                    MessageBanner(l.cancelNotAllowed),
                    const FieldGap(),
                    AppButton(
                      label: l.backToJob,
                      onPressed: () => context.go(_jobPath),
                    ),
                  ] else ...[
                    Text(
                      widget.pro
                          ? l.cancelIntroPro(amount)
                          : l.cancelIntroCustomer(amount),
                      style: AppTypography.body,
                    ),
                    sectionTitle(l.cancelReasonTitle),
                    for (final (wire, label) in reasons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: ChoiceCard(
                          title: label,
                          selected: _reason == wire,
                          onTap: _busy
                              ? null
                              : () => setState(() => _reason = wire),
                        ),
                      ),
                    if (_attempted && _reason == null)
                      Text(
                        l.reasonRequired,
                        style: AppTypography.label.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    const FieldGap(),
                    AppTextField(
                      label: l.noteOptional,
                      controller: _note,
                      enabled: !_busy,
                      maxLength: 500,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                    ),
                    const FieldGap(),
                    AppButton(
                      label: l.cancelSubmit,
                      isLoading: _busy,
                      onPressed: () => _submit(job),
                    ),
                    if (!widget.pro && job.can(JobAction.proposeSlot))
                      AppButton(
                        label: l.cancelRescheduleInstead,
                        variant: AppButtonVariant.secondary,
                        onPressed: _busy
                            ? null
                            : () => context.go('/c/jobs/${job.id}/appointment'),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 27: Teslim onayı
// =============================================================================

/// `/c/jobs/:id/complete`
class CompleteJobScreen extends ConsumerStatefulWidget {
  const CompleteJobScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<CompleteJobScreen> createState() => _CompleteState();
}

class _CompleteState extends ConsumerState<CompleteJobScreen> {
  bool _busy = false;

  Future<void> _confirm(JobDetail job) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.completeConfirmTitle,
      message: l.completeConfirmBody(
        formatMoney(job.payment.totalAmount, l.localeName),
        job.counterpart.displayName,
      ),
      confirmLabel: l.completeConfirmAction,
      cancelLabel: l.cancel,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final refresh = jobDataInvalidator(ref);
    try {
      await ref.read(apiClientProvider).jobs.confirm(job.id);
      refresh();
      if (!mounted) return;
      // Onay formu yığından çıkar; geri tuşu işe döner.
      router.go('/c/jobs/${job.id}/review');
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(widget.jobId));
    final now = ref.read(nowProvider)();
    final jobPath = '/c/jobs/${widget.jobId}';
    return StackFallback(
      fallback: jobPath,
      child: ListPage(
        title: l.completeTitle,
        leading: AppBackButton(fallback: jobPath),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(widget.jobId)),
          builder: (context, job) {
            String? note;
            for (final e in job.timeline) {
              if (e.type == JobEventType.statusChanged &&
                  e.toStatus == JobStatus.workFinished &&
                  (e.note ?? '').isNotEmpty) {
                note = e.note;
              }
            }
            final photos = [
              for (final e in job.timeline)
                if (e.photo != null && e.actorRole == ActorRole.pro) e.photo!,
            ];
            final canConfirm = job.can(JobAction.confirmCompletion);
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(l.completeIntro, style: AppTypography.body),
                sectionTitle(l.completeProNote),
                AppCard(
                  child: Text(
                    note ?? l.completeNoNote,
                    style: note == null
                        ? AppTypography.bodySecondary
                        : AppTypography.body,
                  ),
                ),
                if (photos.isNotEmpty) ...[
                  sectionTitle(l.completeProPhotos),
                  PhotoStrip(photos: photos),
                ],
                const SizedBox(height: AppSpacing.md),
                InfoRow(
                  l.totalVatIncluded,
                  formatMoney(job.payment.totalAmount, l.localeName),
                  bold: true,
                ),
                if (job.autoCompleteAt != null && canConfirm) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.completeAutoNote(
                      formatDayTime(l, job.autoCompleteAt!, now),
                    ),
                    style: AppTypography.label,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (!canConfirm) ...[
                  MessageBanner(l.completeNotAvailable),
                  const FieldGap(),
                  AppButton(
                    label: l.backToJob,
                    onPressed: () => context.go(jobPath),
                  ),
                ] else ...[
                  AppButton(
                    label: l.completeConfirmButton,
                    isLoading: _busy,
                    onPressed: () => _confirm(job),
                  ),
                  if (job.can(JobAction.complain))
                    AppButton(
                      label: l.complainAction,
                      variant: AppButtonVariant.secondary,
                      onPressed: _busy
                          ? null
                          : () => context.push('/c/jobs/${job.id}/complaint'),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 28: Puanlama
// =============================================================================

String reviewTagLabel(AppLocalizations l, ReviewTag t) => switch (t) {
  ReviewTag.onTime => l.reviewTagOnTime,
  ReviewTag.cleanWork => l.reviewTagCleanWork,
  ReviewTag.fairPrice => l.reviewTagFairPrice,
  ReviewTag.goodCommunication => l.reviewTagGoodCommunication,
  ReviewTag.polite => l.reviewTagPolite,
};

/// `/c/jobs/:id/review`
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  final Set<ReviewTag> _tags = {};
  bool _anonymous = false;
  bool _attempted = false;
  bool _busy = false;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit(JobDetail job) async {
    if (_busy) return;
    setState(() => _attempted = true);
    if (_rating < 1) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final refresh = jobDataInvalidator(ref);
    try {
      await ref
          .read(apiClientProvider)
          .jobs
          .review(
            job.id,
            ReviewRequest(
              rating: _rating,
              tags: ReviewTag.values.where(_tags.contains).toList(),
              comment: _comment.text.trim(),
              anonymous: _anonymous,
            ),
          );
      refresh();
      if (!mounted) return;
      router.go('/c/jobs/${job.id}');
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(widget.jobId));
    final jobPath = '/c/jobs/${widget.jobId}';
    return StackFallback(
      fallback: jobPath,
      child: ListPage(
        title: l.reviewTitle,
        leading: AppBackButton(fallback: jobPath),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(widget.jobId)),
          builder: (context, job) {
            if (!job.can(JobAction.review)) {
              return EmptyState(
                icon: Icons.star_outline,
                title: job.review != null
                    ? l.reviewAlreadyTitle
                    : l.reviewNotAvailableTitle,
                message: job.review != null
                    ? l.reviewAlreadyBody
                    : l.reviewNotAvailableBody,
                actionLabel: l.backToJob,
                onAction: () => context.go(jobPath),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.reviewIntro(job.counterpart.displayName),
                    style: AppTypography.body,
                  ),
                  sectionTitle(l.reviewStarsTitle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: AppSizes.minTouch,
                            minHeight: AppSizes.minTouch,
                          ),
                          tooltip: l.starsCount(i),
                          isSelected: i <= _rating,
                          onPressed: _busy
                              ? null
                              : () => setState(() => _rating = i),
                          icon: Icon(
                            i <= _rating ? Icons.star : Icons.star_border,
                            size: 36,
                            color: AppColors.urgency,
                          ),
                        ),
                    ],
                  ),
                  if (_attempted && _rating < 1)
                    Text(
                      l.reviewStarsRequired,
                      textAlign: TextAlign.center,
                      style: AppTypography.label.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  sectionTitle(l.reviewTagsTitle),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final t in ReviewTag.values)
                        FilterChip(
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          label: Text(reviewTagLabel(l, t)),
                          selected: _tags.contains(t),
                          onSelected: _busy
                              ? null
                              : (v) => setState(
                                  () => v ? _tags.add(t) : _tags.remove(t),
                                ),
                        ),
                    ],
                  ),
                  const FieldGap(),
                  AppTextField(
                    label: l.reviewCommentLabel,
                    controller: _comment,
                    enabled: !_busy,
                    maxLength: 1000,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.reviewAnonymous),
                    subtitle: Text(l.reviewAnonymousHelp),
                    value: _anonymous,
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _anonymous = v),
                  ),
                  const FieldGap(),
                  AppButton(
                    label: l.reviewPublish,
                    isLoading: _busy,
                    onPressed: () => _submit(job),
                  ),
                  AppButton(
                    label: l.reviewSkip,
                    variant: AppButtonVariant.tertiary,
                    onPressed: _busy ? null : () => context.go(jobPath),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 29: Şikayet oluştur
// =============================================================================

const int kComplaintMinChars = 20;
const int kComplaintMaxPhotos = 5;

/// `/c/jobs/:id/complaint`
class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintState();
}

class _ComplaintState extends ConsumerState<ComplaintScreen> {
  ComplaintReason? _reason;
  bool _agreed = false;
  bool _attempted = false;
  bool _busy = false;
  final _description = TextEditingController();
  late final PhotoSet _photos;

  @override
  void initState() {
    super.initState();
    _photos = newPhotoSet(ref, MediaPurpose.complaint, kComplaintMaxPhotos);
  }

  @override
  void dispose() {
    _description.dispose();
    _photos.dispose();
    super.dispose();
  }

  bool get _descriptionOk =>
      _description.text.trim().length >= kComplaintMinChars;

  Future<void> _submit(JobDetail job) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _attempted = true);
    if (_reason == null || !_descriptionOk || !_agreed) return;
    if (_photos.isBusy || _photos.hasFailed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.complaintPhotosPending)));
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: l.complaintConfirmTitle,
      message: l.complaintConfirmBody,
      confirmLabel: l.complaintConfirmAction,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    final refresh = jobDataInvalidator(ref);
    try {
      final c = await ref
          .read(apiClientProvider)
          .complaints
          .create(
            job.id,
            ComplaintRequest(
              reason: _reason!,
              description: _description.text.trim(),
              evidenceIds: _photos.mediaIds,
            ),
          );
      refresh();
      if (!mounted) return;
      router.go('/c/complaints/${c.id}');
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateJobData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(widget.jobId));
    final jobPath = '/c/jobs/${widget.jobId}';
    return StackFallback(
      fallback: jobPath,
      child: ListPage(
        title: l.complaintTitle,
        leading: AppBackButton(fallback: jobPath),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(widget.jobId)),
          builder: (context, job) {
            if (!job.can(JobAction.complain)) {
              return EmptyState(
                icon: Icons.report_outlined,
                title: l.complaintNotAvailableTitle,
                message: l.complaintNotAvailableBody,
                actionLabel: l.backToJob,
                onAction: () => context.go(jobPath),
              );
            }
            final len = _description.text.trim().length;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.complaintIntro, style: AppTypography.body),
                  sectionTitle(l.complaintReasonTitle),
                  for (final r in ComplaintReason.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: ChoiceCard(
                        title: complaintReasonLabel(l, r),
                        selected: _reason == r,
                        onTap: _busy ? null : () => setState(() => _reason = r),
                      ),
                    ),
                  if (_attempted && _reason == null)
                    Text(
                      l.reasonRequired,
                      style: AppTypography.label.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  const FieldGap(),
                  AppTextField(
                    label: l.complaintDescription,
                    controller: _description,
                    enabled: !_busy,
                    maxLength: 2000,
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    helperText: l.complaintDescriptionHelp(
                      len,
                      kComplaintMinChars,
                    ),
                    errorText: _attempted && !_descriptionOk
                        ? l.complaintDescriptionShort(kComplaintMinChars)
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  sectionTitle(l.complaintEvidenceTitle),
                  Text(
                    l.complaintEvidenceHelp(kComplaintMaxPhotos),
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  PhotoSetView(set: _photos, enabled: !_busy),
                  const FieldGap(),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _agreed,
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _agreed = v ?? false),
                    title: Text(l.complaintAgree),
                  ),
                  if (_attempted && !_agreed)
                    Text(
                      l.errConsentRequired,
                      style: AppTypography.label.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  const FieldGap(),
                  AppButton(
                    label: l.complaintSubmit,
                    isLoading: _busy,
                    onPressed: () => _submit(job),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// 30: Şikayet durumu
// =============================================================================

/// `/c/complaints/:id`
class ComplaintStatusScreen extends ConsumerWidget {
  const ComplaintStatusScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(complaintProvider(id));
    final jobPath = async.value == null
        ? '/c/requests'
        : '/c/jobs/${async.requireValue.jobId}';
    return StackFallback(
      fallback: jobPath,
      child: ListPage(
        title: l.complaintStatusTitle,
        leading: AppBackButton(fallback: jobPath),
        body: AsyncView<Complaint>(
          value: async,
          onRetry: () => ref.invalidate(complaintProvider(id)),
          builder: (context, c) {
            final now = ref.read(nowProvider)();
            final tone = switch (c.status) {
              ComplaintStatus.open => StatusTone.urgent,
              ComplaintStatus.inReview => StatusTone.info,
              ComplaintStatus.resolved => StatusTone.success,
              ComplaintStatus.dismissed => StatusTone.neutral,
            };
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(complaintProvider(id).future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(c.publicCode, style: AppTypography.screenTitle),
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(
                      label: complaintStatusLabel(l, c.status),
                      icon: Icons.report_outlined,
                      tone: tone,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(switch (c.status) {
                    ComplaintStatus.open => l.complaintExplainOpen,
                    ComplaintStatus.inReview => l.complaintExplainInReview,
                    ComplaintStatus.resolved => l.complaintExplainResolved,
                    ComplaintStatus.dismissed => l.complaintExplainDismissed,
                  }, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.md),
                  InfoRow(
                    l.complaintReasonTitle,
                    complaintReasonLabel(l, c.reason),
                  ),
                  InfoRow(
                    l.complaintCreatedAt,
                    formatDayTime(l, c.createdAt, now),
                  ),
                  sectionTitle(l.complaintDescription),
                  Text(c.description, style: AppTypography.body),
                  if (c.evidence.isNotEmpty) ...[
                    sectionTitle(l.complaintEvidenceTitle),
                    PhotoStrip(photos: c.evidence),
                  ],
                  if ((c.decision ?? '').isNotEmpty ||
                      (c.decisionNote ?? '').isNotEmpty) ...[
                    sectionTitle(l.complaintDecisionTitle),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((c.decision ?? '').isNotEmpty)
                            Text(c.decision!, style: AppTypography.cardTitle),
                          if ((c.decisionNote ?? '').isNotEmpty)
                            Text(c.decisionNote!, style: AppTypography.body),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: l.complaintGoChat,
                    icon: Icons.chat_bubble_outline,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.push('/jobs/${c.jobId}/chat'),
                  ),
                  AppButton(
                    label: l.backToJob,
                    variant: AppButtonVariant.tertiary,
                    onPressed: () => context.go('/c/jobs/${c.jobId}'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
