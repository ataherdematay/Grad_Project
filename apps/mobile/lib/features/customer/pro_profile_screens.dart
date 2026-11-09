import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../common/pickers.dart';
import '../common/ui.dart';
import '../common/widgets.dart';

String documentLabel(AppLocalizations l, ProDocumentType t) => switch (t) {
  ProDocumentType.identity => l.docIdentity,
  ProDocumentType.tradeCert => l.docTradeCert,
  ProDocumentType.tax => l.docTax,
  ProDocumentType.criminalRecord => l.docCriminalRecord,
};

/// `/c/pros/:id`: herkese açık usta profili.
class ProPublicProfileScreen extends ConsumerWidget {
  const ProPublicProfileScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(proPublicProvider(id));
    final cats = ref.watch(categoriesProvider).value;
    return ListPage(
      title: l.proProfileTitle,
      leading: const AppBackButton(fallback: '/c/requests'),
      body: AsyncView<ProPublicProfile>(
        value: async,
        onRetry: () => ref.invalidate(proPublicProvider(id)),
        builder: (context, p) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(p.businessName, style: AppTypography.screenTitle),
            Text(p.fullName, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: 4,
              children: [
                RatingText(avg: p.ratingAvg, count: p.ratingCount),
                if (p.verifiedDocuments.isNotEmpty)
                  StatusChip(
                    label: l.proVerified,
                    icon: Icons.verified_outlined,
                    tone: StatusTone.success,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            InfoRow(l.proCompletedJobs, '${p.completedJobs}'),
            InfoRow(l.proExperience, l.experienceYears(p.experienceYears)),
            if (p.memberSince != null)
              InfoRow(
                l.proMemberSince,
                formatMonthYear(p.memberSince!, l.localeName),
              ),
            if ((p.bio ?? '').isNotEmpty) ...[
              sectionTitle(l.proAbout),
              Text(p.bio!, style: AppTypography.body),
            ],
            sectionTitle(l.proVerifiedDocuments),
            if (p.verifiedDocuments.isEmpty)
              Text(l.proNoVerifiedDocs, style: AppTypography.bodySecondary)
            else
              for (final d in p.verifiedDocuments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: Text(documentLabel(l, d))),
                    ],
                  ),
                ),
            if (p.categoryIds.isNotEmpty) ...[
              sectionTitle(l.proCategories),
              Text(
                categoryNamesOf(cats, p.categoryIds, l.localeName),
                style: AppTypography.body,
              ),
            ],
            if (p.districts.isNotEmpty) ...[
              sectionTitle(l.proServiceAreas),
              Text(
                p.districts.map((d) => d.name).join(', '),
                style: AppTypography.body,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l.proReviews,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/c/pros/${p.id}/reviews'),
            ),
          ],
        ),
      ),
    );
  }
}

/// `/c/pros/:id/reviews`.
class ProReviewsScreen extends ConsumerWidget {
  const ProReviewsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(proReviewsProvider(id));
    final now = ref.read(nowProvider)();
    return ListPage(
      title: l.proReviews,
      leading: AppBackButton(fallback: '/c/pros/$id'),
      body: AsyncView<Paged<ReviewItem>>(
        value: async,
        onRetry: () => ref.invalidate(proReviewsProvider(id)),
        builder: (context, page) {
          if (page.items.isEmpty) {
            return EmptyState(
              icon: Icons.rate_review_outlined,
              title: l.reviewsEmptyTitle,
              message: l.reviewsEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(proReviewsProvider(id).future),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: page.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final r = page.items[i];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Semantics(
                            label: l.starsOutOf5(r.rating),
                            excludeSemantics: true,
                            child: Row(
                              children: [
                                for (var s = 1; s <= 5; s++)
                                  Icon(
                                    s <= r.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 18,
                                    color: AppColors.urgency,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formatDay(l, r.createdAt, now),
                        style: AppTypography.label,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.authorDisplay == 'Anonim'
                            ? l.anonymous
                            : r.authorDisplay,
                        style: AppTypography.label,
                      ),
                      if (r.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 6,
                            children: [
                              for (final t in r.tags)
                                StatusChip(label: t, icon: Icons.sell_outlined),
                            ],
                          ),
                        ),
                      if ((r.comment ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(r.comment!, style: AppTypography.body),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
