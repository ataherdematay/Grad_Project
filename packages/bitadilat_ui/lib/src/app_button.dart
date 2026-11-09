import 'package:flutter/material.dart';

import 'tokens.dart';

enum AppButtonVariant { primary, secondary, tertiary }

/// 52 px yüksekliğinde buton. Yükleme sırasında kilitlidir: dokunuşlar yok
/// sayılır, ikinci basış `onPressed`i tetiklemez.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  /// Yükleme sırasında ekran okuyucuya söylenen metin.
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    // Yükleme sırasında stil bozulmasın diye onPressed null yapılmaz.
    final VoidCallback? effective = isLoading ? _ignore : onPressed;
    final fg = switch (variant) {
      AppButtonVariant.primary => Colors.white,
      _ => AppColors.primary,
    };

    final Widget content = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effective,
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effective,
        child: content,
      ),
      AppButtonVariant.tertiary => TextButton(
        onPressed: effective,
        child: content,
      ),
    };

    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null && !isLoading,
      label: isLoading ? (loadingLabel ?? label) : label,
      excludeSemantics: true,
      onTap: effective,
      child: SizedBox(width: expand ? double.infinity : null, child: button),
    );
  }

  static void _ignore() {}
}
