import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/common/widgets.dart'
    show MessageBanner;
import 'package:bitadilat_mobile/features/jobs/pro_jobs.dart'
    show urlOpenerProvider;
import 'package:bitadilat_mobile/features/pro/pro_apply.dart'
    show kSupportEmail, supportEmailProvider;
import 'package:bitadilat_mobile/features/notifications/notification_bell.dart';
import 'package:bitadilat_mobile/features/notifications/notification_target.dart';
import 'package:bitadilat_mobile/features/notifications/notification_text.dart';
import 'package:bitadilat_mobile/features/notifications/notifications_controller.dart';
import 'package:bitadilat_mobile/core/photos.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

// -----------------------------------------------------------------------------
// Ortak yardımcılar
// -----------------------------------------------------------------------------

Map<String, dynamic> nj(
  String id,
  String type, {
  Map<String, dynamic> params = const {},
  String? target,
  bool read = false,
  String at = '2026-11-10T07:00:00Z',
}) => {
  'id': id,
  'type': type,
  'params': params,
  'targetRoute': target,
  'read': read,
  'createdAt': at,
};

Notification notif(
  String type, {
  Map<String, dynamic> params = const {},
  String? target,
}) => Notification.fromJson(nj('n', type, params: params, target: target));

Me meWith({
  int unread = 0,
  String? proStatus,
  UserMode mode = UserMode.customer,
}) => Me.fromJson({
  ...meJson(
    lastMode: mode == UserMode.pro ? 'PRO' : 'CUSTOMER',
    pro: proStatus == null ? null : proJson(proStatus),
  ),
  'unreadNotifications': unread,
});

SessionState signedInWith({
  int unread = 0,
  String? proStatus,
  UserMode mode = UserMode.customer,
}) => SessionState.signedIn(
  meWith(unread: unread, proStatus: proStatus, mode: mode),
);

/// Sahte bildirim sunucusu. `pages`: imleç -> sayfa; ilk sayfa imleçsiz.
Handler notifServer({
  required Map<String?, Map<String, dynamic>> pages,
  Map<String, FutureOr<ResponseBody> Function(RequestOptions)> extra = const {},
}) => routes({
  ...baseRoutes(),
  'GET /notifications': (o) {
    final cursor = o.queryParameters['cursor'] as String?;
    return json(200, pages[cursor] ?? {'items': <Object>[], 'unreadCount': 0});
  },
  'POST /notifications/read': (_) => empty(204),
  ...extra,
});

Map<String, dynamic> page(
  List<Map<String, dynamic>> items, {
  int unread = 0,
  String? next,
}) => {'items': items, 'nextCursor': next, 'unreadCount': unread};

final DateTime now0 = DateTime(2026, 11, 10, 9);

// -----------------------------------------------------------------------------
// Tür tablosu: sözleşmedeki 19 tür, params ve TR metni
// -----------------------------------------------------------------------------

class _Case {
  const _Case(this.type, this.params, this.target, this.tr, this.en);

  final String type;
  final Map<String, dynamic> params;
  final String? target;
  final String tr;
  final String? en;
}

String get _from => utc(DateTime(2026, 11, 11, 10));
String get _to => utc(DateTime(2026, 11, 11, 12));
String get _auto => utc(DateTime(2026, 11, 12, 14));

List<_Case> get _cases => [
  const _Case(
    'NEW_MATCHING_REQUEST',
    {
      'publicCode': 'BD-00001',
      'title': 'Musluk damlıyor',
      'districtName': 'Kadıköy',
    },
    '/p/requests/r1',
    'Sana uygun yeni talep: Musluk damlıyor (Kadıköy).',
    'New request that matches you: Musluk damlıyor (Kadıköy).',
  ),
  const _Case(
    'OFFER_RECEIVED',
    {
      'publicCode': 'BD-00001',
      'title': 'Musluk damlıyor',
      'proBusinessName': 'Usta Tesisat',
      'amount': 2450.5,
    },
    '/c/requests/r1/offers',
    'Usta Tesisat, Musluk damlıyor talebine ₺2.450,50 teklif verdi.',
    'Usta Tesisat offered ₺2,450.50 for Musluk damlıyor.',
  ),
  const _Case(
    'OFFER_DECLINED',
    {'publicCode': 'BD-00001', 'title': 'Musluk damlıyor'},
    '/p/offers',
    'Musluk damlıyor (BD-00001) için verdiğin teklif reddedildi.',
    'Your offer for Musluk damlıyor (BD-00001) was declined.',
  ),
  const _Case(
    'OFFER_SUPERSEDED',
    {'publicCode': 'BD-00001', 'title': 'Musluk damlıyor'},
    '/p/offers',
    'Musluk damlıyor (BD-00001) için müşteri başka bir teklifi seçti.',
    null,
  ),
  const _Case(
    'OFFER_ACCEPTED',
    {'publicCode': 'BD-00001', 'title': 'Musluk damlıyor', 'amount': 1200},
    '/p/jobs/j1',
    'Teklifin kabul edildi: Musluk damlıyor (BD-00001), ₺1.200.',
    'Your offer was accepted: Musluk damlıyor (BD-00001), ₺1,200.',
  ),
  const _Case(
    'REQUEST_UPDATED',
    {'publicCode': 'BD-00001', 'title': 'Musluk damlıyor'},
    '/p/requests/r1',
    'Musluk damlıyor (BD-00001) talebi güncellendi. Teklifini gözden geçir.',
    null,
  ),
  _Case(
    'APPOINTMENT_PROPOSED',
    {'publicCode': 'IS-00001', 'slotFrom': _from, 'slotTo': _to},
    '/c/jobs/j1',
    'IS-00001 işi için yeni bir randevu önerildi: Yarın, 10:00-12:00.',
    'A new appointment was proposed for job IS-00001: Tomorrow, 10:00-12:00.',
  ),
  _Case(
    'APPOINTMENT_CONFIRMED',
    {'publicCode': 'IS-00001', 'slotFrom': _from, 'slotTo': _to},
    '/p/jobs/j1',
    'IS-00001 işi için randevu onaylandı: Yarın, 10:00-12:00.',
    'The appointment for job IS-00001 is confirmed: Tomorrow, 10:00-12:00.',
  ),
  const _Case(
    'JOB_STAGE_CHANGED',
    {'publicCode': 'IS-00001', 'status': 'IN_PROGRESS'},
    '/c/jobs/j1',
    'IS-00001 işinin durumu değişti: İş sürüyor.',
    'The status of job IS-00001 changed: In progress.',
  ),
  _Case(
    'WORK_FINISHED',
    {'publicCode': 'IS-00001', 'autoCompleteAt': _auto},
    '/c/jobs/j1',
    'IS-00001 işi bitti. 12 Kasım Perşembe, 14:00 tarihine kadar onaylamazsan '
        'iş kendiliğinden tamamlanır.',
    'Job IS-00001 is finished. If you do not confirm by Thursday 12 November, '
        '14:00, it completes automatically.',
  ),
  _Case(
    'AUTO_COMPLETE_REMINDER',
    {'publicCode': 'IS-00001', 'autoCompleteAt': _auto},
    '/c/jobs/j1',
    'IS-00001 işi 12 Kasım Perşembe, 14:00 tarihinde kendiliğinden '
        'tamamlanacak. Sorun varsa şimdi bildir.',
    null,
  ),
  const _Case(
    'PAYOUT_RELEASED',
    {'publicCode': 'IS-00001', 'amount': 1080},
    '/p/earnings',
    'IS-00001 işinin ₺1.080 tutarındaki ödemesi sana aktarıldı.',
    'The ₺1,080 payment for job IS-00001 was paid out to you.',
  ),
  const _Case(
    'JOB_CANCELLED',
    {'publicCode': 'IS-00001', 'byRole': 'CUSTOMER', 'refundAmount': 1200},
    '/p/jobs/j1',
    'IS-00001 işini müşteri iptal etti. İade tutarı: ₺1.200.',
    'The customer cancelled job IS-00001. Refund: ₺1,200.',
  ),
  const _Case(
    'NEW_MESSAGE',
    {'publicCode': 'IS-00001', 'senderName': 'Ayşe'},
    '/jobs/j1/chat',
    'Ayşe sana mesaj gönderdi (IS-00001).',
    'Ayşe sent you a message (IS-00001).',
  ),
  const _Case(
    'COMPLAINT_OPENED',
    {'publicCode': 'IS-00001', 'complaintCode': 'SK-1001'},
    '/p/jobs/j1',
    'IS-00001 işi için SK-1001 numaralı şikayet açıldı.',
    'Complaint SK-1001 was opened for job IS-00001.',
  ),
  const _Case(
    'COMPLAINT_DECIDED',
    {'complaintCode': 'SK-1001', 'decision': 'FULL_REFUND', 'amount': 1200},
    '/c/complaints/5',
    'SK-1001 şikayeti karara bağlandı: Tam iade. Tutar: ₺1.200.',
    'Complaint SK-1001 was decided: Full refund. Amount: ₺1,200.',
  ),
  const _Case(
    'PRO_APPROVED',
    {},
    '/p/feed',
    'Usta başvurun onaylandı. Artık sana uygun talepleri görebilirsin.',
    'Your pro application was approved. You can now see requests that match you.',
  ),
  const _Case(
    'PRO_REJECTED',
    {'note': 'Belgeler okunmuyor.'},
    '/p/application',
    'Usta başvurun kabul edilmedi. İnceleme notu: Belgeler okunmuyor.',
    'Your pro application was not accepted. Review note: Belgeler okunmuyor.',
  ),
  const _Case(
    'PRO_NEEDS_DOCUMENTS',
    {'note': 'Kimlik okunmuyor.'},
    '/p/application',
    'Başvurunda eksik belgeler var. İnceleme notu: Kimlik okunmuyor.',
    'Your application has missing documents. Review note: Kimlik okunmuyor.',
  ),
];

