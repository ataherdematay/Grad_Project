import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

Map<String, dynamic> _item({
  String ref = 'ESC-9',
  String code = 'REFUND_NEEDS_REVIEW',
  String pending = 'REFUND',
}) => {
  'ref': ref,
  'jobId': 'j9',
  'jobPublicCode': 'BD-10009',
  'jobStatus': 'CANCELLED',
  'status': 'LOCKED',
  'errorCode': code,
  'pendingAction': pending,
  'totalAmount': 1200.0,
  'refundedAmount': 0,
  'customerName': 'Ali Yılmaz',
  'proBusinessName': 'Mavi Hat',
  'attempts': 8,
  'lastAttemptAt': '2026-11-10T10:00:00Z',
  'createdAt': '2026-11-09T10:00:00Z',
};

Map<String, dynamic> _check(
  List<String> allowed, {
  String state = 'FULLY_REFUNDED',
}) => {
  'payment': _item(),
  'gatewayRefundState': state,
  'gatewayRefundedTotal': state == 'FULLY_REFUNDED' ? 1200.0 : 0,
  'allowedResolutions': allowed,
};

void main() {
  group('İncelemedeki ödemeler', () {
    testWidgets('liste, Craftgate kontrolü, not zorunlu, çözüm isteği', (
      tester,
    ) async {
      var resolved = false;
      final fake = FakeApi()
        ..on(
          'GET',
          '/admin/payments/review',
          (_) => json(200, {
            'items': resolved ? <Object>[] : [_item()],
          }),
        )
        ..onJson(
          'GET',
          '/admin/payments/ESC-9/review',
          _check(['MARK_REFUNDED']),
        )
        ..on('POST', '/admin/payments/ESC-9/resolve', (_) {
          resolved = true;
          return json(200, _check(const []));
        });
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      expect(find.text('İncelemedeki ödemeler'), findsOneWidget);
      expect(find.text('BD-10009'), findsOneWidget);
      expect(find.text('İade incelemede'), findsOneWidget);

      await tester.tap(find.text('Craftgate\'e sor ve çöz'));
      await tester.pumpAndSettle();
      expect(fake.count('GET', '/admin/payments/ESC-9/review'), 1);
      expect(find.textContaining('tam iade edilmiş'), findsOneWidget);
      // Tek izinli çözüm hazır seçili; not kısa iken istek gitmez.
      await tester.enterText(find.byType(TextFormField), 'kısa');
      await tester.tap(find.widgetWithText(FilledButton, 'Çöz'));
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/payments/ESC-9/resolve'), 0);

      await tester.enterText(
        find.byType(TextFormField),
        'Craftgate panelinde tam iade görüldü.',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Çöz'));
      await tester.pumpAndSettle();
      expect(fake.last('POST', '/admin/payments/ESC-9/resolve').data, {
        'resolution': 'MARK_REFUNDED',
        'note': 'Craftgate panelinde tam iade görüldü.',
      });
      expect(find.text('Ödeme çözüldü.'), findsOneWidget);
      expect(find.text('İncelemede ödeme yok.'), findsOneWidget);
    });

    testWidgets('birden çok çözümde seçim zorunlu', (tester) async {
      final fake = FakeApi()
        ..onJson('GET', '/admin/payments/review', {
          'items': [_item(code: 'PAYOUT_NEEDS_REVIEW', pending: 'RELEASE')],
        })
        ..onJson(
          'GET',
          '/admin/payments/ESC-9/review',
          _check(['RETRY_REFUND', 'RELEASE'], state: 'NOT_REFUNDED'),
        )
        ..onJson('POST', '/admin/payments/ESC-9/resolve', _check(const []));
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      expect(find.text('Aktarım incelemede'), findsOneWidget);
      await tester.tap(find.text('Craftgate\'e sor ve çöz'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'Craftgate panelinde iade yok.',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Çöz'));
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/payments/ESC-9/resolve'), 0);
      expect(find.text('Bir çözüm seç.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('resolution-release')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Çöz'));
      await tester.pumpAndSettle();
      expect(
        (fake.last('POST', '/admin/payments/ESC-9/resolve').data
            as Map)['resolution'],
        'RELEASE',
      );
    });

    testWidgets('izinli çözüm yoksa açıklanır, istek gitmez', (tester) async {
      final fake = FakeApi()
        ..onJson('GET', '/admin/payments/review', {
          'items': [_item()],
        })
        ..onJson(
          'GET',
          '/admin/payments/ESC-9/review',
          _check(const [], state: 'REFUND_PENDING'),
        );
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      await tester.tap(find.text('Craftgate\'e sor ve çöz'));
      await tester.pumpAndSettle();
      expect(find.text('Şu an çözülemez'), findsOneWidget);
      expect(find.textContaining('iade sonucu bekleniyor'), findsOneWidget);
      expect(fake.count('POST', '/admin/payments/ESC-9/resolve'), 0);
    });

    testWidgets('durum değiştiyse (409) liste yenilenir', (tester) async {
      final fake = FakeApi()
        ..onJson('GET', '/admin/payments/review', {
          'items': [_item()],
        })
        ..onJson(
          'GET',
          '/admin/payments/ESC-9/review',
          _check(['MARK_REFUNDED']),
        )
        ..on(
          'POST',
          '/admin/payments/ESC-9/resolve',
          (_) => apiError(409, 'ILLEGAL_STATE'),
        );
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      final before = fake.count('GET', '/admin/payments/review');
      await tester.tap(find.text('Craftgate\'e sor ve çöz'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        'Craftgate panelinde tam iade görüldü.',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Çöz'));
      await tester.pumpAndSettle();
      expect(fake.count('GET', '/admin/payments/review'), before + 1);
      expect(
        find.text(
          'Kayıt bu arada değişti, bu işlem artık yapılamıyor. Ekranı güncelledik.',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('hesaplar: ilçe süzgeci sunucuya gider', (tester) async {
    final fake = FakeApi();
    await pumpAdmin(tester, fake: fake, initial: '/accounts');
    await tester.tap(find.byKey(const Key('district-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kadıköy').last);
    await tester.pumpAndSettle();
    expect(fake.last('GET', '/admin/users').queryParameters, {
      'district': '23',
    });
  });
}
