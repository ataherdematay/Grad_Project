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

/// `/c/jobs/:id/receipt`: müşteri makbuzu. Hizmet bedeli dökümü yoktur.
class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(paymentReceiptProvider(jobId));
    return StackFallback(
      fallback: '/c/jobs/$jobId',
      child: ListPage(
        title: l.receiptTitle,
        leading: AppBackButton(fallback: '/c/jobs/$jobId'),
        body: AsyncView<PaymentReceipt>(
          value: async,
          onRetry: () => ref.invalidate(paymentReceiptProvider(jobId)),
          builder: (context, r) => _ReceiptBody(receipt: r, jobId: jobId),
        ),
      ),
    );
  }
}

class _ReceiptBody extends ConsumerWidget {
  const _ReceiptBody({required this.receipt, required this.jobId});

  final PaymentReceipt receipt;
  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = receipt;
    String m(Money v) => formatMoney(v, l.localeName);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(paymentReceiptProvider(jobId).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (r.sandbox) ...[
            const _SandboxBadge(),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(l.receiptNo, r.receiptNo, bold: true),
                // Makbuzda göreli tarih ("Bugün") değil, kalıcı tarih yazılır.
                InfoRow(
                  l.receiptDate,
                  formatDateTimeFull(r.issuedAt, l.localeName),
                ),
                if ((r.jobTitle ?? '').isNotEmpty)
                  InfoRow(
                    l.receiptJob,
                    [r.jobTitle!, ?r.jobPublicCode].join(' · '),
                  ),
                if ((r.proName ?? '').isNotEmpty)
                  InfoRow(l.receiptPro, r.proName!),
                if ((r.customerName ?? '').isNotEmpty)
                  InfoRow(l.receiptCustomer, r.customerName!),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.receiptItems, style: AppTypography.cardTitle),
                const SizedBox(height: 4),
                for (final it in r.items)
                  InfoRow(
                    it.kind == ReceiptItemKind.material ? l.materials : l.labor,
                    m(it.amount),
                  ),
                const Divider(),
                InfoRow(l.totalVatIncluded, m(r.total), bold: true),
                if (r.refundedTotal.isPositive) ...[
                  InfoRow(l.refundedLabel, m(r.refundedTotal)),
                  InfoRow(l.receiptNetPaid, m(r.netPaid), bold: true),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (r.card != null)
                  InfoRow(l.receiptCard, cardDisplay(r.card!), valueFlex: 2),
                // Durum satırı çoğu durumda "Para şu an" satırının aynısı ya da
                // eş anlamlısıdır ("Güvence havuzunda" iki kez). Yalnız şikayet
                // (DISPUTED) ek bilgi taşır: para havuzda ama donduruldu.
                if (r.status == EscrowStatus.disputed)
                  InfoRow(
                    l.receiptStatus,
                    escrowLabel(l, r.status, PartyRole.customer),
                  ),
                InfoRow(
                  l.journeyNowLabel,
                  moneyLocationLabel(l, r.moneyLocation),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l.journeyTitle,
            icon: Icons.route_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/c/jobs/$jobId/payment'),
          ),
        ],
      ),
    );
  }
}

/// Belirgin "Sandbox (test) ödemesi" rozeti: ikon + metin, turuncu zemin.
class _SandboxBadge extends StatelessWidget {
  const _SandboxBadge();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF1E9),
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.urgency, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExcludeSemantics(
              child: Icon(Icons.science_outlined, color: AppColors.urgencyText),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.receiptSandboxTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: AppColors.urgencyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.receiptSandboxBody,
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
