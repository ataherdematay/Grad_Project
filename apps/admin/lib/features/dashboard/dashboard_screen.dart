import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data.dart';
import '../../core/format.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/widgets.dart';

/// Başlangıç ekranı: istatistik kartları.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final stats = ref.watch(statsProvider);
    final name = ref.watch(sessionProvider.select((s) => s.me?.fullName ?? ''));
    return PageScroll(
      title: l.dashboardTitle,
      subtitle: l.dashboardWelcome(name),
      actions: [
        AppButton(
          label: l.refresh,
          variant: AppButtonVariant.secondary,
          icon: Icons.refresh,
          expand: false,
          onPressed: () => ref.invalidate(statsProvider),
        ),
      ],
      children: [
        AsyncBody(
          value: stats,
          onRetry: () => ref.invalidate(statsProvider),
          data: (s) => LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              const gap = AppSpacing.md;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              Widget card(
                Key key,
                IconData icon,
                String label,
                String value,
                String? route,
              ) => SizedBox(
                width: width,
                child: _StatCard(
                  key: key,
                  icon: icon,
                  label: label,
                  value: value,
                  onTap: route == null ? null : () => context.go(route),
                ),
              );
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  card(
                    const Key('stat-applications'),
                    Icons.badge_outlined,
                    l.statPendingApplications,
                    '${s.pendingApplications}',
                    Routes.applications,
                  ),
                  card(
                    const Key('stat-complaints'),
                    Icons.flag_outlined,
                    l.statOpenComplaints,
                    '${s.openComplaints}',
                    Routes.complaints,
                  ),
                  card(
                    const Key('stat-jobs'),
                    Icons.handyman_outlined,
                    l.statActiveJobs,
                    '${s.activeJobs}',
                    null,
                  ),
                  card(
                    const Key('stat-escrow'),
                    Icons.lock_outline,
                    l.statLockedEscrow,
                    formatMoney(s.lockedEscrowTotal, l.localeName),
                    Routes.payments,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    semanticLabel: '$label: $value',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTypography.bodySecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.screenTitle.copyWith(color: AppColors.primary),
        ),
      ],
    ),
  );
}
