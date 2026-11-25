import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _tall = Size(1280, 2800);

String _text(WidgetTester tester, String key) =>
    (tester.widget(find.byKey(Key(key))) as Text).data!;

Future<void> _openRow(WidgetTester tester, String ref) async {
  await tester.tap(find.byKey(Key('payment-$ref')));
  await tester.pumpAndSettle();
}

void main() {
  group('Kasa özeti', () {
    testWidgets('dört kart tutarları ve adetleri gösterir', (tester) async {
      await pumpAdmin(tester, initial: '/payments', size: _tall);
      expect(_text(tester, 'vault-pending'), '₺400');
      expect(_text(tester, 'vault-paid'), '₺1.080');
      expect(_text(tester, 'vault-refunded'), '₺600');
      expect(_text(tester, 'vault-commission'), '₺120');
      expect(find.text('Toplam ödeme: 3'), findsOneWidget);
      expect(find.text('Havuzda: 1'), findsOneWidget);
      expect(find.text('Kilitli: 1'), findsOneWidget);
      expect(find.text('Güvence havuzunda bekleyen'), findsOneWidget);
    });

    testWidgets('İngilizce etiketler', (tester) async {
      await pumpAdmin(tester, initial: '/payments', size: _tall, locale: 'en');
      expect(find.text('Waiting in secure hold'), findsOneWidget);
      expect(find.text('Total payments: 3'), findsOneWidget);
    });

    testWidgets('Yenile düğmesi özeti yeniden ister', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      expect(fake.count('GET', '/admin/payments/summary'), 1);
      await tester.tap(find.byKey(const Key('vault-refresh')));
      await tester.pumpAndSettle();
      expect(fake.count('GET', '/admin/payments/summary'), 2);
    });

    testWidgets('hata: mesaj ve Tekrar dene', (tester) async {
      final fake = FakeApi();
      fake.on(
        'GET',
        '/admin/payments/summary',
        (_) => apiError(500, 'INTERNAL'),
      );
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      expect(find.text('Tekrar dene'), findsWidgets);
      fake.onJson('GET', '/admin/payments/summary', vaultSummaryJson());
      await tester.tap(find.text('Tekrar dene').first);
      await tester.pumpAndSettle();
      expect(_text(tester, 'vault-pending'), '₺400');
    });

    testWidgets('boş kasa sıfır gösterir', (tester) async {
      final fake = FakeApi();
      fake.onJson('GET', '/admin/payments/summary', {
        'vaultTotal': 0,
        'paidToProsTotal': 0,
        'refundedToCustomersTotal': 0,
        'commissionEarnedTotal': 0,
        'counts': {'total': 0},
        'generatedAt': null,
      });
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      expect(_text(tester, 'vault-pending'), '₺0');
      expect(find.text('Toplam ödeme: 0'), findsOneWidget);
    });
  });

  group('Ödeme zaman çizelgesi paneli', () {
    testWidgets('satıra tıklayınca panel açılır: olaylar, tutarlar, kart', (
      tester,
    ) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1001');
      expect(fake.count('GET', '/admin/payments/PAY-1001/timeline'), 1);
      expect(find.byKey(const Key('timeline-panel')), findsOneWidget);
      expect(_text(tester, 'amount-gross'), '₺2.200');
      expect(_text(tester, 'amount-commission'), '₺220');
      expect(_text(tester, 'amount-pro-net'), '₺1.980');
      expect(_text(tester, 'amount-refunded'), '₺0');
      expect(_text(tester, 'craftgate-id'), '50001');
      expect(_text(tester, 'card'), 'MASTERCARD **** **** **** 0001');
      expect(_text(tester, 'auto-release').startsWith('13 Kasım'), isTrue);
      expect(find.text('Ödeme başlatıldı'), findsOneWidget);
      expect(find.text('Para güvence havuzuna alındı'), findsOneWidget);
      expect(
        find.text('48 saatlik otomatik aktarım planlandı'),
        findsOneWidget,
      );
      expect(find.textContaining('Aktarım zamanı:'), findsOneWidget);
      expect(find.byKey(const Key('sandbox-badge')), findsOneWidget);
    });

    testWidgets('para şu an nerede: havuzda ise aşama 1 vurgulu', (
      tester,
    ) async {
      await pumpAdmin(tester, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1001');
      expect(find.byKey(const Key('stage-1-active')), findsOneWidget);
      expect(find.byKey(const Key('stage-0')), findsOneWidget);
      expect(_text(tester, 'money-where'), 'Güvence havuzunda');
    });

    testWidgets('iade edilmiş ödeme: iade aşaması ve SEED rozeti', (
      tester,
    ) async {
      await pumpAdmin(tester, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1002');
      expect(find.byKey(const Key('stage-2-active')), findsOneWidget);
      expect(_text(tester, 'money-where'), 'Müşteriye iade edildi');
      expect(_text(tester, 'amount-refunded'), '₺2.200');
      // Panelde ve tabloda sağlayıcı rozeti; Craftgate ID yok.
      expect(find.byKey(const Key('provider-badge-SEED')), findsWidgets);
      expect(_text(tester, 'craftgate-id'), '-');
    });

    testWidgets('sağlayıcı rozetleri tabloda CRAFTGATE ve SEED', (
      tester,
    ) async {
      await pumpAdmin(tester, initial: '/payments', size: _tall);
      expect(find.byKey(const Key('provider-badge-CRAFTGATE')), findsOneWidget);
      expect(find.byKey(const Key('provider-badge-SEED')), findsOneWidget);
    });

    testWidgets('DEMO rozeti, kart ve komisyon boş, sandbox kapalı', (
      tester,
    ) async {
      final fake = FakeApi();
      fake.onJson('GET', '/admin/payments/PAY-1001/timeline', {
        ...timelineJson(provider: 'DEMO', sandbox: false, autoReleaseAt: null),
        'card': null,
        'amounts': {
          'gross': 100,
          'commission': null,
          'proNet': null,
          'refunded': 0,
        },
      });
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1001');
      expect(find.byKey(const Key('provider-badge-DEMO')), findsOneWidget);
      expect(find.byKey(const Key('sandbox-badge')), findsNothing);
      expect(_text(tester, 'card'), '-');
      expect(_text(tester, 'amount-commission'), '-');
      expect(_text(tester, 'amount-pro-net'), '-');
      expect(_text(tester, 'auto-release'), '-');
    });

    testWidgets('bilinmeyen olay ve konum çökertmez', (tester) async {
      final fake = FakeApi();
      fake.onJson('GET', '/admin/payments/PAY-1001/timeline', {
        ...timelineJson(location: 'MARS'),
        'events': [
          {
            'type': 'NEW_THING',
            'at': '2026-11-10T09:00:00Z',
            'amount': null,
            'actor': 'ROBOT',
            'note': 'X_CODE',
          },
        ],
      });
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1001');
      expect(find.text('Olay: NEW_THING'), findsOneWidget);
      expect(find.textContaining('ROBOT'), findsOneWidget);
      expect(find.text('X_CODE'), findsOneWidget);
      expect(_text(tester, 'money-where'), 'Bilinmiyor (MARS)');
    });

    testWidgets('olay yoksa boş mesaj', (tester) async {
      final fake = FakeApi();
      fake.onJson('GET', '/admin/payments/PAY-1001/timeline', {
        ...timelineJson(),
        'events': <Object>[],
      });
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1001');
      expect(find.byKey(const Key('timeline-empty')), findsOneWidget);
    });

    testWidgets('hata: Tekrar dene çizelgeyi yeniden yükler', (tester) async {
      final fake = FakeApi();
      fake.on(
        'GET',
        '/admin/payments/PAY-1001/timeline',
        (_) => apiError(404, 'NOT_FOUND'),
      );
      await pumpAdmin(tester, fake: fake, initial: '/payments', size: _tall);
      await _openRow(tester, 'PAY-1001');
      expect(find.byKey(const Key('amount-gross')), findsNothing);
      fake.onJson('GET', '/admin/payments/PAY-1001/timeline', timelineJson());
      final retry = find.descendant(
        of: find.byKey(const Key('timeline-panel')),
        matching: find.text('Tekrar dene'),
      );
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('amount-gross')), findsOneWidget);
    });

    testWidgets('kapat düğmesi paneli kapatır; İngilizce metinler', (
      tester,
    ) async {
      await pumpAdmin(tester, initial: '/payments', size: _tall, locale: 'en');
      await _openRow(tester, 'PAY-1001');
      expect(find.text('Money placed in the secure hold'), findsOneWidget);
      expect(find.text('In the secure hold'), findsOneWidget);
      await tester.tap(find.byKey(const Key('timeline-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('timeline-panel')), findsNothing);
    });

    testWidgets('dar ekranda panel taşmaz', (tester) async {
      await pumpAdmin(
        tester,
        initial: '/payments',
        size: const Size(400, 3600),
      );
      await _openRow(tester, 'PAY-1001');
      expect(find.byKey(const Key('timeline-panel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
