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

Map<String, dynamic> media() => {
  'id': 'm1',
  'url': 'http://x/api/v1/media/m1/content?exp=1&sig=2',
  'expiresAt': '2026-11-10T10:00:00Z',
};

Map<String, dynamic> proCard() => {
  'id': 'p1',
  'businessName': 'Usta Tesisat',
  'fullName': 'Ali Usta',
  'ratingAvg': 4.5,
  'ratingCount': 12,
  'completedJobs': 30,
  'verified': true,
};

Map<String, dynamic> offerSummary() => {
  'id': 'o1',
  'publicCode': 'TK-00001',
  'requestId': 'r1',
  'status': 'PENDING',
  'pro': proCard(),
  'laborAmount': 1800.0,
  'materialsAmount': 650.5,
  'totalAmount': 2450.5,
  'arrivalFrom': '2026-11-11T10:00:00Z',
  'arrivalTo': '2026-11-11T12:00:00Z',
  'warrantyMonths': 6,
  'note': 'Not',
  'validUntil': '2026-11-11T12:00:00Z',
  'createdAt': '2026-11-10T08:00:00Z',
};

Map<String, dynamic> offerDetail() => {
  ...offerSummary(),
  'items': [
    {
      'kind': 'LABOR',
      'description': 'Montaj',
      'quantity': 1,
      'unitPrice': 1800.0,
      'lineTotal': 1800.0,
    },
    {
      'kind': 'MATERIAL',
      'description': 'Vana',
      'quantity': 2,
      'unitPrice': 325.25,
      'lineTotal': 650.5,
    },
  ],
  'serviceFee': 245.05,
  'netEarning': 2205.45,
  'declineReason': null,
};

Map<String, dynamic> requestSummary() => {
  'id': 'r1',
  'publicCode': 'BD-00001',
  'title': 'Musluk damlıyor',
  'categoryId': '1',
  'urgency': 'URGENT',
  'status': 'OPEN',
  'districtName': 'Kadıköy',
  'neighborhood': 'Moda',
  'createdAt': '2026-11-10T08:00:00Z',
  'expiresAt': '2026-11-17T08:00:00Z',
  'offerCount': 2,
  'minOfferTotal': 2000.0,
  'maxOfferTotal': 2450.5,
};

Map<String, dynamic> requestDetail() => {
  ...requestSummary(),
  'description': 'Mutfak musluğu sürekli damlıyor.',
  'preferredFrom': null,
  'preferredTo': null,
  'photos': [media()],
  'answers': [
    {'questionKey': 'since', 'answer': 'today'},
  ],
  'matchedProCount': 3,
  'matchFactors': ['CATEGORY', 'DISTRICT', 'AVAILABILITY'],
  'address': {
    'districtName': 'Kadıköy',
    'neighborhood': 'Moda',
    'lineFull': 'Moda Cd. 1',
    'doorNote': null,
  },
};

Map<String, dynamic> feedItem() => {
  'id': 'r1',
  'publicCode': 'BD-00001',
  'title': 'Musluk',
  'categoryId': '1',
  'urgency': 'PLANNED',
  'districtName': 'Kadıköy',
  'neighborhood': 'Moda',
  'createdAt': '2026-11-10T08:00:00Z',
  'preferredFrom': '2026-11-12T08:00:00Z',
  'preferredTo': '2026-11-12T12:00:00Z',
  'photoCount': 2,
  'offerCount': 1,
  'myOfferId': null,
};

