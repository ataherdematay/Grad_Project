import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/job_model.dart';
import '../../core/models/offer_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/escrow_guarantee_card.dart';

class OffersListScreen extends StatelessWidget {
  final String jobId;
  const OffersListScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Gelen Usta Teklifleri'),
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

          final offers = job.offers;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: AppTypography.h4),
                      const SizedBox(height: 4),
                      Text('${job.district}, ${job.neighborhood} • ${job.preferredDate}',
                          style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const EscrowGuaranteeCard(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Alınan Teklifler (${offers.length})',
                        style: AppTypography.h3),
                    Text('En Uygun Fiyatlar',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: offers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return _OfferCard(
                      offer: offer,
                      onAccept: () {
                        context.push('/customer/checkout/${job.id}/${offer.id}');
                      },
                      onViewProfile: () {
                        _showProProfileSheet(context, offer.pro);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProProfileSheet(BuildContext context, ProProfile pro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(pro.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pro.businessName, style: AppTypography.h3),
                      Text(pro.name, style: AppTypography.bodyMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 18, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text('${pro.rating} (${pro.reviewCount} Değerlendirme)',
                              style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text('Resmi Doğrulamalar', style: AppTypography.h4),
            const SizedBox(height: 12),
            _VerificationRow(
                icon: Icons.badge_rounded, title: 'T.C. Kimlik & Adres Doğrulaması'),
            const SizedBox(height: 8),
            _VerificationRow(
                icon: Icons.policy_rounded, title: 'Adli Sicil Kaydı Temiz'),
            const SizedBox(height: 8),
            _VerificationRow(
                icon: Icons.workspace_premium_rounded,
                title: 'Mesleki Yeterlilik Belgesi (MYK) Mevcut'),
            const SizedBox(height: 24),
            AppButton(
              text: 'Kapat',
              variant: ButtonVariant.outline,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _VerificationRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.emerald),
        const SizedBox(width: 10),
        Text(title, style: AppTypography.bodyMedium),
        const Spacer(),
        const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.emerald),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  final ProOffer offer;
  final VoidCallback onAccept;
  final VoidCallback onViewProfile;

  const _OfferCard({
    required this.offer,
    required this.onAccept,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(offer.pro.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.pro.businessName,
                        style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.amber),
                        const SizedBox(width: 4),
                        Text('${offer.pro.rating} (${offer.pro.completedJobs} İş)',
                            style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Profil',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(offer.note, style: AppTypography.bodyMedium),
          const SizedBox(height: 14),
          // Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: offer.pro.badges.map((b) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  b,
                  style: AppTypography.label.copyWith(
                    color: AppColors.emeraldDark,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Toplam Tutar (KDV Dahil)', style: AppTypography.bodySmall),
                  Text('₺${offer.totalAmount.toInt()}', style: AppTypography.price),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.shield_rounded, size: 16),
                label: const Text('Teklifi Kabul Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  minimumSize: const Size(160, 44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
