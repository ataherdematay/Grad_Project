import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _family = 'packages/bitadilat_ui/Manrope';

/// Gömülü Manrope değişken font; varsayılan örneği ExtraLight (200). Bir stil
/// Manrope değilse ya da `wght` ekseni `fontWeight` ile aynı değilse metin
/// sistem fontunda ya da ince çizilir.
String? _problem(TextStyle? s) {
  if (s == null) return 'stil yok';
  if (s.fontFamily != _family) return 'aile ${s.fontFamily}';
  final weight = (s.fontWeight ?? FontWeight.w400).value.toDouble();
  final wght = [
    for (final v in s.fontVariations ?? const <FontVariation>[])
      if (v.axis == 'wght') v.value,
  ];
  if (wght.length != 1 || wght.single != weight) {
    return 'fontWeight $weight, wght $wght';
  }
  return null;
}

/// Ekrandaki her metin parçasının (iç içe span'ler dahil) etkin stilini
/// denetler.
List<String> _renderedProblems(WidgetTester t) {
  final out = <String>[];
  for (final p in t.allRenderObjects.whereType<RenderParagraph>()) {
    void visit(InlineSpan span, TextStyle? parent) {
      final style = parent == null
          ? span.style
          : (span.style == null ? parent : parent.merge(span.style));
      if (span is TextSpan) {
        final text = span.text ?? '';
        final icon = style?.fontFamily == 'MaterialIcons';
        if (text.trim().isNotEmpty && !icon) {
          final pr = _problem(style);
          if (pr != null) out.add('"$text": $pr');
        }
        for (final c in span.children ?? const <InlineSpan>[]) {
          visit(c, style);
        }
      }
    }

    visit(p.text, null);
  }
  return out;
}

Future<BuildContext> _pump(WidgetTester t, Widget home) async {
  late BuildContext ctx;
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (c) {
          ctx = c;
          return home;
        },
      ),
    ),
  );
  return ctx;
}

// iOS: boş TextTheme rolleri `CupertinoSystemDisplay/Text` ailesine düşer.
final _ios = TargetPlatformVariant.only(TargetPlatform.iOS);

