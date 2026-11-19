import 'dart:io';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/core/support.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/common/legal_screen.dart';
import 'package:bitadilat_mobile/features/jobs/job_ui.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

AppLocalizations _lang(String code) => lookupAppLocalizations(Locale(code));

JobPayment _pay({String status = 'LOCKED', String? pending, String? error}) =>
    JobPayment.fromJson({
      'ref': 'ESC-1',
      'status': status,
      'totalAmount': 1200,
      'refundedAmount': 0,
      'pendingAction': pending,
      'errorCode': error,
    });

Map<String, dynamic> _job({
  required String status,
  String role = 'CUSTOMER',
  String? pending,
  String? error,
}) {
  final j = jobDetailJson(status: status, role: role, actions: const []);
  (j['payment'] as Map<String, dynamic>)
    ..['pendingAction'] = pending
    ..['errorCode'] = error;
  return j;
}

void main() {
  group('Ödeme: bekleyen iade/aktarım ve destek incelemesi', () {
    test('iptal + LOCKED + REFUND: iade işleniyor (müşteri/usta, TR/EN)', () {
      final tr = _lang('tr');
      final en = _lang('en');
      final p = _pay(pending: 'REFUND');
      expect(paymentLabel(tr, p, PartyRole.customer), 'İade işleniyor');
      expect(paymentLabel(tr, p, PartyRole.pro), 'Müşteriye iade işleniyor');
      expect(paymentLabel(en, p, PartyRole.customer), 'Refund in progress');
      expect(
        paymentExplanation(tr, p, PartyRole.customer),
        tr.escrowExplainRefundPending,
      );
      // Eski "güvence havuzunda, ustaya aktarılır" metni çıkmaz.
      expect(
        paymentExplanation(tr, p, PartyRole.customer),
        isNot(tr.escrowExplain),
      );
    });

    test('tamamlandı + LOCKED + RELEASE: ustaya aktarım işleniyor', () {
      final tr = _lang('tr');
      final p = _pay(pending: 'RELEASE');
      expect(
        paymentLabel(tr, p, PartyRole.customer),
        'Ustaya aktarım işleniyor',
      );
      expect(paymentLabel(tr, p, PartyRole.pro), 'Ustaya aktarım işleniyor');
      expect(
        paymentExplanation(tr, p, PartyRole.pro),
        tr.escrowExplainPayoutPendingPro,
      );
      expect(
        paymentExplanation(_lang('en'), p, PartyRole.customer),
        _lang('en').escrowExplainPayoutPending,
      );
    });

    test('inceleme kodu: destek metni; adres yalnız SUPPORT_EMAIL varsa', () {
      final tr = _lang('tr');
      for (final code in ['REFUND_NEEDS_REVIEW', 'PAYOUT_NEEDS_REVIEW']) {
        final p = _pay(pending: 'REFUND', error: code);
        expect(paymentLabel(tr, p, PartyRole.customer), 'Destek inceliyor');
        expect(
          paymentExplanation(tr, p, PartyRole.customer),
          tr.escrowExplainReview,
        );
        expect(
          paymentExplanation(
            tr,
            p,
            PartyRole.customer,
            supportEmail: 'destek@example.com',
          ),
          contains('destek@example.com'),
        );
      }
    });

    test('bekleyen hareket yoksa eski etiketler aynen', () {
      final tr = _lang('tr');
      expect(
        paymentLabel(tr, _pay(), PartyRole.customer),
        escrowLabel(tr, EscrowStatus.locked, PartyRole.customer),
      );
      expect(
        paymentLabel(tr, _pay(status: 'REFUNDED_TO_CUSTOMER'), PartyRole.pro),
        escrowLabel(tr, EscrowStatus.refundedToCustomer, PartyRole.pro),
      );
    });

    testWidgets('iptal edilmiş iş ekranı iade işleniyor gösterir', (t) async {
      final job = _job(status: 'CANCELLED', pending: 'REFUND');
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/jobs/j1',
        size: tall,
        handler: server3({'GET /jobs/j1': (_) => json(200, job)}),
        overrides: [nowProvider.overrideWithValue(() => kNow)],
      );
      expect(find.text('İade işleniyor'), findsOneWidget);
      expect(find.textContaining('iadesi işleniyor'), findsOneWidget);
      expect(find.text('Güvence havuzunda'), findsNothing);
    });

    testWidgets('incelemede: destek adresi tanımlıysa yazılır', (t) async {
      final job = _job(
        status: 'COMPLETED',
        role: 'PRO',
        pending: 'RELEASE',
        error: 'PAYOUT_NEEDS_REVIEW',
      );
      await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/jobs/j1',
        size: tall,
        handler: server3({'GET /jobs/j1': (_) => json(200, job)}),
        overrides: [
          nowProvider.overrideWithValue(() => kNow),
          supportEmailProvider.overrideWithValue('destek@example.com'),
        ],
      );
      expect(find.text('Destek inceliyor'), findsOneWidget);
      expect(find.textContaining('destek@example.com'), findsOneWidget);
    });

    testWidgets('usta iptal ekranı bekleyen iadeyi söyler', (t) async {
      final job = _job(status: 'CANCELLED', role: 'PRO', pending: 'REFUND');
      await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/jobs/j1/cancelled',
        size: tall,
        handler: server3({'GET /jobs/j1': (_) => json(200, job)}),
      );
      expect(
        find.text('İş iptal edildi. Tutar müşteriye iade ediliyor.'),
        findsOneWidget,
      );
    });
  });

  group('Değerlendirme süzgeci', () {
    testWidgets('yıldız ve yorumlu süzgeci sunucuya gider', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/pros/p1/reviews',
        handler: routes({
          'GET /pros/p1/reviews': (o) => json(200, {
            'items': o.queryParameters['rating'] == 2
                ? <Object>[]
                : [
                    {
                      'id': 'rv1',
                      'rating': 5,
                      'tags': <String>[],
                      'comment': 'Çok iyi',
                      'authorDisplay': 'A.Y.',
                      'createdAt': '2026-11-09T10:00:00Z',
                    },
                  ],
            'nextCursor': null,
          }),
        }),
      );
      expect(find.text('Çok iyi'), findsOneWidget);
      await t.tap(find.text('5 yıldız'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/pros/p1/reviews').queryParameters['rating'], 5);
      await t.ensureVisible(find.text('Yorumlu'));
      await t.pumpAndSettle();
      await t.tap(find.text('Yorumlu'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/pros/p1/reviews').queryParameters, {
        'limit': 50,
        'rating': 5,
        'withComment': true,
      });
      await t.tap(find.text('Yorumlu'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('2 yıldız'));
      await t.pumpAndSettle();
      await t.tap(find.text('2 yıldız'));
      await t.pumpAndSettle();
      expect(find.text('Bu süzgece uyan değerlendirme yok.'), findsOneWidget);
    });
  });

  group('E-posta değişikliği', () {
    testWidgets('kod doğrulanınca e-posta değişir; yanlış kod açıklanır', (
      t,
    ) async {
      var wrong = true;
      final h = await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/c/profile',
        handler: routes({
          ...baseRoutes(),
          'GET /me': (_) => json(200, meJson()),
          'POST /me/email': (_) => empty(202),
          'POST /me/email/confirm': (_) => wrong
              ? apiError(400, 'VALIDATION_FAILED', field: 'code')
              : json(200, {...meJson(), 'email': 'yeni@example.com'}),
        }),
      );
      expect(
        find.text('Telefon numarası şimdilik uygulamadan değiştirilemez.'),
        findsOneWidget,
      );
      await t.tap(find.text('E-postayı değiştir'));
      await t.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), 'yeni@example.com');
      await t.enterText(fields.at(1), 'Parola123');
      await t.tap(find.text('Kod gönder'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/me/email').data, {
        'newEmail': 'yeni@example.com',
        'password': 'Parola123',
      });
      expect(find.textContaining('yeni@example.com adresine'), findsOneWidget);
      // Kod onaylanmadan e-posta değişmez.
      expect(h.container.read(sessionProvider).me!.email, 'ayse@example.com');
      await t.enterText(find.byType(TextFormField).first, '000000');
      await t.tap(find.text('Onayla'));
      await t.pumpAndSettle();
      expect(find.textContaining('Kod geçersiz'), findsOneWidget);
      wrong = false;
      expect(h.adapter.count('POST', '/me/email/confirm'), 1);
      await t.enterText(find.byType(TextFormField).first, '123456');
      await t.pump();
      await t.tap(find.text('Onayla'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/me/email/confirm').data, {'code': '123456'});
      expect(h.container.read(sessionProvider).me!.email, 'yeni@example.com');
      expect(find.text('E-posta adresin güncellendi.'), findsOneWidget);
    });
  });

  group('Yasal taslaklar', () {
    test('uygulamadaki kopyalar docs/legal ile aynı ve TASLAK işaretli', () {
      for (final doc in kLegalDocs) {
        for (final lang in ['tr', 'en']) {
          final path = legalAssetPath(doc, lang)!;
          final asset = File(path).readAsStringSync();
          final source = File('../../docs/legal/${path.split('/').last}')
              .readAsStringSync();
          expect(asset, source, reason: path);
          expect(asset, contains(lang == 'tr' ? 'TASLAK' : 'DRAFT'));
        }
      }
    });

    testWidgets('assetler pubspec ile paketlenmiş (rootBundle)', (t) async {
      final text = await t.runAsync(
        () => rootBundle.loadString(legalAssetPath('kvkk', 'en')!),
      );
      expect(text, contains('DRAFT'));
    });

    for (final doc in kLegalDocs) {
      testWidgets('$doc: taslak etiketi ve gövde', (t) async {
        await pumpApp(
          t,
          session: SessionState.signedIn(testMe()),
          initial: '/legal/$doc',
          handler: routes(baseRoutes()),
        );
        expect(find.text('Taslak metin'), findsOneWidget);
        expect(find.byType(LegalMarkdown), findsOneWidget);
        expect(find.textContaining('TASLAK'), findsWidgets);
      });
    }

    testWidgets('bilinmeyen belge bulunamadı ekranı', (t) async {
      await pumpApp(
        t,
        session: SessionState.signedIn(testMe()),
        initial: '/legal/yok',
        handler: routes(baseRoutes()),
      );
      expect(find.byType(LegalMarkdown), findsNothing);
    });
  });
}
