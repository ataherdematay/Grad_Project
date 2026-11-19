import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions) handler;
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

Map<String, dynamic> _me() => {
  'id': 'u1',
  'fullName': 'Ali Yılmaz',
  'email': 'yeni@example.com',
  'phone': '+905321112233',
  'locale': 'tr',
  'lastMode': 'CUSTOMER',
  'isAdmin': false,
  'status': 'ACTIVE',
  'pro': null,
  'unreadNotifications': 0,
};

Map<String, dynamic> _reviewItem() => {
  'ref': 'ESC-1',
  'jobId': 'j1',
  'jobPublicCode': 'BD-10001',
  'jobStatus': 'CANCELLED',
  'status': 'LOCKED',
  'errorCode': 'REFUND_NEEDS_REVIEW',
  'pendingAction': 'REFUND',
  'totalAmount': 1200.0,
  'refundedAmount': 0,
  'customerName': 'Ali Yılmaz',
  'proBusinessName': 'Mavi Hat',
  'attempts': 8,
  'lastAttemptAt': '2026-11-10T10:00:00Z',
  'createdAt': '2026-11-09T10:00:00Z',
};

void main() {
  group('JobPayment bekleyen hareket ve inceleme', () {
    test('pendingAction ve errorCode okunur; bilinmeyen değer çökmez', () {
      final p = JobPayment.fromJson({
        'ref': 'ESC-1',
        'status': 'LOCKED',
        'totalAmount': 1200,
        'refundedAmount': 0,
        'pendingAction': 'REFUND',
        'errorCode': 'REFUND_NEEDS_REVIEW',
      });
      expect(p.pendingAction, EscrowPendingAction.refund);
      expect(p.errorCode, PaymentErrorCode.refundNeedsReview);
      expect(p.needsReview, isTrue);
      expect(JobPayment.fromJson(p.toJson()), p);

      final q = JobPayment.fromJson({
        'ref': 'ESC-2',
        'status': 'LOCKED',
        'totalAmount': 1200,
        'pendingAction': 'SOMETHING_NEW',
        'errorCode': 'SOMETHING_NEW',
      });
      expect(q.pendingAction, isNull);
      expect(q.errorCode, PaymentErrorCode.unknown);
      expect(q.needsReview, isFalse);

      final r = JobPayment.fromJson({
        'ref': 'ESC-3',
        'status': 'LOCKED',
        'totalAmount': 1200,
        'pendingAction': 'RELEASE',
        'errorCode': 'PAYOUT_NEEDS_REVIEW',
      });
      expect(r.pendingAction, EscrowPendingAction.release);
      expect(r.needsReview, isTrue);
    });

    test('PaymentResult THREEDS_ABANDONED tanınır', () {
      final p = PaymentResult.fromJson({
        'ref': 'r',
        'status': 'FAILED',
        'offerId': 'o',
        'requestId': 'q',
        'totalAmount': 10,
        'errorCode': 'THREEDS_ABANDONED',
        'resultUncertain': false,
      });
      expect(p.errorCode, PaymentErrorCode.threedsAbandoned);
    });
  });

  group('MeApi follow-up', () {
    test('deleteAccount gerekçeyi gövdede yollar, gerekçesiz gövde yok', () async {
      final a = _Adapter((_) => ResponseBody.fromString('', 204));
      final c = _client(a);
      await c.me.deleteAccount(reason: AccountDeletionReason.foundAlternative);
      await c.me.deleteAccount();
      expect(a.requests[0].method, 'DELETE');
      expect(a.requests[0].data, {'reason': 'FOUND_ALTERNATIVE'});
      expect(a.requests[1].data, isNull);
    });

    test('e-posta değişikliği: istek 202, onay Me döner', () async {
      final a = _Adapter(
        (o) => o.path.endsWith('/confirm')
            ? _json(200, _me())
            : ResponseBody.fromString('', 202),
      );
      final c = _client(a);
      await c.me.requestEmailChange(newEmail: 'yeni@example.com', password: 'p');
      final me = await c.me.confirmEmailChange('123456');
      expect(a.requests[0].path, endsWith('/api/v1/me/email'));
      expect(a.requests[0].data, {
        'newEmail': 'yeni@example.com',
        'password': 'p',
      });
      expect(a.requests[1].path, endsWith('/api/v1/me/email/confirm'));
      expect(a.requests[1].data, {'code': '123456'});
      expect(me.email, 'yeni@example.com');
    });

    test('yanlış kod VALIDATION_FAILED (code) fırlatır', () async {
      final a = _Adapter(
        (_) => _json(400, {
          'code': 'VALIDATION_FAILED',
          'message': 'x',
          'field': 'code',
        }),
      );
      await expectLater(
        _client(a).me.confirmEmailChange('000000'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.validationFailed)
              .having((e) => e.field, 'field', 'code'),
        ),
      );
    });
  });

  test('ProsApi.reviews süzgeç parametrelerini yollar', () async {
    final a = _Adapter((_) => _json(200, {'items': [], 'nextCursor': null}));
    final c = _client(a);
    await c.pros.reviews('p1', rating: 4, withComment: true);
    await c.pros.reviews('p1');
    expect(a.requests[0].queryParameters, {'rating': 4, 'withComment': true});
    expect(a.requests[1].queryParameters, isEmpty);
  });

  group('AdminApi inceleme', () {
    test('liste, kontrol ve çözüm uç noktaları', () async {
      final a = _Adapter((o) {
        if (o.path.endsWith('/payments/review')) {
          return _json(200, {
            'items': [_reviewItem()],
          });
        }
        return _json(200, {
          'payment': _reviewItem(),
          'gatewayRefundState': 'FULLY_REFUNDED',
          'gatewayRefundedTotal': 1200.0,
          'allowedResolutions': ['MARK_REFUNDED', 'FUTURE_THING'],
        });
      });
      final c = _client(a);
      final items = await c.admin.paymentReviews();
      expect(items.single.pendingAction, EscrowPendingAction.refund);
      expect(items.single.jobStatus, JobStatus.cancelled);
      expect(items.single.totalAmount, const Money.lira(1200));
      expect(items.single.attempts, 8);

      final check = await c.admin.checkPaymentReview('ESC-1');
      expect(check.resolutions, [PaymentResolution.markRefunded]);
      expect(check.gatewayRefundedTotal, const Money.lira(1200));

      await c.admin.resolvePaymentReview(
        'ESC-1',
        resolution: PaymentResolution.retryRefund,
        note: 'Craftgate panelinde kontrol edildi.',
      );
      expect(a.requests[1].path, endsWith('/admin/payments/ESC-1/review'));
      expect(a.requests[2].method, 'POST');
      expect(a.requests[2].path, endsWith('/admin/payments/ESC-1/resolve'));
      expect(a.requests[2].data, {
        'resolution': 'RETRY_REFUND',
        'note': 'Craftgate panelinde kontrol edildi.',
      });
    });

    test('users ilçe süzgecini yollar', () async {
      final a = _Adapter((_) => _json(200, {'items': []}));
      await _client(a).admin.users(districtId: '23', q: 'ali');
      expect(a.requests.single.queryParameters, {'q': 'ali', 'district': '23'});
    });
  });
}
