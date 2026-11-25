import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/app/guards.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/payment/payment_journey.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

List<Override> get _now => [nowProvider.overrideWithValue(() => kNow)];

typedef Routes = Map<String, FutureOr<ResponseBody> Function(RequestOptions)>;

Map<String, dynamic> timelineJson({
  bool pro = false,
  String status = 'LOCKED',
  String location = 'BITADILAT_VAULT',
  String? autoReleaseAt,
  String? pendingAction,
  String? errorCode,
  List<Map<String, dynamic>>? events,
  bool sandbox = true,
}) => {
  'paymentRef': 'ref-1',
  'jobId': 'j1',
  'jobPublicCode': 'BD-88421',
  'jobTitle': 'Banyo lavabo altı su kaçağı',
  'status': status,
  'moneyLocation': location,
  'provider': 'DEMO',
  'sandbox': sandbox,
  'craftgatePaymentId': 50001,
  'card': pro
      ? null
      : {
          'brand': 'MASTERCARD',
          'last4': '0001',
          'masked': '**** **** **** 0001',
        },
  'amounts': {
    'gross': 1200.0,
    'commission': pro ? 120.0 : null,
    'proNet': pro ? 1080.0 : null,
    'refunded': 0.0,
  },
  'autoReleaseAt': autoReleaseAt,
  'pendingAction': pendingAction,
  'errorCode': errorCode,
  'events':
      events ??
      [
        {
          'type': 'PAYMENT_INITIALIZED',
          'at': '2026-11-09T09:00:00Z',
          'amount': 1200.0,
          'actor': 'CUSTOMER',
          'note': null,
        },
        {
          'type': 'PAYMENT_LOCKED',
          'at': '2026-11-09T09:01:12Z',
          'amount': 1200.0,
          'actor': 'SYSTEM',
          'note': null,
        },
        {
          'type': 'FUTURE_EVENT',
          'at': '2026-11-09T10:00:00Z',
          'amount': null,
          'actor': null,
          'note': null,
        },
      ],
};

Map<String, dynamic> receiptJson({bool sandbox = true, double refunded = 0}) =>
    {
      'receiptNo': 'BT-20261109-5B0F0A',
      'issuedAt': '2026-11-09T09:01:12Z',
      'paymentRef': 'ref-1',
      'jobId': 'j1',
      'jobPublicCode': 'BD-88421',
      'jobTitle': 'Banyo lavabo altı su kaçağı',
      'proName': 'Test Tesisat',
      'customerName': 'Ayşe Yılmaz',
      'items': [
        {
          'kind': 'LABOR',
          'label': 'İşçilik',
          'quantity': 1.0,
          'unitPrice': 900.0,
          'amount': 900.0,
        },
        {
          'kind': 'MATERIAL',
          'label': 'Malzeme',
          'quantity': 1.0,
          'unitPrice': 300.0,
          'amount': 300.0,
        },
      ],
      'total': 1200.0,
      'refundedTotal': refunded,
      'netPaid': 1200.0 - refunded,
      'currency': 'TRY',
      'card': {
        'brand': 'MASTERCARD',
        'last4': '0001',
        'masked': '**** **** **** 0001',
      },
      'status': 'LOCKED',
      'moneyLocation': 'BITADILAT_VAULT',
      'provider': 'DEMO',
      'sandbox': sandbox,
      'sandboxNotice': sandbox ? 'sunucu metni' : null,
    };

Map<String, dynamic> historyItem(
  String ref, {
  String? jobId = 'j1',
  String status = 'LOCKED',
  String location = 'BITADILAT_VAULT',
  double refunded = 0,
}) => {
  'ref': ref,
  'jobId': jobId,
  'jobPublicCode': 'BD-$ref',
  'jobTitle': 'İş $ref',
  'proName': 'Test Tesisat',
  'totalAmount': 1200.0,
  'refundedAmount': refunded,
  'status': status,
  'moneyLocation': location,
  'provider': 'DEMO',
  'sandbox': true,
  'paidAt': '2026-11-09T09:01:12Z',
  'createdAt': '2026-11-09T09:00:00Z',
};

