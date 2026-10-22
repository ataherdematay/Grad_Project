import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 32: Usta İş Yürütme & Aşama Yönetimi (SCR-18)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S32ProExecutionWorkScreen extends StatefulWidget {
  const S32ProExecutionWorkScreen({super.key});

  @override
  State<S32ProExecutionWorkScreen> createState() => _S32ProExecutionWorkScreenState();
}

class _S32ProExecutionWorkScreenState extends State<S32ProExecutionWorkScreen> {
  int _currentMilestone = 3; // 1: Teklif Kabul, 2: Adrese Varış, 3: Onarım Sürüyor, 4: Teslim Talebi, 5: Tamamlandı
  bool _photoAttached = false;

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
              context.go('/step/28');
            }
          },
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'İş Yürütme #501',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EEEB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.darkTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Müşteri: Ata H. · Kadıköy',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F2F6),
              border: Border.all(color: const Color(0xFFC4DEEB)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF247BA0),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sahada',
                  style: AppTypography.labelSm.copyWith(
                    color: const Color(0xFF247BA0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Status Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF4F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC4DEEB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.construction, size: 20, color: AppColors.primaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            'İşlemde: Onarım Sürüyor',
                            style: AppTypography.bodyMdMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Aktif',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '14:10\'da adrese giriş yaptınız. İşi tamamladığınızda aşağıdaki butondan müşteriye teslim onayı gönderin.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer & Location Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A102A34),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8F2FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'AH',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Müşteri: Ata H.',
                                  style: AppTypography.bodyMdMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7F3EF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Ev Sahibi',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.emerald,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tesisat Onarımı Talebi',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.borderSubtle),

                  // Exact Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 20, color: AppColors.alertRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Caferağa Mah. Moda Cad. No: 14 D: 5, Kadıköy',
                              style: AppTypography.bodyMdMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Apartman Zili: Hakan / Kat 2',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Harita uygulaması başlatılıyor...')),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.directions, size: 16, color: Color(0xFF247BA0)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Haritada Yol Tarifi Al',
                                    style: AppTypography.labelMd.copyWith(
                                      color: const Color(0xFF247BA0),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Direct Communication Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.primaryContainer),
                      label: Text(
                        'Müşteriye Mesaj Yaz',
                        style: AppTypography.bodyMdMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      onPressed: () {
                        context.go('/step/19');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Milestone Progress Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A102A34),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Aşama Yönetimi',
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Adım $_currentMilestone / 5',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stepper Items
                  _buildMilestoneItem(
                    isCompleted: true,
                    isActive: false,
                    isLast: false,
                    title: 'Teklif Kabul Edildi',
                    subtitle: '₺2.450 KDV dahil tutar onaylandı',
                  ),
                  _buildMilestoneItem(
                    isCompleted: true,
                    isActive: false,
                    isLast: false,
                    title: 'Adrese Ulaşıldı',
                    subtitle: '14:10\'da check-in yapıldı',
                  ),
                  _buildMilestoneItem(
                    isCompleted: false,
                    isActive: true,
                    isLast: false,
                    title: 'Onarım Sürüyor',
                    subtitle: 'Pirinç vana takıldı, sızdırmazlık deneniyor.',
                  ),
                  _buildMilestoneItem(
                    isCompleted: false,
                    isActive: false,
                    isLast: false,
                    title: 'İşi Bitir Olarak İşaretle',
                    subtitle: 'Müşteri incelemesine gönderilecek',
                  ),
                  _buildMilestoneItem(
                    isCompleted: false,
                    isActive: false,
                    isLast: true,
                    title: 'Tamamlandı ve Kapatıldı',
                    subtitle: 'Müşteri onayı sonrası hesap aktarımı',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scope & Price Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
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
                          const Icon(Icons.receipt_long, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Anlaşılan Kapsam & Ücret',
                            style: AppTypography.bodyMdMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Teklif ID: #T-992',
                        style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text('İşçilik', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('₺1.650', style: AppTypography.bodyMdMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: AppColors.borderSubtle),
                        Expanded(
                          child: Column(
                            children: [
                              Text('Malzeme', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('₺800', style: AppTypography.bodyMdMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 28, color: AppColors.borderSubtle),
                        Expanded(
                          child: Column(
                            children: [
                              Text('Toplam', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text('₺2.450', style: AppTypography.bodyMdMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.verified_user, size: 16, color: AppColors.emerald),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tutar BiTadilat Güvence Havuzunda bloke durumdadır.',
                          style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Photo Upload Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8F2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.photo_camera, size: 20, color: AppColors.primaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _photoAttached ? '2 Fotoğraf Eklendi' : 'İş Sonu Fotoğrafı Ekle',
                          style: AppTypography.bodyMdMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _photoAttached ? AppColors.emerald : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Teslim onayı için önerilir (İsteğe bağlı)',
                          style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6F6FF),
                      foregroundColor: AppColors.primaryContainer,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _photoAttached = !_photoAttached;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_photoAttached ? '2 iş sonu fotoğrafı yüklendi.' : 'Fotoğraflar kaldırıldı.')),
                      );
                    },
                    child: Text(_photoAttached ? 'Kaldır' : 'Yükle', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          boxShadow: [
            BoxShadow(
              color: Color(0x10102A34),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  context.go('/step/33');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'İşi Bitirdim (Müşteriye Teslim Talebi Gönder)',
                      style: AppTypography.bodyLgMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                context.go('/step/24');
              },
              icon: const Icon(Icons.warning, size: 16, color: AppColors.alertRed),
              label: Text(
                'Sahada bir anlaşmazlık mı var? Durum Bildir / Destek İste',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem({
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required String title,
    required String subtitle,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFE7F3EF)
                        : isActive
                            ? AppColors.primaryContainer
                            : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.emerald
                          : isActive
                              ? AppColors.primaryContainer
                              : AppColors.borderSubtle,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: AppColors.emerald)
                      : isActive
                          ? const Icon(Icons.settings, size: 16, color: Colors.white)
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.borderSubtle,
                                shape: BoxShape.circle,
                              ),
                            ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.emerald : AppColors.borderSubtle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMdMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.primaryContainer : AppColors.onSurface,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Şu An',
                            style: AppTypography.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC4DEEB)),
                      ),
                      child: Text(
                        subtitle,
                        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                      ),
                    )
                  else
                    Text(
                      subtitle,
                      style: AppTypography.labelMd.copyWith(
                        color: isCompleted ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.8),
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
