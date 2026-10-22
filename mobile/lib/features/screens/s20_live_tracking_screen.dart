import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 20: İş Aşamaları ve İlerleme Takibi (SCR-08)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S20LiveTrackingScreen extends StatelessWidget {
  const S20LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.95),
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
            Text('İş İlerlemesi', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
            Text('Talep #501 · Mavi Hat Tesisat', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_vert, color: AppColors.textSecondary),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active Status Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF4F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC4DEEB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.build, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Onarım Sürüyor', style: AppTypography.labelMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFC4DEEB)),
                        ),
                        child: Text('Kadıköy · Caferağa', style: AppTypography.labelSm.copyWith(color: const Color(0xFF104D5D))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Usta adreste onarıma devam ediyor', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(
                    'Mavi Hat Tesisat saat 14:10\'da adrese ulaştı. Patlak vana söküldü ve yeni pirinç vana montajı yapılıyor.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                  const Divider(height: 20, color: Color(0xFFD2ECFA)),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: AppColors.primaryContainer),
                      const SizedBox(width: 6),
                      RichText(
                        text: TextSpan(
                          text: 'Tahmini tamamlanma: ',
                          style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary),
                          children: const [
                            TextSpan(text: '~45 dakika', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5-Step Milestone Timeline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aşama Durumu', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                      Text('ADIM 3 / 5', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMilestoneStep(
                    stepNum: '1',
                    title: 'Randevu Planlandı',
                    badge: '14:00 Kadıköy',
                    desc: 'Mavi Hat Tesisat randevuyu onayladı',
                    isDone: true,
                  ),
                  _buildMilestoneStep(
                    stepNum: '2',
                    title: 'Adrese Ulaşıldı',
                    badge: '14:10',
                    desc: 'Usta konuma vardı ve çalışmaya başladı',
                    isDone: true,
                  ),
                  _buildMilestoneStep(
                    stepNum: '3',
                    title: 'Onarım Devam Ediyor',
                    badge: 'Şu An',
                    desc: 'Pirinç vana değişimi ve sızdırmazlık testi yapılıyor',
                    isActive: true,
                    hasPhoto: true,
                  ),
                  _buildMilestoneStep(
                    stepNum: '4',
                    title: 'İş Bitirildi — Onay Bekleniyor',
                    desc: 'Usta işi bitirdiğinde kontrol edip onaylayacaksın',
                    isPending: true,
                    onTapPending: () => context.push('/step/22'),
                  ),
                  _buildMilestoneStep(
                    stepNum: '5',
                    title: 'Tamamlandı ve Değerlendirildi',
                    desc: 'Puan ve yorum adımı',
                    isLast: true,
                    isPending: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Agreed Scope & Price Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, size: 20, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('Anlaşılan Kapsam ve Tutar', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3EF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Sabit Fiyat', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('İşçilik bedeli', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Text('₺1.650', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Malzeme (Pirinç vana & conta)', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Text('₺800', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      'Kapsam: Ana kolon giriş vanası sökümü, 3/4" ECA pirinç küresel vana montajı ve basınç testi.',
                      style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Toplam tutar (KDV dahil)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          Text('Güvenli BiTadilat Havuz Hesabında Bloke', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('₺2.450', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency / Support Link
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/step/24'),
                icon: const Icon(Icons.report_problem, size: 18, color: AppColors.alertRed),
                label: Text(
                  'Usta ile ilgili bir sorun mu var? Destek ekibine bildir',
                  style: AppTypography.bodyMdMedium.copyWith(color: AppColors.alertRed),
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
          border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: ElevatedButton.icon(
          onPressed: () => context.push('/step/19'),
          icon: const Icon(Icons.chat, size: 20),
          label: Text('Ustaya Mesaj Gönder', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneStep({
    required String stepNum,
    required String title,
    required String desc,
    String? badge,
    bool isDone = false,
    bool isActive = false,
    bool isPending = false,
    bool isLast = false,
    bool hasPhoto = false,
    VoidCallback? onTapPending,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFE7F3EF)
                      : (isActive ? AppColors.primaryContainer : AppColors.canvas),
                  border: Border.all(
                    color: isDone
                        ? AppColors.emerald
                        : (isActive ? AppColors.primaryContainer : AppColors.borderSubtle),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check : (isActive ? Icons.build : Icons.radio_button_unchecked),
                  size: 16,
                  color: isDone ? AppColors.emerald : (isActive ? Colors.white : AppColors.outline),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.emerald : AppColors.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: isActive
                              ? AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
                              : AppTypography.bodyMdMedium.copyWith(color: isPending ? AppColors.textSecondary : AppColors.onSurface),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDone ? const Color(0xFFE7F3EF) : const Color(0xFFEDF4F7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: AppTypography.labelSm.copyWith(
                              color: isDone ? AppColors.emerald : AppColors.primaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (onTapPending != null)
                        InkWell(
                          onTap: onTapPending,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Onayla >',
                              style: AppTypography.labelSm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                  if (hasPhoto) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDisabled,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.plumbing, color: AppColors.primaryContainer),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.photo_camera, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text('yerinde_onarım_01.jpg', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface)),
                                  ],
                                ),
                                Text('Usta tarafından yüklendi · 14:18', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.visibility, size: 20, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
