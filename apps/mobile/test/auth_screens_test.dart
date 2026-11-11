import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_mobile/core/error_messages.dart';
import 'package:bitadilat_mobile/core/forms.dart';
import 'package:bitadilat_mobile/features/auth/session.dart';
import 'package:bitadilat_mobile/features/common/widgets.dart';
import 'package:bitadilat_mobile/l10n/app_localizations.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/harness.dart';

Finder field(String label) => find.byWidgetPredicate(
  (w) => w is AppTextField && w.label == label,
  description: 'AppTextField($label)',
);

Finder input(String label) =>
    find.descendant(of: field(label), matching: find.byType(TextFormField));

Finder button(String label) => find.widgetWithText(AppButton, label);

void main() {
  group('Giriş', () {
    testWidgets('boş gönderimde doğrulama hataları, istek gitmez', (t) async {
      final h = await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/login',
      );
      await t.tap(button('Giriş yap'));
      await t.pumpAndSettle();
      expect(find.text('Bu alanı doldur.'), findsNWidgets(2));
      expect(h.adapter.requests, isEmpty);

      await t.enterText(input('E-posta veya telefon'), 'abc');
      await t.tap(button('Giriş yap'));
      await t.pumpAndSettle();
      expect(
        find.text(
          'E-posta adresini ya da 5XX XXX XX XX biçiminde telefon numaranı gir.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('telefon +90 biçiminde normalleşir', (t) async {
      final h = await pumpApp(
        t,
        initial: '/login',
        handler: (o) => o.path.endsWith('/auth/login')
            ? json(200, authJson())
            : apiError(404, 'NOT_FOUND'),
      );
      await t.enterText(input('E-posta veya telefon'), '0532 111 22 33');
      await t.enterText(input('Şifre'), 'abcd1234');
      await t.tap(button('Giriş yap'));
      await t.pumpAndSettle();
      expect(h.adapter.last('/auth/login').data, {
        'identifier': '+905321112233',
        'password': 'abcd1234',
      });
    });

    testWidgets(
      'BAD_CREDENTIALS yerelleştirilmiş mesaj gösterir, veri korunur',
      (t) async {
        await pumpApp(
          t,
          initial: '/login',
          handler: (_) => apiError(401, 'BAD_CREDENTIALS'),
        );
        await t.enterText(input('E-posta veya telefon'), 'a@b.co');
        await t.enterText(input('Şifre'), 'yanlis123');
        await t.tap(button('Giriş yap'));
        await t.pumpAndSettle();
        expect(
          find.text(
            'E-posta, telefon veya şifre hatalı. Bilgilerini kontrol edip tekrar dene.',
          ),
          findsOneWidget,
        );
        expect(find.text('a@b.co'), findsOneWidget);
      },
    );

    testWidgets('ağ hatasında form verisi kaybolmaz', (t) async {
      await pumpApp(
        t,
        initial: '/login',
        handler: (o) =>
            throw DioException.connectionError(requestOptions: o, reason: 'x'),
      );
      await t.enterText(input('E-posta veya telefon'), 'a@b.co');
      await t.enterText(input('Şifre'), 'abcd1234');
      await t.tap(button('Giriş yap'));
      await t.pumpAndSettle();
      expect(
        find.textContaining('İnternet bağlantına ulaşılamıyor'),
        findsOneWidget,
      );
      expect(find.text('a@b.co'), findsOneWidget);
      final password = t.widget<TextFormField>(input('Şifre'));
      expect(password.controller!.text, 'abcd1234');
    });

    testWidgets(
      'istek sürerken düğme kilitli; ikinci dokunuş ikinci istek üretmez',
      (t) async {
        final completer = Completer<ResponseBody>();
        final h = await pumpApp(
          t,
          initial: '/login',
          handler: (o) => completer.future,
        );
        await t.enterText(input('E-posta veya telefon'), 'a@b.co');
        await t.enterText(input('Şifre'), 'abcd1234');
        await t.tap(button('Giriş yap'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 50));
        await t.tap(find.byType(FilledButton), warnIfMissed: false);
        await t.pump(const Duration(milliseconds: 50));
        expect(h.adapter.count('POST', '/auth/login'), 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        completer.complete(apiError(401, 'BAD_CREDENTIALS'));
        await t.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('şifre göster/gizle', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/login',
      );
      expect(
        t
            .widget<TextField>(
              find.descendant(
                of: field('Şifre'),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isTrue,
      );
      await t.tap(find.byTooltip('Şifreyi göster'));
      await t.pump();
      expect(
        t
            .widget<TextField>(
              find.descendant(
                of: field('Şifre'),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isFalse,
      );
    });
  });

  group('Kayıt', () {
    Future<void> fillValid(WidgetTester t) async {
      await t.enterText(input('Ad soyad'), 'Ayşe Yılmaz');
      await t.enterText(input('E-posta'), 'ayse@example.com');
      await t.enterText(input('Telefon'), '5321112233');
      await t.enterText(input('Şifre'), 'abcd1234');
    }

    Future<void> consentAndSubmit(WidgetTester t) async {
      for (final key in ['consent-kvkk', 'consent-terms']) {
        final cb = find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(Checkbox),
        );
        await t.ensureVisible(cb);
        await t.tap(cb);
        await t.pump();
      }
      await t.ensureVisible(button('Hesap oluştur'));
      await t.tap(button('Hesap oluştur'));
      await t.pumpAndSettle();
    }

    testWidgets('varsayılan rol yok; boş gönderimde tüm doğrulamalar çıkar', (
      t,
    ) async {
      final h = await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/register',
      );
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);
      await t.ensureVisible(button('Hesap oluştur'));
      await t.tap(button('Hesap oluştur'));
      await t.pumpAndSettle();
      expect(
        find.text('Devam etmek için bir seçenek belirle.'),
        findsOneWidget,
      );
      expect(find.text('Bu alanı doldur.'), findsWidgets);
      await t.ensureVisible(find.byKey(const Key('consent-terms')));
      expect(
        find.text('Devam etmek için bu onayı vermelisin.'),
        findsNWidgets(2),
      );
      expect(h.adapter.requests, isEmpty);
    });

    testWidgets('zayıf şifre ve eksik telefon hataları', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/register',
      );
      await t.enterText(input('Ad soyad'), 'Ayşe');
      await t.enterText(input('E-posta'), 'ayse@');
      await t.enterText(input('Telefon'), '532');
      await t.enterText(input('Şifre'), 'abcdefgh');
      await t.ensureVisible(button('Hesap oluştur'));
      await t.tap(button('Hesap oluştur'));
      await t.pumpAndSettle();
      expect(find.text('Adını ve soyadını gir.'), findsOneWidget);
      expect(
        find.text('E-posta adresi hatalı. Örnek: ad@ornek.com'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Telefon numarası eksik. 5XX XXX XX XX biçiminde 10 hane gir.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Şifrende en az bir harf ve bir rakam olmalı.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'EMAIL_TAKEN + field=email hatası e-posta alanının altında görünür',
      (t) async {
        final h = await pumpApp(
          t,
          initial: '/register',
          handler: (o) => o.path.endsWith('/auth/register')
              ? apiError(409, 'EMAIL_TAKEN', field: 'email')
              : apiError(404, 'NOT_FOUND'),
        );
        await t.tap(find.text('Müşteri'));
        await t.pump();
        await fillValid(t);
        await consentAndSubmit(t);

        const msg =
            'Bu e-posta adresi zaten kayıtlı. Giriş yap ya da başka bir e-posta kullan.';
        expect(find.text(msg), findsOneWidget);
        final owner = find.ancestor(
          of: find.text(msg),
          matching: find.byType(AppTextField),
        );
        expect(owner, findsOneWidget);
        expect(t.widget<AppTextField>(owner).label, 'E-posta');
        // Form verisi korunur, kullanıcı oturumsuz kalır.
        expect(find.text('ayse@example.com'), findsOneWidget);
        expect(h.uri.path, '/register');

        // E-postayı düzeltince alan hatası kalkar.
        await t.enterText(input('E-posta'), 'baska@example.com');
        await t.pump();
        expect(find.text(msg), findsNothing);
      },
    );

    testWidgets('müşteri kaydı -> /c/home; gövde sözleşmeye uyar', (t) async {
      final h = await pumpApp(
        t,
        initial: '/register',
        handler: (o) => o.path.endsWith('/auth/register')
            ? json(201, authJson())
            : apiError(404, 'NOT_FOUND'),
      );
      await t.tap(find.text('Müşteri'));
      await t.pump();
      await fillValid(t);
      await consentAndSubmit(t);
      expect(h.location, '/c/home');
      expect(h.adapter.last('/auth/register').data, {
        'fullName': 'Ayşe Yılmaz',
        'email': 'ayse@example.com',
        'phone': '+905321112233',
        'password': 'abcd1234',
        'wantsPro': false,
        'kvkkAccepted': true,
        'termsAccepted': true,
      });
    });

    testWidgets('usta kaydı -> /p/apply', (t) async {
      final h = await pumpApp(
        t,
        initial: '/register',
        handler: (o) => o.path.endsWith('/auth/register')
            ? json(201, authJson())
            : apiError(404, 'NOT_FOUND'),
      );
      await t.tap(find.text('Usta'));
      await t.pump();
      await fillValid(t);
      await consentAndSubmit(t);
      expect(h.location, '/p/apply');
      expect(h.adapter.last('/auth/register').data['wantsPro'], true);
    });

    testWidgets('KVKK metni yer tutucu sayfayı açar', (t) async {
      final h = await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/register',
      );
      final read = button('KVKK metnini oku');
      await t.ensureVisible(read);
      await t.tap(read);
      await t.pumpAndSettle();
      expect(h.location, '/legal/kvkk');
      expect(find.text('KVKK aydınlatma metni'), findsOneWidget);
      await t.tap(find.byTooltip('Geri'));
      await t.pumpAndSettle();
      expect(h.location, '/register');
    });
  });

  group('Şifre sıfırlama', () {
    testWidgets(
      'istek -> kod ve yeni şifre -> giriş ekranı, geri tuşu forma dönmez',
      (t) async {
        final h = await pumpApp(
          t,
          session: const SessionState.signedOut(),
          initial: '/forgot-password',
          handler: (o) {
            if (o.path.endsWith('/password/forgot')) return empty(202);
            if (o.path.endsWith('/password/reset')) return empty(204);
            return apiError(404, 'NOT_FOUND');
          },
        );
        await t.tap(button('Kod gönder'));
        await t.pumpAndSettle();
        expect(find.text('Bu alanı doldur.'), findsOneWidget);

        await t.enterText(input('E-posta'), 'ayse@example.com');
        await t.tap(button('Kod gönder'));
        await t.pumpAndSettle();
        expect(h.location, '/reset-password');
        expect(h.adapter.last('/password/forgot').data, {
          'email': 'ayse@example.com',
        });
        // E-posta URL'de değil.
        expect(h.location.contains('ayse'), isFalse);
        expect(
          t.widget<TextFormField>(input('E-posta')).controller!.text,
          'ayse@example.com',
        );

        await t.enterText(input('6 haneli kod'), '12345');
        await t.enterText(input('Yeni şifre'), 'abcd1234');
        await t.tap(button('Şifreyi değiştir'));
        await t.pumpAndSettle();
        expect(
          find.text('Kod 6 haneli olmalı. E-postanı kontrol et.'),
          findsOneWidget,
        );

        await t.enterText(input('6 haneli kod'), '123456');
        await t.tap(button('Şifreyi değiştir'));
        await t.pumpAndSettle();
        expect(h.adapter.last('/password/reset').data, {
          'email': 'ayse@example.com',
          'code': '123456',
          'newPassword': 'abcd1234',
        });
        expect(h.location, '/login');
        expect(h.router.canPop(), isFalse);
      },
    );

    testWidgets('yanlış kod alan altında görünür', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/reset-password',
        handler: (o) => apiError(400, 'VALIDATION_FAILED', field: 'code'),
      );
      await t.enterText(input('E-posta'), 'ayse@example.com');
      await t.enterText(input('6 haneli kod'), '123456');
      await t.enterText(input('Yeni şifre'), 'abcd1234');
      await t.tap(button('Şifreyi değiştir'));
      await t.pumpAndSettle();
      final owner = find.ancestor(
        of: find.text('Bu alan hatalı. Kontrol edip tekrar dene.'),
        matching: find.byType(AppTextField),
      );
      expect(t.widget<AppTextField>(owner).label, '6 haneli kod');
    });
  });

  group('Dil ve ayarlar', () {
    testWidgets('TR -> EN değişince metin değişir ve kalıcı olur', (t) async {
      final h = await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/welcome',
      );
      expect(find.text('Giriş yap'), findsOneWidget);
      expect(find.text('BiTadilat'), findsOneWidget);
      await t.tap(find.text('English'));
      await t.pumpAndSettle();
      expect(find.text('Giriş yap'), findsNothing);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), 'en');
      await t.tap(find.text('Türkçe'));
      await t.pumpAndSettle();
      expect(find.text('Giriş yap'), findsOneWidget);
      expect(h.location, '/welcome');
    });

    testWidgets('giriş ekranı EN doğrulama ve hata metinleri', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/login',
        locale: 'en',
        handler: (_) => apiError(401, 'BAD_CREDENTIALS'),
      );
      await t.tap(button('Log in'));
      await t.pumpAndSettle();
      expect(find.text('Fill in this field.'), findsNWidgets(2));
    });

    testWidgets(
      'ayarlar: çıkış onay diyaloğu, logout çağrısı, yığın sıfırlanır',
      (t) async {
        final h = await pumpApp(
          t,
          tokens: const TokenPair(accessToken: 'A', refreshToken: 'R1'),
          initial: '/c/profile',
          handler: (o) {
            if (o.path.endsWith('/me')) return json(200, meJson());
            if (o.path.endsWith('/auth/logout')) return empty(204);
            return apiError(404, 'NOT_FOUND');
          },
        );
        await t.tap(find.text('Ayarlar'));
        await t.pumpAndSettle();
        expect(h.location, '/settings');

        await t.tap(button('Çıkış yap'));
        await t.pumpAndSettle();
        expect(find.text('Çıkış yapılsın mı?'), findsOneWidget);

        // Vazgeç: hiçbir şey olmaz.
        await t.tap(find.text('Vazgeç'));
        await t.pumpAndSettle();
        expect(h.location, '/settings');
        expect(h.adapter.count('POST', '/auth/logout'), 0);

        await t.tap(button('Çıkış yap'));
        await t.pumpAndSettle();
        await t.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Çıkış yap'),
          ),
        );
        await t.pumpAndSettle();
        expect(h.adapter.last('/auth/logout').data, {'refreshToken': 'R1'});
        expect(h.location, '/welcome');
        expect(h.router.canPop(), isFalse);
        expect(await h.store.read(), isNull);
      },
    );
  });

  group('İlk açılış', () {
    testWidgets('açılış karosu ekranın tam ortasında (iOS açılışıyla aynı)', (
      t,
    ) async {
      await pumpApp(t, session: const SessionState.unknown(), settle: false);
      await t.pump(const Duration(seconds: 1));
      final mark = find.byType(BrandMark);
      expect(mark, findsOneWidget);
      expect(t.getSize(mark), const Size(96, 96));
      expect(t.getCenter(mark), const Offset(390 / 2, 844 / 2));
      expect(find.bySemanticsLabel('Yükleniyor'), findsOneWidget);
    });

    testWidgets('karşılama: marka, tek giriş/kayıt çifti, dil anahtarı', (
      t,
    ) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/welcome',
      );
      expect(find.byType(BrandMark), findsOneWidget);
      expect(find.text('BiTadilat'), findsOneWidget);
      expect(find.byType(LanguageSwitch), findsOneWidget);
      expect(button('Giriş yap'), findsOneWidget);
      expect(button('Hesap oluştur'), findsOneWidget);
      // Butonlar ekranın altına yaslanır, alt kenarda 16 px boşluk kalır.
      final bottom = t.getBottomLeft(button('Hesap oluştur')).dy;
      expect(bottom, greaterThan(844 - 120));
      expect(bottom, lessThanOrEqualTo(844 - 16));
    });

    testWidgets('karşılama 320 px ve 3x yazıda taşmaz', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/welcome',
        size: const Size(320, 568),
        textScale: 3,
      );
      expect(t.takeException(), isNull);
      await t.ensureVisible(button('Hesap oluştur'));
      expect(button('Hesap oluştur'), findsOneWidget);
    });
  });

  group('Taşma (320 px, 2x yazı)', () {
    for (final route in [
      '/welcome',
      '/login',
      '/register',
      '/forgot-password',
      '/reset-password',
      '/legal/kvkk',
      '/yok',
    ]) {
      for (final locale in ['tr', 'en']) {
        testWidgets('$route $locale', (t) async {
          await pumpApp(
            t,
            session: const SessionState.signedOut(),
            initial: route,
            size: const Size(320, 640),
            textScale: 2,
            locale: locale,
          );
          expect(t.takeException(), isNull);
        });
      }
    }

    testWidgets('kayıt hata durumlarıyla 320 px/2x', (t) async {
      await pumpApp(
        t,
        session: const SessionState.signedOut(),
        initial: '/register',
        size: const Size(320, 640),
        textScale: 2,
      );
      await t.ensureVisible(button('Hesap oluştur'));
      await t.tap(button('Hesap oluştur'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });

    for (final route in ['/c/home', '/c/profile', '/settings', '/p/apply']) {
      testWidgets('$route 320 px/2x', (t) async {
        await pumpApp(
          t,
          session: SessionState.signedIn(testMe()),
          initial: route,
          size: const Size(320, 640),
          textScale: 2,
        );
        expect(t.takeException(), isNull, reason: route);
      });
    }
  });

  group('Hata mesajları', () {
    test('her ApiErrorCode için TR ve EN mesaj var', () {
      final tr = lookupAppLocalizations(const Locale('tr'));
      final en = lookupAppLocalizations(const Locale('en'));
      for (final code in ApiErrorCode.values) {
        expect(
          apiErrorMessage(tr, code).trim(),
          isNotEmpty,
          reason: '$code tr',
        );
        expect(
          apiErrorMessage(en, code).trim(),
          isNotEmpty,
          reason: '$code en',
        );
        expect(
          apiErrorMessage(tr, code),
          isNot(apiErrorMessage(en, code)),
          reason: '$code TR ve EN farklı olmalı',
        );
      }
    });
  });

  group('Telefon ve doğrulayıcılar', () {
    test('TR maskesi ve normalleştirme', () {
      expect(formatTrPhone('5321112233'), '532 111 22 33');
      expect(formatTrPhone('+90 532 111 22 33'), '532 111 22 33');
      expect(formatTrPhone('0532 111 22 33'), '532 111 22 33');
      expect(formatTrPhone('53211122334455'), '532 111 22 33');
      expect(normalizePhone('0532 111 22 33'), '+905321112233');
      expect(isValidTrMobile('532 111 22 33'), isTrue);
      expect(isValidTrMobile('432 111 22 33'), isFalse);
      expect(isValidTrMobile('532 111'), isFalse);
    });

    test('kimlik ve şifre', () {
      expect(isValidIdentifier('a@b.co'), isTrue);
      expect(isValidIdentifier('05321112233'), isTrue);
      expect(isValidIdentifier('abc'), isFalse);
      expect(normalizeIdentifier(' a@b.co '), 'a@b.co');
      expect(isStrongPassword('abcd1234'), isTrue);
      expect(isStrongPassword('abcdefgh'), isFalse);
      expect(isStrongPassword('12345678'), isFalse);
      expect(isStrongPassword('abc123'), isFalse);
      expect(isStrongPassword('şifre1234'), isTrue);
    });
  });
}
