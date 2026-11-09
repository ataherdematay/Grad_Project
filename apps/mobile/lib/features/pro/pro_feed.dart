import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/formatters.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';

/// `/p/feed`: eşleşen talepler.
class ProFeedScreen extends ConsumerStatefulWidget {
  const ProFeedScreen({super.key});

  @override
  ConsumerState<ProFeedScreen> createState() => _ProFeedState();
}

class _ProFeedState extends ConsumerState<ProFeedScreen> {
  RequestUrgency? _urgency;
  bool _activating = false;

  Future<void> _activate() async {
    if (_activating) return;
    setState(() => _activating = true);
    try {
      await ref
          .read(apiClientProvider)
          .pro
          .setAvailability(ProAvailability.active);
      invalidateProData(ref);
    } on ApiException catch (e) {
      if (mounted) reportActionError(context, e);
    } finally {
      if (mounted) setState(() => _activating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(feedProvider(_urgency));
    final cats = ref.watch(categoriesProvider).value;
    final now = ref.read(nowProvider)();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l.tabFeed),
        actions: [
          AppIconButton(
            icon: Icons.local_offer_outlined,
            tooltip: l.myOffersTitle,
            onPressed: () => context.push('/p/offers'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: SegmentedButton<RequestUrgency?>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.minTouch),
                ),
                segments: [
                  ButtonSegment(value: null, label: Text(l.filterAll)),
                  ButtonSegment(
                    value: RequestUrgency.urgent,
                    label: Text(l.filterUrgent),
                  ),
                  ButtonSegment(
                    value: RequestUrgency.planned,
                    label: Text(l.filterPlanned),
                  ),
                ],
                selected: {_urgency},
                onSelectionChanged: (s) => setState(() => _urgency = s.first),
              ),
            ),
            Expanded(
              child: AsyncView<FeedPage>(
                value: async,
                onRetry: () => ref.invalidate(feedProvider(_urgency)),
                builder: (context, page) {
                  if (page.onBreak) {
                    return EmptyState(
                      icon: Icons.free_breakfast_outlined,
                      title: l.feedOnBreakTitle,
                      message: l.feedOnBreakBody,
                      actionLabel: _activating ? l.loading : l.feedActivate,
                      onAction: _activating ? null : _activate,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.refresh(feedProvider(_urgency).future),
                    child: page.items.isEmpty
                        ? LayoutBuilder(
                            builder: (context, c) => ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: c.maxHeight,
                                  child: EmptyState(
                                    icon: Icons.search_off,
                                    title: l.feedEmptyTitle,
                                    message: l.feedEmptyBody,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: page.items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (_, i) {
                              final it = page.items[i];
                              return _FeedCard(
                                item: it,
                                category: categoryNameOf(
                                  cats,
                                  it.categoryId,
                                  l.localeName,
                                ),
                                now: now,
                                onTap: () async {
                                  await context.push('/p/requests/${it.id}');
                                  ref.invalidate(feedProvider);
                                },
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.item,
    required this.category,
    required this.now,
    required this.onTap,
  });

  final FeedItem item;
  final String category;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final when =
        item.urgency == RequestUrgency.planned &&
            item.preferredFrom != null &&
            item.preferredTo != null
        ? formatWindow(l, item.preferredFrom!, item.preferredTo!, now)
        : formatDayTime(l, item.createdAt, now);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          Text(
            [
              if (category.isNotEmpty) category,
              '${item.districtName}, ${item.neighborhood}',
            ].join(' · '),
            style: AppTypography.bodySecondary,
          ),
          Text(when, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              urgencyChip(l, item.urgency),
              if (item.photoCount > 0)
                StatusChip(
                  label: l.feedPhotos(item.photoCount),
                  icon: Icons.photo_outlined,
                ),
              StatusChip(
                label: l.feedOffers(item.offerCount),
                icon: Icons.local_offer_outlined,
              ),
              if (item.myOfferId != null)
                StatusChip(
                  label: l.feedMyOffer,
                  icon: Icons.check_circle_outline,
                  tone: StatusTone.success,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// `/p/jobs`: bu dalgada yalnızca boş durum.
class ProJobsScreen extends StatelessWidget {
  const ProJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l.tabJobs)),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.handyman_outlined,
          title: l.jobsEmptyTitle,
          message: l.jobsEmptyBody,
          actionLabel: l.backToFeed,
          onAction: () => context.go('/p/feed'),
        ),
      ),
    );
  }
}
