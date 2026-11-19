import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'widgets.dart';

export 'legal_screen.dart' show LegalScreen, kLegalDocs, legalTitle;

/// Markalı "bulunamadı" ekranı.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Align(alignment: Alignment.centerLeft, child: LogoText()),
            ),
            Expanded(
              child: EmptyState(
                icon: Icons.explore_off_outlined,
                title: l.notFoundTitle,
                message: l.notFoundBody,
                actionLabel: l.notFoundAction,
                onAction: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
