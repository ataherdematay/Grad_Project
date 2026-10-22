import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 13: Teklifleri Karşılaştır (Matris Görünümü)
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S13OffersCompareMatrixScreen extends StatelessWidget {
  const S13OffersCompareMatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryContainer, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/11');
            }
          },
        ),
        title: Text('Teklifleri Karşılaştır', style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
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
            // Request Context Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.build, size: 15, color: AppColors.infoBlue),
                      const SizedBox(width: 4),
                      Text('Tesisat • Acil onarım', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 15, color: AppColors.primaryContainer),
                      const SizedBox(width: 4),
                      Text('İstanbul, Kadıköy', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Header & Scope Description
            Text('2 teklifi karşılaştır', style: AppTypography.headlineLgMobile.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(
              'Karar vermeden önce fiyat, kapsam, uygunluk ve uzman deneyimini birlikte incele.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Filter Control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, size: 16, color: AppColors.primaryContainer),
                      const SizedBox(width: 4),
                      Text('Teklifleri düzenle (2/3)', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer)),
                    ],
                  ),
                ),
                Text('Eşit şartlarda karşılaştırma', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),

            // Matrix Container
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  // Provider Header Row (2 Columns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildProviderHeader(
                          name: 'Mavi Hat Tesisat',
                          subtitle: 'Kıdemli Usta',
                          rating: '4,8',
                          reviews: '(126)',
                          icon: Icons.handyman,
                        ),
                      ),
                      Container(width: 1, height: 120, color: AppColors.borderSubtle),
                      Expanded(
                        child: _buildProviderHeader(
                          name: 'Kaya Sıhhi Tesisat',
                          subtitle: 'Uzman Ekip',
                          rating: '4,9',
                          reviews: '(84)',
                          icon: Icons.plumbing,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),

                  // Row 1: Total Price
                  _buildMatrixRow(
                    title: 'TOPLAM TUTAR (KDV DAHİL)',
                    col1: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₺2.450', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        Text('Sabit fiyat teklifi', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    col2: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₺2.200', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        Text('Sabit fiyat teklifi', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    bgColor: AppColors.surfaceContainerLow.withOpacity(0.4),
                  ),

                  // Row 2: Labor Cost
                  _buildMatrixRow(
                    title: 'İşçilik Bedeli',
                    col1: Text('₺1.500', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    col2: Text('₺1.400', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),

                  // Row 3: Material Cost
                  _buildMatrixRow(
                    title: 'Malzeme Bedeli',
                    col1: Text('₺950', style: AppTypography.bodyMd.copyWith(color: AppColors.primary)),
                    col2: Text('₺800', style: AppTypography.bodyMd.copyWith(color: AppColors.primary)),
                    bgColor: AppColors.surfaceContainerLow.withOpacity(0.2),
                  ),

                  // Row 4: Extra Costs
                  _buildMatrixRow(
                    title: 'Ek Ücret / Sürpriz Masraf',
                    col1: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.tertiaryContainer),
                        const SizedBox(width: 4),
                        Text('Yok', style: AppTypography.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    col2: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.tertiaryContainer),
                        const SizedBox(width: 4),
                        Text('Yok', style: AppTypography.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                  // Row 5: Warranty
                  _buildMatrixRow(
                    title: 'İşçilik Garantisi',
                    col1: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('6 ay usta garantili', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                    ),
                    col2: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('3 ay usta garantili', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                    ),
                    bgColor: AppColors.surfaceContainerLow.withOpacity(0.2),
                  ),

                  // Row 6: Earliest Availability
                  _buildMatrixRow(
                    title: 'Tahmini Başlama / Uygunluk',
                    col1: Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: AppColors.infoBlue),
                        const SizedBox(width: 4),
                        Flexible(child: Text('Bugün 14:00–17:00', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary))),
                      ],
                    ),
                    col2: Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: AppColors.infoBlue),
                        const SizedBox(width: 4),
                        Flexible(child: Text('Yarın sabah', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary))),
                      ],
                    ),
                  ),

                  // Row 7: Scope Detail
                  _buildMatrixRow(
                    title: 'Yapılacak İşlem & Kapsam',
                    col1: Text(
                      'Sızıntı tespiti, contaların ve boru dirseklerinin yenilenmesi, basınç testi.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    col2: Text(
                      'Boru ek yeri değişimi, sızdırmazlık macunu ve genel vana kontrolü.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    bgColor: AppColors.surfaceContainerLow.withOpacity(0.2),
                  ),

                  // Action Buttons Row
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/step/12'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Teklifi incele', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                                const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryContainer),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/step/12'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderSubtle),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Teklifi incele', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                                const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryContainer),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trust Guarantee Banner
            Container(
              padding: const EdgeInsets.all(14),
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.verified_user, size: 18, color: AppColors.infoBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BiTadilat Güvenli İnceleme', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          'Teklifi kabul etmeden önce herhangi bir ücret yansıtılmaz. Usta adresinize gelene kadar tüm detayları mesajla netleştirebilirsiniz.',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderHeader({
    required String name,
    required String subtitle,
    required String rating,
    required String reviews,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, color: AppColors.primaryContainer, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary), overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 13, color: AppColors.tertiaryContainer),
                const SizedBox(width: 4),
                Text('Doğrulanmış uzman', style: AppTypography.labelSm.copyWith(color: AppColors.tertiaryContainer, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.orange),
              const SizedBox(width: 4),
              Text(rating, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(reviews, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixRow({
    required String title,
    required Widget col1,
    required Widget col2,
    Color? bgColor,
  }) {
    return Container(
      color: bgColor ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: col1),
              const SizedBox(width: 14),
              Expanded(child: col2),
            ],
          ),
        ],
      ),
    );
  }
}
