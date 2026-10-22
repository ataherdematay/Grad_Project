import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class S01WelcomeRoleScreen extends StatefulWidget {
  const S01WelcomeRoleScreen({super.key});

  @override
  State<S01WelcomeRoleScreen> createState() => _S01WelcomeRoleScreenState();
}

class _S01WelcomeRoleScreenState extends State<S01WelcomeRoleScreen> {
  String _selectedRole = 'homeowner'; // 'homeowner' or 'pro'
  String _language = 'TR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Utility Bar: Language Toggle
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LangButton(
                        text: 'TR',
                        isSelected: _language == 'TR',
                        onTap: () => setState(() => _language = 'TR'),
                      ),
                      _LangButton(
                        text: 'EN',
                        isSelected: _language == 'EN',
                        onTap: () => setState(() => _language = 'EN'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Brand Section with Architectural Logo
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.roofing_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BiTadilat',
                        style: AppTypography.headlineMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'EV & USTA AĞI',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Value Proposition Statement
              Text(
                'Evin için doğru ustayı güvenle bul.',
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'İhtiyacını anlat, doğrulanmış ustalardan şeffaf ve garantili teklifler al.',
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              // Trust Badges Bar (Quiet Assurance)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TrustBadgeItem(
                      icon: Icons.verified_user_rounded,
                      label: 'Onaylı Ustalar',
                    ),
                    Container(
                      width: 1.5,
                      height: 16,
                      color: AppColors.borderSubtle,
                    ),
                    _TrustBadgeItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Sabit Fiyat',
                    ),
                    Container(
                      width: 1.5,
                      height: 16,
                      color: AppColors.borderSubtle,
                    ),
                    _TrustBadgeItem(
                      icon: Icons.security_rounded,
                      label: 'İş Garantisi',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Role Selection Title
              Text(
                'NASIL BAŞLAMAK İSTERSİN?',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Role 1: Homeowner (Müşteri)
              _RoleSelectTile(
                title: 'Ev sahibi / Müşteri',
                subtitle: 'Onarım veya yenileme ihtiyacım var.',
                icon: Icons.home_repair_service_rounded,
                isSelected: _selectedRole == 'homeowner',
                onTap: () => setState(() => _selectedRole = 'homeowner'),
              ),
              const SizedBox(height: 12),

              // Role 2: Pro (Usta)
              _RoleSelectTile(
                title: 'Hizmet Veren / Usta',
                subtitle: 'İş fırsatlarını gör, teklif ver ve kazan.',
                icon: Icons.engineering_rounded,
                isSelected: _selectedRole == 'pro',
                onTap: () => setState(() => _selectedRole = 'pro'),
              ),
              const SizedBox(height: 36),

              // Action Button: Devam Et
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedRole == 'homeowner') {
                      context.push('/step/2');
                    } else {
                      context.push('/step/27');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Devam Et',
                        style: AppTypography.bodyLgMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Devam ederek BiTadilat Şartlarını kabul etmiş olursun.',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TrustBadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadgeItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoleSelectTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectTile({
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer.withValues(alpha: 0.1)
                    : AppColors.surfaceDisabled,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primaryContainer : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLgMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.borderSubtle,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
