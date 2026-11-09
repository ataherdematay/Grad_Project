import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

enum StatusTone { info, primary, urgent, success, error, neutral }

/// Durum etiketi: ikon ve metin birlikte; renk tek başına anlam taşımaz.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.icon,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final IconData icon;
  final StatusTone tone;

  (Color, Color) get _colors => switch (tone) {
    StatusTone.info => (const Color(0xFFE6F1F6), AppColors.infoText),
    StatusTone.primary => (const Color(0xFFE3EEF0), AppColors.primary),
    StatusTone.urgent => (const Color(0xFFFDF1E9), AppColors.urgencyText),
    StatusTone.success => (const Color(0xFFE7F3EF), AppColors.success),
    StatusTone.error => (const Color(0xFFF8E7E5), AppColors.error),
    StatusTone.neutral => (AppColors.disabled, AppColors.textSecondary),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Semantics(
      label: label,
      container: true,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label, style: AppTypography.label.copyWith(color: fg)),
            ),
          ],
        ),
      ),
    );
  }
}
