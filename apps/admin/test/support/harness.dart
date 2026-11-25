import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_admin/app/app.dart';
import 'package:bitadilat_admin/app/router.dart';
import 'package:bitadilat_admin/core/providers.dart';
import 'package:bitadilat_admin/features/auth/session.dart';
import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Responder = FutureOr<ResponseBody> Function(RequestOptions options);

ResponseBody json(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ResponseBody empty(int status) => ResponseBody.fromString('', status);

ResponseBody apiError(int status, String code) =>
    json(status, {'code': code, 'message': 'dev'});

/// Yönteme ve yola göre yanıt veren sahte HTTP bağdaştırıcısı.
class FakeApi implements HttpClientAdapter {
  FakeApi({bool standard = true}) {
    if (standard) _standard();
  }

  final Map<String, Responder> _routes = {};
  final List<RequestOptions> requests = [];

  void on(String method, String path, Responder r) =>
      _routes['$method $path'] = r;

  void onJson(String method, String path, Object? body, {int status = 200}) =>
      on(method, path, (_) => json(status, body));

  List<RequestOptions> calls(String method, String path) =>
      requests.where((r) => r.method == method && _path(r) == path).toList();

  int count(String method, String path) => calls(method, path).length;

  RequestOptions last(String method, String path) => calls(method, path).last;

  static String _path(RequestOptions o) => o.path.replaceFirst('/api/v1', '');

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final r = _routes['${options.method} ${_path(options)}'];
    if (r == null) return apiError(404, 'NOT_FOUND');
    return r(options);
  }

  @override
  void close({bool force = false}) {}

  void _standard() {
    onJson('GET', '/admin/stats', statsJson());
    onJson('GET', '/admin/payments/review', {'items': <Object>[]});
    onJson('GET', '/districts', [
      {'id': 3, 'name': 'Ataşehir', 'side': 'ANADOLU'},
      {'id': 23, 'name': 'Kadıköy', 'side': 'ANADOLU'},
    ]);
    onJson('GET', '/categories', [
      {
        'id': 'plumbing',
        'nameTr': 'Tesisat',
        'nameEn': 'Plumbing',
        'icon': 'plumbing',
        'colorHex': '#0F4C5C',
        'sortOrder': 1,
      },
      {
        'id': 'electrical',
        'nameTr': 'Elektrik',
        'nameEn': 'Electrical',
        'icon': 'bolt',
        'colorHex': '#0F4C5C',
        'sortOrder': 2,
      },
    ]);
    onJson('GET', '/admin/applications', {
      'items': [applicationSummaryJson(), applicationSummaryJson(id: 'p10')],
    });
    onJson('GET', '/admin/applications/p9', applicationDetailJson());
    onJson('GET', '/admin/complaints', {
      'items': [complaintItemJson()],
    });
    onJson('GET', '/admin/complaints/c1', complaintDetailJson());
    onJson('GET', '/admin/users', {'items': usersJson()});
    onJson('GET', '/admin/payments', paymentsJson());
  }
}

// --- Fixture'lar ---------------------------------------------------------------

Map<String, dynamic> statsJson() => {
  'pendingApplications': 4,
  'openComplaints': 2,
  'activeJobs': 17,
  'lockedEscrowTotal': 12450.5,
};

Map<String, dynamic> mediaJson([String id = 'm1']) => {
  'id': id,
  'url': 'http://localhost:8090/api/v1/media/$id/content?exp=1&sig=2',
  'expiresAt': '2026-11-10T10:00:00Z',
};

Map<String, dynamic> meJson({bool isAdmin = true}) => {
  'id': 'admin-1',
  'fullName': 'Zeynep Yönetici',
  'email': 'admin@bitadilat.test',
  'phone': null,
  'locale': 'tr',
  'lastMode': 'CUSTOMER',
  'isAdmin': isAdmin,
  'status': 'ACTIVE',
  'pro': null,
};

Map<String, dynamic> authJson({bool isAdmin = true}) => {
  'accessToken': 'ACCESS',
  'refreshToken': 'REFRESH',
  'accessExpiresIn': 900,
  'user': meJson(isAdmin: isAdmin),
};

Map<String, dynamic> applicationSummaryJson({
  String id = 'p9',
  String status = 'PENDING_REVIEW',
}) => {
  'proId': id,
  'fullName': id == 'p9' ? 'Hasan Kaya' : 'Selim Demir',
  'businessName': id == 'p9' ? 'Kaya Tesisat' : 'Demir Elektrik',
  'categoryIds': [id == 'p9' ? 'plumbing' : 'electrical'],
  'districtNames': ['Kadıköy', 'Üsküdar'],
  'submittedAt': '2026-11-09T09:00:00Z',
  'reviewStatus': status,
  'documentCount': 2,
};

