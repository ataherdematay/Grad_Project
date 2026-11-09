import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';

class TabSpec {
  const TabSpec(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Alt sekme iskeleti. Sekme kökünde geri oku yoktur; Android geri tuşu
/// önce ilk sekmeye döner.
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.shell, required this.tabs});

  final StatefulNavigationShell shell;
  final List<TabSpec> tabs;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            for (final t in tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}

/// Sekme kökü yer tutucusu: başlık ve "Bu bölüm hazırlanıyor". Sahte veri yok.
class TabRootPlaceholder extends StatelessWidget {
  const TabRootPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(title)),
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

/// Profil sekmesi: gerçek oturum bilgisi, ayarlar ve mod geçişi.
class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key, required this.proMode});

  final bool proMode;

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _switching = false;

  Future<void> _switchMode(Me me) async {
    if (_switching) return;
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _switching = true);
    try {
      if (widget.proMode) {
        await ref.read(sessionProvider.notifier).switchMode(UserMode.customer);
        router.go('/c/home');
      } else if (me.pro == null) {
        router.go('/p/apply');
      } else if (me.pro!.reviewStatus != ReviewStatus.approved) {
        router.go('/p/application');
      } else {
        await ref.read(sessionProvider.notifier).switchMode(UserMode.pro);
        router.go('/p/feed');
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(apiErrorMessage(l, e.code))),
      );
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(sessionProvider.select((s) => s.me));
    final switchLabel = widget.proMode
        ? l.switchToCustomer
        : (me?.pro == null ? l.applyAsPro : l.switchToPro);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l.tabProfile),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (me != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(me.fullName, style: AppTypography.cardTitle),
                    const SizedBox(height: 4),
                    Text(me.email, style: AppTypography.bodySecondary),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            if (!widget.proMode) ...[
              AppButton(
                label: l.addressesTitle,
                icon: Icons.home_outlined,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/c/addresses'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            AppButton(
              label: l.profileSettings,
              icon: Icons.settings_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/settings'),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (me != null)
              AppButton(
                label: switchLabel,
                icon: Icons.swap_horiz,
                variant: AppButtonVariant.secondary,
                isLoading: _switching,
                onPressed: () => _switchMode(me),
              ),
          ],
        ),
      ),
    );
  }
}
