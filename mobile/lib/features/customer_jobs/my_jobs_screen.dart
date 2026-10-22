import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/job_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/status_badge.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Taleplerim & İşlerim'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.h4.copyWith(fontSize: 14),
          tabs: const [
            Tab(text: 'Aktif Talepler'),
            Tab(text: 'Geçmiş / Tamamlanan'),
          ],
        ),
      ),
      body: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          final activeJobs = state.customerJobs
              .where((j) =>
                  j.status != JobStatus.released &&
                  j.status != JobStatus.cancelled)
              .toList();

          final completedJobs = state.customerJobs
              .where((j) =>
                  j.status == JobStatus.released ||
                  j.status == JobStatus.cancelled)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildJobList(activeJobs, isActive: true),
              _buildJobList(completedJobs, isActive: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobList(List<JobRequest> jobs, {required bool isActive}) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.assignment_outlined : Icons.history_rounded,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(
              isActive ? 'Aktif talebiniz bulunmuyor.' : 'Henüz tamamlanan bir iş yok.',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return InkWell(
          onTap: () {
            if (job.status == JobStatus.pendingOffers) {
              context.push('/customer/offers/${job.id}');
            } else {
              context.push('/customer/active-job/${job.id}');
            }
          },
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(job.id, style: AppTypography.label),
                    StatusBadge(status: job.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(job.title, style: AppTypography.h4),
                const SizedBox(height: 6),
                Text(
                  '${job.district}, ${job.neighborhood} • ${job.preferredDate}',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job.status == JobStatus.pendingOffers
                          ? '${job.offers.length} Usta Teklifi Mevcut'
                          : (job.status == JobStatus.released
                              ? '₺2.450 Tamamlandı'
                              : 'Ahmet Usta Yönlendirildi'),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
