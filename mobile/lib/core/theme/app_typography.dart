import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// BiTadilat Typography System - Exact Manrope Tailwind Scale
class AppTypography {
  static TextStyle get headlineLg => GoogleFonts.manrope(
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 28,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.manrope(
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.015 * 24,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.manrope(
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 20,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.manrope(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLgMedium => GoogleFonts.manrope(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.manrope(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMdMedium => GoogleFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.manrope(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelMd => GoogleFonts.manrope(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02 * 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSm => GoogleFonts.manrope(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.04 * 11,
        color: AppColors.textSecondary,
      );

  // Backward compatibility convenience getters
  static TextStyle get h1 => headlineLgMobile;
  static TextStyle get h2 => headlineMd;
  static TextStyle get h3 => headlineSm;
  static TextStyle get h4 => bodyLgMedium;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => labelMd;
  static TextStyle get label => labelSm;
  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
  static TextStyle get price => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryContainer,
      );
}
