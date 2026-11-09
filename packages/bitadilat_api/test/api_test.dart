import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

typedef Handler = FutureOr<ResponseBody> Function(RequestOptions options);

/// Sahte HTTP: istekleri kaydeder, `handler` ile yanıt üretir.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Handler handler;
  final List<RequestOptions> requests = [];

  int count(String path) =>
      requests.where((r) => r.path.endsWith(path)).length;

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

Map<String, dynamic> meJson({Object? pro}) => {
  'id': 'u-1',
  'fullName': 'Ayşe Yılmaz',
  'email': 'ayse@example.com',
  'phone': '+905551112233',
  'locale': 'tr',
  'lastMode': 'CUSTOMER',
  'isAdmin': false,
  'status': 'ACTIVE',
  'pro': pro,
};

Map<String, dynamic> authJson(String access, String refresh) => {
  'accessToken': access,
  'refreshToken': refresh,
  'accessExpiresIn': 900,
  'user': meJson(),
};

ApiClient clientWith(FakeAdapter adapter, TokenStore store) => ApiClient(
  config: const ApiConfig('http://localhost:8090'),
  tokenStore: store,
  adapter: adapter,
);

void main() {
  group('hata çözümleme', () {
    test('hata JSON\'u ApiException olur', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(409, {
          'code': 'EMAIL_TAKEN',
          'message': 'dev msg',
          'field': 'email',
        }),
      );
      final client = clientWith(adapter, MemoryTokenStore());
      await expectLater(
        client.auth.login(
          const LoginRequest(identifier: 'a@b.c', password: 'x'),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.emailTaken)
              .having((e) => e.field, 'field', 'email')
              .having((e) => e.message, 'message', 'dev msg')
              .having((e) => e.statusCode, 'status', 409),
        ),
      );
    });

    test('bilinmeyen kod unknown olur', () {
      final e = ApiException.fromResponse(418, {'code': 'TEAPOT'});
      expect(e.code, ApiErrorCode.unknown);
      expect(e.statusCode, 418);
    });

    test('ağ hatası networkError olur', () async {
      final adapter = FakeAdapter(
        (o) => throw DioException.connectionError(
          requestOptions: o,
          reason: 'offline',
        ),
      );
      final client = clientWith(adapter, MemoryTokenStore());
      await expectLater(
        client.me.get(),
        throwsA(
          isA<ApiException>().having((e) => e.isNetworkError, 'net', true),
        ),
      );
    });

    test('her bilinen kod ayrıştırılır', () {
      for (final c in ApiErrorCode.values) {
        if (c == ApiErrorCode.networkError || c == ApiErrorCode.unknown) {
          continue;
        }
        expect(ApiErrorCode.parse(c.wire), c);
      }
    });
  });

  group('AuthInterceptor', () {
    test('Bearer ekler', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'A1', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter((_) => jsonBody(200, meJson()));
      final client = clientWith(adapter, store);
      await client.me.get();
      expect(adapter.requests.single.headers['Authorization'], 'Bearer A1');
    });

    test('3 paralel 401 tam 1 refresh yapar, 3 istek de tekrarlanıp başarılır',
        () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter((o) async {
        if (o.path.endsWith('/auth/refresh')) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return jsonBody(200, authJson('NEW', 'R2'));
        }
        if (o.headers['Authorization'] == 'Bearer NEW') {
          return jsonBody(200, meJson());
        }
        return jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'expired'});
      });
      final client = clientWith(adapter, store);

      final results = await Future.wait([
        client.me.get(),
        client.me.get(),
        client.me.get(),
      ]);

      expect(results, hasLength(3));
      expect(adapter.count('/auth/refresh'), 1);
      // 3 ilk deneme + 3 tekrar
      expect(adapter.count('/me'), 6);
      final tokens = await store.read();
      expect(tokens?.accessToken, 'NEW');
      expect(tokens?.refreshToken, 'R2');
    });

    test('refresh 401 dönerse sessionExpired tetiklenir, token\'lar silinir',
        () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter((o) async {
        if (o.path.endsWith('/auth/refresh')) {
          return jsonBody(401, {'code': 'UNAUTHENTICATED'});
        }
        return jsonBody(401, {'code': 'TOKEN_EXPIRED'});
      });
      final client = clientWith(adapter, store);
      var events = 0;
      client.sessionExpired.listen((_) => events++);

      await expectLater(
        Future.wait([
          client.me.get(),
          client.me.get(),
        ]),
        throwsA(isA<ApiException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(await store.read(), isNull);
      expect(events, 1);
      expect(adapter.count('/auth/refresh'), 1);
    });

    test('refresh sırasında ağ hatası token\'ları silmez', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter((o) async {
        if (o.path.endsWith('/auth/refresh')) {
          throw DioException.connectionError(requestOptions: o, reason: 'x');
        }
        return jsonBody(401, {'code': 'TOKEN_EXPIRED'});
      });
      final client = clientWith(adapter, store);
      await expectLater(client.me.get(), throwsA(isA<ApiException>()));
      expect(await store.read(), isNotNull);
    });

    test('giriş token\'ları depoya yazar', () async {
      final store = MemoryTokenStore();
      final adapter = FakeAdapter((_) => jsonBody(200, authJson('A', 'R')));
      final client = clientWith(adapter, store);
      final res = await client.auth.login(
        const LoginRequest(identifier: 'a@b.c', password: 'secret123'),
      );
      expect(res.user.id, 'u-1');
      expect((await store.read())?.refreshToken, 'R');
      expect(adapter.requests.single.headers.containsKey('Authorization'),
          isFalse);
    });
  });

  group('modeller', () {
    test('AuthResponse gidiş-dönüş', () {
      final json = authJson('A', 'R');
      json['user'] = meJson(
        pro: {
          'reviewStatus': 'PENDING_REVIEW',
          'availability': 'ON_BREAK',
          'businessName': 'Usta Tesisat',
        },
      );
      final model = AuthResponse.fromJson(json);
      expect(model.user.pro?.reviewStatus, ReviewStatus.pendingReview);
      expect(model.user.pro?.availability, ProAvailability.onBreak);
      expect(AuthResponse.fromJson(model.toJson()), model);
      expect(jsonDecode(jsonEncode(model.toJson())), json);
    });

    test('Me pro null', () {
      final me = Me.fromJson(meJson());
      expect(me.pro, isNull);
      expect(me.lastMode, UserMode.customer);
      expect(Me.fromJson(me.toJson()), me);
    });

    test('Address, Category, District gidiş-dönüş', () {
      final address = Address.fromJson({
        'id': 'a1',
        'label': 'Ev',
        'districtId': 12,
        'districtName': 'Kadıköy',
        'neighborhood': 'Moda',
        'lineFull': 'Moda Cd. 1',
        'doorNote': null,
        'isDefault': true,
      });
      expect(address.districtId, '12');
      expect(Address.fromJson(address.toJson()), address);

      final category = Category.fromJson({
        'id': 'plumbing',
        'nameTr': 'Tesisat',
        'nameEn': 'Plumbing',
        'icon': 'water',
        'colorHex': '#0F4C5C',
        'sortOrder': 1,
      });
      expect(Category.fromJson(category.toJson()), category);

      final district = District.fromJson({
        'id': 'kadikoy',
        'name': 'Kadıköy',
        'side': 'ANADOLU',
      });
      expect(District.fromJson(district.toJson()), district);
    });

    test('istek gövdeleri sözleşme alan adlarıyla gider', () {
      expect(
        const RegisterRequest(
          fullName: 'A B',
          email: 'a@b.c',
          phone: '+905551112233',
          password: 'abcd1234',
          wantsPro: true,
          kvkkAccepted: true,
          termsAccepted: true,
        ).toJson().keys.toSet(),
        {
          'fullName',
          'email',
          'phone',
          'password',
          'wantsPro',
          'kvkkAccepted',
          'termsAccepted',
        },
      );
      expect(
        const LoginRequest(identifier: 'x', password: 'y').toJson().keys,
        ['identifier', 'password'],
      );
      expect(
        const ResetPasswordRequest(
          email: 'e',
          code: '123456',
          newPassword: 'p',
        ).toJson().keys,
        ['email', 'code', 'newPassword'],
      );
      expect(const UpdateMeRequest(lastMode: UserMode.pro).toJson(), {
        'lastMode': 'PRO',
      });
    });
  });
}
