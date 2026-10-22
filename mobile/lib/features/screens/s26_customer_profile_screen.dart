import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 26: Müşteri Profil & Ayarlar (SCR-C-PROF)
/// Flow: 5. Müşteri Profil & Ayarlar
/// Role: CUSTOMER
class S26CustomerProfileScreen extends StatelessWidget {
  const S26CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
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
        title: Text('Profilim', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Customer Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.surfaceContainer,
                            child: const Text('AY', style: TextStyle(color: AppColors.primaryContainer, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ali Yılmaz', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                              Text('+90 532 450 88 92', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                              Text('Üyelik: Mayıs 2024', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: AppColors.primaryContainer),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 15, color: AppColors.emerald),
                            const SizedBox(width: 4),
                            Text('Doğrulanmış Müşteri', style: AppTypography.labelMd.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text('Kadıköy, İstanbul', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                            Text('AKTİF İŞ', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('1', style: AppTypography.headlineLgMobile.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('Talep', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Sıhhi Tesisat', style: AppTypography.labelSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                            Text('BAŞARILI İŞLEM', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('3', style: AppTypography.headlineLgMobile.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('Tamamlandı', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F3EF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Onaylı Çözüm', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Settings & Account Sections
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Kayıtlı Adreslerim',
                    subtitle: 'Ev: Kadıköy, Caferağa Mah.',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.verified_user,
                    iconColor: AppColors.emerald,
                    iconBg: const Color(0xFFE7F3EF),
                    title: 'BiTadilat Güvence Havuzu',
                    subtitle: 'Ödeme ve güvence sistemi bilgisi',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.notifications_active,
                    title: 'Bildirim Tercihleri',
                    subtitle: 'SMS ve Uygulama İçi',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Yardım & Destek Merkezi',
                    subtitle: 'SSS, canlı destek ve iletişim',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  _buildMenuItem(
                    icon: Icons.lock,
                    title: 'Gizlilik ve KVKK',
                    subtitle: 'Veri güvenliği ve aydınlatma metni',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Switch Role Action Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.construction, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hizmet Profesyoneli Moduna Geç', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('BiTadilat Usta ağına katılın veya usta panelinize geçiş yapın.', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/step/27'),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Usta Modu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Logout Button
            OutlinedButton.icon(
              onPressed: () => context.go('/step/1'),
              icon: const Icon(Icons.logout, size: 20, color: AppColors.alertRed),
              label: Text('Çıkış Yap', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.borderSubtle),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text('BiTadilat v2.4.1 (Güncel Sürüm)', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTab(context, icon: Icons.home, label: 'Ana Sayfa', route: '/step/4'),
            _buildTab(context, icon: Icons.build, label: 'Taleplerim', route: '/step/10'),
            _buildTab(context, icon: Icons.chat, label: 'Mesajlar', route: '/step/19'),
            _buildTab(context, icon: Icons.person, label: 'Profil', route: '/step/26', isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBg,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.canvas,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(icon, size: 20, color: iconColor ?? AppColors.primaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                  Text(subtitle, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: () {
        if (!isActive) context.go(route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.primaryContainer : AppColors.textSecondary,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: isActive ? AppColors.primaryContainer : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
