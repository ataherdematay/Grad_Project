import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class S08WizardReviewScreen extends StatelessWidget {
  const S08WizardReviewScreen({super.key});

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
              // Progress Tracker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Talep oluştur • 4 / 4',
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
                      '%100 Tamamlandı',
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
                  value: 1.0,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceDisabled,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Talebini gözden geçir',
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Yayınlamadan önce bilgilerini kontrol edebilirsin.',
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 20),

              // Card 1: Hizmet ve öncelik
              _ReviewCard(
                icon: Icons.plumbing_rounded,
                title: 'Hizmet ve öncelik',
                onEdit: () => context.push('/step/5'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Tesisat',
                        style: AppTypography.bodyMdMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              size: 14, color: AppColors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Acil onarım',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.orange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Card 2: Hizmet konumu
              _ReviewCard(
                icon: Icons.location_on_outlined,
                title: 'Hizmet konumu',
                onEdit: () => context.push('/step/6'),
                child: Text(
                  'İstanbul, Kadıköy (Caferağa Mah.)',
                  style: AppTypography.bodyLgMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Card 3: İş açıklaması
              _ReviewCard(
                icon: Icons.description_outlined,
                title: 'İş açıklaması',
                onEdit: () => context.push('/step/6'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Banyo Bataryası Değişimi & Su Kaçağı Tamiri',
                      style: AppTypography.bodyMdMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lavabo altı fleks borusunda damlama var ve batarya kireçlenmeden ötürü sıkıştı...',
                      style: AppTypography.bodyMd.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Card 4: Fotoğraf
              _ReviewCard(
                icon: Icons.image_outlined,
                title: 'Eklenen fotoğraflar',
                onEdit: () => context.push('/step/7'),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=200',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '1 görsel eklendi',
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Trust Guarantee Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: AppColors.emerald, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Teklif toplamak tamamen ücretsizdir. Beğendiğin teklifi seçip onaylayana kadar hiçbir ücret ödemezsin.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.emeraldDark,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/step/9');
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
                        'Talebi Onayla ve Yayınla',
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

class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onEdit;
  final Widget child;

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
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
                  Icon(icon, size: 18, color: AppColors.primaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.bodyMdMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onEdit,
                child: Text(
                  'Düzenle',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
