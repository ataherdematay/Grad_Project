import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/core/photos.dart';
import 'package:bitadilat_mobile/features/common/ui.dart' show MediaImage;
import 'package:bitadilat_mobile/features/jobs/customer_jobs.dart';
import 'package:bitadilat_mobile/features/jobs/job_ui.dart';
import 'package:bitadilat_mobile/features/jobs/pro_jobs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

/// Diyalogdaki onay düğmesi (formdaki aynı adlı düğmeyle karışmasın).
Finder dialogBtn(String label) => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.widgetWithText(FilledButton, label),
);

List<Override> get _now => [nowProvider.overrideWithValue(() => kNow)];

Handler jobServer(
  Map<String, dynamic> job, [
  Map<String, FutureOr<ResponseBody> Function(RequestOptions)> extra = const {},
]) => server3({
  'GET /jobs/j1': (_) => json(200, job),
  'GET /requests': (_) => json(200, {'items': <Object>[], 'nextCursor': null}),
  ...extra,
});

Future<Harness> openJob(
  WidgetTester t,
  String route,
  Map<String, dynamic> job, {
  bool pro = false,
  Map<String, FutureOr<ResponseBody> Function(RequestOptions)> extra = const {},
  List<Override> overrides = const [],
  String locale = 'tr',
}) => pumpApp(
  t,
  session: pro ? proSession3() : customerSession(),
  initial: route,
  size: tall,
  locale: locale,
  handler: jobServer(job, extra),
  overrides: [..._now, ...overrides],
);

