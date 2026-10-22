import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EscrowGuaranteeCard extends StatelessWidget {
  final String? customTitle;
  final String? customSubtitle;

  const EscrowGuaranteeCard({
    super.key,
    this.customTitle,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emeraldLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emerald.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.emerald,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customTitle ?? 'BiTadilat Güvenli Havuz (Escrow)',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.emeraldDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customSubtitle ??
                      'Ödemeniz doğrudan ustaya gitmez. BDDK lisanslı güvenli havuz hesabında bloke edilir. İş bitip siz onay kodu verene kadar ustanın hesabına aktarılmaz. 30 gün işçilik garantisi altındadır.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.emeraldDark.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
