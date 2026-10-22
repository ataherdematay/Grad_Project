import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 18: İş Alanı — Randevu Onaylandı
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S18JobWorkspaceScreen extends StatelessWidget {
  const S18JobWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/4');
            }
          },
        ),
        title: Text('İş Alanı', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Confirmation Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 32, color: AppColors.tertiary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_available, size: 15, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Yaklaşan Randevu', style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Randevun onaylandı', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text(
                    'Mavi Hat Tesisat seçtiğin zaman aralığında hizmet verecek.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Compact Appointment Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.plumbing, color: AppColors.primaryContainer, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiaryFixed.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified, size: 12, color: AppColors.tertiary),
                                      const SizedBox(width: 2),
                                      Text('Doğrulanmış uzman', style: AppTypography.labelSm.copyWith(color: AppColors.tertiary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('Tesisat • Acil onarım', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Snapshot banner
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.home_repair_service, color: AppColors.primaryContainer, size: 24),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Banyo Sıhhi Tesisat Bakımı', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                            Text('İş kapsamı: Vana değişimi ve sızdırmazlık testi', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24, color: AppColors.surfaceDisabled),
                  // Details
                  _buildDetailRow(Icons.calendar_today, 'Randevu', 'Yarın · 14:00 – 16:00'),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on, 'Hizmet bölgesi', 'İstanbul, Kadıköy'),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.receipt_long, 'Teklif toplamı', '₺2.450 (KDV dahil)', isHighlighted: true),
                  const SizedBox(height: 12),
                  // Privacy box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kesin adresin, randevu onayıyla uzmanla güvenli biçimde paylaşıldı.',
                            style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Job Status Timeline
            Text('İş durumu', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  _buildStatusItem(
                    title: 'Teklif kabul edildi',
                    desc: 'İş kapsamı ve bütçe onaylandı',
                    isDone: true,
                  ),
                  _buildStatusItem(
                    title: 'Randevu onaylandı',
                    desc: 'Usta takvimine işlendi',
                    isDone: true,
                  ),
                  _buildStatusItem(
                    title: 'İş başlangıcı',
                    desc: 'Randevu saatinde güncellenecek',
                    isActive: true,
                  ),
                  _buildStatusItem(
                    title: 'İş tamamlandı',
                    desc: 'Onay ve değerlendirme adımı',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Communication & Tracking Cards
            Text('İletişim ve takip', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => context.push('/step/19'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.chat, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mesajlar', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                          Text('Mavi Hat Tesisat ile uygulama içinden iletişim kur', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => context.push('/step/20'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.checklist, color: AppColors.primaryContainer, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('İş ilerlemesi', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDisabled,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('Henüz başlamadı', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                          Text('Usta mekana ulaştığında aktifleşecek', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Secondary Action Link: Randevuyu değiştir veya iptal et
            Center(
              child: TextButton(
                onPressed: () => context.push('/step/21'),
                child: Text(
                  'Randevuyu değiştir veya iptal et',
                  style: AppTypography.bodyMdMedium.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => context.push('/step/19'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat, size: 20),
              const SizedBox(width: 8),
              Text('Ustaya mesaj gönder', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        Text(
          value,
          style: isHighlighted
              ? AppTypography.bodyLgMedium.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)
              : AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String desc,
    bool isDone = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.tertiaryFixed
                      : (isActive ? AppColors.primaryContainer : AppColors.surfaceDisabled),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check : (isActive ? Icons.schedule : Icons.radio_button_unchecked),
                  size: 14,
                  color: isDone ? AppColors.tertiary : (isActive ? Colors.white : AppColors.outline),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.tertiaryFixed : AppColors.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isActive
                      ? AppTypography.bodyMdMedium.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)
                      : AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface),
                ),
                Text(desc, style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
