import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class S02PhoneAuthScreen extends StatefulWidget {
  const S02PhoneAuthScreen({super.key});

  @override
  State<S02PhoneAuthScreen> createState() => _S02PhoneAuthScreenState();
}

class _S02PhoneAuthScreenState extends State<S02PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '532 849 20 11');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: RichText(
          text: TextSpan(
            text: 'Bi',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Tadilat',
                style: AppTypography.headlineSm.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Tracker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ADIM 1 / 2',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Güvenlik Onayı',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Segmented Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceDisabled,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryContainer),
                ),
              ),
              const SizedBox(height: 24),

              // Hero Icon & Heading
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: const Icon(
                  Icons.phonelink_lock_rounded,
                  color: AppColors.primaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Telefon numaranı doğrula',
                style: AppTypography.headlineLgMobile.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hesabını korumak ve işinle ilgili güncellemeleri paylaşmak için SMS ile doğrulama yapacağız.',
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Phone Field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cep Telefonu Numaranız',
                    style: AppTypography.bodyMdMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Zorunlu',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🇹🇷', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '+90',
                      style: AppTypography.bodyLgMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 1.5,
                      height: 24,
                      color: AppColors.surfaceDisabled,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTypography.bodyLgMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          hintText: '5XX XXX XX XX',
                        ),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Standart SMS operatör tarifeleri geçerlidir.',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Security Guarantee Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 20,
                      color: AppColors.emerald,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'Güvenli Doğrulama: ',
                          style: AppTypography.bodyMdMedium.copyWith(
                            color: AppColors.emerald,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Telefon numaran ustalarla doğrudan paylaşılmaz. İletişim BiTadilat üzerinden güvenle sağlanır.',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/step/3');
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
                        'Doğrulama kodu gönder',
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
            ],
          ),
        ),
      ),
    );
  }
}
