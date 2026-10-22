import 'package:flutter_test/flutter_test.dart';
import 'package:bitadilat_mobile/main.dart';

void main() {
  testWidgets('BiTadilat App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BiTadilatApp());
    await tester.pumpAndSettle();

    // Verify that the title and role selection options are rendered.
    expect(find.text('BiTadilat'), findsWidgets);
    expect(find.text('Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Hizmet Almak İstiyorum'), findsOneWidget);
    expect(find.text('Ustayım & Hizmet Veriyorum'), findsOneWidget);
  });
}
