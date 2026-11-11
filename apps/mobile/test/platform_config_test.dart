// Xcode / Android SDK olmadan platform yapılandırmasını doğrular. Özellikle
// iOS'ta iki Info.plist'in (Release/Profile ve Debug) ATS dışında aynı
// kalmasını zorlar: biri değişip diğeri unutulursa bu test kırılır.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  });
}
