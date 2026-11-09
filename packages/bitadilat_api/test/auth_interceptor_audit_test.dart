// Denetimde bulunan AuthInterceptor yarışları ve hata sınıfları için testler.
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

  /// Gönderim anındaki (yol, Authorization) çiftleri; tekrar denenen istek
  /// aynı `RequestOptions` nesnesini değiştirdiği için ayrıca saklanır.
  final List<(String, Object?)> sent = [];

  int count(String path) => requests.where((r) => r.path.endsWith(path)).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sent.add((options.path, options.headers['Authorization']));
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

Map<String, dynamic> meJson() => {
  'id': 'u-1',
  'fullName': 'Ayşe Yılmaz',
  'email': 'ayse@example.com',
  'phone': '+905551112233',
  'locale': 'tr',
  'lastMode': 'CUSTOMER',
  'isAdmin': false,
  'status': 'ACTIVE',
  'pro': null,
};

Map<String, dynamic> authJson(String access, String refresh) => {
  'accessToken': access,
  'refreshToken': refresh,
  'accessExpiresIn': 900,
  'user': meJson(),
};

/// Gerçek güvenli depolama gibi: okuma çağrı anındaki değeri gecikmeyle
/// döndürür (platform kanalı). Eski uygulamada bu, refresh bittikten sonra
/// eski token'ı görüp ikinci bir refresh başlatıyordu.
class SlowStore implements TokenStore {
  SlowStore(this._tokens);

  TokenPair? _tokens;
  Duration readDelay = const Duration(milliseconds: 30);

  @override
  Future<TokenPair?> read() async {
    final snapshot = _tokens;
    await Future<void>.delayed(readDelay);
    return snapshot;
  }

  @override
  Future<void> write(TokenPair tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

ApiClient clientWith(FakeAdapter adapter, TokenStore store) => ApiClient(
  config: const ApiConfig('http://localhost:8090'),
  tokenStore: store,
  adapter: adapter,
);

/// Sunucu gibi davranır: refresh token döner (rotasyon), eski refresh token
/// ikinci kez kullanılırsa 401 verir.
Handler rotatingServer({Duration refreshDelay = Duration.zero}) {
  var valid = 'R1';
  var access = 'OLD';
  var n = 1;
  return (o) async {
    if (o.path.endsWith('/auth/refresh')) {
      await Future<void>.delayed(refreshDelay);
      final sent = (o.data as Map)['refreshToken'];
      if (sent != valid) {
        return jsonBody(401, {'code': 'UNAUTHENTICATED', 'message': 'reuse'});
      }
      n++;
      valid = 'R$n';
      access = 'A$n';
      return jsonBody(200, authJson(access, valid));
    }
    if (o.headers['Authorization'] == 'Bearer $access' && access != 'OLD') {
      return jsonBody(200, meJson());
    }
    return jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'expired'});
  };
}

