import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/offer_model.dart';
import '../../core/repositories/mock_job_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class ProJobDetailScreen extends StatefulWidget {
  final String jobId;
  const ProJobDetailScreen({super.key, required this.jobId});

  @override
  State<ProJobDetailScreen> createState() => _ProJobDetailScreenState();
}

class _ProJobDetailScreenState extends State<ProJobDetailScreen> {
  final _laborController = TextEditingController(text: '1800');
  final _materialsController = TextEditingController(text: '650');
  final _noteController = TextEditingController(
      text:
          'ECA marka pirinç döküm batarya ve çelik örgülü fleks hortum kullanılacaktır. 12 ay koşulsuz sızdırmazlık garantilidir.');
  int _warrantyMonths = 12;
  bool _isLoading = false;

  @override
  void dispose() {
    _laborController.dispose();
    _materialsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final labor = double.tryParse(_laborController.text) ?? 0;
    final mat = double.tryParse(_materialsController.text) ?? 0;
    return labor + mat;
  }

  void _submitBid() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final newOffer = ProOffer(
      id: 'off-${DateTime.now().millisecondsSinceEpoch}',
      jobId: widget.jobId,
      pro: MockJobRepository.proAhmet,
      laborAmount: double.tryParse(_laborController.text) ?? 1800,
      materialsAmount: double.tryParse(_materialsController.text) ?? 650,
      totalAmount: _totalAmount,
      warrantyMonths: _warrantyMonths,
      estimatedArrivalMinutes: 45,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    context.read<JobBloc>().add(
          SubmitProBidEvent(jobId: widget.jobId, offer: newOffer),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.emerald,
        content: Text('Teklifiniz müşteriye başarıyla iletildi!'),
      ),
    );
    context.pop();
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
        title: const Text('İş Detayı & Teklif Formu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Details Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Banyo Bataryası Değişimi & Su Kaçağı Tamiri',
                      style: AppTypography.h3),
                  const SizedBox(height: 6),
                  Text('Kadıköy, Caferağa Mah. • 1.4 km uzaklıkta',
                      style: AppTypography.bodySmall),
                  const SizedBox(height: 12),
                  Text(
                    'Lavabo altı fleks borusunda damlama var ve batarya kireçlenmeden ötürü sıkıştı. Yeni batarya montajı ve kaçak tespiti gerekiyor.',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Teklifinizi Belirleyin', style: AppTypography.h3),
            const SizedBox(height: 8),
            Text(
              'İşçilik ve malzeme maliyetinizi şeffaf şekilde ayırarak müşteriye güven verin.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
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
                    controller: _laborController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'İşçilik Bedeli (₺)',
                      prefixIcon: Icon(Icons.handyman_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _materialsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Malzeme Bedeli (₺)',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Müşteriye Not / Garanti Kapsamı',
                      hintText: 'Kullanılacak parça kalitesi ve garanti...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Toplam Teklifiniz:', style: AppTypography.h4),
                      Text('₺${_totalAmount.toInt()}', style: AppTypography.price),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Teklifi Müşteriye İlet',
              variant: ButtonVariant.primary,
              icon: Icons.send_rounded,
              isLoading: _isLoading,
              onPressed: _submitBid,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
