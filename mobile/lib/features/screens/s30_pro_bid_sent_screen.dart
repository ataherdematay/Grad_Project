import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 30: Usta Teklif Gönderildi Onayı (SCR-16)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S30ProBidSentScreen extends StatelessWidget {
  const S30ProBidSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.go('/step/28'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Big Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EF),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.emerald, width: 2),
              ),
              child: const Icon(Icons.check_circle, size: 48, color: AppColors.emerald),
            ),
            const SizedBox(height: 20),

            // Title & Subtitle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Müşterinin Yanıtı Bekleniyor',
                style: AppTypography.labelMd.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Teklifin Başarıyla İletildi!',
              style: AppTypography.headlineLgMobile.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Ev sahibi teklifini inceliyor. Kabul edildiğinde bildirim alacaksın.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Offer Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TEKLİF DETAYI', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
                      Text('Talep #BD-88412', style: AppTypography.labelSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Banyo Lavabo Altı Temiz Su Borusu Patlağı', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Text('Kadıköy, Moda', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('İşçilik Bedeli', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Text('₺1.500', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Malzeme Bedeli', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Text('₺950', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Toplam Tutar (KDV Dahil)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text('₺2.450', style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('İşçilik Garantisi:', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            Text('6 Ay', style: AppTypography.labelSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Zaman Aralığı:', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            Text('Bugün 14:00 – 17:00', style: AppTypography.labelSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/step/28'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Talepler Akışına Dön', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/step/31'),
              child: Text('Müsaitlik Takvimimi Düzenle', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}
