import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/category_model.dart';
import '../../core/models/job_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/escrow_guarantee_card.dart';
import '../../core/widgets/status_badge.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(const LoadCustomerJobsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.handyman_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'BiTadilat',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Kadıköy, Moda',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Escrow Guarantee Card
            const EscrowGuaranteeCard(),
            const SizedBox(height: 24),

            // Active Job Card (if any pending offers)
            BlocBuilder<JobBloc, JobState>(
              builder: (context, state) {
                final activeJob = state.activeJob;
                if (activeJob == null) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Aktif Hizmet Talebiniz', style: AppTypography.h3),
                        StatusBadge(status: activeJob.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _ActiveJobPreviewCard(job: activeJob),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // Categories Section
            Text('Hangi Alanda Usta Arıyorsunuz?', style: AppTypography.h3),
            const SizedBox(height: 6),
            Text(
              'Garantili hizmet için ihtiyacınız olan kategoriyi seçin',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: ServiceCategory.defaultCategories.length,
              itemBuilder: (context, index) {
                final cat = ServiceCategory.defaultCategories[index];
                return _CategoryCard(
                  category: cat,
                  onTap: () {
                    context.push('/customer/wizard?category=${cat.id}');
                  },
                );
              },
            ),

            const SizedBox(height: 28),
            // Trust Pillars Banner
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
                  Text('BiTadilat Güvencesi', style: AppTypography.h4),
                  const SizedBox(height: 12),
                  _PillarRow(
                    icon: Icons.verified_user_rounded,
                    title: 'Adli Sicil & Kimlik Onayı',
                    subtitle: 'Tüm ustalarımız e-Devlet ve sabıka kaydı kontrolünden geçer.',
                  ),
                  const SizedBox(height: 10),
                  _PillarRow(
                    icon: Icons.lock_clock_rounded,
                    title: 'Sıfır Riskli Havuz Ödemesi',
                    subtitle: 'İş bitmeden ustanın hesabına tek kuruş aktarılmaz.',
                  ),
                  const SizedBox(height: 10),
                  _PillarRow(
                    icon: Icons.shield_moon_rounded,
                    title: '30 Gün İşçilik Garantisi',
                    subtitle: 'Aynı arıza tekrarlarsa ücretsiz usta yönlendirilir.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobPreviewCard extends StatelessWidget {
  final JobRequest job;
  const _ActiveJobPreviewCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final hasOffers = job.offers.isNotEmpty;
    final isScheduled = job.status == JobStatus.scheduled ||
        job.status == JobStatus.proEnRoute ||
        job.status == JobStatus.inProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${job.district}, ${job.neighborhood}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                job.preferredDate,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (isScheduled) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Randevu Onaylandı',
                        style: AppTypography.label.copyWith(color: AppColors.emerald)),
                    Text('Usta: Ahmet Yılmaz', style: AppTypography.h4),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/customer/active-job/${job.id}');
                  },
                  icon: const Icon(Icons.location_searching_rounded, size: 16),
                  label: const Text('Canlı Takip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(120, 40),
                  ),
                ),
              ],
            ),
          ] else if (hasOffers) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.orangeLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_offer_rounded,
                        color: AppColors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${job.offers.length} Usta Teklif Verdi',
                          style: AppTypography.h4.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '₺2.200\'den başlayan fiyatlar',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push('/customer/offers/${job.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(110, 40),
                  ),
                  child: const Text('İncele'),
                ),
              ],
            ),
          ] else ...[
            Text('Teklifler hazırlanıyor, en geç 15 dk içinde gelecek.',
                style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '₺${category.startingPrice.toInt()}\'den başlar',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillarRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PillarRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.emerald),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
