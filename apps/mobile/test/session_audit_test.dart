// Denetimde bulunan oturum, yönlendirme ve test altyapısı sorunları.
import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/app/guards.dart';
import 'package:bitadilat_mobile/core/providers.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _tokens = TokenPair(accessToken: 'A', refreshToken: 'R');
const _suspendedTr = 'Hesabın askıya alındı. Destek ekibiyle iletişime geç.';

void main() {
  group('açılış (bootstrap)', () {
    testWidgets('429 geçicidir: token silinmez, tekrar dene çıkar', (t) async {
      var limited = true;
      final h = await pumpApp(
        t,
        tokens: _tokens,
        handler: (o) {
          if (o.path.endsWith('/me')) {
            return limited
                ? apiError(429, 'TOO_MANY_ATTEMPTS')
                : json(200, meJson());
          }
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(find.text('Oturumun açılamadı'), findsOneWidget);
      expect(await h.store.read(), isNotNull);
      limited = false;
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
    });

    testWidgets('sözleşmeye uymayan /me açılışta takılı kalmaz', (t) async {
      final h = await pumpApp(
        t,
        tokens: _tokens,
        handler: (o) {
          if (o.path.endsWith('/me')) {
            return json(200, {...meJson(), 'lastMode': 'ADMIN'});
          }
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(find.text('Oturumun açılamadı'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
      expect(await h.store.read(), isNotNull);
    });

    testWidgets('401 ACCOUNT_SUSPENDED: oturum kapanır, açıklamalı karşılama', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        tokens: _tokens,
        handler: (o) {
          if (o.path.endsWith('/me')) {
            return apiError(401, 'ACCOUNT_SUSPENDED');
          }
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(h.uri.path, '/welcome');
      expect(find.text(_suspendedTr), findsOneWidget);
      expect(await h.store.read(), isNull);
    });

    testWidgets('refresh ACCOUNT_SUSPENDED dönerse de açıklama görünür', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        tokens: _tokens,
        handler: (o) {
          if (o.path.endsWith('/auth/refresh')) {
            return apiError(401, 'ACCOUNT_SUSPENDED');
          }
          if (o.path.endsWith('/me')) return apiError(401, 'TOKEN_EXPIRED');
          return apiError(404, 'NOT_FOUND');
        },
      );
      expect(h.uri.path, '/welcome');
      expect(find.text(_suspendedTr), findsOneWidget);
      expect(await h.store.read(), isNull);
    });
  });

  testWidgets('oturum açıkken 401 ACCOUNT_SUSPENDED -> karşılama ve açıklama, '
      'next taşınmaz', (t) async {
    var meCalls = 0;
    final h = await pumpApp(
      t,
      tokens: _tokens,
      handler: (o) {
        if (o.path.endsWith('/me')) {
          meCalls++;
          return meCalls == 1
              ? json(200, meJson())
              : apiError(401, 'ACCOUNT_SUSPENDED');
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
    expect(find.text(_suspendedTr), findsOneWidget);
    expect(await h.store.read(), isNull);
  });

  group('next güvenliği', () {
    test('açılış next\'i iç giriş rotası olmalı; //host/login reddedilir', () {
      const out = SessionState.signedOut();
      expect(
        guardRedirect(out, Uri.parse('/?next=%2F%2Fevil.example%2Flogin')),
        '/welcome',
      );
      expect(
        guardRedirect(
          out,
          Uri.parse('/?next=https%3A%2F%2Fevil.example%2Flogin'),
        ),
        '/welcome',
      );
      expect(
        guardRedirect(
          out,
          Uri.parse('/?next=%2Flogin%3Fnext%3D%252Fc%252Fhome'),
        ),
        '/login?next=%2Fc%2Fhome',
      );
    });

    test(
      'safeNext kodlanmış çift eğik çizgi ve bilinmeyen kökleri reddeder',
      () {
        expect(safeNext('/%2F%2Fevil.example'), isNull);
        expect(safeNext('/admin/users'), isNull);
        expect(safeNext('http:/c/home'), isNull);
      },
    );
  });

  group('taşma testlerinin geçerliliği', () {
    testWidgets('harness 2x yazı ölçeğini gerçekten uygular', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/welcome',
        size: const Size(320, 640),
        textScale: 2,
      );
      final context = t.element(find.text('Giriş yap').first);
      expect(MediaQuery.textScalerOf(context).scale(10), 20);
      expect(MediaQuery.sizeOf(context).width, 320);
    });

    testWidgets('aynı yöntem gerçek bir taşmayı yakalar', (t) async {
      t.view.physicalSize = const Size(320, 640);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        const MaterialApp(
          home: Row(children: [SizedBox(width: 400, height: 10)]),
        ),
      );
      expect(t.takeException(), isNotNull);
    });
  });
}
