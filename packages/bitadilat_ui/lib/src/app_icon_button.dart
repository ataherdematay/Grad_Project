import 'package:flutter/material.dart';

import 'tokens.dart';

/// En az 48x48 dokunma alanı ve zorunlu `tooltip` (erişilebilirlik etiketi).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: onPressed,
      constraints: const BoxConstraints(
        minWidth: AppSizes.minTouch,
        minHeight: AppSizes.minTouch,
      ),
    );
  }
}
