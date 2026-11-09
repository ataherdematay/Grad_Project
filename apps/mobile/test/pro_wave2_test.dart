import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/core/photos.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/pro/offer_logic.dart';
import 'package:bitadilat_mobile/features/pro/pro_apply.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';

SessionState proSession() => SessionState.signedIn(
  testMe(proStatus: 'APPROVED', lastMode: UserMode.pro),
);

const tall = Size(390, 2600);

Finder btn(String label) => find.widgetWithText(AppButton, label);

String trMsg(String Function(AppLocalizations) f) =>
    f(lookupAppLocalizations(const Locale('tr')));

Map<String, dynamic> proOfferItem({String status = 'PENDING'}) => {
  ...offerSummaryJson(status: status),
  'request': {
    'id': 'r1',
    'publicCode': 'BD-00001',
    'title': 'Mutfak musluğu damlıyor',
    'districtName': 'Kadıköy',
  },
};

void main() {
  group('Teklif hesapları', () {
    test('toplam, hizmet bedeli %10 ve net', () {
      final t = OfferTotals.of(const Money.lira(1800), const [
        OfferLine(description: 'Vana', quantity: 2, unitPrice: Money.lira(325)),
      ]);
      expect(t.materials, const Money.lira(650));
      expect(t.total, const Money.lira(2450));
      expect(t.serviceFee, const Money.lira(245));
      expect(t.net, const Money.lira(2205));
    });

    test('kuruşlu tutarlar kayıpsız toplanır', () {
      final t = OfferTotals.of(const Money.cents(10), const [
        OfferLine(description: 'a', quantity: 3, unitPrice: Money.cents(20)),
      ]);
      expect(t.total.cents, 70);
      expect(t.serviceFee.cents, 7);
      expect(t.net.cents, 63);
      expect(t.serviceFee + t.net, t.total);
    });

    test('tutar metni TR ve EN biçiminde çözülür', () {
      expect(parseMoney('1.250,50', 'tr'), const Money.cents(125050));
      expect(parseMoney('1250', 'tr'), const Money.lira(1250));
      expect(parseMoney('1,250.50', 'en'), const Money.cents(125050));
      expect(parseMoney('abc', 'tr'), isNull);
      expect(parseMoney('', 'tr'), isNull);
      expect(parseMoney('12,345', 'tr'), isNull);
    });

    test('varış penceresi sözleşme sınırları', () {
      final now = DateTime(2026, 11, 10, 9);
      DateTime at(int h, [int d = 0]) => DateTime(2026, 11, 10 + d, h);
      expect(validateArrival(null, null, now), ArrivalIssue.missing);
      expect(validateArrival(at(8), at(10), now), ArrivalIssue.past);
      expect(
        validateArrival(at(10), at(10).add(const Duration(minutes: 30)), now),
        ArrivalIssue.tooShort,
      );
      expect(validateArrival(at(10), at(23), now), ArrivalIssue.tooLong);
      expect(validateArrival(at(10, 15), at(12, 15), now), ArrivalIssue.tooFar);
      expect(validateArrival(at(10), at(11), now), isNull);
      expect(validateArrival(at(10), at(22), now), isNull);
      expect(validateArrival(at(8, 14), at(10, 14), now), isNull);
    });
  });

  group('Akış', () {
    testWidgets('onBreak: Moladasın boş durumu ve Aktif ol', (t) async {
      var onBreak = true;
      Map<String, dynamic>? put;
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/feed',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/feed': (_) => json(200, {
            'items': onBreak ? <Object>[] : [feedItemJson()],
            'onBreak': onBreak,
          }),
          'PUT /pro/availability': (o) {
            put = o.data as Map<String, dynamic>;
            onBreak = false;
            return json(200, proProfileJson());
          },
          'GET /me': (_) =>
              json(200, meJson(lastMode: 'PRO', pro: proJson('APPROVED'))),
        }),
      );
      expect(find.text('Moladasın'), findsOneWidget);
      expect(btn('Aktif ol'), findsOneWidget);
      await t.tap(btn('Aktif ol'));
      await t.pumpAndSettle();
      expect(put, {'availability': 'ACTIVE'});
      expect(find.text('Moladasın'), findsNothing);
      expect(find.text('Mutfak musluğu damlıyor'), findsOneWidget);
      expect(h.adapter.count('GET', '/pro/feed'), 2);
    });

    testWidgets('kartlar ve Acil/Planlı filtresi sorguya gider', (t) async {
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/feed',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/feed': (_) => json(200, {
            'items': [feedItemJson(myOfferId: 'o1')],
            'onBreak': false,
          }),
        }),
      );
      expect(find.text('Kadıköy, Moda'), findsNothing);
      expect(find.textContaining('Kadıköy, Moda'), findsOneWidget);
      expect(find.text('2 fotoğraf'), findsOneWidget);
      expect(find.text('1 teklif'), findsOneWidget);
      expect(find.text('Teklif verdin'), findsOneWidget);
      expect(h.adapter.last('/pro/feed').queryParameters, {'limit': 50});
      await t.tap(find.text('Acil'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/pro/feed').queryParameters, {
        'urgency': 'URGENT',
        'limit': 50,
      });
      await t.tap(find.text('Planlı'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/pro/feed').queryParameters, {
        'urgency': 'PLANNED',
        'limit': 50,
      });
    });

    testWidgets(
      'talep detayı: maskeli konum ve Teklif hazırla / Teklifini gör',
      (t) async {
        var mine = false;
        await pumpApp(
          t,
          session: proSession(),
          initial: '/p/requests/r1',
          handler: routes({
            ...baseRoutes(),
            'GET /pro/requests/r1': (_) => json(
              200,
              proRequestJson(
                myOffer: mine ? offerDetailJson(forPro: true) : null,
              ),
            ),
          }),
        );
        expect(find.text('Kadıköy, Moda'), findsOneWidget);
        expect(find.textContaining('Moda Cd.'), findsNothing);
        expect(
          find.text('Tam adres, teklifin kabul edilince paylaşılır.'),
          findsOneWidget,
        );
        expect(btn('Teklif hazırla'), findsOneWidget);
        mine = true;
      },
    );

    testWidgets('verilmiş teklif varsa Teklifini gör', (t) async {
      await pumpApp(
        t,
        session: proSession(),
        initial: '/p/requests/r1',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/requests/r1': (_) =>
              json(200, proRequestJson(myOffer: offerDetailJson(forPro: true))),
        }),
      );
      expect(btn('Teklifini gör'), findsOneWidget);
      expect(btn('Teklif hazırla'), findsNothing);
    });
  });

  group('Teklif formu', () {
    final fixedNow = DateTime(2026, 11, 10, 8);

    Future<Harness> openForm(WidgetTester t, Handler handler) => pumpApp(
      t,
      session: proSession(),
      initial: '/p/requests/r1/offer',
      size: tall,
      handler: handler,
      overrides: [nowProvider.overrideWithValue(() => fixedNow)],
    );

    Future<void> fillValid(WidgetTester t) async {
      await t.enterText(find.byType(TextFormField).first, '1800');
      await t.tap(btn('Malzeme kalemi ekle'));
      await t.pumpAndSettle();
      final sheet = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextFormField),
      );
      await t.enterText(sheet.at(0), 'Küresel vana');
      await t.enterText(sheet.at(1), '2');
      await t.enterText(sheet.at(2), '325');
      await t.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Kaydet'),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Gün'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tamam'));
      await t.pumpAndSettle();
      await t.tap(find.text('Başlangıç saati'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tamam'));
      await t.pumpAndSettle();
    }

    Handler server({FutureOr<ResponseBody> Function(RequestOptions)? post}) =>
        routes({
          ...baseRoutes(),
          'GET /pro/requests/r1': (_) => json(200, proRequestJson()),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
          'POST /pro/requests/r1/offers':
              post ?? (_) => json(201, offerDetailJson(id: 'o9', forPro: true)),
          'GET /offers/o9': (_) =>
              json(200, offerDetailJson(id: 'o9', forPro: true)),
          'GET /pro/offers': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
        });

    testWidgets('canlı özet: toplam, hizmet bedeli %10 ve net', (t) async {
      await openForm(t, server());
      expect(find.text('Hizmet bedeli (%10)'), findsOneWidget);
      await t.enterText(find.byType(TextFormField).first, '1800');
      await t.tap(btn('Malzeme kalemi ekle'));
      await t.pumpAndSettle();
      final sheet = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextFormField),
      );
      await t.enterText(sheet.at(0), 'Küresel vana');
      await t.enterText(sheet.at(1), '2');
      await t.enterText(sheet.at(2), '325');
      await t.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Kaydet'),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('2 × ₺325'), findsOneWidget);
      expect(find.text('₺2.450'), findsOneWidget);
      expect(find.text('-₺245'), findsOneWidget);
      expect(find.text('₺2.205'), findsOneWidget);
      // Kalemi sil: toplamlar otomatik güncellenir.
      await t.tap(find.byTooltip('Kalemi sil'));
      await t.pumpAndSettle();
      expect(find.text('₺1.800'), findsWidgets);
      expect(find.text('-₺180'), findsOneWidget);
      expect(find.text('₺1.620'), findsOneWidget);
    });

    testWidgets('boş form gönderilmez, pencere hatası görünür', (t) async {
      final h = await openForm(t, server());
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(find.text('Gün ve başlangıç saatini seç.'), findsOneWidget);
      expect(find.textContaining('İşçilik tutarı 0'), findsOneWidget);
      expect(h.adapter.count('POST', '/pro/requests/r1/offers'), 0);
    });

    testWidgets('geçmiş başlangıç reddedilir', (t) async {
      // Şimdi 08:00 iken varsayılan 10:00 geçerli; şimdi 11:00 yapılınca geçmiş.
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/requests/r1/offer',
        size: tall,
        handler: server(),
        overrides: [
          nowProvider.overrideWithValue(() => DateTime(2026, 11, 10, 11)),
        ],
      );
      await t.enterText(find.byType(TextFormField).first, '1800');
      await t.tap(find.text('Gün'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tamam'));
      await t.pumpAndSettle();
      await t.tap(find.text('Başlangıç saati'));
      await t.pumpAndSettle();
      await t.tap(find.text('Tamam'));
      await t.pumpAndSettle();
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(find.text('Varış zamanı ileri bir tarih olmalı.'), findsOneWidget);
      expect(h.adapter.count('POST', '/pro/requests/r1/offers'), 0);
    });

    testWidgets(
      'çift basışta tek istek, aynı anahtar; başarıda sent ve yığın',
      (t) async {
        final gate = Completer<void>();
        Map<String, dynamic>? body;
        final h = await openForm(
          t,
          server(
            post: (o) async {
              body = o.data as Map<String, dynamic>;
              await gate.future;
              return json(201, offerDetailJson(id: 'o9', forPro: true));
            },
          ),
        );
        await fillValid(t);
        await t.tap(btn('Teklifi gönder'));
        await t.pump(const Duration(milliseconds: 100));
        await t.tap(find.byType(FilledButton).last, warnIfMissed: false);
        await t.pump(const Duration(milliseconds: 100));
        expect(h.adapter.count('POST', '/pro/requests/r1/offers'), 1);
        gate.complete();
        await t.pumpAndSettle();

        final post = h.adapter.requests.firstWhere((r) => r.method == 'POST');
        expect(post.headers['Idempotency-Key'], isNotEmpty);
        expect(body!['laborAmount'], 1800);
        expect(body!['materialsAmount'], 650);
        expect(body!['warrantyMonths'], 0);
        expect((body!['items'] as List), hasLength(2));
        expect(body!['arrivalFrom'], endsWith('Z'));

        expect(h.location, '/p/offers/o9/sent');
        expect(find.text('Teklifin gönderildi'), findsOneWidget);
        expect(find.text('Net kazancın'), findsOneWidget);
        // Geri tuşu forma dönmez, akışa gider.
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(h.location, '/p/feed');
        expect(find.text('Teklifi gönder'), findsNothing);
      },
    );

    testWidgets('ALREADY_OFFERED mesajı gösterilir, form korunur', (t) async {
      await openForm(t, server(post: (_) => apiError(409, 'ALREADY_OFFERED')));
      await fillValid(t);
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(find.text(trMsg((l) => l.apiErrorAlreadyOffered)), findsOneWidget);
      final labor = t.widget<TextFormField>(find.byType(TextFormField).first);
      expect(labor.controller!.text, '1800');
    });

    testWidgets('ILLEGAL_STATE: ekran güncellendi mesajı ve yenileme', (
      t,
    ) async {
      final h = await openForm(
        t,
        server(post: (_) => apiError(409, 'ILLEGAL_STATE')),
      );
      await fillValid(t);
      final before = h.adapter.count('GET', '/pro/requests/r1');
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(
        find.text('Bu işlem artık yapılamıyor, ekran güncellendi.'),
        findsOneWidget,
      );
      expect(
        h.adapter.count('GET', '/pro/requests/r1'),
        greaterThanOrEqualTo(before),
      );
    });

    testWidgets('ağ hatasında form korunur ve tekrar gönderilebilir', (
      t,
    ) async {
      var fail = true;
      final h = await openForm(
        t,
        server(
          post: (o) {
            if (fail) {
              throw DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              );
            }
            return json(201, offerDetailJson(id: 'o9', forPro: true));
          },
        ),
      );
      await fillValid(t);
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('İnternet bağlantına ulaşılamıyor'),
        findsOneWidget,
      );
      fail = false;
      await t.tap(btn('Teklifi gönder'));
      await t.pumpAndSettle();
      expect(h.location, '/p/offers/o9/sent');
      final keys = h.adapter.requests
          .where((r) => r.method == 'POST')
          .map((r) => r.headers['Idempotency-Key'])
          .toSet();
      expect(
        keys,
        hasLength(1),
        reason: 'aynı gövde aynı anahtarla yeniden gider',
      );
    });
  });

  group('Tekliflerim', () {
    testWidgets('durum filtresi sorguya gider; PENDING geri çekilir (onaylı)', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/offers',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/offers': (_) => json(200, {
            'items': [proOfferItem()],
            'nextCursor': null,
          }),
          'POST /pro/offers/o1/withdraw': (_) =>
              json(200, offerDetailJson(status: 'WITHDRAWN', forPro: true)),
        }),
      );
      expect(find.text('Mutfak musluğu damlıyor'), findsOneWidget);
      await t.tap(find.text('Bekliyor').first);
      await t.pumpAndSettle();
      expect(h.adapter.last('/pro/offers').queryParameters, {
        'status': 'PENDING',
        'limit': 50,
      });

      await t.tap(btn('Geri çek'));
      await t.pumpAndSettle();
      expect(find.text('Teklif geri çekilsin mi?'), findsOneWidget);
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/pro/offers/o1/withdraw'), 0);

      await t.tap(btn('Geri çek'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Geri çek'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/pro/offers/o1/withdraw'), 1);
    });

    testWidgets('kabul edilen teklifte Geri çek yok; boş durum', (t) async {
      await pumpApp(
        t,
        session: proSession(),
        initial: '/p/offers',
        handler: routes({
          'GET /pro/offers': (_) => json(200, {
            'items': [proOfferItem(status: 'ACCEPTED')],
            'nextCursor': null,
          }),
        }),
      );
      expect(btn('Geri çek'), findsNothing);
      expect(find.text('Kabul edildi'), findsWidgets);
    });

    testWidgets('İşlerim bu dalgada boş durum', (t) async {
      await pumpApp(t, session: proSession(), initial: '/p/jobs');
      expect(find.text('Henüz işin yok'), findsOneWidget);
    });
  });

  group('Başvuru', () {
    testWidgets('zorunlu belgeler yoksa gönderilmez; yüklenince gönderilir', (
      t,
    ) async {
      var n = 0;
      Map<String, dynamic>? body;
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/p/apply',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'POST /media': (o) => uploadOk(o, 'up${++n}'),
          'POST /pro/application': (o) {
            body = o.data as Map<String, dynamic>;
            return json(201, applicationJson());
          },
          'GET /pro/application': (_) => json(200, applicationJson()),
          'GET /me': (_) => json(200, meJson(pro: proJson('PENDING_REVIEW'))),
        }),
        overrides: [
          photoPickerProvider.overrideWithValue(FakePicker([1000])),
        ],
      );
      await t.tap(btn('Başvuruyu gönder'));
      await t.pumpAndSettle();
      expect(find.text('Kimlik belgesini yükle.'), findsOneWidget);
      expect(find.text('Mesleki yeterlilik belgesini yükle.'), findsOneWidget);
      expect(find.text('Vergi levhası belgesini yükle.'), findsNothing);
      expect(h.adapter.count('POST', '/pro/application'), 0);

      // Alanlar.
      await t.enterText(find.byType(TextFormField).at(0), 'Usta Tesisat');
      await t.tap(find.text('Seç').at(0));
      await t.pumpAndSettle();
      await t.tap(find.text('Tesisat').last);
      await t.tap(find.text('Bitti'));
      await t.pumpAndSettle();
      await t.tap(find.text('Seç').at(0));
      await t.pumpAndSettle();
      await t.tap(find.text('Kadıköy').last);
      await t.tap(find.text('Bitti'));
      await t.pumpAndSettle();

      // Yalnız kimlik: hâlâ eksik.
      await t.tap(find.widgetWithText(AppButton, 'Fotoğraf ekle').at(0));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      await t.tap(btn('Başvuruyu gönder'));
      await t.pumpAndSettle();
      expect(find.text('Kimlik belgesini yükle.'), findsNothing);
      expect(find.text('Mesleki yeterlilik belgesini yükle.'), findsOneWidget);
      expect(h.adapter.count('POST', '/pro/application'), 0);

      await t.tap(find.widgetWithText(AppButton, 'Fotoğraf ekle').at(0));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      await t.tap(btn('Başvuruyu gönder'));
      await t.pumpAndSettle();

      expect(body!['businessName'], 'Usta Tesisat');
      expect(body!['categoryIds'], ['plumbing']);
      expect(body!['districtIds'], [1]);
      expect(body!['documents'], [
        {'type': 'IDENTITY', 'mediaId': 'up1'},
        {'type': 'TRADE_CERT', 'mediaId': 'up2'},
      ]);
      final uploads = h.adapter.requests.where(
        (r) => r.path.endsWith('/media'),
      );
      for (final u in uploads) {
        expect((u.data as FormData).fields.single.value, 'PRO_DOCUMENT');
      }
      expect(h.location, '/p/application');
      expect(find.text('İnceleniyor'), findsWidgets);
      // Geri: profil.
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/c/profile');
    });

    test('eksik zorunlu belge hesabı', () {
      final sets = <ProDocumentType, PhotoSet>{};
      expect(
        missingRequiredDocs(sets),
        containsAll([ProDocumentType.identity, ProDocumentType.tradeCert]),
      );
    });

    testWidgets('NEEDS_DOCUMENTS: not, durum, dolu form ve yeniden gönderim', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe(proStatus: 'NEEDS_DOCUMENTS')),
        initial: '/p/application',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /pro/application': (_) => json(
            200,
            applicationJson(
              status: 'NEEDS_DOCUMENTS',
              note: 'Kimlik okunmuyor.',
            ),
          ),
        }),
      );
      expect(find.text('Belge eksik'), findsWidgets);
      expect(find.text('Kimlik okunmuyor.'), findsOneWidget);
      expect(btn('Müşteri moduna dön'), findsOneWidget);
      await t.tap(btn('Belgeleri güncelle ve yeniden gönder'));
      await t.pumpAndSettle();
      expect(h.location, '/p/apply');
      final name = t.widget<TextFormField>(find.byType(TextFormField).first);
      expect(name.controller!.text, 'Usta Tesisat');
      expect(find.text('Tesisat'), findsWidgets);
    });

    testWidgets('PENDING_REVIEW: yeniden gönderim yok, müşteri moduna dön', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe(proStatus: 'PENDING_REVIEW')),
        initial: '/p/application',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/application': (_) => json(200, applicationJson()),
        }),
      );
      expect(btn('Belgeleri güncelle ve yeniden gönder'), findsNothing);
      await t.tap(btn('Müşteri moduna dön'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
    });
  });

  group('Usta profili', () {
    Handler profileServer(void Function(RequestOptions) onPut) => routes({
      ...baseRoutes(),
      'GET /pro/profile': (_) => json(200, proProfileJson()),
      'PUT /pro/availability': (o) {
        onPut(o);
        return json(200, proProfileJson(availability: 'ON_BREAK'));
      },
      'PUT /pro/profile': (o) {
        onPut(o);
        return json(200, proProfileJson());
      },
      'GET /me': (_) =>
          json(200, meJson(lastMode: 'PRO', pro: proJson('APPROVED'))),
      'PATCH /me': (_) =>
          json(200, meJson(lastMode: 'CUSTOMER', pro: proJson('APPROVED'))),
    });

    testWidgets('Aktif/Mola anahtarı ve kaydet', (t) async {
      final puts = <RequestOptions>[];
      final h = await pumpApp(
        t,
        session: proSession(),
        initial: '/p/profile',
        size: tall,
        handler: profileServer(puts.add),
      );
      expect(find.text('Aktifsin'), findsOneWidget);
      await t.tap(find.byType(Switch).first);
      await t.pumpAndSettle();
      expect(puts.single.data, {'availability': 'ON_BREAK'});

      await t.tap(btn('Kaydet'));
      await t.pumpAndSettle();
      final body = puts.last.data as Map<String, dynamic>;
      expect(body['businessName'], 'Usta Tesisat');
      expect(body['categoryIds'], ['plumbing']);
      expect(body['districtIds'], [1]);
      expect(body['workingHours'], [
        {'weekday': 1, 'start': '09:00', 'end': '18:00', 'acceptsUrgent': true},
      ]);

      await t.tap(btn('Müşteri moduna geç'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
    });
  });

  group('Taşma (320 px, 2x yazı) usta ekranları', () {
    final server = routes({
      ...baseRoutes(),
      'GET /pro/feed': (_) => json(200, {
        'items': [feedItemJson(myOfferId: 'o1')],
        'onBreak': false,
      }),
      'GET /pro/requests/r1': (_) => json(200, proRequestJson()),
      'GET /pro/offers': (_) => json(200, {
        'items': [proOfferItem()],
        'nextCursor': null,
      }),
      'GET /offers/o1': (_) => json(200, offerDetailJson(forPro: true)),
      'GET /pro/profile': (_) => json(200, proProfileJson()),
      'GET /pro/application': (_) => json(
        200,
        applicationJson(status: 'NEEDS_DOCUMENTS', note: 'Kimlik okunmuyor.'),
      ),
    });
    for (final route in [
      '/p/feed',
      '/p/requests/r1',
      '/p/requests/r1/offer',
      '/p/offers',
      '/p/offers/o1/sent',
      '/p/profile',
      '/p/jobs',
    ]) {
      testWidgets(route, (t) async {
        await pumpApp(
          t,
          session: proSession(),
          initial: route,
          handler: server,
          size: const Size(320, 640),
          textScale: 2,
        );
        expect(t.takeException(), isNull, reason: route);
      });
    }
    testWidgets('/p/apply', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/p/apply',
        handler: server,
        size: const Size(320, 640),
        textScale: 2,
      );
      expect(t.takeException(), isNull);
    });
    testWidgets('/p/application', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe(proStatus: 'NEEDS_DOCUMENTS')),
        initial: '/p/application',
        handler: server,
        size: const Size(320, 640),
        textScale: 2,
      );
      expect(t.takeException(), isNull);
    });
    testWidgets('teklif formu doluyken', (t) async {
      await pumpApp(
        t,
        session: proSession(),
        initial: '/p/requests/r1/offer',
        handler: server,
        size: const Size(320, 640),
        textScale: 2,
      );
      await t.enterText(find.byType(TextFormField).first, '1800');
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  group('TR/EN', () {
    testWidgets('usta akışı İngilizce', (t) async {
      await pumpApp(
        t,
        session: proSession(),
        initial: '/p/feed',
        locale: 'en',
        handler: routes({
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': true}),
        }),
      );
      expect(find.text("You are on a break"), findsOneWidget);
      expect(btn('Go active'), findsOneWidget);
    });
  });
}
