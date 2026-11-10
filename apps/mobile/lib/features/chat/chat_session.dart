import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sohbet yoklama aralığı; testlerde ezilebilir.
final chatPollIntervalProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 3),
);

/// Gönderilirken (ya da gönderilemeyince) görünen geçici baloncuk.
class PendingMessage {
  PendingMessage({
    required this.localId,
    required this.body,
    this.photoId,
    this.photoBytes,
  });

  final int localId;
  final String body;
  final String? photoId;
  final Uint8List? photoBytes;
  bool failed = false;
  ApiException? error;
}

/// Bir işin sohbet durumu: ilk yükleme, `after=` ile yoklama, gönderme,
/// okundu bildirimi. Ağ erişimi tek yerdedir; ekran yalnız dinler.
class ChatSession extends ChangeNotifier {
  ChatSession({
    required this.api,
    required this.jobId,
    this.pollInterval = const Duration(seconds: 3),
    this.pageSize = 50,
  });

  final ChatApi api;
  final String jobId;
  final Duration pollInterval;
  final int pageSize;

  final List<Message> messages = [];
  final List<PendingMessage> pending = [];
  int? otherLastReadId;
  bool loading = true;
  ApiException? error;

  Timer? _timer;
  bool _inFlight = false;
  bool _disposed = false;
  int _markedRead = 0;
  int _localSeq = 0;

  /// `after=` imleci: yalnız liste yanıtından (yükleme ve yoklama) ilerler.
  /// Gönderilen mesajın kimliği imleci ilerletmez; yoksa son yoklamadan sonra
  /// karşı tarafın yazdığı (daha küçük kimlikli) mesaj hiç çekilmez.
  int _cursor = 0;

  bool get isPolling => _timer != null;
  int get lastId => messages.isEmpty ? 0 : messages.last.id;

  void _advance(List<Message> items) {
    for (final m in items) {
      if (m.id > _cursor) _cursor = m.id;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// İlk yükleme: mesajlar `limit` kadar sayfalanarak sonuna kadar çekilir.
  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      for (var guard = 0; guard < 40; guard++) {
        final page = await api.messages(
          jobId,
          after: _cursor == 0 ? null : _cursor,
          limit: pageSize,
        );
        _merge(page.items);
        _advance(page.items);
        otherLastReadId = page.otherLastReadId ?? otherLastReadId;
        if (page.items.length < pageSize) break;
      }
      loading = false;
      _notify();
      unawaited(_markRead());
    } on ApiException catch (e) {
      loading = false;
      error = e;
      _notify();
    }
  }

  void startPolling() {
    if (_disposed) return;
    _timer ??= Timer.periodic(pollInterval, (_) => poll());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// Yeni mesajları ister (`after=` son kimlik). Önceki istek sürüyorsa atlar.
  Future<void> poll() async {
    if (_inFlight || _disposed || loading) return;
    _inFlight = true;
    try {
      final page = await api.messages(
        jobId,
        after: _cursor == 0 ? null : _cursor,
        limit: pageSize,
      );
      _advance(page.items);
      final changed =
          _merge(page.items) || page.otherLastReadId != otherLastReadId;
      otherLastReadId = page.otherLastReadId ?? otherLastReadId;
      if (changed) {
        _notify();
        unawaited(_markRead());
      }
    } on ApiException {
      // Geçici hata: bir sonraki yoklama yeniden dener.
    } finally {
      _inFlight = false;
    }
  }

  /// Yeni mesaj eklendiyse `true`.
  bool _merge(List<Message> items) {
    var added = false;
    final known = {for (final m in messages) m.id};
    for (final m in items) {
      if (known.add(m.id)) {
        messages.add(m);
        added = true;
      }
    }
    if (added) messages.sort((a, b) => a.id.compareTo(b.id));
    return added;
  }

  Future<void> _markRead() async {
    final last = lastId;
    final hasIncoming = messages.any((m) => !m.mine && m.id > _markedRead);
    if (last == 0 || !hasIncoming) return;
    _markedRead = last;
    try {
      await api.markRead(jobId, last);
    } on ApiException {
      _markedRead = 0;
    }
  }

  /// Mesaj gönderir. Önce geçici baloncuk görünür. Hata olursa baloncuk
  /// "gönderilemedi" olarak kalır ve hata döner.
  Future<ApiException?> send(
    String body, {
    String? photoId,
    Uint8List? photoBytes,
  }) {
    final p = PendingMessage(
      localId: --_localSeq,
      body: body,
      photoId: photoId,
      photoBytes: photoBytes,
    );
    pending.add(p);
    _notify();
    return _deliver(p);
  }

  Future<ApiException?> retry(PendingMessage p) {
    p
      ..failed = false
      ..error = null;
    _notify();
    return _deliver(p);
  }

  void discard(PendingMessage p) {
    pending.remove(p);
    _notify();
  }

  Future<ApiException?> _deliver(PendingMessage p) async {
    try {
      final m = await api.send(
        jobId,
        SendMessageRequest(body: p.body, photoId: p.photoId),
      );
      pending.remove(p);
      _merge([m]);
      _notify();
      return null;
    } on ApiException catch (e) {
      p
        ..failed = true
        ..error = e;
      _notify();
      return e;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    super.dispose();
  }
}
