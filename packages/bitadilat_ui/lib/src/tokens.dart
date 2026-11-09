import 'package:flutter/material.dart';

/// Renk token'ları (BiTadilatDESIGN.md).
abstract final class AppColors {
  static const Color primary = Color(0xFF0F4C5C);
  static const Color primaryDark = Color(0xFF0A3945);
  static const Color urgency = Color(0xFFE87525);
  static const Color success = Color(0xFF107A5B);
  static const Color error = Color(0xFFB9382C);
  static const Color info = Color(0xFF247BA0);
  static const Color canvas = Color(0xFFF7F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF102A34);
  static const Color textSecondary = Color(0xFF5F6F73);
  static const Color border = Color(0xFFD9E1DD);
  static const Color disabled = Color(0xFFE9EEEB);

  /// Etiket metni için koyulaştırılmış tonlar (açık zeminde AA kontrast).
  static const Color urgencyText = Color(0xFF9B4500);
  static const Color infoText = Color(0xFF1A5F7F);
}

/// Boşluk ölçeği: 8 / 12 / 16 / 24.
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
}

/// Köşe yarıçapları.
abstract final class AppRadius {
  static const double button = 14;
  static const double card = 16;
  static const double input = 12;
}

/// Ölçüler.
abstract final class AppSizes {
  static const double controlHeight = 52;
  static const double minTouch = 48;
}
