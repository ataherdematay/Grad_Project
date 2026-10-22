import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 22: İş Tamamlama ve Teslim Onayı (SCR-10)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S22CompletionPinScreen extends StatefulWidget {
  const S22CompletionPinScreen({super.key});

  @override
  State<S22CompletionPinScreen> createState() => _S22CompletionPinScreenState();
}

class _S22CompletionPinScreenState extends State<S22CompletionPinScreen> {
  bool _isApproving = false;

  void _handleApprove() {
    setState(() => _isApproving = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        context.push('/step/23');
      }
    });
  }

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
              context.go('/step/20');
            }
          },
        ),
        title: Column(
          children: [
            Text('İş Tamamlama Onayı', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
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
            // Top Hero Inspection Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F3EF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFB8E4D5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 22, color: AppColors.emerald),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usta onarımı tamamladığını bildirdi',
                              style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lütfen lavabo altındaki yeni vanayı ve su sızdırmazlığını kontrol ettikten sonra teslim almayı onaylayın.',
                              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFB8E4D5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop, size: 16, color: AppColors.emerald),
                          const SizedBox(width: 4),
                          Text('Sızdırmazlık testi yapıldı', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: AppColors.emerald),
                          const SizedBox(width: 4),
                          Text('12 Ay İşçilik Garantisi', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Completed Work Summary Card
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
                          Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7F3EF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('Doğrulanmış usta', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Bugün 14:55 tamamlandı', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  Text('YAPILAN İŞLEMLER KAPSAMI', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  _buildCheckBullet('Patlak temiz su vanası yeni pirinç vana ile değiştirildi'),
                  const SizedBox(height: 6),
                  _buildCheckBullet('Boru bağlantı contaları ve teflon sızdırmazlık yenilendi'),
                  const SizedBox(height: 6),
                  _buildCheckBullet('Şebeke basınç testi yapıldı, herhangi bir sızıntı görülmedi'),
                  const SizedBox(height: 14),
                  // Proof Photo Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo_camera, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Usta Kanıt Fotoğrafı (1)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                        ],
                      ),
                      Text('Dokunarak büyütün', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDisabled,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 36, color: AppColors.emerald),
                            SizedBox(height: 4),
                            Text('Montaj Tamamlandı Görseli', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                        Positioned(
                          bottom: 8,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Usta tarafından eklendi • 14:55', style: AppTypography.labelSm.copyWith(color: Colors.white, backgroundColor: Colors.black54)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.visibility, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 2),
                                    Text('Önizle', style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
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
            ),
            const SizedBox(height: 16),

            // Itemized Financial Summary Card
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
                          const Icon(Icons.receipt_long, size: 20, color: AppColors.primaryContainer),
                          const SizedBox(width: 6),
                          Text('Ödeme ve Tutar Özeti', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('Sabit Fiyat', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
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
                      Text('Malzeme (Pirinç vana & contalar)', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
                      Text('₺800', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                    ],
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
                          Text('Toplam tutar', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                          Text('(KDV dahil)', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                      Text('₺2.450', style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Escrow Protection Note Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCCE7F4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock, size: 16, color: AppColors.infoBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Güvenli BiTadilat Havuz Hesabı: ',
                              style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: 'Onay verdiğinizde hizmet bedeli ustaya aktarılacaktır. Ustanın yanından ayrılmadan önce vanayı açıp kontrol ediniz.',
                                  style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.normal),
                                ),
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
            const SizedBox(height: 10),

            // Warranty Notice Row
            Container(
              padding: const EdgeInsets.all(12),
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
                      const Icon(Icons.verified, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Fatura ve Garanti Belgesi profilinize iletilecektir', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
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
            ElevatedButton(
              onPressed: _isApproving ? null : _handleApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isApproving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Onaylanıyor ve Havuz Çözülüyor...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('İşi Onayla ve Değerlendirmeye Geç', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: () => context.push('/step/24'),
              icon: const Icon(Icons.report_problem, size: 16, color: AppColors.alertRed),
              label: Text(
                'İşte eksik veya sızıntı mı var? Sorun bildir / Destek talep et',
                style: AppTypography.labelMd.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, size: 18, color: AppColors.emerald),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface)),
        ),
      ],
    );
  }
}
