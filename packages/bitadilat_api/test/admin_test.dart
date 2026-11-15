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

ApiClient clientWith(FakeAdapter a) => ApiClient(
  config: const ApiConfig('http://x'),
  tokenStore: MemoryTokenStore(
    const TokenPair(accessToken: 'A', refreshToken: 'R'),
  ),
  adapter: a,
);

Map<String, dynamic> media([String id = 'm1']) => {
  'id': id,
  'url': 'http://x/api/v1/media/$id/content?exp=1&sig=2',
  'expiresAt': '2026-11-10T10:00:00Z',
};

Map<String, dynamic> offer() => {
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
  'laborAmount': 1500.0,
  'materialsAmount': 700.0,
  'totalAmount': 2200.0,
  'arrivalFrom': '2026-11-11T10:00:00Z',
  'arrivalTo': '2026-11-11T12:00:00Z',
  'warrantyMonths': 6,
  'validUntil': '2026-11-11T12:00:00Z',
  'createdAt': '2026-11-10T08:00:00Z',
  'items': [],
};

Map<String, dynamic> complaintDetail() => {
  'id': 'c1',
  'publicCode': 'SK-1001',
  'jobId': 'j1',
  'reason': 'INCOMPLETE_WORK',
  'description': 'İş yarım bırakıldı, usta geri dönmedi.',
  'evidence': [media('e1')],
  'status': 'OPEN',
  'decision': null,
  'decisionNote': null,
  'createdAt': '2026-11-10T09:00:00Z',
  'decidedAt': null,
  'job': {
    'id': 'j1',
    'publicCode': 'BD-88409',
    'title': 'Musluk tamiri',
    'status': 'DISPUTED',
    'statusBeforeDispute': 'WORK_FINISHED',
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
        'note': 'Bitti',
        'photo': media('p1'),
        'actorRole': 'PRO',
        'createdAt': '2026-11-10T08:30:00Z',
      },
    ],
    'offer': offer(),
    'districtName': 'Kadıköy',
  },
  'payment': {
    'ref': 'PAY-1',
    'status': 'DISPUTED',
    'provider': 'CRAFTGATE',
    'totalAmount': 2200.0,
    'commission': 220.0,
    'proPayout': 1980.0,
    'refundedAmount': 0,
  },
  'messages': [
    {
      'id': 5,
      'senderRole': 'CUSTOMER',
      'body': 'Ne zaman gelirsin?',
      'photo': null,
      'createdAt': '2026-11-10T08:40:00Z',
    },
  ],
  'customer': {'id': 'u1', 'fullName': 'Ayşe Yılmaz'},
  'pro': {
    'id': 'p1',
    'businessName': 'Mavi Hat',
    'fullName': 'Ali Usta',
    'warningCount': 2,
    'cancellationCount': 1,
  },
};

Map<String, dynamic> applicationDetail() => {
  'proId': 'p9',
  'fullName': 'Hasan Kaya',
  'businessName': 'Kaya Tesisat',
  'categoryIds': ['plumbing', 3],
  'districtNames': ['Kadıköy', 'Üsküdar'],
  'submittedAt': '2026-11-09T09:00:00Z',
  'reviewStatus': 'PENDING_REVIEW',
  'documentCount': 1,
  'email': 'hasan@example.com',
  'phone': '+905320000000',
  'bio': 'Yirmi yıllık tecrübe.',
  'experienceYears': 20,
  'reviewNote': null,
  'documents': [
    {
      'id': 'd1',
      'type': 'TRADE_CERT',
      'status': 'PENDING',
      'media': media('d1'),
    },
  ],
  'history': [
    {
      'id': 1,
      'action': 'REQUEST_DOCUMENTS',
      'note': 'Vergi levhası okunmuyor.',
      'adminName': 'Yönetici',
      'createdAt': '2026-11-09T10:00:00Z',
    },
  ],
};

