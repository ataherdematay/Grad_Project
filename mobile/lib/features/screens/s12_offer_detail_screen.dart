import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 12: Teklif Detayı & Kapsam
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S12OfferDetailScreen extends StatelessWidget {
  const S12OfferDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/11');
            }
          },
        ),
        title: Text('Teklif Detayı', style: AppTypography.headlineSm.copyWith(color: AppColors.primary)),
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
            // Top Context Card
            Container(
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
                      Wrap(
                        spacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Tesisat', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF1E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, size: 15, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text('Acil onarım', style: AppTypography.labelMd.copyWith(color: AppColors.secondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('İstanbul, Kadıköy', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Talep No: #BD-88412 • Su kaçak tespiti ve onarım',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Professional Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handyman, color: AppColors.primaryContainer, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                            InkWell(
                              onTap: () => context.push('/step/14'),
                              child: Row(
                                children: [
                                  Text(
                                    'Profili görüntüle',
                                    style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer),
                                  ),
                                  const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryContainer),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F3EF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, size: 14, color: AppColors.emerald),
                              const SizedBox(width: 4),
                              Text('Doğrulanmış uzman', style: AppTypography.labelSm.copyWith(color: AppColors.emerald)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: AppColors.orange),
                            const SizedBox(width: 4),
                            Text('4,8', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text('· 126 değerlendirme', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price Summary & Itemized Cost Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Teklif özeti', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                Text('KDV Dahil', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
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
                  // Highlight Total
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Toplam tutar (KDV dahil)', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                            Text('₺2.450', style: AppTypography.headlineLgMobile.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.payments, color: AppColors.primaryContainer, size: 22),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Itemized Breakdown
                  _buildCostRow('İşçilik bedeli', '₺1.500'),
                  const SizedBox(height: 8),
                  _buildCostRow('Malzeme ve sarf parçalar', '₺950'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ek işlem veya servis ücreti', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Yok', style: AppTypography.labelMd.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Toplam', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                        Text('₺2.450', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scope of Work Card (Yapılacak işlemler)
            Text('Yapılacak işlemler', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 8),
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
                  _buildScopeItem(
                    title: 'Kaçak kaynağının tespiti',
                    desc: 'Akustik cihazla boru hattı ve sızıntı noktası belirlenir.',
                  ),
                  const SizedBox(height: 12),
                  _buildScopeItem(
                    title: 'Lavabo altı bağlantılarının kontrolü',
                    desc: 'Gider boruları, fleks hortumlar ve conta sızdırmazlığı incelenir.',
                  ),
                  const SizedBox(height: 12),
                  _buildScopeItem(
                    title: 'Gerekli parça değişimi',
                    desc: 'Aşınmış contalar ve flex hortum yenilenerek test edilir.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Professional Note Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_quote, color: AppColors.primaryContainer, size: 20),
                      const SizedBox(width: 4),
                      Text('Ustanın Teklif Notu', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Text(
                      'Arıza giderilir ve vana bağlantıları kontrol edilir. Ek işlem gerekirse onayın alınmadan çalışma yapılmaz.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Additional Detail Rows
            Container(
              padding: const EdgeInsets.all(12),
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
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_user, color: AppColors.primaryContainer, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hizmet Güvencesi', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            Text('İşçilik garantisi', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('6 ay', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.schedule, color: AppColors.primaryContainer, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Servis Aralığı', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            Text('Tahmini uygunluk', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Bugün 14:00–17:00', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Secondary Interactive Action: Ustaya soru sor
            OutlinedButton.icon(
              onPressed: () => context.push('/step/19'),
              icon: const Icon(Icons.chat, size: 20, color: AppColors.primaryContainer),
              label: Text('Ustaya soru sor', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primaryContainer)),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.borderSubtle),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 80),
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
            Text(
              'Teklifi kabul ettikten sonra uygun randevu zamanını seçebilirsin.',
              style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.push('/step/15'),
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
                  Text('Teklifi kabul et', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildScopeItem({required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFE7F3EF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 18, color: AppColors.emerald),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
              const SizedBox(height: 2),
              Text(desc, style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
