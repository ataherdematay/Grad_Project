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

const _statuses = [
  'LOCKED',
  'DISPUTED',
  'RELEASED_TO_PRO',
  'REFUNDED_TO_CUSTOMER',
  'SPLIT_SETTLED',
  'FAILED',
  'INITIALIZED',
];

/// Ödeme defteri: durum süzgeci, toplam kartları ve tablo.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    final value = ref.watch(paymentsProvider(_status));
    final loc = l.localeName;
    return PageScroll(
      title: l.paymentsTitle,
      subtitle: l.paymentsSubtitle,
      children: [
        FilterRow<String?>(
          label: l.filterStatus,
          selected: _status,
          options: [
            (null, l.filterAll),
            for (final s in _statuses) (s, escrowLabel(l, s)),
          ],
          onSelected: (s) => setState(() => _status = s),
        ),
        const SizedBox(height: AppSpacing.lg),
        AsyncBody(
          value: value,
          onRetry: () => ref.invalidate(paymentsProvider(_status)),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Totals(totals: data.totals),
              const SizedBox(height: AppSpacing.lg),
              if (data.items.isEmpty)
                EmptyState(
                  title: l.paymentsEmptyTitle,
                  message: l.paymentsEmptyMessage,
                  icon: Icons.account_balance_wallet_outlined,
                )
              else
                ResponsiveTable<AdminPaymentRow>(
                  minWidth: 1180,
                  rowKey: (r) => Key('payment-${r.ref}'),
                  columns: [
                    TableColumn(
                      header: l.colRef,
                      flex: 3,
                      cell: (r) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(r.ref, style: AppTypography.label),
                          if (r.jobPublicCode != null)
                            Text(
                              r.jobPublicCode!,
                              style: AppTypography.bodySecondary,
                            ),
                        ],
                      ),
                    ),
                    TableColumn(
                      header: l.colStatus,
                      flex: 3,
                      cell: (r) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          escrowChip(l, r.status),
                          if (r.errorCode != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                r.errorCode!,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    TableColumn(
                      header: l.colProvider,
                      flex: 2,
                      cell: (r) => Text(r.provider),
                    ),
                    TableColumn(
                      header: l.colParties,
                      flex: 3,
                      cell: (r) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.customerName ?? '-'),
                          Text(
                            r.proBusinessName ?? '-',
                            style: AppTypography.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                    TableColumn(
                      header: l.colTotal,
                      flex: 2,
                      alignEnd: true,
                      cell: (r) => Text(formatMoney(r.totalAmount, loc)),
                    ),
                    TableColumn(
                      header: l.colServiceFee,
                      flex: 2,
                      alignEnd: true,
                      cell: (r) => Text(formatMoney(r.commission, loc)),
                    ),
                    TableColumn(
                      header: l.colProPayout,
                      flex: 2,
                      alignEnd: true,
                      cell: (r) => Text(formatMoney(r.proPayout, loc)),
                    ),
                    TableColumn(
                      header: l.colRefunded,
                      flex: 2,
                      alignEnd: true,
                      cell: (r) => Text(formatMoney(r.refundedAmount, loc)),
                    ),
                    TableColumn(
                      header: l.colDate,
                      flex: 2,
                      cell: (r) => Text(formatDate(r.createdAt, loc, now)),
                    ),
                  ],
                  rows: data.items,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.totals});

  final AdminPaymentTotals totals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = l.localeName;
    final cards = [
      ('total-locked', l.totalLocked, totals.lockedTotal, Icons.lock_outline),
      (
        'total-released',
        l.totalReleased,
        totals.releasedTotal,
        Icons.north_east,
      ),
      (
        'total-commission',
        l.totalCommission,
        totals.commissionTotal,
        Icons.percent,
      ),
      ('total-refunded', l.totalRefunded, totals.refundedTotal, Icons.undo),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        const gap = AppSpacing.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (key, label, money, icon) in cards)
              SizedBox(
                width: width,
                child: AppCard(
                  semanticLabel: '$label: ${formatMoney(money, loc)}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: AppColors.primary),
                      const SizedBox(height: AppSpacing.xs),
                      Text(label, style: AppTypography.bodySecondary),
                      Text(
                        formatMoney(money, loc),
                        key: Key(key),
                        style: AppTypography.section.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
