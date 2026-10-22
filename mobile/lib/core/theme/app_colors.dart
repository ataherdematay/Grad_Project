import 'package:flutter/material.dart';

/// BiTadilat Design System - Authoritative Color Tokens
class AppColors {
  // Brand Primary & Trust Colors
  static const Color primary = Color(0xFF0F4C5C); // Deep Aegean Teal
  static const Color primaryDark = Color(0xFF0A333E);
  static const Color primaryLight = Color(0xFF1E6F85);

  // Trust & Escrow Accent Colors
  static const Color emerald = Color(0xFF107A5B); // Escrow / Trust Green
  static const Color emeraldLight = Color(0xFFE8F5EE);
  static const Color emeraldDark = Color(0xFF0B5841);

  // Urgency & Attention Colors
  static const Color orange = Color(0xFFE87525); // Action / Urgency Orange
  static const Color orangeLight = Color(0xFFFDF0E7);
  static const Color amber = Color(0xFFF59E0B);

  // Neutral & Canvas Surfaces
  static const Color background = Color(0xFFF7F8F6); // Soft Ivory/Grey Canvas
  static const Color surface = Color(0xFFFFFFFF); // Card Background
  static const Color surfaceVariant = Color(0xFFEFF2ED);

  // Border & Divider Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEDF2F7);

  // Typography & Content Colors
  static const Color textPrimary = Color(0xFF1A202C); // Near Black
  static const Color textSecondary = Color(0xFF4A5568); // Slate Grey
  static const Color textMuted = Color(0xFF718096); // Soft Grey
  static const Color textDisabled = Color(0xFFA0AEC0);

  // System & Feedback States
  static const Color success = Color(0xFF107A5B);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Shimmer & Skeleton
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
