import 'package:flutter/material.dart';

import 'tokens.dart';

/// Beyaz yüzey, 16 px köşe, 1 px kenarlık. `onTap` verilirse dokunulabilir
/// (en az 48 px yükseklik).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }
    return Semantics(
      container: semanticLabel != null,
      label: semanticLabel,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
