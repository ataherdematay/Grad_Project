import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/language_toggle.dart';

/// Bu genişlik ve üstünde sol gezinme sabit görünür.
const double kDesktopBreakpoint = 1024;

class _NavItem {
  const _NavItem(this.id, this.route, this.icon);

  final String id;
  final String route;
  final IconData icon;
}

const _items = [
  _NavItem('home', Routes.home, Icons.dashboard_outlined),
  _NavItem('applications', Routes.applications, Icons.badge_outlined),
  _NavItem('complaints', Routes.complaints, Icons.flag_outlined),
  _NavItem('accounts', Routes.accounts, Icons.people_outline),
  _NavItem('payments', Routes.payments, Icons.account_balance_wallet_outlined),
];

String _label(AppLocalizations l, String id) => switch (id) {
  'home' => l.navHome,
  'applications' => l.navApplications,
  'complaints' => l.navComplaints,
  'accounts' => l.navAccounts,
  _ => l.navPayments,
};

int _selectedIndex(String location) {
  for (var i = 1; i < _items.length; i++) {
    if (location.startsWith(_items[i].route)) return i;
  }
  return 0;
}

/// Sol gezinme + üst çubuk. 1024 px altında gezinme çekmeceye taşınır.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= kDesktopBreakpoint;
        final selected = _selectedIndex(location);
        final sidebar = _Sidebar(
          selected: selected,
          onSelect: (i) => context.go(_items[i].route),
        );
        return Scaffold(
          drawer: wide ? null : Drawer(child: SafeArea(child: sidebar)),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide) SizedBox(width: 248, child: sidebar),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(showMenu: !wide),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              l.appTitle,
              style: AppTypography.section.copyWith(color: AppColors.primary),
            ),
          ),
          Expanded(
            child: Semantics(
              container: true,
              label: l.navLabel,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _NavTile(
                      key: Key('nav-${_items[i].id}'),
                      icon: _items[i].icon,
                      label: _label(l, _items[i].id),
                      selected: i == selected,
                      onTap: () {
                        // Çekmeceyi Scaffold üzerinden kapat: Navigator.maybePop
                        // detay sayfasındayken çekmeceyi açık bırakıyordu.
                        Scaffold.maybeOf(context)?.closeDrawer();
                        onSelect(i);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        excludeSemantics: true,
        child: Material(
          color: selected ? AppColors.selectedSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.input),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(icon, size: 22, color: fg),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.weight(
                          AppTypography.body.copyWith(color: fg),
                          selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.showMenu});

  final bool showMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final name = ref.watch(sessionProvider.select((s) => s.me?.fullName ?? ''));
    // Çok dar ekranda ad ve başlık gizlenir, çıkış yalnız simge olur.
    final compact = MediaQuery.sizeOf(context).width < 640;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (showMenu)
            Builder(
              builder: (ctx) => AppIconButton(
                icon: Icons.menu,
                tooltip: l.openMenu,
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (showMenu && !compact)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Text(
                  l.appTitle,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          const Spacer(),
          const LanguageToggle(),
          const SizedBox(width: AppSpacing.xs),
          if (compact)
            Tooltip(
              message: name,
              child: const Icon(
                Icons.account_circle_outlined,
                key: Key('admin-name'),
                color: AppColors.textSecondary,
              ),
            )
          else
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      name,
                      key: const Key('admin-name'),
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          if (compact)
            AppIconButton(
              key: const Key('logout'),
              icon: Icons.logout,
              tooltip: l.logout,
              onPressed: () => ref.read(sessionProvider.notifier).logout(),
            )
          else
            TextButton.icon(
              key: const Key('logout'),
              onPressed: () => ref.read(sessionProvider.notifier).logout(),
              icon: const Icon(Icons.logout, size: 20),
              label: Text(l.logout),
            ),
        ],
      ),
    );
  }
}
