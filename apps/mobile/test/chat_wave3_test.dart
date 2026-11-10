import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/formatters.dart';
import 'package:bitadilat_mobile/core/photos.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/chat/chat_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/harness.dart';
import 'support/wave3_fixtures.dart';

List<Override> get _now => [nowProvider.overrideWithValue(() => kNow)];

/// Sohbet sunucusu: mesaj listesi bellekte tutulur.
class FakeChatServer {
  FakeChatServer({List<Map<String, dynamic>>? initial, this.otherRead})
    : messages = initial ?? [messageJson(1), messageJson(2, mine: true)];

  final List<Map<String, dynamic>> messages;
  int? otherRead;
  Map<String, dynamic> job = jobDetailJson(actions: ['CHAT']);
  FutureOr<ResponseBody> Function(RequestOptions)? onSend;

  Handler get handler => server3({
    'GET /jobs/j1': (_) => json(200, job),
    'GET /jobs/j1/messages': (o) {
      final after = o.queryParameters['after'] as int? ?? 0;
      return json(200, {
        'items': [
          for (final m in messages)
            if ((m['id'] as int) > after) m,
        ],
        'otherLastReadId': otherRead,
      });
    },
    'POST /jobs/j1/messages/read': (_) => empty(204),
    'POST /jobs/j1/messages': (o) {
      if (onSend != null) return onSend!(o);
      final body = o.data as Map;
      final m = messageJson(
        messages.length + 1,
        mine: true,
        body: body['body'] as String,
      );
      messages.add(m);
      return json(201, m);
    },
    'GET /conversations': (_) => json(200, {'items': <Object>[]}),
  });
}

Future<Harness> openChat(
  WidgetTester t,
  FakeChatServer s, {
  String route = '/jobs/j1/chat',
  bool pro = false,
  List<Override> overrides = const [],
  String locale = 'tr',
}) => pumpApp(
  t,
  session: pro ? proSession3() : customerSession(),
  initial: route,
  handler: s.handler,
  size: tall,
  locale: locale,
  overrides: [..._now, ...overrides],
);

int gets(Harness h) => h.adapter.count('GET', '/jobs/j1/messages');

Future<void> tick(WidgetTester t, [int ms = 50]) =>
    t.pump(Duration(milliseconds: ms));

