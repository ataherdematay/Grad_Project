import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../settings/change_email_dialog.dart';
import '../settings/edit_profile_dialog.dart';

class TabSpec {
  const TabSpec(
    this.icon,
    this.selectedIcon,
    this.label, {
    this.refresh,
    this.root,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Sekmeye dönülünce çalışır: sekmenin verisini yeniden çekmek için
  /// sağlayıcıları geçersiz kılar (NAVIGATION_RULES §4).
  final void Function(WidgetRef ref)? refresh;

  /// Sekmenin kök adresi. Verilirse, sekmeden açılan bir ekran kapanıp bu
  /// adrese dönüldüğünde de [refresh] çalışır.
  final String? root;
}

/// Alt sekme iskeleti. Sekme kökünde geri oku yoktur; Android geri tuşu
/// önce ilk sekmeye döner.
class TabShell extends ConsumerStatefulWidget {
  const TabShell({super.key, required this.shell, required this.tabs});

  final StatefulNavigationShell shell;
  final List<TabSpec> tabs;

  @override
  ConsumerState<TabShell> createState() => _TabShellState();
}

class _TabShellState extends ConsumerState<TabShell> {
  GoRouterDelegate? _delegate;
  bool _onRoot = true;

  StatefulNavigationShell get shell => widget.shell;
  List<TabSpec> get tabs => widget.tabs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.maybeOf(context)?.routerDelegate;
    if (identical(delegate, _delegate)) return;
    _delegate?.removeListener(_onRouteChanged);
    _delegate = delegate?..addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _delegate?.removeListener(_onRouteChanged);
    super.dispose();
  }

  /// Sekmeden açılan ekran (talep, iş, teklif...) kapanıp sekme köküne
  /// dönülünce sekmenin verisi yeniden çekilir (NAVIGATION_RULES §4); ekran
  /// sunucudaki durumu değiştirmiş olabilir.
  void _onRouteChanged() {
    final delegate = _delegate;
    if (delegate == null || !mounted) return;
    final config = delegate.currentConfiguration;
    if (config.isEmpty) return;
    final last = config.matches.last;
    final uri = last is ImperativeRouteMatch ? last.matches.uri : config.uri;
    final root = tabs[shell.currentIndex].root;
    final onRoot = root != null && uri.path == root;
    final returned = onRoot && !_onRoot;
    _onRoot = onRoot || root == null;
    if (returned) tabs[shell.currentIndex].refresh?.call(ref);
  }

  void _open(int i) {
    // Sekmeler yığında canlı kalır; dönüşte eski veri değil güncel veri
    // gösterilsin diye sekmenin sağlayıcıları geçersiz kılınır.
    tabs[i].refresh?.call(ref);
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _open(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _open,
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

  Future<void> _edit(Me me) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showEditProfileDialog(context, me);
    if (!ok) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.accountUpdated)));
  }

  Future<void> _changeEmail() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showChangeEmailDialog(context);
    if (!ok) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.emailChangeDone)));
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
                    if ((me.phone ?? '').isNotEmpty) ...[
                      Text(me.phone!, style: AppTypography.bodySecondary),
                      Text(l.phoneReadOnlyNote, style: AppTypography.label),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        TextButton.icon(
                          onPressed: () => _edit(me),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(l.accountEdit),
                        ),
                        TextButton.icon(
                          onPressed: _changeEmail,
                          icon: const Icon(Icons.alternate_email, size: 18),
                          label: Text(l.emailChangeAction),
                        ),
                      ],
                    ),
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
              AppButton(
                label: l.paymentsTitle,
                icon: Icons.receipt_long_outlined,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/c/payments'),
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
