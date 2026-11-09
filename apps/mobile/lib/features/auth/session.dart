import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

enum SessionStatus { unknown, bootstrapFailed, signedOut, signedIn }

/// Oturum kapanışının kullanıcıya gösterilecek nedeni.
enum SessionNotice { adminBlocked, sessionExpired }

/// Yönetici hesabı mobil uygulamaya giriş yapamaz.
class AdminAccountException implements Exception {
  const AdminAccountException();
}

class SessionState {
  const SessionState._({
    required this.status,
    this.me,
    this.notice,
    this.landing,
    this.loggedOut = false,
    this.error,
  });

  const SessionState.unknown() : this._(status: SessionStatus.unknown);

  const SessionState.bootstrapFailed(ApiException error)
    : this._(status: SessionStatus.bootstrapFailed, error: error);

  const SessionState.signedOut({
    SessionNotice? notice,
    bool loggedOut = false,
  }) : this._(
         status: SessionStatus.signedOut,
         notice: notice,
         loggedOut: loggedOut,
       );

  const SessionState.signedIn(Me me, {String? landing})
    : this._(status: SessionStatus.signedIn, me: me, landing: landing);

  final SessionStatus status;
  final Me? me;
  final SessionNotice? notice;

  /// Kayıttan hemen sonra açılacak rota (örn. `/p/apply`).
  final String? landing;

  /// Kullanıcı bilerek çıkış yaptı (girişte `next` taşınmaz).
  final bool loggedOut;
  final ApiException? error;

  bool get isSignedIn => status == SessionStatus.signedIn && me != null;
}

/// Oturum durumunu tutar: açılışta `/me`, giriş, kayıt, çıkış, mod değişimi.
class SessionController extends Notifier<SessionState> {
  StreamSubscription<void>? _expiredSub;

  @override
  SessionState build() {
    final client = ref.watch(apiClientProvider);
    _expiredSub = client.sessionExpired.listen((_) {
      if (state.status == SessionStatus.signedIn) {
        state = const SessionState.signedOut(
          notice: SessionNotice.sessionExpired,
        );
      }
    });
    ref.onDispose(() => _expiredSub?.cancel());
    Future.microtask(bootstrap);
    return const SessionState.unknown();
  }

  ApiClient get _client => ref.read(apiClientProvider);

  /// Token varsa `GET /me`, yoksa oturumsuz.
  Future<void> bootstrap() async {
    state = const SessionState.unknown();
    final tokens = await ref.read(tokenStoreProvider).read();
    if (tokens == null) {
      state = const SessionState.signedOut();
      return;
    }
    try {
      final me = await _client.me.get();
      if (me.isAdmin) {
        await _dropSession();
        state = const SessionState.signedOut(notice: SessionNotice.adminBlocked);
        return;
      }
      state = SessionState.signedIn(me);
    } on ApiException catch (e) {
      if (e.isNetworkError || (e.statusCode ?? 0) >= 500) {
        state = SessionState.bootstrapFailed(e);
      } else {
        await ref.read(tokenStoreProvider).clear();
        state = const SessionState.signedOut();
      }
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final auth = await _client.auth.login(
      LoginRequest(identifier: identifier, password: password),
    );
    await _accept(auth.user);
  }

  Future<void> register(RegisterRequest request) async {
    final auth = await _client.auth.register(request);
    await _accept(
      auth.user,
      landing: request.wantsPro ? '/p/apply' : '/c/home',
    );
  }

  Future<void> _accept(Me me, {String? landing}) async {
    if (me.isAdmin) {
      await _dropSession();
      throw const AdminAccountException();
    }
    state = SessionState.signedIn(me, landing: landing);
  }

  /// Admin hesabı: sunucuda çıkış yap, yerel token'ları sil.
  Future<void> _dropSession() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    try {
      if (tokens != null) await _client.auth.logout(tokens.refreshToken);
    } on ApiException {
      // Yerel token'lar zaten silinir.
    }
    await ref.read(tokenStoreProvider).clear();
  }

  /// Refresh token ile `logout` çağırır, yerel oturumu kapatır.
  Future<void> logout() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    try {
      if (tokens != null) await _client.auth.logout(tokens.refreshToken);
    } on ApiException {
      // Ağ yoksa bile yerel çıkış yapılır.
    }
    await ref.read(tokenStoreProvider).clear();
    state = const SessionState.signedOut(loggedOut: true);
  }

  /// `PATCH /me` ile son modu kaydeder; başarılıysa durum güncellenir.
  Future<void> switchMode(UserMode mode) async {
    final me = await _client.me.update(UpdateMeRequest(lastMode: mode));
    state = SessionState.signedIn(me);
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
