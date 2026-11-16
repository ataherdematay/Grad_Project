import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';

Handler _handler({
  Map<String, dynamic>? Function()? onDelete,
  Map<String, dynamic>? Function()? onPassword,
  Map<String, dynamic>? Function()? onPatch,
}) => routes({
  ...baseRoutes(),
  'GET /me': (_) => json(200, meJson()),
  'GET /requests': (_) => json(200, {'items': <Object>[]}),
  'GET /jobs': (_) => json(200, {'items': <Object>[]}),
  'DELETE /me': (_) {
    final err = onDelete?.call();
    return err == null ? empty(204) : json(409, err);
  },
  'POST /me/password': (_) {
    final err = onPassword?.call();
    return err == null ? empty(204) : json(400, err);
  },
  'PATCH /me': (o) {
    final err = onPatch?.call();
    if (err != null) return json(400, err);
    return json(200, {...meJson(), 'fullName': (o.data as Map)['fullName']});
  },
});

Future<void> _openChangePassword(WidgetTester t) async {
  await t.tap(find.text('Şifreyi değiştir'));
  await t.pumpAndSettle();
}

void main() {
  group('Ayarlar: şifre değiştirme', () {
    testWidgets('alanlar boşken ve şifreler uyuşmazken istek gitmez', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(),
      );
      await _openChangePassword(t);
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(find.text('Bu alanı doldur.'), findsNWidgets(3));

      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'eski1234');
      await t.enterText(fields.at(1), 'yeni12345');
      await t.enterText(fields.at(2), 'baska12345');
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(find.text('Şifreler aynı değil.'), findsOneWidget);
      expect(h.adapter.count('POST', '/me/password'), 0);
    });

    testWidgets('başarıda istek gider, bildirim çıkar', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(),
      );
      await _openChangePassword(t);
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'eski1234');
      await t.enterText(fields.at(1), 'yeni12345');
      await t.enterText(fields.at(2), 'yeni12345');
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/me/password').data, {
        'currentPassword': 'eski1234',
        'newPassword': 'yeni12345',
      });
      expect(
        find.text('Şifren değişti. Diğer cihazlardaki oturumların kapandı.'),
        findsOneWidget,
      );
      expect(find.text('Şifreni değiştir'), findsNothing);
    });

    testWidgets('yanlış mevcut şifre alan altında görünür', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(
          onPassword: () => {
            'code': 'VALIDATION_FAILED',
            'message': 'x',
            'field': 'currentPassword',
          },
        ),
      );
      await _openChangePassword(t);
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'yanlis123');
      await t.enterText(fields.at(1), 'yeni12345');
      await t.enterText(fields.at(2), 'yeni12345');
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(find.text('Mevcut şifre yanlış.'), findsOneWidget);
      expect(find.text('Şifreni değiştir'), findsOneWidget);
    });

    testWidgets('EN: başlık ve eşleşmeme metni İngilizce', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(),
        locale: 'en',
      );
      await t.tap(find.text('Change password'));
      await t.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'old12345');
      await t.enterText(fields.at(1), 'new12345');
      await t.enterText(fields.at(2), 'other12345');
      await t.tap(find.text('Save'));
      await t.pumpAndSettle();
      expect(find.text('The passwords do not match.'), findsOneWidget);
    });
  });

  group('Ayarlar: hesap silme', () {
    testWidgets('onay verilince DELETE /me gider ve karşılamaya dönülür', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(),
      );
      await t.ensureVisible(find.text('Hesabımı sil'));
      await t.tap(find.text('Hesabımı sil'));
      await t.pumpAndSettle();
      expect(find.text('Hesabın silinsin mi?'), findsOneWidget);
      await t.tap(find.text('Hesabı sil'));
      await t.pumpAndSettle();
      expect(h.adapter.count('DELETE', '/me'), 1);
      expect(h.location, '/welcome');
    });

    testWidgets('vazgeçilirse istek gitmez', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(),
      );
      await t.ensureVisible(find.text('Hesabımı sil'));
      await t.tap(find.text('Hesabımı sil'));
      await t.pumpAndSettle();
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(h.adapter.count('DELETE', '/me'), 0);
      expect(h.location, '/settings');
    });

    testWidgets('açık iş varken sunucu reddi açıklanır, oturum açık kalır', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(
          onDelete: () => {'code': 'ILLEGAL_STATE', 'message': 'x'},
        ),
      );
      await t.ensureVisible(find.text('Hesabımı sil'));
      await t.tap(find.text('Hesabımı sil'));
      await t.pumpAndSettle();
      await t.tap(find.text('Hesabı sil'));
      await t.pumpAndSettle();
      expect(find.textContaining('hesabını silemezsin'), findsOneWidget);
      expect(h.location, '/settings');
    });

    testWidgets('EN: red metni İngilizce', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/settings',
        handler: _handler(
          onDelete: () => {'code': 'ILLEGAL_STATE', 'message': 'x'},
        ),
        locale: 'en',
      );
      await t.ensureVisible(find.text('Delete my account'));
      await t.tap(find.text('Delete my account'));
      await t.pumpAndSettle();
      await t.tap(find.text('Delete account'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('You cannot delete your account'),
        findsOneWidget,
      );
    });
  });

  group('Profil düzenleme', () {
    testWidgets('ad güncellenir ve profil kartı yenilenir', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/profile',
        handler: _handler(),
      );
      await t.tap(find.text('Profili düzenle'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField), 'Ayşe Demir');
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/me').data, {'fullName': 'Ayşe Demir'});
      expect(find.text('Ayşe Demir'), findsOneWidget);
      expect(find.text('Profilin güncellendi.'), findsOneWidget);
    });

    testWidgets('geçersiz ad istek göndermez', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/profile',
        handler: _handler(),
      );
      await t.tap(find.text('Profili düzenle'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField), 'Ayşe');
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(find.text('Adını ve soyadını gir.'), findsOneWidget);
      expect(h.adapter.count('PATCH', '/me'), 0);
    });

    testWidgets('sunucu alan hatası gösterilir', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/profile',
        handler: _handler(
          onPatch: () => {
            'code': 'VALIDATION_FAILED',
            'message': 'x',
            'field': 'fullName',
          },
        ),
      );
      await t.tap(find.text('Profili düzenle'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField), 'Ayşe Demir');
      await t.tap(find.text('Kaydet'));
      await t.pumpAndSettle();
      expect(
        find.text('Bu alan hatalı. Kontrol edip tekrar dene.'),
        findsOneWidget,
      );
    });
  });

  group('Sekmeye dönünce yenileme', () {
    testWidgets('sekmeden açılan ekran kapanınca sekme verisi yenilenir', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/requests',
        handler: _handler(),
      );
      final before = h.adapter.count('GET', '/requests');
      h.router.push('/settings');
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/requests'), before);
      h.router.pop();
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/requests'), greaterThan(before));
    });

    testWidgets('profil sekmesine dönünce GET /me yenilenir', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/home',
        handler: _handler(),
      );
      final before = h.adapter.count('GET', '/me');
      await t.tap(find.text('Profil'));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/me'), greaterThan(before));
    });
  });

  group('Yasal metinler', () {
    for (final (locale, badge) in [
      ('tr', 'Taslak metin'),
      ('en', 'Draft text'),
    ]) {
      testWidgets('$locale: taslak olduğu açıkça yazar', (t) async {
        await pumpApp(
          t,
          session: SessionState.signedIn(testMe()),
          initial: '/legal/kvkk',
          handler: _handler(),
          locale: locale,
        );
        expect(find.text(badge), findsOneWidget);
        expect(
          find.textContaining(locale == 'tr' ? 'taslaktır' : 'is a draft'),
          findsOneWidget,
        );
      });
    }
  });
}
