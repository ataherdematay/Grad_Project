import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class S05WizardCategoryScreen extends StatefulWidget {
  const S05WizardCategoryScreen({super.key});

  @override
  State<S05WizardCategoryScreen> createState() =>
      _S05WizardCategoryScreenState();
}

class _S05WizardCategoryScreenState extends State<S05WizardCategoryScreen> {
  String _selectedCategory = 'tesisat';
  String _selectedPriority = 'acil';

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'tesisat',
      'name': 'Tesisat',
      'desc': 'Su, kaçak, tıkanıklık',
      'icon': Icons.plumbing_rounded,
    },
    {
      'id': 'elektrik',
      'name': 'Elektrik',
      'desc': 'Sigorta, hat, montaj',
      'icon': Icons.bolt_rounded,
    },
    {
      'id': 'boya',
      'name': 'Boya & Badana',
      'desc': 'İç cephe, alçı tamir',
      'icon': Icons.format_paint_rounded,
    },
    {
      'id': 'klima',
      'name': 'Klima',
      'desc': 'Bakım, gaz, arıza',
      'icon': Icons.mode_fan_off_rounded,
    },
    {
      'id': 'banyo',
      'name': 'Banyo Yenileme',
      'desc': 'Fayans, duşakabin',
      'icon': Icons.shower_rounded,
    },
    {
      'id': 'mutfak',
      'name': 'Mutfak Yenileme',
      'desc': 'Tezgah, dolap montaj',
      'icon': Icons.kitchen_rounded,
    },
    {
      'id': 'marangoz',
      'name': 'Marangoz & Montaj',
      'desc': 'Kapı, kilit, mobilya',
      'icon': Icons.handyman_rounded,
    },
    {
      'id': 'onarim',
      'name': 'Küçük Onarım',
      'desc': 'Genel ev tamiratı',
      'icon': Icons.build_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'BiTadilat',
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Talep oluştur • 1 / 4',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '%25 Tamamlandı',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceDisabled,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Hangi hizmete ihtiyacın var?',
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Doğru ustaları eşleştirebilmemiz için hizmet türünü ve önceliğini seç.',
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 18),

              // Search Bar
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hizmet ara (ör: batarya, sigorta, boya)',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Grid Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hizmet Türü',
                      style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w700)),
                  Text('8 Kategori', style: AppTypography.labelSm),
                ],
              ),
              const SizedBox(height: 12),

              // 8 Category Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['id'];
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = cat['id']),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 2),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryContainer.withValues(alpha: 0.1)
                                  : AppColors.surfaceDisabled,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              color: isSelected
                                  ? AppColors.primaryContainer
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cat['name'] as String,
                                  style: AppTypography.bodyMdMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  cat['desc'] as String,
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Priority Section
              Text('Öncelik Durumu',
                  style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _PriorityRow(
                id: 'acil',
                title: 'Acil Onarım',
                subtitle: 'Bugün / En kısa sürede müdahale gerekir',
                badgeText: 'Bugün',
                badgeColor: AppColors.orange,
                isSelected: _selectedPriority == 'acil',
                onTap: () => setState(() => _selectedPriority = 'acil'),
              ),
              const SizedBox(height: 10),
              _PriorityRow(
                id: 'planli',
                title: 'Planlı Tadilat',
                subtitle: 'Bu hafta içinde uygun bir günde yapılsın',
                badgeText: 'Bu Hafta',
                badgeColor: AppColors.primaryContainer,
                isSelected: _selectedPriority == 'planli',
                onTap: () => setState(() => _selectedPriority = 'planli'),
              ),
              const SizedBox(height: 10),
              _PriorityRow(
                id: 'esnek',
                title: 'Esnek Zamanlı',
                subtitle: 'Fiyat ve usta uygunluğuna göre karar vereceğim',
                badgeText: 'Esnek',
                badgeColor: AppColors.textSecondary,
                isSelected: _selectedPriority == 'esnek',
                onTap: () => setState(() => _selectedPriority = 'esnek'),
              ),
              const SizedBox(height: 36),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/step/6');
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityRow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
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
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMdMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTypography.labelSm.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
