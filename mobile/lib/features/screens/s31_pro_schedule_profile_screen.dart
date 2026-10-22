import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 31: Usta Profil & Müsaitlik Yönetimi (SCR-17)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S31ProScheduleProfileScreen extends StatefulWidget {
  const S31ProScheduleProfileScreen({super.key});

  @override
  State<S31ProScheduleProfileScreen> createState() => _S31ProScheduleProfileScreenState();
}

class _S31ProScheduleProfileScreenState extends State<S31ProScheduleProfileScreen> {
  bool _isAvailable = true;

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
              context.go('/step/28');
            }
          },
        ),
        title: Column(
          children: [
            Text('Profil ve Müsaitlik', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            Text('Mavi Hat Tesisat (Mehmet Demir)', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F3EF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('Müsait', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Working Status Toggle Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('İş Alma Durumu', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        _isAvailable ? 'Yeni eşleşen talepleri alıyorsunuz' : 'Şu anda yeni teklif almıyorsunuz',
                        style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAvailable,
                    activeColor: AppColors.emerald,
                    onChanged: (val) => setState(() => _isAvailable = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Schedule
            Text('HAFTALIK ÇALIŞMA SAATLERİ', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildScheduleRow('Hafta İçi (Pzt - Cum)', '09:00 – 18:00', isActive: true),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                  _buildScheduleRow('Cumartesi', '09:00 – 15:00', isActive: true),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                  _buildScheduleRow('Pazar', 'Kapalı', isActive: false),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Service Areas
            Text('HİZMET VERİLEN BÖLGELER', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Kadıköy', 'Üsküdar', 'Ataşehir', 'Beşiktaş'].map((district) {
                      return Chip(
                        label: Text(district),
                        backgroundColor: AppColors.canvas,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {},
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Yeni Bölge Ekle'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Verification & Badges
            Text('DOĞRULANMIŞ BELGELER VE ROZETLER', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildBadgeRow('Vergi Levhası', 'Onaylandı'),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                  _buildBadgeRow('Mesleki Yeterlilik (MYK)', 'Onaylandı'),
                  const Divider(height: 16, color: AppColors.borderSubtle),
                  _buildBadgeRow('Adli Sicil Kaydı', 'Onaylandı'),
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil ve müsaitlik ayarlarınız kaydedildi.')),
            );
            context.go('/step/28');
          },
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
              Text('Değişiklikleri Kaydet', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String days, String hours, {bool isActive = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(days, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isActive ? AppColors.canvas : AppColors.surfaceDisabled,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            hours,
            style: AppTypography.labelMd.copyWith(
              color: isActive ? AppColors.primaryContainer : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeRow(String title, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
        Row(
          children: [
            const Icon(Icons.verified, size: 16, color: AppColors.emerald),
            const SizedBox(width: 4),
            Text(status, style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
