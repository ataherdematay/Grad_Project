// Xcode / Android SDK olmadan platform yapılandırmasını doğrular. Özellikle
// iOS'ta iki Info.plist'in (Release/Profile ve Debug) ATS dışında aynı
// kalmasını zorlar: biri değişip diğeri unutulursa bu test kırılır.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bitadilat_mobile/core/providers.dart';
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

/// PNG'nin parça (chunk) türleri ve IHDR alanları.
({List<String> chunks, int width, int height, int colorType}) _png(
  String path,
) {
  final b = File(path).readAsBytesSync();
  final d = ByteData.sublistView(b);
  final chunks = <String>[];
  var pos = 8;
  while (pos < b.length) {
    final len = d.getUint32(pos);
    chunks.add(String.fromCharCodes(b.sublist(pos + 4, pos + 8)));
    pos += 12 + len;
  }
  return (
    chunks: chunks,
    width: d.getUint32(16),
    height: d.getUint32(20),
    colorType: b[25],
  );
}

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
    test('ikon ve açılış görseli: boyutlar tutarlı, ikon alfasız, sRGB '
        'etiketli', () {
      // Etiketsiz PNG iOS'ta Display P3 sayılıp doygun çizilir; açılış
      // karosu Flutter'daki BrandMark'tan farklı renkte görünüyordu.
      const icons = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
      final contents =
          jsonDecode(_read('$icons/Contents.json')) as Map<String, dynamic>;
      for (final item in (contents['images'] as List).cast<Map>()) {
        final pt = double.parse((item['size'] as String).split('x').first);
        final scale = int.parse((item['scale'] as String).replaceAll('x', ''));
        final png = _png('$icons/${item['filename']}');
        expect(png.width, (pt * scale).round(), reason: '${item['filename']}');
        expect(png.height, png.width);
        expect(png.colorType, 2, reason: 'RGB, alfa yok: ${item['filename']}');
        expect(png.chunks, contains('sRGB'), reason: '${item['filename']}');
      }
      const launch = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';
      for (final (name, px) in [
        ('LaunchImage.png', 96),
        ('LaunchImage@2x.png', 192),
        ('LaunchImage@3x.png', 288),
      ]) {
        final png = _png('$launch/$name');
        expect((png.width, png.height), (px, px), reason: name);
        expect(png.chunks, contains('sRGB'), reason: name);
      }
    });

    test('açılış ve ana storyboard zemini tuval rengi (#F7F8F6)', () {
      for (final f in ['LaunchScreen', 'Main']) {
        expect(
          _read('ios/Runner/Base.lproj/$f.storyboard'),
          contains(
            '<color key="backgroundColor" red="0.96862745098039216" '
            'green="0.97254901960784312" blue="0.96470588235294119" alpha="1" '
            'colorSpace="custom" customColorSpace="sRGB"/>',
          ),
          reason: f,
        );
      }
      expect(
        _read('ios/Runner/Base.lproj/LaunchScreen.storyboard'),
        contains('<image name="LaunchImage" width="96" height="96"/>'),
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

    test(
      'WebView ve harita: INTERNET izni var, https VIEW sorgusu tanımlı',
      () {
        // 3-D Secure WebView'i INTERNET iznine, "Haritada aç" https VIEW
        // sorgusuna dayanır (Android 11+ paket görünürlüğü).
        expect(main, contains('android.intent.action.VIEW'));
        expect(main, contains('<data android:scheme="https"/>'));
      },
    );

    test('düz HTTP yalnız debug manifestinde', () {
      expect(debug, contains('android:usesCleartextTraffic="true"'));
    });

    test(
      'network security config: release yalnız HTTPS, debug yalnız yerel HTTP',
      () {
        expect(
          main,
          contains(
            'android:networkSecurityConfig="@xml/network_security_config"',
          ),
        );
        final release = _read(
          'android/app/src/main/res/xml/network_security_config.xml',
        );
        expect(release, contains('cleartextTrafficPermitted="false"'));
        expect(release, isNot(contains('cleartextTrafficPermitted="true"')));
        expect(release, isNot(contains('<certificates src="user"')));
        final dbg = _read(
          'android/app/src/debug/res/xml/network_security_config.xml',
        );
        final domains = RegExp(r'<domain[^>]*>([^<]+)</domain>')
            .allMatches(dbg)
            .map((m) => m.group(1))
            .toSet();
        expect(domains, {'10.0.2.2', 'localhost', '127.0.0.1'});
        // profile derlemesi release kuralını kullanır (kendi kopyası yok).
        expect(
          File('android/app/src/profile/res/xml/network_security_config.xml')
              .existsSync(),
          isFalse,
        );
      },
    );

    test('yalnız INTERNET izni; release imzası repoda değil', () {
      final perms = RegExp(r'<uses-permission android:name="([^"]+)"')
          .allMatches(main)
          .map((m) => m.group(1))
          .toList();
      expect(perms, ['android.permission.INTERNET']);
      final ignore = _read('android/.gitignore');
      expect(ignore, contains('key.properties'));
      expect(ignore, contains('**/*.jks'));
      expect(ignore, contains('**/*.keystore'));
      expect(File('android/key.properties').existsSync(), isFalse);
      final keystores = Directory('android')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) => f.path.endsWith('.jks') || f.path.endsWith('.keystore'),
          );
      expect(keystores, isEmpty);
      expect(gradle, contains('signingConfigs.getByName("release")'));
      expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    });

    test('simge her yoğunlukta, adaptive simge ve açılış kaynakları var', () {
      const sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      for (final e in sizes.entries) {
        for (final name in ['ic_launcher', 'ic_launcher_round']) {
          final png = _png(
            'android/app/src/main/res/mipmap-${e.key}/$name.png',
          );
          expect(png.width, e.value, reason: '${e.key}/$name');
          expect(png.height, e.value, reason: '${e.key}/$name');
        }
      }
      expect(main, contains('android:icon="@mipmap/ic_launcher"'));
      expect(main, contains('android:roundIcon="@mipmap/ic_launcher_round"'));
      const res = 'android/app/src/main/res';
      for (final f in [
        'mipmap-anydpi-v26/ic_launcher.xml',
        'mipmap-anydpi-v26/ic_launcher_round.xml',
        'drawable/ic_launcher_background.xml',
        'drawable/ic_launcher_foreground.xml',
        'drawable/ic_launcher_monochrome.xml',
        'drawable/launch_background.xml',
        'drawable/launch_logo.xml',
        'drawable/splash_icon.xml',
        'values/colors.xml',
      ]) {
        expect(File('$res/$f').existsSync(), isTrue, reason: f);
      }
      // Kaynaklarda adı geçen her @drawable/@color/@mipmap tanımlı olmalı.
      final defined = <String>{
        for (final f in Directory(
          res,
        ).listSync(recursive: true).whereType<File>())
          '${f.parent.path.split('/').last.split('-').first}/'
              '${f.uri.pathSegments.last.split('.').first}',
        ...RegExp(r'<color name="([^"]+)"')
            .allMatches(_read('$res/values/colors.xml'))
            .map((m) => 'color/${m.group(1)}'),
      };
      final refs = <String>{};
      for (final f in [
        ...Directory(res).listSync(recursive: true).whereType<File>(),
        File('android/app/src/main/AndroidManifest.xml'),
      ].where((f) => f.path.endsWith('.xml'))) {
        refs.addAll(
          RegExp(r'@(drawable|color|mipmap|xml|style)/([A-Za-z0-9_]+)')
              .allMatches(f.readAsStringSync())
              .where((m) => m.group(1) != 'style')
              .map((m) => '${m.group(1)}/${m.group(2)}'),
        );
      }
      expect(
        defined.containsAll(refs),
        isTrue,
        reason: '${refs.difference(defined)}',
      );
    });
  });

  group('release API adresi', () {
    test('release yalnız https kabul eder, debug her şeyi', () {
      expect(
        () => ensureSecureApiBaseUrl('http://localhost:8090', release: true),
        throwsStateError,
      );
      expect(
        () => ensureSecureApiBaseUrl('api.example.com', release: true),
        throwsStateError,
      );
      ensureSecureApiBaseUrl('https://api.example.com', release: true);
      ensureSecureApiBaseUrl('http://10.0.2.2:8090', release: false);
    });
  });
}
