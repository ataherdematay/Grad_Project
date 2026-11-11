import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/app/app.dart';
import 'package:bitadilat_mobile/app/router.dart';
import 'package:bitadilat_mobile/core/providers.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Handler = FutureOr<ResponseBody> Function(RequestOptions options);

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  Handler handler;
  final List<RequestOptions> requests = [];

  int count(String method, String path) =>
      requests.where((r) => r.method == method && r.path.endsWith(path)).length;

  RequestOptions last(String path) =>
      requests.lastWhere((r) => r.path.endsWith(path));

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

ResponseBody json(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

ResponseBody empty(int status) => ResponseBody.fromString('', status);

ResponseBody apiError(int status, String code, {String? field}) =>
    json(status, {'code': code, 'message': 'dev', 'field': ?field});

Map<String, dynamic> meJson({
  bool isAdmin = false,
  String lastMode = 'CUSTOMER',
  Map<String, dynamic>? pro,
}) => {
  'id': 'u-1',
  'fullName': 'Ayşe Yılmaz',
  'email': 'ayse@example.com',
  'phone': '+905321112233',
  'locale': 'tr',
  'lastMode': lastMode,
  'isAdmin': isAdmin,
  'status': 'ACTIVE',
  'pro': pro,
};

Map<String, dynamic> authJson({
  bool isAdmin = false,
  String lastMode = 'CUSTOMER',
  Map<String, dynamic>? pro,
}) => {
  'accessToken': 'ACCESS',
  'refreshToken': 'REFRESH',
  'accessExpiresIn': 900,
  'user': meJson(isAdmin: isAdmin, lastMode: lastMode, pro: pro),
};

Map<String, dynamic> proJson(String status) => {
  'reviewStatus': status,
  'availability': 'ACTIVE',
  'businessName': 'Usta Tesisat',
};

Me testMe({
  String? proStatus,
  UserMode lastMode = UserMode.customer,
  bool isAdmin = false,
}) => Me.fromJson(
  meJson(
    isAdmin: isAdmin,
    lastMode: lastMode == UserMode.pro ? 'PRO' : 'CUSTOMER',
    pro: proStatus == null ? null : proJson(proStatus),
  ),
);

/// Sahte oturum sağlayıcısı: ağa gitmeden verilen durumla başlar.
class FakeSession extends SessionController {
  FakeSession(this.initial);

  final SessionState initial;

  @override
  SessionState build() {
    // Gerçek sınıftaki dinleyiciyi kurmak için üst sınıf çağrılmaz.
    return initial;
  }
}

class Harness {
  Harness(this.container, this.adapter, this.store);

  final ProviderContainer container;
  final FakeAdapter adapter;
  final MemoryTokenStore store;

  GoRouter get router => container.read(routerProvider);

  /// `push` ile açılan ekranlar dahil, en üstteki ekranın adresi.
  Uri get uri {
    final list = router.routerDelegate.currentConfiguration;
    final last = list.matches.last;
    return last is ImperativeRouteMatch ? last.matches.uri : list.uri;
  }

  String get location => uri.toString();
}

/// Uygulamayı verilen oturum/ağ ayarlarıyla çizer.
Future<Harness> pumpApp(
  WidgetTester tester, {
  SessionState? session,
  String initial = '/',
  Handler? handler,
  TokenPair? tokens,
  Size size = const Size(390, 844),
  double textScale = 1,
  String locale = 'tr',
  List<Override> overrides = const [],

  /// `false` iken yalnız bir kare çizilir (zamanlayıcı ve yoklama testleri).
  bool settle = true,
}) async {
  SharedPreferences.setMockInitialValues({'locale': locale});
  final prefs = await SharedPreferences.getInstance();
  final adapter = FakeAdapter(handler ?? (_) => apiError(404, 'NOT_FOUND'));
  final store = MemoryTokenStore(tokens);
  final client = ApiClient(
    config: const ApiConfig('http://localhost:8090'),
    tokenStore: store,
    adapter: adapter,
  );
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      tokenStoreProvider.overrideWithValue(store),
      apiClientProvider.overrideWithValue(client),
      initialLocationProvider.overrideWithValue(initial),
      if (session != null)
        sessionProvider.overrideWith(() => FakeSession(session)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const BitadilatApp(),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }
  return Harness(container, adapter, store);
}
