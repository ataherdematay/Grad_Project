// Dalga 2 denetiminde bulunan hataların regresyon testleri.
import 'dart:async';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/core/photos.dart';
import 'package:bitadilat_mobile/core/providers.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/customer/wizard_screen.dart';
import 'package:bitadilat_mobile/features/customer/wizard_state.dart';
import 'package:bitadilat_mobile/features/pro/offer_logic.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';

const tall = Size(390, 1400);

Finder btn(String label) => find.widgetWithText(AppButton, label);

final customer = SessionState.signedIn(testMe());

SessionState proSession() => SessionState.signedIn(
  testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
);

SessionState userSession(String id) => SessionState.signedIn(
  Me.fromJson({...meJson(), 'id': id, 'fullName': 'Kullanıcı $id'}),
);

/// Testte kullanıcı değiştirebilen sahte oturum.
class SwitchableSession extends FakeSession {
  SwitchableSession(super.initial);

  void set(SessionState s) => state = s;
}

/// Her çağrıda aynı baytları döner (aynı fotoğrafı iki kez seçmek).
class SamePhotoPicker implements PhotoPicker {
  final bytes = Uint8List.fromList(List<int>.generate(800, (i) => i % 251));

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async =>
      PickedPhoto(bytes: Uint8List.fromList(bytes), name: 'same.jpg');
}

