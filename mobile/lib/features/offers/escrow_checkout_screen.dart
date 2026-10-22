import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/escrow_guarantee_card.dart';

class EscrowCheckoutScreen extends StatefulWidget {
  final String jobId;
  final String offerId;

  const EscrowCheckoutScreen({
    super.key,
    required this.jobId,
    required this.offerId,
  });

  @override
  State<EscrowCheckoutScreen> createState() => _EscrowCheckoutScreenState();
}

class _EscrowCheckoutScreenState extends State<EscrowCheckoutScreen> {
  final _cardNumber = TextEditingController(text: '4543 •••• •••• 9821');
  final _expiry = TextEditingController(text: '12/28');
  final _cvv = TextEditingController(text: '349');
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    context.read<JobBloc>().add(
          AcceptOfferEvent(jobId: widget.jobId, offerId: widget.offerId),
        );

    context.go('/customer/payment-success/${widget.jobId}');
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
        title: const Text('Güvenli Havuz Ödemesi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EscrowGuaranteeCard(),
              const SizedBox(height: 20),
              Text('Ödeme Özeti', style: AppTypography.h4),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _PriceRow(label: 'Usta İşçilik Bedeli', value: '₺1.800'),
                    const SizedBox(height: 8),
                    _PriceRow(
                        label: 'Malzeme (ECA Batarya & Çelik Hortum)',
                        value: '₺650'),
                    const SizedBox(height: 8),
                    _PriceRow(label: 'Platform Hizmet Bedeli', value: 'ÜCRETSİZ'),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Toplam Havuz Blokesi', style: AppTypography.h3),
                        Text('₺2.450', style: AppTypography.price),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Kart Bilgileri (256-Bit SSL)', style: AppTypography.h4),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _cardNumber,
                      decoration: const InputDecoration(
                        labelText: 'Kart Numarası',
                        prefixIcon: Icon(Icons.credit_card_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiry,
                            decoration: const InputDecoration(
                              labelText: 'Son Kullanma (AA/YY)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _cvv,
                            decoration: const InputDecoration(
                              labelText: 'CVV / CVC',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: '₺2.450 Güvenli Havuzda Kilitle',
                variant: ButtonVariant.emerald,
                icon: Icons.lock_outline_rounded,
                isLoading: _isLoading,
                onPressed: _processPayment,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Kartınızdan para çekilmez; iş bitip siz onay verene kadar havuzda kilitli kalır.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value,
            style:
                AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
