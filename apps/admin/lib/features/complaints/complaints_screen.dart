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

/// Şikayetler: durum süzgeci ve liste (en eski önce).
class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  /// `null`: açık ve incelemede (sunucu varsayılanı).
  ComplaintStatus? _status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    final value = ref.watch(complaintsProvider(_status));
    return PageScroll(
      title: l.complaintsTitle,
      subtitle: l.complaintsSubtitle,
      children: [
        FilterRow<ComplaintStatus?>(
          label: l.filterStatus,
          selected: _status,
          options: [
            (null, l.complaintsActive),
            for (final s in ComplaintStatus.values)
              (s, complaintStatusLabel(l, s)),
          ],
          onSelected: (s) => setState(() => _status = s),
        ),
        const SizedBox(height: AppSpacing.lg),
        AsyncBody(
          value: value,
          onRetry: () => ref.invalidate(complaintsProvider(_status)),
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                title: l.complaintsEmptyTitle,
                message: l.complaintsEmptyMessage,
                icon: Icons.flag_outlined,
              );
            }
            return ResponsiveTable<AdminComplaintItem>(
              stackBelow: 640,
              rowKey: (r) => Key('complaint-${r.id}'),
              onTap: (r) => context.go(Routes.complaint(r.id)),
              columns: [
                TableColumn(
                  header: l.colComplaint,
                  flex: 3,
                  cell: (r) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.publicCode, style: AppTypography.cardTitle),
                      Text(
                        complaintReasonLabel(l, r.reason),
                        style: AppTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
                TableColumn(
                  header: l.colJob,
                  flex: 2,
                  cell: (r) => Text(r.jobPublicCode),
                ),
                TableColumn(
                  header: l.roleCustomer,
                  flex: 2,
                  cell: (r) => Text(r.customerName),
                ),
                TableColumn(
                  header: l.rolePro,
                  flex: 2,
                  cell: (r) => Text(r.proBusinessName),
                ),
                TableColumn(
                  header: l.colAmount,
                  flex: 2,
                  alignEnd: true,
                  cell: (r) => Text(formatMoney(r.amount, l.localeName)),
                ),
                TableColumn(
                  header: l.colDate,
                  flex: 2,
                  cell: (r) => Text(formatDate(r.createdAt, l.localeName, now)),
                ),
                TableColumn(
                  header: l.colStatus,
                  flex: 2,
                  cell: (r) => complaintStatusChip(l, r.status),
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
