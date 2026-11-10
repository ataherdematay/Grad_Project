// Dalga 3 ek görevleri: iOS E2E'de bulunan düzeltmelerin regresyon testleri.
import 'dart:io';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/draft_photos.dart';
import 'package:bitadilat_mobile/core/providers.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/customer/wizard_state.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

void main() {
  group('Taslak açıklama sayacı', draftCounterTests);

  group('Admin girişi ve Me.phone', () {
    test('phone null olabilir', () {
      final me = Me.fromJson({...meJson(isAdmin: true), 'phone': null});
      expect(me.phone, isNull);
      expect(me.isAdmin, isTrue);
    });

    testWidgets('admin yanıtında phone null: doğru ret mesajı', (t) async {
      final h = await pumpApp(
        t,
        initial: '/login',
        handler: (o) {
          if (o.path.endsWith('/auth/login')) {
            final a = authJson(isAdmin: true);
            (a['user'] as Map<String, dynamic>)['phone'] = null;
            return json(200, a);
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
      expect(find.text('Bir sorun oluştu'), findsNothing);
      expect(h.location, '/login');
    });
  });

  group('Çok satırlı alanlar', () {
    testWidgets('AppTextField minLines/maxLines', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                AppTextField(label: 'tek'),
                AppTextField(label: 'çok', minLines: 3),
              ],
            ),
          ),
        ),
      );
      final fields = t.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields[0].maxLines, 1);
      expect(fields[1].minLines, 3);
      expect(fields[1].maxLines, greaterThan(3));
    });

    testWidgets('şikayet açıklaması ve usta notu çok satırlı', (t) async {
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/jobs/j1/complaint',
        size: tall,
        handler: server3({
          'GET /jobs/j1': (_) => json(
            200,
            jobDetailJson(status: 'IN_PROGRESS', actions: ['COMPLAIN']),
          ),
        }),
      );
      final f = t.widget<TextField>(find.byType(TextField));
      expect(f.minLines, 3);
      expect(f.maxLines, greaterThan(1));
    });
  });

  group('iOS geri kaydırma', () {
    test('tema iOS için Cupertino geçişi kullanır', () {
      final b = AppTheme.light().pageTransitionsTheme.builders;
      expect(b[TargetPlatform.iOS], isA<CupertinoPageTransitionsBuilder>());
    });

    Future<void> edgeSwipe(WidgetTester t) async {
      await t.dragFrom(const Offset(2, 300), const Offset(300, 0));
      await t.pumpAndSettle();
    }

    testWidgets('itilen ekrandan kenar kaydırmasıyla geri dönülür', (t) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final h = await pumpApp(
          t,
          session: customerSession(),
          initial: '/c/home',
          handler: server3({
            'GET /requests': (_) =>
                json(200, {'items': <Object>[], 'nextCursor': null}),
            'GET /jobs': (_) => json(200, {
              'items': [jobSummaryJson()],
            }),
            'GET /jobs/j1': (_) => json(200, jobDetailJson()),
          }),
        );
        await t.tap(find.text('Mutfak musluğu damlıyor'));
        await t.pumpAndSettle();
        expect(h.location, '/c/jobs/j1');
        await edgeSwipe(t);
        expect(h.location, '/c/home');
        // Sekme kökünde kaydırma hiçbir şey açmaz.
        await edgeSwipe(t);
        expect(h.location, '/c/home');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('yığını değişmiş sonuç ekranında kaydırma geri açmaz', (
      t,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final h = await pumpApp(
          t,
          session: customerSession(),
          initial: '/c/payments/ESC-1/result',
          handler: server3({
            'GET /payments/ESC-1': (_) => json(
              200,
              paymentJson(
                status: 'FAILED',
                jobId: null,
                errorCode: 'PAYMENT_DECLINED',
              ),
            ),
          }),
        );
        await edgeSwipe(t);
        expect(h.location, '/c/payments/ESC-1/result');
        // Ödeme sonrası iş: yığında ödeme ekranları yok.
        expect(h.router.canPop(), isFalse);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  group('Karşılaştırmada 3 teklif', () {
    testWidgets('320 px ve 2x yazıda üç teklif de görünür', (t) async {
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/requests/r1/compare?ids=o1,o2,o3',
        size: const Size(320, 640),
        textScale: 2,
        handler: server3({
          'GET /requests/r1/offers': (_) => json(200, {
            'items': [
              offerSummaryJson(id: 'o1', pro: 'Mavi Hat'),
              offerSummaryJson(id: 'o2', pro: 'Kırmızı Su'),
              offerSummaryJson(id: 'o3', pro: 'Yeşil Boru'),
            ],
            'declinedCount': 0,
          }),
        }),
      );
      expect(t.takeException(), isNull);
      for (final n in ['Mavi Hat', 'Kırmızı Su', 'Yeşil Boru']) {
        expect(find.text(n), findsWidgets);
      }
      // Yatay kaydırma gerekmez.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
      );
    });
  });

  group('Ana sayfa en fazla 3 kart', () {
    testWidgets('5 iş ve 4 talep: 3er kart ve Tümünü gör', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/home',
        size: const Size(390, 3000),
        handler: server3({
          'GET /requests': (_) => json(200, {
            'items': [
              for (var i = 1; i <= 4; i++)
                {
                  ...requestSummaryJson(id: 'r$i'),
                  'title': 'Talep $i',
                  'createdAt': '2026-11-0${i}T08:00:00Z',
                },
            ],
            'nextCursor': null,
          }),
          'GET /jobs': (_) => json(200, {
            'items': [
              for (var i = 1; i <= 5; i++)
                {
                  ...jobSummaryJson(id: 'j$i'),
                  'title': 'İş $i',
                  'updatedAt': '2026-11-0${i}T08:00:00Z',
                },
            ],
          }),
        }),
      );
      expect(find.text('Aktif işlerin'), findsOneWidget);
      expect(find.text('Açık taleplerin'), findsOneWidget);
      // En yeni üçü: 5, 4, 3 ve 4, 3, 2.
      for (final n in [
        'İş 5',
        'İş 4',
        'İş 3',
        'Talep 4',
        'Talep 3',
        'Talep 2',
      ]) {
        expect(find.text(n), findsOneWidget, reason: n);
      }
      expect(find.text('İş 2'), findsNothing);
      expect(find.text('Talep 1'), findsNothing);
      expect(find.text('Tümünü gör'), findsNWidgets(2));
      await t.tap(find.text('Tümünü gör').first);
      await t.pumpAndSettle();
      expect(h.location, '/c/requests');
    });

    testWidgets('3 ya da daha azsa Tümünü gör yok', (t) async {
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/home',
        handler: server3({
          'GET /requests': (_) => json(200, {
            'items': [requestSummaryJson()],
            'nextCursor': null,
          }),
          'GET /jobs': (_) => json(200, {
            'items': [jobSummaryJson()],
          }),
        }),
      );
      expect(find.text('Tümünü gör'), findsNothing);
    });
  });

  group('lastMode kararı', () {
    testWidgets('lastMode PRO + onaysız usta: giriş /p/application açar', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(
          testMe(proStatus: 'PENDING_REVIEW', lastMode: UserMode.pro),
        ),
        initial: '/',
        handler: server3({
          'GET /pro/application': (_) =>
              json(200, applicationJson(status: 'PENDING_REVIEW')),
        }),
      );
      expect(h.location, '/p/application');
    });

    testWidgets('lastMode PRO + onaylı usta: usta akışı', (t) async {
      final h = await pumpApp(
        t,
        session: proSession3(),
        initial: '/',
        handler: server3({
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
        }),
      );
      expect(h.location, '/p/feed');
    });

    ProviderContainer sessionContainer(Handler h) {
      SharedPreferences.setMockInitialValues({});
      final adapter = FakeAdapter(h);
      final store = MemoryTokenStore(null);
      final client = ApiClient(
        config: const ApiConfig('http://localhost:8090'),
        tokenStore: store,
        adapter: adapter,
      );
      final c = ProviderContainer(
        overrides: [
          tokenStoreProvider.overrideWithValue(store),
          apiClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    const wantsProReq = RegisterRequest(
      fullName: 'Ayşe Yılmaz',
      email: 'ayse@example.com',
      phone: '+905321112233',
      password: 'abcd1234',
      wantsPro: true,
      kvkkAccepted: true,
      termsAccepted: true,
    );

    test(
      'wantsPro ile kayıt: başvurudan sonra lastMode PRO kaydedilir',
      () async {
        Map<String, dynamic>? patch;
        final c = sessionContainer((o) {
          final path = o.path.replaceFirst('/api/v1', '');
          if (path == '/auth/register') return json(201, authJson());
          if (path == '/me' && o.method == 'GET') return json(200, meJson());
          if (path == '/me') {
            patch = o.data as Map<String, dynamic>;
            return json(200, meJson(lastMode: 'PRO'));
          }
          return apiError(404, 'NOT_FOUND');
        });
        final n = c.read(sessionProvider.notifier);
        await n.register(wantsProReq);
        await n.afterApplicationSubmitted();
        expect(patch, {'lastMode': 'PRO'});
        expect(c.read(sessionProvider).me!.lastMode, UserMode.pro);
      },
    );

    test('wantsPro olmadan kayıt: mod değişmez', () async {
      var patched = false;
      final c = sessionContainer((o) {
        final path = o.path.replaceFirst('/api/v1', '');
        if (path == '/auth/register') return json(201, authJson());
        if (path == '/me' && o.method == 'GET') return json(200, meJson());
        patched = true;
        return json(200, meJson(lastMode: 'PRO'));
      });
      final n = c.read(sessionProvider.notifier);
      await n.register(wantsProReq.copyWith(wantsPro: false));
      await n.afterApplicationSubmitted();
      expect(patched, isFalse);
    });
  });

  group('Taslak fotoğrafları', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('draft_photos'));
    tearDown(() => dir.deleteSync(recursive: true));

    ProviderContainer make(
      SharedPreferences prefs,
      FileDraftPhotoStore store,
    ) => ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        draftPhotoStoreProvider.overrideWithValue(store),
        sessionProvider.overrideWith(
          () => FakeSession(SessionState.signedIn(testMe())),
        ),
      ],
    );

    test('yüklenen fotoğraf kapat-aç sonrası geri gelir', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = FileDraftPhotoStore(baseDir: dir);
      final a = make(prefs, store);
      final sub = a.listen(wizardProvider, (_, _) {});
      final w = a.read(wizardProvider.notifier);
      w.update((d) => d.copyWith(title: 'Musluk'));
      w.photos.addRestored(
        bytes: Uint8List.fromList([1, 2, 3]),
        mediaId: 'up9',
        name: 'a.jpg',
        mime: 'image/jpeg',
        localPath: '',
      );
      // Yükleme biten fotoğraf (kopya henüz yok): dinleyici dosyayı yazar.
      final item = w.photos.items.single..localPath = null;
      w.photos.remove(item);
      w.photos.addRestored(
        bytes: Uint8List.fromList([1, 2, 3]),
        mediaId: 'up9',
        name: 'a.jpg',
        mime: 'image/jpeg',
        localPath: await store.save(
          'u-1',
          'up9',
          Uint8List.fromList([1, 2, 3]),
        ),
      );
      w.update((d) => d.copyWith(description: 'x' * 30));
      sub.close();
      a.dispose();

      final b = make(prefs, store);
      addTearDown(b.dispose);
      b.listen(wizardProvider, (_, _) {});
      final wb = b.read(wizardProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(wb.photos.mediaIds, ['up9']);
      expect(b.read(wizardProvider).draft.title, 'Musluk');
    });

    test('yerel dosya yoksa fotoğraf sessizce düşer', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = FileDraftPhotoStore(baseDir: dir);
      final path = await store.save('u-1', 'up9', Uint8List.fromList([1]));
      await prefs.setString(
        draftKeyFor('u-1'),
        '{"draft":{"title":"Musluk"},"step":2,"photos":[{"mediaId":"up9","path":"$path","name":"a.jpg","mime":"image/jpeg"},{"mediaId":"up8","path":"${dir.path}/yok.img","name":"b.jpg","mime":"image/jpeg"}]}',
      );
      final c = make(prefs, store);
      addTearDown(c.dispose);
      c.listen(wizardProvider, (_, _) {});
      final w = c.read(wizardProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(w.photos.mediaIds, ['up9']);
      // Kayıttan da çıkar.
      expect(prefs.getString(draftKeyFor('u-1')), isNot(contains('up8')));
    });

    test('yayından sonra dosyalar silinir', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = FileDraftPhotoStore(baseDir: dir);
      final path = await store.save('u-1', 'up9', Uint8List.fromList([1]));
      await prefs.setString(
        draftKeyFor('u-1'),
        '{"draft":{"title":"Musluk"},"step":2,"photos":[{"mediaId":"up9","path":"$path","name":"a.jpg","mime":"image/jpeg"}]}',
      );
      final c = make(prefs, store);
      addTearDown(c.dispose);
      c.listen(wizardProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 100));
      c.read(wizardProvider.notifier).finish();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(File(path).existsSync(), isFalse);
      expect(prefs.getString(draftKeyFor('u-1')), isNull);
    });
  });
}

void draftCounterTests() {
  testWidgets('geri yüklenen taslakta açıklama sayacı doğru sayıyı gösterir', (
    t,
  ) async {
    final h = await pumpApp(
      t,
      session: SessionState.signedIn(testMe()),
      initial: '/settings',
      handler: routes(baseRoutes()),
      size: const Size(390, 1400),
    );
    await h.container
        .read(sharedPreferencesProvider)
        .setString(
          draftKeyFor('u-1'),
          '{"draft":{"title":"Musluk damlıyor","description":"${'x' * 30}"},"step":3}',
        );
    h.router.push('/c/requests/new');
    await t.pumpAndSettle();
    expect(find.text('Musluk damlıyor'), findsOneWidget);
    // Sayaç ilk çizimde geri yüklenen metni sayar (E2E O3: "0 / en az 20").
    expect(find.text('30 / en az 20 karakter'), findsOneWidget);
    expect(find.text('0 / en az 20 karakter'), findsNothing);
  });
}
