import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Screen 16: Randevu Zamanı Seç (SCR-06)
/// Flow: 3. Teklif Karşılaştırma & Randevu
/// Role: CUSTOMER
class S16AppointmentTimeScreen extends StatefulWidget {
  const S16AppointmentTimeScreen({super.key});

  @override
  State<S16AppointmentTimeScreen> createState() => _S16AppointmentTimeScreenState();
}

class _S16AppointmentTimeScreenState extends State<S16AppointmentTimeScreen> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 2; // Default to 14:00 - 16:00

  final List<Map<String, String>> _dates = [
    {'day': 'Bugün', 'num': '14', 'month': 'Mayıs'},
    {'day': 'Yarın', 'num': '15', 'month': 'Mayıs'},
    {'day': 'Perşembe', 'num': '16', 'month': 'Mayıs'},
    {'day': 'Cuma', 'num': '17', 'month': 'Mayıs'},
    {'day': 'Cumartesi', 'num': '18', 'month': 'Mayıs'},
  ];

  final List<String> _timeSlots = [
    '09:00 – 11:00',
    '11:00 – 13:00',
    '14:00 – 16:00',
    '16:00 – 18:00',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDateStr = _dates[_selectedDateIndex]['day'] ?? '';
    final selectedTimeStr = _timeSlots[_selectedTimeIndex];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/step/15');
            }
          },
        ),
        title: Text('Randevu Zamanı Seç', style: AppTypography.headlineSm.copyWith(color: AppColors.primary)),
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
            // Top Accepted-Offer Summary Card
            Container(
              padding: const EdgeInsets.all(14),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.plumbing, color: AppColors.primaryContainer, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mavi Hat Tesisat', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.onSurface)),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7F3EF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified, size: 13, color: AppColors.emerald),
                                    const SizedBox(width: 4),
                                    Text('Doğrulanmış uzman', style: AppTypography.labelSm.copyWith(color: AppColors.emerald)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₺2.450', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                          Text('KDV dahil', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('Tesisat', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface)),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          Row(
                            children: [
                              const Icon(Icons.error_outline, size: 15, color: AppColors.orange),
                              const SizedBox(width: 4),
                              Text('Acil onarım', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.orange)),
                            ],
                          ),
                        ],
                      ),
                      Text('Onaylanan Teklif', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main Section Intro
            Text('Uygun bir gün ve saat seç', style: AppTypography.headlineMd.copyWith(color: AppColors.onSurface)),
            const SizedBox(height: 4),
            Text(
              'Ustanın uygun zaman aralıklarından sana en uygun olanı seç.',
              style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Date Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tarih seçimi', style: AppTypography.bodyMdMedium.copyWith(color: AppColors.textSecondary)),
                Text('Bir gün seçin', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_dates.length, (index) {
                  final isSelected = _selectedDateIndex == index;
                  final item = _dates[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 84,
                        height: 94,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['day']!,
                              style: AppTypography.labelMd.copyWith(
                                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              item['num']!,
                              style: AppTypography.headlineSm.copyWith(
                                color: isSelected ? Colors.white : AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['month']!,
                              style: AppTypography.labelSm.copyWith(
                                color: isSelected ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 22),

            // Time Slot Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saat aralığı', style: AppTypography.headlineSm.copyWith(color: AppColors.onSurface)),
                Text('Uygun aralık seçin', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTimeIndex == index;
                final slot = _timeSlots[index];
                return InkWell(
                  onTap: () => setState(() => _selectedTimeIndex = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slot,
                          style: AppTypography.bodyMdMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            // Disabled Slot: 18:00 – 20:00 Dolu
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDisabled,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '18:00 – 20:00',
                        style: AppTypography.bodyMdMedium.copyWith(
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Dolu', style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Information Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.infoBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info, size: 20, color: AppColors.infoBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Randevu onayı', style: AppTypography.bodyLgMedium.copyWith(color: AppColors.darkTeal)),
                        const SizedBox(height: 2),
                        Text(
                          'Seçtiğin zaman aralığı uzmana iletilir. Kesinleştiğinde sana bildirim göndeririz.',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Selection Preview Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_available, color: AppColors.infoBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Seçilen randevu: $selectedDateStr • $selectedTimeStr',
                        style: AppTypography.bodyMdMedium.copyWith(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F3EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('Hazır', style: AppTypography.labelSm.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold)),
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
          onPressed: () => context.push('/step/17'),
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
              Text('Randevu talebini gönder', style: AppTypography.bodyLgMedium.copyWith(color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
