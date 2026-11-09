import 'package:bitadilat_api/bitadilat_api.dart';

import '../features/auth/session.dart';

/// Oturumsuz erişilebilen giriş rotaları (NAVIGATION_RULES `G`).
const Set<String> guestPaths = {
  '/welcome',
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
};

const Set<String> _tabPaths = {
  '/c/home',
  '/c/requests',
  '/c/messages',
  '/c/profile',
  '/p/feed',
  '/p/jobs',
  '/p/messages',
  '/p/profile',
};

final RegExp _legalRe = RegExp(r'^/legal/[^/]+$');
final RegExp _chatRe = RegExp(r'^/jobs/[^/]+/chat$');

/// Uygulamada tanımlı rota mı? Değilse "bulunamadı" ekranı gösterilir.
bool isKnownPath(String path) =>
    path == '/' ||
    guestPaths.contains(path) ||
    _tabPaths.contains(path) ||
    path == '/p/apply' ||
    path == '/p/application' ||
    path == '/settings' ||
    path == '/notifications' ||
    _legalRe.hasMatch(path) ||
    _chatRe.hasMatch(path);

bool _isPublic(String path) =>
    path == '/' || guestPaths.contains(path) || _legalRe.hasMatch(path);

/// Yalnızca uygulama içi, korumalı bir rota `next` olarak kabul edilir.
String? safeNext(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (!raw.startsWith('/') || raw.startsWith('//') || raw.contains('\\')) {
    return null;
  }
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  final path = uri.path;
  if (path == '/' || guestPaths.contains(path)) return null;
  const prefixes = ['/c/', '/p/', '/jobs/', '/legal/'];
  final internal =
      isKnownPath(path) || prefixes.any((p) => path.startsWith(p));
  return internal ? raw : null;
}

String withNextQuery(String path, String next) =>
    Uri(path: path, queryParameters: {'next': next}).toString();

/// Kullanıcının etkin modu: usta modu yalnız onaylı usta için geçerli.
bool isProMode(Me me) =>
    me.lastMode == UserMode.pro && me.pro?.reviewStatus == ReviewStatus.approved;

/// Modun ana sekmesi.
String homeFor(Me me) => isProMode(me) ? '/p/feed' : '/c/home';

String _toPro(String path) => switch (path) {
  '/c/requests' => '/p/jobs',
  '/c/messages' => '/p/messages',
  '/c/profile' => '/p/profile',
  _ => '/p/feed',
};

String _toCustomer(String path) => switch (path) {
  '/p/jobs' => '/c/requests',
  '/p/messages' => '/c/messages',
  '/p/profile' => '/c/profile',
  _ => '/c/home',
};

/// NAVIGATION_RULES §3 korumaları. `null` = olduğu gibi aç.
String? guardRedirect(SessionState s, Uri uri) {
  final path = uri.path;

  // Oturum henüz çözülmedi: yalnız açılış ekranı.
  if (s.status == SessionStatus.unknown ||
      s.status == SessionStatus.bootstrapFailed) {
    if (path == '/') return null;
    // Derin bağlantı kaybolmasın: açılıştan sonra `next` ile devam edilir.
    return Uri(path: '/', queryParameters: {'next': uri.toString()}).toString();
  }

  if (!s.isSignedIn) {
    if (path == '/') {
      final raw = uri.queryParameters['next'];
      // Oturumsuz giriş ekranı derin bağlantısı (örn. /login) korunur.
      if (raw != null && guestPaths.contains(Uri.tryParse(raw)?.path)) {
        return raw;
      }
      final next = safeNext(raw);
      return next == null ? '/welcome' : withNextQuery('/welcome', next);
    }
    // Bilinmeyen rota ve genel rotalar olduğu gibi açılır.
    if (!isKnownPath(path) || _isPublic(path)) return null;
    // Oturum süresi dolduysa ya da kullanıcı çıktıysa `next` taşınmaz.
    if (s.notice == SessionNotice.sessionExpired || s.loggedOut) {
      return '/welcome';
    }
    return withNextQuery('/welcome', uri.toString());
  }

  final me = s.me!;
  if (!isKnownPath(path)) return null;

  if (path == '/') {
    return safeNext(uri.queryParameters['next']) ?? s.landing ?? homeFor(me);
  }

  if (guestPaths.contains(path)) {
    return safeNext(uri.queryParameters['next']) ?? s.landing ?? homeFor(me);
  }

  final pro = me.pro;
  final approved = pro?.reviewStatus == ReviewStatus.approved;

  if (path == '/p/apply') {
    if (pro == null) return null;
    return approved ? '/p/feed' : '/p/application';
  }
  if (path == '/p/application') {
    if (pro == null) return '/p/apply';
    return approved ? '/p/feed' : null;
  }
  if (path.startsWith('/p/')) {
    if (pro == null) return '/p/apply';
    if (!approved) return '/p/application';
    // Müşteri modundaki onaylı usta usta rotasını açamaz (rol sınırı).
    if (!isProMode(me)) return _toCustomer(path);
    return null;
  }
  if (path.startsWith('/c/') && isProMode(me)) return _toPro(path);

  return null;
}
