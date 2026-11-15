import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final ResponseBody Function(RequestOptions o) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _Mem implements TokenStore {
  TokenPair? pair = const TokenPair(accessToken: 'A', refreshToken: 'R');

  @override
  Future<TokenPair?> read() async => pair;

  @override
  Future<void> write(TokenPair p) async => pair = p;

  @override
  Future<void> clear() async => pair = null;
}

ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ApiClient _client(_Adapter a) => ApiClient(
  config: const ApiConfig('http://x'),
  tokenStore: _Mem(),
  adapter: a,
);

Map<String, dynamic> _n({
  Object id = 'n1',
  String type = 'OFFER_RECEIVED',
  Object? params = const {
    'publicCode': 'BD-1',
    'amount': 2450.5,
    'proBusinessName': 'Usta',
  },
  String? target = '/c/requests/5/offers',
  bool read = false,
}) => {
  'id': id,
  'type': type,
  'params': params,
  'targetRoute': target,
  'read': read,
  'createdAt': '2026-11-10T08:00:00Z',
};

void main() {
  group('Notification', () {
    test('JSON okunur, sayısal kimlik metne çevrilir', () {
      final n = Notification.fromJson(_n(id: 42));
      expect(n.id, '42');
      expect(n.kind, NotificationType.offerReceived);
      expect(n.param('publicCode'), 'BD-1');
      expect(n.param('amount'), '2450.5');
      expect(n.targetRoute, '/c/requests/5/offers');
      expect(n.read, isFalse);
      expect(n.createdAt.isUtc, isTrue);
      expect(Notification.fromJson(n.toJson()), n);
    });

    test('bilinmeyen tür çökmez, unknown olur ve ham tür korunur', () {
      final n = Notification.fromJson(_n(type: 'SOMETHING_NEW'));
      expect(n.kind, NotificationType.unknown);
      expect(n.type, 'SOMETHING_NEW');
    });

    test('params yok ya da nesne değilse boş, targetRoute null olabilir', () {
      final a = Notification.fromJson(_n(params: null, target: null));
      expect(a.params, isEmpty);
      expect(a.targetRoute, isNull);
      expect(Notification.fromJson(_n(params: 'x')).params, isEmpty);
    });

    test('sözleşmedeki 19 türün hepsi tanınır', () {
      final known = NotificationType.values
          .where((t) => t != NotificationType.unknown)
          .map((t) => t.wire)
          .toList();
      expect(known.length, 19);
      for (final w in known) {
        expect(NotificationType.fromWire(w).wire, w);
      }
    });
  });

  group('NotificationsApi', () {
    test('liste: sayfa, imleç ve okunmamış sayısı', () async {
      final a = _Adapter(
        (_) => _json(200, {
          'items': [_n(), _n(id: 'n2', read: true)],
          'nextCursor': 'abc',
          'unreadCount': 7,
        }),
      );
      final page = await _client(a).notifications.list(cursor: 'c0', limit: 20);
      expect(page.items.length, 2);
      expect(page.nextCursor, 'abc');
      expect(page.hasMore, isTrue);
      expect(page.unreadCount, 7);
      final r = a.requests.single;
      expect(r.method, 'GET');
      expect(r.path, endsWith('/api/v1/notifications'));
      expect(r.queryParameters, {'cursor': 'c0', 'limit': 20});
    });

    test('markRead ids ile ve idsiz (hepsi) gider', () async {
      final a = _Adapter((_) => ResponseBody.fromString('', 204));
      final api = _client(a).notifications;
      await api.markRead(ids: ['3', 'x']);
      await api.markAllRead();
      expect(a.requests[0].method, 'POST');
      expect(a.requests[0].path, endsWith('/notifications/read'));
      expect(a.requests[0].data, {
        'ids': [3, 'x'],
      });
      expect(a.requests[1].data, <String, dynamic>{});
    });

    test('hata ApiException olur', () async {
      final a = _Adapter(
        (_) => _json(500, {'code': 'INTERNAL', 'message': 'x'}),
      );
      expect(_client(a).notifications.list(), throwsA(isA<ApiException>()));
    });
  });

  group('DevicesApi', () {
    test('PUT /devices platform ve belirteç gönderir', () async {
      final a = _Adapter((_) => ResponseBody.fromString('', 204));
      await _client(a).devices.put(platform: DevicePlatform.ios, token: 'tok');
      final r = a.requests.single;
      expect(r.method, 'PUT');
      expect(r.path, endsWith('/api/v1/devices'));
      expect(r.data, {'platform': 'IOS', 'token': 'tok'});
    });
  });

  group('Me ve Complaint eklemeleri', () {
    Map<String, dynamic> me([Object? unread]) => {
      'id': 'u1',
      'fullName': 'A B',
      'email': 'a@b.c',
      'locale': 'tr',
      'lastMode': 'CUSTOMER',
      'isAdmin': false,
      'status': 'ACTIVE',
      'unreadNotifications': ?unread,
    };

    test('Me.unreadNotifications okunur, yoksa 0', () {
      expect(Me.fromJson(me(5)).unreadNotifications, 5);
      expect(Me.fromJson(me()).unreadNotifications, 0);
    });

    test('Complaint iade ve usta tutarları kuruşa çevrilir', () {
      final c = Complaint.fromJson({
        'id': 'c1',
        'publicCode': 'SK-1001',
        'jobId': 'j1',
        'reason': 'NO_SHOW',
        'description': 'd',
        'status': 'RESOLVED',
        'decision': 'SPLIT_50_50',
        'decisionNote': 'not',
        'createdAt': '2026-11-10T08:00:00Z',
        'refundAmount': 1225.25,
        'proAmount': 1225.25,
      });
      expect(c.refundAmount, const Money.cents(122525));
      expect(c.proAmount, const Money.cents(122525));
    });
  });
}
