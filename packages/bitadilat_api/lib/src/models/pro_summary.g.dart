// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProSummary _$ProSummaryFromJson(Map<String, dynamic> json) => _ProSummary(
  reviewStatus: $enumDecode(_$ReviewStatusEnumMap, json['reviewStatus']),
  availability: $enumDecode(_$ProAvailabilityEnumMap, json['availability']),
  businessName: json['businessName'] as String?,
);

Map<String, dynamic> _$ProSummaryToJson(_ProSummary instance) =>
    <String, dynamic>{
      'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
      'availability': _$ProAvailabilityEnumMap[instance.availability]!,
      'businessName': instance.businessName,
    };

const _$ReviewStatusEnumMap = {
  ReviewStatus.pendingReview: 'PENDING_REVIEW',
  ReviewStatus.needsDocuments: 'NEEDS_DOCUMENTS',
  ReviewStatus.approved: 'APPROVED',
  ReviewStatus.rejected: 'REJECTED',
  ReviewStatus.suspended: 'SUSPENDED',
};

const _$ProAvailabilityEnumMap = {
  ProAvailability.active: 'ACTIVE',
  ProAvailability.onBreak: 'ON_BREAK',
};
