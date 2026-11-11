import 'dart:async';

import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../auth/session.dart';

/// Rozet metni: 99'dan büyük sayılar `99+` görünür.
String badgeText(int count) => count > 99 ? '99+' : '$count';

/// Üst çubuktaki zil: okunmamış sayısı `Me.unreadNotifications`tan gelir.
/// Sayı oturum açılışında ve mod değişiminde zaten taze gelir; sekmeye
/// dönünce, aşağı çekip yenileyince ve bildirim merkezinden dönünce `GET /me`
/// ile yenilenir.
class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  Future<void> _refresh() async {
    if (!mounted) return;
    await ref.read(sessionProvider.notifier).refreshMe();
  }

  Future<void> _open() async {
    await context.push<void>('/notifications');
    unawaited(_refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = ref.watch(
      sessionProvider.select((s) => s.me?.unreadNotifications ?? 0),
    );
    final label = count > 0
        ? l.notificationsBellLabelUnread(count)
        : l.notificationsBellLabel;
    return Stack(
      alignment: Alignment.center,
      children: [
        AppIconButton(
          icon: Icons.notifications_none,
          tooltip: label,
          onPressed: _open,
        ),
        if (count > 0)
          Positioned(
            top: 6,
            right: 4,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Container(
                  key: const ValueKey('bell-badge'),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.canvas, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeText(count),
                    textScaler: TextScaler.noScaling,
                    style: AppTypography.weight(
                      AppTypography.label,
                      FontWeight.w700,
                    ).copyWith(color: Colors.white, fontSize: 10, height: 1.2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
