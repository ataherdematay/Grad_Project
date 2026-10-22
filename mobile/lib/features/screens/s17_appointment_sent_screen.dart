import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 17: Randevu Talebi İletildi
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S17AppointmentSentScreen extends StatelessWidget {
  const S17AppointmentSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/4');
            }
          },
        ),
        title: Text('BiTadilat', style: AppTypography.headlineSm.copyWith(color: AppColors.primary)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Visual Graphic: Calm Pending State
            Center(
              child: Container(
                width: 96,
                height: 96,
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month, color: AppColors.primaryContainer, size: 36),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.schedule, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Header & Copy Block
            Text(
              'Randevu talebin iletildi',
              style: AppTypography.headlineLgMobile.copyWith(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Mavi Hat Tesisat seçtiğin zaman aralığı için bilgilendirildi.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 18, color: AppColors.infoBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Ustanın onayı bekleniyor',
                      style: AppTypography.labelMd.copyWith(color: AppColors.darkTeal, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: AppColors.emerald),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Kadıköy • Tesisat', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Acil Onarım', style: AppTypography.labelSm.copyWith(color: AppColors.secondary)),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.surfaceDisabled),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('Seçilen zaman', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('Bugün • 14:00 – 16:00', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('Toplam teklif', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          text: '₺2.450 ',
                          style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '(KDV dahil)',
                              style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Process Timeline: Süreç Takibi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Süreç Takibi', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                      Text('ADIM 3 / 4', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineStep(
                    icon: Icons.check,
                    iconBg: const Color(0xFFE7F3EF),
                    iconColor: AppColors.emerald,
                    title: 'Teklif kabul edildi',
                    desc: 'İşçilik ve malzeme onaylandı',
                    isLineActive: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.check,
                    iconBg: const Color(0xFFE7F3EF),
                    iconColor: AppColors.emerald,
                    title: 'Randevu talebi iletildi',
                    desc: 'Zaman aralığı ustaya yönlendirildi',
                    isLineActive: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.schedule,
                    iconBg: AppColors.primary,
                    iconColor: Colors.white,
                    title: 'Usta onayı bekleniyor',
                    desc: 'Usta yanıtı bekleniyor',
                    isCurrent: true,
                    isLineActive: false,
                  ),
                  _buildTimelineStep(
                    icon: Icons.handyman,
                    iconBg: AppColors.surfaceDisabled,
                    iconColor: AppColors.textSecondary,
                    title: 'İş başlangıcı',
                    desc: 'Usta belirtilen adrese gelir',
                    isLast: true,
                    isLineActive: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informative Notice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active, color: AppColors.infoBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Onay geldiğinde bildirim alacaksın', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                        const SizedBox(height: 2),
                        Text(
                          'Randevu kesinleşmeden önce tarih veya saat değişikliği talebinde bulunabilirsin.',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action CTA Area
            ElevatedButton(
              onPressed: () => context.push('/step/18'),
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
                  Text('Talep detayına git', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/step/4'),
              child: Text('Ana sayfaya dön', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
    bool isCurrent = false,
    bool isLast = false,
    bool isLineActive = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLineActive ? AppColors.emerald : AppColors.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: isCurrent
                          ? AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)
                          : AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: isCurrent
                      ? AppTypography.labelMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)
                      : AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
