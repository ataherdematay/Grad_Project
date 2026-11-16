import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

enum SessionStatus { signedOut, signedIn }

/// Oturum kapanışının girişte gösterilecek nedeni.
enum SessionNotice { sessionExpired, accountSuspended, accessDenied }

/// Giriş yapan hesap yönetici değil: oturum hemen kapatılır.
class NotAdminException implements Exception {
  const NotAdminException();
}

class SessionState {
  const SessionState.signedOut({this.notice})
    : status = SessionStatus.signedOut,
      me = null;

  const SessionState.signedIn(Me this.me, {this.notice})
    : status = SessionStatus.signedIn;

  final SessionStatus status;
  final Me? me;
  final SessionNotice? notice;

  bool get isSignedIn => status == SessionStatus.signedIn && me != null;
}

/// Oturum durumu. Token'lar yalnız bellekte; açılışta `/me` çağrısı yok, sayfa
/// yenilenince yeniden giriş gerekir.
class SessionController extends Notifier<SessionState> {
  StreamSubscription<SessionEndReason>? _endedSub;

  @override
  SessionState build() {
    final client = ref.watch(apiClientProvider);
    // Refresh reddedildi ya da hesap askıya alındı: token'lar API katmanında
    // silindi, girişe dön.
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
    return const SessionState.signedOut();
  }

  ApiClient get _client => ref.read(apiClientProvider);

  /// Başarısızlıkta `ApiException` ya da [NotAdminException] fırlatır.
  Future<void> login({required String email, required String password}) async {
    final auth = await _client.auth.login(
      LoginRequest(identifier: email.trim(), password: password),
    );
    if (!auth.user.isAdmin) {
      try {
        await _client.auth.logout(auth.refreshToken);
      } on ApiException {
        // Yerel token'lar logout içinde her durumda silinir.
      }
      await ref.read(tokenStoreProvider).clear();
      throw const NotAdminException();
    }
    state = SessionState.signedIn(auth.user);
  }

  Future<void> logout() async {
    final tokens = await ref.read(tokenStoreProvider).read();
    try {
      if (tokens != null) await _client.auth.logout(tokens.refreshToken);
    } on ApiException {
      // Ağ yoksa bile yerel çıkış yapılır.
    }
    await ref.read(tokenStoreProvider).clear();
    state = const SessionState.signedOut();
  }

  /// Oturum sürerken sunucu 403 verdi (yönetici yetkisi alınmış olabilir):
  /// sunucuda oturum kapatılmaya çalışılır, yerel token'lar silinir ve girişe
  /// dönülür.
  Future<void> accessDenied() async {
    if (state.status == SessionStatus.signedOut) return;
    final tokens = await ref.read(tokenStoreProvider).read();
    state = const SessionState.signedOut(notice: SessionNotice.accessDenied);
    try {
      if (tokens != null) await _client.auth.logout(tokens.refreshToken);
    } on ApiException {
      // Sunucu reddetse de yerel oturum kapanır.
    }
    await ref.read(tokenStoreProvider).clear();
  }
}

/// Oturum açıkken gelen her 403 yanıtında oturumu temiz biçimde kapatır.
/// Uygulama kökünde izlenir; `/auth/*` çağrıları kapsam dışıdır.
final sessionGuardProvider = Provider<void>((ref) {
  final sub = ref.watch(apiClientProvider).forbidden.listen((_) {
    if (ref.read(sessionProvider).isSignedIn) {
      unawaited(ref.read(sessionProvider.notifier).accessDenied());
    }
  });
  ref.onDispose(sub.cancel);
});

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
