import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 29: Usta Teklif Hazırlama (SCR-15)
/// Flow: 6. Hizmet Profesyoneli (Usta)
/// Role: PRO
class S29ProBidCreationScreen extends StatefulWidget {
  const S29ProBidCreationScreen({super.key});

  @override
  State<S29ProBidCreationScreen> createState() => _S29ProBidCreationScreenState();
}

class _S29ProBidCreationScreenState extends State<S29ProBidCreationScreen> {
  final TextEditingController _laborController = TextEditingController(text: '1500');
  final TextEditingController _materialController = TextEditingController(text: '950');
  final TextEditingController _noteController = TextEditingController(
    text: 'Lavabo altı boru ve pirinç vana montajı orijinal parçalarla garantili olarak yapılacaktır.',
  );
  int _selectedWarranty = 6;
  int _selectedSlot = 0;

  int get _totalCost {
    final labor = int.tryParse(_laborController.text) ?? 0;
    final mat = int.tryParse(_materialController.text) ?? 0;
    return labor + mat;
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
              context.go('/step/28');
            }
          },
        ),
        title: Text('Teklif Hazırla', style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Request Recap Card
            Container(
              padding: const EdgeInsets.all(14),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF1E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Acil Onarım', style: AppTypography.labelSm.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                      ),
                      Text('1.2 km · Moda, Kadıköy', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Banyo Lavabo Altı Temiz Su Borusu Patlağı', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Text('Talep No: #BD-88412 · Ali Yılmaz', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Şeffaf Maliyet Ayrımı (İşçilik & Malzeme)
            Text('ŞEFFAF MALİYET AYRIMI (ZORUNLU)', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('İşçilik Bedeli (₺)', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _laborController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                prefixText: '₺ ',
                                filled: true,
                                fillColor: AppColors.canvas,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Malzeme Bedeli (₺)', style: AppTypography.labelMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _materialController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                prefixText: '₺ ',
                                filled: true,
                                fillColor: AppColors.canvas,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Toplam Teklif Tutarı (KDV Dahil)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text('₺$_totalCost', style: AppTypography.headlineSm.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Uygun Tarih ve Saat
            Text('UYGUN BULUNDUĞUNUZ ZAMAN ARALIĞI', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedSlot = 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedSlot == 0 ? AppColors.surfaceContainerLow : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedSlot == 0 ? AppColors.primaryContainer : AppColors.borderSubtle,
                          width: _selectedSlot == 0 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bugün (Önerilen)', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          Text('14:00 – 17:00 Arası', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedSlot = 1),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedSlot == 1 ? AppColors.surfaceContainerLow : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedSlot == 1 ? AppColors.primaryContainer : AppColors.borderSubtle,
                          width: _selectedSlot == 1 ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yarın Sabah', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          Text('09:00 – 12:00 Arası', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Garanti Süresi
            Text('İŞÇİLİK GARANTİSİ TAAHHÜDÜ', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Row(
              children: [6, 12].map((months) {
                final isSelected = _selectedWarranty == months;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text('$months Ay Garanti'),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.onSurface, fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => _selectedWarranty = months),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Teklif Açıklaması
            Text('USTANIN NOTU & KAPSAM AÇIKLAMASI', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderSubtle)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryContainer)),
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
          onPressed: () => context.push('/step/30'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Teklifi Müşteriye Gönder', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
