import 'dart:convert';
import 'dart:io';

import 'package:bitadilat_admin/app/router.dart';
import 'package:bitadilat_admin/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

const _routes = [
  '/',
  '/applications',
  '/applications/p9',
  '/complaints',
  '/complaints/c1',
  '/accounts',
  '/payments',
];

void main() {
  Future<void> visit(WidgetTester tester, Harness h, String route) async {
    h.router.go(route);
    await tester.pumpAndSettle();
    expect(h.location, route);
    expect(tester.takeException(), isNull, reason: route);
  }

  group('Düzen', () {
    for (final width in [1280.0, 1024.0]) {
      testWidgets('${width.toInt()} px: sol gezinme sabit, taşma yok', (
        tester,
      ) async {
        final h = await pumpAdmin(tester, size: Size(width, 800));
        for (final route in _routes) {
          await visit(tester, h, route);
          // Dört bölümün hepsi gezinmede.
          for (final id in [
            'applications',
            'complaints',
            'accounts',
            'payments',
          ]) {
            expect(find.byKey(Key('nav-$id')), findsOneWidget, reason: route);
          }
          expect(find.byTooltip('Menüyü aç'), findsNothing);
          // Üst çubuk: admin adı ve çıkış.
          expect(find.byKey(const Key('admin-name')), findsOneWidget);
          expect(find.byKey(const Key('logout')), findsOneWidget);
        }
      });

      testWidgets('${width.toInt()} px: karar diyaloğu taşmaz', (tester) async {
        await pumpAdmin(
          tester,
          size: Size(width, 800),
          initial: '/complaints/c1/decision',
        );
        expect(find.byKey(const Key('decision-dialog')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('${width.toInt()} px: EN dilinde de taşma yok', (
        tester,
      ) async {
        final h = await pumpAdmin(tester, size: Size(width, 800), locale: 'en');
        for (final route in _routes) {
          await visit(tester, h, route);
        }
      });
    }

    testWidgets('1024 px altında gezinme çekmeceye taşınır, taşma yok', (
      tester,
    ) async {
      final h = await pumpAdmin(tester, size: const Size(900, 800));
      for (final route in _routes) {
        await visit(tester, h, route);
        expect(find.byKey(const Key('nav-applications')), findsNothing);
        expect(find.byTooltip('Menüyü aç'), findsOneWidget);
      }
    });

    testWidgets('dar ekranda menü açılır ve sayfa değişir', (tester) async {
      final h = await pumpAdmin(tester, size: const Size(700, 800));
      await tester.tap(find.byTooltip('Menüyü aç'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nav-complaints')), findsOneWidget);
      await tester.tap(find.byKey(const Key('nav-complaints')));
      await tester.pumpAndSettle();
      expect(h.location, Routes.complaints);
      expect(find.byKey(const Key('nav-complaints')), findsNothing);
    });

    testWidgets('detay sayfasında menüden seçince çekmece kapanır', (
      tester,
    ) async {
      final h = await pumpAdmin(
        tester,
        size: const Size(700, 800),
        initial: '/applications/p9',
      );
      await tester.tap(find.byTooltip('Menüyü aç'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-payments')));
      await tester.pumpAndSettle();
      expect(h.location, Routes.payments);
      expect(find.byKey(const Key('nav-payments')), findsNothing);
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('1023 px sınırı: çekmece, 1024 px sabit gezinme', (
      tester,
    ) async {
      await pumpAdmin(tester, size: const Size(1023, 800));
      expect(find.byKey(const Key('nav-applications')), findsNothing);
      tester.view.physicalSize = const Size(1024, 800);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nav-applications')), findsOneWidget);
    });

    testWidgets('gezinme sayfalar arasında geçiş yapar, seçili öğe değişir', (
      tester,
    ) async {
      final h = await pumpAdmin(tester);
      for (final (id, route) in [
        ('applications', Routes.applications),
        ('complaints', Routes.complaints),
        ('accounts', Routes.accounts),
        ('payments', Routes.payments),
        ('home', Routes.home),
      ]) {
        await tester.tap(find.byKey(Key('nav-$id')));
        await tester.pumpAndSettle();
        expect(h.location, route);
      }
    });

    testWidgets('en dar ekranda (360 px) tablolar taşmaz', (tester) async {
      final h = await pumpAdmin(tester, size: const Size(360, 800));
      for (final route in [
        '/applications',
        '/complaints',
        '/accounts',
        '/payments',
        '/applications/p9',
        '/complaints/c1',
      ]) {
        await visit(tester, h, route);
      }
    });
  });

  group('Başlangıç ekranı', () {
    testWidgets('istatistik kartları', (tester) async {
      final h = await pumpAdmin(tester);
      expect(find.text('Genel bakış'), findsWidgets);
      expect(
        find.text('Merhaba Zeynep Yönetici, bekleyen işler aşağıda.'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-applications')),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-complaints')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-jobs')),
          matching: find.text('17'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-escrow')),
          matching: find.text('₺12.450,50'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('stat-applications')));
      await tester.pumpAndSettle();
      expect(h.location, Routes.applications);
    });

    testWidgets('istatistik hatasında tekrar dene', (tester) async {
      var fail = true;
      final fake = FakeApi()
        ..on(
          'GET',
          '/admin/stats',
          (_) =>
              fail ? apiError(500, 'INTERNAL_ERROR') : json(200, statsJson()),
        );
      await pumpAdmin(tester, fake: fake);
      expect(find.text('Liste yüklenemedi'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stat-applications')), findsOneWidget);
    });
  });

  group('TR / EN', () {
    testWidgets('dil anahtarı arayüzü değiştirir ve tercihi saklar', (
      tester,
    ) async {
      final h = await pumpAdmin(tester);
      expect(find.text('Başvurular'), findsWidgets);
      expect(find.text('Logout'), findsNothing);

      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Applications'), findsWidgets);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Başvurular'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('stat-escrow')),
          matching: find.text('₺12,450.50'),
        ),
        findsOneWidget,
      );
      final prefs = h.container.read(sharedPreferencesProvider);
      expect(prefs.getString('locale'), 'en');

      await tester.tap(find.text('TR'));
      await tester.pumpAndSettle();
      expect(find.text('Başvurular'), findsWidgets);
      expect(prefs.getString('locale'), 'tr');
    });

    testWidgets('kayıtlı dil tercihi açılışta uygulanır', (tester) async {
      await pumpAdmin(tester, signedIn: false, locale: 'en');
      expect(find.text('Admin sign-in'), findsOneWidget);
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('giriş ekranında dil değişir', (tester) async {
      await pumpAdmin(tester, signedIn: false);
      expect(find.text('Yönetici girişi'), findsOneWidget);
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Admin sign-in'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('başvuru ekranı EN: durum etiketleri ve diyalog metinleri', (
      tester,
    ) async {
      await pumpAdmin(tester, initial: '/applications/p9', locale: 'en');
      expect(find.text('Under review'), findsWidgets);
      await tester.tap(find.byKey(const Key('reject')));
      await tester.pumpAndSettle();
      expect(find.text('Reject application'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
      await tester.pumpAndSettle();
      expect(
        find.text('The note must be at least 10 characters.'),
        findsOneWidget,
      );
    });

    test(
      'app_tr.arb ve app_en.arb aynı anahtarlara ve yer tutuculara sahip',
      () {
        Map<String, dynamic> load(String name) =>
            jsonDecode(File('lib/l10n/$name').readAsStringSync())
                as Map<String, dynamic>;
        final tr = load('app_tr.arb');
        final en = load('app_en.arb');
        Set<String> keys(Map<String, dynamic> m) =>
            m.keys.where((k) => !k.startsWith('@')).toSet();
        expect(keys(en), keys(tr));
        for (final k in keys(tr)) {
          final placeholders = RegExp(r'\{(\w+)\}');
          Set<String> ph(String s) =>
              placeholders.allMatches(s).map((m) => m.group(1)!).toSet();
          expect(ph(en[k] as String), ph(tr[k] as String), reason: k);
          expect((tr[k] as String).trim(), isNotEmpty, reason: k);
          expect((en[k] as String).trim(), isNotEmpty, reason: k);
        }
      },
    );

    test('Türkçe metin lib/ içinde gömülü değil (l10n dışında)', () {
      final turkish = RegExp(r'''(["'])[^"'\n]*[çğıöşüÇĞİÖŞÜ][^"'\n]*\1''');
      final offenders = <String>[];
      for (final f
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where(
                (f) => f.path.endsWith('.dart') && !f.path.contains('/l10n/'),
              )) {
        var n = 0;
        for (final line in f.readAsLinesSync()) {
          n++;
          final code = line.split('//').first;
          if (turkish.hasMatch(code)) offenders.add('${f.path}:$n $line');
        }
      }
      expect(offenders, isEmpty);
    });

    test('hitap "sen": TR metinlerde "siz" kalıbı yok', () {
      final tr = jsonDecode(
        File('lib/l10n/app_tr.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final bad = RegExp(
        r'\b(siz|sizin|giriniz|seçiniz|bekleyiniz)\b',
        caseSensitive: false,
      );
      for (final e in tr.entries) {
        if (e.value is String) {
          expect(bad.hasMatch(e.value as String), isFalse, reason: e.key);
        }
      }
    });
  });
}
