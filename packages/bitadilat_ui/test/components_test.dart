import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpNarrow(WidgetTester tester, Widget child) async {
  AppTypography.useGoogleFonts = false;
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2)),
        child: c!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const long =
      'Çok uzun bir metin: ekran okuyucu ve büyük yazı boyutu için sarılmalı';

  testWidgets('AppButton 320px ve 2x yazıda taşmaz; üç varyant', (t) async {
    await pumpNarrow(
      t,
      const Column(
        children: [
          AppButton(label: long, onPressed: _noop, icon: Icons.add),
          AppButton(
            label: long,
            onPressed: _noop,
            variant: AppButtonVariant.secondary,
          ),
          AppButton(
            label: long,
            onPressed: _noop,
            variant: AppButtonVariant.tertiary,
          ),
          AppButton(label: long, onPressed: _noop, isLoading: true),
        ],
      ),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('AppButton yüksekliği en az 52', (t) async {
    AppTypography.useGoogleFonts = false;
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: AppButton(label: 'Giriş yap', onPressed: _noop),
          ),
        ),
      ),
    );
    expect(
      t.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(52),
    );
  });

  testWidgets('AppButton yüklemede ikinci basışı yok sayar', (t) async {
    AppTypography.useGoogleFonts = false;
    var taps = 0;
    var loading = false;
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppButton(
              label: 'Gönder',
              isLoading: loading,
              onPressed: () {
                taps++;
                setState(() => loading = true);
              },
            ),
          ),
        ),
      ),
    );
    await t.tap(find.byType(FilledButton));
    await t.pump();
    await t.tap(find.byType(FilledButton));
    await t.pump();
    expect(taps, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppTextField 320px/2x taşmaz, hata gösterir, şifre aç-kapa', (
    t,
  ) async {
    await pumpNarrow(
      t,
      const Column(
        children: [
          AppTextField(
            label: long,
            hintText: long,
            errorText: long,
            isPassword: true,
            showPasswordTooltip: 'Şifreyi göster',
            hidePasswordTooltip: 'Şifreyi gizle',
          ),
        ],
      ),
    );
    expect(t.takeException(), isNull);
    expect(find.text(long), findsWidgets);
    expect(find.byTooltip('Şifreyi göster'), findsOneWidget);
    await t.tap(find.byTooltip('Şifreyi göster'));
    await t.pump();
    expect(find.byTooltip('Şifreyi gizle'), findsOneWidget);
    final size = t.getSize(find.byTooltip('Şifreyi gizle'));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('AppTextField yüksekliği en az 52', (t) async {
    AppTypography.useGoogleFonts = false;
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: AppTextField(label: 'E-posta')),
      ),
    );
    expect(
      t.getSize(find.byType(TextFormField)).height,
      greaterThanOrEqualTo(52),
    );
  });

  testWidgets('AppCard taşmaz', (t) async {
    await pumpNarrow(t, const AppCard(onTap: _noop, child: Text(long)));
    expect(t.takeException(), isNull);
  });

  testWidgets('StatusChip ikon ve metin birlikte, taşmaz', (t) async {
    await pumpNarrow(
      t,
      const Column(
        children: [
          StatusChip(
            label: long,
            icon: Icons.schedule,
            tone: StatusTone.urgent,
          ),
          StatusChip(
            label: 'Doğrulandı',
            icon: Icons.verified,
            tone: StatusTone.success,
          ),
        ],
      ),
    );
    expect(t.takeException(), isNull);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
    expect(find.text('Doğrulandı'), findsOneWidget);
  });

  testWidgets('showConfirmDialog taşmaz; onay true, vazgeç false', (t) async {
    AppTypography.useGoogleFonts = false;
    t.view.physicalSize = const Size(320, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    bool? result;
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: c!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showConfirmDialog(
                context,
                title: 'Çıkış yapılsın mı?',
                message: 'Bu işlem geri alınamaz. $long',
                confirmLabel: 'Çıkış yap',
                cancelLabel: 'Vazgeç',
                destructive: true,
              ),
              child: const Text('aç'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('aç'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('Çıkış yapılsın mı?'), findsOneWidget);
    await t.tap(find.text('Vazgeç'));
    await t.pumpAndSettle();
    expect(result, isFalse);

    await t.tap(find.text('aç'));
    await t.pumpAndSettle();
    await t.tap(find.text('Çıkış yap'));
    await t.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('EmptyState ve ErrorState taşmaz; tekrar dene çalışır', (
    t,
  ) async {
    var retried = 0;
    await pumpNarrow(
      t,
      SizedBox(
        height: 600,
        child: Column(
          children: [
            const Expanded(
              child: EmptyState(
                title: long,
                message: long,
                actionLabel: 'Talep oluştur',
                onAction: _noop,
              ),
            ),
            Expanded(
              child: ErrorState(
                title: long,
                message: long,
                retryLabel: 'Tekrar dene',
                onRetry: () => retried++,
              ),
            ),
          ],
        ),
      ),
    );
    expect(t.takeException(), isNull);
    await t.ensureVisible(find.text('Tekrar dene'));
    await t.tap(find.text('Tekrar dene'));
    expect(retried, 1);
  });

  testWidgets('AppIconButton en az 48x48 ve tooltip taşır', (t) async {
    AppTypography.useGoogleFonts = false;
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(
            child: AppIconButton(
              icon: Icons.close,
              tooltip: 'Kapat',
              onPressed: _noop,
            ),
          ),
        ),
      ),
    );
    final size = t.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.byTooltip('Kapat'), findsOneWidget);
  });

  test('token değerleri', () {
    expect(AppColors.primary, const Color(0xFF0F4C5C));
    expect(AppColors.urgency, const Color(0xFFE87525));
    expect(AppRadius.button, 14);
    expect(AppSpacing.lg, 24);
    final theme = AppTheme.light();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.primary);
  });
}

void _noop() {}
