import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 15: Teklif Kabul Onayı (Güvence Havuzu)
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S15EscrowCheckoutScreen extends StatelessWidget {
  const S15EscrowCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Background content (Dimmed Offer Summary)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Context
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Talep No: #BD-88412 • Su kaçak tespiti ve onarım', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.handyman, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium),
                          Text('4,8 · 126 değerlendirme', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modal Backdrop Tint
          Container(
            color: const Color(0x990A1A22),
          ),

          // Bottom Sheet Confirmation Dialog
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20, top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0C8CB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  // Header Prompt
                  Text(
                    'Bu teklifi kabul etmek istiyor musun?',
                    style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Teklif kabul edildiğinde diğer teklif sahiplerine bilgi verilir. Randevu zamanını bir sonraki adımda seçebilirsin.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Compact Summary Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F3EF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, size: 13, color: AppColors.emerald),
                                  const SizedBox(width: 4),
                                  Text('Doğrulanmış', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Tesisat • Acil onarım', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                        ),
                        const Divider(height: 20, color: AppColors.borderSubtle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Toplam Tutar', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                            RichText(
                              text: TextSpan(
                                text: '₺2.450 ',
                                style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.verified_user, size: 16, color: AppColors.emerald),
                            const SizedBox(width: 6),
                            Text('İşçilik garantisi: 6 ay', style: AppTypography.labelMd.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Informational Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, size: 18, color: AppColors.infoBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ek işlem gerekirse çalışma başlamadan önce onayın alınır.',
                            style: AppTypography.labelMd.copyWith(color: AppColors.infoBlue, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Area
                  ElevatedButton(
                    onPressed: () => context.push('/step/16'),
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
                        Text('Teklifi kabul et', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/step/12');
                      }
                    },
                    child: Text('Vazgeç', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
