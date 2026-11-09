import 'dart:async';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/data.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/core/photos.dart';
import 'package:bitadilat_mobile/core/providers.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/customer/wizard_screen.dart';
import 'package:bitadilat_mobile/features/customer/wizard_state.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';

final customer = SessionState.signedIn(testMe());
const tall = Size(390, 1400);

Finder btn(String label) => find.widgetWithText(AppButton, label);

Handler wizardServer({void Function(RequestOptions)? onCreate}) => routes({
  ...baseRoutes(),
  'POST /requests': (o) {
    onCreate?.call(o);
    return json(201, requestDetailJson(id: 'r9'));
  },
  'GET /requests/r9': (_) => json(200, requestDetailJson(id: 'r9')),
  'GET /requests': (_) => json(200, {
    'items': [requestSummaryJson(id: 'r9')],
    'nextCursor': null,
  }),
});

void main() {
  final now = DateTime(2026, 11, 10, 9);

  group('Sihirbaz doğrulamaları', () {
    List<WizardIssue> v(
      RequestDraft d,
      int step, {
      List<String> keys = const [],
    }) => validateStep(d, step, now: now, requiredQuestionKeys: keys);

    test('adım 1: kategori ve planlı tarih aralığı', () {
      expect(v(const RequestDraft(), 1), [WizardIssue.category]);
      const ok = RequestDraft(categoryId: 'plumbing');
      expect(v(ok, 1), isEmpty);
      final planned = ok.copyWith(urgency: RequestUrgency.planned);
      expect(
        v(planned, 1),
        containsAll([WizardIssue.dateFrom, WizardIssue.dateTo]),
      );
      expect(
        v(
          planned.copyWith(
            preferredFrom: now.add(const Duration(days: 2)),
            preferredTo: now.add(const Duration(days: 1)),
          ),
          1,
        ),
        [WizardIssue.dateOrder],
      );
      expect(
        v(
          planned.copyWith(
            preferredFrom: now.subtract(const Duration(hours: 1)),
            preferredTo: now.add(const Duration(days: 1)),
          ),
          1,
        ),
        [WizardIssue.datePast],
      );
      expect(
        v(
          planned.copyWith(
            preferredFrom: now.add(const Duration(days: 1)),
            preferredTo: now.add(const Duration(days: 31)),
          ),
          1,
        ),
        [WizardIssue.dateRange],
      );
      expect(
        v(
          planned.copyWith(
            preferredFrom: now.add(const Duration(days: 1)),
            preferredTo: now.add(const Duration(days: 2)),
          ),
          1,
        ),
        isEmpty,
      );
    });

    test('adım 2: adres ve kategori soruları', () {
      const d = RequestDraft(categoryId: 'plumbing');
      expect(v(d, 2, keys: ['since']), [
        WizardIssue.address,
        WizardIssue.answers,
      ]);
      expect(
        v(
          d.copyWith(addressId: '7', answers: {'since': 'today'}),
          2,
          keys: ['since'],
        ),
        isEmpty,
      );
    });

    test('adım 3: başlık 5-150, açıklama en az 20, fotoğraflar', () {
      expect(v(const RequestDraft(), 3), [
        WizardIssue.title,
        WizardIssue.description,
      ]);
      final d = RequestDraft(title: 'Musluk', description: 'x' * 19);
      expect(v(d, 3), [WizardIssue.description]);
      expect(v(d.copyWith(description: 'x' * 20), 3), isEmpty);
      expect(v(d.copyWith(title: 'abcd', description: 'x' * 20), 3), [
        WizardIssue.title,
      ]);
      expect(
        validateStep(
          d.copyWith(description: 'x' * 20),
          3,
          now: now,
          photosBusy: true,
        ),
        [WizardIssue.photosBusy],
      );
    });
  });

  group('Taslak kalıcılığı', () {
    test('uygulama kapanıp açılınca taslak geri gelir', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ProviderContainer make() => ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      final c1 = make();
      final ctrl = c1.read(wizardProvider.notifier);
      ctrl.update(
        (d) => d.copyWith(
          categoryId: 'plumbing',
          addressId: '7',
          title: 'Musluk damlıyor',
          answers: {'since': 'today'},
        ),
      );
      ctrl.goTo(3);
      c1.dispose();

      final c2 = make();
      addTearDown(c2.dispose);
      final s = c2.read(wizardProvider);
      expect(s.step, 3);
      expect(s.draft.categoryId, 'plumbing');
      expect(s.draft.addressId, '7');
      expect(s.draft.title, 'Musluk damlıyor');
      expect(s.draft.answers, {'since': 'today'});
    });

    test('bozuk taslak sessizce boş taslağa döner', () async {
      SharedPreferences.setMockInitialValues({kDraftKey: '{bozuk'});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c.dispose);
      expect(c.read(wizardProvider).draft.isEmpty, isTrue);
    });
  });

  group('Fotoğraf seçimi', () {
    PhotoSet makeSet(
      FakeAdapter adapter,
      FakePicker picker, {
      Recompress? recompress,
    }) {
      final client = ApiClient(
        config: const ApiConfig('http://x'),
        tokenStore: MemoryTokenStore(null),
        adapter: adapter,
      );
      return PhotoSet(
        api: client.media,
        picker: picker,
        recompress: recompress ?? (b, q, w) async => null,
      );
    }

    test('en fazla 5 fotoğraf eklenir', () async {
      final adapter = FakeAdapter((o) => uploadOk(o));
      final set = makeSet(adapter, FakePicker([1000]));
      for (var i = 0; i < 7; i++) {
        await set.add(PhotoSource.gallery);
      }
      expect(set.items, hasLength(kMaxRequestPhotos));
      expect(set.isFull, isTrue);
      expect(adapter.requests, hasLength(5));
      expect(set.mediaIds, hasLength(5));
    });

    test(
      '1,5 MB üstü bir kez daha sıkıştırılır; yine büyükse reddedilir',
      () async {
        final adapter = FakeAdapter((o) => uploadOk(o));
        var recompressCalls = 0;
        final set = makeSet(
          adapter,
          FakePicker([kMaxPhotoBytes + 1]),
          recompress: (b, q, w) async {
            recompressCalls++;
            return Uint8List(kMaxPhotoBytes + 10);
          },
        );
        await set.add(PhotoSource.gallery);
        expect(recompressCalls, 1);
        expect(adapter.requests, isEmpty);
        expect(set.items.single.status, PhotoStatus.failed);
        expect(set.items.single.failure, PhotoFailure.tooLarge);
        expect(set.mediaIds, isEmpty);
        set.remove(set.items.single);
        expect(set.items, isEmpty);
      },
    );

    test('sıkıştırma küçültürse küçük dosya yüklenir', () async {
      final adapter = FakeAdapter((o) => uploadOk(o));
      final set = makeSet(
        adapter,
        FakePicker([kMaxPhotoBytes + 1]),
        recompress: (b, q, w) async => Uint8List(1000),
      );
      await set.add(PhotoSource.gallery);
      expect(set.items.single.status, PhotoStatus.done);
      expect(adapter.requests, hasLength(1));
      final form = adapter.requests.single.data as dynamic;
      expect(form.files.single.value.length, 1000);
    });

    test('yükleme hatası tek tek yeniden denenir ve kaldırılır', () async {
      var fail = true;
      final adapter = FakeAdapter(
        (o) => fail ? apiError(500, 'INTERNAL_ERROR') : uploadOk(o),
      );
      final set = makeSet(adapter, FakePicker([500]));
      await set.add(PhotoSource.gallery);
      expect(set.items.single.failure, PhotoFailure.upload);
      fail = false;
      await set.retry(set.items.single);
      expect(set.items.single.status, PhotoStatus.done);
    });

    testWidgets('1,5 MB reddi yerelleştirilmiş hata gösterir', (t) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        size: tall,
        handler: wizardServer(),
        overrides: [
          photoPickerProvider.overrideWithValue(
            FakePicker([kMaxPhotoBytes + 1]),
          ),
          recompressProvider.overrideWithValue((b, q, w) async => null),
        ],
      );
      h.container.read(wizardProvider.notifier).goTo(3);
      await t.pumpAndSettle();
      await t.tap(btn('Fotoğraf ekle'));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'Fotoğraf 1,5 MB sınırını aşıyor. Daha küçük bir fotoğraf seç.',
        ),
        findsOneWidget,
      );
      expect(h.adapter.count('POST', '/media'), 0);
      await t.tap(find.byTooltip('Fotoğrafı kaldır'));
      await t.pumpAndSettle();
      expect(find.textContaining('1,5 MB'), findsNothing);
    });
  });

  group('Sihirbaz akışı', () {
    Future<void> fillToReview(WidgetTester t) async {
      await t.tap(find.text('Tesisat'));
      await t.pumpAndSettle();
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      await t.tap(find.text('Ev'));
      await t.tap(find.text('Birkaç gün'));
      await t.pumpAndSettle();
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField).at(0), 'Mutfak musluğu');
      await t.enterText(
        find.byType(TextFormField).at(1),
        'Musluk iki gündür sürekli damlatıyor.',
      );
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
    }

    testWidgets('doğrulama geçmeden ilerlenmez, geri tuşu önceki adıma gider', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        size: tall,
        handler: wizardServer(),
      );
      expect(find.text('Adım 1 / 4'), findsOneWidget);
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      expect(find.text('Devam etmek için bir kategori seç.'), findsOneWidget);
      expect(find.text('Adım 1 / 4'), findsOneWidget);

      await t.tap(find.text('Tesisat'));
      await t.pumpAndSettle();
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      expect(find.text('Adım 2 / 4'), findsOneWidget);
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      expect(find.text('Bir adres seç ya da yeni adres ekle.'), findsOneWidget);
      expect(find.text('Tüm soruları cevapla.'), findsOneWidget);
      expect(find.text('Adım 2 / 4'), findsOneWidget);

      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Adım 1 / 4'), findsOneWidget);
      expect(h.location, '/c/requests/new');
    });

    testWidgets(
      'inceleme: Düzenle ilgili adıma gider, oradan Gözden geçir döner',
      (t) async {
        await pumpApp(
          t,
          session: customer,
          initial: '/c/requests/new',
          size: tall,
          handler: wizardServer(),
        );
        await fillToReview(t);
        expect(find.text('Adım 4 / 4'), findsOneWidget);
        expect(
          find.text('Musluk iki gündür sürekli damlatıyor.'),
          findsOneWidget,
        );
        await t.tap(find.text('Düzenle').first);
        await t.pumpAndSettle();
        expect(find.text('Adım 1 / 4'), findsOneWidget);
        expect(btn('Gözden geçir'), findsOneWidget);
        await t.tap(btn('Gözden geçir'));
        await t.pumpAndSettle();
        expect(find.text('Adım 4 / 4'), findsOneWidget);
      },
    );

    testWidgets('yayından sonra geri tuşu forma dönmez; taslak silinir', (
      t,
    ) async {
      Map<String, dynamic>? body;
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        size: tall,
        handler: wizardServer(
          onCreate: (o) => body = o.data as Map<String, dynamic>,
        ),
      );
      await fillToReview(t);
      await t.tap(btn('Talebi yayınla'));
      await t.pumpAndSettle();

      expect(h.location, '/c/requests/r9/published');
      expect(find.text('3 usta eşleşti'), findsOneWidget);
      expect(find.text('Kategoriye uygun'), findsOneWidget);
      expect(body!['categoryId'], 'plumbing');
      expect(body!['addressId'], 7);
      expect(body!['urgency'], 'URGENT');
      expect(body!['preferredFrom'], isNull);
      expect(body!['answers'], [
        {'questionKey': 'since', 'answer': 'days'},
      ]);
      expect(
        h.adapter.requests
            .firstWhere((r) => r.method == 'POST')
            .headers['Idempotency-Key'],
        isNotNull,
      );

      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/c/requests');
      expect(find.byType(RequestWizardScreen), findsNothing);
      expect(find.text('Adım 4 / 4'), findsNothing);
      expect(
        h.container.read(sharedPreferencesProvider).getString(kDraftKey),
        isNull,
      );
    });

    testWidgets('çift dokunuşta tek istek gider', (t) async {
      final gate = Completer<void>();
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'POST /requests': (o) async {
            await gate.future;
            return json(201, requestDetailJson(id: 'r9'));
          },
          'GET /requests/r9': (_) => json(200, requestDetailJson(id: 'r9')),
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      await fillToReview(t);
      await t.tap(btn('Talebi yayınla'));
      await t.pump();
      await t.tap(find.byType(FilledButton).last, warnIfMissed: false);
      await t.pump();
      gate.complete();
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/requests'), 1);
    });

    testWidgets('eşleşme 0 ise "Açık tut" ve "Düzenle" seçenekleri çıkar', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r9/published',
        handler: routes({
          ...baseRoutes(),
          'GET /requests/r9': (_) =>
              json(200, requestDetailJson(id: 'r9', matched: 0)),
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      expect(find.text('Şu an eşleşen usta yok'), findsOneWidget);
      expect(btn('Açık tut'), findsOneWidget);
      expect(btn('Düzenle'), findsOneWidget);
      await t.tap(btn('Açık tut'));
      await t.pumpAndSettle();
      expect(h.location, '/c/requests');
    });

    testWidgets('talep düzenleme sihirbazı dolu açılır ve PATCH eder', (
      t,
    ) async {
      Map<String, dynamic>? patch;
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/edit',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /requests/r1': (_) => json(200, requestDetailJson()),
          'PATCH /requests/r1': (o) {
            patch = o.data as Map<String, dynamic>;
            return json(200, requestDetailJson());
          },
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      expect(find.text('Talebi düzenle'), findsOneWidget);
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      expect(find.text('Adım 3 / 4'), findsOneWidget);
      await t.tap(btn('Devam'));
      await t.pumpAndSettle();
      await t.tap(btn('Değişiklikleri kaydet'));
      await t.pumpAndSettle();
      expect(patch!['title'], 'Mutfak musluğu damlıyor');
      expect(patch!['photoIds'], ['m1']);
      expect(h.adapter.count('POST', '/requests'), 0);
    });
  });

  group('Teklif listesi', () {
    Handler offersServer({List<Map<String, dynamic>>? items}) => routes({
      ...baseRoutes(),
      'GET /requests/r1': (_) => json(200, requestDetailJson()),
      'GET /requests/r1/offers': (_) => json(200, {
        'items':
            items ??
            [
              offerSummaryJson(id: 'o1', pro: 'Mavi Hat'),
              offerSummaryJson(id: 'o2', pro: 'Kırmızı Su', total: 2100),
            ],
        'declinedCount': 1,
      }),
      'GET /offers/o1': (_) => json(200, offerDetailJson()),
      'GET /pros/po1': (_) => json(200, proPublicJson()),
      'GET /pros/po1/reviews': (_) => json(200, {'items': <Object>[]}),
    });

    testWidgets('sıralama ve filtre sorguya yansır, sonuç sayısı görünür', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/offers',
        size: tall,
        handler: offersServer(),
      );
      expect(find.text('2 teklif'), findsOneWidget);
      expect(h.adapter.last('/requests/r1/offers').queryParameters, {
        'sort': 'recommended',
      });
      await t.tap(find.byTooltip('Filtrele ve sırala'));
      await t.pumpAndSettle();
      await t.tap(find.text('En düşük fiyat'));
      await t.enterText(find.byType(TextFormField).last, '2500');
      await t.tap(find.text('4.5+'));
      await t.pumpAndSettle();
      await t.tap(btn('Sonuçları uygula'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/requests/r1/offers').queryParameters, {
        'sort': 'price',
        'maxPrice': '2500',
        'minRating': 4.5,
      });
    });

    testWidgets('filtreye uyan teklif yoksa boş durum ve temizle düğmesi', (
      t,
    ) async {
      await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/offers',
        size: tall,
        handler: offersServer(items: const []),
      );
      expect(find.text('Henüz teklif yok'), findsOneWidget);
    });

    testWidgets('karşılaştırma: 2-3 teklif seçilir, 4. seçilmez', (t) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/offers',
        size: tall,
        handler: offersServer(
          items: [
            offerSummaryJson(id: 'o1', pro: 'Mavi Hat'),
            offerSummaryJson(id: 'o2', pro: 'Kırmızı Su', total: 2100),
            offerSummaryJson(id: 'o3', pro: 'Yeşil Boru', total: 2300),
            offerSummaryJson(id: 'o4', pro: 'Sarı Vana', total: 2600),
          ],
        ),
      );
      await t.tap(btn('Karşılaştır'));
      await t.pumpAndSettle();
      final go = find.widgetWithText(AppButton, 'Karşılaştır (0)');
      expect(go, findsOneWidget);
      await t.tap(find.text('Mavi Hat'));
      await t.pumpAndSettle();
      // 1 teklifle karşılaştırma açılamaz.
      await t.tap(find.widgetWithText(AppButton, 'Karşılaştır (1)'));
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1/offers');
      await t.tap(find.text('Kırmızı Su'));
      await t.tap(find.text('Yeşil Boru'));
      await t.tap(find.text('Sarı Vana'));
      await t.pumpAndSettle();
      expect(find.widgetWithText(AppButton, 'Karşılaştır (3)'), findsOneWidget);
      await t.tap(find.widgetWithText(AppButton, 'Karşılaştır (3)'));
      await t.pumpAndSettle();
      expect(h.uri.path, '/c/requests/r1/compare');
      expect(h.uri.queryParameters['ids'], 'o1,o2,o3');
      expect(find.text('Karşılaştırma'), findsOneWidget);
      expect(find.text('Mavi Hat'), findsOneWidget);
      expect(find.text('Yeşil Boru'), findsOneWidget);
      expect(find.text('Sarı Vana'), findsNothing);
      expect(find.text('Toplam (KDV dahil)'), findsOneWidget);
    });
  });

  group('Teklif detayı ve reddetme', () {
    Handler offerServer({
      FutureOr<ResponseBody> Function(RequestOptions)? decline,
    }) => routes({
      ...baseRoutes(),
      'GET /offers/o1': (_) => json(200, offerDetailJson()),
      'POST /offers/o1/decline':
          decline ?? (_) => json(200, offerDetailJson(status: 'DECLINED')),
      'GET /requests/r1/offers': (_) => json(200, {
        'items': [offerSummaryJson()],
        'declinedCount': 0,
      }),
      'GET /requests/r1': (_) => json(200, requestDetailJson()),
      'GET /requests': (_) =>
          json(200, {'items': <Object>[], 'nextCursor': null}),
      'GET /pros/po1': (_) => json(200, proPublicJson()),
    });

    test('ödeme bayrağı bu dalgada kapalı', () {
      expect(kPaymentsEnabled, isFalse);
    });

    testWidgets('kPaymentsEnabled=false iken kabul düğmesi yok, soru sor yok', (
      t,
    ) async {
      await pumpApp(
        t,
        session: customer,
        initial: '/c/offers/o1',
        size: tall,
        handler: offerServer(),
      );
      expect(find.text('Toplam tutar (KDV dahil)'), findsOneWidget);
      expect(find.text('₺2.450'), findsOneWidget);
      expect(find.text('Küresel vana × 2'), findsOneWidget);
      expect(find.text('Teklifi kabul et'), findsNothing);
      expect(find.textContaining('soru'), findsNothing);
      expect(btn('Teklifi reddet'), findsOneWidget);
      expect(btn('Profili görüntüle'), findsOneWidget);
      await t.tap(btn('Profili görüntüle'));
      await t.pumpAndSettle();
      expect(find.text('Usta profili'), findsOneWidget);
      expect(find.text('Kimlik'), findsOneWidget);
    });

    testWidgets('reddetme: gerekçe zorunlu, onay diyaloğu, gövde doğru', (
      t,
    ) async {
      Map<String, dynamic>? body;
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/offers/o1',
        size: tall,
        handler: offerServer(
          decline: (o) {
            body = o.data as Map<String, dynamic>;
            return json(200, offerDetailJson(status: 'DECLINED'));
          },
        ),
      );
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      expect(h.location, '/c/offers/o1/decline');

      // Gerekçe yok: istek gitmez.
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      expect(find.text('Devam etmek için bir gerekçe seç.'), findsOneWidget);
      expect(h.adapter.count('POST', '/offers/o1/decline'), 0);

      // Talep kapanacaksa gerekçe uygun olmalı.
      await t.tap(find.text('Fiyat bütçeme uygun değil'));
      await t.tap(find.byType(Switch));
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      expect(find.textContaining('Talebi kapatmak için'), findsOneWidget);
      expect(h.adapter.count('POST', '/offers/o1/decline'), 0);
      await t.tap(find.byType(Switch));

      await t.enterText(find.byType(TextFormField), 'Çok pahalı');
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      expect(find.text('Teklif reddedilsin mi?'), findsOneWidget);
      // Vazgeç: istek gitmez.
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/offers/o1/decline'), 0);

      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Teklifi reddet').last);
      await t.pumpAndSettle();
      expect(body, {
        'reason': 'PRICE',
        'note': 'Çok pahalı',
        'keepRequestOpen': true,
      });
      expect(h.adapter.count('POST', '/offers/o1/decline'), 1);
      expect(h.location, isNot('/c/offers/o1/decline'));
    });

    testWidgets('ILLEGAL_STATE: ekran güncellendi mesajı ve yeniden yükleme', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/offers/o1/decline',
        size: tall,
        handler: offerServer(decline: (_) => apiError(409, 'ILLEGAL_STATE')),
      );
      await t.tap(find.text('Diğer'));
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      final before = h.adapter.count('GET', '/offers/o1');
      await t.tap(find.widgetWithText(FilledButton, 'Teklifi reddet').last);
      await t.pumpAndSettle();
      expect(
        find.text('Bu işlem artık yapılamıyor, ekran güncellendi.'),
        findsOneWidget,
      );
      expect(h.adapter.count('GET', '/offers/o1'), greaterThan(before));
    });
  });

  group('Talepler ve adresler', () {
    testWidgets('Aktif ve Geçmiş sekmeleri, boş durumlar, durum etiketleri', (
      t,
    ) async {
      await pumpApp(
        t,
        session: customer,
        initial: '/c/requests',
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (o) => json(200, {
            'items': o.queryParameters['scope'] == 'active'
                ? [
                    requestSummaryJson(),
                    requestSummaryJson(id: 'r2', offerCount: 0),
                  ]
                : <Object>[],
            'nextCursor': null,
          }),
        }),
      );
      expect(find.text('2 teklif geldi'), findsOneWidget);
      expect(find.text('Teklif bekleniyor'), findsOneWidget);
      expect(find.text('₺2.000 - ₺2.450'), findsOneWidget);
      await t.tap(find.text('Geçmiş'));
      await t.pumpAndSettle();
      expect(find.text('Geçmiş talebin yok'), findsOneWidget);
    });

    testWidgets('Ana sayfa en yeni açık talebi ve Talep oluştur gösterir', (
      t,
    ) async {
      await pumpApp(
        t,
        session: customer,
        initial: '/c/home',
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (_) => json(200, {
            'items': [requestSummaryJson()],
            'nextCursor': null,
          }),
        }),
      );
      expect(find.text('Mutfak musluğu damlıyor'), findsOneWidget);
      expect(btn('Talep oluştur'), findsOneWidget);
      expect(btn('Teklifleri gör (2)'), findsOneWidget);
    });

    testWidgets('talep iptali: gerekçe, onay diyaloğu, POST', (t) async {
      Map<String, dynamic>? body;
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/cancel',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'POST /requests/r1/cancel': (o) {
            body = o.data as Map<String, dynamic>;
            return json(200, requestDetailJson(status: 'CANCELLED'));
          },
          'GET /requests/r1': (_) => json(200, requestDetailJson()),
        }),
      );
      await t.tap(btn('Talebi iptal et'));
      await t.pumpAndSettle();
      expect(find.text('Devam etmek için bir gerekçe seç.'), findsOneWidget);
      await t.tap(find.text('Sorunu çözdüm'));
      await t.tap(btn('Talebi iptal et'));
      await t.pumpAndSettle();
      expect(find.text('Talep iptal edilsin mi?'), findsOneWidget);
      await t.tap(find.widgetWithText(FilledButton, 'Talebi iptal et').last);
      await t.pumpAndSettle();
      expect(body, {'reason': 'SOLVED'});
      expect(h.adapter.count('POST', '/requests/r1/cancel'), 1);
    });

    testWidgets('adresler: liste, varsayılan yap, sil (onaylı)', (t) async {
      var addrs = [addressJson('7', true), addressJson('8', false)];
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/addresses',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /me/addresses': (_) => json(200, addrs),
          'PATCH /me/addresses/8': (o) {
            expect((o.data as Map)['isDefault'], isTrue);
            addrs = [addressJson('7', false), addressJson('8', true)];
            return json(200, addrs[1]);
          },
          'DELETE /me/addresses/7': (_) {
            addrs = [addrs[1]];
            return empty(204);
          },
        }),
      );
      expect(find.text('Varsayılan'), findsOneWidget);
      await t.tap(find.widgetWithText(AppButton, 'Varsayılan yap'));
      await t.pumpAndSettle();
      expect(h.adapter.count('PATCH', '/me/addresses/8'), 1);
      await t.tap(find.widgetWithText(AppButton, 'Sil').first);
      await t.pumpAndSettle();
      expect(find.text('Adres silinsin mi?'), findsOneWidget);
      await t.tap(find.widgetWithText(FilledButton, 'Sil'));
      await t.pumpAndSettle();
      expect(h.adapter.count('DELETE', '/me/addresses/7'), 1);
    });

    testWidgets('değerlendirme yoksa boş durum', (t) async {
      await pumpApp(
        t,
        session: customer,
        initial: '/c/pros/p1/reviews',
        handler: routes({
          'GET /pros/p1/reviews': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      expect(find.text('Henüz değerlendirme yok'), findsOneWidget);
    });
  });

  group('Biçimler ve dil', () {
    testWidgets('para ve göreli tarih TR/EN', (t) async {
      await pumpApp(t, session: customer, initial: '/c/home');
      final tr = AppLocalizations.of(t.element(find.byType(Scaffold).first));
      expect(formatMoney(const Money.lira(2450), 'tr'), '₺2.450');
      expect(formatMoney(const Money.lira(2450), 'en'), '₺2,450');
      expect(formatMoney(const Money.cents(122550), 'tr'), '₺1.225,50');
      final base = DateTime(2026, 11, 10, 9);
      expect(formatDay(tr, DateTime(2026, 11, 10, 15).toUtc(), base), 'Bugün');
      expect(formatDay(tr, DateTime(2026, 11, 11, 15).toUtc(), base), 'Yarın');
      expect(
        formatWindow(
          tr,
          DateTime(2026, 11, 14, 14).toUtc(),
          DateTime(2026, 11, 14, 16).toUtc(),
          base,
        ),
        '14 Kasım Cumartesi, 14:00-16:00',
      );
    });

    testWidgets('TR ve EN geçişi yeni ekranlarda çalışır', (t) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/home',
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      expect(btn('Talep oluştur'), findsOneWidget);
      expect(find.text('Aktif talebin yok'), findsOneWidget);
      await h.container.read(localeProvider.notifier).set(const Locale('en'));
      await t.pumpAndSettle();
      expect(btn('Create request'), findsOneWidget);
      expect(find.text('No active request'), findsOneWidget);
      h.router.go('/c/requests');
      await t.pumpAndSettle();
      expect(find.text('My requests'), findsWidgets);
      expect(find.text('Past'), findsOneWidget);
    });
  });

  group('Taşma (320 px, 2x yazı) müşteri ekranları', () {
    final server = routes({
      ...baseRoutes(),
      'GET /requests': (_) => json(200, {
        'items': [
          requestSummaryJson(),
          requestSummaryJson(id: 'r2', offerCount: 0),
        ],
        'nextCursor': null,
      }),
      'GET /requests/r1': (_) => json(200, requestDetailJson()),
      'GET /requests/r1/offers': (_) => json(200, {
        'items': [
          offerSummaryJson(id: 'o1', pro: 'Mavi Hat Tesisat ve Isıtma'),
          offerSummaryJson(id: 'o2', pro: 'Kırmızı Su', total: 2100),
        ],
        'declinedCount': 1,
      }),
      'GET /offers/o1': (_) => json(200, offerDetailJson()),
      'GET /pros/po1': (_) => json(200, proPublicJson()),
      'GET /pros/po1/reviews': (_) => json(200, {
        'items': [
          {
            'id': 'v1',
            'rating': 5,
            'tags': ['Temiz', 'Zamanında'],
            'comment': 'Çok memnun kaldım, teşekkürler.',
            'authorDisplay': 'A.Y.',
            'createdAt': '2026-11-09T08:00:00Z',
          },
        ],
      }),
    });
    for (final route in [
      '/c/home',
      '/c/requests',
      '/c/addresses',
      '/c/requests/new',
      '/c/requests/r1',
      '/c/requests/r1/edit',
      '/c/requests/r1/cancel',
      '/c/requests/r1/published',
      '/c/requests/r1/offers',
      '/c/requests/r1/compare?ids=o1,o2',
      '/c/offers/o1',
      '/c/offers/o1/decline',
      '/c/pros/po1',
      '/c/pros/po1/reviews',
    ]) {
      testWidgets(route, (t) async {
        await pumpApp(
          t,
          session: customer,
          initial: route,
          handler: server,
          size: const Size(320, 640),
          textScale: 2,
        );
        expect(t.takeException(), isNull, reason: route);
      });
    }

    testWidgets('sihirbaz 4 adım ve 2x yazı', (t) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        handler: server,
        size: const Size(320, 640),
        textScale: 2,
      );
      h.container
          .read(wizardProvider.notifier)
          .update(
            (d) => d.copyWith(
              categoryId: 'plumbing',
              addressId: '7',
              answers: {'since': 'today'},
              title: 'Mutfak musluğu',
              description: 'Musluk iki gündür damlatıyor.',
            ),
          );
      for (final step in [2, 3, 4]) {
        h.container.read(wizardProvider.notifier).goTo(step);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: 'adım $step');
      }
    });
  });
}
