import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';

/// Güvence havuzu özeti: havuzda bekleyen, ustalara aktarılan, iade edilen
/// ve kazanılan hizmet bedeli, ayrıca adetler. Tutarlar sunucudan gelir;
/// istemcide toplama yapılmaz.
class VaultSummarySection extends ConsumerWidget {
  const VaultSummarySection({super.key, this.onRefresh});

  /// Yenile düğmesine basılınca (defteri de yenilemek için).
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(vaultSummaryProvider);
    final now = ref.watch(nowProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.vaultTitle, style: AppTypography.section),
                  const SizedBox(height: 2),
                  Text(l.vaultSubtitle, style: AppTypography.bodySecondary),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            OutlinedButton.icon(
              key: const Key('vault-refresh'),
              onPressed: value.isLoading
                  ? null
                  : () {
                      ref.invalidate(vaultSummaryProvider);
                      onRefresh?.call();
                    },
              icon: const Icon(Icons.refresh),
              label: Text(l.refresh),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AsyncBody(
          value: value,
          onRetry: () => ref.invalidate(vaultSummaryProvider),
          data: (s) => _Summary(summary: s, now: now),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary, required this.now});

  final AdminVaultSummary summary;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = l.localeName;
    final s = summary;
    final c = s.counts;
    final cards = [
      (
        'vault-pending',
        l.vaultCardPending,
        s.vaultTotal,
        Icons.lock_outline,
        '${l.vaultCardPendingHint}: ${c.locked} + ${c.disputed}',
      ),
      (
        'vault-paid',
        l.vaultCardPaid,
        s.paidToProsTotal,
        Icons.north_east,
        null,
      ),
      (
        'vault-refunded',
        l.vaultCardRefunded,
        s.refundedToCustomersTotal,
        Icons.undo,
        null,
      ),
      (
        'vault-commission',
        l.vaultCardCommission,
        s.commissionEarnedTotal,
        Icons.percent,
        null,
      ),
    ];
    final counts = [
      ('total', l.vaultCountTotal, c.total),
      ('vault', l.vaultCountVault, c.vault),
      ('locked', l.vaultCountLocked, c.locked),
      ('disputed', l.vaultCountDisputed, c.disputed),
      ('released', l.vaultCountReleased, c.released),
      ('refunded', l.vaultCountRefunded, c.refunded),
      ('split', l.vaultCountSplit, c.split),
      ('failed', l.vaultCountFailed, c.failed),
      ('pending', l.vaultCountPending, c.pendingAction),
      ('review', l.vaultCountReview, c.needsReview),
      ('seed', l.vaultCountSeed, c.seed),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 560
                ? 2
                : 1;
            const gap = AppSpacing.md;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final (key, label, money, icon, hint) in cards)
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
                          if (hint != null)
                            Text(hint, style: AppTypography.label),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (key, label, n) in counts)
              Chip(
                key: Key('count-$key'),
                label: Text('$label: $n'),
                visualDensity: VisualDensity.compact,
                backgroundColor: key == 'review' && n > 0
                    ? const Color(0xFFFDF1E9)
                    : AppColors.neutralSurface,
                side: BorderSide.none,
              ),
          ],
        ),
        if (s.generatedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            l.vaultUpdatedAt(formatDateTime(s.generatedAt!, loc, now)),
            style: AppTypography.bodySecondary,
          ),
        ],
      ],
    );
  }
}
