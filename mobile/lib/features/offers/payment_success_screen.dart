import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String jobId;
  const PaymentSuccessScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald, width: 2),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 48,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Ödeme Güvenli Havuzda!',
                style: AppTypography.h1.copyWith(color: AppColors.emeraldDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '₺2.450 tutarındaki ödemeniz BDDK lisanslı güvenli havuz hesabında bloke edildi. Usta randevu saatinde adresinizde olacak.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 32),
              // Security Completion PIN Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'İŞ TESLİM ONAY KODUNUZ (PIN)',
                      style: AppTypography.label.copyWith(
                        letterSpacing: 1.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '849 201',
                        style: AppTypography.h1.copyWith(
                          letterSpacing: 6,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bu kodu usta işi tamamen bitirip siz memnun kalana kadar ASLA paylaşmayınız.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Canlı Takip Ekranına Git',
                icon: Icons.navigation_rounded,
                onPressed: () {
                  context.go('/customer/active-job/$jobId');
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Ana Sayfaya Dön',
                variant: ButtonVariant.ghost,
                onPressed: () {
                  context.go('/customer/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
