import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions o) handler;
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

Map<String, dynamic> _timeline({bool pro = false}) => {
  'paymentRef': 'ref-1',
  'jobId': 'job-1',
  'jobPublicCode': 'BD-88421',
  'jobTitle': 'Banyo lavabo altı su kaçağı',
  'status': 'RELEASED_TO_PRO',
  'moneyLocation': 'PRO',
  'provider': 'CRAFTGATE',
  'sandbox': true,
  'craftgatePaymentId': 50001,
  'card': pro
      ? null
      : {
          'brand': 'MASTERCARD',
          'last4': '0001',
          'masked': '**** **** **** 0001',
        },
  'amounts': {
    'gross': 1200.00,
    'commission': pro ? 120.00 : null,
    'proNet': pro ? 1080.00 : null,
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
      'type': 'SOMETHING_NEW',
      'at': '2026-11-26T09:02:00Z',
      'amount': null,
      'actor': null,
      'note': null,
    },
    {
      'type': 'RELEASED_TO_PRO',
      'at': '2026-11-27T15:10:01Z',
      'amount': pro ? 1080.00 : null,
      'actor': 'SYSTEM',
      'note': null,
    },
  ],
};

void main() {
  test(
    'timeline: müşteri görünümü (komisyon yok) ve bilinmeyen olay türü',
    () async {
      final a = _Adapter((_) => _json(200, _timeline()));
      final t = await _client(a).paymentDemo.timeline('job-1');
      expect(a.requests.single.path, endsWith('/jobs/job-1/payment/timeline'));
      expect(t.moneyLocation, MoneyLocation.pro);
      expect(t.status, EscrowStatus.releasedToPro);
      expect(t.provider, PaymentProviderKind.craftgate);
      expect(t.sandbox, isTrue);
      expect(t.card!.last4, '0001');
      expect(t.amounts.gross, const Money.lira(1200));
      expect(t.amounts.commission, isNull);
      expect(t.amounts.proNet, isNull);
      expect(t.events.map((e) => e.type), [
        PaymentEventType.paymentLocked,
        PaymentEventType.unknown,
        PaymentEventType.releasedToPro,
      ]);
      expect(t.events.last.amount, isNull);
      expect(t.autoReleaseAt, isNull);
    },
  );

  test('timeline: usta görünümü kart görmez, komisyon ve net gelir', () async {
    final a = _Adapter((_) => _json(200, _timeline(pro: true)));
    final t = await _client(a).paymentDemo.timeline('job-1');
    expect(t.card, isNull);
    expect(t.amounts.proNet, const Money.lira(1080));
    expect(t.amounts.commission, const Money.lira(120));
    expect(t.events.last.amount, const Money.lira(1080));
  });

  test('timeline: autoReleaseAt ve inceleme kodu çözülür', () async {
    final body = _timeline()
      ..['status'] = 'LOCKED'
      ..['moneyLocation'] = 'BITADILAT_VAULT'
      ..['autoReleaseAt'] = '2026-11-29T14:00:00Z'
      ..['errorCode'] = 'PAYOUT_NEEDS_REVIEW';
    final a = _Adapter((_) => _json(200, body));
    final t = await _client(a).paymentDemo.timeline('job-1');
    expect(t.moneyLocation, MoneyLocation.vault);
    expect(t.autoReleaseAt, DateTime.utc(2026, 11, 29, 14));
    expect(t.needsReview, isTrue);
  });

  test('timeline: 404 ApiException(notFound)', () async {
    final a = _Adapter(
      (_) => _json(404, {'code': 'NOT_FOUND', 'message': 'x'}),
    );
    expect(
      _client(a).paymentDemo.timeline('nope'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.notFound,
        ),
      ),
    );
  });

  test('receipt: kalemler, toplam, maskeli kart, sandbox', () async {
    final a = _Adapter(
      (_) => _json(200, {
        'receiptNo': 'BT-20261126-5B0F0A',
        'issuedAt': '2026-11-26T09:01:12Z',
        'paymentRef': 'ref-1',
        'jobId': 'job-1',
        'jobPublicCode': 'BD-88421',
        'jobTitle': 'Banyo',
        'proName': 'Test Tesisat',
        'customerName': 'Ali Yılmaz',
        'items': [
          {
            'kind': 'LABOR',
            'label': 'İşçilik',
            'quantity': 1.00,
            'unitPrice': 900.00,
            'amount': 900.00,
          },
          {
            'kind': 'MATERIAL',
            'label': 'Malzeme',
            'quantity': 1.00,
            'unitPrice': 300.00,
            'amount': 300.00,
          },
        ],
        'total': 1200.00,
        'refundedTotal': 0.00,
        'netPaid': 1200.00,
        'currency': 'TRY',
        'card': {
          'brand': null,
          'last4': '0001',
          'masked': '**** **** **** 0001',
        },
        'status': 'LOCKED',
        'moneyLocation': 'BITADILAT_VAULT',
        'provider': 'DEMO',
        'sandbox': true,
        'sandboxNotice': 'Bu bir sandbox (deneme) ödemesidir.',
      }),
    );
    final r = await _client(a).paymentDemo.receipt('job-1');
    expect(a.requests.single.path, endsWith('/jobs/job-1/payment/receipt'));
    expect(r.receiptNo, 'BT-20261126-5B0F0A');
    expect(r.items.map((e) => e.kind), [
      ReceiptItemKind.labor,
      ReceiptItemKind.material,
    ]);
    expect(r.items.fold<Money>(Money.zero, (s, e) => s + e.amount), r.total);
    expect(r.card!.brand, isNull);
    expect(r.provider, PaymentProviderKind.demo);
    expect(r.sandbox, isTrue);
    expect(r.netPaid, const Money.lira(1200));
  });

  test('receipt: usta için 403 ApiException(forbidden)', () async {
    final a = _Adapter(
      (_) => _json(403, {'code': 'FORBIDDEN', 'message': 'x'}),
    );
    expect(
      _client(a).paymentDemo.receipt('job-1'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.forbidden,
        ),
      ),
    );
  });

  test('me/payments: sayfalama parametreleri ve nextCursor', () async {
    final a = _Adapter(
      (o) => _json(200, {
        'items': [
          {
            'ref': 'ref-1',
            'jobId': null,
            'jobPublicCode': 'BD-1',
            'jobTitle': 'İş',
            'proName': 'Usta',
            'totalAmount': 1200.00,
            'refundedAmount': 600.00,
            'status': 'SPLIT_SETTLED',
            'moneyLocation': 'SPLIT',
            'provider': 'SEED',
            'sandbox': true,
            'paidAt': '2026-11-26T09:01:12Z',
            'createdAt': '2026-11-26T09:00:00Z',
          },
        ],
        'nextCursor': 'abc',
      }),
    );
    final p = await _client(a).paymentDemo.myPayments(cursor: 'c0', limit: 20);
    final q = a.requests.single.queryParameters;
    expect(q['cursor'], 'c0');
    expect(q['limit'], 20);
    expect(p.hasMore, isTrue);
    expect(p.items.single.jobId, isNull);
    expect(p.items.single.moneyLocation, MoneyLocation.split);
    expect(p.items.single.refundedAmount, const Money.lira(600));
    expect(p.items.single.status, EscrowStatus.splitSettled);
  });

  test('me/payments: boş liste', () async {
    final a = _Adapter((_) => _json(200, {'items': [], 'nextCursor': null}));
    final p = await _client(a).paymentDemo.myPayments();
    expect(p.items, isEmpty);
    expect(p.hasMore, isFalse);
    expect(a.requests.single.queryParameters.containsKey('cursor'), isFalse);
  });

  test('bozuk gövde ApiException(unknown) olur', () async {
    final a = _Adapter((_) => _json(200, {'foo': 1}));
    expect(
      _client(a).paymentDemo.receipt('job-1'),
      throwsA(isA<ApiException>()),
    );
  });
}
