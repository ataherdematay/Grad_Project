import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/formatters.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../jobs/job_ui.dart';

/// Talep kartı: başlık, kategori, konum, etiketler.
class RequestCard extends ConsumerWidget {
  const RequestCard({super.key, required this.item, required this.onTap});

  final RequestSummary item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cats = ref.watch(categoriesProvider).value;
    final now = ref.read(nowProvider)();
    final cat = categoryNameOf(cats, item.categoryId, l.localeName);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            [
              if (cat.isNotEmpty) cat,
              '${item.districtName}, ${item.neighborhood}',
              formatDay(l, item.createdAt, now),
            ].join(' · '),
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              requestStatusChip(l, item.status, item.offerCount),
              urgencyChip(l, item.urgency),
            ],
          ),
          if (item.status == RequestStatus.open &&
              item.minOfferTotal != null &&
              item.maxOfferTotal != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.minOfferTotal == item.maxOfferTotal
                  ? formatMoney(item.minOfferTotal!, l.localeName)
                  : l.offerRange(
                      formatMoney(item.minOfferTotal!, l.localeName),
                      formatMoney(item.maxOfferTotal!, l.localeName),
                    ),
              style: AppTypography.label,
            ),
          ],
        ],
      ),
    );
  }
}

/// Ana sayfada her bölümde en çok bu kadar kart gösterilir.
const int kHomeMaxCards = 3;