Map<String, dynamic> applicationDetailJson({
  String status = 'PENDING_REVIEW',
  String? note,
}) => {
  ...applicationSummaryJson(status: status),
  'email': 'hasan@example.com',
  'phone': '+905320000000',
  'bio': 'Yirmi yıllık tesisat tecrübem var.',
  'experienceYears': 20,
  'reviewNote': note,
  'documents': [
    {
      'id': 'd1',
      'type': 'IDENTITY',
      'status': 'PENDING',
      'media': mediaJson('d1'),
    },
    {'id': 'd2', 'type': 'TAX', 'status': 'PENDING', 'media': mediaJson('d2')},
  ],
  'history': [
    {
      'id': 1,
      'action': 'REQUEST_DOCUMENTS',
      'note': 'Vergi levhası okunmuyor.',
      'adminName': 'Zeynep Yönetici',
      'createdAt': '2026-11-09T10:00:00Z',
    },
  ],
};

Map<String, dynamic> complaintItemJson({
  String id = 'c1',
  String status = 'OPEN',
}) => {
  'id': id,
  'publicCode': 'SK-1001',
  'jobId': 'j1',
  'jobPublicCode': 'BD-88409',
  'reason': 'INCOMPLETE_WORK',
  'status': status,
  'customerName': 'Ayşe Yılmaz',
  'proBusinessName': 'Mavi Hat',
  'amount': 2200,
  'createdAt': '2026-11-10T09:00:00Z',
};

Map<String, dynamic> complaintDetailJson({
  String status = 'OPEN',
  String? decision,
  String? decisionNote,
}) => {
  'id': 'c1',
  'publicCode': 'SK-1001',
  'jobId': 'j1',
  'reason': 'INCOMPLETE_WORK',
  'description': 'İş yarım bırakıldı, usta geri dönmedi.',
  'evidence': [mediaJson('e1')],
  'status': status,
  'decision': decision,
  'decisionNote': decisionNote,
  'createdAt': '2026-11-10T09:00:00Z',
  'decidedAt': decision == null ? null : '2026-11-11T09:00:00Z',
  'refundAmount': decision == null ? null : 1100,
  'proAmount': decision == null ? null : 1100,
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
        'fromStatus': 'SCHEDULED',
        'toStatus': 'ARRIVED',
        'note': null,
        'photo': null,
        'actorRole': 'PRO',
        'createdAt': '2026-11-10T08:00:00Z',
      },
      {
        'id': 2,
        'type': 'NOTE',
        'note': 'Parça eksik, yarın tamamlarım.',
        'photo': null,
        'actorRole': 'PRO',
        'createdAt': '2026-11-10T08:30:00Z',
      },
    ],
    'offer': {
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
      'laborAmount': 1500,
      'materialsAmount': 700,
      'totalAmount': 2200,
      'arrivalFrom': '2026-11-11T10:00:00Z',
      'arrivalTo': '2026-11-11T12:00:00Z',
      'warrantyMonths': 6,
      'validUntil': '2026-11-11T12:00:00Z',
      'createdAt': '2026-11-10T08:00:00Z',
      'items': [],
    },
    'districtName': 'Kadıköy',
  },
  'payment': {
    'ref': 'PAY-1001',
    'status': 'DISPUTED',
    'provider': 'CRAFTGATE',
    'totalAmount': 2200,
    'commission': 220,
    'proPayout': 1980,
    'refundedAmount': 0,
  },
  'messages': [
    {
      'id': 5,
      'senderRole': 'CUSTOMER',
      'body': 'Ne zaman geleceksin?',
      'photo': null,
      'createdAt': '2026-11-10T08:40:00Z',
    },
    {
      'id': 6,
      'senderRole': 'PRO',
      'body': 'Yarın sabah geliyorum.',
      'photo': null,
      'createdAt': '2026-11-10T08:45:00Z',
    },
  ],
  'customer': {'id': 'u1', 'fullName': 'Ayşe Yılmaz'},
  'pro': {
    'id': 'p1',
    'businessName': 'Mavi Hat',
    'fullName': 'Ali Usta',
    'warningCount': 2,
    'cancellationCount': 3,
  },
};

