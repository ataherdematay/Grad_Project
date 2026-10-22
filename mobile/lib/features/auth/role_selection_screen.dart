import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/auth_bloc.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // App Logo & Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'BiTadilat',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Hoş Geldiniz',
                style: AppTypography.h1,
              ),
              const SizedBox(height: 8),
              Text(
                'Lütfen devam etmek için BiTadilat\'ı hangi amaçla kullanacağınızı seçin.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 28),
              // Role Option 1: Customer
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isCustomer = state.selectedRole == UserRole.customer;
                  return _RoleCard(
                    title: 'Hizmet Almak İstiyorum',
                    subtitle:
                        'Evim veya işyerim için güvenilir usta bulup teklif almak ve garantili havuz ödemesiyle çalışmak istiyorum.',
                    icon: Icons.person_search_rounded,
                    isSelected: isCustomer,
                    onTap: () {
                      context
                          .read<AuthBloc>()
                          .add(const SelectRoleEvent(UserRole.customer));
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              // Role Option 2: Pro
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isPro = state.selectedRole == UserRole.pro;
                  return _RoleCard(
                    title: 'Ustayım & Hizmet Veriyorum',
                    subtitle:
                        'Bölgemdeki iş ilanlarına teklif verip yeni müşteriler kazanmak ve hak edişimi güvence altına almak istiyorum.',
                    icon: Icons.engineering_rounded,
                    isSelected: isPro,
                    onTap: () {
                      context
                          .read<AuthBloc>()
                          .add(const SelectRoleEvent(UserRole.pro));
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              // Bottom Action
              AppButton(
                text: 'Devam Et',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  context.push('/phone-auth');
                },
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Devam ederek Kullanım Şartları ve Gizlilik Politikasını kabul etmiş olursunuz.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: AppTypography.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textDisabled,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