AppLocalizations lang(String code) => lookupAppLocalizations(Locale(code));

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr');
    await initializeDateFormatting('en');
  });

  // ---------------------------------------------------------------------------
  group('Metinler (type + params)', () {
    test('sözleşmedeki 19 tür tabloda', () {
      expect(_cases.length, 19);
      expect(
        {for (final c in _cases) c.type},
        {
          for (final t in NotificationType.values)
            if (t != NotificationType.unknown) t.wire,
        },
      );
    });

    for (final c in _cases) {
      test('TR ${c.type}', () {
        final n = notif(c.type, params: c.params, target: c.target);
        expect(notificationText(lang('tr'), n, now0), c.tr);
      });
    }

    final withEn = [
      for (final c in _cases)
        if (c.en != null) c,
    ];
    test('EN metni en az 8 türde var', () {
      expect(withEn.length, greaterThanOrEqualTo(8));
    });
    for (final c in withEn) {
      test('EN ${c.type}', () {
        final n = notif(c.type, params: c.params, target: c.target);
        expect(notificationText(lang('en'), n, now0), c.en);
      });
    }

    test('EN: yer tutucu kalmaz, her türde metin üretilir', () {
      for (final c in _cases) {
        final n = notif(c.type, params: c.params, target: c.target);
        final text = notificationText(lang('en'), n, now0);
        expect(text, isNotEmpty);
        expect(text, isNot(contains('{')));
        expect(text, isNot(contains('–')), reason: c.type);
      }
    });

    test('bilinmeyen tür genel metin verir, çökmez', () {
      final n = notif('BRAND_NEW_TYPE', params: {'x': 1}, target: '/c/home');
      expect(notificationText(lang('tr'), n, now0), 'Yeni bir bildirimin var.');
      expect(
        notificationText(lang('en'), n, now0),
        'You have a new notification.',
      );
      expect(notificationIcon(n.kind), Icons.notifications_none);
    });

    test('eksik ve bozuk params çökmez', () {
      for (final t in NotificationType.values) {
        final n = notif(t.wire, params: const {});
        expect(notificationText(lang('tr'), n, now0), isNotEmpty);
      }
      final bad = notif(
        'OFFER_RECEIVED',
        params: {'amount': 'abc', 'title': 'T', 'proBusinessName': 'U'},
      );
      expect(
        notificationText(lang('tr'), bad, now0),
        'U, T talebine – teklif verdi.',
      );
      final badSlot = notif(
        'APPOINTMENT_PROPOSED',
        params: {'publicCode': 'X', 'slotFrom': 'yarın', 'slotTo': 5},
      );
      expect(notificationText(lang('tr'), badSlot, now0), contains('–'));
      // `NaN`, sonsuz ve nesne tutar da çökertmez.
      for (final amount in <Object>[
        'NaN',
        'Infinity',
        {'x': 1},
        true,
      ]) {
        final n = notif(
          'PAYOUT_RELEASED',
          params: {'publicCode': 'X', 'amount': amount},
        );
        expect(
          notificationText(lang('tr'), n, now0),
          contains('–'),
          reason: '$amount',
        );
      }
    });

    test('iptal eden role göre metin; bilinmeyen rol genel iptal', () {
      String text(String by) => notificationText(
        lang('tr'),
        notif(
          'JOB_CANCELLED',
          params: {'publicCode': 'A', 'byRole': by, 'refundAmount': 10},
        ),
        now0,
      );
      expect(text('PRO'), 'A işini usta iptal etti. İade tutarı: ₺10.');
      expect(text('SYSTEM'), 'A işi iptal edildi. İade tutarı: ₺10.');
    });

    test('şikayet kararı tutarsız: tutar cümlesi yok; ham karar korunur', () {
      final n = notif(
        'COMPLAINT_DECIDED',
        params: {'complaintCode': 'SK-1', 'decision': 'SPLIT_50_50'},
      );
      expect(
        notificationText(lang('tr'), n, now0),
        'SK-1 şikayeti karara bağlandı: Yarı yarıya paylaşım (%50 / %50).',
      );
      final raw = notif(
        'COMPLAINT_DECIDED',
        params: {'complaintCode': 'SK-1', 'decision': 'YENI_KARAR'},
      );
      expect(
        notificationText(lang('tr'), raw, now0),
        'SK-1 şikayeti karara bağlandı: YENI_KARAR.',
      );
    });

    test('TR ve EN ARB anahtarları aynı', () {
      Set<String> keys(String f) =>
          (jsonDecode(File('lib/l10n/$f').readAsStringSync()) as Map).keys
              .cast<String>()
              .where((k) => !k.startsWith('@'))
              .toSet();
      expect(keys('app_en.arb'), keys('app_tr.arb'));
    });
  });

  // ---------------------------------------------------------------------------
  group('Hedef rota kararı', () {
    final customer = meWith();
    final proInCustomerMode = meWith(proStatus: 'APPROVED');
    final proInProMode = meWith(proStatus: 'APPROVED', mode: UserMode.pro);

    test('dış, bozuk ya da bilinmeyen hedef reddedilir', () {
      for (final bad in [
        null,
        '',
        'https://evil.example/c/jobs/1',
        'http://evil.example',
        '//evil.example/c/home',
        'javascript:alert(1)',
        '/\\evil',
        'c/jobs/1',
        '/c/../p/feed',
        '/bilinmeyen/rota',
        '/',
        '/login',
        '/welcome',
        '/notifications',
        '/c/jobs/1/',
        '   ',
        '/c/jobs/%2e%2e',
        '/c/jobs/%2E%2E/offers',
        '/c/jobs/a%2Fb',
        '/c/jobs/a%5Cb',
        '/c/jobs/.',
      ]) {
        expect(
          resolveNotificationTarget(customer, bad).action,
          TargetAction.blocked,
          reason: '$bad',
        );
      }
    });

    test('iç rota açılır', () {
      for (final ok in [
        '/c/jobs/12',
        '/c/requests/5/offers',
        '/c/complaints/5',
        '/jobs/12/chat',
        '/settings',
      ]) {
        final t = resolveNotificationTarget(customer, ok);
        expect(t.action, TargetAction.open, reason: ok);
        expect(t.route, ok);
      }
    });

    test('usta profili olmayan müşteri /p/ rotasını açamaz', () {
      expect(
        resolveNotificationTarget(customer, '/p/jobs/1').action,
        TargetAction.blocked,
      );
    });

    test('onaylı usta müşteri modunda: /p/ için mod değişimi önerilir', () {
      final t = resolveNotificationTarget(proInCustomerMode, '/p/jobs/9');
      expect(t.action, TargetAction.switchToPro);
      expect(t.route, '/p/jobs/9');
      expect(
        resolveNotificationTarget(proInCustomerMode, '/c/jobs/9').action,
        TargetAction.open,
      );
    });

    test('usta modunda: /c/ için müşteri moduna geçiş önerilir', () {
      expect(
        resolveNotificationTarget(proInProMode, '/c/jobs/9').action,
        TargetAction.switchToCustomer,
      );
      expect(
        resolveNotificationTarget(proInProMode, '/p/jobs/9').action,
        TargetAction.open,
      );
      // Sohbet role bağlı değildir.
      expect(
        resolveNotificationTarget(proInProMode, '/jobs/9/chat').action,
        TargetAction.open,
      );
    });

    test('onaysız usta: /p/ hedefleri /p/application açar', () {
      for (final st in [
        'PENDING_REVIEW',
        'NEEDS_DOCUMENTS',
        'REJECTED',
        'SUSPENDED',
      ]) {
        final me = meWith(proStatus: st, mode: UserMode.pro);
        expect(
          resolveNotificationTarget(me, '/p/application').action,
          TargetAction.open,
          reason: st,
        );
        // Askıdaki ya da onaysız ustanın usta hedefi: durum ekranı açılır.
        final t = resolveNotificationTarget(me, '/p/jobs/1');
        expect(t.action, TargetAction.open, reason: st);
        expect(t.route, '/p/application', reason: st);
      }
    });
  });

  // ---------------------------------------------------------------------------
  group('Para ve karar hesabı', () {
    test('rozet metni', () {
      expect(badgeText(1), '1');
      expect(badgeText(99), '99');
      expect(badgeText(100), '99+');
      expect(badgeText(2500), '99+');
    });
  });

  // ---------------------------------------------------------------------------
  group('Bildirim merkezi', () {
    final sample = [
      nj(
        'n1',
        'OFFER_RECEIVED',
        params: {
          'publicCode': 'BD-00001',
          'title': 'Musluk damlıyor',
          'proBusinessName': 'Usta Tesisat',
          'amount': 2450.5,
        },
        target: '/c/requests/r1/offers',
      ),
      nj(
        'n2',
        'PAYOUT_RELEASED',
        params: {'publicCode': 'IS-00001', 'amount': 1080},
        target: '/p/earnings',
        read: true,
      ),
    ];

    testWidgets('liste: okunmamış işareti, metinler, Tümünü okundu say', (
      t,
    ) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        overrides: [nowProvider.overrideWithValue(() => now0)],
        handler: notifServer(pages: {null: page(sample, unread: 1)}),
      );
      expect(find.text('Bildirimler'), findsWidgets);
      expect(
        find.text(
          'Usta Tesisat, Musluk damlıyor talebine ₺2.450,50 teklif verdi.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('IS-00001 işinin ₺1.080 tutarındaki ödemesi sana aktarıldı.'),
        findsOneWidget,
      );
      // Yalnız okunmamış olanda nokta var.
      expect(find.byKey(const ValueKey('unread-dot')), findsOneWidget);
      expect(btn('Tümünü okundu say'), findsOneWidget);
    });

    testWidgets('EN metin ve düğme', (t) async {
      await pumpApp(
        t,
        locale: 'en',
        session: signedInWith(unread: 1),
        initial: '/notifications',
        overrides: [nowProvider.overrideWithValue(() => now0)],
        handler: notifServer(pages: {null: page(sample, unread: 1)}),
      );
      expect(find.text('Notifications'), findsWidgets);
      expect(
        find.text('Usta Tesisat offered ₺2,450.50 for Musluk damlıyor.'),
        findsOneWidget,
      );
      expect(btn('Mark all as read'), findsOneWidget);
    });

    testWidgets('dokununca okundu çağrılır ve hedef rotaya gidilir', (t) async {
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(pages: {null: page(sample, unread: 1)}),
      );
      await t.tap(find.textContaining('Usta Tesisat, Musluk'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/notifications/read'), 1);
      expect(h.adapter.last('/notifications/read').data, {
        'ids': ['n1'],
      });
      expect(h.location, '/c/requests/r1/offers');
      // Geri: bildirim merkezi.
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/notifications');
      expect(find.byKey(const ValueKey('unread-dot')), findsNothing);
      expect(btn('Tümünü okundu say'), findsNothing);
      expect(h.container.read(sessionProvider).me!.unreadNotifications, 0);
    });

    testWidgets('çift dokunma: tek okundu isteği, hedef bir kez açılır', (
      t,
    ) async {
      final gate = Completer<void>();
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(
          pages: {null: page(sample, unread: 1)},
          extra: {
            'POST /notifications/read': (_) async {
              await gate.future;
              return empty(204);
            },
          },
        ),
      );
      final n = h.container.read(notificationsProvider.notifier);
      // Denetleyici düzeyi: istek sürerken ikinci çağrı yeni istek atmaz.
      unawaited(n.markRead('n1'));
      unawaited(n.markRead('n1'));
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(milliseconds: 10));
      }
      expect(h.adapter.count('POST', '/notifications/read'), 1);
      gate.complete();
      await t.pumpAndSettle();
      expect(h.container.read(sessionProvider).me!.unreadNotifications, 0);
      expect(h.container.read(notificationsProvider).value!.unreadCount, 0);
    });

    testWidgets('satıra iki kez hızlı dokunmak hedefi bir kez açar', (t) async {
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(pages: {null: page(sample, unread: 1)}),
      );
      final row = find.textContaining('Usta Tesisat, Musluk');
      await t.tap(row);
      await t.tap(row, warnIfMissed: false);
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1/offers');
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/notifications');
      // Dönüşte kilit kalkar: yeniden açılabilir.
      await t.tap(row);
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1/offers');
    });

    testWidgets('askıdaki usta: usta hedefi başvuru durumu ekranını açar', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1, proStatus: 'SUSPENDED'),
        initial: '/notifications',
        handler: notifServer(
          pages: {
            null: page([
              nj(
                'n1',
                'COMPLAINT_DECIDED',
                params: {'complaintCode': 'SK-1', 'decision': 'FULL_REFUND'},
                target: '/p/jobs/j1',
              ),
            ], unread: 1),
          },
          extra: {
            'GET /me': (_) => json(200, {
              ...meJson(pro: proJson('SUSPENDED')),
              'unreadNotifications': 1,
            }),
            'GET /pro/application': (_) => json(
              200,
              applicationJson(status: 'SUSPENDED', note: 'Tekrarlanan.'),
            ),
          },
        ),
      );
      await t.tap(find.textContaining('SK-1'));
      await t.pumpAndSettle();
      expect(find.text('Bu bildirim açılamıyor'), findsNothing);
      expect(h.location, '/p/application');
      expect(find.text('Usta profilin askıya alındı'), findsOneWidget);
    });

    testWidgets('okunmuş bildirime dokunmak okundu isteği göndermez', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: signedInWith(),
        initial: '/notifications',
        handler: notifServer(pages: {null: page(sample, unread: 1)}),
      );
      await t.tap(find.textContaining('IS-00001 işinin'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/notifications/read'), 0);
      // Müşterinin /p/earnings'i yok: açıklama gösterilir.
      expect(find.text('Bu bildirim açılamıyor'), findsOneWidget);
    });

    testWidgets(
      'Tümünü okundu say: gövdesiz istek, işaretler ve rozet sıfırlanır',
      (t) async {
        final h = await pumpApp(
          t,
          session: signedInWith(unread: 2),
          initial: '/notifications',
          handler: notifServer(
            pages: {
              null: page([
                ...sample,
                nj('n3', 'PRO_APPROVED', target: '/p/feed'),
              ], unread: 2),
            },
          ),
        );
        expect(find.byKey(const ValueKey('unread-dot')), findsNWidgets(2));
        await t.tap(btn('Tümünü okundu say'));
        await t.pumpAndSettle();
        expect(h.adapter.count('POST', '/notifications/read'), 1);
        expect(h.adapter.last('/notifications/read').data, <String, dynamic>{});
        expect(find.byKey(const ValueKey('unread-dot')), findsNothing);
        expect(btn('Tümünü okundu say'), findsNothing);
        expect(h.container.read(sessionProvider).me!.unreadNotifications, 0);
      },
    );

    testWidgets('Tümünü okundu say hata verirse işaretler korunur', (t) async {
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(
          pages: {null: page(sample, unread: 1)},
          extra: {
            'POST /notifications/read': (_) => apiError(500, 'INTERNAL_ERROR'),
          },
        ),
      );
      await t.tap(btn('Tümünü okundu say'));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('unread-dot')), findsOneWidget);
      expect(h.container.read(sessionProvider).me!.unreadNotifications, 1);
    });

    testWidgets('boş durum', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/notifications',
        handler: notifServer(pages: {null: page(const [])}),
      );
      expect(find.text('Henüz bildirimin yok'), findsOneWidget);
      expect(btn('Tümünü okundu say'), findsNothing);
    });

    testWidgets('hata durumunda Tekrar dene', (t) async {
      var fail = true;
      final h = await pumpApp(
        t,
        session: signedInWith(),
        initial: '/notifications',
        handler: notifServer(
          pages: {null: page(sample)},
          extra: {
            'GET /notifications': (_) => fail
                ? apiError(500, 'INTERNAL_ERROR')
                : json(200, page(sample)),
          },
        ),
      );
      expect(find.text('Tekrar dene'), findsOneWidget);
      fail = false;
      await t.tap(find.text('Tekrar dene'));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/notifications'), 2);
      expect(find.textContaining('Usta Tesisat, Musluk'), findsOneWidget);
    });

    testWidgets('aşağı çekince yeniden yüklenir', (t) async {
      final h = await pumpApp(
        t,
        session: signedInWith(),
        initial: '/notifications',
        handler: notifServer(pages: {null: page(sample)}),
      );
      expect(h.adapter.count('GET', '/notifications'), 1);
      await t.fling(find.byType(ListView).first, const Offset(0, 400), 1000);
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/notifications'), 2);
    });

    testWidgets('sayfalama: Daha fazla göster sonraki sayfayı ekler', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: signedInWith(),
        initial: '/notifications',
        handler: notifServer(
          pages: {
            null: page([sample[0]], next: 'c2', unread: 1),
            'c2': page([sample[1]], unread: 1),
          },
        ),
      );
      expect(find.textContaining('₺1.080'), findsNothing);
      expect(h.adapter.requests.first.queryParameters['limit'], 20);
      await t.tap(btn('Daha fazla göster'));
      await t.pumpAndSettle();
      expect(
        h.adapter.requests
            .where(
              (r) => r.path.endsWith('/notifications') && r.method == 'GET',
            )
            .last
            .queryParameters['cursor'],
        'c2',
      );
      expect(find.textContaining('₺1.080'), findsOneWidget);
      expect(btn('Daha fazla göster'), findsNothing);
    });

    testWidgets('sayfalama hatasında liste korunur', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/notifications',
        handler: notifServer(
          pages: {
            null: page([sample[0]], next: 'c2'),
          },
          extra: {
            'GET /notifications': (o) => o.queryParameters['cursor'] == null
                ? json(200, page([sample[0]], next: 'c2'))
                : apiError(500, 'INTERNAL_ERROR'),
          },
        ),
      );
      await t.tap(btn('Daha fazla göster'));
      await t.pumpAndSettle();
      expect(find.textContaining('Usta Tesisat, Musluk'), findsOneWidget);
      expect(find.text('Bir sorun oluştu'), findsOneWidget);
      expect(btn('Daha fazla göster'), findsOneWidget);
    });

    testWidgets('bilinmeyen tür genel metinle çizilir; hedefi yine açılır', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(
          pages: {
            null: page([
              nj(
                'n9',
                'FUTURE_THING',
                params: {'a': 1},
                target: '/c/requests/r1/offers',
              ),
            ], unread: 1),
          },
        ),
      );
      expect(t.takeException(), isNull);
      expect(find.text('Yeni bir bildirimin var.'), findsOneWidget);
      await t.tap(find.text('Yeni bir bildirimin var.'));
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1/offers');
    });

    testWidgets(
      'dış hedef reddedilir, açıklama gösterilir, okundu yine işlenir',
      (t) async {
        final h = await pumpApp(
          t,
          session: signedInWith(unread: 2),
          initial: '/notifications',
          handler: notifServer(
            pages: {
              null: page([
                nj(
                  'n1',
                  'NEW_MESSAGE',
                  params: {'senderName': 'Ali', 'publicCode': 'IS-1'},
                  target: 'https://evil.example/x',
                ),
                nj('n2', 'PRO_APPROVED'),
              ], unread: 2),
            },
          ),
        );
        await t.tap(find.textContaining('Ali sana mesaj'));
        await t.pumpAndSettle();
        expect(find.text('Bu bildirim açılamıyor'), findsOneWidget);
        expect(h.location, '/notifications');
        await t.tap(find.text('Kapat'));
        await t.pumpAndSettle();
        expect(h.adapter.last('/notifications/read').data, {
          'ids': ['n1'],
        });
        // Hedefi olmayan bildirim de aynı açıklamayı verir.
        await t.tap(find.textContaining('Usta başvurun onaylandı'));
        await t.pumpAndSettle();
        expect(find.text('Bu bildirim açılamıyor'), findsOneWidget);
        expect(h.location, '/notifications');
      },
    );

    testWidgets('korumaların izin vermediği hedefe gidilmez', (t) async {
      final h = await pumpApp(
        t,
        // Usta profili yok: /p/jobs/j1 açılamaz.
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(
          pages: {
            null: page([
              nj(
                'n1',
                'OFFER_ACCEPTED',
                params: {'title': 'T', 'publicCode': 'B', 'amount': 5},
                target: '/p/jobs/j1',
              ),
            ], unread: 1),
          },
        ),
      );
      await t.tap(find.textContaining('Teklifin kabul edildi'));
      await t.pumpAndSettle();
      expect(find.text('Bu bildirim açılamıyor'), findsOneWidget);
      expect(h.location, '/notifications');
    });

    group('mod değişimi', () {
      Map<String, FutureOr<ResponseBody> Function(RequestOptions)> proRoutes([
        String serverMode = 'CUSTOMER',
      ]) {
        var mode = serverMode;
        return {
          'PATCH /me': (o) {
            mode = (o.data as Map)['lastMode'] as String;
            return json(200, {
              ...meJson(lastMode: mode, pro: proJson('APPROVED')),
              'unreadNotifications': 0,
            });
          },
          'GET /me': (_) => json(200, {
            ...meJson(lastMode: mode, pro: proJson('APPROVED')),
            'unreadNotifications': 1,
          }),
        };
      }

      final toPro = page([
        nj(
          'n1',
          'OFFER_ACCEPTED',
          params: {'title': 'Musluk', 'publicCode': 'BD-1', 'amount': 1200},
          target: '/p/jobs/j1',
        ),
      ], unread: 1);

      testWidgets('müşteri modunda /p/ hedefi: diyalog, onayla -> geç ve aç', (
        t,
      ) async {
        final h = await pumpApp(
          t,
          session: signedInWith(unread: 1, proStatus: 'APPROVED'),
          initial: '/notifications',
          handler: notifServer(pages: {null: toPro}, extra: proRoutes()),
        );
        await t.tap(find.textContaining('Teklifin kabul edildi'));
        await t.pumpAndSettle();
        expect(find.text('Usta moduna geçip açalım mı?'), findsOneWidget);
        expect(h.adapter.count('PATCH', '/me'), 0);
        await t.tap(find.widgetWithText(FilledButton, 'Usta moduna geç'));
        await t.pumpAndSettle();
        expect(h.adapter.last('/me').data, {'lastMode': 'PRO'});
        expect(h.location, '/p/jobs/j1');
        // Mod değişimi yığını sıfırladı: geri sekme köküne gider.
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(h.location, '/p/feed');
        expect(h.container.read(sessionProvider).me!.lastMode, UserMode.pro);
      });

      testWidgets('Ana sayfa > zil > bildirim: mod değişir, yığın sıfırlanır', (
        t,
      ) async {
        final h = await pumpApp(
          t,
          session: signedInWith(unread: 1, proStatus: 'APPROVED'),
          initial: '/c/home',
          handler: notifServer(
            pages: {null: toPro},
            extra: {
              ...proRoutes(),
              'GET /requests': (_) => json(200, {'items': <Object>[]}),
              'GET /jobs': (_) => json(200, {'items': <Object>[]}),
            },
          ),
        );
        await t.tap(find.byTooltip('Bildirimler, 1 okunmamış'));
        await t.pumpAndSettle();
        expect(h.location, '/notifications');
        await t.tap(find.textContaining('Teklifin kabul edildi'));
        await t.pumpAndSettle();
        await t.tap(find.widgetWithText(FilledButton, 'Usta moduna geç'));
        await t.pumpAndSettle();
        expect(h.location, '/p/jobs/j1');
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(h.location, '/p/feed');
        // Eski müşteri yığını (Ana sayfa, bildirimler) kalmadı.
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(h.location, '/p/feed');
      });

      testWidgets('Vazgeç: mod ve ekran değişmez', (t) async {
        final h = await pumpApp(
          t,
          session: signedInWith(unread: 1, proStatus: 'APPROVED'),
          initial: '/notifications',
          handler: notifServer(pages: {null: toPro}, extra: proRoutes()),
        );
        await t.tap(find.textContaining('Teklifin kabul edildi'));
        await t.pumpAndSettle();
        await t.tap(find.text('Vazgeç'));
        await t.pumpAndSettle();
        expect(h.adapter.count('PATCH', '/me'), 0);
        expect(h.location, '/notifications');
        expect(
          h.container.read(sessionProvider).me!.lastMode,
          UserMode.customer,
        );
      });

      testWidgets('usta modunda /c/ hedefi: müşteri moduna geçip aç', (
        t,
      ) async {
        final h = await pumpApp(
          t,
          session: signedInWith(
            unread: 1,
            proStatus: 'APPROVED',
            mode: UserMode.pro,
          ),
          initial: '/notifications',
          handler: notifServer(
            pages: {
              null: page([
                nj(
                  'n1',
                  'OFFER_RECEIVED',
                  params: {'title': 'T', 'proBusinessName': 'U', 'amount': 5},
                  target: '/c/requests/r1/offers',
                ),
              ], unread: 1),
            },
            extra: proRoutes('PRO'),
          ),
        );
        await t.tap(find.textContaining('talebine'));
        await t.pumpAndSettle();
        expect(find.text('Müşteri moduna geçip açalım mı?'), findsOneWidget);
        await t.tap(find.widgetWithText(FilledButton, 'Müşteri moduna geç'));
        await t.pumpAndSettle();
        expect(h.adapter.last('/me').data, {'lastMode': 'CUSTOMER'});
        expect(h.location, '/c/requests/r1/offers');
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(h.location, '/c/home');
      });

      testWidgets('mod kaydı başarısızsa ekran değişmez, hata gösterilir', (
        t,
      ) async {
        final h = await pumpApp(
          t,
          session: signedInWith(unread: 1, proStatus: 'APPROVED'),
          initial: '/notifications',
          handler: notifServer(
            pages: {null: toPro},
            extra: {'PATCH /me': (_) => apiError(500, 'INTERNAL_ERROR')},
          ),
        );
        await t.tap(find.textContaining('Teklifin kabul edildi'));
        await t.pumpAndSettle();
        await t.tap(find.widgetWithText(FilledButton, 'Usta moduna geç'));
        await t.pumpAndSettle();
        expect(h.location, '/notifications');
        expect(
          h.container.read(sessionProvider).me!.lastMode,
          UserMode.customer,
        );
      });
    });
  });

  // ---------------------------------------------------------------------------
  group('Zil ve rozet', () {
    Handler home({int serverUnread = 0}) => routes({
      ...baseRoutes(),
      'GET /requests': (_) =>
          json(200, {'items': <Object>[], 'nextCursor': null}),
      'GET /jobs': (_) => json(200, {'items': <Object>[], 'nextCursor': null}),
      'GET /me': (_) =>
          json(200, {...meJson(), 'unreadNotifications': serverUnread}),
      'GET /notifications': (_) => json(
        200,
        page([
          nj('n1', 'PRO_APPROVED', target: '/c/home'),
          nj('n2', 'PRO_APPROVED', target: '/c/home'),
          nj('n3', 'PRO_APPROVED', target: '/c/home'),
        ], unread: 3),
      ),
      'POST /notifications/read': (_) => empty(204),
    });

    testWidgets('müşteri Ana sayfa: rozet Me.unreadNotifications', (t) async {
      final semantics = t.ensureSemantics();
      await pumpApp(
        t,
        session: signedInWith(unread: 3),
        initial: '/c/home',
        handler: home(serverUnread: 3),
      );
      expect(find.byKey(const ValueKey('bell-badge')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byTooltip('Bildirimler, 3 okunmamış'), findsOneWidget);
      final sem = t.getSemantics(
        find.widgetWithIcon(IconButton, Icons.notifications_none),
      );
      // Ekran okuyucu adı: IconButton tooltip'i anlamsal ağaca `tooltip` olarak girer.
      expect(sem.tooltip, 'Bildirimler, 3 okunmamış');
      semantics.dispose();
    });

    testWidgets('99 üstü 99+ görünür', (t) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 150),
        initial: '/c/home',
        handler: home(serverUnread: 150),
      );
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);
    });

    testWidgets('tam 99 olduğu gibi görünür', (t) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 99),
        initial: '/c/home',
        handler: home(serverUnread: 99),
      );
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('okunmamış yoksa rozet yok; etiket yalın', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/home',
        handler: home(),
      );
      expect(find.byKey(const ValueKey('bell-badge')), findsNothing);
      expect(find.byTooltip('Bildirimler'), findsOneWidget);
    });

    testWidgets('EN etiket', (t) async {
      await pumpApp(
        t,
        locale: 'en',
        session: signedInWith(unread: 1),
        initial: '/c/home',
        handler: home(serverUnread: 1),
      );
      expect(find.byTooltip('Notifications, 1 unread'), findsOneWidget);
    });

    testWidgets('zil bildirim merkezini açar; okununca rozet azalır', (
      t,
    ) async {
      var serverUnread = 3;
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 3),
        initial: '/c/home',
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (_) => json(200, {'items': <Object>[]}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
          'GET /me': (_) =>
              json(200, {...meJson(), 'unreadNotifications': serverUnread}),
          'GET /notifications': (_) => json(
            200,
            page([
              nj(
                'n1',
                'OFFER_RECEIVED',
                params: {'title': 'T', 'proBusinessName': 'U', 'amount': 5},
                target: '/c/requests/r1/offers',
              ),
              nj('n2', 'PRO_APPROVED', target: '/c/home'),
              nj('n3', 'PRO_APPROVED', target: '/c/home'),
            ], unread: 3),
          ),
          'POST /notifications/read': (_) {
            serverUnread = 2;
            return empty(204);
          },
        }),
      );
      await t.tap(find.byTooltip('Bildirimler, 3 okunmamış'));
      await t.pumpAndSettle();
      expect(h.location, '/notifications');
      await t.tap(find.textContaining('talebine'));
      await t.pumpAndSettle();
      expect(h.location, '/c/requests/r1/offers');
      // Bildirim merkezi altta kalır.
      expect(h.container.read(sessionProvider).me!.unreadNotifications, 2);
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/notifications');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/c/home');
      expect(find.byTooltip('Bildirimler, 2 okunmamış'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('sekme köküne giden bildirim yığına ikinci kez eklenmez', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/c/home',
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (_) => json(200, {'items': <Object>[]}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
          'GET /notifications': (_) => json(
            200,
            page([nj('n1', 'PRO_APPROVED', target: '/c/home')], unread: 1),
          ),
          'POST /notifications/read': (_) => empty(204),
        }),
      );
      await t.tap(find.byTooltip('Bildirimler, 1 okunmamış'));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('Usta başvurun onaylandı'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(h.location, '/c/home');
      expect(find.byTooltip('Bildirimler'), findsOneWidget);
    });

    testWidgets('usta akışı üst çubuğunda da zil var', (t) async {
      await pumpApp(
        t,
        session: signedInWith(
          unread: 7,
          proStatus: 'APPROVED',
          mode: UserMode.pro,
        ),
        initial: '/p/feed',
        handler: routes({
          ...baseRoutes(),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
          'GET /me': (_) => json(200, {
            ...meJson(lastMode: 'PRO', pro: proJson('APPROVED')),
            'unreadNotifications': 7,
          }),
        }),
      );
      expect(find.byTooltip('Bildirimler, 7 okunmamış'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('aşağı çekince /me yenilenir ve rozet güncellenir', (t) async {
      var unread = 1;
      final h = await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/c/home',
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (_) => json(200, {'items': <Object>[]}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
          'GET /me': (_) =>
              json(200, {...meJson(), 'unreadNotifications': unread}),
        }),
      );
      expect(find.text('1'), findsOneWidget);
      unread = 5;
      await t.fling(find.byType(ListView).first, const Offset(0, 400), 1000);
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/me'), greaterThanOrEqualTo(1));
      expect(find.text('5'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  group('Derin bağlantıda geri sekme köküne gider', () {
    Handler any() => routes({
      ...baseRoutes(),
      'GET /requests': (_) => json(200, {'items': <Object>[]}),
      'GET /jobs': (_) => json(200, {'items': <Object>[]}),
    });

    const customerTargets = {
      '/c/requests/r1/offers': '/c/requests',
      '/c/jobs/j1': '/c/requests',
      // Sohbet, gelinen işe döner; işin geri tuşu sekme köküne gider.
      '/jobs/j1/chat': '/c/jobs/j1',
    };
    customerTargets.forEach((route, root) {
      testWidgets('müşteri $route', (t) async {
        final h = await pumpApp(
          t,
          session: signedInWith(),
          initial: route,
          handler: any(),
        );
        expect(h.location, route);
        await t.tap(find.byTooltip('Geri').first);
        await t.pumpAndSettle();
        expect(h.location, root);
      });
    });

    const proTargets = {
      '/p/requests/r1': '/p/feed',
      '/p/jobs/j1': '/p/jobs',
      '/p/offers': '/p/feed',
      '/p/earnings': '/p/profile',
    };
    proTargets.forEach((route, root) {
      testWidgets('usta $route', (t) async {
        final h = await pumpApp(
          t,
          session: signedInWith(proStatus: 'APPROVED', mode: UserMode.pro),
          initial: route,
          handler: any(),
        );
        expect(h.location, route);
        await t.tap(find.byTooltip('Geri').first);
        await t.pumpAndSettle();
        expect(h.location, root);
      });
    });

    testWidgets('/p/application -> profil', (t) async {
      final h = await pumpApp(
        t,
        session: signedInWith(proStatus: 'REJECTED', mode: UserMode.pro),
        initial: '/p/application',
        handler: any(),
      );
      await t.tap(find.byTooltip('Geri').first);
      await t.pumpAndSettle();
      expect(h.location, '/c/profile');
    });
  });

  // ---------------------------------------------------------------------------
  group('/p/application: yönetici kararı', () {
    Map<String, dynamic> app({
      required String status,
      String? note,
      required List<(String, String)> docs,
    }) => {
      ...applicationJson(status: status, note: note),
      'documents': [
        for (var i = 0; i < docs.length; i++)
          {
            'id': 'd${i + 1}',
            'type': docs[i].$1,
            'status': docs[i].$2,
            'media': mediaJson('m${i + 1}'),
          },
      ],
    };

    testWidgets(
      'NEEDS_DOCUMENTS: not görünür, yalnız reddedilen belge istenir',
      (t) async {
        Map<String, dynamic>? body;
        var up = 0;
        final h = await pumpApp(
          t,
          session: signedInWith(proStatus: 'NEEDS_DOCUMENTS'),
          initial: '/p/application',
          size: tall,
          overrides: [
            photoPickerProvider.overrideWithValue(FakePicker([1000])),
          ],
          handler: routes({
            ...baseRoutes(),
            'GET /pro/application': (_) => body != null
                ? json(200, applicationJson())
                : json(
                    200,
                    app(
                      status: 'NEEDS_DOCUMENTS',
                      note: 'Mesleki belge okunmuyor.',
                      docs: [
                        ('IDENTITY', 'ACCEPTED'),
                        ('TRADE_CERT', 'REJECTED'),
                        ('TAX', 'PENDING'),
                      ],
                    ),
                  ),
            'POST /media': (o) => uploadOk(o, 'up${++up}'),
            'POST /pro/application': (o) {
              body = o.data as Map<String, dynamic>;
              return json(201, applicationJson());
            },
            'GET /me': (_) => json(200, meJson(pro: proJson('PENDING_REVIEW'))),
          }),
        );
        expect(find.text('Mesleki belge okunmuyor.'), findsOneWidget);
        expect(find.text('Yeniden yüklemen gereken belgeler'), findsOneWidget);
        // Tek yükleme alanı: yalnız reddedilen belge.
        expect(find.widgetWithText(AppButton, 'Fotoğraf ekle'), findsOneWidget);
        expect(
          find.text('Kimlik'),
          findsOneWidget,
        ); // durum satırı, yükleme değil
        // Yüklemeden gönderilmez.
        await t.tap(btn('Yeniden gönder'));
        await t.pumpAndSettle();
        expect(
          find.text('Mesleki yeterlilik belgesini yükle.'),
          findsOneWidget,
        );
        expect(h.adapter.count('POST', '/pro/application'), 0);

        await t.tap(find.widgetWithText(AppButton, 'Fotoğraf ekle'));
        await t.pumpAndSettle();
        await t.tap(find.text('Galeriden seç'));
        await t.pumpAndSettle();
        await t.tap(btn('Yeniden gönder'));
        await t.pumpAndSettle();

        expect(h.adapter.count('POST', '/pro/application'), 1);
        expect(body!['businessName'], 'Usta Tesisat');
        expect(body!['categoryIds'], ['plumbing']);
        expect(body!['districtIds'], [1]);
        // Kabul edilen ve inceleniyor olanlar korunur; yalnız reddedilen yenilenir.
        expect(body!['documents'], [
          {'type': 'IDENTITY', 'mediaId': 'm1'},
          {'type': 'TAX', 'mediaId': 'm3'},
          {'type': 'TRADE_CERT', 'mediaId': 'up1'},
        ]);
        expect(h.adapter.count('POST', '/media'), 1);
        expect(
          (h.adapter.last('/media').data as FormData).fields.single.value,
          'PRO_DOCUMENT',
        );
        // Durum yenilenir: inceleniyor.
        expect(
          h.container.read(sessionProvider).me!.pro!.reviewStatus,
          ReviewStatus.pendingReview,
        );
        expect(find.text('Yeniden yüklemen gereken belgeler'), findsNothing);
      },
    );

    testWidgets('NEEDS_DOCUMENTS gönderim hatası ekranda gösterilir', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: signedInWith(proStatus: 'NEEDS_DOCUMENTS'),
        initial: '/p/application',
        size: tall,
        overrides: [
          photoPickerProvider.overrideWithValue(FakePicker([1000])),
        ],
        handler: routes({
          ...baseRoutes(),
          'GET /pro/application': (_) => json(
            200,
            app(
              status: 'NEEDS_DOCUMENTS',
              note: 'x',
              docs: [('IDENTITY', 'REJECTED')],
            ),
          ),
          'POST /media': (o) => uploadOk(o),
          'POST /pro/application': (_) => apiError(500, 'INTERNAL_ERROR'),
        }),
      );
      await t.tap(find.widgetWithText(AppButton, 'Fotoğraf ekle'));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      await t.tap(btn('Yeniden gönder'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/pro/application'), 1);
      expect(find.byType(MessageBanner), findsOneWidget);
      expect(btn('Yeniden gönder'), findsOneWidget);
    });

    testWidgets('REJECTED: not, açıklama ve yeniden başvuru yolu', (t) async {
      await pumpApp(
        t,
        session: signedInWith(proStatus: 'REJECTED'),
        initial: '/p/application',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /pro/application': (_) => json(
            200,
            app(
              status: 'REJECTED',
              note: 'Belgeler sahte görünüyor.',
              docs: [('IDENTITY', 'REJECTED')],
            ),
          ),
        }),
      );
      expect(find.text('Reddedildi'), findsWidgets);
      expect(find.text('Belgeler sahte görünüyor.'), findsOneWidget);
      expect(find.textContaining('Başvurun kabul edilmedi'), findsOneWidget);
      expect(btn('Yeniden başvur'), findsOneWidget);
      // Yükleme alanı bu ekranda yok; yeniden başvuru formu ayrı.
      expect(find.widgetWithText(AppButton, 'Fotoğraf ekle'), findsNothing);
    });

    group('SUSPENDED açıklama ekranı', () {
      Handler suspendedServer({String? note}) => routes({
        ...baseRoutes(),
        'GET /pro/application': (_) => json(
          200,
          app(
            status: 'SUSPENDED',
            note: note,
            docs: [('IDENTITY', 'ACCEPTED')],
          ),
        ),
        'PATCH /me': (o) => json(
          200,
          meJson(
            lastMode: (o.data as Map)['lastMode'] as String,
            pro: proJson('SUSPENDED'),
          ),
        ),
        'GET /requests': (_) => json(200, {'items': <Object>[]}),
        'GET /jobs': (_) => json(200, {'items': <Object>[]}),
      });

      testWidgets('usta modundaki askıdaki usta /p/application görür', (
        t,
      ) async {
        final h = await pumpApp(
          t,
          session: signedInWith(proStatus: 'SUSPENDED', mode: UserMode.pro),
          initial: '/p/feed',
          size: tall,
          overrides: [
            supportEmailProvider.overrideWithValue('yardim@ornek.test'),
          ],
          handler: suspendedServer(note: 'Tekrarlanan şikayetler.'),
        );
        expect(h.location, '/p/application');
        expect(find.text('Usta profilin askıya alındı'), findsOneWidget);
        expect(find.text('Neden askıya alındı?'), findsOneWidget);
        expect(find.text('Tekrarlanan şikayetler.'), findsOneWidget);
        expect(btn('Destekle iletişime geç'), findsOneWidget);
        expect(btn('Müşteri moduna geç'), findsOneWidget);
        // Askıdayken yeniden gönderim ve belge yükleme yok.
        expect(btn('Yeniden gönder'), findsNothing);
        expect(btn('Yeniden başvur'), findsNothing);
      });

      testWidgets('not yoksa genel neden metni', (t) async {
        await pumpApp(
          t,
          session: signedInWith(proStatus: 'SUSPENDED'),
          initial: '/p/application',
          size: tall,
          handler: suspendedServer(),
        );
        expect(
          find.textContaining('inceleme sonucunda askıya alındı'),
          findsOneWidget,
        );
      });

      testWidgets('destekle iletişim e-posta bağlantısı açar', (t) async {
        final opened = <Uri>[];
        await pumpApp(
          t,
          session: signedInWith(proStatus: 'SUSPENDED'),
          initial: '/p/application',
          size: tall,
          overrides: [
            supportEmailProvider.overrideWithValue('yardim@ornek.test'),
            urlOpenerProvider.overrideWithValue((u) async {
              opened.add(u);
              return true;
            }),
          ],
          handler: suspendedServer(),
        );
        await t.tap(btn('Destekle iletişime geç'));
        await t.pumpAndSettle();
        expect(opened.single.scheme, 'mailto');
        expect(opened.single.path, 'yardim@ornek.test');
        expect(
          opened.single.queryParameters['subject'],
          'Usta profilim askıya alındı',
        );
      });

      testWidgets('e-posta uygulaması açılamazsa bilgi verilir', (t) async {
        await pumpApp(
          t,
          session: signedInWith(proStatus: 'SUSPENDED'),
          initial: '/p/application',
          size: tall,
          overrides: [
            supportEmailProvider.overrideWithValue('yardim@ornek.test'),
            urlOpenerProvider.overrideWithValue((_) async => false),
          ],
          handler: suspendedServer(),
        );
        await t.tap(btn('Destekle iletişime geç'));
        await t.pumpAndSettle();
        expect(
          find.textContaining('E-posta uygulaması açılamadı'),
          findsOneWidget,
        );
        expect(find.textContaining('yardim@ornek.test'), findsOneWidget);
      });

      testWidgets('destek adresi tanımsızsa e-posta düğmesi ve adres yok', (
        t,
      ) async {
        final opened = <Uri>[];
        await pumpApp(
          t,
          session: signedInWith(proStatus: 'SUSPENDED'),
          initial: '/p/application',
          size: tall,
          overrides: [
            urlOpenerProvider.overrideWithValue((u) async {
              opened.add(u);
              return true;
            }),
          ],
          handler: suspendedServer(),
        );
        expect(kSupportEmail, isEmpty);
        expect(btn('Destekle iletişime geç'), findsNothing);
        expect(find.textContaining('@'), findsNothing);
        expect(find.textContaining('destek ekibine yaz'), findsOneWidget);
        expect(opened, isEmpty);
      });

      testWidgets('Müşteri moduna geç: son mod kaydedilir, Ana sayfa açılır', (
        t,
      ) async {
        final h = await pumpApp(
          t,
          session: signedInWith(proStatus: 'SUSPENDED', mode: UserMode.pro),
          initial: '/p/application',
          size: tall,
          handler: suspendedServer(),
        );
        await t.tap(btn('Müşteri moduna geç'));
        await t.pumpAndSettle();
        expect(h.adapter.last('/me').data, {'lastMode': 'CUSTOMER'});
        expect(h.location, '/c/home');
      });

      testWidgets('EN metinler', (t) async {
        await pumpApp(
          t,
          locale: 'en',
          session: signedInWith(proStatus: 'SUSPENDED'),
          initial: '/p/application',
          size: tall,
          overrides: [
            supportEmailProvider.overrideWithValue('yardim@ornek.test'),
          ],
          handler: suspendedServer(),
        );
        expect(find.text('Your pro profile is suspended'), findsOneWidget);
        expect(btn('Contact support'), findsOneWidget);
      });
    });
  });

  // ---------------------------------------------------------------------------
  group('Şikayet durum ekranı: karar', () {
    Handler complaintServer(Map<String, dynamic> complaint) => routes({
      ...baseRoutes(),
      'GET /complaints/5': (_) => json(200, complaint),
      'GET /jobs/j1': (_) => json(200, jobDetailJson()),
    });

    Map<String, dynamic> decided(
      String decision, {
      Map<String, dynamic> extra = const {},
    }) => {
      ...complaintJson(
        status: decision == 'RELEASE_TO_PRO' ? 'DISMISSED' : 'RESOLVED',
      ),
      'decision': decision,
      'decisionNote': 'Kanıtlar incelendi.',
      'decidedAt': '2026-11-10T08:30:00Z',
      ...extra,
    };

    testWidgets('sunucu tutarları: tür, not, iade ve usta payı', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: tall,
        handler: complaintServer(
          decided(
            'SPLIT_50_50',
            extra: {'refundAmount': 600.5, 'proAmount': 599.5},
          ),
        ),
      );
      expect(find.text('Yarı yarıya paylaşım (%50 / %50)'), findsOneWidget);
      expect(find.text('Kanıtlar incelendi.'), findsOneWidget);
      expect(find.text('İnceleme ekibinin notu'), findsOneWidget);
      expect(find.text('Tutarlar'), findsOneWidget);
      expect(find.text('Sana iade edilen'), findsOneWidget);
      expect(find.text('₺600,50'), findsOneWidget);
      expect(find.text('Ustaya aktarılan'), findsOneWidget);
      expect(find.text('₺599,50'), findsOneWidget);
      expect(find.textContaining('Karar tarihi'), findsOneWidget);
    });

    testWidgets('tutarlar gelmezse hesaplanmaz: tutar bilgisi yok', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: tall,
        handler: complaintServer(decided('FULL_REFUND')),
      );
      expect(find.text('Tam iade'), findsOneWidget);
      expect(find.text('Tutar bilgisi henüz yok.'), findsOneWidget);
      // İş toplamı (₺1.200) karar tutarı gibi gösterilmez.
      expect(find.text('Sana iade edilen'), findsNothing);
      expect(find.text('₺1.200'), findsNothing);
      expect(find.text('₺0'), findsNothing);
    });

    testWidgets('ustaya aktar: sunucunun tutarları olduğu gibi', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: tall,
        handler: complaintServer(
          decided(
            'RELEASE_TO_PRO',
            extra: {'refundAmount': 0, 'proAmount': 1080},
          ),
        ),
      );
      expect(find.text('Ödeme ustaya aktarıldı'), findsOneWidget);
      expect(find.text('₺0'), findsOneWidget);
      expect(find.text('₺1.080'), findsOneWidget);
      expect(find.text('Tutar bilgisi henüz yok.'), findsNothing);
    });

    testWidgets('EN karar metni', (t) async {
      await pumpApp(
        t,
        locale: 'en',
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: tall,
        handler: complaintServer(
          decided('FULL_REFUND', extra: {'refundAmount': 1200, 'proAmount': 0}),
        ),
      );
      expect(find.text('Full refund'), findsOneWidget);
      expect(find.text('Refunded to you'), findsOneWidget);
      expect(find.text('₺1,200'), findsOneWidget);
    });

    testWidgets('karar yokken karar kartı ve tutarlar görünmez', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: tall,
        handler: complaintServer(complaintJson(status: 'IN_REVIEW')),
      );
      expect(find.text('Tutarlar'), findsNothing);
      expect(find.text('Karar'), findsNothing);
    });

    testWidgets('iş okunamazsa ham karar ve not yine görünür', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: tall,
        handler: routes({
          ...baseRoutes(),
          'GET /complaints/5': (_) => json(200, decided('FULL_REFUND')),
        }),
      );
      expect(find.text('Tam iade'), findsOneWidget);
      expect(find.text('Kanıtlar incelendi.'), findsOneWidget);
      expect(find.text('Tutar bilgisi henüz yok.'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  group('Taşma (320 px, 2x yazı) ve dokunma alanı', () {
    const small = Size(320, 640);
    final longItems = [
      for (var i = 0; i < _cases.length; i++)
        nj(
          'n$i',
          _cases[i].type,
          params: _cases[i].params,
          target: _cases[i].target,
          read: i.isEven,
        ),
      nj('x', 'UNKNOWN_FUTURE'),
    ];

    testWidgets('/notifications dolu liste', (t) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 10),
        initial: '/notifications',
        size: small,
        textScale: 2,
        handler: notifServer(
          pages: {null: page(longItems, unread: 10, next: 'c')},
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('/notifications boş ve EN', (t) async {
      await pumpApp(
        t,
        locale: 'en',
        session: signedInWith(),
        initial: '/notifications',
        size: small,
        textScale: 2,
        handler: notifServer(pages: {null: page(const [])}),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('mod değişimi diyaloğu', (t) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 1, proStatus: 'APPROVED'),
        initial: '/notifications',
        size: small,
        textScale: 2,
        handler: notifServer(
          pages: {
            null: page([
              nj(
                'n1',
                'OFFER_ACCEPTED',
                params: {'title': 'Musluk', 'publicCode': 'B', 'amount': 1},
                target: '/p/jobs/j1',
              ),
            ], unread: 1),
          },
        ),
      );
      await t.tap(find.textContaining('Teklifin kabul edildi'));
      await t.pumpAndSettle();
      expect(find.text('Usta moduna geçip açalım mı?'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('Ana sayfa ve usta akışı zili 99+ ile', (t) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 500),
        initial: '/c/home',
        size: small,
        textScale: 2,
        handler: routes({
          ...baseRoutes(),
          'GET /requests': (_) => json(200, {'items': <Object>[]}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      expect(find.text('99+'), findsOneWidget);
      expect(t.takeException(), isNull);
      final box = t.getSize(find.byTooltip('Bildirimler, 500 okunmamış'));
      expect(box.width, greaterThanOrEqualTo(48));
      expect(box.height, greaterThanOrEqualTo(48));
    });

    testWidgets('usta akışı zili', (t) async {
      await pumpApp(
        t,
        session: signedInWith(
          unread: 500,
          proStatus: 'APPROVED',
          mode: UserMode.pro,
        ),
        initial: '/p/feed',
        size: small,
        textScale: 2,
        handler: routes({
          ...baseRoutes(),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
        }),
      );
      expect(find.text('99+'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    for (final st in [
      'NEEDS_DOCUMENTS',
      'REJECTED',
      'SUSPENDED',
      'PENDING_REVIEW',
    ]) {
      testWidgets('/p/application $st', (t) async {
        await pumpApp(
          t,
          session: signedInWith(proStatus: st),
          initial: '/p/application',
          size: small,
          textScale: 2,
          handler: routes({
            ...baseRoutes(),
            'GET /pro/application': (_) => json(200, {
              ...applicationJson(
                status: st,
                note: 'Uzun bir inceleme notu: belgelerin okunaklı olması gerekiyor, lütfen yeniden yükle.',
              ),
              'documents': [
                {
                  'id': 'a',
                  'type': 'IDENTITY',
                  'status': 'ACCEPTED',
                  'media': mediaJson('m1'),
                },
                {
                  'id': 'b',
                  'type': 'TRADE_CERT',
                  'status': 'REJECTED',
                  'media': mediaJson('m2'),
                },
                {
                  'id': 'c',
                  'type': 'CRIMINAL_RECORD',
                  'status': 'PENDING',
                  'media': mediaJson('m3'),
                },
              ],
            }),
          }),
        );
        expect(t.takeException(), isNull, reason: st);
      });
    }

    testWidgets('/c/complaints/5 kararlı', (t) async {
      await pumpApp(
        t,
        session: signedInWith(),
        initial: '/c/complaints/5',
        size: small,
        textScale: 2,
        handler: routes({
          ...baseRoutes(),
          'GET /complaints/5': (_) => json(200, {
            ...complaintJson(status: 'RESOLVED'),
            'decision': 'SPLIT_50_50',
            'decisionNote': 'Uzun bir gerekçe metni; iki taraf da kısmen haklı bulundu ve tutar paylaştırıldı.',
            'decidedAt': '2026-11-10T08:30:00Z',
            'refundAmount': 600,
            'proAmount': 600,
          }),
        }),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('bildirim satırı dokunma alanı en az 48', (t) async {
      await pumpApp(
        t,
        session: signedInWith(unread: 1),
        initial: '/notifications',
        handler: notifServer(
          pages: {
            null: page([nj('n', 'PRO_APPROVED', target: '/p/feed')], unread: 1),
          },
        ),
      );
      final size = t.getSize(find.byType(InkWell).first);
      expect(size.height, greaterThanOrEqualTo(48));
      final all = t.getSize(
        find.widgetWithText(AppButton, 'Tümünü okundu say'),
      );
      expect(all.height, greaterThanOrEqualTo(48));
    });
  });
}