PhotoSet photoSet(
  FakeAdapter adapter,
  PhotoPicker picker, {
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

/// Tüm adımları geçerli, yayına hazır taslak (acil talep).
RequestDraft validDraft() => const RequestDraft(
  categoryId: 'plumbing',
  addressId: '7',
  answers: {'since': 'today'},
  title: 'Mutfak musluğu',
  description: 'Musluk iki gündür sürekli damlatıyor.',
);

Handler wizardServer({
  FutureOr<ResponseBody> Function(RequestOptions o)? create,
}) => routes({
  ...baseRoutes(),
  'POST /requests': create ?? (_) => json(201, requestDetailJson(id: 'r9')),
  'GET /requests/r9': (_) => json(200, requestDetailJson(id: 'r9')),
  'GET /requests': (_) => json(200, {'items': <Object>[], 'nextCursor': null}),
});

void main() {
  group('Para girişi', () {
    test('yanlış ondalık ayırıcı tutarı 100 katına çıkarmaz', () {
      // TR klavyede nokta ile yazılmış kuruş: 1250.50 -> ₺1.250,50.
      expect(parseMoney('1250.50', 'tr'), const Money.cents(125050));
      expect(parseMoney('12.5', 'tr'), const Money.cents(1250));
      // Binlik ayırıcı olarak nokta (TR) geçerli kalır.
      expect(parseMoney('1.250', 'tr'), const Money.lira(1250));
      expect(parseMoney('1.250.000,5', 'tr'), const Money.cents(125000050));
      // EN için virgülle yazılmış kuruş.
      expect(parseMoney('1250,5', 'en'), const Money.cents(125050));
      expect(parseMoney('1,250', 'en'), const Money.lira(1250));
      // Bozuk gruplama reddedilir.
      expect(parseMoney('12.34.56', 'tr'), isNull);
      expect(parseMoney('1.2.3', 'tr'), isNull);
      expect(parseMoney('1,25,0', 'en'), isNull);
    });
  });

  group('Sihirbaz taslağı kullanıcıya özel', () {
    test('başka kullanıcı önceki kullanıcının taslağını görmez', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ProviderContainer make(String user) => ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionProvider.overrideWith(() => FakeSession(userSession(user))),
        ],
      );
      final a = make('a');
      a
          .read(wizardProvider.notifier)
          .update(
            (d) => d.copyWith(title: 'A kullanıcısının evi', addressId: '7'),
          );
      a.dispose();

      final b = make('b');
      expect(b.read(wizardProvider).draft.isEmpty, isTrue);
      b.dispose();

      final a2 = make('a');
      addTearDown(a2.dispose);
      expect(a2.read(wizardProvider).draft.title, 'A kullanıcısının evi');
    });

    test('eski ortak taslak anahtarı okunmaz ve silinir', () async {
      SharedPreferences.setMockInitialValues({
        kDraftKey: '{"draft":{"title":"Eski"},"step":2}',
      });
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionProvider.overrideWith(() => FakeSession(userSession('b'))),
        ],
      );
      addTearDown(c.dispose);
      expect(c.read(wizardProvider).draft.isEmpty, isTrue);
      expect(prefs.getString(kDraftKey), isNull);
    });

    test(
      'oturumdaki kullanıcı değişince bellekteki taslak sıfırlanır',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        late SwitchableSession session;
        final c = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            sessionProvider.overrideWith(
              () => session = SwitchableSession(userSession('a')),
            ),
          ],
        );
        addTearDown(c.dispose);
        final sub = c.listen(wizardProvider, (_, _) {});
        addTearDown(sub.close);
        c.read(wizardProvider.notifier).update((d) => d.copyWith(title: 'A'));
        expect(c.read(wizardProvider).draft.title, 'A');
        session.set(userSession('b'));
        expect(c.read(wizardProvider).draft.isEmpty, isTrue);
      },
    );
  });

  group('Sihirbaz yayını', () {
    testWidgets(
      'yayından önce tüm adımlar yeniden doğrulanır (eskimiş tarih)',
      (t) async {
        final h = await pumpApp(
          t,
          session: customer,
          initial: '/c/requests/new',
          size: tall,
          handler: wizardServer(),
        );
        final ctrl = h.container.read(wizardProvider.notifier);
        final past = DateTime.now().subtract(const Duration(days: 2));
        ctrl.update(
          (_) => validDraft().copyWith(
            urgency: RequestUrgency.planned,
            preferredFrom: past,
            preferredTo: past.add(const Duration(hours: 3)),
          ),
        );
        ctrl.goTo(4);
        await t.pumpAndSettle();
        await t.tap(btn('Talebi yayınla'));
        await t.pumpAndSettle();
        expect(h.adapter.count('POST', '/requests'), 0);
        expect(find.text('Adım 1 / 4'), findsOneWidget);
        expect(
          find.text('Başlangıç ileri bir zamanda olmalı.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('sunucunun alan hatası ilgili adımı açar ve alanı söyler', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        size: tall,
        handler: wizardServer(
          create: (_) => apiError(400, 'VALIDATION_FAILED', field: 'title'),
        ),
      );
      final ctrl = h.container.read(wizardProvider.notifier);
      ctrl.update((_) => validDraft());
      ctrl.goTo(4);
      await t.pumpAndSettle();
      await t.tap(btn('Talebi yayınla'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/requests'), 1);
      expect(find.text('Adım 3 / 4'), findsOneWidget);
      expect(
        find.text('“Başlık” bilgisi kabul edilmedi. Kontrol edip tekrar dene.'),
        findsOneWidget,
      );
    });

    testWidgets('bekleyen teklifi olan talep düzenlenirken onay istenir', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/edit',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /requests/r1': (_) => json(200, requestDetailJson()),
          'PATCH /requests/r1': (_) => json(200, requestDetailJson()),
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      h.container.read(wizardProvider.notifier).goTo(4);
      await t.pumpAndSettle();
      await t.tap(btn('Değişiklikleri kaydet'));
      await t.pumpAndSettle();
      expect(find.textContaining('2 bekleyen teklifin'), findsOneWidget);
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(h.adapter.count('PATCH', '/requests/r1'), 0);

      await t.tap(btn('Değişiklikleri kaydet'));
      await t.pumpAndSettle();
      await t.tap(
        find.widgetWithText(FilledButton, 'Değişiklikleri kaydet').last,
      );
      await t.pumpAndSettle();
      expect(h.adapter.count('PATCH', '/requests/r1'), 1);
    });

    testWidgets('eskimiş taslak tarihiyle tarih seçici açılır (çökme yok)', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/new',
        size: tall,
        handler: wizardServer(),
      );
      final past = DateTime.now().subtract(const Duration(days: 3));
      h.container
          .read(wizardProvider.notifier)
          .update(
            (_) => validDraft().copyWith(
              urgency: RequestUrgency.planned,
              preferredFrom: past,
              preferredTo: past.add(const Duration(hours: 2)),
            ),
          );
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(PickerFieldButton, 'En erken'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    test('düzenlemede sunucu tarihleri yerel saate çevrilir', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionProvider.overrideWith(() => FakeSession(customer)),
        ],
      );
      addTearDown(c.dispose);
      final d = RequestDetail.fromJson({
        ...requestDetailJson(),
        'urgency': 'PLANNED',
        'preferredFrom': '2026-11-20T07:00:00Z',
        'preferredTo': '2026-11-20T10:00:00Z',
      });
      c.read(wizardProvider.notifier).startEdit(d, const []);
      final draft = c.read(wizardProvider).draft;
      expect(draft.preferredFrom!.isUtc, isFalse);
      expect(draft.preferredFrom!.toUtc(), DateTime.utc(2026, 11, 20, 7));
    });
  });

  group('Fotoğraflar', () {
    test('beklenmeyen hata yüklemeyi takılı bırakmaz', () async {
      final adapter = FakeAdapter((o) => uploadOk(o));
      final set = photoSet(
        adapter,
        FakePicker([kMaxPhotoBytes + 1]),
        recompress: (b, q, w) async => throw StateError('çözülemedi'),
      );
      await set.add(PhotoSource.gallery);
      expect(set.isBusy, isFalse);
      expect(set.items.single.status, PhotoStatus.failed);
      expect(adapter.requests, isEmpty);
    });

    test('aynı fotoğraf iki kez eklenmez', () async {
      final adapter = FakeAdapter((o) => uploadOk(o));
      final set = photoSet(adapter, SamePhotoPicker());
      expect(await set.add(PhotoSource.gallery), PhotoAddResult.added);
      expect(await set.add(PhotoSource.gallery), PhotoAddResult.duplicate);
      expect(set.items, hasLength(1));
      expect(adapter.requests, hasLength(1));
    });
  });

  group('Listeler en çok 50 kayıt ister', () {
    testWidgets('akış, tekliflerim ve değerlendirmeler', (t) async {
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/feed',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
          'GET /pro/offers': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      expect(h.adapter.last('/pro/feed').queryParameters['limit'], 50);
      h.router.push('/p/offers');
      await t.pumpAndSettle();
      expect(h.adapter.last('/pro/offers').queryParameters['limit'], 50);
    });

    testWidgets('usta değerlendirmeleri', (t) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/pros/p1/reviews',
        handler: routes({
          'GET /pros/p1/reviews': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        }),
      );
      expect(h.adapter.last('/pros/p1/reviews').queryParameters['limit'], 50);
    });
  });

  group('Eskimiş durum ve gezinme', () {
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
    });

    testWidgets('OFFER_EXPIRED: açıklama ve ekran yenileme', (t) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/offers/o1/decline',
        size: tall,
        handler: offerServer(decline: (_) => apiError(409, 'OFFER_EXPIRED')),
      );
      await t.tap(find.text('Diğer'));
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      final before = h.adapter.count('GET', '/offers/o1');
      await t.tap(find.widgetWithText(FilledButton, 'Teklifi reddet').last);
      await t.pumpAndSettle();
      expect(
        find.text('Bu teklifin süresi doldu. Teklif listesine dön.'),
        findsOneWidget,
      );
      expect(h.adapter.count('GET', '/offers/o1'), greaterThan(before));
    });

    testWidgets('derin bağlantıyla açılan reddetme başarıda talebe gider', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/offers/o1/decline',
        size: tall,
        handler: offerServer(),
      );
      await t.tap(find.text('Diğer'));
      await t.tap(btn('Teklifi reddet'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Teklifi reddet').last);
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1/offers');
    });

    testWidgets('derin bağlantıyla açılan iptal başarıda talebe gider', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/cancel',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'POST /requests/r1/cancel': (_) =>
              json(200, requestDetailJson(status: 'CANCELLED')),
          'GET /requests/r1': (_) =>
              json(200, requestDetailJson(status: 'CANCELLED')),
        }),
      );
      await t.tap(find.text('Sorunu çözdüm'));
      await t.tap(btn('Talebi iptal et'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Talebi iptal et').last);
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1');
    });

    testWidgets('karşılaştırma derin bağlantıda boş yığında pop yapmaz', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/compare?ids=o1,o2',
        handler: offerServer(),
      );
      expect(find.text('Teklifler artık listede yok'), findsOneWidget);
      await t.tap(btn('Tekliflere dön'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(h.location, '/c/requests/r1/offers');
    });
  });

  group('İngilizce çoğul', () {
    test('tekil sayılarda "1 offers" yazılmaz', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(en.requestOffersCount(1), '1 offer');
      expect(en.requestOffersCount(3), '3 offers');
      expect(en.offersResultCount(1), '1 offer');
      expect(en.publishedMatchTitle(1), '1 pro matched');
      expect(en.experienceYears(1), '1 year');
      expect(en.feedPhotos(1), '1 photo');
      expect(en.feedOffers(1), '1 offer');
      expect(en.offersDeclinedCount(1), 'You declined 1 offer.');
      expect(en.starsOutOf5(1), '1 out of 5 stars');
    });
  });

  group('Yerelleştirilmiş puan', () {
    testWidgets('TR puanı virgülle yazılır', (t) async {
      await pumpApp(
        t,
        session: customer,
        initial: '/c/requests/r1/offers',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /requests/r1': (_) => json(200, requestDetailJson()),
          'GET /requests/r1/offers': (_) => json(200, {
            'items': [offerSummaryJson()],
            'declinedCount': 0,
          }),
        }),
      );
      expect(find.text('4,6 (12)'), findsOneWidget);
      expect(find.text('4.6 (12)'), findsNothing);
    });
  });

  group('Teklif formu', () {
    final fixedNow = DateTime(2026, 11, 10, 8);

    Future<void> fillValid(WidgetTester t) async {
      await t.enterText(find.byType(TextFormField).first, '1800');
      await t.tap(find.text('Gün'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tamam'));
      await t.pumpAndSettle();
      await t.tap(find.text('Başlangıç saati'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tamam'));
      await t.pumpAndSettle();
    }

    Handler server(FutureOr<ResponseBody> Function(RequestOptions) post) =>
        routes({
          ...baseRoutes(),
          'GET /pro/requests/r1': (_) => json(200, proRequestJson()),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
          'POST /pro/requests/r1/offers': post,
        });

    testWidgets('sunucunun varış alanı hatası varış bölümünde görünür', (
      t,
    ) async {
      await pumpApp(
        t,
        session: proSession(),
        initial: '/p/requests/r1/offer',
        size: const Size(390, 2600),
        handler: server(
          (_) => apiError(400, 'VALIDATION_FAILED', field: 'arrivalFrom'),
        ),
        overrides: [nowProvider.overrideWithValue(() => fixedNow)],
      );
      await fillValid(t);
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'Varış aralığı kabul edilmedi. Gün ve saatleri kontrol edip tekrar dene.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Akış boş durumu', () {
    testWidgets('bir sonraki adım düğmesi profile götürür', (t) async {
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/feed',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
          'GET /pro/profile': (_) => json(200, proProfileJson()),
        }),
      );
      expect(find.text('Şu an uygun talep yok'), findsOneWidget);
      await t.tap(btn('Kategori ve ilçelerini düzenle'));
      await t.pumpAndSettle();
      expect(h.location, '/p/profile');
    });
  });
}
