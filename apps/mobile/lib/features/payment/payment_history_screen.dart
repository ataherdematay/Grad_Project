import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../core/payment_data.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../jobs/job_ui.dart';
import 'payment_journey.dart';

/// `/c/payments`: müşterinin ödeme geçmişi (yeniden eskiye, sayfalı).
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(paymentHistoryProvider);
    return ListPage(
      title: l.paymentsTitle,
      leading: const AppBackButton(fallback: '/c/profile'),
      body: AsyncView<PaymentHistoryState>(
        value: async,
        onRetry: () => ref.invalidate(paymentHistoryProvider),
        builder: (context, s) => s.items.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l.paymentsEmptyTitle,
                message: l.paymentsEmptyBody,
                actionLabel: l.payToRequests,
                onAction: () => context.go('/c/requests'),
              )
            : _HistoryList(state: s),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({required this.state});

  final PaymentHistoryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final items = state.items;
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(paymentHistoryProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PaymentHistoryTile(item: it),
            ),
          if (state.moreError != null) ...[
            MessageBannerText(l.paymentsMoreFailed),
            const SizedBox(height: AppSpacing.xs),
          ],
          if (state.hasMore)
            AppButton(
              label: state.moreError != null ? l.retry : l.paymentsLoadMore,
              variant: AppButtonVariant.secondary,
              isLoading: state.loadingMore,
              onPressed: () =>
                  ref.read(paymentHistoryProvider.notifier).loadMore(),
            ),
        ],
      ),
    );
  }
}

/// Hata metni için sade başlık satırı (ana hata ekranı değil, liste altı).
class MessageBannerText extends StatelessWidget {
  const MessageBannerText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      style: AppTypography.label.copyWith(color: AppColors.error),
    ),
  );
}

StatusTone _statusTone(EscrowStatus s) => switch (s) {
  EscrowStatus.releasedToPro => StatusTone.success,
  EscrowStatus.locked || EscrowStatus.initialized => StatusTone.info,
  EscrowStatus.disputed || EscrowStatus.splitSettled => StatusTone.urgent,
  EscrowStatus.refundedToCustomer => StatusTone.primary,
  EscrowStatus.failed => StatusTone.error,
};

IconData _statusIcon(EscrowStatus s) => switch (s) {
  EscrowStatus.releasedToPro => Icons.check_circle_outline,
  EscrowStatus.locked || EscrowStatus.initialized => Icons.lock_outline,
  EscrowStatus.disputed => Icons.report_outlined,
  EscrowStatus.splitSettled => Icons.call_split,
  EscrowStatus.refundedToCustomer => Icons.undo,
  EscrowStatus.failed => Icons.error_outline,
};

class PaymentHistoryTile extends ConsumerWidget {
  const PaymentHistoryTile({super.key, required this.item});

  final PaymentHistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    String m(Money v) => formatMoney(v, l.localeName);
    final when = item.paidAt ?? item.createdAt;
    final subtitle = [
      ?item.jobPublicCode,
      if (when != null) formatDay(l, when, now),
    ].join(' · ');
    final statusLabel = escrowLabel(l, item.status, PartyRole.customer);
    final moneyLabel = moneyLocationLabel(l, item.moneyLocation);
    final title = (item.jobTitle ?? '').isNotEmpty
        ? item.jobTitle!
        : l.paymentsNoJob;
    return AppCard(
      onTap: () => context.push(
        item.jobId != null
            ? '/c/jobs/${item.jobId}/payment'
            : '/c/payments/${item.ref}/result',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: AppTypography.cardTitle)),
              const SizedBox(width: AppSpacing.xs),
              Text(m(item.totalAmount), style: AppTypography.cardTitle),
            ],
          ),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: AppTypography.bodySecondary),
          if ((item.proName ?? '').isNotEmpty)
            Text(item.proName!, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusChip(
                label: statusLabel,
                icon: _statusIcon(item.status),
                tone: _statusTone(item.status),
              ),
              if (item.sandbox) const SandboxChip(),
            ],
          ),
          const SizedBox(height: 6),
          // "Para: …" satırı çipteki metnin aynısıysa (LOCKED: "Güvence
          // havuzunda") tekrar yazılmaz.
          if (moneyLabel != statusLabel)
            Text(l.paymentsMoneyLine(moneyLabel), style: AppTypography.label),
          if (item.refundedAmount.isPositive)
            Text(
              '${l.refundedLabel}: ${m(item.refundedAmount)}',
              style: AppTypography.label,
            ),
        ],
      ),
    );
  }
}
