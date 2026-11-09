import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import 'widgets.dart';

/// Markalı "bulunamadı" ekranı.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Align(alignment: Alignment.centerLeft, child: LogoText()),
            ),
            Expanded(
              child: EmptyState(
                icon: Icons.explore_off_outlined,
                title: l.notFoundTitle,
                message: l.notFoundBody,
                actionLabel: l.notFoundAction,
                onAction: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// KVKK, koşullar ve gizlilik için yer tutucu metin sayfası.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final String doc;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = switch (doc) {
      'kvkk' => l.legalKvkkTitle,
      'terms' => l.legalTermsTitle,
      'privacy' => l.legalPrivacyTitle,
      _ => null,
    };
    if (title == null) return const NotFoundScreen();
    return PageScaffold(
      title: title,
      child: Text(l.legalPlaceholder, style: AppTypography.body),
    );
  }
}

/// Sonraki dalgalarda doldurulacak ortak ekranlar için yer tutucu.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        title: Text(title),
      ),
      body: SafeArea(
        child: EmptyState(
          title: l.comingSoonTitle,
          message: l.comingSoonBody,
          icon: Icons.construction_outlined,
        ),
      ),
    );
  }
}

/// `/p/apply` ve `/p/application`: usta başvurusu yer tutucusu. Müşteri
/// moduna dönüş her zaman vardır.
class ProApplicationPlaceholder extends ConsumerWidget {
  const ProApplicationPlaceholder({super.key, required this.apply});

  final bool apply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pro = ref.watch(sessionProvider.select((s) => s.me?.pro));
    final status = pro == null
        ? null
        : switch (pro.reviewStatus) {
            ReviewStatus.pendingReview => (
              l.statusPendingReview,
              Icons.hourglass_top,
              StatusTone.urgent,
            ),
            ReviewStatus.needsDocuments => (
              l.statusNeedsDocuments,
              Icons.upload_file,
              StatusTone.urgent,
            ),
            ReviewStatus.rejected => (
              l.statusRejected,
              Icons.cancel_outlined,
              StatusTone.error,
            ),
            ReviewStatus.suspended => (
              l.statusSuspended,
              Icons.block,
              StatusTone.error,
            ),
            ReviewStatus.approved => null,
          };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        title: Text(apply ? l.proApplyTitle : l.proApplicationTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (status != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(
                    label: status.$1,
                    icon: status.$2,
                    tone: status.$3,
                  ),
                ),
              ),
            Expanded(
              child: EmptyState(
                title: l.comingSoonTitle,
                message: l.comingSoonBody,
                icon: Icons.construction_outlined,
                actionLabel: l.backToCustomerMode,
                onAction: () => context.go('/c/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
