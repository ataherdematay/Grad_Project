import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 24: Şikayet ve Uyuşmazlık Bildirimi (SCR-12)
/// Flow: 4. Aktif İş, Mesajlaşma & Teslim
/// Role: CUSTOMER
class S24DisputeReportScreen extends StatefulWidget {
  const S24DisputeReportScreen({super.key});

  @override
  State<S24DisputeReportScreen> createState() => _S24DisputeReportScreenState();
}

class _S24DisputeReportScreenState extends State<S24DisputeReportScreen> {
  int _selectedReason = 0;
  final TextEditingController _detailController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {
      'title': 'Usta randevuya gelmedi / Ulaşılamıyor (No-Show)',
      'desc': 'Belirlenen randevu saatinde adrese gelinmedi ve iletişim kurulamadı.',
    },
    {
      'title': 'Anlaşılandan farklı veya eksik iş yapıldı',
      'desc': 'Teklifte taahhüt edilen kapsam tam olarak yerine getirilmedi.',
    },
    {
      'title': 'Teklif dışı fazladan ücret talep edildi',
      'desc': 'Önceden onaylanmamış ek masraflar veya fiyat artışı istendi.',
    },
    {
      'title': 'İletişimde saygısız / uygunsuz tutum',
      'desc': 'Profesyonel olmayan üslup veya davranış sergilendi.',
    },
    {
      'title': 'Diğer uyuşmazlık',
      'desc': 'Yukarıdaki maddeler dışındaki herhangi bir operasyonel sorun.',
    },
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
              context.go('/step/20');
            }
          },
        ),
        title: Column(
          children: [
            Text('Sorun Bildir / Şikayet', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
            Text('İş #504 · Ali Usta (Elektrik)', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
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
            // Uyuşmazlık Çözüm Merkezi Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF5C7A9)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF1E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF5C7A9)),
                    ),
                    child: const Icon(Icons.gavel, size: 22, color: AppColors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Uyuşmazlık Çözüm Merkezi', style: AppTypography.bodyMdMedium.copyWith(color: const Color(0xFF642B00), fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Güvence', style: AppTypography.labelSm.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'BiTadilat arabuluculuk ekibi tarafların mesaj geçmişini, varış saatlerini ve anlaşma şartlarını tarafsız biçimde inceler.',
                          style: AppTypography.labelMd.copyWith(color: const Color(0xFF642B00).withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Sorun Türü Seçimi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SORUN TÜRÜ SEÇİMİ', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
                Text('* Zorunlu', style: AppTypography.labelSm.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(_reasons.length, (index) {
              final item = _reasons[index];
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
                        color: isSelected ? AppColors.alertRed : AppColors.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.alertRed : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.alertRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: AppTypography.bodyMdMedium.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['desc']!,
                                style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Detaylar
            Text('Neler yaşandığını detaylandırın...', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 6),
            TextField(
              controller: _detailController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tarih, saat ve ustanın verdiği yanıtlar gibi detayları yazmanız incelemeyi hızlandırır...',
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
            const SizedBox(height: 16),

            // Escrow Frozen Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF4F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC4DEEB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 20, color: AppColors.primaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Şikayet oluşturulduğunda ödeme havuzu otomatik olarak dondurulur ve tarafsız moderatör incelemesine alınır.',
                      style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
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
        child: ElevatedButton(
          onPressed: () => context.push('/step/25'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.alertRed,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Şikayet Kaydı Oluştur', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
