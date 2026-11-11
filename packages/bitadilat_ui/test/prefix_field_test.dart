import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester t, {String? error}) async {
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const AppTextField(label: 'Ad', hintText: 'Örn. Ayşe'),
              AppTextField(
                label: 'Tutar',
                hintText: '0',
                prefixText: '₺',
                errorText: error,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('önek (₺, +90) diğer alanların metniyle aynı sütundan başlar', (
    t,
  ) async {
    await _pump(t);
    final hintLeft = t.getTopLeft(find.text('Örn. Ayşe')).dx;
    expect(t.getTopLeft(find.text('₺')).dx, hintLeft);
    // İpucu öneğin sağında, arada boşlukla başlar.
    expect(
      t.getTopLeft(find.text('0')).dx,
      greaterThan(t.getTopRight(find.text('₺')).dx),
    );
  });

  testWidgets('önek boşken, odakta ve yazınca görünür; alan 52 px kalır', (
    t,
  ) async {
    await _pump(t);
    final field = find.byType(TextFormField).last;
    final before = t.getRect(find.text('₺'));
    expect(t.getSize(field).height, 52);
    await t.tap(field);
    await t.enterText(field, '1500');
    await t.pump();
    expect(find.text('₺'), findsOneWidget);
    expect(t.getRect(find.text('₺')), before);
    // Önek ve girilen metin aynı satırda, dikeyde ortalı.
    final value = find.descendant(
      of: field,
      matching: find.byType(EditableText),
    );
    expect(
      (t.getCenter(find.text('₺')).dy - t.getCenter(value).dy).abs(),
      lessThan(1.5),
    );
    expect(t.getSize(field).height, 52);
  });

  testWidgets('hata metni önekli alanda da metin sütunundan başlar', (t) async {
    await _pump(t, error: 'Tutarı yaz.');
    expect(
      t.getTopLeft(find.text('Tutarı yaz.')).dx,
      t.getTopLeft(find.text('Örn. Ayşe')).dx,
    );
    expect(
      t.getTopLeft(find.text('₺')).dx,
      t.getTopLeft(find.text('Örn. Ayşe')).dx,
    );
  });
}
