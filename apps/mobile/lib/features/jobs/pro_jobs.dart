import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data.dart';
import '../../core/formatters.dart';
import '../../core/photos.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import 'customer_jobs.dart' show complaintStatusLabel;
import 'job_ui.dart';

// --- Haritada aç -------------------------------------------------------------

/// Adres için sistem harita uygulamasında arama bağlantısı. iOS'ta Apple
/// Maps, diğerlerinde Google Maps; canlı takip yoktur.
Uri mapsSearchUri(JobAddress a, {TargetPlatform? platform}) {
  final query = [
    a.lineFull,
    a.neighborhood,
    a.districtName,
  ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
  final p = platform ?? defaultTargetPlatform;
  if (p == TargetPlatform.iOS || p == TargetPlatform.macOS) {
    return Uri.https('maps.apple.com', '/', {'q': query});
  }
  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
}

/// Dış bağlantıyı açan işlev; testlerde sahtesi verilir.
final urlOpenerProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

// =============================================================================
// /p/jobs
// =============================================================================

/// `/p/jobs`: aktif ve geçmiş işler.
class ProJobsScreen extends ConsumerWidget {
  const ProJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l.tabJobs),
          bottom: TabBar(
            tabs: [
              Tab(text: l.tabActive),
              Tab(text: l.tabPast),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              _ProJobList(scope: 'active'),
              _ProJobList(scope: 'past'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProJobList extends ConsumerWidget {
  const _ProJobList({required this.scope});

  final String scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final q = JobsQuery(PartyRole.pro, scope);
    final async = ref.watch(jobsProvider(q));
    final active = scope == 'active';
    return AsyncView<List<JobSummary>>(
      value: async,
      onRetry: () => ref.invalidate(jobsProvider(q)),
      builder: (context, jobs) => RefreshIndicator(
        onRefresh: () async => ref.refresh(jobsProvider(q).future),
        child: jobs.isEmpty
            ? LayoutBuilder(
                builder: (context, c) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: c.maxHeight,
                      child: EmptyState(
                        icon: Icons.handyman_outlined,
                        title: active ? l.jobsEmptyTitle : l.jobsEmptyPastTitle,
                        message: active ? l.jobsEmptyBody : l.jobsEmptyPastBody,
                        actionLabel: active ? l.backToFeed : null,
                        onAction: active ? () => context.go('/p/feed') : null,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: jobs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) => JobCard(
                  job: jobs[i],
                  onTap: () async {
                    await context.push('/p/jobs/${jobs[i].id}');
                    ref.invalidate(jobsProvider);
                  },
                ),
              ),
      ),
    );
  }
}

// =============================================================================
// 40: İş yürütme
// =============================================================================

/// `/p/jobs/:id`
class ProJobScreen extends ConsumerWidget {
  const ProJobScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(jobProvider(id));
    return StackFallback(
      fallback: '/p/jobs',
      child: ListPage(
        title: l.jobScreenTitle,
        leading: const AppBackButton(fallback: '/p/jobs'),
        body: AsyncView<JobDetail>(
          value: async,
          onRetry: () => ref.invalidate(jobProvider(id)),
          builder: (context, job) => _ProJobBody(job: job),
        ),
      ),
    );
  }
}

class _ProJobBody extends ConsumerStatefulWidget {
  const _ProJobBody({required this.job});

  final JobDetail job;

  @override
  ConsumerState<_ProJobBody> createState() => _ProJobBodyState();
}

class _ProJobBodyState extends ConsumerState<_ProJobBody> {
  bool _busy = false;

  JobDetail get job => widget.job;

  Future<void> _stage(Future<Object?> Function(JobsApi api) call) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await call(ref.read(apiClientProvider).jobs);
      invalidateJobData(ref);
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

  Future<void> _push(String path) async {
    await context.push(path);
    if (mounted) invalidateJobData(ref);
  }

  Future<void> _openMaps() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    var ok = false;
    try {
      ok = await ref.read(urlOpenerProvider)(mapsSearchUri(job.address));
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.mapsOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    final p = job.appointment.pendingProposal;
    final canAccept = job.can(JobAction.acceptProposal) && p != null;
    final hasAddress = (job.address.lineFull ?? '').isNotEmpty;
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
                icon: Icons.person_outline,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(job.publicCode, style: AppTypography.bodySecondary),
          if (job.status == JobStatus.workFinished &&
              job.autoCompleteAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.proAutoCompleteNote(formatDayTime(l, job.autoCompleteAt!, now)),
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
              onPressed: () =>
                  _stage((api) => api.acceptProposal(job.id, p.id)),
            ),
          if (job.can(JobAction.proposeSlot))
            AppButton(
              label: l.appointmentProSubmit,
              variant: AppButtonVariant.secondary,
              onPressed: _busy
                  ? null
                  : () => _push('/p/jobs/${job.id}/appointment'),
            ),
          if (job.can(JobAction.markArrived))
            AppButton(
              label: l.proArrived,
              icon: Icons.place_outlined,
              isLoading: _busy,
              onPressed: () => _stage((api) => api.arrived(job.id)),
            ),
          if (job.can(JobAction.startWork))
            AppButton(
              label: l.proStart,
              icon: Icons.play_arrow,
              isLoading: _busy,
              onPressed: () => _stage((api) => api.start(job.id)),
            ),
          if (job.can(JobAction.finishWork))
            AppButton(
              label: l.proFinish,
              icon: Icons.check,
              onPressed: _busy ? null : () => _push('/p/jobs/${job.id}/finish'),
            ),
          if (job.can(JobAction.addNote))
            AppButton(
              label: l.proAddNote,
              icon: Icons.note_add_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: _busy ? null : () => _push('/p/jobs/${job.id}/note'),
            ),
          const SizedBox(height: AppSpacing.xs),
          if (job.can(JobAction.chat))
            ChatEntryCard(job: job, onReturn: () => invalidateJobData(ref)),
          if (job.complaint != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
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
                ],
              ),
            ),
          ],
          sectionTitle(l.addressTitle),
          AddressCard(address: job.address),
          if (hasAddress) ...[
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.proOpenMaps,
              icon: Icons.map_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: _openMaps,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          OfferSummaryCard(job: job),
          const SizedBox(height: AppSpacing.sm),
          PaymentSummaryCard(job: job),
          TimelineView(job: job),
          const SizedBox(height: AppSpacing.md),
          if (job.can(JobAction.cancel))
            AppButton(
              label: l.proCancelAction,
              variant: AppButtonVariant.tertiary,
              onPressed: _busy ? null : () => _push('/p/jobs/${job.id}/cancel'),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Not veya fotoğraf ekle
// =============================================================================

/// `/p/jobs/:id/note`
class ProNoteScreen extends ConsumerStatefulWidget {
  const ProNoteScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<ProNoteScreen> createState() => _ProNoteState();
}

class _ProNoteState extends ConsumerState<ProNoteScreen> {
  final _note = TextEditingController();
  late final PhotoSet _photos;
  bool _attempted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _photos = newPhotoSet(ref, MediaPurpose.jobPhoto, 5);
    _photos.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _photos
      ..removeListener(_rebuild)
      ..dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final text = _note.text.trim();
    setState(() => _attempted = true);
    if (text.isEmpty && _photos.mediaIds.isEmpty) return;
    if (_photos.isBusy || _photos.hasFailed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.photosPending)));
      return;
    }
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(apiClientProvider)
          .jobs
          .addEvent(
            widget.jobId,
            JobNoteRequest(
              note: text.isEmpty ? null : text,
              photoIds: _photos.mediaIds,
            ),
          );
      invalidateJobData(ref);
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/p/jobs/${widget.jobId}');
      }
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
    final jobPath = '/p/jobs/${widget.jobId}';
    final empty = _note.text.trim().isEmpty && _photos.mediaIds.isEmpty;
    return StackFallback(
      fallback: jobPath,
      child: ListPage(
        title: l.proNoteTitle,
        leading: AppBackButton(fallback: jobPath),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.proNoteIntro, style: AppTypography.body),
              const FieldGap(),
              AppTextField(
                label: l.proNoteLabel,
                controller: _note,
                enabled: !_busy,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                errorText: _attempted && empty ? l.proNoteEmpty : null,
                onChanged: (_) => setState(() {}),
              ),
              sectionTitle(l.proPhotosTitle),
              PhotoSetView(set: _photos, enabled: !_busy),
              const FieldGap(),
              AppButton(
                label: l.proNoteSubmit,
                isLoading: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// İşi bitirdim (form) → 43
// =============================================================================

const int kFinishNoteMin = 10;
const int kFinishNoteMax = 1000;

/// `/p/jobs/:id/finish`
class ProFinishScreen extends ConsumerStatefulWidget {
  const ProFinishScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<ProFinishScreen> createState() => _ProFinishState();
}

class _ProFinishState extends ConsumerState<ProFinishScreen> {
  final _note = TextEditingController();
  late final PhotoSet _photos;
  bool _attempted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _photos = newPhotoSet(ref, MediaPurpose.jobPhoto, 5);
    _photos.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _photos
      ..removeListener(_rebuild)
      ..dispose();
    _note.dispose();
    super.dispose();
  }

  bool get _noteOk => _note.text.trim().length >= kFinishNoteMin;

  Future<void> _submit() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    setState(() => _attempted = true);
    if (!_noteOk) return;
    if (_photos.isBusy || _photos.hasFailed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.photosPending)));
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: l.proFinishConfirmTitle,
      message: l.proFinishConfirmBody,
      confirmLabel: l.proFinishConfirmAction,
      cancelLabel: l.cancel,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(apiClientProvider)
          .jobs
          .finish(
            widget.jobId,
            FinishJobRequest(
              note: _note.text.trim(),
              photoIds: _photos.mediaIds,
            ),
          );
      invalidateJobData(ref);
      // Form yığından çıkar; geri tuşu İşlerim'e döner.
      router.go('/p/jobs/${widget.jobId}/finished');
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
    final jobPath = '/p/jobs/${widget.jobId}';
    final len = _note.text.trim().length;
    return StackFallback(
      fallback: jobPath,
      child: ListPage(
        title: l.proFinishTitle,
        leading: AppBackButton(fallback: jobPath),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.proFinishIntro, style: AppTypography.body),
              const FieldGap(),
              AppTextField(
                label: l.proFinishNoteLabel,
                controller: _note,
                enabled: !_busy,
                maxLength: kFinishNoteMax,
                keyboardType: TextInputType.multiline,
                helperText: l.proFinishNoteHelp(len, kFinishNoteMin),
                errorText: _attempted && !_noteOk
                    ? l.proFinishNoteShort(kFinishNoteMin)
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              sectionTitle(l.proPhotosTitle),
              Text(l.proFinishPhotosHelp, style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.xs),
              PhotoSetView(set: _photos, enabled: !_busy),
              const FieldGap(),
              AppButton(
                label: l.proFinishSubmit,
                isLoading: _busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `/p/jobs/:id/finished` (43)
class ProFinishedScreen extends ConsumerWidget {
  const ProFinishedScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final job = ref.watch(jobProvider(jobId)).value;
    final now = ref.read(nowProvider)();
    final auto = job?.autoCompleteAt;
    return StackFallback(
      fallback: '/p/jobs',
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l.proFinishedTitle),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 56,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l.proFinishedHeadline,
                    textAlign: TextAlign.center,
                    style: AppTypography.section,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.proFinishedBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                  if (auto != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.proAutoCompleteNote(formatDayTime(l, auto, now)),
                      textAlign: TextAlign.center,
                      style: AppTypography.label,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: l.proBackToJobs,
                    onPressed: () => context.go('/p/jobs'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `/p/jobs/:id/cancelled` (42)
class ProCancelledScreen extends StatelessWidget {
  const ProCancelledScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StackFallback(
      fallback: '/p/feed',
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l.proCancelledTitle),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.cancel_outlined,
                      size: 56,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l.proCancelledHeadline,
                    textAlign: TextAlign.center,
                    style: AppTypography.section,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.proCancelledBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: l.backToFeed,
                    onPressed: () => context.go('/p/feed'),
                  ),
                  AppButton(
                    label: l.proBackToJobs,
                    variant: AppButtonVariant.tertiary,
                    onPressed: () => context.go('/p/jobs'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Kazançlar
// =============================================================================

String earningStatusLabel(AppLocalizations l, EarningStatus s) => switch (s) {
  EarningStatus.pending => l.earningPending,
  EarningStatus.released => l.earningReleased,
  EarningStatus.refunded => l.earningRefunded,
  EarningStatus.split => l.earningSplit,
};

/// `/p/earnings`
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(earningsProvider);
    final now = ref.read(nowProvider)();
    String m(Money v) => formatMoney(v, l.localeName);
    return ListPage(
      title: l.earningsTitle,
      leading: const AppBackButton(fallback: '/p/profile'),
      body: AsyncView<Earnings>(
        value: async,
        onRetry: () => ref.invalidate(earningsProvider),
        builder: (context, e) => RefreshIndicator(
          onRefresh: () async => ref.refresh(earningsProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(l.earningsReleased, m(e.releasedTotal), bold: true),
                    InfoRow(l.earningsPending, m(e.pendingTotal)),
                    InfoRow(l.earningsFeeTotal, m(e.serviceFeeTotal)),
                    const SizedBox(height: 4),
                    Text(
                      l.earningsPendingHelp,
                      style: AppTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
              sectionTitle(l.earningsList),
              if (e.items.isEmpty)
                SizedBox(
                  height: 280,
                  child: EmptyState(
                    icon: Icons.payments_outlined,
                    title: l.earningsEmptyTitle,
                    message: l.earningsEmptyBody,
                    actionLabel: l.backToFeed,
                    onAction: () => context.go('/p/feed'),
                  ),
                ),
              for (final it in e.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    onTap: () => context.push('/p/jobs/${it.jobId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.title, style: AppTypography.cardTitle),
                        Text(
                          '${it.publicCode} · ${formatDay(l, it.date, now)}',
                          style: AppTypography.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InfoRow(l.totalVatIncluded, m(it.totalAmount)),
                        InfoRow(l.serviceFeeLabel, m(it.serviceFee)),
                        InfoRow(
                          l.netEarningLabel,
                          m(it.netEarning),
                          bold: true,
                        ),
                        const SizedBox(height: 4),
                        StatusChip(
                          label: earningStatusLabel(l, it.status),
                          icon: switch (it.status) {
                            EarningStatus.released =>
                              Icons.check_circle_outline,
                            EarningStatus.pending => Icons.hourglass_top,
                            EarningStatus.refunded => Icons.undo,
                            EarningStatus.split => Icons.call_split,
                          },
                          tone: switch (it.status) {
                            EarningStatus.released => StatusTone.success,
                            EarningStatus.pending => StatusTone.info,
                            _ => StatusTone.neutral,
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
