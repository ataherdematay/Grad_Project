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
import '../common/labels.dart';
import '../common/widgets.dart';

/// Kategori kimliklerini seçili dildeki adlara çevirir; katalog gelmediyse boş.
String categoryNames(
  AsyncValue<List<Category>> catalog,
  List<String> ids,
  String locale,
) {
  final list = catalog.asData?.value;
  if (list == null) return '';
  final byId = {for (final c in list) c.id: c};
  return [
    for (final id in ids)
      if (byId[id] != null)
        (locale == 'en' ? byId[id]!.nameEn : byId[id]!.nameTr),
  ].join(', ');
}

/// Usta başvuruları: durum süzgeci, arama ve liste.
class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  ApplicationsQuery _query = const ApplicationsQuery();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    final value = ref.watch(applicationsProvider(_query));
    final catalog = ref.watch(categoriesProvider);
    return PageScroll(
      title: l.applicationsTitle,
      subtitle: l.applicationsSubtitle,
      children: [
        FilterRow<ReviewStatus>(
          label: l.filterStatus,
          selected: _query.status,
          options: [
            for (final s in ReviewStatus.values) (s, reviewStatusLabel(l, s)),
          ],
          onSelected: (s) => setState(
            () => _query = ApplicationsQuery(status: s, q: _query.q),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SearchField(
          label: l.search,
          hint: l.applicationsSearchHint,
          onChanged: (q) => setState(
            () => _query = ApplicationsQuery(status: _query.status, q: q),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AsyncBody(
          value: value,
          onRetry: () => ref.invalidate(applicationsProvider(_query)),
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                title: l.applicationsEmptyTitle,
                message: l.applicationsEmptyMessage,
                icon: Icons.badge_outlined,
              );
            }
            return ResponsiveTable<AdminApplicationSummary>(
              stackBelow: 640,
              rowKey: (r) => Key('application-${r.proId}'),
              onTap: (r) => context.go(Routes.application(r.proId)),
              columns: [
                TableColumn(
                  header: l.colPro,
                  flex: 3,
                  cell: (r) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.businessName, style: AppTypography.cardTitle),
                      Text(r.fullName, style: AppTypography.bodySecondary),
                    ],
                  ),
                ),
                TableColumn(
                  header: l.colCategories,
                  flex: 2,
                  cell: (r) =>
                      Text(categoryNames(catalog, r.categoryIds, l.localeName)),
                ),
                TableColumn(
                  header: l.colDistricts,
                  flex: 2,
                  cell: (r) => Text(r.districtNames.join(', ')),
                ),
                TableColumn(
                  header: l.colSubmitted,
                  flex: 2,
                  cell: (r) => Text(
                    r.submittedAt == null
                        ? '-'
                        : formatDate(r.submittedAt!, l.localeName, now),
                  ),
                ),
                TableColumn(
                  header: l.colDocuments,
                  flex: 1,
                  cell: (r) => Text('${r.documentCount}'),
                ),
                TableColumn(
                  header: l.colStatus,
                  flex: 2,
                  cell: (r) => reviewStatusChip(l, r.reviewStatus),
                ),
              ],
              rows: items,
            );
          },
        ),
      ],
    );
  }
}
