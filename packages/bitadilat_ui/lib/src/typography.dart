import 'package:flutter/material.dart';

import 'tokens.dart';

/// Manrope tipografisi.
///
/// Font pakete gömülüdür (`fonts/Manrope-VariableFont_wght.ttf`, SIL OFL 1.1,
/// kaynak: google/fonts `ofl/manrope/`); çalışma anında ağdan font
/// indirilmez. Değişken fontun varsayılan örneği ExtraLight (200) olduğundan
/// her stil `wght` eksenini kalınlıkla birlikte açıkça verir; kalınlığı
/// değiştirmek için [AppTypography.weight] kullanılır.
///
/// Testlerde paket fontu yüklenmez; metin test fontuyla, deterministik çizilir.
abstract final class AppTypography {
  /// Font ailesi ve paketi; `ThemeData` ve elle kurulan stiller içindir.
  static const String fontFamily = 'Manrope';
  static const String fontPackage = 'bitadilat_ui';

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? height,
    Color color = AppColors.textPrimary,
  }) => TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
    height: height,
    color: color,
  );

  /// [style]'ın kalınlığını değiştirir; değişken fontun `wght` ekseni de
  /// birlikte güncellenir (yalnız `fontWeight` değiştirmek yetmez).
  static TextStyle weight(TextStyle style, FontWeight weight) => style.copyWith(
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
  );

  /// Ekran başlığı: 28 semibold.
  static TextStyle get screenTitle => _style(28, FontWeight.w600, height: 1.2);

  /// Bölüm başlığı: 20 semibold.
  static TextStyle get section => _style(20, FontWeight.w600, height: 1.3);

  /// Kart başlığı: 16 semibold.
  static TextStyle get cardTitle => _style(16, FontWeight.w600, height: 1.3);

  /// Buton etiketi: 16 semibold.
  static TextStyle get button => _style(16, FontWeight.w600, height: 1.25);

  /// Gövde: 16 regular, 1.45 satır.
  static TextStyle get body => _style(16, FontWeight.w400, height: 1.45);

  /// İkincil gövde.
  static TextStyle get bodySecondary =>
      _style(16, FontWeight.w400, height: 1.45, color: AppColors.textSecondary);

  /// Etiket: 14 medium.
  static TextStyle get label => _style(14, FontWeight.w500, height: 1.3);

  /// Material'in 15 metin rolünün hepsi. Boş bırakılan rol `ThemeData`
  /// içinde platform fontuna düşer (iOS'ta SF: tarih/saat seçici başlığı,
  /// büyük AppBar); bu yüzden tasarımda karşılığı olmayan roller de Manrope
  /// ile ve Material 3 ölçüleriyle doldurulur.
  static TextTheme get textTheme => TextTheme(
    displayLarge: _style(57, FontWeight.w400, height: 64 / 57),
    displayMedium: _style(45, FontWeight.w400, height: 52 / 45),
    displaySmall: _style(36, FontWeight.w400, height: 44 / 36),
    headlineLarge: _style(32, FontWeight.w600, height: 1.25),
    headlineMedium: screenTitle,
    headlineSmall: _style(24, FontWeight.w600, height: 1.3),
    titleLarge: section,
    titleMedium: cardTitle,
    titleSmall: cardTitle,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: label.copyWith(color: AppColors.textSecondary),
    labelLarge: button,
    labelMedium: label,
    labelSmall: label,
  );
}
