import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class S10MyRequestsScreen extends StatefulWidget {
  const S10MyRequestsScreen({super.key});

  @override
  State<S10MyRequestsScreen> createState() => _S10MyRequestsScreenState();
}

class _S10MyRequestsScreenState extends State<S10MyRequestsScreen>
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
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.go('/step/4'),
        ),
        title: Text(
          'Taleplerim',
          style: AppTypography.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryContainer,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryContainer,
          indicatorWeight: 3,
          labelStyle: AppTypography.bodyMdMedium.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.bodyMd,
          tabs: const [
            Tab(text: 'Aktif Talepler (1)'),
            Tab(text: 'Geçmiş / Tamamlanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Active Requests
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#TD-84920',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primaryContainer,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('12 dk önce', style: AppTypography.labelSm),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.orangeLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    size: 13, color: AppColors.orange),
                                const SizedBox(width: 3),
                                Text(
                                  'Acil Onarım',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Banyo Bataryası Değişimi & Su Kaçağı Tamiri',
                        style: AppTypography.bodyLgMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 15, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Kadıköy, Caferağa Mah. • Tesisat',
                            style: AppTypography.bodyMd.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Offers Received Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3 Usta Teklif Verdi',
                                    style: AppTypography.bodyMdMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryContainer,
                                    ),
                                  ),
                                  Text(
                                    '₺2.200 - ₺2.800 aralığında',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/step/11');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Gelen Teklifleri İncele (3)',
                                style: AppTypography.bodyMdMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab 2: History
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_rounded,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Henüz geçmiş tamamlanmış bir işiniz yok.',
                  style: AppTypography.bodyMd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
