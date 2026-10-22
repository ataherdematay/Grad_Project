import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/auth_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/escrow_guarantee_card.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profilim & Ayarlar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.user;
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user?.avatarUrl ??
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Ata Atay',
                                style: AppTypography.h3),
                            Text(user?.phoneNumber ?? '+90 532 123 45 67',
                                style: AppTypography.bodySmall),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emeraldLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'MÜŞTERİ HESABI',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.emeraldDark,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Role Switch Action Button (Customer <-> Pro switch)
            InkWell(
              onTap: () {
                context.read<AuthBloc>().add(const SwitchRoleEvent());
                context.go('/pro/home');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.swap_horiz_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usta Moduna Geç',
                              style: AppTypography.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                          Text(
                            'İş ilanlarını gör, teklif ver ve kazanmaya başla',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Escrow Guarantee Card
            const EscrowGuaranteeCard(),
            const SizedBox(height: 20),

            // Settings items
            _SettingsGroup(
              title: 'Hesap & Güvenlik',
              items: [
                _SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Kayıtlı Adreslerim',
                  subtitle: 'Kadıköy, Moda Cad. No:42',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Kayıtlı Kartlarım (Escrow)',
                  subtitle: 'Mastercard •••• 9821',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Bildirim Tercihleri',
                  subtitle: 'SMS ve Anlık Bildirimler Açık',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: 'Destek & Yasal',
              items: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'BiTadilat 7/24 Destek',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Gizlilik ve KVKK Politikası',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Çıkış Yap',
                  textColor: AppColors.error,
                  onTap: () {
                    context.read<AuthBloc>().add(const LogoutEvent());
                    context.go('/');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title, style: AppTypography.label),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.bodySmall)
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.textDisabled),
    );
  }
}
