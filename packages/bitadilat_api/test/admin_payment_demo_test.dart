import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final ResponseBody Function(RequestOptions) handler;
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

ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ApiClient _client(_Adapter a) => ApiClient(
  config: const ApiConfig('http://x'),
  tokenStore: MemoryTokenStore(
    const TokenPair(accessToken: 'A', refreshToken: 'R'),
  ),
  adapter: a,
);

Map<String, dynamic> _timeline() => {
  'paymentRef': '5b0f0a3e',
  'jobId': 'j1',
  'jobPublicCode': 'BD-88421',
  'jobTitle': 'Banyo lavabo altı su kaçağı',
  'status': 'RELEASED_TO_PRO',
  'moneyLocation': 'PRO',
  'provider': 'CRAFTGATE',
  'sandbox': true,
  'craftgatePaymentId': 50001,
  'card': {'brand': 'MASTERCARD', 'last4': '0001', 'masked': '**** 0001'},
  'amounts': {
    'gross': 1200.00,
    'commission': 120.00,
    'proNet': 1080.00,
    'refunded': 0.00,
  },
  'autoReleaseAt': null,
  'pendingAction': null,
  'errorCode': null,
  'events': [
    {
      'type': 'PAYMENT_LOCKED',
      'at': '2026-11-26T09:01:12Z',
      'amount': 1200.00,
      'actor': 'SYSTEM',
      'note': null,
    },
    {
      'type': 'FUTURE_TYPE',
      'at': '2026-11-27T15:10:01Z',
      'amount': 1080.5,
      'actor': null,
      'note': 'X',
    },
  ],
};

void main() {
  test('summary: yol, tutarlar kuruşa ve sayılar çözülür', () async {
    final a = _Adapter(
      (o) => _json(200, {
        'vaultTotal': 400.00,
        'paidToProsTotal': 1080.00,
        'refundedToCustomersTotal': 600.50,
        'commissionEarnedTotal': 120.00,
        'counts': {
          'total': 3,
          'vault': 1,
          'locked': 1,
          'disputed': 0,
          'released': 1,
          'refunded': 1,
          'split': 0,
          'failed': 0,
          'pendingAction': 0,
          'needsReview': 2,
          'seed': 4,
        },
        'generatedAt': '2026-11-26T12:00:00Z',
      }),
    );
    final s = await _client(a).adminPaymentVaultSummary();
    expect(a.requests.single.path, '/api/v1/admin/payments/summary');
    expect(a.requests.single.method, 'GET');
    expect(s.vaultTotal, const Money.lira(400));
    expect(s.refundedToCustomersTotal, const Money.cents(60050));
    expect(s.commissionEarnedTotal, const Money.lira(120));
    expect(s.counts.total, 3);
    expect(s.counts.needsReview, 2);
    expect(s.counts.seed, 4);
    expect(s.generatedAt, DateTime.utc(2026, 11, 26, 12));
  });

  test('summary: eksik counts ve tutarlar sıfır olur', () async {
    final s = await _client(_Adapter((o) => _json(200, {})))
        .adminPaymentVaultSummary();
    expect(s.vaultTotal, Money.zero);
    expect(s.counts.total, 0);
    expect(s.generatedAt, isNull);
  });

  test('timeline: tam gövde çözülür, bilinmeyen olay tipi korunur', () async {
    final a = _Adapter((o) => _json(200, _timeline()));
    final t = await _client(a).adminPaymentTimeline('5b0f0a3e');
    expect(a.requests.single.path, '/api/v1/admin/payments/5b0f0a3e/timeline');
    expect(t.status, 'RELEASED_TO_PRO');
    expect(t.moneyLocation, 'PRO');
    expect(t.provider, 'CRAFTGATE');
    expect(t.craftgatePaymentId, 50001);
    expect(t.card!.brand, 'MASTERCARD');
    expect(t.card!.masked, '**** 0001');
    expect(t.amounts.gross, const Money.lira(1200));
    expect(t.amounts.commission, const Money.lira(120));
    expect(t.amounts.proNet, const Money.lira(1080));
    expect(t.autoReleaseAt, isNull);
    expect(t.events, hasLength(2));
    expect(t.events.first.amount, const Money.lira(1200));
    expect(t.events.last.type, 'FUTURE_TYPE');
    expect(t.events.last.amount, const Money.cents(108050));
    expect(t.events.last.actor, isNull);
  });

  test('timeline: null alanlar (kart, komisyon, iş) sorun çıkarmaz', () async {
    final body = _timeline()
      ..['card'] = null
      ..['jobId'] = null
      ..['jobTitle'] = null
      ..['craftgatePaymentId'] = null
      ..['amounts'] = {
        'gross': 500,
        'commission': null,
        'proNet': null,
        'refunded': 0,
      }
      ..['autoReleaseAt'] = '2026-11-29T14:00:00Z'
      ..['events'] = <Object>[];
    final t = await _client(_Adapter((o) => _json(200, body)))
        .adminPaymentTimeline('r');
    expect(t.card, isNull);
    expect(t.jobId, isNull);
    expect(t.craftgatePaymentId, isNull);
    expect(t.amounts.commission, isNull);
    expect(t.amounts.proNet, isNull);
    expect(t.autoReleaseAt, DateTime.utc(2026, 11, 29, 14));
    expect(t.events, isEmpty);
  });

  test('timeline: ref URL güvenli kodlanır; 404 ApiException olur', () async {
    final a = _Adapter(
      (o) => _json(404, {'code': 'NOT_FOUND', 'message': 'x'}),
    );
    await expectLater(
      _client(a).adminPaymentTimeline('a/b'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.notFound,
        ),
      ),
    );
    expect(a.requests.single.path, contains('a%2Fb'));
  });

  test('timeline: bozuk gövde ApiException(unknown) olur', () async {
    final a = _Adapter((o) => _json(200, {'status': 'LOCKED'}));
    await expectLater(
      _client(a).adminPaymentTimeline('r'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', ApiErrorCode.unknown),
      ),
    );
  });
}
