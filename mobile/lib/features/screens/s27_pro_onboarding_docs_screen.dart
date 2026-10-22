import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 27: Usta Kayıt & Belge Yükleme (SCR-P-ONB)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S27ProOnboardingDocsScreen extends StatefulWidget {
  const S27ProOnboardingDocsScreen({super.key});

  @override
  State<S27ProOnboardingDocsScreen> createState() => _S27ProOnboardingDocsScreenState();
}

class _S27ProOnboardingDocsScreenState extends State<S27ProOnboardingDocsScreen> {
  String _selectedTrade = 'Tesisat';
  final Set<String> _districts = {'Kadıköy', 'Üsküdar', 'Ataşehir'};

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
              context.go('/step/26');
            }
          },
        ),
        title: Column(
          children: [
            Text('Usta Belge Doğrulama', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            Text('Adım 2 / 2: Mesleki Kayıt', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trust Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emerald.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doğrulanmış Usta Güvencesi', style: AppTypography.bodyMdMedium.copyWith(color: const Color(0xFF0D5C45), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'BiTadilat üzerinden ev sahiplerine teklif verebilmek ve güven rozeti kazanmak için belgelerinizi sisteme yükleyin.',
                          style: AppTypography.labelMd.copyWith(color: const Color(0xFF2D5A4C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Uzmanlık ve Bölge
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
                    children: [
                      const Icon(Icons.handyman, size: 18, color: AppColors.primaryContainer),
                      const SizedBox(width: 6),
                      Text('1. UZMANLIK VE HİZMET BÖLGESİ', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Ana Uzmanlık Alanınız', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Tesisat', 'Elektrik', 'Boya', 'Klima'].map((trade) {
                      final isSelected = _selectedTrade == trade;
                      return InkWell(
                        onTap: () => setState(() => _selectedTrade = trade),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryContainer : AppColors.canvas,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
                            ),
                          ),
                          child: Text(
                            isSelected ? '$trade (Seçildi)' : trade,
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 24, color: AppColors.borderSubtle),
                  Text('Hizmet Verdiğiniz İlçeler (İstanbul Anadolu)', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ..._districts.map(
                        (d) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(d, style: AppTypography.labelSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryContainer, style: BorderStyle.solid),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 14, color: AppColors.primaryContainer),
                              const SizedBox(width: 4),
                              Text('İlçe Ekle', style: AppTypography.labelSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: Zorunlu Doğrulama Belgeleri
            Row(
              children: [
                const Icon(Icons.description, size: 18, color: AppColors.primaryContainer),
                const SizedBox(width: 6),
                Text('2. DOĞRULAMA BELGELERİ', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 10),

            // Doc 1: Vergi Levhası (Yüklendi)
            _buildDocCard(
              icon: Icons.check_circle,
              iconColor: AppColors.emerald,
              iconBg: const Color(0xFFE7F3EF),
              title: 'Vergi Levhası / Esnaf Sicil',
              subtitle: 'vergi_levhasi_2024.pdf (Yüklendi)',
              actionText: 'Değiştir',
            ),
            const SizedBox(height: 10),

            // Doc 2: MYK Belgesi
            _buildDocCard(
              icon: Icons.upload_file,
              iconColor: AppColors.textSecondary,
              iconBg: AppColors.canvas,
              title: 'Mesleki Yeterlilik (MYK) / Ustalık',
              subtitle: 'PDF veya görsel yükleyin (Zorunlu)',
              actionText: 'Dosya Seç',
              isButton: true,
            ),
            const SizedBox(height: 10),

            // Doc 3: Adli Sicil
            _buildDocCard(
              icon: Icons.policy,
              iconColor: AppColors.textSecondary,
              iconBg: AppColors.canvas,
              title: 'Adli Sicil Kaydı (e-Devlet)',
              subtitle: 'Son 30 gün içinde barkodlu (Zorunlu)',
              actionText: 'Dosya Seç',
              isButton: true,
            ),
            const SizedBox(height: 14),

            // Review Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yüklenen belgeler BiTadilat idari paneli tarafından en geç 24 saat içinde doğrulanır.',
                      style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
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
        child: ElevatedButton(
          onPressed: () => context.push('/step/28'),
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
              Text('Başvuruyu İncelemeye Gönder', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String actionText,
    bool isButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (isButton)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.canvas,
                foregroundColor: AppColors.onSurface,
                elevation: 0,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(actionText, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold)),
            )
          else
            TextButton(
              onPressed: () {},
              child: Text(actionText, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