void main() {
  testWidgets('TextTheme\'in 15 girişinin hepsi Manrope ve doğru wght', (
    t,
  ) async {
    final ctx = await _pump(t, const SizedBox());
    final theme = Theme.of(ctx);
    for (final tt in [theme.textTheme, theme.primaryTextTheme]) {
      final entries = <String, TextStyle?>{
        'displayLarge': tt.displayLarge,
        'displayMedium': tt.displayMedium,
        'displaySmall': tt.displaySmall,
        'headlineLarge': tt.headlineLarge,
        'headlineMedium': tt.headlineMedium,
        'headlineSmall': tt.headlineSmall,
        'titleLarge': tt.titleLarge,
        'titleMedium': tt.titleMedium,
        'titleSmall': tt.titleSmall,
        'bodyLarge': tt.bodyLarge,
        'bodyMedium': tt.bodyMedium,
        'bodySmall': tt.bodySmall,
        'labelLarge': tt.labelLarge,
        'labelMedium': tt.labelMedium,
        'labelSmall': tt.labelSmall,
      };
      final bad = {
        for (final e in entries.entries)
          if (_problem(e.value) != null) e.key: _problem(e.value),
      };
      expect(bad, isEmpty);
    }
  }, variant: _ios);

  testWidgets('tasarım ölçüleri korunur', (t) async {
    final ctx = await _pump(t, const SizedBox());
    final tt = Theme.of(ctx).textTheme;
    expect(tt.headlineMedium!.fontSize, 28); // ekran başlığı
    expect(tt.headlineMedium!.fontWeight, FontWeight.w600);
    expect(tt.titleLarge!.fontSize, 20); // bölüm başlığı
    expect(tt.titleLarge!.fontWeight, FontWeight.w600);
    expect(tt.bodyLarge!.fontSize, 16);
    expect(tt.bodyLarge!.fontWeight, FontWeight.w400);
    expect(tt.labelMedium!.fontSize, 14);
    expect(tt.labelMedium!.fontWeight, FontWeight.w500);
  }, variant: _ios);

  testWidgets('AppBar, sekme, liste, chip, alan, alt gezinme Manrope', (
    t,
  ) async {
    await _pump(
      t,
      DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Başlık'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Açık'),
                Tab(text: 'Geçmiş'),
              ],
            ),
          ),
          body: ListView(
            children: [
              const ListTile(
                title: Text('Liste başlığı'),
                subtitle: Text('Alt yazı'),
                trailing: Text('Sağ'),
              ),
              ChoiceChip(
                label: const Text('Seçili'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Süzgeç'),
                selected: false,
                onSelected: (_) {},
              ),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Etiket',
                  hintText: 'İpucu',
                  helperText: 'Yardım',
                  prefixText: '₺',
                ),
              ),
              const TextField(
                decoration: InputDecoration(errorText: 'Hata metni'),
              ),
              const Text('Düz metin'),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Ana'),
              NavigationDestination(icon: Icon(Icons.list), label: 'Talepler'),
            ],
          ),
        ),
      ),
    );
    expect(_renderedProblems(t), isEmpty);
  }, variant: _ios);

  testWidgets('diyalog ve SnackBar Manrope', (t) async {
    final ctx = await _pump(t, const Scaffold(body: SizedBox()));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: const Text('Kaydedildi'),
        action: SnackBarAction(label: 'Geri al', onPressed: () {}),
      ),
    );
    showConfirmDialog(
      ctx,
      title: 'Teklifi reddet',
      message: 'Emin misin?',
      confirmLabel: 'Reddet',
      cancelLabel: 'Vazgeç',
    );
    await t.pumpAndSettle();
    expect(find.text('Teklifi reddet'), findsOneWidget);
    expect(_renderedProblems(t), isEmpty);
  }, variant: _ios);

  testWidgets('tarih seçici Manrope', (t) async {
    final ctx = await _pump(t, const Scaffold(body: SizedBox()));
    showDatePicker(
      context: ctx,
      initialDate: DateTime(2026, 11, 12),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
    );
    await t.pumpAndSettle();
    expect(_renderedProblems(t), isEmpty);
  }, variant: _ios);

  testWidgets('saat seçici Manrope', (t) async {
    final ctx = await _pump(t, const Scaffold(body: SizedBox()));
    showTimePicker(
      context: ctx,
      initialTime: const TimeOfDay(hour: 9, minute: 30),
    );
    await t.pumpAndSettle();
    expect(_renderedProblems(t), isEmpty);
  }, variant: _ios);

  selectionColorTests();
}

/// Turuncu yalnız aciliyet içindir (BiTadilatDESIGN.md); seçili chip ve
/// segment Material 3'te `secondaryContainer` rengini kullanır.
void selectionColorTests() {
  testWidgets('seçili ChoiceChip ve SegmentedButton turuncu değil, teal', (
    t,
  ) async {
    await _pump(
      t,
      Scaffold(
        body: Column(
          children: [
            ChoiceChip(
              label: const Text('Hepsi'),
              selected: true,
              onSelected: (_) {},
            ),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 0, label: Text('Tümü')),
                ButtonSegment(value: 1, label: Text('Acil')),
              ],
              selected: const {0},
              onSelectionChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    Color? colorOf(String text) {
      final p = t.renderObject<RenderParagraph>(find.text(text));
      return p.text.style?.color;
    }

    expect(colorOf('Hepsi'), AppColors.primaryDark);
    expect(colorOf('Tümü'), AppColors.primaryDark);
    final scheme = Theme.of(t.element(find.text('Hepsi'))).colorScheme;
    expect(scheme.secondaryContainer, isNot(const Color(0xFFFDF1E9)));
    expect(scheme.secondaryContainer, scheme.primaryContainer);
  });
}