/// `/c/home`: aktif talep özeti ve "Talep oluştur".
class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(requestsProvider('active'));
    final jobs = ref.watch(
      jobsProvider(const JobsQuery(PartyRole.customer, 'active')),
    );
    final me = ref.watch(
      sessionProvider.select((s) => s.me?.fullName.split(' ').first),
    );
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l.tabHome)),
      body: SafeArea(
        child: AsyncView<Paged<RequestSummary>>(
          value: async,
          onRetry: () {
            ref
              ..invalidate(requestsProvider)
              ..invalidate(jobsProvider);
          },
          builder: (context, page) {
            final open =
                page.items.where((r) => r.status == RequestStatus.open).toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final activeJobs = (jobs.value ?? const <JobSummary>[]).toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            return RefreshIndicator(
              onRefresh: () {
                ref.invalidate(jobsProvider);
                return ref.refresh(requestsProvider('active').future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  if (me != null)
                    Text(l.homeGreeting(me), style: AppTypography.screenTitle),
                  const SizedBox(height: AppSpacing.md),
                  if (activeJobs.isNotEmpty) ...[
                    Text(l.homeActiveJobs, style: AppTypography.section),
                    const SizedBox(height: AppSpacing.xs),
                    for (final j in activeJobs.take(kHomeMaxCards))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: JobCard(
                          job: j,
                          onTap: () async {
                            await context.push('/c/jobs/${j.id}');
                            ref.invalidate(jobsProvider);
                          },
                        ),
                      ),
                    if (activeJobs.length > kHomeMaxCards)
                      AppButton(
                        label: l.homeSeeAll,
                        variant: AppButtonVariant.tertiary,
                        onPressed: () => context.go('/c/requests'),
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (open.isEmpty && activeJobs.isEmpty)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.homeNoActiveTitle,
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.homeNoActiveBody,
                            style: AppTypography.bodySecondary,
                          ),
                        ],
                      ),
                    )
                  else if (open.isNotEmpty) ...[
                    Text(l.homeOpenRequests, style: AppTypography.section),
                    const SizedBox(height: AppSpacing.xs),
                    for (final r in open.take(kHomeMaxCards)) ...[
                      RequestCard(
                        item: r,
                        onTap: () async {
                          await context.push('/c/requests/${r.id}');
                          ref.invalidate(requestsProvider);
                        },
                      ),
                      if (r.offerCount > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        AppButton(
                          label: l.seeOffers(r.offerCount),
                          variant: AppButtonVariant.secondary,
                          onPressed: () =>
                              context.push('/c/requests/${r.id}/offers'),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    if (open.length > kHomeMaxCards)
                      AppButton(
                        label: l.homeSeeAll,
                        variant: AppButtonVariant.tertiary,
                        onPressed: () => context.go('/c/requests'),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l.createRequest,
                    icon: Icons.add,
                    onPressed: () => context.push('/c/requests/new'),
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

/// `/c/requests`: Aktif ve Geçmiş sekmeleri.
class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l.tabRequests),
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
              _RequestList(scope: 'active'),
              _RequestList(scope: 'past'),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.scope});

  final String scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(requestsProvider(scope));
    final active = scope == 'active';
    return AsyncView<Paged<RequestSummary>>(
      value: async,
      onRetry: () => ref.invalidate(requestsProvider(scope)),
      builder: (context, page) {
        final empty = page.items.isEmpty;
        return RefreshIndicator(
          onRefresh: () async => ref.refresh(requestsProvider(scope).future),
          child: empty
              ? LayoutBuilder(
                  builder: (context, c) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: c.maxHeight,
                        child: EmptyState(
                          icon: Icons.assignment_outlined,
                          title: active
                              ? l.requestsEmptyActiveTitle
                              : l.requestsEmptyPastTitle,
                          message: active
                              ? l.requestsEmptyActiveBody
                              : l.requestsEmptyPastBody,
                          actionLabel: active ? l.createRequest : null,
                          onAction: active
                              ? () => context.push('/c/requests/new')
                              : null,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: page.items.length + (active ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    if (active && i == page.items.length) {
                      return AppButton(
                        label: l.createRequest,
                        icon: Icons.add,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.push('/c/requests/new'),
                      );
                    }
                    final r = page.items[i];
                    return RequestCard(
                      item: r,
                      onTap: () async {
                        // Atanmış talep işin kendi ekranını açar.
                        final job = r.status == RequestStatus.assigned
                            ? r.jobId
                            : null;
                        await context.push(
                          job != null ? '/c/jobs/$job' : '/c/requests/${r.id}',
                        );
                        ref
                          ..invalidate(requestsProvider)
                          ..invalidate(jobsProvider);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

/// `/c/requests/:id`: detay.
class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(requestProvider(id));
    return ListPage(
      title: l.requestDetailTitle,
      leading: const AppBackButton(fallback: '/c/requests'),
      body: AsyncView<RequestDetail>(
        value: async,
        onRetry: () => ref.invalidate(requestProvider(id)),
        builder: (context, r) => _RequestDetailBody(r: r),
      ),
    );
  }
}

class _RequestDetailBody extends ConsumerWidget {
  const _RequestDetailBody({required this.r});

  final RequestDetail r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cats = ref.watch(categoriesProvider).value;
    final qs = ref.watch(questionsProvider(r.categoryId)).value;
    final now = ref.read(nowProvider)();
    final open = r.status == RequestStatus.open;
    String answerText(RequestAnswer a) {
      for (final q in qs ?? const <Question>[]) {
        if (q.key != a.questionKey) continue;
        var v = a.answer;
        for (final o in q.options) {
          if (o.value == a.answer) {
            v = l.localeName == 'en' ? o.labelEn : o.labelTr;
          }
        }
        return '${l.localeName == 'en' ? q.labelEn : q.labelTr}: $v';
      }
      return '${a.questionKey}: ${a.answer}';
    }

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(requestProvider(r.id).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(r.title, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              requestStatusChip(l, r.status, r.offerCount),
              urgencyChip(l, r.urgency),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(l.requestCode, r.publicCode),
          InfoRow(
            l.wizCategory,
            categoryNameOf(cats, r.categoryId, l.localeName),
          ),
          if (r.preferredFrom != null && r.preferredTo != null)
            InfoRow(
              l.wizDates,
              formatWindow(l, r.preferredFrom!, r.preferredTo!, now),
            ),
          InfoRow(l.requestLocation, '${r.districtName}, ${r.neighborhood}'),
          if ((r.address?.lineFull ?? '').isNotEmpty)
            InfoRow(l.addressLine, r.address!.lineFull!),
          if ((r.address?.doorNote ?? '').isNotEmpty)
            InfoRow(l.addressDoorNote, r.address!.doorNote!),
          if (open) InfoRow(l.requestExpiresOn, formatDay(l, r.expiresAt, now)),
          sectionTitle(l.wizFieldDescription),
          Text(r.description, style: AppTypography.body),
          if (r.answers.isNotEmpty) ...[
            sectionTitle(l.requestAnswers),
            for (final a in r.answers)
              Text(answerText(a), style: AppTypography.body),
          ],
          if (r.photos.isNotEmpty) ...[
            sectionTitle(l.requestPhotos),
            PhotoStrip(photos: r.photos),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (r.status == RequestStatus.open ||
              r.status == RequestStatus.assigned)
            AppButton(
              label: l.seeOffers(r.offerCount),
              onPressed: () async {
                await context.push('/c/requests/${r.id}/offers');
                ref.invalidate(requestProvider(r.id));
              },
            ),
          if (open) ...[
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: l.edit,
              icon: Icons.edit_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                await context.push('/c/requests/${r.id}/edit');
                ref.invalidate(requestProvider(r.id));
              },
            ),
            AppButton(
              label: l.requestCancel,
              variant: AppButtonVariant.tertiary,
              onPressed: () async {
                await context.push('/c/requests/${r.id}/cancel');
                ref.invalidate(requestProvider(r.id));
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// `/c/requests/:id/cancel`: gerekçe sayfası + onay diyaloğu.
class CancelRequestScreen extends ConsumerStatefulWidget {
  const CancelRequestScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<CancelRequestScreen> createState() => _CancelState();
}

class _CancelState extends ConsumerState<CancelRequestScreen> {
  RequestCancelReason? _reason;
  final _note = TextEditingController();
  bool _attempted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l, RequestCancelReason r) => switch (r) {
    RequestCancelReason.plansChanged => l.cancelReasonPlansChanged,
    RequestCancelReason.solved => l.cancelReasonSolved,
    RequestCancelReason.noSuitableOffer => l.cancelReasonNoSuitableOffer,
    RequestCancelReason.other => l.cancelReasonOther,
  };

  Future<void> _submit() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    setState(() => _attempted = true);
    if (_reason == null) return;
    final ok = await showConfirmDialog(
      context,
      title: l.cancelConfirmTitle,
      message: l.cancelConfirmMessage,
      confirmLabel: l.requestCancel,
      cancelLabel: l.keepRequest,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final router = GoRouter.of(context);
    try {
      final note = _note.text.trim();
      await ref
          .read(apiClientProvider)
          .requests
          .cancel(
            widget.id,
            CancelRequestInput(
              reason: _reason!,
              note: note.isEmpty ? null : note,
            ),
          );
      invalidateRequestData(ref);
      // Derin bağlantıyla açıldıysa yığın boştur: talebin detayına gidilir.
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/c/requests/${widget.id}');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = apiErrorMessage(l, e.code));
      if (isStaleStateError(e)) invalidateRequestData(ref);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      title: l.requestCancel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.cancelReasonTitle, style: AppTypography.section),
          const SizedBox(height: AppSpacing.xs),
          for (final r in RequestCancelReason.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ChoiceCard(
                title: _label(l, r),
                selected: _reason == r,
                onTap: _loading ? null : () => setState(() => _reason = r),
              ),
            ),
          if (_attempted && _reason == null)
            Text(
              l.reasonRequired,
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),
          const FieldGap(),
          AppTextField(
            label: l.noteOptional,
            controller: _note,
            enabled: !_loading,
            maxLength: 250,
            keyboardType: TextInputType.multiline,
            minLines: 3,
          ),
          if (_error != null) ...[const FieldGap(), MessageBanner(_error!)],
          const FieldGap(),
          AppButton(
            label: l.requestCancel,
            isLoading: _loading,
            onPressed: _submit,
          ),
          AppButton(
            label: l.keepRequest,
            variant: AppButtonVariant.tertiary,
            onPressed: _loading ? null : () => context.pop(),
          ),
        ],
      ),
    );
  }
}

/// `/c/requests/:id/published`: eşleşen usta sayısı ve gerekçesi.
class PublishedScreen extends ConsumerWidget {
  const PublishedScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(requestProvider(id));
    return ListPage(
      title: l.publishedTitle,
      leading: const AppBackButton(fallback: '/c/requests'),
      body: AsyncView<RequestDetail>(
        value: async,
        onRetry: () => ref.invalidate(requestProvider(id)),
        builder: (context, r) {
          final none = r.matchedProCount == 0;
          String factor(MatchFactor f) => switch (f) {
            MatchFactor.category => l.matchCategory,
            MatchFactor.district => l.matchDistrict,
            MatchFactor.availability => l.matchAvailability,
          };
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Icon(
                none ? Icons.search_off : Icons.check_circle_outline,
                size: 56,
                color: none ? AppColors.textSecondary : AppColors.success,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                none
                    ? l.publishedNoMatchTitle
                    : l.publishedMatchTitle(r.matchedProCount),
                textAlign: TextAlign.center,
                style: AppTypography.screenTitle,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                none ? l.publishedNoMatchBody : l.publishedMatchBody,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
              if (!none && r.matchFactors.isNotEmpty) ...[
                sectionTitle(l.matchReasons),
                for (final f in r.matchFactors)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: Text(factor(f))),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (none) ...[
                AppButton(
                  label: l.keepOpen,
                  onPressed: () => context.go('/c/requests'),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.edit,
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    await context.push('/c/requests/${r.id}/edit');
                    ref.invalidate(requestProvider(r.id));
                  },
                ),
              ] else ...[
                AppButton(
                  label: l.goToMyRequests,
                  onPressed: () => context.go('/c/requests'),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.goHome,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go('/c/home'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
