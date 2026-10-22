import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/job_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/status_badge.dart';

class JobTrackingScreen extends StatelessWidget {
  final String jobId;
  const JobTrackingScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/customer/home'),
        ),
        title: const Text('Canlı İş & Usta Takibi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {
              context.push('/customer/chat/$jobId');
            },
          ),
        ],
      ),
      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          final job = state.customerJobs.firstWhere(
            (j) => j.id == jobId,
            orElse: () => state.customerJobs.isNotEmpty
                ? state.customerJobs.first
                : JobRequest(
                    id: 'job-84920',
                    customerId: 'u-101',
                    categoryId: 'plumbing',
                    title: 'Banyo Bataryası Değişimi',
                    description: '',
                    urgency: UrgencyLevel.thisWeek,
                    preferredDate: '',
                    preferredTimeSlot: '',
                    city: 'İstanbul',
                    district: 'Kadıköy',
                    neighborhood: 'Moda',
                    addressLine: '',
                    photoUrls: const [],
                    createdAt: DateTime.now(),
                  ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Pro Info Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ahmet Yılmaz (Usta)', style: AppTypography.h3),
                            Text('Mavi Hat Su Tesisatı',
                                style: AppTypography.bodySmall),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 16, color: AppColors.amber),
                                const SizedBox(width: 4),
                                Text('4.9 (248 İş)',
                                    style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/customer/chat/$jobId'),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          foregroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive QA Simulation Banner (helps user & advisors test transitions!)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Simülasyon / Test Araç Çubuğu',
                              style: AppTypography.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800)),
                          StatusBadge(status: job.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aşağıdaki butonlarla usta durumunu canlı simüle edebilirsiniz:',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SimButton(
                            label: 'Yola Çıktı',
                            isActive: job.status == JobStatus.proEnRoute,
                            onTap: () {
                              context.read<JobBloc>().add(UpdateJobStatusEvent(
                                  jobId: job.id, status: JobStatus.proEnRoute));
                            },
                          ),
                          _SimButton(
                            label: 'İşe Başladı',
                            isActive: job.status == JobStatus.inProgress,
                            onTap: () {
                              context.read<JobBloc>().add(UpdateJobStatusEvent(
                                  jobId: job.id, status: JobStatus.inProgress));
                            },
                          ),
                          _SimButton(
                            label: 'İş Bitti',
                            isActive: job.status == JobStatus.completed,
                            onTap: () {
                              context.read<JobBloc>().add(UpdateJobStatusEvent(
                                  jobId: job.id, status: JobStatus.completed));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Süreç Aşamaları', style: AppTypography.h3),
                const SizedBox(height: 16),

                // Timeline Steps
                _TimelineStep(
                  title: 'Randevu Onaylandı & Havuz Kilitlendi',
                  subtitle:
                      '₺2.450 tutarındaki ödeme güvenli havuz hesabına alındı.',
                  isDone: true,
                  isCurrent: job.status == JobStatus.scheduled,
                ),
                _TimelineStep(
                  title: 'Usta Yola Çıktı',
                  subtitle: job.status == JobStatus.proEnRoute
                      ? 'Ahmet Usta yolda. Tahmini varış: 15 dakika.'
                      : 'Randevu saatinde usta adrese hareket edecek.',
                  isDone: job.status == JobStatus.proEnRoute ||
                      job.status == JobStatus.inProgress ||
                      job.status == JobStatus.completed ||
                      job.status == JobStatus.released,
                  isCurrent: job.status == JobStatus.proEnRoute,
                ),
                _TimelineStep(
                  title: 'İşlem Devam Ediyor',
                  subtitle: job.status == JobStatus.inProgress
                      ? 'Usta adreste. Montaj ve sızdırmazlık testi yapılıyor.'
                      : 'Usta ulaştığında montaj başlayacaktır.',
                  isDone: job.status == JobStatus.inProgress ||
                      job.status == JobStatus.completed ||
                      job.status == JobStatus.released,
                  isCurrent: job.status == JobStatus.inProgress,
                ),
                _TimelineStep(
                  title: 'İş Teslimi & Havuz Serbest Bırakma',
                  subtitle:
                      'İşi kontrol edin. Memnun kaldıysanız PIN kodunu teyit ederek havuzu çözün.',
                  isDone: job.status == JobStatus.released,
                  isCurrent: job.status == JobStatus.completed,
                  isLast: true,
                ),

                const SizedBox(height: 28),
                // Action Buttons
                if (job.status == JobStatus.completed ||
                    job.status == JobStatus.inProgress) ...[
                  AppButton(
                    text: 'İşi Onayla & Havuz Ödemesini Çöz',
                    variant: ButtonVariant.emerald,
                    icon: Icons.verified_rounded,
                    onPressed: () {
                      context.push('/customer/complete/${job.id}');
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                AppButton(
                  text: 'Usta ile Canlı Mesajlaş',
                  variant: ButtonVariant.outline,
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () {
                    context.push('/customer/chat/${job.id}');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SimButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SimButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isCurrent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.emerald
        : (isCurrent ? AppColors.primary : AppColors.border);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.emerald : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.emerald : AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h4.copyWith(
                      color: isDone || isCurrent
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight:
                          isCurrent ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDone || isCurrent
                          ? AppColors.textSecondary
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
