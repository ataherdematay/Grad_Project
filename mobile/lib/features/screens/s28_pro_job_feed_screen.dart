import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 28: Usta Eşleşen Talepler Akışı (SCR-14)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S28ProJobFeedScreen extends StatefulWidget {
  const S28ProJobFeedScreen({super.key});

  @override
  State<S28ProJobFeedScreen> createState() => _S28ProJobFeedScreenState();
}

class _S28ProJobFeedScreenState extends State<S28ProJobFeedScreen> {
  int _selectedFilterTab = 0; // 0: Tümü, 1: Acil, 2: Planlı

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.handyman, color: AppColors.primaryContainer, size: 20),
          ),
        ),
        title: Text('BiTadilat Usta', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [
          // Availability Chip
          InkWell(
            onTap: () => context.push('/step/31'),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Müsait', style: AppTypography.labelMd.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
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
            // Region & Category Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.primaryContainer),
                        const SizedBox(width: 4),
                        Text('Kadıköy, Üsküdar', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary)),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.plumbing, size: 16, color: AppColors.primaryContainer),
                        const SizedBox(width: 4),
                        Text('Tesisat', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('5 km', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Segmented Feed Filter Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEFEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilterTab = 0),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedFilterTab == 0 ? AppColors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Tümü',
                              style: AppTypography.labelMd.copyWith(
                                color: _selectedFilterTab == 0 ? Colors.white : AppColors.textSecondary,
                                fontWeight: _selectedFilterTab == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: _selectedFilterTab == 0 ? Colors.white.withOpacity(0.2) : AppColors.borderSubtle,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('4', style: TextStyle(color: _selectedFilterTab == 0 ? Colors.white : AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilterTab = 1),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedFilterTab == 1 ? AppColors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(
                              'Acil (1)',
                              style: AppTypography.labelMd.copyWith(
                                color: _selectedFilterTab == 1 ? Colors.white : AppColors.textSecondary,
                                fontWeight: _selectedFilterTab == 1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilterTab = 2),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedFilterTab == 2 ? AppColors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Planlı (3)',
                            style: AppTypography.labelMd.copyWith(
                              color: _selectedFilterTab == 2 ? Colors.white : AppColors.textSecondary,
                              fontWeight: _selectedFilterTab == 2 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Feed Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Bölgendeki Eşleşen Talepler', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('4 Talep', style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.tune, size: 16, color: AppColors.primaryContainer),
                    const SizedBox(width: 4),
                    Text('Sırala', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // CARD 1: Urgent Request #501
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondaryContainer, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF1E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, size: 14, color: AppColors.secondary),
                                const SizedBox(width: 4),
                                Text('Acil Onarım', style: AppTypography.labelMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: AppColors.primaryContainer),
                                const SizedBox(width: 2),
                                Text('1.2 km · Moda', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Text('12 dk önce', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Banyo Lavabo Altı Temiz Su Borusu Patlağı',
                    style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temiz su vanası kırıldı ve su sızdırıyor. Acil pirinç vana montajı ve sızdırmazlık testi gerekiyor.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.photo_library, size: 16, color: AppColors.primaryContainer),
                            const SizedBox(width: 6),
                            Text('Müşteri Fotoğrafları (2)', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F3EF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('₺2.000 - ₺2.800 Havuz Güvenceli', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.push('/step/29'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Teklif Hazırla', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // CARD 2: Planned Request
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Planlı İş', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 12, color: AppColors.primaryContainer),
                                const SizedBox(width: 2),
                                Text('2.8 km · Koşuyolu', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text('45 dk önce', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mutfak Bataryası Değişimi ve Filtre Montajı',
                    style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tezgah altı spiral hortum ve batarya yenilemesi yapılacak. Malzeme ev sahibi tarafından temin edildi.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tahmini Bütçe: ₺1.200 - ₺1.600', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600)),
                      OutlinedButton(
                        onPressed: () => context.push('/step/29'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryContainer),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: Text('Teklif Hazırla', style: AppTypography.labelMd.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
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
            _buildProTab(context, icon: Icons.view_list, label: 'Talepler', route: '/step/28', isActive: true),
            _buildProTab(context, icon: Icons.handyman, label: 'İşlerim', route: '/step/32'),
            _buildProTab(context, icon: Icons.chat, label: 'Mesajlar', route: '/step/19'),
            _buildProTab(context, icon: Icons.event_available, label: 'Müsaitlik', route: '/step/31'),
          ],
        ),
      ),
    );
  }

  Widget _buildProTab(
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
