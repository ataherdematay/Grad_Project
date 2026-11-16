import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

/// `AppButton` içindeki düğmenin `onPressed` değeri.
VoidCallback? _onPressed(WidgetTester tester, String key) {
  final f = find.byKey(Key(key));
  final btn = find.descendant(
    of: f,
    matching: find.byWidgetPredicate(
      (w) => w is OutlinedButton || w is FilledButton || w is TextButton,
    ),
  );
  final w = tester.widget(btn);
  if (w is OutlinedButton) return w.onPressed;
  if (w is FilledButton) return w.onPressed;
  return (w as TextButton).onPressed;
}

void main() {
  group('Hesaplar', () {
    testWidgets('kendi hesabında ve yönetici hesaplarında askıya alma kapalı', (
      tester,
    ) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/accounts');
      // Oturumdaki yönetici (admin-1) ve diğer yönetici (admin-2).
      expect(_onPressed(tester, 'suspend-admin-1'), isNull);
      expect(_onPressed(tester, 'suspend-admin-2'), isNull);
      // Sıradan müşteri açık.
      expect(_onPressed(tester, 'suspend-u-1'), isNotNull);
      // Askıdaki hesapta yeniden aktifleştirme açık; silinen hesapta eylem yok.
      expect(_onPressed(tester, 'reactivate-u-2'), isNotNull);
      expect(find.byKey(const Key('suspend-u-3')), findsNothing);
      expect(find.byKey(const Key('reactivate-u-3')), findsNothing);
    });

    testWidgets('usta hesabında rol "Usta" yazar, müşteride "Müşteri"', (
      tester,
    ) async {
      await pumpAdmin(tester, initial: '/accounts');
      // Satır başına bir rol metni: usta (u-2) "Usta", sıradan hesap "Müşteri".
      // ("Usta"/"Müşteri" süzgeç çipinde de geçer: satır metni +1.)
      expect(find.text('Usta'), findsNWidgets(2));
      expect(find.text('Müşteri'), findsNWidgets(3));
      expect(find.text('Yönetici'), findsNWidgets(3));
    });

    testWidgets('kendi hesabın için neden açıklayan ipucu var', (tester) async {
      await pumpAdmin(tester, initial: '/accounts');
      expect(
        find.byTooltip('Kendi hesabını askıya alamazsın.'),
        findsOneWidget,
      );
      expect(
        find.byTooltip('Yönetici hesapları askıya alınamaz.'),
        findsOneWidget,
      );
    });

    testWidgets('kapalı düğmeye basmak istek göndermez', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/accounts');
      await tester.tap(
        find.byKey(const Key('suspend-admin-1')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(fake.requests.where((r) => r.method == 'POST'), isEmpty);
      expect(find.text('Zeynep Yönetici hesabını askıya al'), findsNothing);
    });

    testWidgets('arama, rol ve durum süzgeci sunucuya gider', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/accounts');
      expect(fake.last('GET', '/admin/users').queryParameters, isEmpty);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Usta'));
      await tester.pumpAndSettle();
      expect(fake.last('GET', '/admin/users').queryParameters, {'role': 'PRO'});

      // "Askıda" iki süzgeçte de var; durum satırındaki ikincisi.
      await tester.tap(find.widgetWithText(ChoiceChip, 'Askıda'));
      await tester.pumpAndSettle();
      expect(fake.last('GET', '/admin/users').queryParameters, {
        'role': 'PRO',
        'status': 'SUSPENDED',
      });

      await tester.enterText(find.byType(TextFormField), 'ali');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(fake.last('GET', '/admin/users').queryParameters, {
        'q': 'ali',
        'role': 'PRO',
        'status': 'SUSPENDED',
      });
    });

    testWidgets('askıya al: not zorunlu, istek, açık iş uyarısı', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson('POST', '/admin/users/u-1/suspend', {'activeJobCount': 2});
      await pumpAdmin(tester, fake: fake, initial: '/accounts');

      await tester.tap(find.byKey(const Key('suspend-u-1')));
      await tester.pumpAndSettle();
      expect(find.text('Ayşe Yılmaz hesabını askıya al'), findsOneWidget);

      final confirm = find.widgetWithText(FilledButton, 'Askıya al');
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Not en az 10 karakter olmalı.'), findsOneWidget);
      expect(fake.count('POST', '/admin/users/u-1/suspend'), 0);

      await tester.enterText(
        find.byType(TextFormField).last,
        'Sahte belge kullandı.',
      );
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(fake.last('POST', '/admin/users/u-1/suspend').data, {
        'note': 'Sahte belge kullandı.',
      });
      expect(find.textContaining('Süren 2 iş var'), findsOneWidget);
    });

    testWidgets('yeniden aktifleştir: onay sonrası istek', (tester) async {
      final fake = FakeApi()
        ..on('POST', '/admin/users/u-2/reactivate', (_) => empty(204));
      await pumpAdmin(tester, fake: fake, initial: '/accounts');

      await tester.tap(find.byKey(const Key('reactivate-u-2')));
      await tester.pumpAndSettle();
      expect(
        find.text('Ali Usta hesabını yeniden aktifleştir'),
        findsOneWidget,
      );
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/users/u-2/reactivate'), 0);

      await tester.tap(find.byKey(const Key('reactivate-u-2')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Yeniden aktifleştir'),
      );
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/users/u-2/reactivate'), 1);
      expect(find.text('Hesap yeniden aktifleştirildi.'), findsOneWidget);
    });

    testWidgets('yalnız usta profili askıdaysa profil buradan geri açılır', (
      tester,
    ) async {
      final fake = FakeApi()
        ..onJson('GET', '/admin/users', {
          'items': [
            {
              'id': 'u-4',
              'fullName': 'Emre Usta',
              'email': 'emre@example.com',
              'phone': null,
              'isAdmin': false,
              'status': 'ACTIVE',
              'createdAt': '2026-10-06T09:00:00Z',
              'pro': {
                'businessName': 'Eller Tesisat',
                'reviewStatus': 'SUSPENDED',
              },
            },
          ],
        })
        ..on('POST', '/admin/users/u-4/reactivate', (_) => empty(204));
      await pumpAdmin(tester, fake: fake, initial: '/accounts');

      // Hesap etkin: askıya alma da açık kalır.
      expect(_onPressed(tester, 'suspend-u-4'), isNotNull);
      await tester.tap(find.byKey(const Key('reactivate-pro-u-4')));
      await tester.pumpAndSettle();
      expect(
        find.text('Eller Tesisat usta profilini yeniden aç'),
        findsOneWidget,
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Yeniden aktifleştir'),
      );
      await tester.pumpAndSettle();
      expect(fake.count('POST', '/admin/users/u-4/reactivate'), 1);
      expect(find.text('Usta profili yeniden açıldı.'), findsOneWidget);
    });

    testWidgets(
      'sunucu yönetici askısını reddederse (ILLEGAL_STATE) yenilenir',
      (tester) async {
        final fake = FakeApi()
          ..on(
            'POST',
            '/admin/users/u-1/suspend',
            (_) => apiError(409, 'ILLEGAL_STATE'),
          );
        await pumpAdmin(tester, fake: fake, initial: '/accounts');
        await tester.tap(find.byKey(const Key('suspend-u-1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).last,
          'Sahte belge kullandı.',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Askıya al'));
        await tester.pumpAndSettle();
        expect(fake.count('GET', '/admin/users'), 2);
        expect(find.textContaining('Kayıt bu arada değişti'), findsOneWidget);
      },
    );

    testWidgets('boş durum', (tester) async {
      final fake = FakeApi()..onJson('GET', '/admin/users', {'items': []});
      await pumpAdmin(tester, fake: fake, initial: '/accounts');
      expect(find.text('Hesap bulunamadı'), findsOneWidget);
    });

    testWidgets('hata durumunda tekrar dene', (tester) async {
      var fail = true;
      final fake = FakeApi()
        ..on(
          'GET',
          '/admin/users',
          (_) => fail
              ? apiError(403, 'FORBIDDEN')
              : json(200, {'items': usersJson()}),
        );
      await pumpAdmin(tester, fake: fake, initial: '/accounts');
      expect(find.text('Bu işlem için yetkin yok.'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    });
  });

  group('Ödemeler', () {
    testWidgets('toplam kartları ve tablo', (tester) async {
      await pumpAdmin(tester, initial: '/payments');
      expect(
        tester.widget<Text>(find.byKey(const Key('total-locked'))).data,
        '₺2.200',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('total-released'))).data,
        '₺8.800',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('total-commission'))).data,
        '₺880',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('total-refunded'))).data,
        '₺1.225,50',
      );
      expect(find.byKey(const Key('payment-PAY-1001')), findsOneWidget);
      expect(find.byKey(const Key('payment-PAY-1002')), findsOneWidget);
      expect(find.text('REQUEST_ALREADY_ASSIGNED'), findsOneWidget);
      expect(find.text('Müşteriye iade edildi'), findsWidgets);
    });

    testWidgets('1024 px: tüm sütunlar görünür, yatay kaydırma gizli kalmaz', (
      tester,
    ) async {
      await pumpAdmin(
        tester,
        initial: '/payments',
        size: const Size(1024, 768),
      );
      for (final h in ['Ustaya ödeme', 'İade', 'Tarih']) {
        expect(find.text(h), findsWidgets);
      }
      expect(find.text('₺1.980'), findsOneWidget);
      // Tablo yatay kaydırılmaz: satırlar kart olarak alt alta dizilir.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
      );
      expect(
        tester.getRect(find.text('₺1.980')).right,
        lessThanOrEqualTo(1024),
      );
    });

    testWidgets('durum süzgeci sunucuya gider', (tester) async {
      final fake = FakeApi();
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      expect(fake.last('GET', '/admin/payments').queryParameters, isEmpty);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Ustaya aktarıldı'));
      await tester.pumpAndSettle();
      expect(fake.last('GET', '/admin/payments').queryParameters, {
        'status': 'RELEASED_TO_PRO',
      });
    });

    testWidgets('boş durum toplamları yine gösterir', (tester) async {
      final fake = FakeApi()
        ..onJson('GET', '/admin/payments', {
          'items': [],
          'totals': {
            'lockedTotal': 0,
            'releasedTotal': 0,
            'commissionTotal': 0,
            'refundedTotal': 0,
          },
        });
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      expect(find.text('Bu durumda ödeme yok'), findsOneWidget);
      expect(find.byKey(const Key('total-locked')), findsOneWidget);
    });

    testWidgets('hata durumunda tekrar dene', (tester) async {
      var fail = true;
      final fake = FakeApi()
        ..on(
          'GET',
          '/admin/payments',
          (_) => fail
              ? apiError(500, 'INTERNAL_ERROR')
              : json(200, paymentsJson()),
        );
      await pumpAdmin(tester, fake: fake, initial: '/payments');
      expect(find.text('Liste yüklenemedi'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Tekrar dene'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('payment-PAY-1001')), findsOneWidget);
    });
  });
}
