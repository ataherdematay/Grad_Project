import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/guards.dart' show isTabRoot;
import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import 'notification_target.dart';
import 'notification_text.dart';
import 'notifications_controller.dart';

/// `/notifications`: müşteri ve usta için ortak bildirim merkezi. Rolü
/// değiştirmez (NAVIGATION_RULES §2).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _markingAll = false;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    // Usta durumu değişmiş olabilir (örn. başvuru onayı): hedefin korumaları
    // güncel profille değerlendirilsin.
    Future.microtask(() {
      if (mounted) unawaited(ref.read(sessionProvider.notifier).refreshMe());
    });
  }

  Future<void> _markAll() async {
    if (_markingAll) return;
    setState(() => _markingAll = true);
    try {
      await ref.read(notificationsProvider.notifier).markAllRead();
    } on ApiException catch (e) {
      if (mounted) reportActionError(context, e);
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  Future<void> _showCantOpen() {
    final l = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.notificationsCantOpenTitle),
        content: SingleChildScrollView(
          child: Text(l.notificationsCantOpenBody),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  /// Sekme kökleri `go` ile, diğer rotalar `push` ile açılır (sekme kökü
  /// ikinci kez yığına eklenmez).
  Future<void> _openRoute(GoRouter router, String route) async {
    if (isTabRoot(Uri.parse(route).path)) {
      router.go(route);
    } else {
      await router.push<void>(route);
    }
  }

  Future<void> _tap(Notification n) async {
    if (_opening) return;
    final me = ref.read(sessionProvider).me;
    if (me == null) return;
    // Çift dokunma hedefi iki kez açmasın: hedef ekran kapanana dek kilitli.
    _opening = true;
    try {
      await _handleTap(n, me);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _handleTap(Notification n, Me me) async {
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final session = ref.read(sessionProvider.notifier);
    // Okundu işareti gezinmeyi beklemez; hata olursa bildirim okunmamış kalır.
    unawaited(ref.read(notificationsProvider.notifier).markRead(n.id));
    final target = resolveNotificationTarget(me, n.targetRoute);
    switch (target.action) {
      case TargetAction.blocked:
        await _showCantOpen();
      case TargetAction.open:
        await _openRoute(router, target.route!);
      case TargetAction.switchToPro || TargetAction.switchToCustomer:
        final toPro = target.action == TargetAction.switchToPro;
        final ok = await showConfirmDialog(
          context,
          title: toPro
              ? l.notificationsSwitchProTitle
              : l.notificationsSwitchCustomerTitle,
          message: toPro
              ? l.notificationsSwitchProBody
              : l.notificationsSwitchCustomerBody,
          confirmLabel: toPro ? l.switchToPro : l.switchToCustomer,
          cancelLabel: l.cancel,
        );
        if (!ok || !mounted) return;
        try {
          await session.switchMode(toPro ? UserMode.pro : UserMode.customer);
          // Mod değişimi yığını sıfırlar; hedef sekme kökünün üstüne açılır.
          router.go(toPro ? '/p/feed' : '/c/home');
          unawaited(_openRoute(router, target.route!));
        } on ApiException catch (e) {
          if (mounted) reportActionError(context, e);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(notificationsProvider);
    final now = ref.read(nowProvider)();
    return ListPage(
      title: l.notificationsTitle,
      leading: const AppBackButton(),
      body: AsyncView<NotificationsState>(
        value: async,
        onRetry: () => ref.invalidate(notificationsProvider),
        builder: (context, s) {
          Future<void> refresh() => ref.refresh(notificationsProvider.future);

          if (s.items.isEmpty) {
            return RefreshIndicator(
              onRefresh: refresh,
              child: LayoutBuilder(
                builder: (context, c) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: c.maxHeight,
                      child: EmptyState(
                        icon: Icons.notifications_none,
                        title: l.notificationsEmptyTitle,
                        message: l.notificationsEmptyBody,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (s.unreadCount > 0)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppButton(
                      label: l.notificationsMarkAllRead,
                      icon: Icons.done_all,
                      variant: AppButtonVariant.tertiary,
                      isLoading: _markingAll,
                      onPressed: _markAll,
                    ),
                  ),
                for (final n in s.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: _NotificationTile(
                      notification: n,
                      now: now,
                      onTap: () => _tap(n),
                    ),
                  ),
                if (s.hasMore) ...[
                  if (s.loadMoreFailed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(
                        l.genericErrorTitle,
                        style: AppTypography.label.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  AppButton(
                    label: l.notificationsLoadMore,
                    variant: AppButtonVariant.secondary,
                    isLoading: s.loadingMore,
                    onPressed: () =>
                        ref.read(notificationsProvider.notifier).loadMore(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.now,
    required this.onTap,
  });

  final Notification notification;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final n = notification;
    final text = notificationText(l, n, now);
    final when = formatDayTime(l, n.createdAt, now);
    final unread = !n.read;
    return AppCard(
      onTap: onTap,
      semanticLabel: unread
          ? '${l.notificationUnread}. $text. $when'
          : '$text. $when',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  notificationIcon(n.kind),
                  color: unread ? AppColors.primary : AppColors.textSecondary,
                ),
                if (unread)
                  const Positioned(top: -2, right: -2, child: _UnreadDot()),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: unread
                        ? AppTypography.weight(
                            AppTypography.body,
                            FontWeight.w700,
                          )
                        : AppTypography.body,
                  ),
                  const SizedBox(height: 4),
                  Text(when, style: AppTypography.bodySecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('unread-dot'),
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: AppColors.error,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.surface, width: 1.5),
    ),
  );
}
