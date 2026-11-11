// Gömülü Manrope değişken bir fonttur: `fontWeight` tek başına kalınlığı
// değiştirmez, `wght` ekseni de güncellenmelidir. Kalınlık yalnız
// `AppTypography` (stiller ve `AppTypography.weight`) üzerinden verilir;
// elle `fontWeight:` yazılırsa metin üst stilin kalınlığında (ör. 400) kalır.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kaynakta AppTypography dışında elle fontWeight yok', () {
    final offenders = <String>[];
    for (final root in ['lib', '../../packages/bitadilat_ui/lib']) {
      for (final f in Directory(root).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        if (f.path.endsWith('typography.dart')) continue;
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('fontWeight:')) {
            offenders.add('${f.path}:${i + 1}');
          }
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
