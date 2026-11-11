import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/providers.dart';
import '../auth/session.dart';

/// Bildirimler sayfa sayfa gelir; ilk sayfa ekran açılınca yüklenir.
const int kNotificationsPageSize = 20;

class NotificationsState {
  const NotificationsState({
    required this.items,
    this.nextCursor,
    this.unreadCount = 0,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Notification> items;
  final String? nextCursor;
  final int unreadCount;
  final bool loadingMore;
  final bool loadMoreFailed;

  bool get hasMore => nextCursor != null;

  NotificationsState copyWith({
    List<Notification>? items,
    String? Function()? nextCursor,
    int? unreadCount,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) => NotificationsState(
    items: items ?? this.items,
    nextCursor: nextCursor == null ? this.nextCursor : nextCursor(),
    unreadCount: unreadCount ?? this.unreadCount,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

/// Bildirim listesi. Okundu işlemleri sunucuya gider, yerel liste ve zil
/// rozeti (`Me.unreadNotifications`) hemen güncellenir.
class NotificationsController extends AsyncNotifier<NotificationsState> {
  NotificationsApi get _api => ref.read(apiClientProvider).notifications;

  @override
  Future<NotificationsState> build() async {
    final page = await _api.list(limit: kNotificationsPageSize);
    _syncBadge(page.unreadCount);
    return NotificationsState(
      items: page.items,
      nextCursor: page.nextCursor,
      unreadCount: page.unreadCount,
    );
  }

  void _syncBadge(int count) {
    // Oluşturma sırasında başka sağlayıcıya yazılamaz.
    Future.microtask(() {
      if (!ref.mounted) return;
      ref.read(sessionProvider.notifier).setUnreadNotifications(count);
    });
  }

  Future<void> loadMore() async {
    final s = state.value;
    if (s == null || !s.hasMore || s.loadingMore) return;
    state = AsyncData(s.copyWith(loadingMore: true, loadMoreFailed: false));
    try {
      final page = await _api.list(
        cursor: s.nextCursor,
        limit: kNotificationsPageSize,
      );
      if (!ref.mounted) return;
      final cur = state.value ?? s;
      final known = {for (final n in cur.items) n.id};
      state = AsyncData(
        cur.copyWith(
          items: [
            ...cur.items,
            for (final n in page.items)
              if (!known.contains(n.id)) n,
          ],
          nextCursor: () => page.nextCursor,
          unreadCount: page.unreadCount,
          loadingMore: false,
        ),
      );
      _syncBadge(page.unreadCount);
    } on ApiException {
      if (!ref.mounted) return;
      state = AsyncData(
        (state.value ?? s).copyWith(loadingMore: false, loadMoreFailed: true),
      );
    }
  }

  /// Tek bildirimi okundu yapar. Ağ hatası gezinmeyi engellemez: yerel durum
  /// değişmez, hata yutulur ve `false` döner.
  Future<bool> markRead(String id) async {
    final s = state.value;
    final target = s?.items.where((n) => n.id == id).firstOrNull;
    if (s == null || target == null || target.read) return true;
    try {
      await _api.markRead(ids: [id]);
    } on ApiException {
      return false;
    }
    if (!ref.mounted) return true;
    final cur = state.value ?? s;
    final unread = (cur.unreadCount - 1).clamp(0, 1 << 30);
    state = AsyncData(
      cur.copyWith(
        items: [
          for (final n in cur.items)
            if (n.id == id) n.copyWith(read: true) else n,
        ],
        unreadCount: unread,
      ),
    );
    ref.read(sessionProvider.notifier).setUnreadNotifications(unread);
    return true;
  }

  /// "Tümünü okundu say".
  Future<void> markAllRead() async {
    final s = state.value;
    if (s == null) return;
    await _api.markAllRead();
    if (!ref.mounted) return;
    final cur = state.value ?? s;
    state = AsyncData(
      cur.copyWith(
        items: [for (final n in cur.items) n.copyWith(read: true)],
        unreadCount: 0,
      ),
    );
    ref.read(sessionProvider.notifier).setUnreadNotifications(0);
  }
}

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      NotificationsState
    >(NotificationsController.new, retry: noRetry);
