import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 11: Gelen Teklifler Listesi (SCR-04)
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S11OffersListScreen extends StatelessWidget {
  const S11OffersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryContainer),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/10');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_repair_service, size: 20, color: AppColors.primaryContainer),
            const SizedBox(width: 6),
            Text('BiTadilat', style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer)),
          ],
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryContainer),
                onPressed: () {},
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Request Context Card (Compact)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TALEP ÖZETİ',
                        style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Talep No: #TD-84920',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildChip(Icons.plumbing, 'Tesisat', AppColors.surface, AppColors.primaryContainer),
                      _buildChip(Icons.bolt, 'Acil onarım', AppColors.secondaryFixed, AppColors.secondary),
                      _buildChip(Icons.location_on, 'İstanbul, Kadıköy', AppColors.surface, AppColors.textSecondary, iconColor: AppColors.infoBlue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Screen Title & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '3 teklif geldi',
                  style: AppTypography.headlineLgMobile.copyWith(color: AppColors.onSurface),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDisabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Tümü Aktif',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Teklifleri işçilik, malzeme, tarih ve uzman deneyimine göre karşılaştır.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),

            // Sort & Filter Controls + Compare Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert, size: 18, color: AppColors.primaryContainer),
                      const SizedBox(width: 4),
                      Text('Önerilen sıralama', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, size: 18, color: AppColors.outline),
                    ],
                  ),
                ),
                const Spacer(),
                Text('3 sonuç', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: const Icon(Icons.tune, size: 18, color: AppColors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Compare CTA Banner
            InkWell(
              onTap: () => context.push('/step/13'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryContainer.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.compare_arrows, color: AppColors.primaryContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Teklifleri Yan Yana Karşılaştır (Matris Görünümü)',
                        style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primaryContainer, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Informative Transparency Micro-Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.infoBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Teklifleri dilediğin gibi değerlendirebilirsin. Kabul etmeden önce herhangi bir ücret yansımaz.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Offer Card 1: Mavi Hat Tesisat
            _buildOfferCard(
              context,
              name: 'Mavi Hat Tesisat',
              rating: '4,8',
              reviewCount: '126',
              timeText: 'Bugün 14:00 - 17:00',
              timeIcon: Icons.schedule,
              price: '₺2.450',
              laborCost: '₺1.500',
              materialCost: '₺950',
              quote: '“Lavabo gideri ve vana bağlantılarını kontrol edip conta yenilemesini garantili yaparız.”',
              avatarIcon: Icons.handyman,
              onTap: () => context.push('/step/12'),
            ),
            const SizedBox(height: 16),

            // Offer Card 2: Kaya Sıhhi Tesisat
            _buildOfferCard(
              context,
              name: 'Kaya Sıhhi Tesisat',
              rating: '4,9',
              reviewCount: '84',
              timeText: 'Yarın sabah (09:00)',
              timeIcon: Icons.event,
              price: '₺2.200',
              laborCost: '₺1.400',
              materialCost: '₺800',
              quote: '“Kadıköy bölgesindeyim, sızıntı tespiti ve orijinal yedek parça montajı dahil fiyattır.”',
              avatarIcon: Icons.plumbing,
              onTap: () => context.push('/step/12'),
            ),
            const SizedBox(height: 16),

            // Offer Card 3: Usta Eller Tesisat
            _buildOfferCard(
              context,
              name: 'Usta Eller Tesisat',
              rating: '4,7',
              reviewCount: '62',
              timeText: 'Bugün 18:00',
              timeIcon: Icons.schedule,
              price: '₺2.600',
              laborCost: '₺1.700',
              materialCost: '₺900',
              quote: '“Robot cihazla kırmadan sızıntı tespiti ve termal kamera kontrolü yapılır.”',
              avatarIcon: Icons.home_repair_service,
              onTap: () => context.push('/step/12'),
            ),
            const SizedBox(height: 20),

            // Bottom Clarification Footnote
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 16, color: AppColors.tertiaryContainer),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'BiTadilat Güvencesi: Onaylamadığın sürece teklif bağlayıcı değildir.',
                    style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color bg, Color textColor, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor ?? textColor),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelMd.copyWith(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String name,
    required String rating,
    required String reviewCount,
    required String timeText,
    required IconData timeIcon,
    required String price,
    required String laborCost,
    required String materialCost,
    required String quote,
    required IconData avatarIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Artisan Header Info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(avatarIcon, color: AppColors.primaryContainer, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 14, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Text(
                          'Doğrulanmış uzman',
                          style: AppTypography.labelMd.copyWith(color: AppColors.emerald),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ratings & Schedule Meta
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.orange),
                    const SizedBox(width: 4),
                    Text(rating, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text('($reviewCount değerlendirme)', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                Row(
                  children: [
                    Icon(timeIcon, size: 15, color: AppColors.primaryContainer),
                    const SizedBox(width: 4),
                    Text(timeText, style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Transparent Breakdown Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ŞEFFAF MALİYET',
                      style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    Text(
                      price,
                      style: AppTypography.headlineMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('İşçilik: ', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                        Text(laborCost, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.outline, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Malzeme: ', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                        Text(materialCost, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quote Note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  quote,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Card Action Button
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.borderSubtle),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Teklifi İncele',
                  style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primaryContainer),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.primaryContainer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
