import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class EscrowCompletionScreen extends StatefulWidget {
  final String jobId;
  const EscrowCompletionScreen({super.key, required this.jobId});

  @override
  State<EscrowCompletionScreen> createState() => _EscrowCompletionScreenState();
}

class _EscrowCompletionScreenState extends State<EscrowCompletionScreen> {
  final _pinController = TextEditingController(text: '849201');
  final _reviewController = TextEditingController(
      text:
          'Ahmet Usta tam vaktinde geldi, çok temiz ve titiz çalıştı. Garanti belgesini teslim etti, su sızıntısı tamamen kesildi.');
  int _rating = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _completeWork() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    context.read<JobBloc>().add(
          CompleteWorkEvent(
            jobId: widget.jobId,
            pin: _pinController.text.trim(),
            rating: _rating,
            review: _reviewController.text.trim(),
          ),
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 64, color: AppColors.emerald),
            const SizedBox(height: 16),
            Text('İş Başarıyla Tamamlandı!',
                style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '₺2.450 tutarındaki havuz ödemesi Ahmet Usta\'nın hesabına aktarıldı. 30 günlük BiTadilat garantiniz başladı.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Ana Sayfaya Dön',
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/customer/home');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('İş Teslimi & Havuz Çözümü'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.emerald, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Son Adım: İşlem Onayı',
                              style: AppTypography.h4.copyWith(
                                  color: AppColors.emeraldDark,
                                  fontWeight: FontWeight.w800)),
                          Text(
                            'Yapılan işi kontrol ettiyseniz PIN kodunuzu girerek ₺2.450 havuz ödemesini ustaya serbest bırakabilirsiniz.',
                            style: AppTypography.bodySmall.copyWith(
                                color: AppColors.emeraldDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Güvenlik PIN Kodu', style: AppTypography.h4),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTypography.h2.copyWith(
                  letterSpacing: 8,
                  color: AppColors.primary,
                ),
                decoration: const InputDecoration(
                  hintText: '6 Haneli PIN',
                ),
              ),
              const SizedBox(height: 24),
              Text('Usta Değerlendirmesi', style: AppTypography.h4),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      onPressed: () => setState(() => _rating = starIndex),
                      icon: Icon(
                        starIndex <= _rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColors.amber,
                        size: 36,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Text('Görüş & Yorumunuz', style: AppTypography.h4),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Hizmet kalitesi, zamanlama ve temizlik hakkında yorum yazın...',
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                text: 'Onayla & Ödemeyi Ustaya Aktar',
                variant: ButtonVariant.emerald,
                icon: Icons.check_circle_rounded,
                isLoading: _isLoading,
                onPressed: _completeWork,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
