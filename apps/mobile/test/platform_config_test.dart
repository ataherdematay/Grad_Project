// Xcode / Android SDK olmadan platform yapılandırmasını doğrular. Özellikle
// iOS'ta iki Info.plist'in (Release/Profile ve Debug) ATS dışında aynı
// kalmasını zorlar: biri değişip diğeri unutulursa bu test kırılır.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

/// pbxproj içindeki `/* <name> */ = { isa = XCBuildConfiguration; ... }`
/// bloklarından `INFOPLIST_FILE` içerenleri (Runner hedefi) döndürür.
Map<String, String> _runnerConfigs(String pbx) {
  final result = <String, String>{};
  final re = RegExp(
    r'/\* (Debug|Release|Profile) \*/ = \{\s*isa = XCBuildConfiguration;(.*?)\n\t\t\};',
    dotAll: true,
  );
  for (final m in re.allMatches(pbx)) {
    if (_setting(m.group(2)!, 'INFOPLIST_FILE') != null) {
      result[m.group(1)!] = m.group(2)!;
    }
  }
  return result;
}

String? _setting(String block, String key) =>
    RegExp('(?<![A-Z_])$key = ([^;]+);').firstMatch(block)?.group(1)?.trim();

const _atsBlock =
    '\t<key>NSAppTransportSecurity</key>\n'
    '\t<dict>\n'
    '\t\t<key>NSAllowsLocalNetworking</key>\n'
    '\t\t<true/>\n'
    '\t</dict>\n';

void main() {
  group('iOS', () {
    final pbx = _read('ios/Runner.xcodeproj/project.pbxproj');
    final configs = _runnerConfigs(pbx);

    test('Runner hedefinin üç yapılandırması da var', () {
      expect(configs.keys.toSet(), {'Debug', 'Release', 'Profile'});
    });

    test('bundle id her yapılandırmada com.bitadilat.app', () {
      for (final e in configs.entries) {
        expect(
          _setting(e.value, 'PRODUCT_BUNDLE_IDENTIFIER'),
          'com.bitadilat.app',
          reason: e.key,
        );
      }
    });

    test('ATS istisnası yalnız Debug plist\'inde', () {
      expect(
        _setting(configs['Debug']!, 'INFOPLIST_FILE'),
        'Runner/Info-Debug.plist',
      );
      expect(
        _setting(configs['Release']!, 'INFOPLIST_FILE'),
        'Runner/Info.plist',
      );
      expect(
        _setting(configs['Profile']!, 'INFOPLIST_FILE'),
        'Runner/Info.plist',
      );

      final release = _read('ios/Runner/Info.plist');
      final debug = _read('ios/Runner/Info-Debug.plist');
      expect(release, isNot(contains('NSAppTransportSecurity')));
      expect(release, isNot(contains('NSAllowsArbitraryLoads')));
      expect(debug, isNot(contains('NSAllowsArbitraryLoads')));
      expect(debug, contains(_atsBlock));
      // Sapma koruması: ATS bloğu çıkarılınca iki dosya birebir aynı olmalı.
      expect(debug.replaceFirst(_atsBlock, ''), release);
    });

    test('dağıtım hedefi iOS 16.0, görünen ad BiTadilat', () {
      final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);')
          .allMatches(pbx)
          .map((m) => m.group(1))
          .toSet();
      expect(targets, {'16.0'});
      final plist = _read('ios/Runner/Info.plist');
      expect(
        plist,
        contains(
          '<key>CFBundleDisplayName</key>\n\t<string>BiTadilat</string>',
        ),
      );
    });
  });

  group('Android', () {
    final gradle = _read('android/app/build.gradle.kts');
    final main = _read('android/app/src/main/AndroidManifest.xml');
    final debug = _read('android/app/src/debug/AndroidManifest.xml');

    test('applicationId ve namespace com.bitadilat.app', () {
      expect(gradle, contains('namespace = "com.bitadilat.app"'));
      expect(gradle, contains('applicationId = "com.bitadilat.app"'));
    });

    test('ana manifest: INTERNET izni, ad, düz HTTP yok, yedek kapalı', () {
      expect(
        main,
        contains(
          '<uses-permission android:name="android.permission.INTERNET"/>',
        ),
      );
      expect(main, contains('android:label="BiTadilat"'));
      expect(main, isNot(contains('usesCleartextTraffic')));
      // Token'ların şifreli tercih dosyası buluta yedeklenmez.
      expect(main, contains('android:allowBackup="false"'));
    });

    test('WebView ve harita: INTERNET izni var, https VIEW sorgusu tanımlı', () {
      // 3-D Secure WebView'i INTERNET iznine, "Haritada aç" https VIEW
      // sorgusuna dayanır (Android 11+ paket görünürlüğü).
      expect(main, contains('android.intent.action.VIEW'));
      expect(main, contains('<data android:scheme="https"/>'));
    });

    test('düz HTTP yalnız debug manifestinde', () {
      expect(debug, contains('android:usesCleartextTraffic="true"'));
    });
  });
}
