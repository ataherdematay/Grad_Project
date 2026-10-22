import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/bloc/job_bloc.dart';
import '../../core/models/category_model.dart';
import '../../core/models/job_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/escrow_guarantee_card.dart';

class WizardFlowScreen extends StatefulWidget {
  final String? initialCategoryId;
  const WizardFlowScreen({super.key, this.initialCategoryId});

  @override
  State<WizardFlowScreen> createState() => _WizardFlowScreenState();
}

class _WizardFlowScreenState extends State<WizardFlowScreen> {
  int _currentStep = 1;
  static const int _totalSteps = 5;

  late String _selectedCategoryId;
  final _titleController = TextEditingController(
      text: 'Banyo Bataryası Değişimi & Su Kaçağı Tamiri');
  final _descController = TextEditingController(
      text:
          'Lavabo altı fleks borusunda damlama var ve batarya kireçlenmeden ötürü sıkıştı. Yeni batarya montajı ve kaçak tespiti gerekiyor.');
  UrgencyLevel _selectedUrgency = UrgencyLevel.thisWeek;
  String _selectedDate = '25 Ekim Cuma';
  String _selectedTimeSlot = '14:00 - 17:00';
  final _city = 'İstanbul';
  final _districtController = TextEditingController(text: 'Kadıköy');
  final _neighborhoodController = TextEditingController(text: 'Caferağa Mah.');
  final _addressLineController =
      TextEditingController(text: 'Moda Cad. No:42 Daire:5');

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 'plumbing';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    _addressLineController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _submitJob();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _submitJob() {
    final newJob = JobRequest(
      id: 'job-${DateTime.now().millisecondsSinceEpoch % 100000}',
      customerId: 'u-101',
      categoryId: _selectedCategoryId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      urgency: _selectedUrgency,
      preferredDate: _selectedDate,
      preferredTimeSlot: _selectedTimeSlot,
      city: _city,
      district: _districtController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      addressLine: _addressLineController.text.trim(),
      photoUrls: const [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
      ],
      createdAt: DateTime.now(),
    );

    context.read<JobBloc>().add(CreateJobEvent(newJob));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state.operationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.emerald,
              content: Text('Talebiniz başarıyla oluşturuldu! Çevredeki ustalara iletildi.'),
            ),
          );
          context.go('/customer/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _prevStep,
          ),
          title: Text('Yeni Hizmet Talebi ($_currentStep/$_totalSteps)'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: _currentStep / _totalSteps,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildStepContent(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: AppButton(
                  text: _currentStep == _totalSteps ? 'Talebi Yayınla' : 'Devam Et',
                  icon: _currentStep == _totalSteps
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  onPressed: _nextStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Category();
      case 2:
        return _buildStep2Details();
      case 3:
        return _buildStep3Schedule();
      case 4:
        return _buildStep4Location();
      case 5:
        return _buildStep5Summary();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Category() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adım 1: Hizmet Kategorisi Seçin', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text('Yapılacak tamirat ve tadilat işinin uzmanlık alanını belirleyin.',
            style: AppTypography.bodyMedium),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ServiceCategory.defaultCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final cat = ServiceCategory.defaultCategories[index];
            final isSelected = cat.id == _selectedCategoryId;
            return InkWell(
              onTap: () {
                setState(() => _selectedCategoryId = cat.id);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cat.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name,
                              style: AppTypography.h4.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              )),
                          Text(cat.description,
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : AppColors.textDisabled,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adım 2: Sorun ve Talep Detayları', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'Ustaların size en doğru fiyat ve malzeme teklifini verebilmesi için detayları paylaşın.',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Talep Başlığı', style: AppTypography.h4),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Örn: Mutfak Bataryası Değişimi',
          ),
        ),
        const SizedBox(height: 20),
        Text('Arıza / İş Açıklaması', style: AppTypography.h4),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Sorunun ne zaman başladığını, tamir veya yenileme isteğinizi yazın...',
          ),
        ),
        const SizedBox(height: 20),
        Text('Fotoğraf Ekle (Tavsiye Edilir)', style: AppTypography.h4),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1 Fotoğraf Eklendi',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                    Text('Fotoğraflı ilanlar %40 daha hızlı teklif alır.',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: AppColors.emerald),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Schedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adım 3: Zamanlama & Aciliyet', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text('Ustanın adrese hangi gün ve saat aralığında gelmesini istersiniz?',
            style: AppTypography.bodyMedium),
        const SizedBox(height: 24),
        Text('Aciliyet Seviyesi', style: AppTypography.h4),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _UrgencyChip(
                label: 'Bugün Acil',
                icon: Icons.flash_on_rounded,
                isSelected: _selectedUrgency == UrgencyLevel.emergency,
                onTap: () => setState(() => _selectedUrgency = UrgencyLevel.emergency),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _UrgencyChip(
                label: 'Bu Hafta',
                icon: Icons.calendar_today_rounded,
                isSelected: _selectedUrgency == UrgencyLevel.thisWeek,
                onTap: () => setState(() => _selectedUrgency = UrgencyLevel.thisWeek),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _UrgencyChip(
                label: 'Esnek',
                icon: Icons.event_note_rounded,
                isSelected: _selectedUrgency == UrgencyLevel.flexible,
                onTap: () => setState(() => _selectedUrgency = UrgencyLevel.flexible),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Tercih Edilen Tarih', style: AppTypography.h4),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_selectedDate, style: AppTypography.bodyLarge),
              const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Saat Aralığı', style: AppTypography.h4),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_selectedTimeSlot, style: AppTypography.bodyLarge),
              const Icon(Icons.access_time_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adım 4: Konum Bilgileri', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text(
          'Ustanın geleceği adresi giriniz. Açık adresiniz teklifi onaylayana kadar maskelenir.',
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('İlçe', style: AppTypography.h4),
        const SizedBox(height: 8),
        TextField(
          controller: _districtController,
          decoration: const InputDecoration(hintText: 'Örn: Kadıköy'),
        ),
        const SizedBox(height: 16),
        Text('Mahalle', style: AppTypography.h4),
        const SizedBox(height: 8),
        TextField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(hintText: 'Örn: Caferağa Mah.'),
        ),
        const SizedBox(height: 16),
        Text('Açık Adres (Cadde / Sokak / No)', style: AppTypography.h4),
        const SizedBox(height: 8),
        TextField(
          controller: _addressLineController,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Moda Cad. No:42 Daire:5'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.shield_outlined, size: 16, color: AppColors.emerald),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Açık adresiniz teklifi onaylayıp havuz ödemesi yapana kadar ustalardan gizlenir.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.emeraldDark),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adım 5: Talep Özeti & Onay', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text('Lütfen bilgilerin doğruluğunu kontrol edip ilanı yayınlayınız.',
            style: AppTypography.bodyMedium),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_titleController.text, style: AppTypography.h3),
              const SizedBox(height: 8),
              Text(_descController.text, style: AppTypography.bodyMedium),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              _SummaryRow(
                  label: 'Konum',
                  value: '${_districtController.text}, ${_neighborhoodController.text}'),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Tarih & Saat', value: '$_selectedDate ($_selectedTimeSlot)'),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Aciliyet', value: _selectedUrgency.labelTr),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const EscrowGuaranteeCard(),
      ],
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UrgencyChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
