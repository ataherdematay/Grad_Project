import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 25: Şikayet İletildi ve Durum Takibi (SCR-13)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S25DisputeTrackingScreen extends StatelessWidget {
  const S25DisputeTrackingScreen({super.key});

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
        title: Column(
          children: [
            Text('Şikayet Kaydı Alındı', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            Text('Dosya #CMP-104 · İş #504', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: AppColors.primary),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Case Confirmation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF6AD55).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF1E9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text('İnceleme Sırasında', style: AppTypography.labelMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text('Öncelikli Dosya', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Dosyanız Denetim Ekibine Ulaştı', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'İş #504 ile ilgili bildirdiğiniz uyuşmazlık kayda alındı. İki tarafın mesajlaşma kayıtları ve randevu zaman damgaları incelenmektedir.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                  const Divider(height: 20, color: Color(0xFFF6AD55)),
                  Row(
                    children: [
                      const Icon(Icons.verified_user, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text('BiTadilat Güvence Kapsamında', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Case Summary Card (Uyuşmazlık Özeti)
            Container(
              padding: const EdgeInsets.all(16),
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
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.description, size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text('Uyuşmazlık Özeti', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Tüketici Koruması', style: AppTypography.labelSm.copyWith(color: AppColors.infoBlue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  _buildSummaryRow('Dosya No', '#CMP-104'),
                  _buildSummaryRow('Şikayet Edilen Usta', 'Ali Kaya (Ali Usta — Elektrik)'),
                  _buildSummaryRow('Bildirilen Konu', 'Randevuya gelinmedi (Gecikme / İletişimsizlik)'),
                  _buildSummaryRow('Kayıt Tarihi', 'Bugün, 14:48'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mevcut Durum', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF1E9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Moderatör İncelemesinde', style: AppTypography.labelMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. What Happens Next (Adım Adım Süreç)
            Container(
              padding: const EdgeInsets.all(16),
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
                      Text('Süreç Nasıl İlerleyecek?', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                      Text('Ort. 2-4 Saat', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProcessStep(
                    num: '1',
                    title: '1. Sistem Kayıtları Kontrol Edilir',
                    desc: 'Randevu teyidi ve uygulama içi mesaj geçmişi incelenir.',
                    isActive: true,
                  ),
                  _buildProcessStep(
                    num: '2',
                    title: '2. Ustadan Açıklama İstenir',
                    desc: 'Ulaşım veya mücbir sebep durumu için ustaya bildirim iletilir.',
                  ),
                  _buildProcessStep(
                    num: '3',
                    title: '3. Karar ve Bildirim',
                    desc: 'Haklılık tespiti yapıldığında tarafınıza anlık bildirim ve e-posta ile çözüm iletilir.',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/step/4'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Ana Sayfaya Dön', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.push('/step/19'),
              child: Text('Mesajlaşmaya Dön', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required String num,
    required String title,
    required String desc,
    bool isActive = false,
    bool isLast = false,
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
                  color: isActive ? AppColors.primaryContainer : AppColors.surface,
                  border: Border.all(
                    color: isActive ? AppColors.primaryContainer : AppColors.borderSubtle,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: isActive
                              ? AppTypography.bodyLgMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
                              : AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Aktif', style: AppTypography.labelSm.copyWith(color: AppColors.infoBlue)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
