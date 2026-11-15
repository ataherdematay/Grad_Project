import 'package:bitadilat_api/bitadilat_api.dart';

import '../../app/guards.dart';
import '../auth/session.dart';

/// Bildirime dokununca ne yapılacağı.
enum TargetAction {
  /// Rota bu kullanıcı ve mod için açılabilir.
  open,

  /// Rota usta moduna ait; kullanıcı onaylı usta, şu an müşteri modunda.
  switchToPro,

  /// Rota müşteri moduna ait; kullanıcı şu an usta modunda.
  switchToCustomer,

  /// Açılamaz: iç rota değil, bilinmiyor ya da korumalar izin vermiyor.
  blocked,
}

class NotificationTarget {
  const NotificationTarget(this.action, [this.route]);

  final TargetAction action;
  final String? route;

  @override
  String toString() => 'NotificationTarget($action, $route)';
}

/// `targetRoute` yalnız uygulama içi ve bilinen bir rota ise kabul edilir
/// (şema, sunucu adı, `//`, ters eğik çizgi, `..` olmaz).
String? internalRoute(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (!raw.startsWith('/') || raw.startsWith('//')) return null;
  if (raw.contains('\\') || raw.contains('..')) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  // Kodlanmış `..`, `/` ya da `\` (`%2e%2e`, `%2F`, `%5C`) parametre olarak
  // çözülüp başka bir API yoluna gitmesin.
  for (final seg in uri.pathSegments) {
    if (seg == '.' || seg == '..' || seg.contains('/') || seg.contains('\\')) {
      return null;
    }
  }
  final path = uri.path;
  if (path == '/' || path == '/notifications') return null;
  if (guestPaths.contains(path)) return null;
  if (!isKnownPath(path)) return null;
  return raw;
}

/// Rota korumaları (`guardRedirect`) ile aynı kurallarla karar verir; mod
/// değişimi yalnız kullanıcının o moda hakkı varsa önerilir.
NotificationTarget resolveNotificationTarget(Me me, String? raw) {
  final route = internalRoute(raw);
  if (route == null) return const NotificationTarget(TargetAction.blocked);
  final uri = Uri.parse(route);
  final redirect = guardRedirect(SessionState.signedIn(me), uri);
  if (redirect == null) return NotificationTarget(TargetAction.open, route);
  final path = uri.path;
  if (path.startsWith('/p/') &&
      me.pro?.reviewStatus == ReviewStatus.approved &&
      !isProMode(me)) {
    return NotificationTarget(TargetAction.switchToPro, route);
  }
  if (path.startsWith('/c/') && isProMode(me)) {
    return NotificationTarget(TargetAction.switchToCustomer, route);
  }
  // Onaysız ya da askıdaki usta: korumalar gibi başvuru durumu ekranı açılır
  // (askı nedeni ve sonraki adım orada anlatılır).
  if (path.startsWith('/p/') && redirect == '/p/application') {
    return const NotificationTarget(TargetAction.open, '/p/application');
  }
  return const NotificationTarget(TargetAction.blocked);
}
