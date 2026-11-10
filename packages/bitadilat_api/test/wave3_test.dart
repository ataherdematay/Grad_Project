import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

typedef Handler = FutureOr<ResponseBody> Function(RequestOptions options);

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Handler handler;
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

ResponseBody jsonBody(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

class _Mem implements TokenStore {
  TokenPair? pair = const TokenPair(accessToken: 'A', refreshToken: 'R');

  @override
  Future<TokenPair?> read() async => pair;

  @override
  Future<void> write(TokenPair p) async => pair = p;

  @override
  Future<void> clear() async => pair = null;
}

ApiClient clientWith(FakeAdapter a) => ApiClient(
  config: const ApiConfig('http://x'),
  tokenStore: _Mem(),
  adapter: a,
);

Map<String, dynamic> media([String id = 'm1']) => {
  'id': id,
  'url': 'http://x/api/v1/media/$id/content?exp=1&sig=2',
  'expiresAt': '2026-11-10T10:00:00Z',
};

Map<String, dynamic> offerDetail() => {
  'id': 'o1',
  'publicCode': 'TK-00001',
  'requestId': 'r1',
  'status': 'ACCEPTED',
  'pro': {
    'id': 'p1',
    'businessName': 'Mavi Hat',
    'fullName': 'Ali Usta',
    'ratingAvg': 4.5,
    'ratingCount': 12,
    'completedJobs': 30,
    'verified': true,
  },
  'laborAmount': 900.0,
  'materialsAmount': 300.5,
  'totalAmount': 1200.5,
  'arrivalFrom': '2026-11-11T10:00:00Z',
  'arrivalTo': '2026-11-11T12:00:00Z',
  'warrantyMonths': 6,
  'note': null,
  'validUntil': '2026-11-11T12:00:00Z',
  'createdAt': '2026-11-10T08:00:00Z',
  'items': [],
  'serviceFee': null,
  'netEarning': null,
};

Map<String, dynamic> jobSummary() => {
  'id': 'j1',
  'publicCode': 'BD-88409',
  'requestId': 'r1',
  'title': 'Musluk',
  'categoryId': 'plumbing',
  'status': 'SCHEDULED',
  'viewerRole': 'CUSTOMER',
  'counterpart': {'id': 'p1', 'displayName': 'Mavi Hat'},
  'totalAmount': 1200.5,
  'scheduledFrom': '2026-11-11T07:00:00Z',
  'scheduledTo': '2026-11-11T09:00:00Z',
  'updatedAt': '2026-11-10T08:00:00Z',
  'unreadMessages': 2,
};

Map<String, dynamic> jobDetail() => {
  ...jobSummary(),
  'offer': offerDetail(),
  'address': {
    'districtName': 'Kadıköy',
    'neighborhood': 'Moda',
    'lineFull': 'Moda Cd. 1/3',
    'doorNote': 'Zil bozuk',
  },
  'appointment': {
    'scheduledFrom': '2026-11-11T07:00:00Z',
    'scheduledTo': '2026-11-11T09:00:00Z',
    'pendingProposal': {
      'id': 99,
      'proposedBy': 'PRO',
      'slotFrom': '2026-11-12T07:00:00Z',
      'slotTo': '2026-11-12T09:00:00Z',
      'createdAt': '2026-11-10T09:00:00Z',
    },
  },
  'timeline': [
    {
      'id': 1,
      'type': 'STATUS_CHANGED',
      'fromStatus': null,
      'toStatus': 'AWAITING_APPOINTMENT',
      'note': null,
      'photo': null,
      'actorRole': 'SYSTEM',
      'createdAt': '2026-11-10T08:00:00Z',
    },
    {
      'id': 2,
      'type': 'PHOTO',
      'fromStatus': null,
      'toStatus': null,
      'note': 'Önce',
      'photo': media(),
      'actorRole': 'PRO',
      'createdAt': '2026-11-10T09:00:00Z',
    },
  ],
  'payment': {
    'ref': 'ESC-1',
    'status': 'LOCKED',
    'totalAmount': 1200.5,
    'refundedAmount': 0,
    'serviceFee': null,
    'netEarning': null,
  },
  'autoCompleteAt': null,
  'review': null,
  'complaint': null,
  'allowedActions': ['ACCEPT_PROPOSAL', 'CANCEL', 'CHAT', 'MARK_ARRIVED'],
};

void main() {
  group('model JSON gidiş-dönüş', () {
    test('JobSummary', () {
      final j = JobSummary.fromJson(jobSummary());
      expect(j.status, JobStatus.scheduled);
      expect(j.viewerRole, PartyRole.customer);
      expect(j.totalAmount, const Money.cents(120050));
      expect(j.unreadMessages, 2);
      expect(JobSummary.fromJson(j.toJson()), j);
    });

    test('JobDetail: öneri, zaman çizelgesi, ödeme, eylemler', () {
      final d = JobDetail.fromJson(jobDetail());
      expect(d.appointment.pendingProposal!.id, '99');
      expect(d.appointment.pendingProposal!.proposedBy, PartyRole.pro);
      expect(d.timeline, hasLength(2));
      expect(d.timeline[0].fromStatus, isNull);
      expect(d.timeline[1].photo!.id, 'm1');
      expect(d.timeline[1].type, JobEventType.photo);
      expect(d.payment.status, EscrowStatus.locked);
      expect(d.payment.refundedAmount, Money.zero);
      expect(d.payment.serviceFee, isNull);
      expect(d.offer.totalAmount, const Money.cents(120050));
      expect(d.can(JobAction.markArrived), isTrue);
      expect(d.can(JobAction.review), isFalse);
      expect(JobDetail.fromJson(d.toJson()), d);
      expect(d.summary.id, 'j1');
    });

    test('JobDetail: usta payı dolu, şikayet ve puan', () {
      final raw = jobDetail()
        ..['viewerRole'] = 'PRO'
        ..['payment'] = {
          'ref': 'ESC-1',
          'status': 'DISPUTED',
          'totalAmount': 2200,
          'refundedAmount': 0,
          'serviceFee': 220.0,
          'netEarning': 1980.0,
        }
        ..['complaint'] = {'id': 5, 'publicCode': 'SK-1001', 'status': 'OPEN'}
        ..['review'] = {
          'id': 3,
          'rating': 5,
          'tags': ['ON_TIME'],
          'comment': 'Süper',
          'authorDisplay': 'Ali Y.',
          'createdAt': '2026-11-10T10:00:00Z',
        };
      final d = JobDetail.fromJson(raw);
      expect(d.payment.serviceFee, const Money.lira(220));
      expect(d.payment.netEarning, const Money.lira(1980));
      expect(d.complaint!.publicCode, 'SK-1001');
      expect(d.complaint!.status, ComplaintStatus.open);
      expect(d.review!.rating, 5);
      expect(JobDetail.fromJson(d.toJson()), d);
    });

    test('bilinmeyen eylem yok sayılır, bilinmeyen durum ApiException', () {
      final raw = jobDetail()..['allowedActions'] = ['FLY'];
      final d = JobDetail.fromJson(raw);
      for (final a in JobAction.values) {
        expect(d.can(a), isFalse);
      }
    });

    test('JobEvent türleri', () {
      for (final t in [
        'STATUS_CHANGED',
        'NOTE',
        'PHOTO',
        'APPOINTMENT_PROPOSED',
        'APPOINTMENT_ACCEPTED',
      ]) {
        final e = JobEvent.fromJson({
          'id': 1,
          'type': t,
          'actorRole': 'ADMIN',
          'createdAt': '2026-11-10T08:00:00Z',
        });
        expect(e.type.wire, t);
        expect(e.actorRole, ActorRole.admin);
        expect(JobEvent.fromJson(e.toJson()), e);
      }
    });

    test('Message ve Conversation', () {
      final m = Message.fromJson({
        'id': 9007199254740,
        'senderRole': 'PRO',
        'mine': false,
        'body': 'Merhaba',
        'photo': media(),
        'createdAt': '2026-11-10T08:00:00Z',
      });
      expect(m.id, 9007199254740);
      expect(m.senderRole, PartyRole.pro);
      expect(m.photo!.id, 'm1');
      expect(Message.fromJson(m.toJson()), m);

      final c = Conversation.fromJson({
        'jobId': 'j1',
        'publicCode': 'BD-88409',
        'title': 'Musluk',
        'counterpart': {'id': 'p1', 'displayName': 'Mavi Hat'},
        'lastMessage': m.toJson(),
        'unreadCount': 3,
        'jobStatus': 'IN_PROGRESS',
      });
      expect(c.unreadCount, 3);
      expect(c.jobStatus, JobStatus.inProgress);
      expect(Conversation.fromJson(c.toJson()), c);
      final none = Conversation.fromJson({
        'jobId': 'j1',
        'publicCode': 'BD-1',
        'title': 'x',
        'counterpart': {'id': 'p1', 'displayName': 'Ali Y.'},
        'lastMessage': null,
        'jobStatus': 'COMPLETED',
      });
      expect(none.lastMessage, isNull);
      expect(none.unreadCount, 0);
    });

    test('Complaint', () {
      final c = Complaint.fromJson({
        'id': 5,
        'publicCode': 'SK-1001',
        'jobId': 'j1',
        'reason': 'EXTRA_CHARGE',
        'description': 'Fazla ücret istendi, anlaşmadık.',
        'evidence': [media()],
        'status': 'IN_REVIEW',
        'decision': null,
        'decisionNote': null,
        'createdAt': '2026-11-10T08:00:00Z',
        'decidedAt': null,
      });
      expect(c.reason, ComplaintReason.extraCharge);
      expect(c.status, ComplaintStatus.inReview);
      expect(c.evidence, hasLength(1));
      expect(Complaint.fromJson(c.toJson()), c);
    });

    test('PaymentResult: hata kodları ve bilinmeyen kod', () {
      final r = PaymentResult.fromJson({
        'ref': 'ESC-1',
        'status': 'REFUNDED_TO_CUSTOMER',
        'offerId': 'o1',
        'requestId': 'r1',
        'jobId': null,
        'totalAmount': 1200.5,
        'cardLast4': '0001',
        'errorCode': 'REQUEST_ALREADY_ASSIGNED',
        'errorMessage': 'Talep başkasına verildi',
        'resultUncertain': false,
      });
      expect(r.status, EscrowStatus.refundedToCustomer);
      expect(r.errorCode, PaymentErrorCode.requestAlreadyAssigned);
      expect(r.totalAmount, const Money.cents(120050));
      expect(PaymentResult.fromJson(r.toJson()), r);

      final odd = PaymentResult.fromJson({
        'ref': 'E',
        'status': 'FAILED',
        'totalAmount': 10,
        'errorCode': 'SOMETHING_NEW',
      });
      expect(odd.errorCode, PaymentErrorCode.unknown);
      expect(odd.resultUncertain, isFalse);
      for (final c in [
        'PAYMENT_DECLINED',
        'OFFER_EXPIRED',
        'RESULT_UNCERTAIN',
      ]) {
        final p = PaymentResult.fromJson({
          'ref': 'E',
          'status': 'FAILED',
          'totalAmount': 10,
          'errorCode': c,
        });
        expect(p.errorCode!.wire, c);
      }
    });

    test('Earnings', () {
      final e = Earnings.fromJson({
        'releasedTotal': 1260.0,
        'pendingTotal': 1080.5,
        'serviceFeeTotal': 140.0,
        'items': [
          {
            'jobId': 'j1',
            'publicCode': 'BD-88407',
            'title': 'Tesisat',
            'totalAmount': 1400,
            'serviceFee': 140.0,
            'netEarning': 1260.0,
            'status': 'RELEASED',
            'date': '2026-11-09T08:00:00Z',
          },
        ],
      });
      expect(e.releasedTotal, const Money.lira(1260));
      expect(e.pendingTotal, const Money.cents(108050));
      expect(e.items.single.status, EarningStatus.released);
      expect(Earnings.fromJson(e.toJson()), e);
    });

    test('RequestSummary.jobId ve ProRequestDetail.status', () {
      final r = RequestSummary.fromJson({
        'id': 'r1',
        'publicCode': 'BD-1',
        'title': 't',
        'categoryId': 'plumbing',
        'urgency': 'URGENT',
        'status': 'ASSIGNED',
        'districtName': 'K',
        'neighborhood': 'M',
        'createdAt': '2026-11-10T08:00:00Z',
        'expiresAt': '2026-11-17T08:00:00Z',
        'jobId': 12,
      });
      expect(r.jobId, '12');
      expect(RequestSummary.fromJson(r.toJson()), r);
      final p = ProRequestDetail.fromJson({
        'id': 'r1',
        'publicCode': 'BD-1',
        'title': 't',
        'categoryId': 'plumbing',
        'urgency': 'URGENT',
        'districtName': 'K',
        'neighborhood': 'M',
        'createdAt': '2026-11-10T08:00:00Z',
        'description': 'd',
        'status': 'ASSIGNED',
      });
      expect(p.status, RequestStatus.assigned);
    });

    test('CardPaymentRequest.toString kart verisini yazmaz', () {
      const c = CardPaymentRequest(
        offerId: '1',
        attemptKey: 'k',
        cardHolderName: 'Test Kullanici',
        cardNumber: '5258640000000001',
        expireMonth: '07',
        expireYear: '2044',
        cvc: '000',
      );
      final s = c.toString();
      expect(s, isNot(contains('5258')));
      expect(s, isNot(contains('Test Kullanici')));
      expect(s, isNot(contains('2044')));
      expect(c.toJson()['expireYear'], '2044');
    });
  });

  group('API çağrıları', () {
    test('PaymentsApi.init3ds gövdesi ve yanıtı', () async {
      final a = FakeAdapter(
        (o) => jsonBody(200, {'ref': 'ESC-1', 'htmlContent': '<form></form>'}),
      );
      final init = await clientWith(a).payments.init3ds(
        const CardPaymentRequest(
          offerId: 'o1',
          attemptKey: 'abc',
          cardHolderName: 'Test Kullanici',
          cardNumber: '5258640000000001',
          expireMonth: '07',
          expireYear: '2044',
          cvc: '000',
        ),
      );
      expect(init.ref, 'ESC-1');
      expect(init.htmlContent, '<form></form>');
      final r = a.requests.single;
      expect(r.method, 'POST');
      expect(r.path, '/api/v1/payments/3ds/init');
      expect(r.data['attemptKey'], 'abc');
      expect(r.data['cardNumber'], '5258640000000001');
    });

    test('INVALID_CARD alanı ve PAYMENT_DECLINED ref taşınır', () async {
      var code = 'INVALID_CARD';
      final a = FakeAdapter(
        (o) => code == 'INVALID_CARD'
            ? jsonBody(400, {'code': code, 'message': 'x', 'field': 'number'})
            : jsonBody(402, {'code': code, 'message': 'x', 'ref': 'ESC-9'}),
      );
      const card = CardPaymentRequest(
        offerId: 'o1',
        attemptKey: 'abc',
        cardHolderName: 'A B',
        cardNumber: '1',
        expireMonth: '07',
        expireYear: '2044',
        cvc: '000',
      );
      final api = clientWith(a).payments;
      await expectLater(
        api.init3ds(card),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.invalidCard)
              .having((e) => e.field, 'field', 'number'),
        ),
      );
      code = 'PAYMENT_DECLINED';
      await expectLater(
        api.init3ds(card),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.paymentDeclined)
              .having((e) => e.ref, 'ref', 'ESC-9'),
        ),
      );
    });

    test('yeni hata kodları tanınır', () {
      expect(ApiErrorCode.parse('OFFER_EXPIRED'), ApiErrorCode.offerExpired);
      expect(
        ApiErrorCode.parse('DUPLICATE_ATTEMPT'),
        ApiErrorCode.duplicateAttempt,
      );
      expect(
        ApiErrorCode.parse('PAYMENT_IN_PROGRESS'),
        ApiErrorCode.paymentInProgress,
      );
    });

    test('JobsApi uç noktaları ve gövdeler', () async {
      final a = FakeAdapter((o) {
        if (o.path == '/api/v1/jobs') {
          return jsonBody(200, {
            'items': [jobSummary()],
          });
        }
        return jsonBody(200, jobDetail());
      });
      final api = clientWith(a).jobs;
      final page = await api.list(role: PartyRole.pro, scope: 'active');
      expect(page.items.single.id, 'j1');
      expect(a.requests.last.queryParameters, {'as': 'PRO', 'scope': 'active'});

      await api.get('j1');
      await api.proposeSlot(
        'j1',
        ProposeSlotRequest(
          slotFrom: DateTime.utc(2026, 11, 12, 7),
          slotTo: DateTime.utc(2026, 11, 12, 9),
        ),
      );
      expect(a.requests.last.path, '/api/v1/jobs/j1/appointment/proposals');
      expect(a.requests.last.data['slotFrom'], '2026-11-12T07:00:00.000Z');

      await api.acceptProposal('j1', '99');
      expect(
        a.requests.last.path,
        '/api/v1/jobs/j1/appointment/proposals/99/accept',
      );
      await api.arrived('j1');
      expect(a.requests.last.path, '/api/v1/jobs/j1/arrived');
      await api.start('j1');
      expect(a.requests.last.path, '/api/v1/jobs/j1/start');
      await api.finish(
        'j1',
        const FinishJobRequest(note: 'Bitti, temiz.', photoIds: ['5', 'ab']),
      );
      expect(a.requests.last.path, '/api/v1/jobs/j1/finish');
      expect(a.requests.last.data, {
        'note': 'Bitti, temiz.',
        'photoIds': [5, 'ab'],
      });
      await api.addEvent('j1', const JobNoteRequest(note: 'Not'));
      expect(a.requests.last.path, '/api/v1/jobs/j1/events');
      expect(a.requests.last.data, {'note': 'Not', 'photoIds': <Object>[]});
      await api.confirm('j1');
      expect(a.requests.last.path, '/api/v1/jobs/j1/confirm');
      await api.cancel(
        'j1',
        CancelJobRequest(reason: CustomerCancelReason.plansChanged.wire),
      );
      expect(a.requests.last.data, {'reason': 'PLANS_CHANGED'});
      await api.review(
        'j1',
        const ReviewRequest(
          rating: 5,
          tags: [ReviewTag.onTime, ReviewTag.goodCommunication],
          comment: 'İyi',
          anonymous: true,
        ),
      );
      expect(a.requests.last.path, '/api/v1/jobs/j1/review');
      expect(a.requests.last.data, {
        'rating': 5,
        'tags': ['ON_TIME', 'GOOD_COMMUNICATION'],
        'comment': 'İyi',
        'anonymous': true,
      });
    });

    test('ChatApi: after, gönderme, okundu, konuşmalar', () async {
      final a = FakeAdapter((o) {
        if (o.path.endsWith('/messages/read')) {
          return ResponseBody.fromString('', 204);
        }
        if (o.path.endsWith('/messages') && o.method == 'GET') {
          return jsonBody(200, {
            'items': [
              {
                'id': 5,
                'senderRole': 'CUSTOMER',
                'mine': true,
                'body': 'Selam',
                'photo': null,
                'createdAt': '2026-11-10T08:00:00Z',
              },
            ],
            'otherLastReadId': 4,
          });
        }
        if (o.path.endsWith('/messages')) {
          return jsonBody(201, {
            'id': 6,
            'senderRole': 'CUSTOMER',
            'mine': true,
            'body': 'x',
            'photo': null,
            'createdAt': '2026-11-10T08:00:00Z',
          });
        }
        return jsonBody(200, {'items': <Object>[]});
      });
      final api = clientWith(a).chat;
      final page = await api.messages('j1', after: 4, limit: 50);
      expect(page.items.single.id, 5);
      expect(page.otherLastReadId, 4);
      expect(a.requests.last.queryParameters, {'after': 4, 'limit': 50});
      await api.messages('j1');
      expect(a.requests.last.queryParameters, isEmpty);

      final sent = await api.send(
        'j1',
        const SendMessageRequest(body: 'x', photoId: '7'),
      );
      expect(sent.id, 6);
      expect(a.requests.last.data, {'body': 'x', 'photoId': 7});
      await api.send('j1', const SendMessageRequest(body: 'y'));
      expect(a.requests.last.data, {'body': 'y'});

      await api.markRead('j1', 6);
      expect(a.requests.last.path, '/api/v1/jobs/j1/messages/read');
      expect(a.requests.last.data, {'lastReadId': 6});

      expect(await api.conversations(PartyRole.customer), isEmpty);
      expect(a.requests.last.queryParameters, {'as': 'CUSTOMER'});
    });

    test('ComplaintsApi ve ProApi.earnings', () async {
      final complaint = {
        'id': 5,
        'publicCode': 'SK-1001',
        'jobId': 'j1',
        'reason': 'NO_SHOW',
        'description': 'Usta hiç gelmedi, aradım açmadı.',
        'evidence': <Object>[],
        'status': 'OPEN',
        'createdAt': '2026-11-10T08:00:00Z',
      };
      final a = FakeAdapter((o) {
        if (o.path.endsWith('/pro/earnings')) {
          return jsonBody(200, {
            'releasedTotal': 0,
            'pendingTotal': 0,
            'serviceFeeTotal': 0,
            'items': <Object>[],
          });
        }
        return jsonBody(o.method == 'POST' ? 201 : 200, complaint);
      });
      final c = clientWith(a);
      final created = await c.complaints.create(
        'j1',
        const ComplaintRequest(
          reason: ComplaintReason.noShow,
          description: 'Usta hiç gelmedi, aradım açmadı.',
          evidenceIds: ['3'],
        ),
      );
      expect(created.publicCode, 'SK-1001');
      expect(a.requests.last.path, '/api/v1/jobs/j1/complaint');
      expect(a.requests.last.data['reason'], 'NO_SHOW');
      expect(a.requests.last.data['evidenceIds'], [3]);
      await c.complaints.get('5');
      expect(a.requests.last.path, '/api/v1/complaints/5');
      final e = await c.pro.earnings();
      expect(e.releasedTotal, Money.zero);
    });

    test('409 ILLEGAL_STATE işlerde ApiException olur', () async {
      final a = FakeAdapter(
        (o) => jsonBody(409, {'code': 'ILLEGAL_STATE', 'message': 'x'}),
      );
      await expectLater(
        clientWith(a).jobs.confirm('j1'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.illegalState,
          ),
        ),
      );
    });
  });
}
