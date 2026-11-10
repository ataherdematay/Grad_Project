import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/features/payment/card_validation.dart';
import 'package:bitadilat_mobile/features/payment/payment_screens.dart';
import 'package:bitadilat_mobile/features/payment/threeds_logic.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

/// Banka WebView'i yerine: HTML'i gösterir, düğmeyle bitiş adresini taklit eder.
Widget fakeBank(BuildContext context, String html, VoidCallback onDone) {
  return Column(
    children: [
      Text('bank:$html'),
      TextButton(
        onPressed: () {
          final d = threeDsNavigationDecision(
            'http://localhost:8090/api/payments/3ds/done?ref=ESC-1',
            onDone,
          );
          expect(d, NavigationDecision.prevent);
        },
        child: const Text('bankadan dön'),
      ),
    ],
  );
}

void main() {
  group('Kart doğrulama', () {
    test('Luhn: test kartı geçer, bozuk numara geçmez', () {
      expect(passesLuhn('5258640000000001'), isTrue);
      expect(passesLuhn('4111111111111111'), isTrue);
      expect(passesLuhn('4111111111111112'), isFalse);
      expect(passesLuhn(''), isFalse);
      expect(passesLuhn('42a'), isFalse);
    });

    test('4\'lü gruplama ve 16 hane sınırı', () {
      expect(formatCardNumber('5258'), '5258');
      expect(formatCardNumber('52586'), '5258 6');
      expect(formatCardNumber('5258640000000001999'), '5258 6400 0000 0001');
      expect(formatCardNumber('5258-6400 0000 0001'), '5258 6400 0000 0001');
    });

    test('son kullanma AA/YY biçimi ve çözümleme', () {
      expect(formatExpiry('0'), '0');
      expect(formatExpiry('074'), '07/4');
      expect(formatExpiry('0744'), '07/44');
      expect(parseExpiry('07/44'), (month: 7, year: 2044));
      expect(parseExpiry('13/44'), isNull);
      expect(parseExpiry('07/4'), isNull);
    });

    test('alan hataları', () {
      final now = DateTime(2026, 11, 10);
      Map<CardField, CardError> v({
        String h = 'Test Kullanici',
        String n = '5258 6400 0000 0001',
        String e = '07/44',
        String c = '000',
      }) => validateCard(holderName: h, number: n, expiry: e, cvc: c, now: now);
      expect(v(), isEmpty);
      expect(v(h: 'Test')[CardField.holderName], CardError.holderInvalid);
      expect(
        v(n: '4111 1111 1111 1112')[CardField.number],
        CardError.numberInvalid,
      );
      expect(v(n: '4111')[CardField.number], CardError.numberInvalid);
      expect(v(e: '1/44')[CardField.expiry], CardError.expiryInvalid);
      expect(v(e: '10/26')[CardField.expiry], CardError.expiryPast);
      expect(v(e: '11/26'), isEmpty);
      expect(v(c: '12')[CardField.cvc], CardError.cvcInvalid);
      expect(v(c: '1234'), isEmpty);
    });

    test('sunucu field değeri alana eşlenir', () {
      expect(cardFieldFromServer('holderName'), CardField.holderName);
      expect(cardFieldFromServer('number'), CardField.number);
      expect(cardFieldFromServer('expiry'), CardField.expiry);
      expect(cardFieldFromServer('cvc'), CardField.cvc);
      expect(cardFieldFromServer('x'), isNull);
      expect(cardFieldFromServer(null), isNull);
    });
  });

  group('3-D Secure gezinme mantığı', () {
    test('bitiş adresi yakalanır', () {
      expect(
        isThreeDsDoneUrl('http://localhost:8090/api/payments/3ds/done?ref=E1'),
        isTrue,
      );
      expect(
        isThreeDsDoneUrl('https://api.bitadilat.example/api/payments/3ds/done'),
        isTrue,
      );
      expect(isThreeDsDoneUrl('https://bank.example/3ds/challenge'), isFalse);
      expect(
        isThreeDsDoneUrl('http://localhost:8090/api/payments/3ds/callback'),
        isFalse,
      );
      expect(isThreeDsDoneUrl('::geçersiz::'), isFalse);
    });

    test('bitişte gezinme engellenir ve geri çağrı bir kez çalışır', () {
      var done = 0;
      final d = threeDsNavigationDecision(
        'http://localhost:8090/api/payments/3ds/done?ref=E1',
        () => done++,
      );
      expect(d, NavigationDecision.prevent);
      expect(done, 1);
      final other = threeDsNavigationDecision(
        'https://bank.example/otp',
        () => done++,
      );
      expect(other, NavigationDecision.navigate);
      expect(done, 1);
    });
  });

  group('Kabul onayı (18)', () {
    testWidgets('döküm, KDV, güvence havuzu ve iptal politikası', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/offers/o1/accept',
        size: tall,
        handler: server3({}),
        overrides: [nowProvider.overrideWithValue(() => kNow)],
      );
      expect(find.text('Toplam tutar (KDV dahil)'), findsOneWidget);
      expect(find.text('₺1.200'), findsWidgets);
      expect(find.text('₺900'), findsOneWidget);
      expect(find.text('₺300'), findsOneWidget);
      expect(find.text('Tutar KDV dahildir.'), findsOneWidget);
      expect(find.text('Ödemen güvence havuzunda tutulur'), findsOneWidget);
      expect(find.text('İptal politikası'), findsOneWidget);
      // Yasak ifadeler yok.
      expect(find.textContaining('garanti'), findsNothing);
      expect(find.textContaining('%100'), findsNothing);
      expect(find.textContaining('escrow'), findsNothing);
      await t.tap(btn('Ödemeye geç, ₺1.200'));
      await t.pumpAndSettle();
      expect(h.location, '/c/offers/o1/pay');
    });

    testWidgets('süresi dolmuş teklif kabul edilemez', (t) async {
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/offers/o1/accept',
        size: tall,
        handler: server3({
          'GET /offers/o1': (_) => json(200, {
            ...pendingOfferJson(),
            'validUntil': '2026-11-09T10:00:00Z',
          }),
        }),
        overrides: [nowProvider.overrideWithValue(() => kNow)],
      );
      expect(find.textContaining('artık kabul edilemiyor'), findsOneWidget);
      expect(t.widget<AppButton>(btn('Ödemeye geç, ₺1.200')).onPressed, isNull);
    });
  });

  group('Kart formu (19)', () {
    Future<Harness> openPay(
      WidgetTester t, {
      Handler? handler,
      List<Override> overrides = const [],
      String locale = 'tr',
    }) => pumpApp(
      t,
      session: customerSession(),
      initial: '/c/offers/o1/pay',
      size: tall,
      locale: locale,
      handler: handler ?? server3({}),
      overrides: [
        nowProvider.overrideWithValue(() => kNow),
        threeDsViewBuilderProvider.overrideWithValue(fakeBank),
        ...overrides,
      ],
    );

    Future<void> fillTest(WidgetTester t) async {
      await t.tap(btn('Test kartını doldur'));
      await t.pumpAndSettle();
    }

    testWidgets('test kartı düğmesi debug derlemesinde görünür ve doldurur', (
      t,
    ) async {
      await openPay(t);
      expect(btn('Test kartını doldur'), findsOneWidget);
      await fillTest(t);
      final fields = t
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields[0].controller!.text, 'Test Kullanici');
      expect(fields[1].controller!.text, '5258 6400 0000 0001');
      expect(fields[2].controller!.text, '07/44');
      expect(fields[3].controller!.text, '000');
    });

    testWidgets('test kartı düğmesi debug dışında görünmez', (t) async {
      await openPay(
        t,
        overrides: [showTestCardProvider.overrideWithValue(false)],
      );
      expect(btn('Test kartını doldur'), findsNothing);
      expect(find.textContaining('5258'), findsNothing);
    });

    testWidgets('boş form: alan hataları, istek gitmez', (t) async {
      final h = await openPay(t);
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(find.text(tr((l) => l.cardErrHolder)), findsOneWidget);
      expect(find.text(tr((l) => l.cardErrNumber)), findsOneWidget);
      expect(find.text(tr((l) => l.cardErrExpiry)), findsOneWidget);
      expect(find.text(tr((l) => l.cardErrCvc)), findsOneWidget);
      expect(h.adapter.count('POST', '/payments/3ds/init'), 0);
    });

    testWidgets('yazarken numara 4\'lü gruplanır, AA/YY biçimlenir', (t) async {
      await openPay(t);
      final f = find.byType(TextFormField);
      await t.enterText(f.at(1), '5258640000000001');
      await t.enterText(f.at(2), '0744');
      await t.pump();
      final fields = t.widgetList<TextFormField>(f).toList();
      expect(fields[1].controller!.text, '5258 6400 0000 0001');
      expect(fields[2].controller!.text, '07/44');
    });

    testWidgets('geçersiz Luhn ve geçmiş tarih yerelde yakalanır', (t) async {
      final h = await openPay(t);
      final f = find.byType(TextFormField);
      await t.enterText(f.at(0), 'Test Kullanici');
      await t.enterText(f.at(1), '4111111111111112');
      await t.enterText(f.at(2), '0126');
      await t.enterText(f.at(3), '000');
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(find.text(tr((l) => l.cardErrNumber)), findsOneWidget);
      expect(find.text(tr((l) => l.cardErrExpiryPast)), findsOneWidget);
      expect(h.adapter.count('POST', '/payments/3ds/init'), 0);
    });

    testWidgets('INVALID_CARD field=number alanın altında, form korunur', (
      t,
    ) async {
      final h = await openPay(
        t,
        handler: server3({
          'POST /payments/3ds/init': (_) =>
              apiError(400, 'INVALID_CARD', field: 'number'),
        }),
      );
      await fillTest(t);
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/payments/3ds/init'), 1);
      expect(find.text(tr((l) => l.cardErrNumber)), findsOneWidget);
      expect(find.text(tr((l) => l.cardErrCvc)), findsNothing);
      final fields = t
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      expect(fields[1].controller!.text, '5258 6400 0000 0001');
      expect(h.location, '/c/offers/o1/pay');
    });

    for (final (field, expected) in [
      ('holderName', (AppLocalizations l) => l.cardErrHolder),
      ('expiry', (AppLocalizations l) => l.cardErrExpiry),
      ('cvc', (AppLocalizations l) => l.cardErrCvc),
    ]) {
      testWidgets('INVALID_CARD field=$field ilgili alanda', (t) async {
        await openPay(
          t,
          handler: server3({
            'POST /payments/3ds/init': (_) =>
                apiError(400, 'INVALID_CARD', field: field),
          }),
        );
        await fillTest(t);
        await t.tap(btn('₺1.200 öde'));
        await t.pumpAndSettle();
        expect(find.text(tr(expected)), findsOneWidget);
      });
    }

    testWidgets('her denemede yeni attemptKey; ağ hatasında form korunur', (
      t,
    ) async {
      var n = 0;
      final h = await openPay(
        t,
        handler: server3({
          'POST /payments/3ds/init': (o) {
            n++;
            if (n == 1) {
              throw DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              );
            }
            return json(200, {
              'ref': 'ESC-1',
              'htmlContent': '<form>3ds</form>',
            });
          },
        }),
      );
      await fillTest(t);
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('İnternet bağlantına ulaşılamıyor'),
        findsOneWidget,
      );
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      final posts = h.adapter.requests
          .where(
            (r) => r.method == 'POST' && r.path.endsWith('/payments/3ds/init'),
          )
          .toList();
      expect(posts, hasLength(2));
      final k1 = (posts[0].data as Map)['attemptKey'];
      final k2 = (posts[1].data as Map)['attemptKey'];
      expect(k1, isNot(k2));
      final body = posts[1].data as Map;
      expect(body['offerId'], 'o1');
      expect(body['cardHolderName'], 'Test Kullanici');
      expect(body['cardNumber'], '5258640000000001');
      expect(body['expireMonth'], '07');
      expect(body['expireYear'], '2044');
      expect(body['cvc'], '000');
      expect(body.containsKey('amount'), isFalse);
      // Banka ekranı açıldı; kart formu yığında değil.
      expect(h.location, '/c/payments/ESC-1/3ds');
      expect(find.text('bank:<form>3ds</form>'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('PAYMENT_DECLINED sonuç ekranına geçer', (t) async {
      final h = await openPay(
        t,
        handler: server3({
          'POST /payments/3ds/init': (_) => json(402, {
            'code': 'PAYMENT_DECLINED',
            'message': 'x',
            'ref': 'ESC-7',
          }),
          'GET /payments/ESC-7': (_) => json(
            200,
            paymentJson(
              ref: 'ESC-7',
              status: 'FAILED',
              jobId: null,
              errorCode: 'PAYMENT_DECLINED',
            ),
          ),
        }),
      );
      await fillTest(t);
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(h.location, '/c/payments/ESC-7/result');
      expect(find.text(tr((l) => l.payFailDeclined)), findsOneWidget);
    });

    testWidgets('DUPLICATE_ATTEMPT ve PAYMENT_IN_PROGRESS mesaj gösterir', (
      t,
    ) async {
      var code = 'DUPLICATE_ATTEMPT';
      await openPay(
        t,
        handler: server3({
          'POST /payments/3ds/init': (_) => apiError(409, code),
        }),
      );
      await fillTest(t);
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(find.text(tr((l) => l.apiErrorDuplicateAttempt)), findsOneWidget);
      code = 'PAYMENT_IN_PROGRESS';
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(find.text(tr((l) => l.apiErrorPaymentInProgress)), findsOneWidget);
    });

    testWidgets('ekrandan çıkınca kart alanları temizlenir', (t) async {
      final h = await openPay(
        t,
        handler: server3({
          'POST /payments/3ds/init': (_) =>
              json(200, {'ref': 'ESC-1', 'htmlContent': '<form/>'}),
        }),
      );
      await fillTest(t);
      final number = t
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList()[1]
          .controller!;
      expect(number.text, isNotEmpty);
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      expect(h.location, '/c/payments/ESC-1/3ds');
      expect(number.text, isEmpty);
    });

    testWidgets('EN metinleri', (t) async {
      await openPay(t, locale: 'en');
      expect(find.text('Fill the test card'), findsOneWidget);
      await t.tap(btn('Pay ₺1,200'));
      await t.pumpAndSettle();
      expect(find.text(en((l) => l.cardErrNumber)), findsOneWidget);
    });
  });

  group('Banka doğrulaması (WebView)', () {
    Future<Harness> openBank(WidgetTester t, {Handler? handler}) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/offers/o1/pay',
        size: tall,
        handler:
            handler ??
            server3({
              'POST /payments/3ds/init': (_) => json(200, {
                'ref': 'ESC-1',
                'htmlContent': '<form>3ds</form>',
              }),
              'GET /payments/ESC-1': (_) => json(
                200,
                paymentJson(
                  status: 'INITIALIZED',
                  jobId: null,
                  uncertain: true,
                ),
              ),
            }),
        overrides: [
          nowProvider.overrideWithValue(() => kNow),
          threeDsViewBuilderProvider.overrideWithValue(fakeBank),
        ],
      );
      await t.tap(btn('Test kartını doldur'));
      await t.pumpAndSettle();
      await t.tap(btn('₺1.200 öde'));
      await t.pumpAndSettle();
      return h;
    }

    testWidgets('bitiş adresi yakalanınca sonuç ekranına gidilir', (t) async {
      final h = await openBank(t);
      expect(h.location, '/c/payments/ESC-1/3ds');
      await t.tap(find.text('bankadan dön'));
      await t.pump(const Duration(milliseconds: 10));
      await t.pump(const Duration(milliseconds: 600));
      expect(h.location, '/c/payments/ESC-1/result');
      expect(find.text('bank:<form>3ds</form>'), findsNothing);
      expect(
        h.adapter.count('GET', '/payments/ESC-1'),
        greaterThanOrEqualTo(1),
      );
      for (var i = 0; i < 40; i++) {
        await t.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('kapat düğmesi onay ister; vazgeçince ekran kalır', (t) async {
      final h = await openBank(t);
      await t.tap(find.byTooltip('Kapat'));
      await t.pumpAndSettle();
      expect(find.text('Doğrulamayı kapatmak istiyor musun?'), findsOneWidget);
      await t.tap(find.text('Doğrulamaya dön'));
      await t.pumpAndSettle();
      expect(h.location, '/c/payments/ESC-1/3ds');
      await t.tap(find.byTooltip('Kapat'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Kapat'));
      await t.pumpAndSettle();
      expect(h.location, '/c/payments/ESC-1/result');
    });

    testWidgets('sistem geri tuşu da onay ister', (t) async {
      final h = await openBank(t);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Doğrulamayı kapatmak istiyor musun?'), findsOneWidget);
      expect(h.location, '/c/payments/ESC-1/3ds');
    });

    testWidgets('htmlContent olmadan (yeniden başlatma) doğrudan sonuç', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/payments/ESC-1/3ds',
        handler: server3({
          'GET /payments/ESC-1': (_) =>
              json(200, paymentJson(status: 'INITIALIZED', jobId: null)),
        }),
      );
      expect(h.location, '/c/payments/ESC-1/result');
    });
  });

  group('Ödeme sonucu (20)', () {
    Future<Harness> openResult(
      WidgetTester t,
      Handler handler, {
      String locale = 'tr',
      bool settle = true,
    }) => pumpApp(
      t,
      session: customerSession(),
      initial: '/c/payments/ESC-1/result',
      handler: handler,
      locale: locale,
      settle: settle,
      overrides: [nowProvider.overrideWithValue(() => kNow)],
    );

    testWidgets('INITIALIZED iken yoklar, LOCKED gelince yığın değişir', (
      t,
    ) async {
      var n = 0;
      final h = await openResult(
        t,
        server3({
          'GET /payments/ESC-1': (_) {
            n++;
            return json(
              200,
              n < 3
                  ? paymentJson(
                      status: 'INITIALIZED',
                      jobId: null,
                      uncertain: true,
                    )
                  : paymentJson(status: 'LOCKED'),
            );
          },
          'GET /jobs/j1': (_) => json(
            200,
            jobDetailJson(
              status: 'AWAITING_APPOINTMENT',
              actions: ['PROPOSE_SLOT'],
            ),
          ),
        }),
        settle: false,
      );
      expect(find.text('Bankadan sonuç bekleniyor'), findsOneWidget);
      expect(h.adapter.count('GET', '/payments/ESC-1'), 1);
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 10));
      expect(h.adapter.count('GET', '/payments/ESC-1'), 2);
      expect(find.text('Bankadan sonuç bekleniyor'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/payments/ESC-1'), 3);
      expect(h.location, '/c/jobs/j1/appointment');
      // Ödeme ekranları yığında değil: geri tuşu işe döner.
      expect(h.router.canPop(), isFalse);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('30 saniye sonra yoklama durur, belirsiz sonuç metni çıkar', (
      t,
    ) async {
      final h = await openResult(
        t,
        server3({
          'GET /payments/ESC-1': (_) => json(
            200,
            paymentJson(status: 'INITIALIZED', jobId: null, uncertain: true),
          ),
        }),
        settle: false,
      );
      for (var i = 0; i < 40; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      await t.pumpAndSettle();
      // İlk istek + her aralık için bir yoklama; toplam bekleme 30 sn.
      expect(
        h.adapter.count('GET', '/payments/ESC-1'),
        1 + kPaymentPollSeconds.length,
      );
      expect(kPaymentPollSeconds.reduce((a, b) => a + b), 30);
      expect(find.text(tr((l) => l.payUncertainTitle)), findsOneWidget);
      expect(find.text(tr((l) => l.payFailUncertain)), findsOneWidget);
      await t.tap(btn('Tekrar kontrol et'));
      await t.pump(const Duration(milliseconds: 10));
      await t.pump(const Duration(milliseconds: 10));
      expect(
        h.adapter.count('GET', '/payments/ESC-1'),
        2 + kPaymentPollSeconds.length,
      );
      // Zamanlayıcıları bitir.
      for (var i = 0; i < 40; i++) {
        await t.pump(const Duration(seconds: 1));
      }
    });

    final cases = <(String, String, String Function(AppLocalizations), String)>[
      (
        'FAILED',
        'PAYMENT_DECLINED',
        (l) => l.payFailDeclined,
        'Ödeme tamamlanamadı',
      ),
      (
        'REFUNDED_TO_CUSTOMER',
        'REQUEST_ALREADY_ASSIGNED',
        (l) => l.payFailAssigned,
        'Ödemen iade edildi',
      ),
      (
        'REFUNDED_TO_CUSTOMER',
        'OFFER_EXPIRED',
        (l) => l.payFailExpired,
        'Ödemen iade edildi',
      ),
      (
        'FAILED',
        'RESULT_UNCERTAIN',
        (l) => l.payFailUncertain,
        'Sonuç henüz belli değil',
      ),
    ];
    for (final (status, code, text, title) in cases) {
      testWidgets('$status / $code için doğru metin', (t) async {
        await openResult(
          t,
          server3({
            'GET /payments/ESC-1': (_) => json(
              200,
              paymentJson(status: status, jobId: null, errorCode: code),
            ),
          }),
        );
        expect(find.text(tr(text)), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        // Sunucunun kendi metni gösterilmez (yerelleştirme bizde).
        expect(find.text('Sunucu metni'), findsNothing);
      });
    }

    testWidgets('errorCode yok ya da bilinmiyor: genel metin', (t) async {
      await openResult(
        t,
        server3({
          'GET /payments/ESC-1': (_) => json(
            200,
            paymentJson(status: 'FAILED', jobId: null, errorCode: 'YENI_KOD'),
          ),
        }),
      );
      expect(find.text(tr((l) => l.payFailGeneric)), findsOneWidget);
    });

    testWidgets('EN hata metinleri', (t) async {
      await openResult(
        t,
        server3({
          'GET /payments/ESC-1': (_) => json(
            200,
            paymentJson(
              status: 'REFUNDED_TO_CUSTOMER',
              jobId: null,
              errorCode: 'OFFER_EXPIRED',
            ),
          ),
        }),
        locale: 'en',
      );
      expect(find.text(en((l) => l.payFailExpired)), findsOneWidget);
      expect(find.text('Try a different card'), findsOneWidget);
    });

    testWidgets('Farklı kartla dene kart formunu açar', (t) async {
      final h = await openResult(
        t,
        server3({
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
      await t.tap(btn('Farklı kartla dene'));
      await t.pumpAndSettle();
      expect(h.location, '/c/offers/o1/pay');
      // Geri: kabul onayı, ödeme sonucuna dönülmez.
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/c/offers/o1/accept');
    });

    testWidgets('Teklife dön teklifi açar', (t) async {
      final h2 = await openResult(
        t,
        server3({
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
      await t.tap(btn('Teklife dön'));
      await t.pumpAndSettle();
      expect(h2.location, '/c/offers/o1');
    });

    testWidgets('ağ hatasında tekrar dene', (t) async {
      var fail = true;
      await openResult(
        t,
        server3({
          'GET /payments/ESC-1': (o) {
            if (fail) {
              throw DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              );
            }
            return json(
              200,
              paymentJson(
                status: 'FAILED',
                jobId: null,
                errorCode: 'PAYMENT_DECLINED',
              ),
            );
          },
        }),
      );
      expect(find.text('Tekrar dene'), findsOneWidget);
      fail = false;
      await t.tap(btn('Tekrar dene'));
      await t.pumpAndSettle();
      expect(find.text(tr((l) => l.payFailDeclined)), findsOneWidget);
    });
  });
}
