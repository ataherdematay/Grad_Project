import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Manrope tipografisi.
///
/// Font şimdilik çalışma anında `google_fonts` ile alınır; dosya depoda yok.
/// Pakete gömülmesi bekliyor. Testlerde `useGoogleFonts = false` yapılır.
abstract final class AppTypography {
  static bool useGoogleFonts = true;

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? height,
    Color color = AppColors.textPrimary,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
    return useGoogleFonts ? GoogleFonts.manrope(textStyle: base) : base;
  }

  /// Ekran başlığı: 28 semibold.
  static TextStyle get screenTitle =>
      _style(28, FontWeight.w600, height: 1.2);

  /// Bölüm başlığı: 20 semibold.
  static TextStyle get section => _style(20, FontWeight.w600, height: 1.3);

  /// Kart başlığı: 16 semibold.
  static TextStyle get cardTitle => _style(16, FontWeight.w600, height: 1.3);

  /// Buton etiketi: 16 semibold.
  static TextStyle get button => _style(16, FontWeight.w600, height: 1.25);

  /// Gövde: 16 regular, 1.45 satır.
  static TextStyle get body => _style(16, FontWeight.w400, height: 1.45);

  /// İkincil gövde.
  static TextStyle get bodySecondary => _style(
    16,
    FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Etiket: 14 medium.
  static TextStyle get label => _style(14, FontWeight.w500, height: 1.3);

  static TextTheme get textTheme => TextTheme(
    headlineMedium: screenTitle,
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
