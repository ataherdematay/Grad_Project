import 'package:flutter/material.dart';

/// BiTadilat Design System - Authoritative Color Tokens
/// Verbatim mapping to Google Stitch and Tailwind tokens from preview/screens/*.html
class AppColors {
  // Brand Primary & Teal Accents
  static const Color primary = Color(0xFF003441); // Deep Primary
  static const Color primaryDark = Color(0xFF0A3945);
  static const Color primaryContainer = Color(0xFF0F4C5C); // Aegean Teal
  static const Color darkTeal = Color(0xFF0A3945); // Dark Pressed Teal
  static const Color primaryLight = Color(0xFFB6EBFE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Trust & Escrow Emerald Accents
  static const Color emerald = Color(0xFF107A5B); // Escrow & Verification Green
  static const Color emeraldLight = Color(0xFFE7F3EF); // Green Badge Background
  static const Color emeraldDark = Color(0xFF003727); // Deep Green
  static const Color tertiary = Color(0xFF003727);
  static const Color tertiaryContainer = Color(0xFF00503A);
  static const Color tertiaryFixed = Color(0xFF99F5CE);
  static const Color tertiaryFixedDim = Color(0xFF7DD8B3);

  // Urgency & Attention Accents
  static const Color secondary = Color(0xFF9B4500);
  static const Color secondaryContainer = Color(0xFFFD8535);
  static const Color secondaryFixed = Color(0xFFFFDBC9);
  static const Color orange = Color(0xFFE87525); // Urgent Alert Orange
  static const Color orangeLight = Color(0xFFFDF1E9); // Light Orange Background
  static const Color amber = Color(0xFFF59E0B);

  // Canvas & Surfaces
  static const Color canvas = Color(0xFFF7F8F6); // Soft Ivory/Grey Canvas
  static const Color background = Color(0xFFF7F8F6);
  static const Color surface = Color(0xFFFFFFFF); // Card Background
  static const Color surfaceContainerLow = Color(0xFFE6F6FF);
  static const Color surfaceContainer = Color(0xFFD8F2FF);
  static const Color surfaceContainerHigh = Color(0xFFD2ECFA);
  static const Color surfaceContainerHighest = Color(0xFFCCE7F4);
  static const Color surfaceVariant = Color(0xFFCCE7F4);
  static const Color surfaceDisabled = Color(0xFFE9EEEB);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFD9E1DD);
  static const Color border = Color(0xFFD9E1DD);
  static const Color borderLight = Color(0xFFEDF2F7);
  static const Color outline = Color(0xFF70787C);

  // Typography & Content
  static const Color onSurface = Color(0xFF031E28); // Near Black Headlines
  static const Color onSurfaceVariant = Color(0xFF40484B);
  static const Color textPrimary = Color(0xFF031E28);
  static const Color textSecondary = Color(0xFF5F6F73); // Slate Body
  static const Color textMuted = Color(0xFF70787C);
  static const Color textDisabled = Color(0xFFA0AEC0);

  // System States
  static const Color infoBlue = Color(0xFF247BA0);
  static const Color alertRed = Color(0xFFB9382C);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
}
