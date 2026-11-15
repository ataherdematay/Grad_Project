import 'dart:async';

import 'package:dio/dio.dart';

import 'package:bitadilat_admin/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

Future<Harness> openDetail(WidgetTester tester, FakeApi fake) async {
  final h = await pumpAdmin(tester, fake: fake, initial: '/applications/p9');
  expect(h.location, '/applications/p9');
  return h;
}

void main() {
  group('Başvuru listesi', () {
    testWidgets(
      'varsayılan durum PENDING_REVIEW, kayıtlar ve kategori adları',
      (tester) async {
        final fake = FakeApi();
        final h = await pumpAdmin(tester, fake: fake, initial: '/applications');
        expect(fake.last('GET', '/admin/applications').queryParameters, {
          'status': 'PENDING_REVIEW',
        });
        expect(find.text('Kaya Tesisat'), findsOneWidget);
        expect(find.text('Demir Elektrik'), findsOneWidget);
        expect(find.text('Tesisat'), findsOneWidget);
        expect(find.text('Kadıköy, Üsküdar'), findsWidgets);

        await tester.tap(find.byKey(const Key('application-p9')));
        await tester.pumpAndSettle();
        expect(h.location, '/applications/p9');
      },
    );

    testWidgets('durum süzgeci ve arama sunucuya gider', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/applications');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Eksik belge'));
      await tester.pumpAndSettle();
      expect(
        fake.last('GET', '/admin/applications').queryParameters['status'],
        'NEEDS_DOCUMENTS',
      );

      await tester.enterText(find.byType(TextFormField), ' hasan ');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      final q = fake.last('GET', '/admin/applications').queryParameters;
      expect(q['q'], 'hasan');
      expect(q['status'], 'NEEDS_DOCUMENTS');
    });

    testWidgets('boş durum', (tester) async {
      final fake = FakeApi()
        ..onJson('GET', '/admin/applications', {'items': []});
      await pumpAdmin(tester, fake: fake, initial: '/applications');
      expect(find.text('Bu durumda başvuru yok'), findsOneWidget);
    });

    testWidgets('hata durumunda tekrar dene çalışır', (tester) async {
      var calls = 0;
      final fake = FakeApi()
        ..on('GET', '/admin/applications', (_) {
          calls++;
          return calls == 1
              ? apiError(500, 'INTERNAL_ERROR')
              : json(200, {
                  'items': [applicationSummaryJson()],
                });
        });
      await pumpAdmin(tester, fake: fake, initial: '/applications');
      expect(find.text('Liste yüklenemedi'), findsOneWidget);
      expect(find.textContaining('Beklenmeyen bir sorun'), findsOneWidget);

      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.text('Kaya Tesisat'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('ağ hatası mesajı', (tester) async {
      final fake = FakeApi()
        ..on('GET', '/admin/applications', (o) {
          throw DioException.connectionError(
            requestOptions: o,
            reason: 'offline',
          );
        });
      await pumpAdmin(tester, fake: fake, initial: '/applications');
      expect(find.textContaining('Sunucuya ulaşılamıyor'), findsOneWidget);
    });
  });

  group('Başvuru detayı', () {
    testWidgets('kişi, işletme, belgeler ve geçmiş görünür', (tester) async {
      await openDetail(tester, FakeApi());
      expect(find.text('hasan@example.com'), findsOneWidget);
      expect(find.text('+905320000000'), findsOneWidget);
      expect(find.text('20 yıl'), findsOneWidget);
      expect(find.text('Kimlik'), findsOneWidget);
      expect(find.text('Vergi levhası'), findsOneWidget);
      expect(find.byKey(const Key('document-d1')), findsOneWidget);
      expect(find.textContaining('Vergi levhası okunmuyor.'), findsOneWidget);
      expect(find.text('Eksik belge istedi · Zeynep Yönetici'), findsOneWidget);
    });

    testWidgets('görsel büyütülür, yeni sekmede açılır', (tester) async {
      final h = await openDetail(tester, FakeApi());
      await tester.tap(find.byKey(const Key('document-open-d1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('media-viewer')), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('media-viewer')),
          matching: find.text('Yeni sekmede aç'),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.opened, [
        'http://localhost:8090/api/v1/media/d1/content?exp=1&sig=2',
      ]);

      await tester.tap(find.byTooltip('Kapat'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('media-viewer')), findsNothing);
    });

    testWidgets('PDF için kartın bağlantısı yeni sekmede açar', (tester) async {
      final h = await openDetail(tester, FakeApi());
      final link = find.descendant(
        of: find.byKey(const Key('document-d2')),
        matching: find.text('Yeni sekmede aç'),
      );
      await tester.ensureVisible(link);
      await tester.pumpAndSettle();
      await tester.tap(link);
      await tester.pump();
      expect(h.opened.single, contains('/media/d2/content'));
    });

    testWidgets('onayla: onay diyaloğu, istek, yenileme', (tester) async {
      final fake = FakeApi()
        ..onJson(
          'POST',
          '/admin/applications/p9/approve',
          applicationDetailJson(status: 'APPROVED'),
        );
      await openDetail(tester, fake);

      await tester.tap(find.byKey(const Key('approve')));
      await tester.pumpAndSettle();
      expect(find.text('Başvuruyu onayla'), findsOneWidget);
      // Vazgeç: istek yok.
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/applications/p9/approve'), 0);

      await tester.tap(find.byKey(const Key('approve')));
      await tester.pumpAndSettle();
      fake.onJson(
        'GET',
        '/admin/applications/p9',
        applicationDetailJson(status: 'APPROVED'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Onayla').last);
      await tester.pumpAndSettle();

      expect(fake.count('POST', '/admin/applications/p9/approve'), 1);
      expect(find.text('Başvuru onaylandı.'), findsOneWidget);
      // Ekran yenilendi: karar düğmeleri kalktı.
      expect(find.byKey(const Key('approve')), findsNothing);
      expect(
        find.text('Bu başvuru için yapılacak bir işlem yok.'),
        findsOneWidget,
      );
    });

    testWidgets('reddet: not 10-1000 karakter doğrulanır', (tester) async {
      final fake = FakeApi()
        ..onJson(
          'POST',
          '/admin/applications/p9/reject',
          applicationDetailJson(status: 'REJECTED'),
        );
      await openDetail(tester, fake);

      await tester.tap(find.byKey(const Key('reject')));
      await tester.pumpAndSettle();
      expect(find.text('Başvuruyu reddet'), findsOneWidget);

      final confirm = find.widgetWithText(FilledButton, 'Reddet');
      // Boş not.
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);
      expect(fake.count('POST', '/admin/applications/p9/reject'), 0);

      // 9 karakter hâlâ kısa.
      await tester.enterText(find.byType(TextFormField), '123456789');
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);
      expect(fake.count('POST', '/admin/applications/p9/reject'), 0);

      // 1001 karakter fazla.
      await tester.enterText(find.byType(TextFormField), 'a' * 1001);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Not en fazla 1000 karakter olabilir.'), findsOneWidget);
      expect(fake.count('POST', '/admin/applications/p9/reject'), 0);

      // Tam 10 ve tam 1000 geçerli.
      await tester.enterText(find.byType(TextFormField), '1234567890');
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/applications/p9/reject'), 1);
      expect(fake.last('POST', '/admin/applications/p9/reject').data, {
        'note': '1234567890',
      });
      expect(find.text('Başvuru reddedildi.'), findsOneWidget);
    });

    testWidgets('1000 karakterlik not kabul edilir', (tester) async {
      final fake = FakeApi()
        ..onJson(
          'POST',
          '/admin/applications/p9/reject',
          applicationDetailJson(status: 'REJECTED'),
        );
      await openDetail(tester, fake);
      await tester.tap(find.byKey(const Key('reject')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'b' * 1000);
      await tester.tap(find.widgetWithText(FilledButton, 'Reddet'));
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/applications/p9/reject'), 1);
    });

    testWidgets('eksik belge iste: not ve en az bir belge türü', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson(
          'POST',
          '/admin/applications/p9/request-documents',
          applicationDetailJson(status: 'NEEDS_DOCUMENTS'),
        );
      await openDetail(tester, fake);

      await tester.tap(find.byKey(const Key('request-docs')));
      await tester.pumpAndSettle();
      final confirm = find.widgetWithText(FilledButton, 'Eksik belge iste');

      await tester.enterText(
        find.byType(TextFormField),
        'Vergi levhası okunmuyor.',
      );
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('En az bir belge türü seç.'), findsOneWidget);
      expect(fake.count('POST', '/admin/applications/p9/request-documents'), 0);

      // Yalnız başvurudaki türler (kimlik, vergi) sunulur.
      expect(find.byKey(const Key('doc-type-criminalRecord')), findsNothing);
      expect(find.byKey(const Key('doc-type-tradeCert')), findsNothing);
      await tester.tap(find.byKey(const Key('doc-type-identity')));
      await tester.tap(find.byKey(const Key('doc-type-tax')));
      await tester.pump();
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(
        fake.last('POST', '/admin/applications/p9/request-documents').data,
        {
          'note': 'Vergi levhası okunmuyor.',
          'documentTypes': ['IDENTITY', 'TAX'],
        },
      );
      expect(find.text('Eksik belge istendi.'), findsOneWidget);
    });

    testWidgets('ILLEGAL_STATE: ekran yenilenir ve açıklama gösterilir', (
      tester,
    ) async {
      final fake = FakeApi()
        ..on(
          'POST',
          '/admin/applications/p9/approve',
          (_) => apiError(409, 'ILLEGAL_STATE'),
        );
      await openDetail(tester, fake);
      expect(fake.count('GET', '/admin/applications/p9'), 1);

      // Başka bir yönetici bu arada onayladı.
      fake.onJson(
        'GET',
        '/admin/applications/p9',
        applicationDetailJson(status: 'APPROVED'),
      );
      await tester.tap(find.byKey(const Key('approve')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Onayla').last);
      await tester.pumpAndSettle();

      expect(fake.count('GET', '/admin/applications/p9'), 2);
      expect(find.textContaining('Kayıt bu arada değişti'), findsOneWidget);
      expect(find.byKey(const Key('approve')), findsNothing);
    });

    testWidgets('ILLEGAL_STATE reddetme diyaloğunu kapatıp yeniler', (
      tester,
    ) async {
      final fake = FakeApi()
        ..on(
          'POST',
          '/admin/applications/p9/reject',
          (_) => apiError(409, 'ILLEGAL_STATE'),
        );
      await openDetail(tester, fake);
      fake.onJson(
        'GET',
        '/admin/applications/p9',
        applicationDetailJson(status: 'REJECTED', note: 'Zaten reddedildi.'),
      );
      await tester.tap(find.byKey(const Key('reject')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Belgeler uyuşmuyor.');
      await tester.tap(find.widgetWithText(FilledButton, 'Reddet'));
      await tester.pumpAndSettle();

      expect(find.text('Başvuruyu reddet'), findsNothing);
      expect(find.textContaining('Kayıt bu arada değişti'), findsOneWidget);
      expect(find.text('Zaten reddedildi.'), findsOneWidget);
    });

    testWidgets('sunucu doğrulama hatası diyalogda kalır, not korunur', (
      tester,
    ) async {
      final fake = FakeApi()
        ..on(
          'POST',
          '/admin/applications/p9/reject',
          (_) => apiError(400, 'VALIDATION_FAILED'),
        );
      await openDetail(tester, fake);
      await tester.tap(find.byKey(const Key('reject')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Belgeler uyuşmuyor.');
      await tester.tap(find.widgetWithText(FilledButton, 'Reddet'));
      await tester.pumpAndSettle();
      expect(find.text('Başvuruyu reddet'), findsOneWidget);
      expect(find.textContaining('eksik ya da hatalı alan'), findsOneWidget);
      expect(find.text('Belgeler uyuşmuyor.'), findsOneWidget);
    });

    testWidgets('gönderirken düğmeler kilitlenir, ikinci istek gitmez', (
      tester,
    ) async {
      final gate = Completer<void>();
      final fake = FakeApi()
        ..on('POST', '/admin/applications/p9/approve', (_) async {
          await gate.future;
          return json(200, applicationDetailJson(status: 'APPROVED'));
        });
      await openDetail(tester, fake);

      await tester.tap(find.byKey(const Key('approve')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Onayla').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Sürerken: reddet ve eksik belge kilitli, onay düğmesi yükleniyor.
      expect(
        tester
            .widget<OutlinedButton>(
              find.descendant(
                of: find.byKey(const Key('reject')),
                matching: find.byType(OutlinedButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.descendant(
                of: find.byKey(const Key('request-docs')),
                matching: find.byType(OutlinedButton),
              ),
            )
            .onPressed,
        isNull,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('approve')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('approve')), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Başvuruyu onayla'), findsNothing);
      expect(fake.count('POST', '/admin/applications/p9/approve'), 1);

      gate.complete();
      fake.onJson(
        'GET',
        '/admin/applications/p9',
        applicationDetailJson(status: 'APPROVED'),
      );
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/applications/p9/approve'), 1);
    });

    testWidgets('onaylanmış başvuruda eylem yok, ret notu görünür', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson(
          'GET',
          '/admin/applications/p9',
          applicationDetailJson(status: 'REJECTED', note: 'Sabıka kaydı yok.'),
        );
      await openDetail(tester, fake);
      expect(find.byKey(const Key('approve')), findsNothing);
      expect(find.byKey(const Key('reject')), findsNothing);
      expect(find.text('Sabıka kaydı yok.'), findsOneWidget);
    });

    testWidgets('geri düğmesi listeye döner', (tester) async {
      final h = await openDetail(tester, FakeApi());
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(h.location, Routes.applications);
    });
  });
}
