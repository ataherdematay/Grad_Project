import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/jobs/job_ui.dart';
import 'package:bitadilat_mobile/features/notifications/notification_text.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

SessionState signedInWith({required String proStatus}) => SessionState.signedIn(
  Me.fromJson({
    ...meJson(lastMode: 'CUSTOMER', pro: proJson(proStatus)),
    'unreadNotifications': 0,
  }),
);

Finder _input(String label) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => w is AppTextField && w.label == label,
    description: 'AppTextField($label)',
  ),
  matching: find.byType(TextFormField),
);

AppLocalizations _lang(String code) => lookupAppLocalizations(Locale(code));

Notification _notif(String type, Map<String, dynamic> params) =>
    Notification.fromJson({
      'id': 'n',
      'type': type,
      'params': params,
      'targetRoute': null,
      'read': false,
      'createdAt': '2026-11-10T07:00:00Z',
    });

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr');
    await initializeDateFormatting('en');
  });

  group('Başvuru durumu ekranı', () {
    Handler server(String status, List<(String, String)> docs) => routes({
      ...baseRoutes(),
      'GET /pro/application': (_) => json(200, {
        ...applicationJson(status: status, note: 'Not.'),
        'documents': [
          for (var i = 0; i < docs.length; i++)
            {
              'id': 'd${i + 1}',
              'type': docs[i].$1,
              'status': docs[i].$2,
              'media': mediaJson('m${i + 1}'),
            },
        ],
      }),
    });

    testWidgets('REJECTED: bekleyen belge "inceleniyor" yazmaz', (t) async {
      await pumpApp(
        t,
        session: signedInWith(proStatus: 'REJECTED'),
        initial: '/p/application',
        size: tall,
        handler: server('REJECTED', [
          ('IDENTITY', 'PENDING'),
          ('TRADE_CERT', 'REJECTED'),
        ]),
      );
      expect(find.text('İnceleniyor'), findsNothing);
      expect(find.text('İncelenmedi'), findsOneWidget);
      // Gerçek durumu olan belge olduğu gibi kalır.
      expect(find.text('Reddedildi'), findsWidgets);
    });

    testWidgets('PENDING_REVIEW: belge hâlâ "inceleniyor"', (t) async {
      await pumpApp(
        t,
        session: signedInWith(proStatus: 'PENDING_REVIEW'),
        initial: '/p/application',
        size: tall,
        handler: server('PENDING_REVIEW', [('IDENTITY', 'PENDING')]),
      );
      // Durum çipi + belge çipi.
      expect(find.text('İnceleniyor'), findsNWidgets(2));
      expect(find.text('İncelenmedi'), findsNothing);
    });

    for (final status in ['PENDING_REVIEW', 'REJECTED', 'NEEDS_DOCUMENTS']) {
      testWidgets('$status: zil görünür ve bildirim merkezini açar', (t) async {
        final h = await pumpApp(
          t,
          session: signedInWith(proStatus: status),
          initial: '/p/application',
          size: tall,
          handler: routes({
            ...baseRoutes(),
            'GET /pro/application': (_) =>
                json(200, applicationJson(status: status)),
            'GET /notifications': (_) =>
                json(200, {'items': <Object>[], 'nextCursor': null}),
          }),
        );
        final bell = find.byIcon(Icons.notifications_none);
        expect(bell, findsOneWidget);
        await t.tap(bell);
        await t.pumpAndSettle();
        expect(h.location, '/notifications');
      });
    }
  });

  group('Giriş: askıya alınmış hesap', () {
    const suspended = 'Hesabın askıya alındı. Destek ekibiyle iletişime geç.';

    Future<void> login(WidgetTester t, SessionNotice? notice, Handler h) async {
      await pumpApp(
        t,
        session: SessionState.signedOut(notice: notice),
        initial: '/login',
        handler: h,
      );
      await t.enterText(_input('E-posta veya telefon'), 'a@b.co');
      await t.enterText(_input('Şifre'), 'abcd1234');
      await t.tap(find.widgetWithText(AppButton, 'Giriş yap'));
      await t.pumpAndSettle();
    }

    Handler loginFails(int status, String code) =>
        (o) => o.path.endsWith('/auth/login')
        ? apiError(status, code)
        : apiError(404, 'NOT_FOUND');

    testWidgets('bildirim varken aynı hata yalnız bir kez görünür', (t) async {
      await login(
        t,
        SessionNotice.accountSuspended,
        loginFails(401, 'ACCOUNT_SUSPENDED'),
      );
      expect(find.text(suspended), findsOneWidget);
    });

    testWidgets('bildirim yokken hata formda görünür', (t) async {
      await login(t, null, loginFails(401, 'ACCOUNT_SUSPENDED'));
      expect(find.text(suspended), findsOneWidget);
    });

    testWidgets('farklı bir bildirim varken giriş hatası gizlenmez', (t) async {
      await login(
        t,
        SessionNotice.sessionExpired,
        loginFails(401, 'ACCOUNT_SUSPENDED'),
      );
      expect(find.text(suspended), findsOneWidget);
      expect(find.text(_lang('tr').noticeSessionExpired), findsOneWidget);
    });
  });

  group('Bildirim metni: tutar', () {
    String text(String code, Map<String, dynamic> params) => notificationText(
      _lang(code),
      _notif('COMPLAINT_DECIDED', params),
      DateTime.utc(2026, 11, 10, 12),
    );

    test('tutar sıfırsa ya da yoksa tutar cümlesi yazılmaz', () {
      for (final amount in <Object?>[0, '0.00', '0', null]) {
        final params = {
          'complaintCode': 'SK-1001',
          'decision': 'RELEASE_TO_PRO',
          'amount': ?amount,
        };
        expect(text('tr', params), isNot(contains('Tutar')));
        expect(text('tr', params), isNot(contains('₺0')));
        expect(text('en', params), isNot(contains('Amount')));
      }
    });

    test('bozuk tutar da cümleyi düşürmez', () {
      final params = {
        'complaintCode': 'SK-1001',
        'decision': 'RELEASE_TO_PRO',
        'amount': 'abc',
      };
      expect(text('tr', params), isNot(contains('Tutar')));
    });

    test('pozitif tutar yazılır', () {
      final params = {
        'complaintCode': 'SK-1001',
        'decision': 'FULL_REFUND',
        'amount': '1100.00',
      };
      expect(text('tr', params), contains('Tutar: ₺1.100'));
      expect(text('en', params), contains('Amount: ₺1,100'));
    });
  });

  group('Ödeme kartı açıklaması', () {
    test('para havuzdan çıkınca havuzda tutulur denmez', () {
      final l = _lang('tr');
      const stale = 'güvence havuzunda tutulur';
      for (final role in PartyRole.values) {
        for (final byComplaint in [true, false]) {
          for (final s in [
            EscrowStatus.releasedToPro,
            EscrowStatus.refundedToCustomer,
            EscrowStatus.splitSettled,
            EscrowStatus.disputed,
          ]) {
            expect(
              escrowExplanation(l, s, role, byComplaint: byComplaint),
              isNot(contains(stale)),
            );
          }
        }
      }
      expect(
        escrowExplanation(l, EscrowStatus.splitSettled, PartyRole.pro),
        contains('paylaştırıldı'),
      );
    });

    test('"şikayet kararıyla" yalnız sonuçlanan şikayette yazılır', () {
      final l = _lang('tr');
      for (final role in PartyRole.values) {
        for (final s in [
          EscrowStatus.releasedToPro,
          EscrowStatus.refundedToCustomer,
        ]) {
          // Onay, 48 saat ya da iptal: şikayet yok.
          expect(escrowExplanation(l, s, role), isNot(contains('Şikayet')));
          expect(
            escrowExplanation(l, s, role, byComplaint: true),
            startsWith('Şikayet kararıyla'),
          );
        }
      }
      expect(
        escrowExplanation(l, EscrowStatus.releasedToPro, PartyRole.pro),
        l.escrowDoneReleasedPro,
      );
      expect(
        escrowExplanation(
          l,
          EscrowStatus.refundedToCustomer,
          PartyRole.customer,
        ),
        l.escrowDoneRefunded,
      );
    });

    test('kilitli ödemede eski açıklama korunur', () {
      final l = _lang('tr');
      expect(
        escrowExplanation(l, EscrowStatus.locked, PartyRole.pro),
        l.escrowExplainPro,
      );
      expect(
        escrowExplanation(l, EscrowStatus.locked, PartyRole.customer),
        l.escrowExplain,
      );
    });
  });
}
