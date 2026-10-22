import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/auth_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '532 123 45 67');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Telefon Numaranız',
                style: AppTypography.h1,
              ),
              const SizedBox(height: 8),
              Text(
                'Giriş yapmak ve işlem güvenliğinizi sağlamak için cep telefonu numaranıza SMS ile doğrulama kodu göndereceğiz.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 32),
              // Phone Input Field with TR prefix
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('🇹🇷', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            '+90',
                            style: AppTypography.h4.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTypography.h4.copyWith(
                          letterSpacing: 1.0,
                        ),
                        decoration: const InputDecoration(
                          hintText: '5XX XXX XX XX',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: AppColors.emerald,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Numaranız hiçbir zaman üçüncü taraflarla paylaşılmaz.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.emeraldDark,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.otpSent) {
                    context.push('/otp-verify');
                  }
                },
                builder: (context, state) {
                  return AppButton(
                    text: 'Doğrulama Kodu Gönder',
                    isLoading: state.isLoading,
                    icon: Icons.sms_outlined,
                    onPressed: () {
                      final raw = _phoneController.text.trim();
                      context
                          .read<AuthBloc>()
                          .add(SendOtpEvent('+90 $raw'));
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
