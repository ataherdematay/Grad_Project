// WCAG AA kontrast kontrolü (BiTadilatDESIGN.md §7): metin 4.5:1.
import 'dart:math' as math;

import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('kontrast hesabı bilinen değerleri verir', () {
    expect(contrast(Colors.black, Colors.white), closeTo(21, 0.01));
    expect(contrast(Colors.white, Colors.white), closeTo(1, 0.001));
  });

  test('metin token çiftleri AA (4.5:1) geçer', () {
    final pairs = <String, (Color, Color)>{
      'beyaz / primary': (Colors.white, AppColors.primary),
      'textPrimary / canvas': (AppColors.textPrimary, AppColors.canvas),
      'textSecondary / canvas': (AppColors.textSecondary, AppColors.canvas),
      'textSecondary / surface': (AppColors.textSecondary, AppColors.surface),
      'textSecondary / selectedSurface': (
        AppColors.textSecondary,
        AppColors.selectedSurface,
      ),
      'error / surface': (AppColors.error, AppColors.surface),
      'error / canvas': (AppColors.error, AppColors.canvas),
      'primary / canvas': (AppColors.primary, AppColors.canvas),
    };
    for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: name);
    }
  });

  testWidgets('her StatusChip tonunda etiket AA geçer', (t) async {
    AppTypography.useGoogleFonts = false;
    for (final tone in StatusTone.values) {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusChip(label: 'Durum', icon: Icons.info, tone: tone),
          ),
        ),
      );
      final box = t.widget<Container>(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.byType(Container),
        ),
      );
      final bg = (box.decoration! as BoxDecoration).color!;
      final fg = t.widget<Text>(find.text('Durum')).style!.color!;
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$tone');
    }
  });
}
