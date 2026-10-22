import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 33: Usta Teslim Bildirimi İletildi (SCR-P-DONE)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S33ProDeliveryDoneScreen extends StatelessWidget {
  const S33ProDeliveryDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () {
            context.go('/step/28');
          },
        ),
        title: Text(
          'İŞ #501 TESLİM EDİLDİ',
          style: AppTypography.labelMd.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(),

              // Big Success Animated Circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3EF),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.emerald, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15107A5B),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle,
                  size: 44,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3EF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Müşterinin Onayı Bekleniyor',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Teslim Talebi Müşteriye İletildi',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'İş tamamlama bildiriminiz ev sahibi Ali Yılmaz\'a iletildi.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Escrow Balance Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06102A34),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GÜVENCE HAVUZU TUTARI',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₺2.450',
                                  style: AppTypography.headlineSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryContainer,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(KDV dahil)',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F3EF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock, size: 14, color: AppColors.emerald),
                              const SizedBox(width: 4),
                              Text(
                                'Havuzda Korumada',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.emerald,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.borderSubtle),

                    // Details
                    _buildDetailRow('İş Kapsamı:', 'Banyo Lavabo Su Sızıntısı'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Hizmet Türü:', 'Tesisat • Acil Onarım'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yüklenen Kanıt:',
                          style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.photo_camera, size: 14, color: AppColors.emerald),
                            const SizedBox(width: 4),
                            Text(
                              '2 Fotoğraf Eklendi',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Auto-release policy notice
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ev sahibi onay verdiğinde veya 48 saat içinde itiraz edilmediğinde bakiye otomatik olarak hesabınıza aktarılacaktır.',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    context.go('/step/28');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Eşleşen Talepler Akışına Dön',
                        style: AppTypography.bodyLgMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.go('/step/31');
                  },
                  child: Text(
                    'Müsaitlik ve Profil Ayarlarını Aç',
                    style: AppTypography.bodyMdMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