void main() {
  group('Admin model JSON gidiş-dönüşü', () {
    test('AdminStats', () {
      final s = AdminStats.fromJson({
        'pendingApplications': 3,
        'openComplaints': 1,
        'activeJobs': 7,
        'lockedEscrowTotal': 12450.5,
      });
      expect(s.lockedEscrowTotal, const Money.cents(1245050));
      expect(AdminStats.fromJson(s.toJson()), s);
    });

    test('AdminApplicationDetail (sayısal kategori kimliği metne çevrilir)', () {
      final d = AdminApplicationDetail.fromJson(applicationDetail());
      expect(d.categoryIds, ['plumbing', '3']);
      expect(d.reviewStatus, ReviewStatus.pendingReview);
      expect(d.documents.single.type, ProDocumentType.tradeCert);
      expect(d.documents.single.media.id, 'd1');
      expect(d.history.single.adminName, 'Yönetici');
      expect(AdminApplicationDetail.fromJson(d.toJson()), d);
    });

    test('AdminApplicationSummary', () {
      final s = AdminApplicationSummary.fromJson({
        'proId': 9,
        'fullName': 'Hasan Kaya',
        'businessName': 'Kaya Tesisat',
        'categoryIds': ['plumbing'],
        'districtNames': ['Kadıköy'],
        'submittedAt': '2026-11-09T09:00:00Z',
        'reviewStatus': 'NEEDS_DOCUMENTS',
        'documentCount': 2,
      });
      expect(s.proId, '9');
      expect(s.reviewStatus, ReviewStatus.needsDocuments);
      expect(AdminApplicationSummary.fromJson(s.toJson()), s);
    });

    test('AdminComplaintItem', () {
      final i = AdminComplaintItem.fromJson({
        'id': 1,
        'publicCode': 'SK-1001',
        'jobId': 2,
        'jobPublicCode': 'BD-1',
        'reason': 'NO_SHOW',
        'status': 'IN_REVIEW',
        'customerName': 'Ayşe Y.',
        'proBusinessName': 'Mavi Hat',
        'amount': 2200,
        'createdAt': '2026-11-10T09:00:00Z',
      });
      expect(i.amount, const Money.lira(2200));
      expect(i.status, ComplaintStatus.inReview);
      expect(AdminComplaintItem.fromJson(i.toJson()), i);
    });

    test('AdminComplaintDetail', () {
      final d = AdminComplaintDetail.fromJson(complaintDetail());
      expect(d.job.statusBeforeDispute, JobStatus.workFinished);
      expect(d.job.timeline, hasLength(2));
      expect(d.job.offer.totalAmount, const Money.lira(2200));
      expect(d.payment!.totalAmount, const Money.lira(2200));
      expect(d.payment!.refundedAmount, Money.zero);
      expect(d.warnPro, isFalse);
      expect(d.suspendPro, isFalse);
      expect(d.refundAmount, isNull);
      expect(d.proAmount, isNull);
      expect(d.messages.single.senderRole, PartyRole.customer);
      expect(d.pro.warningCount, 2);
      expect(AdminComplaintDetail.fromJson(d.toJson()), d);
    });

    test('AdminUser', () {
      final u = AdminUser.fromJson({
        'id': 'u2',
        'fullName': 'Selim',
        'email': 's@example.com',
        'phone': null,
        'isAdmin': false,
        'status': 'SUSPENDED',
        'createdAt': '2026-11-01T09:00:00Z',
        'pro': {'businessName': 'Selim Boya', 'reviewStatus': 'APPROVED'},
      });
      expect(u.status, AccountStatus.suspended);
      expect(u.pro!.reviewStatus, ReviewStatus.approved);
      expect(AdminUser.fromJson(u.toJson()), u);
    });

    test('AdminPayments', () {
      final p = AdminPayments.fromJson({
        'items': [
          {
            'ref': 'PAY-1',
            'jobPublicCode': 'BD-1',
            'status': 'LOCKED',
            'provider': 'SEED',
            'totalAmount': 2200,
            'commission': 220,
            'proPayout': 1980,
            'refundedAmount': 0,
            'customerName': 'Ayşe',
            'proBusinessName': 'Mavi Hat',
            'createdAt': '2026-11-10T09:00:00Z',
            'lockedAt': '2026-11-10T09:01:00Z',
            'releasedAt': null,
            'refundedAt': null,
            'errorCode': null,
          },
        ],
        'totals': {
          'lockedTotal': 2200,
          'releasedTotal': 0,
          'commissionTotal': 220.5,
          'refundedTotal': 0,
        },
      });
      expect(p.items.single.commission, const Money.lira(220));
      expect(p.totals.commissionTotal, const Money.cents(22050));
      final again = AdminPaymentRow.fromJson(p.items.single.toJson());
      expect(again, p.items.single);
    });

    test('ComplaintDecision kodları sözleşmeyle aynı', () {
      expect(
        ComplaintDecision.values.map((d) => d.code),
        ['FULL_REFUND', 'SPLIT_50_50', 'RELEASE_TO_PRO'],
      );
      const req = ComplaintDecisionRequest(
        decision: ComplaintDecision.split5050,
        note: 'Her iki taraf da kısmen haklı.',
        warnPro: true,
      );
      final json = req.toJson();
      expect(json['decision'], 'SPLIT_50_50');
      expect(json['warnPro'], true);
      expect(json['suspendPro'], false);
      expect(ComplaintDecisionRequest.fromJson(json), req);
      expect(ComplaintDecision.tryParse('RELEASE_TO_PRO'),
          ComplaintDecision.releaseToPro);
      expect(ComplaintDecision.tryParse('X'), isNull);
    });
  });

  group('AdminComplaintDetail sözleşme alanları', () {
    test('karar sonrası tutarlar sunucudan okunur (1250.50 -> 125050 kuruş)',
        () {
      final d = AdminComplaintDetail.fromJson({
        ...complaintDetail(),
        'status': 'RESOLVED',
        'decision': 'SPLIT_50_50',
        'decisionNote': 'Her iki taraf da kısmen haklı.',
        'decidedAt': '2026-11-11T09:00:00Z',
        'refundAmount': 1250.50,
        'proAmount': '1250.49',
        'warnPro': true,
        'suspendPro': true,
      });
      expect(d.refundAmount, const Money.cents(125050));
      expect(d.proAmount, const Money.cents(125049));
      expect(d.warnPro, isTrue);
      expect(d.suspendPro, isTrue);
      expect(ComplaintDecision.tryParse(d.decision),
          ComplaintDecision.split5050);
    });

    test('emanet kaydı yoksa payment null olabilir', () {
      final d = AdminComplaintDetail.fromJson({
        ...complaintDetail(),
        'payment': null,
      });
      expect(d.payment, isNull);
    });

    test('karar gövdesi tutar taşımaz', () {
      const req = ComplaintDecisionRequest(
        decision: ComplaintDecision.fullRefund,
        note: 'Usta adrese hiç gelmedi.',
      );
      expect(req.toJson().keys.toSet(),
          {'decision', 'note', 'warnPro', 'suspendPro'});
    });
  });

  group('AdminApi', () {
    test('uç noktalar, sorgular ve gövdeler', () async {
      final a = FakeAdapter((o) {
        final p = o.path;
        if (p.endsWith('/admin/applications') && o.method == 'GET') {
          return jsonBody(200, {'items': []});
        }
        if (p.contains('/admin/applications/p9')) {
          return jsonBody(200, applicationDetail());
        }
        if (p.endsWith('/admin/complaints') && o.method == 'GET') {
          return jsonBody(200, {'items': []});
        }
        if (p.contains('/admin/complaints/c1')) {
          return jsonBody(200, complaintDetail());
        }
        if (p.endsWith('/admin/users') && o.method == 'GET') {
          return jsonBody(200, {'items': []});
        }
        if (p.endsWith('/suspend')) {
          return jsonBody(200, {'activeJobCount': 2});
        }
        if (p.endsWith('/reactivate')) return ResponseBody.fromString('', 204);
        if (p.endsWith('/admin/payments')) {
          return jsonBody(200, {'items': [], 'totals': {}});
        }
        return jsonBody(404, {'code': 'NOT_FOUND', 'message': 'x'});
      });
      final api = clientWith(a).admin;

      await api.applications(status: ReviewStatus.needsDocuments, q: ' Ali ');
      var r = a.requests.last;
      expect(r.path, '/api/v1/admin/applications');
      expect(r.queryParameters, {'status': 'NEEDS_DOCUMENTS', 'q': 'Ali'});

      await api.applications();
      expect(a.requests.last.queryParameters, isEmpty);

      await api.approve('p9');
      r = a.requests.last;
      expect(r.path, '/api/v1/admin/applications/p9/approve');
      expect(r.data, <String, dynamic>{});

      await api.reject('p9', 'Belgeler uyuşmuyor.');
      expect(a.requests.last.path.endsWith('/p9/reject'), isTrue);
      expect(a.requests.last.data, {'note': 'Belgeler uyuşmuyor.'});

      await api.requestDocuments(
        'p9',
        note: 'Vergi levhası okunmuyor.',
        documentTypes: [ProDocumentType.tax, ProDocumentType.criminalRecord],
      );
      expect(a.requests.last.path.endsWith('/p9/request-documents'), isTrue);
      expect(a.requests.last.data, {
        'note': 'Vergi levhası okunmuyor.',
        'documentTypes': ['TAX', 'CRIMINAL_RECORD'],
      });

      await api.complaints(status: ComplaintStatus.inReview);
      expect(a.requests.last.queryParameters, {'status': 'IN_REVIEW'});

      await api.reviewComplaint('c1');
      expect(a.requests.last.path.endsWith('/complaints/c1/review'), isTrue);

      await api.decideComplaint(
        'c1',
        const ComplaintDecisionRequest(
          decision: ComplaintDecision.releaseToPro,
          note: 'Şikayet dayanaksız.',
          suspendPro: true,
        ),
      );
      expect(a.requests.last.path.endsWith('/complaints/c1/decision'), isTrue);
      expect(a.requests.last.data, {
        'decision': 'RELEASE_TO_PRO',
        'note': 'Şikayet dayanaksız.',
        'warnPro': false,
        'suspendPro': true,
      });

      await api.users(
        q: 'ali',
        role: AccountRole.pro,
        status: AccountStatus.active,
      );
      expect(a.requests.last.queryParameters, {
        'q': 'ali',
        'role': 'PRO',
        'status': 'ACTIVE',
      });

      final res = await api.suspendUser('u2', 'Sahte belge kullandı.');
      expect(res.activeJobCount, 2);
      expect(a.requests.last.data, {'note': 'Sahte belge kullandı.'});

      await api.reactivateUser('u2');
      expect(a.requests.last.path.endsWith('/users/u2/reactivate'), isTrue);

      final pays = await api.payments(status: 'LOCKED');
      expect(a.requests.last.queryParameters, {'status': 'LOCKED'});
      expect(pays.totals.lockedTotal, Money.zero);
    });

    test('403 FORBIDDEN ApiException olur', () async {
      final a = FakeAdapter(
        (_) => jsonBody(403, {'code': 'FORBIDDEN', 'message': 'no'}),
      );
      await expectLater(
        clientWith(a).admin.stats(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.forbidden,
          ),
        ),
      );
    });

    test('409 ILLEGAL_STATE', () async {
      final a = FakeAdapter(
        (_) => jsonBody(409, {'code': 'ILLEGAL_STATE', 'message': 'x'}),
      );
      await expectLater(
        clientWith(a).admin.approve('p9'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.illegalState,
          ),
        ),
      );
    });

    test('sözleşmeye uymayan gövde ApiException(unknown) olur', () async {
      final a = FakeAdapter((_) => jsonBody(200, {'unexpected': true}));
      await expectLater(
        clientWith(a).admin.stats(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.unknown,
          ),
        ),
      );
    });
  });
}
