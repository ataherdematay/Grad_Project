import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// TR / EN dil anahtarı.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(localeProvider).languageCode;
    return Semantics(
      label: l.language,
      container: true,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          minimumSize: const Size(48, 40),
        ),
        segments: const [
          ButtonSegment(value: 'tr', label: Text('TR')),
          ButtonSegment(value: 'en', label: Text('EN')),
        ],
        selected: {current},
        onSelectionChanged: (s) =>
            ref.read(localeProvider.notifier).set(Locale(s.first)),
      ),
    );
  }
}
