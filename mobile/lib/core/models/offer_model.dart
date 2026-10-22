import 'package:equatable/equatable.dart';

enum OfferStatus {
  pending,
  accepted,
  rejected,
  completed,
}

class ProProfile extends Equatable {
  final String id;
  final String name;
  final String businessName;
  final double rating;
  final int reviewCount;
  final int completedJobs;
  final List<String> badges;
  final String avatarUrl;
  final int experienceYears;
  final bool isIdentityVerified;
  final bool isCriminalRecordClean;

  const ProProfile({
    required this.id,
    required this.name,
    required this.businessName,
    required this.rating,
    required this.reviewCount,
    required this.completedJobs,
    required this.badges,
    required this.avatarUrl,
    this.experienceYears = 8,
    this.isIdentityVerified = true,
    this.isCriminalRecordClean = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        businessName,
        rating,
        reviewCount,
        completedJobs,
        badges,
        avatarUrl,
        experienceYears,
        isIdentityVerified,
        isCriminalRecordClean,
      ];
}

class ProOffer extends Equatable {
  final String id;
  final String jobId;
  final ProProfile pro;
  final double laborAmount;
  final double materialsAmount;
  final double totalAmount;
  final int warrantyMonths;
  final int estimatedArrivalMinutes;
  final String note;
  final OfferStatus status;
  final DateTime createdAt;

  const ProOffer({
    required this.id,
    required this.jobId,
    required this.pro,
    required this.laborAmount,
    required this.materialsAmount,
    required this.totalAmount,
    required this.warrantyMonths,
    required this.estimatedArrivalMinutes,
    required this.note,
    this.status = OfferStatus.pending,
    required this.createdAt,
  });

  ProOffer copyWith({
    String? id,
    String? jobId,
    ProProfile? pro,
    double? laborAmount,
    double? materialsAmount,
    double? totalAmount,
    int? warrantyMonths,
    int? estimatedArrivalMinutes,
    String? note,
    OfferStatus? status,
    DateTime? createdAt,
  }) {
    return ProOffer(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      pro: pro ?? this.pro,
      laborAmount: laborAmount ?? this.laborAmount,
      materialsAmount: materialsAmount ?? this.materialsAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      estimatedArrivalMinutes:
          estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        pro,
        laborAmount,
        materialsAmount,
        totalAmount,
        warrantyMonths,
        estimatedArrivalMinutes,
        note,
        status,
        createdAt,
      ];
}