void main() {
  group('Müşteri iş ekranı: düğmeler allowedActions listesinden', () {
    testWidgets('randevulu iş: değiştir, iptal, sohbet; onay ve şikayet yok', (
      t,
    ) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(actions: ['CHAT', 'CANCEL', 'PROPOSE_SLOT']),
      );
      expect(find.text('Randevun onaylandı'), findsWidgets);
      expect(btn('Randevuyu değiştir'), findsOneWidget);
      expect(btn('İşi iptal et'), findsOneWidget);
      expect(find.text('Mesajlar'), findsOneWidget);
      expect(btn('Teslimi onayla'), findsNothing);
      expect(btn('Sorun bildir'), findsNothing);
      expect(btn('Puan ver'), findsNothing);
    });

    testWidgets('onay bekleyen iş: onayla ve sorun bildir; iptal yok', (
      t,
    ) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(
          status: 'WORK_FINISHED',
          actions: ['CONFIRM_COMPLETION', 'COMPLAIN', 'CHAT'],
          autoCompleteAt: '2026-11-12T09:00:00Z',
        ),
      );
      expect(btn('Teslimi onayla'), findsOneWidget);
      expect(btn('Sorun bildir'), findsOneWidget);
      expect(btn('İşi iptal et'), findsNothing);
      expect(btn('Randevuyu değiştir'), findsNothing);
      expect(find.textContaining('otomatik onaylanır'), findsOneWidget);
      expect(find.text('Onayın bekleniyor'), findsWidgets);
    });

    testWidgets('tamamlanmış iş: puan ver; liste boşsa hiç eylem yok', (
      t,
    ) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(status: 'COMPLETED', actions: ['REVIEW']),
      );
      expect(btn('Puan ver'), findsOneWidget);
      expect(btn('İşi iptal et'), findsNothing);
    });

    testWidgets('eylem listesi boş: eylem düğmesi yok', (t) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(status: 'COMPLETED', actions: []),
      );
      for (final label in [
        'Puan ver',
        'İşi iptal et',
        'Teslimi onayla',
        'Sorun bildir',
        'Randevu seç',
        'Randevuyu değiştir',
        'Kabul et',
      ]) {
        expect(btn(label), findsNothing, reason: label);
      }
      expect(find.text('Mesajlar'), findsNothing);
      expect(find.text('Tamamlandı'), findsWidgets);
    });

    testWidgets('puan verilmiş iş puanı gösterir', (t) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(
          status: 'COMPLETED',
          actions: [],
          review: {
            'id': 3,
            'rating': 4,
            'tags': ['ON_TIME'],
            'comment': 'Hızlı ve temiz çalıştı.',
            'authorDisplay': 'Ali Y.',
            'createdAt': '2026-11-10T10:00:00Z',
          },
        ),
      );
      expect(find.text('Hızlı ve temiz çalıştı.'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('durum başlığı, adres, döküm, ödeme ve zaman çizelgesi', (
      t,
    ) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(status: 'AWAITING_APPOINTMENT', actions: ['CHAT']),
      );
      expect(find.text('Ustanın onayı bekleniyor'), findsWidgets);
      expect(find.text('Moda Cd. 1/3'), findsOneWidget);
      expect(find.text('Kapı notu: Zil bozuk'), findsOneWidget);
      expect(find.text('Teklif özeti'), findsOneWidget);
      expect(find.text('₺900'), findsOneWidget);
      expect(find.text('₺300'), findsOneWidget);
      expect(find.text('Güvence havuzunda'), findsOneWidget);
      expect(find.text('Arıza fotoğrafı'), findsOneWidget);
      expect(find.byType(MediaImage), findsWidgets);
      // Müşteri hizmet bedelini görmez.
      expect(find.text('Hizmet bedeli (%10)'), findsNothing);
    });

    testWidgets('şikayetli iş: kart ve durum etiketi', (t) async {
      await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(
          status: 'DISPUTED',
          actions: ['CHAT'],
          escrow: 'DISPUTED',
          complaint: {'id': '5', 'publicCode': 'SK-1001', 'status': 'OPEN'},
        ),
        extra: {'GET /complaints/5': (_) => json(200, complaintJson())},
      );
      expect(find.text('Şikayet inceleniyor'), findsWidgets);
      expect(find.text('Şikayet SK-1001'), findsOneWidget);
      await t.tap(find.text('Şikayet SK-1001'));
      await t.pumpAndSettle();
      expect(find.text('SK-1001'), findsOneWidget);
    });

    testWidgets('ustanın önerisi: kabul et isteği gider', (t) async {
      final h = await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(
          status: 'AWAITING_APPOINTMENT',
          actions: ['ACCEPT_PROPOSAL', 'PROPOSE_SLOT', 'CHAT'],
          pendingProposal: {
            'id': 99,
            'proposedBy': 'PRO',
            'slotFrom': '2026-11-12T07:00:00Z',
            'slotTo': '2026-11-12T09:00:00Z',
            'createdAt': '2026-11-10T07:00:00Z',
          },
        ),
        extra: {
          'POST /jobs/j1/appointment/proposals/99/accept': (_) =>
              json(200, jobDetailJson()),
        },
      );
      expect(find.text('Usta bu aralığı önerdi'), findsOneWidget);
      expect(btn('Başka aralık seç'), findsOneWidget);
      await t.tap(btn('Kabul et'));
      await t.pumpAndSettle();
      expect(
        h.adapter.count('POST', '/jobs/j1/appointment/proposals/99/accept'),
        1,
      );
    });

    testWidgets('ILLEGAL_STATE: açıklama ve yenileme', (t) async {
      final h = await openJob(
        t,
        '/c/jobs/j1',
        jobDetailJson(
          actions: ['ACCEPT_PROPOSAL'],
          pendingProposal: {
            'id': 99,
            'proposedBy': 'PRO',
            'slotFrom': '2026-11-12T07:00:00Z',
            'slotTo': '2026-11-12T09:00:00Z',
            'createdAt': '2026-11-10T07:00:00Z',
          },
        ),
        extra: {
          'POST /jobs/j1/appointment/proposals/99/accept': (_) =>
              apiError(409, 'ILLEGAL_STATE'),
        },
      );
      final before = h.adapter.count('GET', '/jobs/j1');
      await t.tap(btn('Kabul et'));
      await t.pumpAndSettle();
      expect(
        find.text('Bu işlem artık yapılamıyor, ekran güncellendi.'),
        findsOneWidget,
      );
      expect(h.adapter.count('GET', '/jobs/j1'), greaterThan(before));
    });
  });

  group('Usta iş ekranı (40)', () {
    Future<Harness> openPro(
      WidgetTester t,
      List<String> actions, {
      String status = 'SCHEDULED',
      Map<String, FutureOr<ResponseBody> Function(RequestOptions)> extra =
          const {},
      List<Override> overrides = const [],
      Map<String, dynamic>? proposal,
    }) => openJob(
      t,
      '/p/jobs/j1',
      jobDetailJson(
        role: 'PRO',
        status: status,
        actions: actions,
        pendingProposal: proposal,
      ),
      pro: true,
      extra: extra,
      overrides: overrides,
    );

    testWidgets('SCHEDULED: adrese ulaştım ve iptal; başladım/bitirdim yok', (
      t,
    ) async {
      await openPro(t, ['MARK_ARRIVED', 'CANCEL', 'CHAT']);
      expect(btn('Adrese ulaştım'), findsOneWidget);
      expect(btn('İşi iptal et'), findsOneWidget);
      expect(btn('İşe başladım'), findsNothing);
      expect(btn('İşi bitirdim'), findsNothing);
      expect(btn('Not veya fotoğraf ekle'), findsNothing);
      // Usta kazancı: hizmet bedeli ve net.
      expect(find.text('Hizmet bedeli (%10)'), findsWidgets);
      expect(find.text('₺1.080'), findsWidgets);
      expect(find.text('Moda Cd. 1/3'), findsOneWidget);
      expect(find.text('Kapı notu: Zil bozuk'), findsOneWidget);
      expect(btn('Haritada aç'), findsOneWidget);
    });

    testWidgets('ARRIVED: başladım ve not; adrese ulaştım yok', (t) async {
      await openPro(t, ['START_WORK', 'ADD_NOTE', 'CANCEL'], status: 'ARRIVED');
      expect(btn('İşe başladım'), findsOneWidget);
      expect(btn('Not veya fotoğraf ekle'), findsOneWidget);
      expect(btn('Adrese ulaştım'), findsNothing);
      expect(btn('İşi bitirdim'), findsNothing);
    });

    testWidgets('IN_PROGRESS: bitirdim ve not; iptal yok', (t) async {
      await openPro(t, ['FINISH_WORK', 'ADD_NOTE'], status: 'IN_PROGRESS');
      expect(btn('İşi bitirdim'), findsOneWidget);
      expect(btn('Not veya fotoğraf ekle'), findsOneWidget);
      expect(btn('İşi iptal et'), findsNothing);
    });

    testWidgets('müşteri önerisi: kabul et ve yeni aralık öner', (t) async {
      await openPro(
        t,
        ['ACCEPT_PROPOSAL', 'PROPOSE_SLOT'],
        status: 'AWAITING_APPOINTMENT',
        proposal: {
          'id': 77,
          'proposedBy': 'CUSTOMER',
          'slotFrom': '2026-11-12T07:00:00Z',
          'slotTo': '2026-11-12T09:00:00Z',
          'createdAt': '2026-11-10T07:00:00Z',
        },
      );
      expect(find.text('Müşteri bu aralığı önerdi'), findsOneWidget);
      expect(btn('Kabul et'), findsOneWidget);
      expect(btn('Yeni aralık öner'), findsOneWidget);
    });

    testWidgets('adrese ulaştım isteği gider', (t) async {
      final h = await openPro(
        t,
        ['MARK_ARRIVED'],
        extra: {
          'POST /jobs/j1/arrived': (_) =>
              json(200, jobDetailJson(role: 'PRO', status: 'ARRIVED')),
        },
      );
      await t.tap(btn('Adrese ulaştım'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/jobs/j1/arrived'), 1);
    });

    testWidgets('işe başladım isteği gider', (t) async {
      final h = await openPro(
        t,
        ['START_WORK'],
        status: 'ARRIVED',
        extra: {
          'POST /jobs/j1/start': (_) =>
              json(200, jobDetailJson(role: 'PRO', status: 'IN_PROGRESS')),
        },
      );
      await t.tap(btn('İşe başladım'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/jobs/j1/start'), 1);
    });

    testWidgets('Haritada aç sistem harita bağlantısını açar', (t) async {
      final opened = <Uri>[];
      await openPro(
        t,
        ['MARK_ARRIVED'],
        overrides: [
          urlOpenerProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
      );
      await t.tap(btn('Haritada aç'));
      await t.pumpAndSettle();
      expect(opened, hasLength(1));
      expect(
        opened.single.queryParameters.values.join(),
        contains('Moda Cd. 1/3'),
      );
      expect(opened.single.scheme, 'https');
    });

    testWidgets('harita açılamazsa bilgi verilir', (t) async {
      await openPro(
        t,
        ['MARK_ARRIVED'],
        overrides: [urlOpenerProvider.overrideWithValue((uri) async => false)],
      );
      await t.tap(btn('Haritada aç'));
      await t.pumpAndSettle();
      expect(find.text('Harita uygulaması açılamadı.'), findsOneWidget);
    });

    testWidgets('ILLEGAL_STATE: açıklama ve yenileme', (t) async {
      final h = await openPro(
        t,
        ['MARK_ARRIVED'],
        extra: {'POST /jobs/j1/arrived': (_) => apiError(409, 'ILLEGAL_STATE')},
      );
      final before = h.adapter.count('GET', '/jobs/j1');
      await t.tap(btn('Adrese ulaştım'));
      await t.pumpAndSettle();
      expect(
        find.text('Bu işlem artık yapılamıyor, ekran güncellendi.'),
        findsOneWidget,
      );
      expect(h.adapter.count('GET', '/jobs/j1'), greaterThan(before));
    });
  });

  group('Harita bağlantısı', () {
    const address = JobAddress(
      districtName: 'Kadıköy',
      neighborhood: 'Moda',
      lineFull: 'Moda Cd. 1/3',
    );
    test('iOS Apple Maps, Android Google Maps', () {
      final ios = mapsSearchUri(address, platform: TargetPlatform.iOS);
      expect(ios.host, 'maps.apple.com');
      expect(ios.queryParameters['q'], 'Moda Cd. 1/3, Moda, Kadıköy');
      final android = mapsSearchUri(address, platform: TargetPlatform.android);
      expect(android.host, 'www.google.com');
      expect(android.path, '/maps/search/');
      expect(android.queryParameters['query'], 'Moda Cd. 1/3, Moda, Kadıköy');
    });
  });

  group('Randevu (21, 22)', () {
    Map<String, dynamic> job({
      Map<String, dynamic>? proposal,
      List<String> actions = const ['PROPOSE_SLOT'],
      String role = 'CUSTOMER',
    }) => jobDetailJson(
      role: role,
      status: 'AWAITING_APPOINTMENT',
      actions: actions,
      pendingProposal: proposal,
    );

    testWidgets('7 gün, sabit aralıklar, teklifteki aralık önceden seçili', (
      t,
    ) async {
      final h = await openJob(
        t,
        '/c/jobs/j1/appointment',
        job(),
        extra: {
          'POST /jobs/j1/appointment/proposals': (_) =>
              json(200, jobDetailJson()),
        },
      );
      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.text('Bugün'), findsOneWidget);
      // Teklif yarın 10:00-12:00: yarının aralıkları görünür.
      expect(find.text('Yarın'), findsOneWidget);
      for (final s in [
        '09:00-11:00',
        '10:00-12:00',
        '11:00-13:00',
        '14:00-16:00',
        '16:00-18:00',
      ]) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      expect(find.text('Teklifteki varış aralığı'), findsOneWidget);
      // Seçim yapmadan gönder: teklifin aralığı gider.
      await t.tap(btn('Randevu iste'));
      await t.pumpAndSettle();
      final body = h.adapter.last('/jobs/j1/appointment/proposals').data as Map;
      expect(body['slotFrom'], utc(offerFrom));
      expect(body['slotTo'], utc(offerTo));
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('başka aralık seçilir ve o gönderilir', (t) async {
      final h = await openJob(
        t,
        '/c/jobs/j1/appointment',
        job(),
        extra: {
          'POST /jobs/j1/appointment/proposals': (_) =>
              json(200, jobDetailJson()),
        },
      );
      await t.tap(find.text('14:00-16:00'));
      await t.pumpAndSettle();
      await t.tap(btn('Randevu iste'));
      await t.pumpAndSettle();
      final body = h.adapter.last('/jobs/j1/appointment/proposals').data as Map;
      expect(body['slotFrom'], utc(DateTime(2026, 11, 11, 14)));
      expect(body['slotTo'], utc(DateTime(2026, 11, 11, 16)));
    });

    testWidgets('bugün: başlangıcı geçmiş aralık sunulmaz', (t) async {
      await openJob(t, '/c/jobs/j1/appointment', job());
      await t.tap(find.text('Bugün'));
      await t.pumpAndSettle();
      // Saat 09:00: 09:00-11:00 geçerli değil (başlangıç gelecekte olmalı).
      expect(find.text('09:00-11:00'), findsNothing);
      expect(find.text('11:00-13:00'), findsOneWidget);
    });

    testWidgets('ustanın önerisi: kabul et', (t) async {
      final h = await openJob(
        t,
        '/c/jobs/j1/appointment',
        job(
          actions: ['ACCEPT_PROPOSAL', 'PROPOSE_SLOT'],
          proposal: {
            'id': 99,
            'proposedBy': 'PRO',
            'slotFrom': '2026-11-12T07:00:00Z',
            'slotTo': '2026-11-12T09:00:00Z',
            'createdAt': '2026-11-10T07:00:00Z',
          },
        ),
        extra: {
          'POST /jobs/j1/appointment/proposals/99/accept': (_) =>
              json(200, jobDetailJson()),
        },
      );
      expect(find.text('Usta bu aralığı önerdi'), findsOneWidget);
      await t.tap(btn('Kabul et'));
      await t.pumpAndSettle();
      expect(
        h.adapter.count('POST', '/jobs/j1/appointment/proposals/99/accept'),
        1,
      );
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('randevu kapalıysa açıklama var, gönderme yok', (t) async {
      await openJob(t, '/c/jobs/j1/appointment', job(actions: []));
      expect(find.textContaining('randevu işlemi yapılamıyor'), findsOneWidget);
      expect(btn('Randevu iste'), findsNothing);
    });

    testWidgets('geri tuşu iş ekranına döner (ödemeden sonra)', (t) async {
      final h = await openJob(t, '/c/jobs/j1/appointment', job());
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('usta: yeni aralık önerir, iş ekranına döner', (t) async {
      final h = await openJob(
        t,
        '/p/jobs/j1/appointment',
        job(role: 'PRO'),
        pro: true,
        extra: {
          'POST /jobs/j1/appointment/proposals': (_) =>
              json(200, jobDetailJson(role: 'PRO')),
        },
      );
      expect(find.text('Teklifindeki varış aralığı'), findsOneWidget);
      await t.tap(find.text('16:00-18:00'));
      await t.pumpAndSettle();
      await t.tap(btn('Yeni aralık öner'));
      await t.pumpAndSettle();
      final body = h.adapter.last('/jobs/j1/appointment/proposals').data as Map;
      expect(body['slotFrom'], utc(DateTime(2026, 11, 11, 16)));
      expect(h.location, '/p/jobs/j1');
    });

    testWidgets('usta: müşterinin önerisini kabul eder', (t) async {
      final h = await openJob(
        t,
        '/p/jobs/j1/appointment',
        job(
          role: 'PRO',
          actions: ['ACCEPT_PROPOSAL', 'PROPOSE_SLOT'],
          proposal: {
            'id': 77,
            'proposedBy': 'CUSTOMER',
            'slotFrom': '2026-11-12T07:00:00Z',
            'slotTo': '2026-11-12T09:00:00Z',
            'createdAt': '2026-11-10T07:00:00Z',
          },
        ),
        pro: true,
        extra: {
          'POST /jobs/j1/appointment/proposals/77/accept': (_) =>
              json(200, jobDetailJson(role: 'PRO')),
        },
      );
      expect(find.text('Müşteri bu aralığı önerdi'), findsOneWidget);
      await t.tap(btn('Kabul et'));
      await t.pumpAndSettle();
      expect(
        h.adapter.count('POST', '/jobs/j1/appointment/proposals/77/accept'),
        1,
      );
      expect(h.location, '/p/jobs/j1');
    });

    test('aralık üreteci: 7 gün, 4 aralık, geçmiş atılır', () {
      final days = upcomingSlotDays(DateTime(2026, 11, 10, 9));
      expect(days, hasLength(7));
      expect(days.first.value.map(slotLabel), [
        '11:00-13:00',
        '14:00-16:00',
        '16:00-18:00',
      ]);
      expect(days[1].value.map(slotLabel), [
        '09:00-11:00',
        '11:00-13:00',
        '14:00-16:00',
        '16:00-18:00',
      ]);
      // Gün sonunda bugün hiç aralık kalmaz.
      expect(upcomingSlotDays(DateTime(2026, 11, 10, 19)), hasLength(6));
    });
  });

  group('İptal (26)', () {
    testWidgets('müşteri: gerekçe zorunlu; onay metni iade tutarını yazar', (
      t,
    ) async {
      final h = await openJob(
        t,
        '/c/jobs/j1/cancel',
        jobDetailJson(actions: ['CANCEL', 'PROPOSE_SLOT']),
        extra: {
          'POST /jobs/j1/cancel': (_) =>
              json(200, jobDetailJson(status: 'CANCELLED', actions: [])),
        },
      );
      expect(
        find.textContaining('₺1.200 kartına iade edilir ve talebin kapanır'),
        findsOneWidget,
      );
      await t.tap(btn('İptal et'));
      await t.pumpAndSettle();
      expect(find.text('Devam etmek için bir gerekçe seç.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await t.tap(find.text('Planlarım değişti'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextFormField), 'Taşınıyorum');
      await t.tap(btn('İptal et'));
      await t.pumpAndSettle();
      expect(
        find.text('Bu işlem geri alınamaz. ₺1.200 kartına iade edilir.'),
        findsOneWidget,
      );
      await t.tap(dialogBtn('İşi iptal et'));
      await t.pumpAndSettle();
      final body = h.adapter.last('/jobs/j1/cancel').data as Map;
      expect(body, {'reason': 'PLANS_CHANGED', 'note': 'Taşınıyorum'});
      expect(h.location, '/c/requests');
    });

    testWidgets('vazgeçilirse istek gitmez', (t) async {
      final h = await openJob(
        t,
        '/c/jobs/j1/cancel',
        jobDetailJson(actions: ['CANCEL']),
      );
      await t.tap(find.text('Usta ulaşılamıyor'));
      await t.tap(btn('İptal et'));
      await t.pumpAndSettle();
      await t.tap(find.text('Vazgeç'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/jobs/j1/cancel'), 0);
      expect(h.location, '/c/jobs/j1/cancel');
    });

    testWidgets('iade edilmiş kısım düşülür', (t) async {
      final job = jobDetailJson(actions: ['CANCEL']);
      (job['payment'] as Map<String, dynamic>)['refundedAmount'] = 200.0;
      await openJob(t, '/c/jobs/j1/cancel', job);
      expect(find.textContaining('₺1.000 kartına iade edilir'), findsOneWidget);
    });

    testWidgets('iptal edilemiyorsa açıklama var', (t) async {
      await openJob(
        t,
        '/c/jobs/j1/cancel',
        jobDetailJson(status: 'IN_PROGRESS', actions: ['CHAT']),
      );
      expect(find.textContaining('artık iptal edilemiyor'), findsOneWidget);
      expect(btn('İptal et'), findsNothing);
    });

    testWidgets('usta: usta gerekçeleri, iade ve talep yeniden açılır', (
      t,
    ) async {
      final h = await openJob(
        t,
        '/p/jobs/j1/cancel',
        jobDetailJson(role: 'PRO', actions: ['CANCEL']),
        pro: true,
        extra: {
          'POST /jobs/j1/cancel': (_) => json(
            200,
            jobDetailJson(role: 'PRO', status: 'CANCELLED', actions: []),
          ),
        },
      );
      expect(find.text('Takvimim uygun değil'), findsOneWidget);
      expect(find.text('Planlarım değişti'), findsNothing);
      await t.tap(find.text('Müşteriye ulaşamıyorum'));
      await t.tap(btn('İptal et'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'Bu işlem geri alınamaz. Müşteriye ₺1.200 iade edilir ve talep yeniden açılır.',
        ),
        findsOneWidget,
      );
      await t.tap(dialogBtn('İşi iptal et'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/jobs/j1/cancel').data, {
        'reason': 'CUSTOMER_UNREACHABLE',
      });
      expect(h.location, '/p/jobs/j1/cancelled');
      expect(
        find.text(
          'Müşteriye iade yapıldı ve talep yeniden açıldı. İptaller profilinde görünür.',
        ),
        findsOneWidget,
      );
    });

    test('onay metni iade tutarını içerir (EN)', () {
      final job = JobDetail.fromJson(jobDetailJson());
      expect(refundAmount(job), const Money.lira(1200));
    });
  });

  group('Teslim onayı (27) ve puan (28)', () {
    Map<String, dynamic> finished({
      List<String> actions = const ['CONFIRM_COMPLETION', 'COMPLAIN', 'CHAT'],
    }) => jobDetailJson(
      status: 'WORK_FINISHED',
      actions: actions,
      autoCompleteAt: '2026-11-12T09:00:00Z',
      timeline: [
        eventJson(
          1,
          to: 'WORK_FINISHED',
          note: 'Vana değişti, sızıntı yok.',
          actor: 'PRO',
        ),
        eventJson(2, type: 'PHOTO', photo: mediaJson('ph9'), actor: 'PRO'),
      ],
    );

    testWidgets('ustanın notu, fotoğrafı ve otomatik onay tarihi', (t) async {
      await openJob(t, '/c/jobs/j1/complete', finished());
      expect(find.text('Vana değişti, sızıntı yok.'), findsOneWidget);
      expect(find.byType(MediaImage), findsOneWidget);
      expect(find.textContaining('Onaylamazsan'), findsOneWidget);
      expect(find.textContaining('otomatik onaylanır'), findsOneWidget);
    });

    testWidgets('onay diyaloğu tutarı anlatır; onaylanınca puana geçilir', (
      t,
    ) async {
      var confirmed = false;
      final completed = jobDetailJson(status: 'COMPLETED', actions: ['REVIEW']);
      final h = await openJob(
        t,
        '/c/jobs/j1/complete',
        finished(),
        extra: {
          'GET /jobs/j1': (_) => json(200, confirmed ? completed : finished()),
          'POST /jobs/j1/confirm': (_) {
            confirmed = true;
            return json(200, completed);
          },
        },
      );
      await t.tap(btn('Onayla'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'Onaylarsan ₺1.200 güvence havuzundan Mavi Hat adlı ustaya aktarılır. Bu işlem geri alınamaz.',
        ),
        findsOneWidget,
      );
      expect(h.adapter.count('POST', '/jobs/j1/confirm'), 0);
      await t.tap(dialogBtn('Onayla ve aktar'));
      await t.pumpAndSettle();
      expect(h.adapter.count('POST', '/jobs/j1/confirm'), 1);
      expect(h.location, '/c/jobs/j1/review');
      expect(find.text('Yayınla'), findsOneWidget);
      // Geri tuşu onay formuna değil iş ekranına döner.
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets(
      'onaydan vazgeçilirse istek gitmez; sorun bildir şikayete gider',
      (t) async {
        final h = await openJob(t, '/c/jobs/j1/complete', finished());
        await t.tap(btn('Onayla'));
        await t.pumpAndSettle();
        await t.tap(find.text('Vazgeç'));
        await t.pumpAndSettle();
        expect(h.adapter.count('POST', '/jobs/j1/confirm'), 0);
        await t.tap(btn('Sorun bildir'));
        await t.pumpAndSettle();
        expect(h.location, '/c/jobs/j1/complaint');
      },
    );

    testWidgets('onay beklemiyorsa düğme yok', (t) async {
      await openJob(t, '/c/jobs/j1/complete', finished(actions: ['CHAT']));
      expect(btn('Onayla'), findsNothing);
      expect(find.textContaining('onay beklemiyor'), findsOneWidget);
    });

    Map<String, dynamic> reviewable() =>
        jobDetailJson(status: 'COMPLETED', actions: ['REVIEW']);

    testWidgets('puan: yıldız zorunlu, istek gitmez', (t) async {
      final h = await openJob(t, '/c/jobs/j1/review', reviewable());
      await t.tap(btn('Yayınla'));
      await t.pumpAndSettle();
      expect(find.text('Devam etmek için yıldız ver.'), findsOneWidget);
      expect(h.adapter.count('POST', '/jobs/j1/review'), 0);
    });

    testWidgets(
      'puan: yıldız, etiket, yorum, anonim gövdesi; iş ekranına döner',
      (t) async {
        final h = await openJob(
          t,
          '/c/jobs/j1/review',
          reviewable(),
          extra: {
            'POST /jobs/j1/review': (_) =>
                json(200, jobDetailJson(status: 'COMPLETED', actions: [])),
          },
        );
        await t.tap(find.byTooltip('4 yıldız'));
        await t.tap(find.text('Zamanında geldi'));
        await t.tap(find.text('Saygılıydı'));
        await t.enterText(find.byType(TextFormField), 'Çok iyi');
        await t.tap(find.byType(Switch));
        await t.pumpAndSettle();
        await t.tap(btn('Yayınla'));
        await t.pumpAndSettle();
        expect(h.adapter.last('/jobs/j1/review').data, {
          'rating': 4,
          'tags': ['ON_TIME', 'POLITE'],
          'comment': 'Çok iyi',
          'anonymous': true,
        });
        expect(h.location, '/c/jobs/j1');
      },
    );

    testWidgets('daha önce puanlanmış iş: bilgi ekranı', (t) async {
      await openJob(
        t,
        '/c/jobs/j1/review',
        jobDetailJson(
          status: 'COMPLETED',
          actions: [],
          review: {
            'id': 3,
            'rating': 5,
            'tags': <String>[],
            'comment': null,
            'authorDisplay': 'Ali Y.',
            'createdAt': '2026-11-10T10:00:00Z',
          },
        ),
      );
      expect(find.text('Puanını verdin'), findsOneWidget);
      expect(btn('Yayınla'), findsNothing);
    });

    testWidgets('puan hatası: ILLEGAL_STATE açıklaması', (t) async {
      await openJob(
        t,
        '/c/jobs/j1/review',
        reviewable(),
        extra: {'POST /jobs/j1/review': (_) => apiError(409, 'ILLEGAL_STATE')},
      );
      await t.tap(find.byTooltip('5 yıldız'));
      await t.tap(btn('Yayınla'));
      await t.pumpAndSettle();
      expect(
        find.text('Bu işlem artık yapılamıyor, ekran güncellendi.'),
        findsOneWidget,
      );
    });
  });

  group('Şikayet (29, 30)', () {
    Map<String, dynamic> disputable() =>
        jobDetailJson(status: 'IN_PROGRESS', actions: ['COMPLAIN', 'CHAT']);

    List<Override> picker() => [
      photoPickerProvider.overrideWithValue(FakePicker([200, 300])),
    ];

    Future<void> fillForm(
      WidgetTester t, {
      String text = 'Usta anlaşılandan fazla ücret istedi.',
    }) async {
      await t.tap(find.text('Ek ücret istendi'));
      await t.enterText(find.byType(TextFormField), text);
      await t.tap(find.byType(Checkbox));
      await t.pumpAndSettle();
    }

    testWidgets('doğrulama: neden, 20 karakter, onay kutusu', (t) async {
      final h = await openJob(t, '/c/jobs/j1/complaint', disputable());
      await t.tap(btn('Şikayeti gönder'));
      await t.pumpAndSettle();
      expect(find.text('Devam etmek için bir gerekçe seç.'), findsOneWidget);
      expect(
        find.text(
          'Açıklama en az 20 karakter olmalı. Ne olduğunu biraz daha anlat.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Devam etmek için bu onayı vermelisin.'),
        findsOneWidget,
      );
      expect(h.adapter.count('POST', '/jobs/j1/complaint'), 0);

      await t.tap(find.text('Ek ücret istendi'));
      await t.enterText(find.byType(TextFormField), 'Kısa açıklama');
      await t.tap(find.byType(Checkbox));
      await t.tap(btn('Şikayeti gönder'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'Açıklama en az 20 karakter olmalı. Ne olduğunu biraz daha anlat.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('en çok 5 kanıt fotoğrafı', (t) async {
      await openJob(
        t,
        '/c/jobs/j1/complaint',
        disputable(),
        overrides: [
          photoPickerProvider.overrideWithValue(
            FakePicker([10, 20, 30, 40, 50, 60]),
          ),
        ],
        extra: {'POST /media': (o) => uploadOk(o)},
      );
      for (var i = 0; i < 5; i++) {
        await t.tap(btn(i == 0 ? 'Fotoğraf ekle' : 'Fotoğraf ekle'));
        await t.pumpAndSettle();
        await t.tap(find.text('Galeriden seç'));
        await t.pumpAndSettle();
      }
      expect(find.text('En fazla 5 fotoğraf eklenebilir'), findsOneWidget);
    });

    testWidgets('onay diyaloğu, COMPLAINT yüklemesi ve gövde; durum ekranı', (
      t,
    ) async {
      var n = 0;
      final h = await openJob(
        t,
        '/c/jobs/j1/complaint',
        disputable(),
        overrides: picker(),
        extra: {
          'POST /media': (o) => uploadOk(o, 'ev${++n}'),
          'POST /jobs/j1/complaint': (_) => json(201, complaintJson()),
          'GET /complaints/5': (_) => json(200, complaintJson()),
        },
      );
      await t.tap(btn('Fotoğraf ekle'));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      final upload = h.adapter.last('/media').data as FormData;
      expect(
        upload.fields.firstWhere((f) => f.key == 'purpose').value,
        'COMPLAINT',
      );
      await fillForm(t);
      await t.tap(btn('Şikayeti gönder'));
      await t.pumpAndSettle();
      expect(find.text('Şikayeti göndermek istiyor musun?'), findsOneWidget);
      expect(h.adapter.count('POST', '/jobs/j1/complaint'), 0);
      await t.tap(dialogBtn('Şikayeti gönder'));
      await t.pumpAndSettle();
      final body = h.adapter.last('/jobs/j1/complaint').data as Map;
      expect(body['reason'], 'EXTRA_CHARGE');
      expect(body['description'], 'Usta anlaşılandan fazla ücret istedi.');
      expect(body['evidenceIds'], ['ev1']);
      expect(h.location, '/c/complaints/5');
      expect(find.text('SK-1001'), findsOneWidget);
      expect(find.text('Alındı'), findsOneWidget);
      // Geri tuşu şikayet formuna değil iş ekranına döner.
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('ağ hatasında form içeriği korunur', (t) async {
      var fail = true;
      final h = await openJob(
        t,
        '/c/jobs/j1/complaint',
        disputable(),
        extra: {
          'POST /jobs/j1/complaint': (o) {
            if (fail) {
              throw DioException(
                requestOptions: o,
                type: DioExceptionType.connectionError,
              );
            }
            return json(201, complaintJson());
          },
          'GET /complaints/5': (_) => json(200, complaintJson()),
        },
      );
      await fillForm(t);
      await t.tap(btn('Şikayeti gönder'));
      await t.pumpAndSettle();
      await t.tap(dialogBtn('Şikayeti gönder'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('İnternet bağlantına ulaşılamıyor'),
        findsOneWidget,
      );
      expect(
        t.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
        'Usta anlaşılandan fazla ücret istedi.',
      );
      fail = false;
      await t.tap(btn('Şikayeti gönder'));
      await t.pumpAndSettle();
      await t.tap(dialogBtn('Şikayeti gönder'));
      await t.pumpAndSettle();
      expect(h.location, '/c/complaints/5');
    });

    testWidgets('şikayet açılamayan iş', (t) async {
      await openJob(
        t,
        '/c/jobs/j1/complaint',
        jobDetailJson(status: 'COMPLETED', actions: []),
      );
      expect(find.text('Şikayet açılamıyor'), findsOneWidget);
      expect(btn('Şikayeti gönder'), findsNothing);
    });

    testWidgets('durum ekranı: karar ve gerekçe', (t) async {
      await openJob(
        t,
        '/c/complaints/5',
        jobDetailJson(),
        extra: {
          'GET /complaints/5': (_) => json(200, {
            ...complaintJson(status: 'RESOLVED'),
            'decision': 'Tam iade',
            'decisionNote': 'Ek ücret kanıtlandı.',
          }),
        },
      );
      expect(find.text('Sonuçlandı'), findsWidgets);
      expect(find.text('Tam iade'), findsOneWidget);
      expect(find.text('Ek ücret kanıtlandı.'), findsOneWidget);
      expect(find.byType(MediaImage), findsWidgets);
    });
  });

  group('Usta: işi bitirdim (43), not, iptal bildirimi (42)', () {
    Map<String, dynamic> working() => jobDetailJson(
      role: 'PRO',
      status: 'IN_PROGRESS',
      actions: ['FINISH_WORK', 'ADD_NOTE'],
    );

    testWidgets('not en az 10 karakter; istek gitmez', (t) async {
      final h = await openJob(t, '/p/jobs/j1/finish', working(), pro: true);
      await t.tap(btn('İşi bitirdim'));
      await t.pumpAndSettle();
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);
      await t.enterText(find.byType(TextFormField), 'Kısa');
      await t.tap(btn('İşi bitirdim'));
      await t.pumpAndSettle();
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(h.adapter.count('POST', '/jobs/j1/finish'), 0);
    });

    testWidgets('JOB_PHOTO yüklenir, gövde gider, yığın değişir', (t) async {
      var n = 0;
      var done = false;
      final after = jobDetailJson(
        role: 'PRO',
        status: 'WORK_FINISHED',
        actions: [],
        autoCompleteAt: '2026-11-12T09:00:00Z',
      );
      final h = await openJob(
        t,
        '/p/jobs/j1/finish',
        working(),
        pro: true,
        overrides: [
          photoPickerProvider.overrideWithValue(FakePicker([100, 200])),
        ],
        extra: {
          'GET /jobs/j1': (_) => json(200, done ? after : working()),
          'POST /media': (o) => uploadOk(o, 'jp${++n}'),
          'POST /jobs/j1/finish': (_) {
            done = true;
            return json(200, after);
          },
        },
      );
      await t.tap(btn('Fotoğraf ekle'));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      expect(
        (h.adapter.last('/media').data as FormData).fields
            .firstWhere((f) => f.key == 'purpose')
            .value,
        'JOB_PHOTO',
      );
      await t.enterText(
        find.byType(TextFormField),
        'Vana değiştirildi, test edildi.',
      );
      await t.tap(btn('İşi bitirdim'));
      await t.pumpAndSettle();
      expect(
        find.text('İşi bitirdiğini bildirmek istiyor musun?'),
        findsOneWidget,
      );
      await t.tap(dialogBtn('Bildir'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/jobs/j1/finish').data, {
        'note': 'Vana değiştirildi, test edildi.',
        'photoIds': ['jp1'],
      });
      expect(h.location, '/p/jobs/j1/finished');
      expect(find.text('Teslimini gönderdin'), findsOneWidget);
      expect(find.textContaining('otomatik onaylanır'), findsOneWidget);
      // Form yığında değil: geri İşlerim'e döner.
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs');
    });

    testWidgets('not ya da fotoğraf eklenir', (t) async {
      final h = await openJob(
        t,
        '/p/jobs/j1/note',
        working(),
        pro: true,
        extra: {'POST /jobs/j1/events': (_) => json(200, working())},
      );
      await t.tap(btn('Ekle'));
      await t.pumpAndSettle();
      expect(find.text('Bir not yaz ya da fotoğraf ekle.'), findsOneWidget);
      expect(h.adapter.count('POST', '/jobs/j1/events'), 0);
      await t.enterText(find.byType(TextFormField), 'Boru değişti');
      await t.tap(btn('Ekle'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/jobs/j1/events').data, {
        'note': 'Boru değişti',
        'photoIds': <Object>[],
      });
      expect(h.location, '/p/jobs/j1');
    });
  });

  group('Kazançlar', () {
    Map<String, dynamic> earnings() => {
      'releasedTotal': 1260.0,
      'pendingTotal': 1080.0,
      'serviceFeeTotal': 260.0,
      'items': [
        {
          'jobId': 'j7',
          'publicCode': 'BD-88407',
          'title': 'Tesisat onarımı',
          'totalAmount': 1400.0,
          'serviceFee': 140.0,
          'netEarning': 1260.0,
          'status': 'RELEASED',
          'date': '2026-11-09T08:00:00Z',
        },
        {
          'jobId': 'j1',
          'publicCode': 'BD-88409',
          'title': 'Musluk',
          'totalAmount': 1200.0,
          'serviceFee': 120.0,
          'netEarning': 1080.0,
          'status': 'PENDING',
          'date': '2026-11-10T08:00:00Z',
        },
      ],
    };

    testWidgets('toplamlar ve liste', (t) async {
      await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/earnings',
        size: tall,
        handler: server3({'GET /pro/earnings': (_) => json(200, earnings())}),
        overrides: _now,
      );
      expect(find.text('Sana aktarılan'), findsOneWidget);
      expect(find.text('₺1.260'), findsWidgets);
      expect(find.text('Güvence havuzunda bekleyen'), findsOneWidget);
      expect(find.text('₺1.080'), findsWidgets);
      expect(find.text('Toplam hizmet bedeli'), findsOneWidget);
      expect(find.text('₺260'), findsOneWidget);
      expect(find.text('Tesisat onarımı'), findsOneWidget);
      expect(find.text('Aktarıldı'), findsOneWidget);
      expect(find.text('Bekliyor'), findsOneWidget);
      expect(find.text('₺140'), findsOneWidget);
    });

    testWidgets('boş durum', (t) async {
      await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/earnings',
        handler: server3({
          'GET /pro/earnings': (_) => json(200, {
            'releasedTotal': 0,
            'pendingTotal': 0,
            'serviceFeeTotal': 0,
            'items': <Object>[],
          }),
        }),
      );
      expect(find.text('Henüz kazanç yok'), findsOneWidget);
      expect(find.text('₺0'), findsWidgets);
    });

    testWidgets('Profil ekranından erişilir', (t) async {
      final h = await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/profile',
        size: tall,
        handler: server3({
          'GET /pro/profile': (_) => json(200, proProfileJson()),
          'GET /pro/earnings': (_) => json(200, earnings()),
        }),
      );
      await t.tap(btn('Kazançlar'));
      await t.pumpAndSettle();
      expect(h.location, '/p/earnings');
    });

    testWidgets('EN', (t) async {
      await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/earnings',
        size: tall,
        locale: 'en',
        handler: server3({'GET /pro/earnings': (_) => json(200, earnings())}),
        overrides: _now,
      );
      expect(find.text('Paid out to you'), findsOneWidget);
      expect(find.text('₺1,260'), findsWidgets);
    });
  });

  group('İşlerim listesi, Taleplerim, Ana sayfa', () {
    testWidgets('/p/jobs aktif işleri listeler, dokununca iş açılır', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/jobs',
        handler: server3({
          'GET /jobs': (o) => json(200, {
            'items': o.queryParameters['scope'] == 'active'
                ? [jobSummaryJson(role: 'PRO', unread: 3)]
                : <Object>[],
          }),
          'GET /jobs/j1': (_) =>
              json(200, jobDetailJson(role: 'PRO', actions: ['CHAT'])),
        }),
        overrides: _now,
      );
      expect(find.text('Mutfak musluğu damlıyor'), findsOneWidget);
      expect(find.textContaining('Ali Y.'), findsOneWidget);
      expect(find.byType(Badge), findsOneWidget);
      expect(
        h.adapter.last('/jobs').queryParameters,
        containsPair('as', 'PRO'),
      );
      await t.tap(find.text('Mutfak musluğu damlıyor'));
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs/j1');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs');
    });

    testWidgets('/p/jobs geçmiş sekmesi ve boş durum', (t) async {
      await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/jobs',
        handler: server3({
          'GET /jobs': (o) => json(200, {
            'items': o.queryParameters['scope'] == 'past'
                ? [jobSummaryJson(role: 'PRO', status: 'COMPLETED')]
                : <Object>[],
          }),
        }),
      );
      expect(find.text('Henüz işin yok'), findsOneWidget);
      await t.tap(find.text('Geçmiş'));
      await t.pumpAndSettle();
      expect(find.text('Tamamlandı'), findsOneWidget);
    });

    testWidgets('ASSIGNED talebe dokununca iş ekranı açılır', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/requests',
        handler: server3({
          'GET /requests': (_) => json(200, {
            'items': [
              {...requestSummaryJson(status: 'ASSIGNED'), 'jobId': 'j1'},
            ],
            'nextCursor': null,
          }),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
          'GET /jobs/j1': (_) => json(200, jobDetailJson()),
        }),
        overrides: _now,
      );
      await t.tap(find.text('Mutfak musluğu damlıyor'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
      expect(h.adapter.count('GET', '/requests/r1'), 0);
    });

    testWidgets('Ana sayfa aktif iş kartını gösterir', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/home',
        handler: server3({
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
          'GET /jobs': (_) => json(200, {
            'items': [jobSummaryJson()],
          }),
          'GET /jobs/j1': (_) => json(200, jobDetailJson()),
        }),
        overrides: _now,
      );
      expect(find.text('Aktif işlerin'), findsOneWidget);
      expect(find.text('Mutfak musluğu damlıyor'), findsOneWidget);
      expect(find.text('Randevun onaylandı'), findsOneWidget);
      await t.tap(find.text('Mutfak musluğu damlıyor'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('Ana sayfa: aktif iş yoksa kart yok', (t) async {
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/home',
        handler: server3({
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      expect(find.text('Aktif işlerin'), findsNothing);
    });
  });

  group('Sekmeye dönünce veri yeniden çekilir (NAVIGATION_RULES §4)', () {
    testWidgets('müşteri: Taleplerim, Mesajlar, Taleplerim', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/requests',
        handler: server3({
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
          'GET /conversations': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      final first = h.adapter.count('GET', '/requests');
      expect(first, greaterThanOrEqualTo(1));
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/conversations'), 1);
      await t.tap(find.text('Taleplerim'));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/requests'), greaterThan(first));
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/conversations'), 2);
    });

    testWidgets('usta: İşlerim sekmesine dönünce iş listesi yenilenir', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/jobs',
        handler: server3({
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
          'GET /conversations': (_) => json(200, {'items': <Object>[]}),
          'GET /pro/feed': (_) =>
              json(200, {'items': <Object>[], 'onBreak': false}),
        }),
      );
      final before = h.adapter.count('GET', '/jobs');
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      await t.tap(find.text('İşlerim'));
      await t.pumpAndSettle();
      expect(h.adapter.count('GET', '/jobs'), greaterThan(before));
    });
  });

  group('Taşma (320 px, 2x yazı) dalga 3 ekranları', () {
    final srv = server3({
      'GET /jobs/j1': (_) => json(
        200,
        jobDetailJson(
          status: 'WORK_FINISHED',
          actions: [
            'ACCEPT_PROPOSAL',
            'PROPOSE_SLOT',
            'CONFIRM_COMPLETION',
            'COMPLAIN',
            'CANCEL',
            'REVIEW',
            'CHAT',
          ],
          autoCompleteAt: '2026-11-12T09:00:00Z',
          unread: 12,
          complaint: {'id': '5', 'publicCode': 'SK-1001', 'status': 'OPEN'},
          pendingProposal: {
            'id': 99,
            'proposedBy': 'PRO',
            'slotFrom': '2026-11-12T07:00:00Z',
            'slotTo': '2026-11-12T09:00:00Z',
            'createdAt': '2026-11-10T07:00:00Z',
          },
        ),
      ),
      'GET /complaints/5': (_) => json(200, complaintJson()),
      'GET /payments/ESC-1': (_) => json(
        200,
        paymentJson(
          status: 'FAILED',
          jobId: null,
          errorCode: 'PAYMENT_DECLINED',
        ),
      ),
      'GET /jobs': (_) => json(200, {
        'items': [jobSummaryJson(unread: 5)],
      }),
      'GET /conversations': (_) => json(200, {
        'items': [
          {
            'jobId': 'j1',
            'publicCode': 'BD-88409',
            'title': 'Mutfak musluğu damlıyor',
            'counterpart': {'id': 'p1', 'displayName': 'Mavi Hat'},
            'lastMessage': messageJson(
              3,
              body: 'Yarın sabah 10 gibi gelirim, kapıyı çalarım.',
            ),
            'unreadCount': 120,
            'jobStatus': 'IN_PROGRESS',
          },
        ],
      }),
      'GET /jobs/j1/messages': (_) => json(200, {
        'items': [
          messageJson(
            1,
            body: 'Yarın sabah 10 gibi gelirim, kapıyı çalarım, lütfen müsait ol.',
          ),
          messageJson(2, mine: true, body: 'Tamam, bekliyorum.'),
        ],
        'otherLastReadId': 2,
      }),
      'GET /pro/earnings': (_) => json(200, {
        'releasedTotal': 12345.5,
        'pendingTotal': 99999,
        'serviceFeeTotal': 1234,
        'items': [
          {
            'jobId': 'j1',
            'publicCode': 'BD-88409',
            'title': 'Mutfak musluğu damlıyor ve banyo giderinde tıkanıklık',
            'totalAmount': 1200.0,
            'serviceFee': 120.0,
            'netEarning': 1080.0,
            'status': 'SPLIT',
            'date': '2026-11-10T08:00:00Z',
          },
        ],
      }),
    });

    for (final locale in ['tr', 'en']) {
      for (final (route, pro) in [
        ('/c/offers/o1/accept', false),
        ('/c/offers/o1/pay', false),
        ('/c/payments/ESC-1/result', false),
        ('/c/jobs/j1', false),
        ('/c/jobs/j1/appointment', false),
        ('/c/jobs/j1/cancel', false),
        ('/c/jobs/j1/complete', false),
        ('/c/jobs/j1/review', false),
        ('/c/jobs/j1/complaint', false),
        ('/c/complaints/5', false),
        ('/jobs/j1/chat', false),
        ('/c/messages', false),
        ('/p/jobs', true),
        ('/p/jobs/j1', true),
        ('/p/jobs/j1/appointment', true),
        ('/p/jobs/j1/cancel', true),
        ('/p/jobs/j1/finish', true),
        ('/p/jobs/j1/note', true),
        ('/p/jobs/j1/finished', true),
        ('/p/jobs/j1/cancelled', true),
        ('/p/earnings', true),
        ('/p/messages', true),
      ]) {
        testWidgets('$route ($locale)', (t) async {
          await pumpApp(
            t,
            session: pro ? proSession3() : customerSession(),
            initial: route,
            handler: srv,
            locale: locale,
            size: const Size(320, 640),
            textScale: 2,
            overrides: _now,
          );
          expect(t.takeException(), isNull, reason: route);
        });
      }
    }
  });
}
