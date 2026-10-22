import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 21: Randevu İptal / Değişiklik Talebi (SCR-09)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S21RescheduleCancelScreen extends StatefulWidget {
  const S21RescheduleCancelScreen({super.key});

  @override
  State<S21RescheduleCancelScreen> createState() => _S21RescheduleCancelScreenState();
}

class _S21RescheduleCancelScreenState extends State<S21RescheduleCancelScreen> {
  int _selectedTab = 0; // 0: Randevuyu İptal Et, 1: Yeni Tarih İste
  int _selectedReason = 0;
  final TextEditingController _noteController = TextEditingController();

  final List<String> _reasons = [
    'Planlarım değişti / Takvim uyuşmazlığı',
    'Sorun bağımsız olarak çözüldü / Onarım gerekmedi',
    'Usta ile iletişim kurulamadı / Gecikme yaşandı',
    'Başka bir hizmet sağlayıcı tercih edildi',
    'Beklenmeyen acil durum / Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/18');
            }
          },
        ),
        title: Column(
          children: [
            Text('Randevu İşlemleri', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            Text('Talep #501 · Mavi Hat Tesisat', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: AppColors.primary),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Summary Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yarın 14:00 – 16:00', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 2),
                              Text('Kadıköy, Moda', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.infoBlue, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Planlandı', style: AppTypography.labelSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Segmented Control (Tabs)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFECEEEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? AppColors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              'Randevuyu İptal Et',
                              style: AppTypography.labelMd.copyWith(
                                color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                                fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? AppColors.primaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_repeat, size: 16, color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Yeni Tarih İste',
                              style: AppTypography.labelMd.copyWith(
                                color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                                fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cancellation Form Section
            Text('İptal Gerekçesi', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 4),
            Text(
              'Hizmet kalitemizi korumak ve ustayı zamanında bilgilendirmek için lütfen iptal nedenini seçin.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // Radio Options
            ...List.generate(_reasons.length, (index) {
              final isSelected = _selectedReason == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedReason = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryContainer : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _reasons[index],
                            style: AppTypography.bodyMdMedium.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),

            // Optional Explanation
            Text('Ek Açıklama (Opsiyonel)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 250,
              decoration: InputDecoration(
                hintText: 'Ustaya veya operasyon ekibine iletmek istediğiniz detaylar...',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryContainer),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancellation Safeguard & Policy Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFEB2B2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.alertRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İptal Koşulu ve Bilgilendirme', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'İş başlangıcından önce yapılan iptallerde herhangi bir ek kesinti uygulanmaz. İptal onaylandığında Mavi Hat Tesisat takviminden çıkarılır ve talep arşive kaldırılır.',
                          style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Confirm cancel and navigate back to customer requests or workspace
                context.go('/step/18');
              },
              icon: const Icon(Icons.cancel, size: 20),
              label: Text('İşi İptal Etmeyi Onayla', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertRed,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/step/18');
                }
              },
              icon: const Icon(Icons.check_circle, size: 20, color: AppColors.primaryContainer),
              label: Text('Vazgeç, Randevuyu Koru', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primaryContainer)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryContainer),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
