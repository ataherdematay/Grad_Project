import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class S06WizardLocationScreen extends StatefulWidget {
  const S06WizardLocationScreen({super.key});

  @override
  State<S06WizardLocationScreen> createState() =>
      _S06WizardLocationScreenState();
}

class _S06WizardLocationScreenState extends State<S06WizardLocationScreen> {
  final _districtController = TextEditingController(text: 'Kadıköy');
  final _neighborhoodController = TextEditingController(text: 'Caferağa Mah.');
  final _titleController = TextEditingController(
      text: 'Banyo Bataryası Değişimi & Su Kaçağı Tamiri');
  final _descController = TextEditingController(
      text:
          'Lavabo altı fleks borusunda damlama var ve batarya kireçlenmeden ötürü sıkıştı. Yeni batarya montajı ve kaçak tespiti gerekiyor.');

  @override
  void dispose() {
    _districtController.dispose();
    _neighborhoodController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
                    'Talep oluştur • 2 / 4',
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
                      '%50 Tamamlandı',
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
                  value: 0.50,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceDisabled,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer),
                ),
              ),
              const SizedBox(height: 16),

              // Carried-Over Summary Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.plumbing_rounded,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tesisat',
                      style: AppTypography.bodyMdMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Acil Onarım',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.lock_outline_rounded,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('1. Adım', style: AppTypography.labelSm),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'İş nerede ve ne yapılması gerekiyor?',
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Konum ve açıklama, uygun uzmanları daha doğru eşleştirmemize yardımcı olur.',
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 20),

              // Location Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hizmet Konumu',
                        style: AppTypography.bodyLgMedium.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('İl', style: AppTypography.labelMd),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_city_rounded,
                                  size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('İstanbul', style: AppTypography.bodyMdMedium),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Hazır',
                                style: AppTypography.labelSm.copyWith(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('İlçe', style: AppTypography.labelMd),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _districtController,
                      style: AppTypography.bodyMdMedium,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.pin_drop_outlined, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Mahalle / Semt', style: AppTypography.labelMd),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _neighborhoodController,
                      style: AppTypography.bodyMdMedium,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.home_outlined, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Job Description Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İş Açıklaması',
                        style: AppTypography.bodyLgMedium.copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('Talep Başlığı', style: AppTypography.labelMd),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      style: AppTypography.bodyMdMedium,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Detaylı Açıklama (En az 20 karakter)',
                        style: AppTypography.labelMd),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(14),
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
                    context.push('/step/7');
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
