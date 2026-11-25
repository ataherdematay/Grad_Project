import 'package:bitadilat_admin/app/router.dart';
import 'package:bitadilat_admin/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  group('Giriş', () {
    testWidgets('oturum yokken giriş ekranına yönlenir', (tester) async {
      final h = await pumpAdmin(
        tester,
        signedIn: false,
        initial: '/applications',
      );
      expect(h.location, '/login');
      expect(find.text('Yönetici girişi'), findsOneWidget);
    });

    testWidgets('yönetici girişi başarılı: genel bakış ve admin adı', (
      tester,
    ) async {
      final fake = FakeApi()..onJson('POST', '/auth/login', authJson());
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester);

      expect(h.location, '/');
      expect(find.byKey(const Key('admin-name')), findsOneWidget);
      expect(find.text('Zeynep Yönetici'), findsWidgets);
      // E-posta, kimlik (identifier) olarak gider.
      expect(fake.last('POST', '/auth/login').data, {
        'identifier': 'admin@bitadilat.test',
        'password': 'Demo1234!',
      });
      // Token yalnız bellekte.
      expect(h.store, isNotNull);
      expect((await h.store.read())!.accessToken, 'ACCESS');
    });

    testWidgets('yönetici olmayan hesap reddedilir ve oturum kapatılır', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson('POST', '/auth/login', authJson(isAdmin: false))
        ..on('POST', '/auth/logout', (_) => empty(204));
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester, email: 'ayse@example.com');

      expect(h.location, '/login');
      expect(find.textContaining('yönetici hesabı değil'), findsOneWidget);
      expect(fake.count('POST', '/auth/logout'), 1);
      expect(fake.last('POST', '/auth/logout').data, {
        'refreshToken': 'REFRESH',
      });
      expect(await h.store.read(), isNull);
      // Yönetici ekranlarına hiç gidilmedi.
      expect(fake.count('GET', '/admin/stats'), 0);
    });

    testWidgets('yanlış şifre mesajı gösterir', (tester) async {
      final fake = FakeApi()
        ..on('POST', '/auth/login', (_) => apiError(401, 'BAD_CREDENTIALS'));
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester);

      expect(h.location, '/login');
      expect(find.textContaining('E-posta ya da şifre hatalı'), findsOneWidget);
    });

    testWidgets('boş alanlar sunucuya gitmez', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, signedIn: false);
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Geçerli bir e-posta adresi gir.'), findsOneWidget);
      expect(find.text('Şifreni gir.'), findsOneWidget);
      expect(fake.count('POST', '/auth/login'), 0);
    });

    testWidgets('çıkış girişe döndürür ve token siler', (tester) async {
      final fake = FakeApi()..on('POST', '/auth/logout', (_) => empty(204));
      final h = await pumpAdmin(tester, fake: fake);
      expect(h.location, '/');
      await tester.tap(find.byKey(const Key('logout')));
      await tester.pumpAndSettle();
      expect(h.location, '/login');
      expect(await h.store.read(), isNull);
      expect(fake.count('POST', '/auth/logout'), 1);
    });

    testWidgets('sessionExpired sonrası girişe dönülür ve açıklama çıkar', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson('POST', '/auth/login', authJson())
        ..on('POST', '/auth/refresh', (_) => apiError(401, 'UNAUTHENTICATED'));
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester);
      expect(h.location, '/');

      // Erişim token'ı doldu, yenileme de reddedildi.
      fake.on(
        'GET',
        '/admin/applications',
        (_) => apiError(401, 'TOKEN_EXPIRED'),
      );
      h.router.go(Routes.applications);
      await tester.pumpAndSettle();

      expect(h.location, '/login');
      expect(find.textContaining('Oturumunun süresi doldu'), findsOneWidget);
      expect(await h.store.read(), isNull);
      expect(fake.count('POST', '/auth/refresh'), 1);
    });

    testWidgets('askıya alınan hesap oturumu kapatır', (tester) async {
      final fake = FakeApi()
        ..onJson('POST', '/auth/login', authJson())
        ..on('GET', '/admin/stats', (_) => apiError(401, 'ACCOUNT_SUSPENDED'));
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester);
      expect(h.location, '/login');
      expect(find.textContaining('askıya alındı'), findsOneWidget);
    });

    testWidgets('oturum sürerken 403: sunucuda çıkış, girişe dönüş, açıklama', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson('POST', '/auth/login', authJson())
        ..on('POST', '/auth/logout', (_) => empty(204));
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester);
      expect(h.location, '/');

      fake.on('GET', '/admin/applications', (_) => apiError(403, 'FORBIDDEN'));
      h.router.go(Routes.applications);
      await tester.pumpAndSettle();

      expect(h.location, '/login');
      expect(find.textContaining('oturumun kapatıldı'), findsOneWidget);
      expect(await h.store.read(), isNull);
      expect(fake.count('POST', '/auth/logout'), 1);
      expect(fake.last('POST', '/auth/logout').data, {
        'refreshToken': 'REFRESH',
      });
    });

    testWidgets('403 İngilizce açıklama gösterir', (tester) async {
      final fake = FakeApi()
        ..onJson('POST', '/auth/login', authJson())
        ..on('POST', '/auth/logout', (_) => empty(204));
      final h = await pumpAdmin(
        tester,
        fake: fake,
        signedIn: false,
        locale: 'en',
      );
      await submitLogin(tester);
      fake.on('GET', '/admin/applications', (_) => apiError(403, 'FORBIDDEN'));
      h.router.go(Routes.applications);
      await tester.pumpAndSettle();
      expect(h.location, '/login');
      expect(find.textContaining('no longer valid'), findsOneWidget);
    });

    testWidgets('askıdaki hesabın girişi açık mesajla reddedilir', (
      tester,
    ) async {
      final fake = FakeApi()
        ..on('POST', '/auth/login', (_) => apiError(401, 'ACCOUNT_SUSPENDED'));
      final h = await pumpAdmin(tester, fake: fake, signedIn: false);
      await submitLogin(tester);
      expect(h.location, '/login');
      expect(find.textContaining('askıya alındı'), findsOneWidget);
      expect(await h.store.read(), isNull);
      expect(fake.count('GET', '/admin/stats'), 0);
    });

    testWidgets('sunucu adresi varsayılanı localhost:8090', (tester) async {
      expect(kApiBaseUrl, 'http://localhost:8090');
    });
  });
}
