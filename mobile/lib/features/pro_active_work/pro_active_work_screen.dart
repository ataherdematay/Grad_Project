import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/job_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';

class ProActiveWorkScreen extends StatefulWidget {
  const ProActiveWorkScreen({super.key});

  @override
  State<ProActiveWorkScreen> createState() => _ProActiveWorkScreenState();
}

class _ProActiveWorkScreenState extends State<ProActiveWorkScreen> {
  final _pinController = TextEditingController(text: '849201');
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPinAndRelease(JobRequest job) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    context.read<JobBloc>().add(
          CompleteWorkEvent(
            jobId: job.id,
            pin: _pinController.text.trim(),
            rating: 5,
            review: 'İş usta tarafından tamamlandı ve onaylandı.',
          ),
        );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded,
                size: 64, color: AppColors.emerald),
            const SizedBox(height: 16),
            Text('Hak Ediş Hesabınıza Aktarıldı!',
                style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '₺2.205 net kazanç (komisyon kesintisi sonrası) IBAN hesabınıza tanımlandı.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Tamam',
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/pro/home');
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
        title: const Text('Aktif Randevu & İş Yürütme'),
      ),
      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          final job = state.customerJobs.isNotEmpty
              ? state.customerJobs.first
              : null;

          if (job == null) {
            return Center(
              child: Text('Şu an aktif bir işiniz bulunmamaktadır.',
                  style: AppTypography.bodyMedium),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Active Job Overview
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Müşteri: Ata Atay', style: AppTypography.h3),
                          StatusBadge(status: job.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(job.title, style: AppTypography.h4),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Açık Adres (Havuz Kilitlendi):',
                                    style: AppTypography.label),
                                Text(
                                  '${job.district}, ${job.neighborhood}\n${job.addressLine}',
                                  style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status Management
                Text('Usta Durum Bildirimi', style: AppTypography.h3),
                const SizedBox(height: 8),
                Text(
                  'Müşteriyi bilgilendirmek için durumunuzu güncelleyin.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<JobBloc>().add(UpdateJobStatusEvent(
                              jobId: job.id, status: JobStatus.proEnRoute));
                        },
                        icon: const Icon(Icons.directions_car_rounded, size: 18),
                        label: const Text('Yola Çıktım'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: job.status == JobStatus.proEnRoute
                              ? AppColors.emerald
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<JobBloc>().add(UpdateJobStatusEvent(
                              jobId: job.id, status: JobStatus.inProgress));
                        },
                        icon: const Icon(Icons.build_rounded, size: 18),
                        label: const Text('İşe Başladım'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: job.status == JobStatus.inProgress
                              ? AppColors.emerald
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // PIN Release Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emerald, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_open_rounded,
                              color: AppColors.emerald, size: 24),
                          const SizedBox(width: 10),
                          Text('İş Teslimi & PIN Onayı',
                              style: AppTypography.h4.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emeraldDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Montajı bitirip müşteriye test ettirdikten sonra müşterinin ekranındaki 6 haneli kodu buraya giriniz.',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'PIN Kodunu Onayla & Kazancı Al',
                        variant: ButtonVariant.emerald,
                        icon: Icons.check_circle_rounded,
                        isLoading: _isLoading,
                        onPressed: () => _verifyPinAndRelease(job),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
