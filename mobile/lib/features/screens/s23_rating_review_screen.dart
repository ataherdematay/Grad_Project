import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 23: Hizmet Değerlendirme ve Puanlama (SCR-11)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S23RatingReviewScreen extends StatefulWidget {
  const S23RatingReviewScreen({super.key});

  @override
  State<S23RatingReviewScreen> createState() => _S23RatingReviewScreenState();
}

class _S23RatingReviewScreenState extends State<S23RatingReviewScreen> {
  int _rating = 5;
  final Set<String> _selectedTags = {
    'Zamanında geldi',
    'Temiz işçilik',
    'Şeffaf fiyat',
    'Güler yüzlü & Saygılı',
  };
  final List<String> _allTags = [
    'Zamanında geldi',
    'Temiz işçilik',
    'Şeffaf fiyat',
    'Hızlı iletişim',
    'Güler yüzlü & Saygılı',
  ];
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
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
            Text('Hizmeti Değerlendir', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            Text('Mavi Hat Tesisat · Talep #501', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: AppColors.textSecondary),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Specialist Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.plumbing, size: 32, color: AppColors.primaryContainer),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.verified, size: 18, color: AppColors.emerald),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text('Kadıköy', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(width: 6),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.borderSubtle, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('Acil Tesisat Onarımı', style: AppTypography.labelMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.borderSubtle),
                  Text('Mavi Hat Tesisat ile deneyimin nasıldı?', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  // Star Rating Block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      final isFilled = starNum <= _rating;
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          isFilled ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                        ),
                        onPressed: () => setState(() => _rating = starNum),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F3EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sentiment_very_satisfied, size: 18, color: AppColors.emerald),
                        const SizedBox(width: 6),
                        Text(
                          'Harika bir hizmet aldım ($_rating / 5)',
                          style: AppTypography.bodyMdMedium.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Feedback Tag Chips Section
            Text('NELERİ BEĞENDİN?', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceContainerLow : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryContainer.withOpacity(0.4) : AppColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? Icons.check : Icons.add,
                          size: 16,
                          color: isSelected ? AppColors.primaryContainer : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tag,
                          style: AppTypography.bodyMdMedium.copyWith(
                            color: isSelected ? AppColors.primaryContainer : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Written Review Input Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Deneyimini Detaylandır (Opsiyonel)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                Text('Diğer komşulara rehber ol', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Ustanın dakikliği, işçilik kalitesi ve fiyat şeffaflığı hakkında detay ekleyin...',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryContainer),
                ),
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
              const SnackBar(content: Text('Değerlendirmeniz başarıyla kaydedildi! Teşekkür ederiz.')),
            );
            context.go('/step/4');
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
              Text('Değerlendirmeyi Gönder ve Tamamla', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
