import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 14: Hizmet Profesyoneli Profili (SCR-05)
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S14ProProfileScreen extends StatelessWidget {
  const S14ProProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/12');
            }
          },
        ),
        title: Text('Usta Profili', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Profile Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.handyman, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mavi Hat Tesisat', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F3EF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, size: 16, color: AppColors.emerald),
                                  const SizedBox(width: 4),
                                  Text('Doğrulanmış uzman', style: AppTypography.labelMd.copyWith(color: AppColors.emerald)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Tesisat ve Bakım Ustası', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Key Metrics Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, size: 16, color: AppColors.orange),
                                  const SizedBox(width: 4),
                                  Text('4,8', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('126 değerlendirme', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.borderSubtle,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: AppColors.emerald),
                                  const SizedBox(width: 4),
                                  Text('214', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('Tamamlanan iş', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.borderSubtle,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.workspace_premium, size: 16, color: AppColors.primaryContainer),
                                  const SizedBox(width: 4),
                                  Text('3 Yıl', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('BiTadilat’ta', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Uzmanlık Alanları Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Uzmanlık alanları', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
                Text('4 Temel Dal', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSkillChip(Icons.water_damage, 'Tesisat'),
                _buildSkillChip(Icons.search, 'Su kaçağı'),
                _buildSkillChip(Icons.countertops, 'Lavabo & batarya'),
                _buildSkillChip(Icons.bathtub, 'Banyo tesisatı'),
              ],
            ),
            const SizedBox(height: 20),

            // Hizmet Bölgeleri Section
            Text('Hizmet bölgeleri', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.primaryContainer, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kadıköy, Üsküdar, Ataşehir ve çevresi', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                        const SizedBox(height: 2),
                        Text('Ortalama varış süresi: Planlanan randevu saatinde', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hakkında Section
            Text('Hakkında', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ev ve iş yeri tesisat onarımı alanında hizmet veriyorum. Arıza tespiti öncesinde iş kapsamını açıkça paylaşır, ek işlem gerekirse çalışma başlamadan onay alırım.',
                    style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, size: 20, color: AppColors.emerald),
                        const SizedBox(width: 8),
                        Text('Şeffaf işçilik ve malzeme ayrımı ilkesi', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Doğrulama Durumu (Verification Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.security, color: AppColors.emerald, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text('Doğrulama durumu', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildVerificationRow('Kimlik doğrulandı'),
                  const SizedBox(height: 8),
                  _buildVerificationRow('Mesleki yeterlilik belgesi incelendi'),
                  const SizedBox(height: 8),
                  _buildVerificationRow('İşletme bilgileri doğrulandı'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.infoBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'BiTadilat uzman denetim ekibi tarafından onaylanmıştır.',
                            style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Müşteri Yorumları Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Müşteri yorumları', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
                Text('Son Değerlendirmeler', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            _buildReviewCard(
              initials: 'A.K.',
              name: 'A.K.',
              rating: '5,0',
              comment: '“Zamanında geldi, sorunu açıkça anlattı ve temiz çalıştı.”',
            ),
            const SizedBox(height: 8),
            _buildReviewCard(
              initials: 'S.D.',
              name: 'S.D.',
              rating: '4,0',
              comment: '“Fiyatlandırma anlaşılırdı, iş planlandığı gibi tamamlandı.”',
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Tüm değerlendirmeleri gör', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer)),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.primaryContainer),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
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
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/step/12');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 20),
                  const SizedBox(width: 8),
                  Text('Teklife dön', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.push('/step/19'),
              icon: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primaryContainer),
              label: Text('Ustaya soru sor', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryContainer),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.emerald),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
      ],
    );
  }

  Widget _buildReviewCard({
    required String initials,
    required String name,
    required String rating,
    required String comment,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.surfaceDisabled,
                    child: Text(initials, style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.orange),
                  const SizedBox(width: 4),
                  Text(rating, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
