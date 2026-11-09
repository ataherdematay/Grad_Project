import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/app/guards.dart';
import 'package:bitadilat_mobile/core/providers.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('Koruma matrisi (router)', () {
    testWidgets('oturumsuz /c/requests -> /welcome?next=/c/requests', (t) async {
      final h = await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/c/requests',
      );
      expect(h.uri.path, '/welcome');
      expect(h.uri.queryParameters['next'], '/c/requests');
    });

    testWidgets('girişten sonra next (/c/requests) açılır',
        (t) async {
      final h = await pumpApp(
        t,
        initial: '/c/requests',
        handler: (o) {
          if (o.path.endsWith('/auth/login')) return json(200, authJson());
          return apiError(404, 'NOT_FOUND');
        },
      );
      // Açılışta token yok -> karşılama, next korunur.
      expect(h.uri.path, '/welcome');
      expect(h.uri.queryParameters['next'], '/c/requests');

      await t.tap(find.widgetWithText(AppButton, 'Giriş yap'));
      await t.pumpAndSettle();
      expect(h.uri.path, '/login');

      await t.enterText(find.byType(TextFormField).at(0), 'ayse@example.com');
      await t.enterText(find.byType(TextFormField).at(1), 'abcd1234');
      await t.tap(find.widgetWithText(AppButton, 'Giriş yap'));
      await t.pumpAndSettle();

      expect(h.location, '/c/requests');
      expect(find.text('Taleplerim'), findsWidgets);
      expect(find.text('Bu bölüm hazırlanıyor'), findsOneWidget);
      expect((await h.store.read())?.accessToken, 'ACCESS');
    });

    testWidgets('oturumlu /login -> /c/home', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/login',
      );
      expect(h.location, '/c/home');
    });

    testWidgets('oturumlu / ve /welcome -> modun ana sekmesi', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(
          testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
        ),
        initial: '/welcome',
      );
      expect(h.location, '/p/feed');
    });

    testWidgets('pro == null iken /p/feed -> /p/apply', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/p/feed',
      );
      expect(h.location, '/p/apply');
    });

    testWidgets('PENDING_REVIEW iken /p/feed -> /p/application', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe(proStatus: 'PENDING_REVIEW')),
        initial: '/p/feed',
      );
      expect(h.location, '/p/application');
      expect(find.text('İnceleniyor'), findsOneWidget);
    });

    for (final status in ['NEEDS_DOCUMENTS', 'REJECTED', 'SUSPENDED']) {
      testWidgets('$status iken /p/jobs -> /p/application', (t) async {
        final h = await pumpApp(
          t,
          session: SessionState.signedIn(testMe(proStatus: status)),
          initial: '/p/jobs',
        );
        expect(h.location, '/p/application');
      });
    }

    testWidgets('onaylı usta usta modunda /p/feed açar', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(
          testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
        ),
        initial: '/p/feed',
      );
      expect(h.location, '/p/feed');
    });

    testWidgets('rol sınırı: usta modunda /c/requests -> /p/jobs', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(
          testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
        ),
        initial: '/c/requests',
      );
      expect(h.location, '/p/jobs');
    });

    testWidgets('rol sınırı: müşteri modunda onaylı usta /p/profile -> /c/profile',
        (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe(proStatus: 'APPROVED')),
        initial: '/p/profile',
      );
      expect(h.location, '/c/profile');
    });

    testWidgets('müşteri /p/apply açabilir', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/p/apply',
      );
      expect(h.location, '/p/apply');
    });

    testWidgets('bilinmeyen rota -> markalı bulunamadı ekranı', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/yok/boyle/bir/sey',
      );
      expect(find.text('Sayfa bulunamadı'), findsOneWidget);
      expect(find.text('BiTadilat'), findsOneWidget);
      await t.tap(find.text('Ana sayfaya dön'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
    });

    testWidgets('oturumsuz bilinmeyen rota da bulunamadı gösterir', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/yok',
      );
      expect(find.text('Sayfa bulunamadı'), findsOneWidget);
    });

    testWidgets('next dış adres olamaz: açık yönlendirme engellenir', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/login?next=https%3A%2F%2Fevil.example',
      );
      expect(h.location, '/c/home');
    });

    testWidgets('admin hesabı girişi reddedilir, token silinir', (t) async {
      final h = await pumpApp(
        t,
        initial: '/login',
        handler: (o) {
          if (o.path.endsWith('/auth/login')) {
            return json(200, authJson(isAdmin: true));
          }
          if (o.path.endsWith('/auth/logout')) return empty(204);
          return apiError(404, 'NOT_FOUND');
        },
      );
      await t.enterText(find.byType(TextFormField).at(0), 'admin@example.com');
      await t.enterText(find.byType(TextFormField).at(1), 'abcd1234');
      await t.tap(find.widgetWithText(AppButton, 'Giriş yap'));
      await t.pumpAndSettle();

      expect(
        find.text('Yönetici hesabıyla web panelinden giriş yap.'),
        findsOneWidget,
      );
      expect(h.uri.path, '/login');
      expect(await h.store.read(), isNull);
      expect(h.adapter.count('POST', '/auth/logout'), 1);
    });

    testWidgets('açılışta token + /me varsa modun ana sekmesi', (t) async {
      final h = await pumpApp(
        t,
        tokens: const TokenPair(accessToken: 'A', refreshToken: 'R'),
        handler: (o) {
          if (o.path.endsWith('/me')) return json(200, meJson());
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(h.location, '/c/home');
    });

    testWidgets('açılışta /me admin dönerse oturum kapanır ve mesaj çıkar',
        (t) async {
      final h = await pumpApp(
        t,
        tokens: const TokenPair(accessToken: 'A', refreshToken: 'R'),
        handler: (o) {
          if (o.path.endsWith('/me')) return json(200, meJson(isAdmin: true));
          if (o.path.endsWith('/auth/logout')) return empty(204);
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(h.uri.path, '/welcome');
      expect(
        find.text('Yönetici hesabıyla web panelinden giriş yap.'),
        findsOneWidget,
      );
      expect(await h.store.read(), isNull);
    });

    testWidgets('açılışta ağ hatası -> tekrar dene, token silinmez', (t) async {
      var fail = true;
      final h = await pumpApp(
        t,
        tokens: const TokenPair(accessToken: 'A', refreshToken: 'R'),
        handler: (o) {
          if (o.path.endsWith('/me')) {
            if (fail) {
              throw DioException.connectionError(requestOptions: o, reason: 'x');
            }
            return json(200, meJson());
          }
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(find.text('Oturumun açılamadı'), findsOneWidget);
      expect(await h.store.read(), isNotNull);
      fail = false;
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
    });

    testWidgets('sessionExpired -> /welcome ve bildirim', (t) async {
      var meCalls = 0;
      final h = await pumpApp(
        t,
        tokens: const TokenPair(accessToken: 'OLD', refreshToken: 'R'),
        handler: (o) {
          if (o.path.endsWith('/auth/refresh')) {
            return apiError(401, 'UNAUTHENTICATED');
          }
          if (o.path.endsWith('/me')) {
            meCalls++;
            return meCalls == 1
                ? json(200, meJson())
                : apiError(401, 'TOKEN_EXPIRED');
          }
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(h.location, '/c/home');
      await t.runAsync(() async {
        await expectLater(
          h.container.read(apiClientProvider).me.get(),
          throwsA(isA<ApiException>()),
        );
      });
      await t.pumpAndSettle();
      expect(h.location, '/welcome');
      expect(
        find.text('Oturumunun süresi doldu. Tekrar giriş yap.'),
        findsOneWidget,
      );
      expect(await h.store.read(), isNull);
    });

    testWidgets('mod değişimi yığını sıfırlar', (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(
          testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
        ),
        initial: '/p/profile',
        handler: (o) {
          if (o.method == 'PATCH' && o.path.endsWith('/me')) {
            expect((o.data as Map)['lastMode'], 'CUSTOMER');
            return json(
              200,
              meJson(lastMode: 'CUSTOMER', pro: proJson('APPROVED')),
            );
          }
          return apiError(404, 'NOT_FOUND');
        },
      );
      // Önce ayarlara it: yığında 2 ekran olsun.
      await t.tap(find.text('Ayarlar'));
      await t.pumpAndSettle();
      expect(h.location, '/settings');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/p/profile');

      await t.tap(find.text('Müşteri moduna geç'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
      expect(h.router.canPop(), isFalse);
    });

    testWidgets('sekme kökünde geri oku yok', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/home',
      );
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('sekmeler arası geçiş ve Android geri ilk sekmeye döner',
        (t) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/home',
      );
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      expect(h.location, '/c/messages');
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
    });
  });

  group('guardRedirect / safeNext', () {
    test('safeNext yalnız uygulama içi rotayı kabul eder', () {
      expect(safeNext('/c/requests'), '/c/requests');
      expect(safeNext('/c/requests/42?x=1'), '/c/requests/42?x=1');
      expect(safeNext('https://evil.example'), isNull);
      expect(safeNext('//evil.example'), isNull);
      expect(safeNext('javascript:alert(1)'), isNull);
      expect(safeNext('/login'), isNull);
      expect(safeNext('/'), isNull);
      expect(safeNext(''), isNull);
      expect(safeNext(null), isNull);
      expect(safeNext(r'/\evil'), isNull);
    });

    test('oturum çözülmeden her rota açılışa gider', () {
      expect(
        guardRedirect(const SessionState.unknown(), Uri.parse('/c/home')),
        startsWith('/?next='),
      );
      expect(
        guardRedirect(const SessionState.unknown(), Uri.parse('/')),
        isNull,
      );
    });
  });
}