void main() {
  group('Money', () {
    test('kuruşa çevirir, double toplama hatası yok', () {
      expect(Money.fromJson(0.1).cents, 10);
      expect((Money.fromJson(0.1) + Money.fromJson(0.2)).cents, 30);
      expect(Money.fromJson(2450.5).cents, 245050);
      expect(Money.fromJson('12.30').cents, 1230);
      expect(Money.fromJson(1225.50).toJson(), 1225.5);
    });

    test('yüzde ve çarpım', () {
      expect(const Money.lira(2450).percent(10), const Money.cents(24500));
      expect(const Money.cents(1005).percent(10).cents, 101);
      expect(const Money.lira(100).times(3), const Money.lira(300));
      expect(const Money.cents(33).times(3).cents, 99);
    });
  });

  group('Model JSON gidiş-dönüş', () {
    void roundTrip<T>(
      String name,
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) from,
      Object Function(T) to,
    ) {
      test(name, () {
        final m = from(json);
        final back = jsonDecode(jsonEncode(to(m))) as Map<String, dynamic>;
        expect(from(back), m);
      });
    }

    roundTrip<MediaRef>('MediaRef', media(), MediaRef.fromJson, (m) => m.toJson());
    roundTrip<ProCard>('ProCard', proCard(), ProCard.fromJson, (m) => m.toJson());
    roundTrip<RequestSummary>(
      'RequestSummary',
      requestSummary(),
      RequestSummary.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<RequestDetail>(
      'RequestDetail',
      requestDetail(),
      RequestDetail.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<OfferSummary>(
      'OfferSummary',
      offerSummary(),
      OfferSummary.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<OfferDetail>(
      'OfferDetail',
      offerDetail(),
      OfferDetail.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<FeedItem>('FeedItem', feedItem(), FeedItem.fromJson, (m) => m.toJson());
    roundTrip<ProRequestDetail>(
      'ProRequestDetail',
      {
        ...feedItem(),
        'description': 'Açıklama açıklama açıklama',
        'photos': [media()],
        'answers': <Object>[],
        'myOffer': offerDetail(),
      },
      ProRequestDetail.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<ProApplication>(
      'ProApplication',
      {
        'reviewStatus': 'NEEDS_DOCUMENTS',
        'reviewNote': 'Kimlik okunmuyor',
        'businessName': 'Usta',
        'bio': '',
        'experienceYears': 5,
        'categoryIds': [1, 2],
        'districtIds': ['3'],
        'documents': [
          {'id': 'd1', 'type': 'IDENTITY', 'status': 'REJECTED', 'media': media()},
        ],
        'submittedAt': '2026-11-10T08:00:00Z',
      },
      ProApplication.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<ProProfile>(
      'ProProfile',
      {
        'businessName': 'Usta',
        'bio': 'Yazı',
        'experienceYears': 3,
        'categoryIds': ['1'],
        'districtIds': ['2'],
        'workingHours': [
          {'weekday': 1, 'start': '09:00', 'end': '18:00', 'acceptsUrgent': true},
        ],
        'reviewStatus': 'APPROVED',
        'availability': 'ON_BREAK',
        'ratingAvg': 4.8,
        'ratingCount': 3,
        'completedJobs': 4,
      },
      ProProfile.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<ProPublicProfile>(
      'ProPublicProfile',
      {
        'id': 'p1',
        'businessName': 'Usta',
        'fullName': 'Ali Usta',
        'bio': 'Yazı',
        'experienceYears': 3,
        'ratingAvg': 4.8,
        'ratingCount': 3,
        'completedJobs': 4,
        'memberSince': '2026-01-10T00:00:00Z',
        'categoryIds': ['1'],
        'districts': [
          {'id': '2', 'name': 'Kadıköy'},
        ],
        'verifiedDocuments': ['IDENTITY', 'TRADE_CERT'],
      },
      ProPublicProfile.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<ReviewItem>(
      'ReviewItem',
      {
        'id': 'v1',
        'rating': 5,
        'tags': ['Temiz'],
        'comment': null,
        'authorDisplay': 'A.Y.',
        'createdAt': '2026-11-10T08:00:00Z',
      },
      ReviewItem.fromJson,
      (m) => m.toJson(),
    );
    roundTrip<Question>(
      'Question',
      {
        'key': 'since',
        'labelTr': 'Ne zamandır?',
        'labelEn': 'Since when?',
        'options': [
          {'value': 'today', 'labelTr': 'Bugün', 'labelEn': 'Today'},
        ],
      },
      Question.fromJson,
      (m) => m.toJson(),
    );

    test('Paged<T> ve imleç', () {
      final p = Paged.fromJson({
        'items': [requestSummary()],
        'nextCursor': 'abc',
      }, RequestSummary.fromJson);
      expect(p.items.single.minOfferTotal, const Money.cents(200000));
      expect(p.hasMore, isTrue);
      final last = Paged.fromJson({
        'items': <Object>[],
        'nextCursor': null,
      }, RequestSummary.fromJson);
      expect(last.hasMore, isFalse);
    });

    test('müşteride serviceFee ve netEarning null', () {
      final j = offerDetail()
        ..['serviceFee'] = null
        ..['netEarning'] = null;
      final o = OfferDetail.fromJson(j);
      expect(o.serviceFee, isNull);
      expect(o.netEarning, isNull);
      expect(o.items, hasLength(2));
      expect(o.items.last.kind, OfferItemKind.material);
    });

    test('ProOfferItem satırı düz yapıdan çözülür', () {
      final item = ProOfferItem.fromJson({
        ...offerSummary(),
        'request': {
          'id': 'r1',
          'publicCode': 'BD-1',
          'title': 'T',
          'districtName': 'Kadıköy',
        },
      });
      expect(item.request.districtName, 'Kadıköy');
      expect(ProOfferItem.fromJson(item.toJson()), item);
    });

    test('bilinmeyen enum ApiException(unknown) olur', () {
      final j = requestSummary()..['status'] = 'ZZZ';
      expect(
        () => decodeApi(() => RequestSummary.fromJson(j)),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', ApiErrorCode.unknown),
        ),
      );
    });
  });

  group('İstek gövdeleri', () {
    test('RequestInput: sayısal kimlikler sayı, PLANNED tarihleri ISO', () {
      final body = RequestInput(
        categoryId: '2',
        urgency: RequestUrgency.planned,
        preferredFrom: DateTime.utc(2026, 11, 12, 8),
        preferredTo: DateTime.utc(2026, 11, 12, 12),
        title: 'Başlık',
        description: 'x' * 20,
        addressId: '7',
        photoIds: const ['a1', '5'],
        answers: const [RequestAnswer(questionKey: 'since', answer: 'today')],
      ).toJson();
      expect(body['categoryId'], 2);
      expect(body['addressId'], 7);
      expect(body['photoIds'], ['a1', 5]);
      expect(body['urgency'], 'PLANNED');
      expect(body['preferredFrom'], '2026-11-12T08:00:00.000Z');
      expect((body['answers'] as List).single, {
        'questionKey': 'since',
        'answer': 'today',
      });
    });

    test('CreateOfferRequest tutarlar sayı olarak gider', () {
      final body = CreateOfferRequest(
        laborAmount: const Money.lira(1800),
        materialsAmount: const Money.cents(65050),
        arrivalFrom: DateTime.utc(2026, 11, 11, 10),
        arrivalTo: DateTime.utc(2026, 11, 11, 12),
        warrantyMonths: 6,
        items: const [
          OfferItemInput(
            kind: OfferItemKind.material,
            description: 'Vana',
            quantity: 2,
            unitPrice: Money.cents(32525),
          ),
        ],
      ).toJson();
      expect(body['laborAmount'], 1800);
      expect(body['materialsAmount'], 650.5);
      expect((body['items'] as List).single['unitPrice'], 325.25);
    });
  });

  group('API sınıfları', () {
    test('RequestsApi.offers: sıralama ve filtre sorguya gider', () async {
      final a = FakeAdapter(
        (_) => jsonBody(200, {
          'items': [offerSummary()],
          'declinedCount': 1,
        }),
      );
      final res = await clientWith(a).requests.offers(
        'r1',
        sort: OfferSort.price,
        maxPrice: const Money.lira(2500),
        minRating: 4.5,
      );
      expect(res.declinedCount, 1);
      final q = a.requests.single.queryParameters;
      expect(q, {'sort': 'price', 'maxPrice': '2500', 'minRating': 4.5});
    });

    test('RequestsApi.list: scope ve imleç', () async {
      final a = FakeAdapter(
        (_) => jsonBody(200, {'items': <Object>[], 'nextCursor': null}),
      );
      await clientWith(a).requests.list(scope: 'past', cursor: 'c1');
      expect(a.requests.single.queryParameters, {'scope': 'past', 'cursor': 'c1'});
    });

    test('ProApi.createOffer Idempotency-Key başlığını gönderir', () async {
      final a = FakeAdapter((_) => jsonBody(201, offerDetail()));
      await clientWith(a).pro.createOffer(
        'r1',
        CreateOfferRequest(
          laborAmount: const Money.lira(1),
          materialsAmount: Money.zero,
          arrivalFrom: DateTime.utc(2026, 11, 11, 10),
          arrivalTo: DateTime.utc(2026, 11, 11, 12),
          warrantyMonths: 0,
        ),
        idempotencyKey: 'key-1',
      );
      expect(a.requests.single.headers['Idempotency-Key'], 'key-1');
      expect(a.requests.single.path, endsWith('/pro/requests/r1/offers'));
    });

    test('ProApi.feed urgency ve offers status sorguları', () async {
      final a = FakeAdapter(
        (o) => o.path.endsWith('/pro/feed')
            ? jsonBody(200, {'items': [feedItem()], 'onBreak': false})
            : jsonBody(200, {'items': <Object>[], 'nextCursor': null}),
      );
      final c = clientWith(a);
      final feed = await c.pro.feed(urgency: RequestUrgency.urgent);
      expect(feed.items.single.photoCount, 2);
      await c.pro.offers(status: OfferStatus.pending);
      expect(a.requests[0].queryParameters, {'urgency': 'URGENT'});
      expect(a.requests[1].queryParameters, {'status': 'PENDING'});
    });

    test('ProApi.setAvailability gövdesi', () async {
      final a = FakeAdapter(
        (_) => jsonBody(200, {
          'businessName': 'U',
          'reviewStatus': 'APPROVED',
          'availability': 'ON_BREAK',
        }),
      );
      final p = await clientWith(a).pro.setAvailability(ProAvailability.onBreak);
      expect(p.availability, ProAvailability.onBreak);
      expect(a.requests.single.data, {'availability': 'ON_BREAK'});
      expect(a.requests.single.method, 'PUT');
    });

    test('MediaApi.upload multipart gönderir ve purpose yazar', () async {
      final a = FakeAdapter(
        (_) => jsonBody(201, {
          'id': 'm9',
          'contentType': 'image/jpeg',
          'sizeBytes': 3,
          'width': 1,
          'height': 1,
        }),
      );
      final res = await clientWith(a).media.upload(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'a.jpg',
        purpose: MediaPurpose.requestPhoto,
        contentType: 'image/jpeg',
      );
      expect(res.id, 'm9');
      final data = a.requests.single.data as FormData;
      expect(data.fields.single.key, 'purpose');
      expect(data.fields.single.value, 'REQUEST_PHOTO');
      expect(data.files.single.key, 'file');
      expect(
        a.requests.single.headers['content-type'] ??
            a.requests.single.contentType,
        contains('multipart/form-data'),
      );
    });

    test('MediaApi.upload 401 yenilemesinden sonra gövdeyi baştan kurar', () async {
      var uploads = 0;
      final a = FakeAdapter((o) {
        if (o.path.endsWith('/auth/refresh')) {
          return jsonBody(200, {
            'accessToken': 'A2',
            'refreshToken': 'R2',
            'accessExpiresIn': 900,
            'user': {
              'id': 'u',
              'fullName': 'A B',
              'email': 'a@b.co',
              'phone': '+905000000000',
              'locale': 'tr',
              'lastMode': 'CUSTOMER',
              'isAdmin': false,
              'status': 'ACTIVE',
            },
          });
        }
        uploads++;
        if (uploads == 1) {
          return jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'x'});
        }
        return jsonBody(201, {
          'id': 'm1',
          'contentType': 'image/jpeg',
          'sizeBytes': 3,
        });
      });
      final res = await clientWith(a).media.upload(
        bytes: Uint8List.fromList([1, 2, 3]),
        filename: 'a.jpg',
        purpose: MediaPurpose.proDocument,
      );
      expect(res.id, 'm1');
      expect(uploads, 2);
    });

    test('CatalogApi.questions ve MeApi.addresses', () async {
      final a = FakeAdapter((o) {
        if (o.path.endsWith('/questions')) {
          return jsonBody(200, [
            {
              'key': 'since',
              'labelTr': 'T',
              'labelEn': 'E',
              'options': [
                {'value': 'today', 'labelTr': 'Bugün', 'labelEn': 'Today'},
              ],
            },
          ]);
        }
        return jsonBody(200, <Object>[]);
      });
      final c = clientWith(a);
      final qs = await c.catalog.questions('plumbing');
      expect(qs.single.options.single.value, 'today');
      expect(a.requests.single.path, endsWith('/categories/plumbing/questions'));
      expect(await c.me.addresses(), isEmpty);
    });
  });
}
