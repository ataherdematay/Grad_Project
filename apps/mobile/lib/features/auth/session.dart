import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

enum SessionStatus { unknown, bootstrapFailed, signedOut, signedIn }

/// Oturum kapanışının kullanıcıya gösterilecek nedeni.
enum SessionNotice { adminBlocked, sessionExpired, accountSuspended }

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

  const SessionState.signedOut({SessionNotice? notice, bool loggedOut = false})
    : this._(
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
  StreamSubscription<SessionEndReason>? _endedSub;

  @override
  SessionState build() {
    final client = ref.watch(apiClientProvider);
    // Token'lar API katmanında silindi: refresh reddedildi ya da hesap askıya
    // alındı (NAVIGATION_RULES §3.6). Açılış sürerken gelirse de işlenir.
    _endedSub = client.sessionEnded.listen((reason) {
      if (state.status == SessionStatus.signedOut) return;
      state = SessionState.signedOut(
        notice: switch (reason) {
          SessionEndReason.expired => SessionNotice.sessionExpired,
          SessionEndReason.suspended => SessionNotice.accountSuspended,
        },
      );
    });
    ref.onDispose(() => _endedSub?.cancel());
    Future.microtask(bootstrap);
    return const SessionState.unknown();
  }

  ApiClient get _client => ref.read(apiClientProvider);

  /// Token varsa `GET /me`, yoksa oturumsuz.
  Future<void> bootstrap() async {
    state = const SessionState.unknown();
    final TokenPair? tokens;
    try {
      tokens = await ref.read(tokenStoreProvider).read();
    } catch (_) {
      // Anahtarlık okunamadı (örn. cihaz açılıştan beri kilitli): açılış
      // ekranında kalıp sonsuza dek dönmek yerine "Tekrar dene" göster.
      state = const SessionState.bootstrapFailed(
        ApiException(code: ApiErrorCode.unknown),
      );
      return;
    }
    if (tokens == null) {
      state = const SessionState.signedOut();
      return;
    }
    try {
      final me = await _client.me.get();
      if (me.isAdmin) {
        await _dropSession();
        state = const SessionState.signedOut(
          notice: SessionNotice.adminBlocked,
        );
        return;
      }
      state = SessionState.signedIn(me);
    } on ApiException catch (e) {
      // `sessionEnded` dinleyicisi oturumu zaten kapattıysa dokunma.
      if (state.status == SessionStatus.signedOut) return;
      if (e.statusCode == 401) {
        // Yalnız sunucu oturumu reddederse token silinir.
        await ref.read(tokenStoreProvider).clear();
        state = SessionState.signedOut(
          notice: e.code == ApiErrorCode.accountSuspended
              ? SessionNotice.accountSuspended
              : null,
        );
      } else {
        // Ağ, 429, 5xx ve beklenmeyen yanıt geçicidir: token korunur,
        // açılış ekranında "Tekrar dene" çıkar.
        state = SessionState.bootstrapFailed(e);
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
