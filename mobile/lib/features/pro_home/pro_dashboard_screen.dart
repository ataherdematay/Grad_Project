import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/job_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ProDashboardScreen extends StatefulWidget {
  const ProDashboardScreen({super.key});

  @override
  State<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends State<ProDashboardScreen> {
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(const LoadProJobsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BiTadilat Usta Paneli',
                style: AppTypography.h3.copyWith(color: AppColors.primary)),
            Text('Kadıköy Bölgesi • Ahmet Yılmaz',
                style: AppTypography.bodySmall),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text(
                  _isAvailable ? 'Çevrimiçi' : 'Meşgul',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _isAvailable ? AppColors.emerald : AppColors.textMuted,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  activeColor: AppColors.emerald,
                  onChanged: (val) => setState(() => _isAvailable = val),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bu Ayki Net Kazanç',
                          style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.8))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('18 Tamamlanan İş',
                            style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('₺34.850',
                      style: AppTypography.h1.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: 16, color: AppColors.emeraldLight),
                          const SizedBox(width: 6),
                          Text('Havuzda Bekleyen Bakiye:',
                              style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.85))),
                        ],
                      ),
                      Text('₺2.450',
                          style: AppTypography.h4.copyWith(
                              color: AppColors.emeraldLight,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nearby Jobs Feed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yakındaki İş Talepleri', style: AppTypography.h3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Çap: 10 km',
                      style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            BlocBuilder<JobBloc, JobState>(
              builder: (context, state) {
                final jobs = state.availableProJobs;

                if (jobs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'Şu an bölgenizde açık iş ilanı bulunmuyor.',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _ProJobCard(
                      job: job,
                      onTap: () {
                        context.push('/pro/jobs/${job.id}');
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProJobCard extends StatelessWidget {
  final JobRequest job;
  final VoidCallback onTap;

  const _ProJobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '1.4 km Uzaklıkta',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.urgency.labelTr,
                    style: AppTypography.label.copyWith(
                      color: AppColors.orange,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Text('12 dk önce', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Text(job.title, style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              job.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${job.district}, ${job.neighborhood}',
                    style: AppTypography.bodySmall),
                const Spacer(),
                Text(
                  '${job.offers.length} Usta Teklif Verdi',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tahmini Bütçe: ₺1.800 - ₺2.600',
                    style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(110, 36),
                  ),
                  child: const Text('Teklif Ver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
