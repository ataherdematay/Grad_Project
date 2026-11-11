import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/guards.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../auth/session.dart';

/// Marka yazısı.
class LogoText extends StatelessWidget {
  const LogoText({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        'BiTadilat',
        style: AppTypography.weight(AppTypography.screenTitle, FontWeight.w800)
            .copyWith(
              fontSize: size,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
      ),
    );
  }
}

/// Marka işareti: teal degrade karo üstünde ev çizgisi ve onay.
///
/// iOS uygulama ikonu ve açılış görseli `tool/brand_assets.py` ile aynı
/// geometriden üretilir; ölçüleri birlikte değiştir.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _BrandMarkPainter()),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  static const _top = Color(0xFF11596B);
  static const _check = Color(0xFF72D9AE);
  static const _viewBox = 32.0;
  static const _glyph = 0.62;
  static const _radius = 0.2237;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & Size.square(s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * _radius)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_top, AppColors.primaryDark],
        ).createShader(rect),
    );
    final unit = s * _glyph / _viewBox;
    final off = (s - s * _glyph) / 2;
    Offset p(double x, double y) => Offset(off + x * unit, off + y * unit);
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * unit
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final house = Path()
      ..addPolygon([
        p(6, 13.5),
        p(16, 5.5),
        p(26, 13.5),
        p(26, 26),
        p(6, 26),
      ], true);
    canvas.drawPath(house, stroke(Colors.white, 2.5));
    final check = Path()
      ..addPolygon([p(11.5, 18), p(14.5, 21), p(20, 14.5)], false);
    canvas.drawPath(check, stroke(_check, 2.75));
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) => false;
}

/// Yığında geri yoksa (derin bağlantı) rota köküne gider; boş yığında `pop`
/// yapılmaz.
class AppBackButton extends ConsumerWidget {
  const AppBackButton({super.key, this.fallback, this.onBack});

  /// Yığında geri yoksa gidilecek rota (varsayılan: modun ana sekmesi).
  final String? fallback;

  /// Verilirse geri tuşunun yerine çalışır (örn. sihirbazda önceki adım).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppIconButton(
      icon: Icons.arrow_back,
      tooltip: AppLocalizations.of(context).back,
      onPressed: () {
        if (onBack != null) {
          onBack!();
        } else if (context.canPop()) {
          context.pop();
        } else {
          final session = ref.read(sessionProvider);
          context.go(
            fallback ??
                (session.isSignedIn ? homeFor(session.me!) : '/welcome'),
          );
        }
      },
    );
  }
}

/// Ortak sayfa iskeleti: kaydırılabilir, en fazla 480 px genişlik, 16 px kenar.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    this.title,
    required this.child,
    this.showBack = true,
  });

  final String? title;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack ? const AppBackButton() : null,
        title: title == null ? null : Text(title!),
      ),
      body: SafeArea(
        // Yatayda ortalanır, dikeyde üstten başlar: kısa içerik ekranın
        // ortasında yüzmez.
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kırmızı çerçeveli hata/uyarı bandı (ekran okuyucuya canlı bölge).
class MessageBanner extends StatelessWidget {
  const MessageBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: const Color(0xFFF8E7E5),
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: AppTypography.label.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TR / EN anahtarı. Seçim kalıcıdır ve çalışma anında uygulanır.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(localeProvider).languageCode;
    return Semantics(
      container: true,
      label: l.languageLabel,
      hint: l.languageSwitchHint,
      // Büyük yazı boyutunda etiketler kırılmaz ("Englis-h"); anahtar
      // sığmazsa bütün olarak küçülür.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SegmentedButton<String>(
          showSelectedIcon: false,
          // Seçili dil ana renkle dolar; turuncu yalnız aciliyet içindir.
          style: SegmentedButton.styleFrom(
            minimumSize: const Size(AppSizes.minTouch, 40),
            tapTargetSize: MaterialTapTargetSize.padded,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            selectedBackgroundColor: AppColors.primary,
            selectedForegroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
            textStyle: AppTypography.label,
          ),
          segments: [
            ButtonSegment(value: 'tr', label: Text(l.languageTurkish)),
            ButtonSegment(value: 'en', label: Text(l.languageEnglish)),
          ],
          selected: {current},
          onSelectionChanged: (s) =>
              ref.read(localeProvider.notifier).set(Locale(s.first)),
        ),
      ),
    );
  }
}

/// Oturum bildirimi (yönetici hesabı, süre doldu) bandı.
class SessionNoticeBanner extends ConsumerWidget {
  const SessionNoticeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(sessionProvider.select((s) => s.notice));
    if (notice == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: MessageBanner(switch (notice) {
        SessionNotice.adminBlocked => l.noticeAdmin,
        SessionNotice.sessionExpired => l.noticeSessionExpired,
        SessionNotice.accountSuspended => l.apiErrorAccountSuspended,
      }),
    );
  }
}

/// `path?next=...`
String withNext(String path, String? next) => next == null
    ? path
    : Uri(path: path, queryParameters: {'next': next}).toString();
