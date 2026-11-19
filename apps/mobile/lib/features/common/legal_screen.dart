import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'misc_screens.dart' show NotFoundScreen;
import 'widgets.dart';

/// Yasal metinler (`/legal/:doc`). Gövde `docs/legal` taslaklarının uygulamaya
/// gömülü kopyasıdır (`assets/legal/<dosya>.<dil>.md`); hepsi TASLAK'tır.
const List<String> kLegalDocs = [
  'kvkk',
  'terms',
  'privacy',
  'payment',
  'pro-terms',
];

const Map<String, String> _legalFiles = {
  'kvkk': 'kvkk-aydinlatma-metni',
  'terms': 'kullanim-kosullari',
  'privacy': 'gizlilik-politikasi',
  'payment': 'odeme-ve-guvence-havuzu-kosullari',
  'pro-terms': 'usta-sozlesmesi-ozeti',
};

String? legalTitle(AppLocalizations l, String doc) => switch (doc) {
  'kvkk' => l.legalKvkkTitle,
  'terms' => l.legalTermsTitle,
  'privacy' => l.legalPrivacyTitle,
  'payment' => l.legalPaymentTitle,
  'pro-terms' => l.legalProTitle,
  _ => null,
};

/// Belgenin dile göre asset yolu; bilinmeyen belge null.
String? legalAssetPath(String doc, String languageCode) {
  final file = _legalFiles[doc];
  if (file == null) return null;
  return 'assets/legal/$file.${languageCode == 'en' ? 'en' : 'tr'}.md';
}

/// Testte değiştirilebilen metin yükleyici.
final legalTextLoaderProvider = Provider<Future<String> Function(String path)>(
  (_) => rootBundle.loadString,
);

final _legalTextProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, path) => ref.read(legalTextLoaderProvider)(path),
);

/// KVKK, koşullar, gizlilik, ödeme koşulları ve usta sözleşmesi özeti. Üstte
/// "Taslak metin" etiketi ve hukuken geçerli olmadığı uyarısı her zaman durur.
class LegalScreen extends ConsumerWidget {
  const LegalScreen({super.key, required this.doc});

  final String doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final title = legalTitle(l, doc);
    final path = legalAssetPath(doc, l.localeName);
    if (title == null || path == null) return const NotFoundScreen();
    final text = ref.watch(_legalTextProvider(path));
    return PageScaffold(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(label: l.legalDraftBadge, icon: Icons.edit_note),
          const SizedBox(height: AppSpacing.sm),
          Text(l.legalDraftNotice, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          text.when(
            data: LegalMarkdown.new,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.legalLoadFailed, style: AppTypography.body),
                TextButton(
                  onPressed: () => ref.invalidate(_legalTextProvider(path)),
                  child: Text(l.retry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Taslaklarda kullanılan küçük Markdown alt kümesi: `#`/`##`/`###`
/// başlıklar, `- ` maddeler, `> ` alıntı, `**kalın**`; geri kalan paragraf.
class LegalMarkdown extends StatelessWidget {
  const LegalMarkdown(this.source, {super.key});

  final String source;

  static List<InlineSpan> _inline(String text) {
    final parts = text.split('**');
    return [
      for (var i = 0; i < parts.length; i++)
        if (parts[i].isNotEmpty)
          TextSpan(
            text: parts[i],
            style: i.isOdd
                ? AppTypography.weight(AppTypography.body, FontWeight.w700)
                : null,
          ),
    ];
  }

  static Widget _rich(String text) =>
      Text.rich(TextSpan(children: _inline(text)), style: AppTypography.body);

  static Widget _header(String text, TextStyle style, {double top = 0}) =>
      Padding(
        padding: EdgeInsets.only(top: top),
        child: Semantics(header: true, child: Text(text, style: style)),
      );

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final raw in source.split('\n')) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: AppSpacing.xs));
        }
      } else if (line.startsWith('### ')) {
        children.add(_header(line.substring(4), AppTypography.cardTitle));
      } else if (line.startsWith('## ')) {
        children.add(
          _header(line.substring(3), AppTypography.section, top: AppSpacing.sm),
        );
      } else if (line.startsWith('# ')) {
        children.add(_header(line.substring(2), AppTypography.screenTitle));
      } else if (line.startsWith('> ')) {
        children.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: AppColors.neutralSurface,
            child: _rich(line.substring(2)),
          ),
        );
      } else if (line.startsWith('- ')) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(child: Text('•  ')),
                Expanded(child: _rich(line.substring(2))),
              ],
            ),
          ),
        );
      } else {
        children.add(_rich(line.trim()));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