List<Map<String, dynamic>> usersJson() => [
  {
    'id': 'admin-1',
    'fullName': 'Zeynep Yönetici',
    'email': 'admin@bitadilat.test',
    'phone': null,
    'isAdmin': true,
    'status': 'ACTIVE',
    'createdAt': '2026-10-01T09:00:00Z',
    'pro': null,
  },
  {
    'id': 'admin-2',
    'fullName': 'Murat Yönetici',
    'email': 'murat@bitadilat.test',
    'phone': null,
    'isAdmin': true,
    'status': 'ACTIVE',
    'createdAt': '2026-10-02T09:00:00Z',
    'pro': null,
  },
  {
    'id': 'u-1',
    'fullName': 'Ayşe Yılmaz',
    'email': 'ayse@example.com',
    'phone': '+905321112233',
    'isAdmin': false,
    'status': 'ACTIVE',
    'createdAt': '2026-10-03T09:00:00Z',
    'pro': null,
  },
  {
    'id': 'u-2',
    'fullName': 'Ali Usta',
    'email': 'ali@example.com',
    'phone': '+905320000001',
    'isAdmin': false,
    'status': 'SUSPENDED',
    'createdAt': '2026-10-04T09:00:00Z',
    'pro': {'businessName': 'Mavi Hat', 'reviewStatus': 'APPROVED'},
  },
  {
    'id': 'u-3',
    'fullName': 'Silinmiş Kişi',
    'email': 'gone@example.com',
    'phone': null,
    'isAdmin': false,
    'status': 'DELETED',
    'createdAt': '2026-10-05T09:00:00Z',
    'pro': null,
  },
];

Map<String, dynamic> paymentsJson() => {
  'items': [
    {
      'ref': 'PAY-1001',
      'jobPublicCode': 'BD-88409',
      'status': 'DISPUTED',
      'provider': 'CRAFTGATE',
      'totalAmount': 2200,
      'commission': 220,
      'proPayout': 1980,
      'refundedAmount': 0,
      'customerName': 'Ayşe Yılmaz',
      'proBusinessName': 'Mavi Hat',
      'createdAt': '2026-11-10T09:00:00Z',
      'lockedAt': '2026-11-10T09:01:00Z',
      'releasedAt': null,
      'refundedAt': null,
      'errorCode': null,
    },
    {
      'ref': 'PAY-1002',
      'jobPublicCode': 'BD-88410',
      'status': 'REFUNDED_TO_CUSTOMER',
      'provider': 'SEED',
      'totalAmount': 1225.5,
      'commission': 0,
      'proPayout': 0,
      'refundedAmount': 1225.5,
      'customerName': 'Burak Can',
      'proBusinessName': 'Demir Elektrik',
      'createdAt': '2026-11-08T09:00:00Z',
      'lockedAt': '2026-11-08T09:01:00Z',
      'releasedAt': null,
      'refundedAt': '2026-11-09T09:00:00Z',
      'errorCode': 'REQUEST_ALREADY_ASSIGNED',
    },
  ],
  'totals': {
    'lockedTotal': 2200,
    'releasedTotal': 8800,
    'commissionTotal': 880,
    'refundedTotal': 1225.5,
  },
};

// --- Uygulama ------------------------------------------------------------------

/// Sabit "şimdi": tarihler testte kaymaz.
final testNow = DateTime.utc(2026, 11, 11, 12);

class FakeSession extends SessionController {
  FakeSession(this.initial);

  final SessionState initial;

  @override
  SessionState build() => initial;
}

class Harness {
  Harness(this.container, this.fake, this.store, this.opened);

  final ProviderContainer container;
  final FakeApi fake;
  final MemoryTokenStore store;

  /// "Yeni sekmede aç" ile istenen adresler.
  final List<String> opened;

  GoRouter get router => container.read(routerProvider);
  String get location => router.state.uri.toString();
}

/// Uygulamayı çizer. `signedIn` iken oturum hazır başlar (ağ çağrısı yok).
Future<Harness> pumpAdmin(
  WidgetTester tester, {
  FakeApi? fake,
  Size size = const Size(1280, 900),
  String locale = 'tr',
  bool signedIn = true,
  String? initial,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({'locale': locale});
  final prefs = await SharedPreferences.getInstance();
  final f = fake ?? FakeApi();
  final store = MemoryTokenStore(
    signedIn
        ? const TokenPair(accessToken: 'ACCESS', refreshToken: 'REFRESH')
        : null,
  );
  final client = ApiClient(
    config: const ApiConfig('http://localhost:8090'),
    tokenStore: store,
    adapter: f,
  );
  final opened = <String>[];
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(store),
      apiClientProvider.overrideWithValue(client),
      nowProvider.overrideWithValue(() => testNow),
      urlOpenerProvider.overrideWithValue((url) async => opened.add(url)),
      initialLocationProvider.overrideWithValue(
        initial ?? (signedIn ? '/' : '/login'),
      ),
      if (signedIn)
        sessionProvider.overrideWith(
          () => FakeSession(SessionState.signedIn(Me.fromJson(meJson()))),
        ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AdminApp()),
  );
  await tester.pumpAndSettle();
  return Harness(container, f, store, opened);
}

/// Giriş formunu doldurup gönderir.
Future<void> submitLogin(
  WidgetTester tester, {
  String email = 'admin@bitadilat.test',
  String password = 'Demo1234!',
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}
