import 'package:equatable/equatable.dart';
import 'offer_model.dart';

enum JobStatus {
  pendingOffers,
  scheduled,
  proEnRoute,
  inProgress,
  completed,
  released,
  cancelled,
}

extension JobStatusExtension on JobStatus {
  String get labelTr {
    switch (this) {
      case JobStatus.pendingOffers:
        return 'Teklif Toplanıyor';
      case JobStatus.scheduled:
        return 'Randevu Onaylandı';
      case JobStatus.proEnRoute:
        return 'Usta Yolda';
      case JobStatus.inProgress:
        return 'İşlem Devam Ediyor';
      case JobStatus.completed:
        return 'İş Bitti (Onay Bekliyor)';
      case JobStatus.released:
        return 'Tamamlandı';
      case JobStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}

enum UrgencyLevel {
  emergency,
  thisWeek,
  flexible,
}

extension UrgencyLevelExtension on UrgencyLevel {
  String get labelTr {
    switch (this) {
      case UrgencyLevel.emergency:
        return 'Bugün Acil';
      case UrgencyLevel.thisWeek:
        return 'Bu Hafta';
      case UrgencyLevel.flexible:
        return 'Esnek Tarih';
    }
  }
}

class JobRequest extends Equatable {
  final String id;
  final String customerId;
  final String categoryId;
  final String title;
  final String description;
  final UrgencyLevel urgency;
  final String preferredDate;
  final String preferredTimeSlot;
  final String city;
  final String district;
  final String neighborhood;
  final String addressLine;
  final List<String> photoUrls;
  final JobStatus status;
  final List<ProOffer> offers;
  final String? selectedOfferId;
  final String completionPin;
  final bool escrowLocked;
  final DateTime createdAt;

  const JobRequest({
    required this.id,
    required this.customerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.urgency,
    required this.preferredDate,
    required this.preferredTimeSlot,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.addressLine,
    required this.photoUrls,
    this.status = JobStatus.pendingOffers,
    this.offers = const [],
    this.selectedOfferId,
    this.completionPin = '849201',
    this.escrowLocked = false,
    required this.createdAt,
  });

  ProOffer? get selectedOffer {
    if (selectedOfferId == null) return null;
    return offers.cast<ProOffer?>().firstWhere(
          (o) => o?.id == selectedOfferId,
          orElse: () => null,
        );
  }

  JobRequest copyWith({
    String? id,
    String? customerId,
    String? categoryId,
    String? title,
    String? description,
    UrgencyLevel? urgency,
    String? preferredDate,
    String? preferredTimeSlot,
    String? city,
    String? district,
    String? neighborhood,
    String? addressLine,
    List<String>? photoUrls,
    JobStatus? status,
    List<ProOffer>? offers,
    String? selectedOfferId,
    String? completionPin,
    bool? escrowLocked,
    DateTime? createdAt,
  }) {
    return JobRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      urgency: urgency ?? this.urgency,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTimeSlot: preferredTimeSlot ?? this.preferredTimeSlot,
      city: city ?? this.city,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      addressLine: addressLine ?? this.addressLine,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      offers: offers ?? this.offers,
      selectedOfferId: selectedOfferId ?? this.selectedOfferId,
      completionPin: completionPin ?? this.completionPin,
      escrowLocked: escrowLocked ?? this.escrowLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        categoryId,
        title,
        description,
        urgency,
        preferredDate,
        preferredTimeSlot,
        city,
        district,
        neighborhood,
        addressLine,
        photoUrls,
        status,
        offers,
        selectedOfferId,
        completionPin,
        escrowLocked,
        createdAt,
      ];
}
