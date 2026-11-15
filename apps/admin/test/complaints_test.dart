import 'dart:async';

import 'package:bitadilat_admin/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

Future<Harness> openComplaint(
  WidgetTester tester,
  FakeApi fake, {
  String path = '/complaints/c1',
}) async {
  final h = await pumpAdmin(tester, fake: fake, initial: path);
  return h;
}

Finder _outcome(String decision, String part) =>
    find.byKey(Key('outcome-$decision-$part'));

Future<void> _tapScrolled(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
}

String _text(WidgetTester tester, Finder f) =>
    tester.widget<Text>(f).data ?? '';

void main() {
  group('Şikayet listesi', () {
    testWidgets('varsayılan: durum parametresi yok; kayıt ve durum etiketi', (
      tester,
    ) async {
      final fake = FakeApi();
      final h = await pumpAdmin(tester, fake: fake, initial: '/complaints');
      expect(fake.last('GET', '/admin/complaints').queryParameters, isEmpty);
      expect(find.text('SK-1001'), findsOneWidget);
      expect(find.text('BD-88409'), findsOneWidget);
      expect(find.text('Mavi Hat'), findsOneWidget);
      expect(find.text('₺2.200'), findsOneWidget);
      expect(find.text('Açık'), findsWidgets);

      await tester.tap(find.byKey(const Key('complaint-c1')));
      await tester.pumpAndSettle();
      expect(h.location, '/complaints/c1');
    });

    testWidgets('durum süzgeci', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/complaints');
      await tester.tap(find.widgetWithText(ChoiceChip, 'İncelemede'));
      await tester.pumpAndSettle();
      expect(fake.last('GET', '/admin/complaints').queryParameters, {
        'status': 'IN_REVIEW',
      });
      await tester.tap(find.widgetWithText(ChoiceChip, 'Açık ve incelemede'));
      await tester.pumpAndSettle();
      expect(fake.last('GET', '/admin/complaints').queryParameters, isEmpty);
    });

    testWidgets('boş ve hata durumları', (tester) async {
      var fail = true;
      final fake = FakeApi()
        ..on('GET', '/admin/complaints', (_) {
          if (fail) return apiError(500, 'INTERNAL_ERROR');
          return json(200, {'items': []});
        });
      await pumpAdmin(tester, fake: fake, initial: '/complaints');
      expect(find.text('Liste yüklenemedi'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.text('Bu durumda şikayet yok'), findsOneWidget);
    });
  });

  group('Şikayet detayı', () {
    testWidgets('şikayet, zaman çizelgesi, sohbet, ödeme ve taraflar', (
      tester,
    ) async {
      await openComplaint(tester, FakeApi());
      expect(find.text('Şikayet SK-1001'), findsOneWidget);
      expect(
        find.text('İş yarım bırakıldı, usta geri dönmedi.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('evidence-e1')), findsOneWidget);
      // Zaman çizelgesi
      expect(find.byKey(const Key('event-1')), findsOneWidget);
      expect(find.text('Randevu onaylandı → Usta adreste'), findsOneWidget);
      expect(find.text('Parça eksik, yarın tamamlarım.'), findsOneWidget);
      // Sohbet
      expect(find.text('Ne zaman geleceksin?'), findsOneWidget);
      expect(find.text('Yarın sabah geliyorum.'), findsOneWidget);
      // Ödeme özeti
      expect(find.text('PAY-1001'), findsOneWidget);
      expect(find.text('CRAFTGATE'), findsOneWidget);
      expect(find.text('₺2.200'), findsOneWidget);
      expect(find.text('₺1.980'), findsOneWidget);
      expect(find.text('₺220'), findsOneWidget);
      // Taraflar: ustanın uyarı ve iptal sayıları
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('pro-warnings'))).data,
        '2',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('pro-cancellations'))).data,
        '3',
      );
    });

    testWidgets('incelemeye al', (tester) async {
      final fake = FakeApi()
        ..onJson(
          'POST',
          '/admin/complaints/c1/review',
          complaintDetailJson(status: 'IN_REVIEW'),
        );
      await openComplaint(tester, fake);

      await tester.tap(find.byKey(const Key('review-complaint')));
      await tester.pumpAndSettle();
      expect(find.text('Şikayeti incelemeye al'), findsOneWidget);
      fake.onJson(
        'GET',
        '/admin/complaints/c1',
        complaintDetailJson(status: 'IN_REVIEW'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'İncelemeye al').last);
      await tester.pumpAndSettle();

      expect(fake.count('POST', '/admin/complaints/c1/review'), 1);
      expect(find.text('Şikayet incelemeye alındı.'), findsOneWidget);
      // İncelemedeyken tekrar "incelemeye al" yok, "karar ver" var.
      expect(find.byKey(const Key('review-complaint')), findsNothing);
      expect(find.byKey(const Key('decide-complaint')), findsOneWidget);
    });

    testWidgets('karar verilmiş şikayette sonuç gösterilir, eylem yok', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson(
          'GET',
          '/admin/complaints/c1',
          complaintDetailJson(
            status: 'RESOLVED',
            decision: 'SPLIT_50_50',
            decisionNote: 'İki taraf da kısmen haklı.',
          ),
        );
      await openComplaint(tester, fake);
      expect(find.text('Verilen karar'), findsOneWidget);
      expect(find.text('%50 / %50'), findsOneWidget);
      expect(find.text('İki taraf da kısmen haklı.'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('result-refund'))).data,
        '₺1.100',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('result-pro'))).data,
        '₺1.100',
      );
      expect(find.byKey(const Key('decide-complaint')), findsNothing);
    });

    testWidgets('/complaints/:id/decision rotası diyaloğu açar', (
      tester,
    ) async {
      await openComplaint(tester, FakeApi(), path: '/complaints/c1/decision');
      expect(find.byKey(const Key('decision-dialog')), findsOneWidget);
    });
  });

  group('Karar diyaloğu', () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('decide-complaint')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('decision-dialog')), findsOneWidget);
    }

    testWidgets('₺2.200 için üç seçeneğin gerçek tutarları', (tester) async {
      await openComplaint(tester, FakeApi());
      await openDialog(tester);

      // Tam iade: müşteriye 2.200, usta 0, bedel 0.
      expect(_text(tester, _outcome('fullRefund', 'refund')), '₺2.200');
      expect(_text(tester, _outcome('fullRefund', 'payout')), '₺0');
      expect(_text(tester, _outcome('fullRefund', 'fee')), '₺0');
      // %50 / %50: 1.100 + 1.100, bedel yok.
      expect(_text(tester, _outcome('split5050', 'refund')), '₺1.100');
      expect(_text(tester, _outcome('split5050', 'payout')), '₺1.100');
      expect(_text(tester, _outcome('split5050', 'fee')), '₺0');
      // Ustaya aktar: usta 1.980, bedel 220, müşteri 0.
      expect(_text(tester, _outcome('releaseToPro', 'refund')), '₺0');
      expect(_text(tester, _outcome('releaseToPro', 'payout')), '₺1.980');
      expect(_text(tester, _outcome('releaseToPro', 'fee')), '₺220');
    });

    testWidgets('tutarlar EN dilinde ₺2,200 biçiminde', (tester) async {
      await openComplaint(tester, FakeApi());
      // Dili değiştir.
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('decide-complaint')));
      await tester.pumpAndSettle();
      expect(_text(tester, _outcome('fullRefund', 'refund')), '₺2,200');
      expect(_text(tester, _outcome('releaseToPro', 'payout')), '₺1,980');
      expect(find.text('Full refund'), findsOneWidget);
    });

    testWidgets('kuruşlu tutar toplamı korur', (tester) async {
      final detail = complaintDetailJson();
      (detail['payment'] as Map<String, dynamic>)['totalAmount'] = 1225.5;
      final fake = FakeApi()..onJson('GET', '/admin/complaints/c1', detail);
      await openComplaint(tester, fake);
      await openDialog(tester);
      expect(_text(tester, _outcome('fullRefund', 'refund')), '₺1.225,50');
      expect(_text(tester, _outcome('split5050', 'refund')), '₺612,75');
      expect(_text(tester, _outcome('split5050', 'payout')), '₺612,75');
      expect(_text(tester, _outcome('releaseToPro', 'fee')), '₺122,55');
      expect(_text(tester, _outcome('releaseToPro', 'payout')), '₺1.102,95');
    });

    testWidgets('karar ve not zorunlu; istek gitmez', (tester) async {
      final fake = FakeApi();
      await openComplaint(tester, fake);
      await openDialog(tester);

      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Bir karar seç.'), findsOneWidget);
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('decision-fullRefund')));
      await tester.enterText(find.byType(TextFormField), 'kısa');
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);
      expect(fake.count('POST', '/admin/complaints/c1/decision'), 0);
      // Onay diyaloğu açılmadı.
      expect(find.text('Kararı kesinleştir'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'c' * 2001);
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Not en fazla 2000 karakter olabilir.'), findsOneWidget);
    });

    testWidgets('kesinleştirme onayı geri alınamazlığı yazar; vazgeçilebilir', (
      tester,
    ) async {
      final fake = FakeApi();
      await openComplaint(tester, fake);
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('decision-releaseToPro')));
      await tester.enterText(find.byType(TextFormField), 'Şikayet dayanaksız.');
      await _tapScrolled(tester, find.byKey(const Key('suspend-pro')));
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();

      expect(
        find.text('Kararı kesinleştir'),
        findsNWidgets(2),
      ); // başlık + düğme
      expect(find.textContaining('geri alınamaz'), findsOneWidget);
      expect(find.textContaining('Müşteriye iade: ₺0'), findsOneWidget);
      expect(find.textContaining('Ustaya ödeme: ₺1.980'), findsOneWidget);
      expect(find.textContaining('Hizmet bedeli: ₺220'), findsOneWidget);
      expect(find.textContaining('askıya alınacak'), findsOneWidget);
      expect(find.textContaining('uyarı kaydı'), findsNothing);

      // Geri dön: istek yok.
      await tester.tap(find.text('Geri'));
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/complaints/c1/decision'), 0);
      expect(find.byKey(const Key('decision-dialog')), findsOneWidget);
    });

    testWidgets('karar gövdesi: karar, not, uyarı ve askı kutuları', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson(
          'POST',
          '/admin/complaints/c1/decision',
          complaintDetailJson(
            status: 'RESOLVED',
            decision: 'SPLIT_50_50',
            decisionNote: 'Her iki taraf da kısmen haklı.',
          ),
        );
      await openComplaint(tester, fake);
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('decision-split5050')));
      await tester.enterText(
        find.byType(TextFormField),
        'Her iki taraf da kısmen haklı.',
      );
      await _tapScrolled(tester, find.byKey(const Key('warn-pro')));
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      fake.onJson(
        'GET',
        '/admin/complaints/c1',
        complaintDetailJson(
          status: 'RESOLVED',
          decision: 'SPLIT_50_50',
          decisionNote: 'Her iki taraf da kısmen haklı.',
        ),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Kararı kesinleştir'));
      await tester.pumpAndSettle();

      expect(fake.last('POST', '/admin/complaints/c1/decision').data, {
        'decision': 'SPLIT_50_50',
        'note': 'Her iki taraf da kısmen haklı.',
        'warnPro': true,
        'suspendPro': false,
      });
      expect(
        find.text('Karar verildi, iki taraf bilgilendirildi.'),
        findsOneWidget,
      );
      expect(find.text('Verilen karar'), findsOneWidget);
    });

    testWidgets('ILLEGAL_STATE: diyalog kapanır, ekran yenilenir', (
      tester,
    ) async {
      final fake = FakeApi()
        ..on(
          'POST',
          '/admin/complaints/c1/decision',
          (_) => apiError(409, 'ILLEGAL_STATE'),
        );
      await openComplaint(tester, fake);
      await openDialog(tester);
      fake.onJson(
        'GET',
        '/admin/complaints/c1',
        complaintDetailJson(status: 'RESOLVED', decision: 'FULL_REFUND'),
      );
      await tester.tap(find.byKey(const Key('decision-fullRefund')));
      await tester.enterText(find.byType(TextFormField), 'Usta hiç gelmedi.');
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Kararı kesinleştir'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('decision-dialog')), findsNothing);
      expect(find.textContaining('Kayıt bu arada değişti'), findsOneWidget);
      expect(find.text('Verilen karar'), findsOneWidget);
      expect(fake.count('GET', '/admin/complaints/c1'), 2);
    });

    testWidgets('GATEWAY_ERROR: diyalog açık kalır, hiçbir şey değişmedi', (
      tester,
    ) async {
      final fake = FakeApi()
        ..on(
          'POST',
          '/admin/complaints/c1/decision',
          (_) => apiError(502, 'GATEWAY_ERROR'),
        );
      await openComplaint(tester, fake);
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('decision-fullRefund')));
      await tester.enterText(find.byType(TextFormField), 'Usta hiç gelmedi.');
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Kararı kesinleştir'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('decision-dialog')), findsOneWidget);
      expect(find.textContaining('hiçbir şey değişmedi'), findsOneWidget);
      expect(find.text('Usta hiç gelmedi.'), findsOneWidget);
    });

    testWidgets('gönderirken düğmeler kilitlenir', (tester) async {
      final gate = Completer<void>();
      final fake = FakeApi()
        ..on('POST', '/admin/complaints/c1/decision', (_) async {
          await gate.future;
          return json(
            200,
            complaintDetailJson(status: 'RESOLVED', decision: 'FULL_REFUND'),
          );
        });
      await openComplaint(tester, fake);
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('decision-fullRefund')));
      await tester.enterText(find.byType(TextFormField), 'Usta hiç gelmedi.');
      await _tapScrolled(tester, find.byKey(const Key('decision-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Kararı kesinleştir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final submit = tester.widget<FilledButton>(
        find.byKey(const Key('decision-submit')),
      );
      expect(submit.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(fake.count('POST', '/admin/complaints/c1/decision'), 1);

      gate.complete();
      fake.onJson(
        'GET',
        '/admin/complaints/c1',
        complaintDetailJson(status: 'RESOLVED', decision: 'FULL_REFUND'),
      );
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/complaints/c1/decision'), 1);
    });

    testWidgets('geri düğmesi listeye döner', (tester) async {
      final h = await openComplaint(tester, FakeApi());
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(h.location, Routes.complaints);
    });
  });
}