void main() {
  group('AuthInterceptor yarışları', () {
    test('refresh bittikten sonra gelen eski token 401\'i ikinci refresh '
        'yapmaz (yavaş depo)', () async {
      final store = SlowStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final server = rotatingServer(
        refreshDelay: const Duration(milliseconds: 10),
      );
      // İkinci isteğin 401'i, birincinin refresh'i bitmek üzereyken gelir.
      var meCalls = 0;
      final adapter = FakeAdapter((o) async {
        if (o.path.endsWith('/me') && o.extra['authRetried'] != true) {
          meCalls++;
          if (meCalls == 2) {
            await Future<void>.delayed(const Duration(milliseconds: 35));
          }
        }
        return server(o);
      });
      final client = clientWith(adapter, store);
      final ended = <SessionEndReason>[];
      client.sessionEnded.listen(ended.add);

      final results = await Future.wait([client.me.get(), client.me.get()]);

      expect(results, hasLength(2));
      expect(adapter.count('/auth/refresh'), 1);
      expect(ended, isEmpty);
      expect((await store.read())?.refreshToken, 'R2');
    });

    test(
      'refresh sürerken başlayan istek bekletilir ve yeni token ile gider',
      () async {
        final store = MemoryTokenStore(
          const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
        );
        final adapter = FakeAdapter(
          rotatingServer(refreshDelay: const Duration(milliseconds: 50)),
        );
        final client = clientWith(adapter, store);

        final first = client.me.get();
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(adapter.count('/auth/refresh'), 1, reason: 'refresh sürüyor');
        final second = client.me.get();
        await Future.wait([first, second]);

        final meRequests = adapter.sent
            .where((r) => r.$1.endsWith('/me'))
            .map((r) => r.$2)
            .toList();
        // İlk istek OLD ile gider; geri kalanlar (tekrar + bekletilen) A2 ile.
        expect(meRequests, ['Bearer OLD', 'Bearer A2', 'Bearer A2']);
        expect(adapter.count('/auth/refresh'), 1);
      },
    );

    test('tekrar denenen istek yeni token ile gider', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter(rotatingServer());
      final client = clientWith(adapter, store);
      await client.me.get();
      expect(adapter.sent.map((r) => r.$2).toList(), [
        'Bearer OLD',
        null, // refresh: Bearer yok
        'Bearer A2',
      ]);
    });

    test('refresh isteği interceptor\'a takılmaz: refresh TOKEN_EXPIRED '
        'dönse de tek refresh, döngü yok', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter(
        (o) => jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'x'}),
      );
      final client = clientWith(adapter, store);
      await expectLater(client.me.get(), throwsA(isA<ApiException>()));
      expect(adapter.count('/auth/refresh'), 1);
      expect(adapter.count('/me'), 1);
      expect(
        adapter.requests
            .firstWhere((r) => r.path.endsWith('/auth/refresh'))
            .headers
            .containsKey('Authorization'),
        isFalse,
      );
    });

    test('refresh sürerken çıkış yapılırsa token\'lar geri yazılmaz', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter(
        rotatingServer(refreshDelay: const Duration(milliseconds: 30)),
      );
      final client = clientWith(adapter, store);
      final pending = client.me.get();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await store.clear(); // kullanıcı çıkış yaptı
      await expectLater(pending, throwsA(isA<ApiException>()));
      expect(await store.read(), isNull);
    });
  });

  group('refresh hata sınıfları', () {
    for (final status in [429, 500, 503]) {
      test(
        'refresh $status geçicidir: token\'lar silinmez, olay yok',
        () async {
          final store = MemoryTokenStore(
            const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
          );
          final adapter = FakeAdapter((o) {
            if (o.path.endsWith('/auth/refresh')) {
              return jsonBody(status, {
                'code': 'INTERNAL_ERROR',
                'message': 'x',
              });
            }
            return jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'x'});
          });
          final client = clientWith(adapter, store);
          final ended = <SessionEndReason>[];
          client.sessionEnded.listen(ended.add);
          await expectLater(client.me.get(), throwsA(isA<ApiException>()));
          await Future<void>.delayed(Duration.zero);
          expect(await store.read(), isNotNull);
          expect(ended, isEmpty);
        },
      );
    }

    test('refresh 401 ACCOUNT_SUSPENDED -> suspended nedeni', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter((o) {
        if (o.path.endsWith('/auth/refresh')) {
          return jsonBody(401, {'code': 'ACCOUNT_SUSPENDED', 'message': 'x'});
        }
        return jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'x'});
      });
      final client = clientWith(adapter, store);
      final ended = <SessionEndReason>[];
      client.sessionEnded.listen(ended.add);
      await expectLater(client.me.get(), throwsA(isA<ApiException>()));
      await Future<void>.delayed(Duration.zero);
      expect(ended, [SessionEndReason.suspended]);
      expect(await store.read(), isNull);
    });

    test('oturumlu istek 401 ACCOUNT_SUSPENDED -> token\'lar silinir, '
        'suspended olayı; refresh denenmez', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'A', refreshToken: 'R1'),
      );
      final adapter = FakeAdapter(
        (o) => jsonBody(401, {'code': 'ACCOUNT_SUSPENDED', 'message': 'x'}),
      );
      final client = clientWith(adapter, store);
      final ended = <SessionEndReason>[];
      client.sessionEnded.listen(ended.add);
      await expectLater(
        client.me.get(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.accountSuspended,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(ended, [SessionEndReason.suspended]);
      expect(await store.read(), isNull);
      expect(adapter.count('/auth/refresh'), 0);
    });

    test('girişte 401 ACCOUNT_SUSPENDED oturum olayı üretmez', () async {
      final store = MemoryTokenStore();
      final adapter = FakeAdapter(
        (o) => jsonBody(401, {'code': 'ACCOUNT_SUSPENDED', 'message': 'x'}),
      );
      final client = clientWith(adapter, store);
      final ended = <SessionEndReason>[];
      client.sessionEnded.listen(ended.add);
      await expectLater(
        client.auth.login(
          const LoginRequest(identifier: 'a@b.c', password: 'x'),
        ),
        throwsA(isA<ApiException>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(ended, isEmpty);
    });

    test('hata metninde refresh token sızmaz', () async {
      final store = MemoryTokenStore(
        const TokenPair(accessToken: 'OLD', refreshToken: 'SECRET-R1'),
      );
      final adapter = FakeAdapter((o) {
        if (o.path.endsWith('/auth/refresh')) {
          throw DioException.connectionError(requestOptions: o, reason: 'x');
        }
        return jsonBody(401, {'code': 'TOKEN_EXPIRED', 'message': 'x'});
      });
      final client = clientWith(adapter, store);
      try {
        await client.me.get();
        fail('hata bekleniyordu');
      } on ApiException catch (e) {
        expect(e.toString(), isNot(contains('SECRET-R1')));
        expect(e.message, isNot(contains('SECRET-R1')));
      }
    });
  });

  group('yanıt çözümleme', () {
    test('sözleşmeye uymayan /me gövdesi ApiException(unknown) olur', () async {
      final adapter = FakeAdapter(
        (_) => jsonBody(200, {...meJson(), 'lastMode': 'ADMIN'}),
      );
      final client = clientWith(adapter, MemoryTokenStore());
      await expectLater(
        client.me.get(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.unknown,
          ),
        ),
      );
    });

    test('bozuk giriş yanıtı token yazmaz, ApiException olur', () async {
      final store = MemoryTokenStore();
      final adapter = FakeAdapter((_) => jsonBody(200, {'accessToken': 'A'}));
      final client = clientWith(adapter, store);
      await expectLater(
        client.auth.login(
          const LoginRequest(identifier: 'a@b.c', password: 'x'),
        ),
        throwsA(isA<ApiException>()),
      );
      expect(await store.read(), isNull);
    });
  });
}