Future<Harness> open(
  WidgetTester t,
  String route,
  Routes extra, {
  bool pro = false,
  String locale = 'tr',
  double textScale = 1,
}) => pumpApp(
  t,
  session: pro ? proSession3() : customerSession(),
  initial: route,
  size: tall,
  locale: locale,
  textScale: textScale,
  handler: server3({
    'GET /requests': (_) =>
        json(200, {'items': <Object>[], 'nextCursor': null}),
    ...extra,
  }),
  overrides: _now,
);

void main() {
  group('Mantık', () {
    test('countdownParts: kalan süre, yukarı yuvarlama, süresi dolmuş', () {
      final now = DateTime.utc(2026, 11, 10, 9);
      final at = now.add(const Duration(hours: 47, minutes: 12, seconds: 10));
      expect(countdownParts(at, now), (hours: 47, minutes: 13, due: false));
      expect(countdownParts(now, now).due, isTrue);
      expect(
        countdownParts(now.subtract(const Duration(hours: 1)), now).due,
        isTrue,
      );
    });

    test('para yeri etiketi ve usta farkı, TR ve EN', () {
      expect(
        tr((l) => moneyLocationLabel(l, MoneyLocation.vault)),
        'Güvence kasasında',
      );
      expect(
        tr((l) => moneyLocationLabel(l, MoneyLocation.customerCard)),
        'Kartında',
      );
      expect(tr((l) => moneyLocationLabel(l, MoneyLocation.pro)), 'Ustada');
      expect(
        tr((l) => moneyLocationLabel(l, MoneyLocation.customerRefunded)),
        'Sana iade edildi',
      );
      expect(
        tr((l) => moneyLocationLabel(l, MoneyLocation.split)),
        'Bölüşüldü',
      );
      expect(
        tr((l) => moneyLocationLabel(l, MoneyLocation.pro, pro: true)),
        'Sende',
      );
      expect(
        en((l) => moneyLocationLabel(l, MoneyLocation.vault)),
        'In the secure vault',
      );
    });

    test('olay metni: bilinmeyen tür genel satır, not kodu çevrilir', () {
      final e = PaymentEvent(type: PaymentEventType.unknown, at: kNow);
      expect(tr((l) => eventTitle(l, e)), 'Ödeme hareketi');
      final late = PaymentEvent(
        type: PaymentEventType.paymentLocked,
        at: kNow,
        note: 'LATE_SUCCESS',
      );
      expect(tr((l) => eventNote(l, late)!), 'Banka onayı geç geldi');
      final odd = PaymentEvent(
        type: PaymentEventType.paymentLocked,
        at: kNow,
        note: 'autoReleaseAt=2026-11-29T14:00:00Z',
      );
      expect(tr((l) => eventNote(l, odd) ?? ''), '');
      final rel = PaymentEvent(type: PaymentEventType.releasedToPro, at: kNow);
      expect(tr((l) => eventTitle(l, rel)), 'Tutar ustaya aktarıldı');
      expect(tr((l) => eventTitle(l, rel, pro: true)), 'Tutar sana aktarıldı');
    });
  });

  group('Paranın yolculuğu (müşteri)', () {
    testWidgets('veri: durum kartı, 3 düğüm, geri sayım, olaylar, makbuz', (
      t,
    ) async {
      final at = utc(kNow.add(const Duration(hours: 47, minutes: 12)));
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) =>
            json(200, timelineJson(autoReleaseAt: at)),
      });
      expect(find.text('Paranın yolculuğu'), findsOneWidget);
      expect(find.text('Para şu an'), findsOneWidget);
      expect(find.text('Güvence kasasında'), findsOneWidget);
      expect(find.text('Kart'), findsNWidgets(2)); // düğüm + kart satırı
      expect(find.text('Güvence kasası'), findsOneWidget);
      expect(find.text('Usta'), findsOneWidget);
      expect(find.text('Sandbox (test)'), findsOneWidget);
      expect(find.text('Otomatik aktarıma kalan süre'), findsOneWidget);
      expect(find.text('47 sa 12 dk'), findsOneWidget);
      expect(
        find.text(
          '48 saat içinde onaylamazsan tutar ustaya otomatik aktarılır.',
        ),
        findsOneWidget,
      );
      expect(find.text('Ödeme başlatıldı'), findsOneWidget);
      expect(find.text('Tutar güvence kasasına alındı'), findsOneWidget);
      expect(find.text('Ödeme hareketi'), findsOneWidget);
      expect(find.text('MASTERCARD **** **** **** 0001'), findsOneWidget);
      expect(find.text(tr((l) => l.serviceFeeLabel)), findsNothing);
      expect(btn('Makbuzu gör'), findsOneWidget);
    });

    testWidgets('geri sayım bitmişse "işleniyor" yazar', (t) async {
      final at = utc(kNow.subtract(const Duration(minutes: 5)));
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) =>
            json(200, timelineJson(autoReleaseAt: at)),
      });
      expect(find.text('Otomatik aktarım işleniyor.'), findsOneWidget);
    });

    testWidgets('bekleyen aktarım ve destek incelemesi etiketi', (t) async {
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) =>
            json(200, timelineJson(pendingAction: 'RELEASE')),
      });
      expect(find.text('Ustaya aktarım işleniyor'), findsOneWidget);
    });

    testWidgets('serbest bırakılmış: ustada, geri sayım yok', (t) async {
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => json(
          200,
          timelineJson(
            status: 'RELEASED_TO_PRO',
            location: 'PRO',
            events: [
              {
                'type': 'RELEASED_TO_PRO',
                'at': '2026-11-09T09:00:00Z',
                'amount': null,
                'actor': 'SYSTEM',
                'note': null,
              },
            ],
          ),
        ),
      });
      expect(find.text('Ustada'), findsOneWidget);
      expect(find.text('Otomatik aktarıma kalan süre'), findsNothing);
      expect(find.text('Tutar ustaya aktarıldı'), findsOneWidget);
    });

    testWidgets('iade ve bölüşüm metinleri', (t) async {
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => json(
          200,
          timelineJson(
            status: 'SPLIT_SETTLED',
            location: 'SPLIT',
            events: const [],
          ),
        ),
      });
      expect(find.text('Bölüşüldü'), findsOneWidget);
    });

    testWidgets('sandbox değilse rozet yok', (t) async {
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) =>
            json(200, timelineJson(sandbox: false)),
      });
      expect(find.text('Sandbox (test)'), findsNothing);
    });

    testWidgets('EN metinleri', (t) async {
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => json(200, timelineJson()),
      }, locale: 'en');
      expect(find.text('Money journey'), findsOneWidget);
      expect(find.text('In the secure vault'), findsOneWidget);
      expect(find.text('Secure vault'), findsOneWidget);
      expect(find.text('Payment started'), findsOneWidget);
      expect(btn('View receipt'), findsOneWidget);
    });

    testWidgets('hata: tekrar dene yeniden ister', (t) async {
      var calls = 0;
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) {
          calls++;
          return calls == 1
              ? apiError(404, 'NOT_FOUND')
              : json(200, timelineJson());
        },
      });
      expect(find.text('Bir sorun oluştu'), findsOneWidget);
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(find.text('Güvence kasasında'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('yükleniyor göstergesi', (t) async {
      final c = Completer<ResponseBody>();
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/jobs/j1/payment',
        size: tall,
        settle: false,
        handler: server3({'GET /jobs/j1/payment/timeline': (_) => c.future}),
        overrides: _now,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      c.complete(json(200, timelineJson()));
      await t.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('320 px ve 2x yazıda taşma yok', (t) async {
      await open(t, '/c/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => json(
          200,
          timelineJson(autoReleaseAt: utc(kNow.add(const Duration(hours: 5)))),
        ),
      }, textScale: 2);
      expect(t.takeException(), isNull);
    });
  });

  group('Paranın yolculuğu (usta)', () {
    testWidgets('kart yok; hizmet bedeli ve net kazanç; makbuz yok', (t) async {
      await open(t, '/p/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => json(
          200,
          timelineJson(
            pro: true,
            autoReleaseAt: utc(kNow.add(const Duration(hours: 30))),
            events: [
              {
                'type': 'AUTO_RELEASE_SCHEDULED',
                'at': '2026-11-09T09:00:00Z',
                'amount': 1080.0,
                'actor': 'SYSTEM',
                'note': 'autoReleaseAt=2026-11-11T09:00:00Z',
              },
            ],
          ),
        ),
      }, pro: true);
      expect(find.text('Müşterinin kartında'), findsNothing);
      expect(find.text('Güvence kasasında'), findsOneWidget);
      expect(find.text('Müşteri'), findsOneWidget); // 1. düğüm
      expect(find.text('Sen'), findsOneWidget); // 3. düğüm
      expect(find.text(tr((l) => l.serviceFeeLabel)), findsOneWidget);
      expect(find.text(tr((l) => l.netEarningLabel)), findsOneWidget);
      expect(find.text('₺1.080'), findsWidgets);
      expect(find.textContaining('**** **** ****'), findsNothing);
      expect(btn('Makbuzu gör'), findsNothing);
      expect(
        find.text(
          'Müşteri 48 saat içinde onaylamazsa tutar sana otomatik aktarılır.',
        ),
        findsOneWidget,
      );
      expect(find.text('30 sa 0 dk'), findsOneWidget);
    });

    testWidgets('serbest bırakılmış: "Sende"', (t) async {
      await open(t, '/p/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => json(
          200,
          timelineJson(pro: true, status: 'RELEASED_TO_PRO', location: 'PRO'),
        ),
      }, pro: true);
      expect(find.text('Sende'), findsOneWidget);
    });

    testWidgets('hata durumu', (t) async {
      await open(t, '/p/jobs/j1/payment', {
        'GET /jobs/j1/payment/timeline': (_) => apiError(404, 'NOT_FOUND'),
      }, pro: true);
      expect(find.text('Bir sorun oluştu'), findsOneWidget);
    });
  });

  group('Makbuz', () {
    testWidgets('veri: no, kalemler, toplam, maskeli kart, sandbox rozeti', (
      t,
    ) async {
      await open(t, '/c/jobs/j1/receipt', {
        'GET /jobs/j1/payment/receipt': (_) => json(200, receiptJson()),
      });
      expect(find.text('Sandbox (test) ödemesi'), findsOneWidget);
      expect(find.text('BT-20261109-5B0F0A'), findsOneWidget);
      expect(find.text('Test Tesisat'), findsOneWidget);
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('İşçilik'), findsOneWidget);
      expect(find.text('Malzeme'), findsOneWidget);
      expect(find.text('₺900'), findsOneWidget);
      expect(find.text('₺300'), findsOneWidget);
      expect(find.text('₺1.200'), findsOneWidget);
      expect(find.text('MASTERCARD **** **** **** 0001'), findsOneWidget);
      expect(find.text('Güvence kasasında'), findsOneWidget);
      // Komisyon dökümü müşteri makbuzunda yok.
      expect(find.text(tr((l) => l.serviceFeeLabel)), findsNothing);
    });

    testWidgets('iade varsa net ödenen görünür; sandbox değilse rozet yok', (
      t,
    ) async {
      await open(t, '/c/jobs/j1/receipt', {
        'GET /jobs/j1/payment/receipt': (_) =>
            json(200, receiptJson(sandbox: false, refunded: 600)),
      });
      expect(find.text('Sandbox (test) ödemesi'), findsNothing);
      expect(find.text('Net ödenen'), findsOneWidget);
      expect(find.text('₺600'), findsWidgets);
    });

    testWidgets('EN', (t) async {
      await open(t, '/c/jobs/j1/receipt', {
        'GET /jobs/j1/payment/receipt': (_) => json(200, receiptJson()),
      }, locale: 'en');
      expect(find.text('Sandbox (test) payment'), findsOneWidget);
      expect(find.text('Receipt no.'), findsOneWidget);
      expect(find.text('Labour'), findsOneWidget);
    });

    testWidgets('hata: 403 yetki mesajı ve tekrar dene', (t) async {
      await open(t, '/c/jobs/j1/receipt', {
        'GET /jobs/j1/payment/receipt': (_) => apiError(403, 'FORBIDDEN'),
      });
      expect(find.text('Bir sorun oluştu'), findsOneWidget);
      expect(find.text('Bu işlem için yetkin yok.'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
    });

    testWidgets('"Paranın yolculuğu" düğmesi zaman çizelgesini açar', (
      t,
    ) async {
      final h = await open(t, '/c/jobs/j1/receipt', {
        'GET /jobs/j1/payment/receipt': (_) => json(200, receiptJson()),
        'GET /jobs/j1/payment/timeline': (_) => json(200, timelineJson()),
      });
      await t.tap(btn('Paranın yolculuğu'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1/payment');
    });
  });

  group('Ödemelerim', () {
    Routes history(List<Map<String, dynamic>> items, {String? next}) => {
      'GET /me/payments': (_) =>
          json(200, {'items': items, 'nextCursor': next}),
    };

    testWidgets('veri: tutar, iş, durum çipi, para nerede', (t) async {
      await open(
        t,
        '/c/payments',
        history([
          historyItem('A1'),
          historyItem(
            'A2',
            status: 'SPLIT_SETTLED',
            location: 'SPLIT',
            refunded: 600,
          ),
        ]),
      );
      expect(find.text('Ödemelerim'), findsOneWidget);
      expect(find.text('İş A1'), findsOneWidget);
      expect(find.text('₺1.200'), findsNWidgets(2));
      expect(find.text('Para: Güvence kasasında'), findsOneWidget);
      expect(find.text('Para: Bölüşüldü'), findsOneWidget);
      expect(find.text('İade edilen: ₺600'), findsOneWidget);
      expect(find.text('Sandbox (test)'), findsNWidgets(2));
      expect(find.text('Daha fazla göster'), findsNothing);
    });

    testWidgets('satıra dokununca zaman çizelgesi açılır', (t) async {
      final h = await open(t, '/c/payments', {
        ...history([historyItem('A1')]),
        'GET /jobs/j1/payment/timeline': (_) => json(200, timelineJson()),
      });
      await t.tap(find.text('İş A1'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1/payment');
      expect(find.text('Paranın yolculuğu'), findsOneWidget);
    });

    testWidgets('işi olmayan ödeme sonuç ekranına gider', (t) async {
      final h = await open(t, '/c/payments', {
        ...history([historyItem('A9', jobId: null)]),
        'GET /payments/A9': (_) =>
            json(200, paymentJson(ref: 'A9', jobId: null)),
      });
      await t.tap(find.text('İş A9'));
      await t.pumpAndSettle();
      expect(h.location, '/c/payments/A9/result');
    });

    testWidgets('boş durum', (t) async {
      await open(t, '/c/payments', history([]));
      expect(find.text('Henüz ödemen yok'), findsOneWidget);
      expect(find.text('Taleplerime git'), findsOneWidget);
    });

    testWidgets('hata ve tekrar dene', (t) async {
      var calls = 0;
      await open(t, '/c/payments', {
        'GET /me/payments': (_) {
          calls++;
          return calls == 1
              ? apiError(500, 'INTERNAL_ERROR')
              : json(200, {
                  'items': [historyItem('A1')],
                  'nextCursor': null,
                });
        },
      });
      expect(find.text('Bir sorun oluştu'), findsOneWidget);
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(find.text('İş A1'), findsOneWidget);
    });

    testWidgets('yükleniyor', (t) async {
      final c = Completer<ResponseBody>();
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/payments',
        size: tall,
        settle: false,
        handler: server3({'GET /me/payments': (_) => c.future}),
        overrides: _now,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      c.complete(json(200, {'items': <Object>[], 'nextCursor': null}));
      await t.pumpAndSettle();
    });

    testWidgets('sayfalama: daha fazla göster imleçle ikinci sayfayı ekler', (
      t,
    ) async {
      final h = await open(t, '/c/payments', {
        'GET /me/payments': (o) {
          final cursor = o.queryParameters['cursor'];
          return cursor == null
              ? json(200, {
                  'items': [historyItem('A1')],
                  'nextCursor': 'c2',
                })
              : json(200, {
                  'items': [historyItem('A2')],
                  'nextCursor': null,
                });
        },
      });
      expect(find.text('İş A1'), findsOneWidget);
      expect(find.text('İş A2'), findsNothing);
      await t.tap(find.text('Daha fazla göster'));
      await t.pumpAndSettle();
      expect(find.text('İş A1'), findsOneWidget);
      expect(find.text('İş A2'), findsOneWidget);
      expect(find.text('Daha fazla göster'), findsNothing);
      expect(h.adapter.requests.last.queryParameters['cursor'], 'c2');
    });

    testWidgets('sonraki sayfa hatasında liste korunur', (t) async {
      await open(t, '/c/payments', {
        'GET /me/payments': (o) => o.queryParameters['cursor'] == null
            ? json(200, {
                'items': [historyItem('A1')],
                'nextCursor': 'c2',
              })
            : apiError(500, 'INTERNAL_ERROR'),
      });
      await t.tap(find.text('Daha fazla göster'));
      await t.pumpAndSettle();
      expect(find.text('İş A1'), findsOneWidget);
      expect(
        find.text('Daha fazlası yüklenemedi. Tekrar dene.'),
        findsOneWidget,
      );
    });

    testWidgets('profil sekmesinde giriş var ve açar', (t) async {
      final h = await open(t, '/c/profile', history([historyItem('A1')]));
      await t.tap(find.text('Ödemelerim'));
      await t.pumpAndSettle();
      expect(h.location, '/c/payments');
      expect(find.text('İş A1'), findsOneWidget);
    });

    testWidgets('EN', (t) async {
      await open(t, '/c/payments', history([historyItem('A1')]), locale: 'en');
      expect(find.text('My payments'), findsOneWidget);
      expect(find.text('Money: In the secure vault'), findsOneWidget);
    });
  });

  group('İş detayı ve ödeme sonucu', () {
    testWidgets('müşteri iş detayı: yolculuk kartı ve makbuz düğmesi', (
      t,
    ) async {
      final h = await open(t, '/c/jobs/j1', {
        'GET /jobs/j1': (_) => json(200, jobDetailJson()),
        'GET /jobs/j1/payment/timeline': (_) => json(200, timelineJson()),
        'GET /jobs/j1/payment/receipt': (_) => json(200, receiptJson()),
      });
      await t.scrollUntilVisible(
        find.text('Paranın yolculuğu'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Para şu an: Güvence kasasında'), findsOneWidget);
      await t.scrollUntilVisible(
        btn('Makbuzu gör'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(btn('Makbuzu gör'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1/receipt');
    });

    testWidgets('yolculuk verisi gelmese bile iş detayı çalışır', (t) async {
      await open(t, '/c/jobs/j1', {
        'GET /jobs/j1': (_) => json(200, jobDetailJson()),
      });
      expect(find.text('Mutfak musluğu damlıyor'), findsOneWidget);
      expect(find.text('Paranın yolculuğu'), findsOneWidget);
    });

    testWidgets('usta iş detayı: yolculuk kartı var, makbuz yok', (t) async {
      await open(t, '/p/jobs/j1', {
        'GET /jobs/j1': (_) => json(200, jobDetailJson(role: 'PRO')),
        'GET /jobs/j1/payment/timeline': (_) =>
            json(200, timelineJson(pro: true)),
      }, pro: true);
      await t.scrollUntilVisible(
        find.text('Paranın yolculuğu'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Para şu an: Güvence kasasında'), findsOneWidget);
      expect(btn('Makbuzu gör'), findsNothing);
    });

    testWidgets('ödeme başarı ekranı: makbuz ve yolculuk düğmeleri', (t) async {
      final h = await open(t, '/c/payments/ESC-1/result', {
        'GET /payments/ESC-1': (_) =>
            json(200, paymentJson(status: 'RELEASED_TO_PRO')),
        'GET /jobs/j1': (_) => json(200, jobDetailJson(status: 'COMPLETED')),
      });
      // RELEASED_TO_PRO işe yönlendirir; başarı ekranı LOCKED + işsiz durumda
      // kalır, makbuz düğmesi ise işi olan ödemede: yönlendirme sonrası iş
      // ekranındaki kart sağlar.
      expect(h.location, '/c/jobs/j1');
      expect(find.text('Paranın yolculuğu'), findsOneWidget);
    });
  });

  group('Rota korumaları', () {
    test('usta modunda müşteri yolculuk rotası usta rotasına döner', () {
      expect(
        guardRedirect(proSession3(), Uri.parse('/c/jobs/j1/payment')),
        '/p/jobs/j1/payment',
      );
    });

    test('müşteri modunda onaylı ustanın usta rotası müşteriye döner', () {
      final s = SessionState.signedIn(
        testMe(proStatus: 'APPROVED', lastMode: UserMode.customer),
      );
      expect(
        guardRedirect(s, Uri.parse('/p/jobs/j1/payment')),
        '/c/jobs/j1/payment',
      );
    });

    test('yeni rotalar bilinen yol; oturumsuz giriş sayfasına gider', () {
      for (final p in [
        '/c/payments',
        '/c/jobs/j1/payment',
        '/c/jobs/j1/receipt',
        '/p/jobs/j1/payment',
      ]) {
        expect(isKnownPath(p), isTrue, reason: p);
      }
      final signedOut = SessionState.signedOut();
      expect(
        guardRedirect(signedOut, Uri.parse('/c/payments')),
        startsWith('/welcome'),
      );
    });

    test('müşteri için yeni rotalar olduğu gibi açılır', () {
      for (final p in [
        '/c/payments',
        '/c/jobs/j1/payment',
        '/c/jobs/j1/receipt',
      ]) {
        expect(
          guardRedirect(customerSession(), Uri.parse(p)),
          isNull,
          reason: p,
        );
      }
    });
  });

  group('Kazançlar', () {
    testWidgets('satırdan paranın yolculuğu açılır', (t) async {
      final h = await open(t, '/p/earnings', {
        'GET /pro/earnings': (_) => json(200, {
          'releasedTotal': 1080.0,
          'pendingTotal': 0.0,
          'serviceFeeTotal': 120.0,
          'items': [
            {
              'jobId': 'j1',
              'publicCode': 'BD-88421',
              'title': 'Banyo lavabo altı su kaçağı',
              'date': '2026-11-09T09:00:00Z',
              'totalAmount': 1200.0,
              'serviceFee': 120.0,
              'netEarning': 1080.0,
              'status': 'RELEASED',
            },
          ],
        }),
        'GET /jobs/j1/payment/timeline': (_) =>
            json(200, timelineJson(pro: true)),
      }, pro: true);
      expect(find.text('Paranın yolculuğu'), findsOneWidget);
      await t.tap(find.text('Paranın yolculuğu'));
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs/j1/payment');
    });
  });

  testWidgets('MoneyFlowDiagram her para yeri için çizilir', (t) async {
    for (final loc in MoneyLocation.values) {
      for (final pro in [false, true]) {
        await t.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('tr'),
            home: Scaffold(
              body: MoneyFlowDiagram(location: loc, pro: pro),
            ),
          ),
        );
        expect(find.byType(MoneyFlowDiagram), findsOneWidget);
        expect(t.takeException(), isNull);
      }
    }
  });
}