void main() {
  group('Sohbet yoklaması', () {
    testWidgets('ilk yükleme mesajları gösterir ve okundu bildirir', (t) async {
      final s = FakeChatServer(otherRead: 2);
      final h = await openChat(t, s);
      expect(find.text('Merhaba'), findsWidgets);
      expect(gets(h), 1);
      expect(
        h.adapter.requests.first.queryParameters.containsKey('after'),
        isFalse,
      );
      // Karşı taraftan gelen mesaj var: son kimlikle okundu bildirilir.
      expect(h.adapter.count('POST', '/jobs/j1/messages/read'), 1);
      expect(h.adapter.last('/jobs/j1/messages/read').data, {'lastReadId': 2});
      // Karşı taraf 2'ye kadar okumuş: kendi mesajımda çift tik.
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('3 saniyede bir after= ile yoklar, yeni mesaj eklenir', (
      t,
    ) async {
      final s = FakeChatServer();
      final h = await openChat(t, s);
      expect(gets(h), 1);
      await t.pump(const Duration(seconds: 2));
      expect(gets(h), 1);
      s.messages.add(messageJson(3, body: 'Yoldayım'));
      await t.pump(const Duration(seconds: 1));
      await tick(t);
      await tick(t);
      expect(gets(h), 2);
      expect(h.adapter.last('/jobs/j1/messages').queryParameters['after'], 2);
      expect(find.text('Yoldayım'), findsOneWidget);
      // Yeni gelen mesaj için yeniden okundu bildirimi.
      expect(h.adapter.last('/jobs/j1/messages/read').data, {'lastReadId': 3});
      await t.pump(const Duration(seconds: 3));
      await tick(t);
      expect(gets(h), 3);
      expect(find.text('Yoldayım'), findsOneWidget);
    });

    testWidgets('arka plana geçince yoklama durur, dönünce sürer', (t) async {
      final s = FakeChatServer();
      final h = await openChat(t, s);
      final binding = t.binding;
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final before = gets(h);
      await t.pump(const Duration(seconds: 15));
      await tick(t);
      expect(gets(h), before);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tick(t);
      await tick(t);
      // Dönünce hemen bir yoklama, ardından 3 saniyelik döngü.
      expect(gets(h), before + 1);
      await t.pump(const Duration(seconds: 3));
      await tick(t);
      expect(gets(h), before + 2);
    });

    testWidgets('ekrandan çıkınca yoklama durur', (t) async {
      final s = FakeChatServer();
      final h = await openChat(t, s, route: '/c/jobs/j1');
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      expect(h.location, '/jobs/j1/chat');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      final before = gets(h);
      await t.pump(const Duration(seconds: 10));
      expect(gets(h), before);
    });

    test('oturum: yoklama başlar ve durur', () async {
      final adapter = FakeAdapter((o) {
        return json(200, {'items': <Object>[], 'otherLastReadId': null});
      });
      final client = ApiClient(
        config: const ApiConfig('http://localhost:8090'),
        tokenStore: MemoryTokenStore(null),
        adapter: adapter,
      );
      final session = ChatSession(api: client.chat, jobId: 'j1');
      expect(session.isPolling, isFalse);
      session.startPolling();
      expect(session.isPolling, isTrue);
      session.stopPolling();
      expect(session.isPolling, isFalse);
      session.dispose();
    });
  });

  group('Gönderme', () {
    testWidgets('gönderilirken geçici baloncuk, sonra tek mesaj', (t) async {
      final s = FakeChatServer();
      final completer = Completer<ResponseBody>();
      s.onSend = (o) => completer.future;
      await openChat(t, s);
      await t.enterText(find.byType(TextField), 'Müsaitim');
      await t.pump();
      await t.tap(find.byTooltip('Gönder'));
      await tick(t);
      await tick(t);
      expect(find.text('Müsaitim'), findsOneWidget);
      expect(find.text('Gönderiliyor'), findsOneWidget);
      // Alan hemen boşalır.
      expect(t.widget<TextField>(find.byType(TextField)).controller!.text, '');
      final m = messageJson(3, mine: true, body: 'Müsaitim');
      s.messages.add(m);
      completer.complete(json(201, m));
      await tick(t);
      await tick(t);
      expect(find.text('Müsaitim'), findsOneWidget);
      expect(find.text('Gönderiliyor'), findsNothing);
      // Yoklama aynı mesajı getirse de çift görünmez.
      await t.pump(const Duration(seconds: 3));
      await tick(t);
      expect(find.text('Müsaitim'), findsOneWidget);
    });

    testWidgets(
      'gönderim, karşı tarafın arada gelen mesajını atlatmaz (after= imleci)',
      (t) async {
        final s = FakeChatServer();
        final h = await openChat(t, s);
        // Son yoklamadan sonra karşı taraf yazdı (id 3), ben de gönderiyorum
        // (sunucu bana id 4 verir).
        s.messages.add(messageJson(3, body: 'Kapıdayım'));
        await t.enterText(find.byType(TextField), 'Geliyorum');
        await t.pump();
        await t.tap(find.byTooltip('Gönder'));
        await tick(t);
        await tick(t);
        expect(find.text('Geliyorum'), findsOneWidget);
        await t.pump(const Duration(seconds: 3));
        await tick(t);
        await tick(t);
        // Yoklama gönderdiğim mesajın değil, son okunan mesajın kimliğinden
        // ister; aradaki mesaj kaybolmaz.
        expect(h.adapter.last('/jobs/j1/messages').queryParameters['after'], 2);
        expect(find.text('Kapıdayım'), findsOneWidget);
        expect(find.text('Geliyorum'), findsOneWidget);
      },
    );

    testWidgets('hata: gönderilemedi, tekrar dene ile gider', (t) async {
      final s = FakeChatServer();
      var fail = true;
      s.onSend = (o) {
        if (fail) {
          throw DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          );
        }
        final m = messageJson(3, mine: true, body: 'Tekrar');
        s.messages.add(m);
        return json(201, m);
      };
      final h = await openChat(t, s);
      await t.enterText(find.byType(TextField), 'Tekrar');
      await t.pump();
      await t.tap(find.byTooltip('Gönder'));
      await tick(t);
      await tick(t);
      await tick(t);
      expect(find.textContaining('Gönderilemedi.'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
      expect(find.text('Tekrar'), findsOneWidget);
      expect(h.adapter.count('POST', '/jobs/j1/messages'), 1);
      fail = false;
      await t.tap(find.text('Tekrar dene'));
      await tick(t);
      await tick(t);
      await tick(t);
      expect(h.adapter.count('POST', '/jobs/j1/messages'), 2);
      expect(find.textContaining('Gönderilemedi.'), findsNothing);
      expect(find.text('Tekrar'), findsOneWidget);
    });

    testWidgets('hatalı mesaj silinebilir', (t) async {
      final s = FakeChatServer();
      s.onSend = (o) => apiError(500, 'INTERNAL_ERROR');
      await openChat(t, s);
      await t.enterText(find.byType(TextField), 'Silinecek');
      await t.pump();
      await t.tap(find.byTooltip('Gönder'));
      await tick(t);
      await tick(t);
      await tick(t);
      expect(find.text('Silinecek'), findsOneWidget);
      await t.tap(find.text('Sil'));
      await tick(t);
      expect(find.text('Silinecek'), findsNothing);
    });

    testWidgets('gönder düğmesi boşken kapalı', (t) async {
      final s = FakeChatServer();
      await openChat(t, s);
      final send = t.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send),
          matching: find.byType(IconButton),
        ),
      );
      expect(send.onPressed, isNull);
      await t.enterText(find.byType(TextField), '   ');
      await t.pump();
      final send2 = t.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send),
          matching: find.byType(IconButton),
        ),
      );
      expect(send2.onPressed, isNull);
    });

    testWidgets('ILLEGAL_STATE: geçici baloncuk kalkar, açıklama çıkar', (
      t,
    ) async {
      final s = FakeChatServer();
      s.onSend = (o) => apiError(409, 'ILLEGAL_STATE');
      await openChat(t, s);
      await t.enterText(find.byType(TextField), 'Geç kaldım');
      await t.pump();
      await t.tap(find.byTooltip('Gönder'));
      await tick(t);
      await tick(t);
      await tick(t);
      expect(find.text('Geç kaldım'), findsNothing);
      expect(
        find.text('Bu işlem artık yapılamıyor, ekran güncellendi.'),
        findsOneWidget,
      );
    });

    testWidgets('fotoğraf CHAT olarak yüklenir, photoId ile gönderilir', (
      t,
    ) async {
      final s = FakeChatServer();
      s.onSend = (o) {
        final m = messageJson(3, mine: true, body: 'Fotoğraf');
        return json(201, m);
      };
      final h = await openChat(
        t,
        s,
        overrides: [
          photoPickerProvider.overrideWithValue(FakePicker([100])),
        ],
      );
      // Medya yüklemesi için sunucuya yol ekle.
      final handler = h.adapter.handler;
      h.adapter.handler = (o) =>
          o.path.endsWith('/media') ? uploadOk(o, '12') : handler(o);
      await t.tap(find.byTooltip('Fotoğraf ekle'));
      await t.pumpAndSettle();
      await t.tap(find.text('Galeriden seç'));
      await t.pumpAndSettle();
      final form = h.adapter.last('/media').data as FormData;
      expect(form.fields.firstWhere((f) => f.key == 'purpose').value, 'CHAT');
      await t.tap(find.byTooltip('Gönder'));
      await tick(t);
      await tick(t);
      expect(h.adapter.last('/jobs/j1/messages').data, {
        'body': 'Fotoğraf',
        'photoId': 12,
      });
    });
  });

  group('Salt okunur sohbet', () {
    testWidgets('CHAT eylemi yoksa giriş alanı kapalı ve açıklama var', (
      t,
    ) async {
      final s = FakeChatServer();
      s.job = jobDetailJson(status: 'COMPLETED', actions: []);
      await openChat(t, s);
      expect(find.text('Merhaba'), findsWidgets);
      expect(find.byType(TextField), findsNothing);
      expect(find.byTooltip('Gönder'), findsNothing);
      expect(find.textContaining('salt okunur'), findsOneWidget);
    });

    testWidgets('boş salt okunur sohbet', (t) async {
      final s = FakeChatServer(initial: []);
      s.job = jobDetailJson(status: 'CANCELLED', actions: []);
      await openChat(t, s);
      expect(find.text('Henüz mesaj yok'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('Geri dönüş ve rol (NAVIGATION_RULES §2)', () {
    testWidgets('usta: iş ekranından sohbete ve geri; rol değişmez', (t) async {
      final s = FakeChatServer();
      s.job = jobDetailJson(role: 'PRO', actions: ['CHAT', 'CANCEL']);
      final h = await openChat(t, s, route: '/p/jobs/j1', pro: true);
      expect(h.location, '/p/jobs/j1');
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      expect(h.location, '/jobs/j1/chat');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs/j1');
      expect(h.container.read(sessionProvider).me!.lastMode, UserMode.pro);
    });

    testWidgets('müşteri: iş ekranından sohbete ve geri', (t) async {
      final s = FakeChatServer();
      final h = await openChat(t, s, route: '/c/jobs/j1');
      await t.tap(find.text('Mesajlar'));
      await t.pumpAndSettle();
      expect(h.location, '/jobs/j1/chat');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets(
      'derin bağlantı (boş yığın): usta moduna ait iş ekranına döner',
      (t) async {
        final s = FakeChatServer();
        s.job = jobDetailJson(role: 'PRO', actions: ['CHAT']);
        final h = await openChat(t, s, pro: true);
        expect(h.router.canPop(), isFalse);
        await t.tap(find.byTooltip('Geri'));
        await t.pumpAndSettle();
        expect(h.location, '/p/jobs/j1');
      },
    );

    testWidgets('derin bağlantı: müşteri müşteri iş ekranına döner', (t) async {
      final s = FakeChatServer();
      final h = await openChat(t, s);
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/c/jobs/j1');
    });

    testWidgets('sistem geri tuşu da role uygun ekrana döner', (t) async {
      final s = FakeChatServer();
      s.job = jobDetailJson(role: 'PRO', actions: ['CHAT']);
      final h = await openChat(t, s, pro: true);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs/j1');
    });

    testWidgets('Mesajlar sekmesinden sohbete ve geri: sekme korunur', (
      t,
    ) async {
      final s = FakeChatServer();
      Map<String, dynamic> conv() => {
        'jobId': 'j1',
        'publicCode': 'BD-88409',
        'title': 'Mutfak musluğu damlıyor',
        'counterpart': {'id': 'c1', 'displayName': 'Ali Y.'},
        'lastMessage': messageJson(2, body: 'Yarın gelirim'),
        'unreadCount': 3,
        'jobStatus': 'SCHEDULED',
      };
      final base = s.handler;
      final h = await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/messages',
        handler: (o) => o.path.endsWith('/conversations')
            ? json(200, {
                'items': [conv()],
              })
            : base(o),
        overrides: _now,
      );
      await t.tap(find.text('Ali Y.'));
      await t.pumpAndSettle();
      expect(h.location, '/jobs/j1/chat');
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/p/messages');
    });
  });

  group('Mesaj kutuları', () {
    Map<String, dynamic> conversation({int unread = 3}) => {
      'jobId': 'j1',
      'publicCode': 'BD-88409',
      'title': 'Mutfak musluğu damlıyor',
      'counterpart': {'id': 'p1', 'displayName': 'Mavi Hat'},
      'lastMessage': messageJson(2, body: 'Yarın 10 gibi gelirim'),
      'unreadCount': unread,
      'jobStatus': 'SCHEDULED',
    };

    testWidgets('liste: ad, son mesaj, okunmamış rozeti, durum', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/messages',
        handler: server3({
          'GET /conversations': (_) => json(200, {
            'items': [
              conversation(),
              conversation(unread: 0)..['jobId'] = 'j2',
            ],
          }),
        }),
        overrides: _now,
      );
      expect(find.text('Mavi Hat'), findsNWidgets(2));
      expect(find.text('Yarın 10 gibi gelirim'), findsNWidgets(2));
      // Yalnız okunmamış konuşmada rozet var.
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Randevun onaylandı'), findsNWidgets(2));
      expect(
        h.adapter.last('/conversations').queryParameters,
        containsPair('as', 'CUSTOMER'),
      );
    });

    testWidgets('müşteri boş durumu', (t) async {
      final h = await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/messages',
        handler: server3({
          'GET /conversations': (_) => json(200, {'items': <Object>[]}),
          'GET /requests': (_) =>
              json(200, {'items': <Object>[], 'nextCursor': null}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      expect(find.text('Henüz konuşma yok'), findsOneWidget);
      await t.tap(btn('Taleplerime git'));
      await t.pumpAndSettle();
      expect(h.location, '/c/requests');
    });

    testWidgets('usta boş durumu', (t) async {
      final h = await pumpApp(
        t,
        session: proSession3(),
        initial: '/p/messages',
        handler: server3({
          'GET /conversations': (_) => json(200, {'items': <Object>[]}),
          'GET /jobs': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      expect(find.text('Henüz konuşma yok'), findsOneWidget);
      expect(find.textContaining('müşteriyle'), findsOneWidget);
      expect(
        h.adapter.last('/conversations').queryParameters,
        containsPair('as', 'PRO'),
      );
      await t.tap(btn('İşlerime git'));
      await t.pumpAndSettle();
      expect(h.location, '/p/jobs');
    });

    testWidgets('EN metinler', (t) async {
      await pumpApp(
        t,
        session: customerSession(),
        initial: '/c/messages',
        locale: 'en',
        handler: server3({
          'GET /conversations': (_) => json(200, {'items': <Object>[]}),
        }),
      );
      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('Go to my requests'), findsOneWidget);
    });
  });
}
