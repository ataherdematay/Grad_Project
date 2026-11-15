// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminStats _$AdminStatsFromJson(Map<String, dynamic> json) => _AdminStats(
  pendingApplications: (json['pendingApplications'] as num).toInt(),
  openComplaints: (json['openComplaints'] as num).toInt(),
  activeJobs: (json['activeJobs'] as num).toInt(),
  lockedEscrowTotal: const MoneyConverter().fromJson(json['lockedEscrowTotal']),
);

Map<String, dynamic> _$AdminStatsToJson(_AdminStats instance) =>
    <String, dynamic>{
      'pendingApplications': instance.pendingApplications,
      'openComplaints': instance.openComplaints,
      'activeJobs': instance.activeJobs,
      'lockedEscrowTotal': const MoneyConverter().toJson(
        instance.lockedEscrowTotal,
      ),
    };

_AdminApplicationSummary _$AdminApplicationSummaryFromJson(
  Map<String, dynamic> json,
) => _AdminApplicationSummary(
  proId: idFromJson(json['proId']),
  fullName: json['fullName'] as String,
  businessName: json['businessName'] as String,
  categoryIds: json['categoryIds'] == null
      ? const <String>[]
      : idListFromJson(json['categoryIds']),
  districtNames:
      (json['districtNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  reviewStatus: $enumDecode(_$ReviewStatusEnumMap, json['reviewStatus']),
  documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AdminApplicationSummaryToJson(
  _AdminApplicationSummary instance,
) => <String, dynamic>{
  'proId': instance.proId,
  'fullName': instance.fullName,
  'businessName': instance.businessName,
  'categoryIds': idListToJson(instance.categoryIds),
  'districtNames': instance.districtNames,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
  'documentCount': instance.documentCount,
};

const _$ReviewStatusEnumMap = {
  ReviewStatus.pendingReview: 'PENDING_REVIEW',
  ReviewStatus.needsDocuments: 'NEEDS_DOCUMENTS',
  ReviewStatus.approved: 'APPROVED',
  ReviewStatus.rejected: 'REJECTED',
  ReviewStatus.suspended: 'SUSPENDED',
};

_AdminAction _$AdminActionFromJson(Map<String, dynamic> json) => _AdminAction(
  id: idFromJson(json['id']),
  action: json['action'] as String,
  note: json['note'] as String?,
  adminName: json['adminName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AdminActionToJson(_AdminAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'note': instance.note,
      'adminName': instance.adminName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_AdminApplicationDetail _$AdminApplicationDetailFromJson(
  Map<String, dynamic> json,
) => _AdminApplicationDetail(
  proId: idFromJson(json['proId']),
  fullName: json['fullName'] as String,
  businessName: json['businessName'] as String,
  categoryIds: json['categoryIds'] == null
      ? const <String>[]
      : idListFromJson(json['categoryIds']),
  districtNames:
      (json['districtNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  reviewStatus: $enumDecode(_$ReviewStatusEnumMap, json['reviewStatus']),
  documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  bio: json['bio'] as String? ?? '',
  experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
  reviewNote: json['reviewNote'] as String?,
  documents:
      (json['documents'] as List<dynamic>?)
          ?.map((e) => ApplicationDocument.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ApplicationDocument>[],
  history:
      (json['history'] as List<dynamic>?)
          ?.map((e) => AdminAction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AdminAction>[],
);

Map<String, dynamic> _$AdminApplicationDetailToJson(
  _AdminApplicationDetail instance,
) => <String, dynamic>{
  'proId': instance.proId,
  'fullName': instance.fullName,
  'businessName': instance.businessName,
  'categoryIds': idListToJson(instance.categoryIds),
  'districtNames': instance.districtNames,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
  'documentCount': instance.documentCount,
  'email': instance.email,
  'phone': instance.phone,
  'bio': instance.bio,
  'experienceYears': instance.experienceYears,
  'reviewNote': instance.reviewNote,
  'documents': instance.documents.map((e) => e.toJson()).toList(),
  'history': instance.history.map((e) => e.toJson()).toList(),
};

_ApproveApplicationRequest _$ApproveApplicationRequestFromJson(
  Map<String, dynamic> json,
) => _ApproveApplicationRequest(note: json['note'] as String?);

Map<String, dynamic> _$ApproveApplicationRequestToJson(
  _ApproveApplicationRequest instance,
) => <String, dynamic>{'note': ?instance.note};

_AdminNoteRequest _$AdminNoteRequestFromJson(Map<String, dynamic> json) =>
    _AdminNoteRequest(note: json['note'] as String);

Map<String, dynamic> _$AdminNoteRequestToJson(_AdminNoteRequest instance) =>
    <String, dynamic>{'note': instance.note};

_RequestDocumentsRequest _$RequestDocumentsRequestFromJson(
  Map<String, dynamic> json,
) => _RequestDocumentsRequest(
  note: json['note'] as String,
  documentTypes: (json['documentTypes'] as List<dynamic>)
      .map((e) => $enumDecode(_$ProDocumentTypeEnumMap, e))
      .toList(),
);

Map<String, dynamic> _$RequestDocumentsRequestToJson(
  _RequestDocumentsRequest instance,
) => <String, dynamic>{
  'note': instance.note,
  'documentTypes': instance.documentTypes
      .map((e) => _$ProDocumentTypeEnumMap[e]!)
      .toList(),
};

const _$ProDocumentTypeEnumMap = {
  ProDocumentType.identity: 'IDENTITY',
  ProDocumentType.tradeCert: 'TRADE_CERT',
  ProDocumentType.tax: 'TAX',
  ProDocumentType.criminalRecord: 'CRIMINAL_RECORD',
};

_AdminComplaintItem _$AdminComplaintItemFromJson(Map<String, dynamic> json) =>
    _AdminComplaintItem(
      id: idFromJson(json['id']),
      publicCode: json['publicCode'] as String,
      jobId: idFromJson(json['jobId']),
      jobPublicCode: json['jobPublicCode'] as String,
      reason: $enumDecode(_$ComplaintReasonEnumMap, json['reason']),
      status: $enumDecode(_$ComplaintStatusEnumMap, json['status']),
      customerName: json['customerName'] as String,
      proBusinessName: json['proBusinessName'] as String,
      amount: const MoneyConverter().fromJson(json['amount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminComplaintItemToJson(_AdminComplaintItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'jobId': instance.jobId,
      'jobPublicCode': instance.jobPublicCode,
      'reason': _$ComplaintReasonEnumMap[instance.reason]!,
      'status': _$ComplaintStatusEnumMap[instance.status]!,
      'customerName': instance.customerName,
      'proBusinessName': instance.proBusinessName,
      'amount': const MoneyConverter().toJson(instance.amount),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ComplaintReasonEnumMap = {
  ComplaintReason.noShow: 'NO_SHOW',
  ComplaintReason.incompleteWork: 'INCOMPLETE_WORK',
  ComplaintReason.extraCharge: 'EXTRA_CHARGE',
  ComplaintReason.rudeBehaviour: 'RUDE_BEHAVIOUR',
  ComplaintReason.other: 'OTHER',
};

const _$ComplaintStatusEnumMap = {
  ComplaintStatus.open: 'OPEN',
  ComplaintStatus.inReview: 'IN_REVIEW',
  ComplaintStatus.resolved: 'RESOLVED',
  ComplaintStatus.dismissed: 'DISMISSED',
};

_AdminComplaintJob _$AdminComplaintJobFromJson(Map<String, dynamic> json) =>
    _AdminComplaintJob(
      id: idFromJson(json['id']),
      publicCode: json['publicCode'] as String,
      title: json['title'] as String,
      status: $enumDecode(_$JobStatusEnumMap, json['status']),
      statusBeforeDispute: $enumDecodeNullable(
        _$JobStatusEnumMap,
        json['statusBeforeDispute'],
      ),
      timeline:
          (json['timeline'] as List<dynamic>?)
              ?.map((e) => JobEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <JobEvent>[],
      offer: OfferDetail.fromJson(json['offer'] as Map<String, dynamic>),
      districtName: json['districtName'] as String? ?? '',
    );

Map<String, dynamic> _$AdminComplaintJobToJson(_AdminComplaintJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'title': instance.title,
      'status': _$JobStatusEnumMap[instance.status]!,
      'statusBeforeDispute': _$JobStatusEnumMap[instance.statusBeforeDispute],
      'timeline': instance.timeline.map((e) => e.toJson()).toList(),
      'offer': instance.offer.toJson(),
      'districtName': instance.districtName,
    };

const _$JobStatusEnumMap = {
  JobStatus.awaitingAppointment: 'AWAITING_APPOINTMENT',
  JobStatus.scheduled: 'SCHEDULED',
  JobStatus.arrived: 'ARRIVED',
  JobStatus.inProgress: 'IN_PROGRESS',
  JobStatus.workFinished: 'WORK_FINISHED',
  JobStatus.completed: 'COMPLETED',
  JobStatus.disputed: 'DISPUTED',
  JobStatus.cancelled: 'CANCELLED',
  JobStatus.resolved: 'RESOLVED',
};

_AdminPaymentSummary _$AdminPaymentSummaryFromJson(Map<String, dynamic> json) =>
    _AdminPaymentSummary(
      ref: json['ref'] as String,
      status: json['status'] as String,
      provider: json['provider'] as String,
      totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
      commission: json['commission'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['commission']),
      proPayout: json['proPayout'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['proPayout']),
      refundedAmount: json['refundedAmount'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['refundedAmount']),
    );

Map<String, dynamic> _$AdminPaymentSummaryToJson(
  _AdminPaymentSummary instance,
) => <String, dynamic>{
  'ref': instance.ref,
  'status': instance.status,
  'provider': instance.provider,
  'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
  'commission': const MoneyConverter().toJson(instance.commission),
  'proPayout': const MoneyConverter().toJson(instance.proPayout),
  'refundedAmount': const MoneyConverter().toJson(instance.refundedAmount),
};

_AdminMessage _$AdminMessageFromJson(Map<String, dynamic> json) =>
    _AdminMessage(
      id: idFromJson(json['id']),
      senderRole: $enumDecode(_$PartyRoleEnumMap, json['senderRole']),
      body: json['body'] as String? ?? '',
      photo: json['photo'] == null
          ? null
          : MediaRef.fromJson(json['photo'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminMessageToJson(_AdminMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderRole': _$PartyRoleEnumMap[instance.senderRole]!,
      'body': instance.body,
      'photo': instance.photo?.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PartyRoleEnumMap = {
  PartyRole.customer: 'CUSTOMER',
  PartyRole.pro: 'PRO',
};

_AdminPartyCustomer _$AdminPartyCustomerFromJson(Map<String, dynamic> json) =>
    _AdminPartyCustomer(
      id: idFromJson(json['id']),
      fullName: json['fullName'] as String,
    );

Map<String, dynamic> _$AdminPartyCustomerToJson(_AdminPartyCustomer instance) =>
    <String, dynamic>{'id': instance.id, 'fullName': instance.fullName};

_AdminPartyPro _$AdminPartyProFromJson(Map<String, dynamic> json) =>
    _AdminPartyPro(
      id: idFromJson(json['id']),
      businessName: json['businessName'] as String,
      fullName: json['fullName'] as String,
      warningCount: (json['warningCount'] as num?)?.toInt() ?? 0,
      cancellationCount: (json['cancellationCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AdminPartyProToJson(_AdminPartyPro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessName': instance.businessName,
      'fullName': instance.fullName,
      'warningCount': instance.warningCount,
      'cancellationCount': instance.cancellationCount,
    };

_AdminComplaintDetail _$AdminComplaintDetailFromJson(
  Map<String, dynamic> json,
) => _AdminComplaintDetail(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  jobId: idFromJson(json['jobId']),
  reason: $enumDecode(_$ComplaintReasonEnumMap, json['reason']),
  description: json['description'] as String,
  evidence:
      (json['evidence'] as List<dynamic>?)
          ?.map((e) => MediaRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MediaRef>[],
  status: $enumDecode(_$ComplaintStatusEnumMap, json['status']),
  decision: json['decision'] as String?,
  decisionNote: json['decisionNote'] as String?,
  refundAmount: const NullableMoneyConverter().fromJson(json['refundAmount']),
  proAmount: const NullableMoneyConverter().fromJson(json['proAmount']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  decidedAt: json['decidedAt'] == null
      ? null
      : DateTime.parse(json['decidedAt'] as String),
  warnPro: json['warnPro'] as bool? ?? false,
  suspendPro: json['suspendPro'] as bool? ?? false,
  job: AdminComplaintJob.fromJson(json['job'] as Map<String, dynamic>),
  payment: json['payment'] == null
      ? null
      : AdminPaymentSummary.fromJson(json['payment'] as Map<String, dynamic>),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => AdminMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <AdminMessage>[],
  customer: AdminPartyCustomer.fromJson(
    json['customer'] as Map<String, dynamic>,
  ),
  pro: AdminPartyPro.fromJson(json['pro'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AdminComplaintDetailToJson(
  _AdminComplaintDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'publicCode': instance.publicCode,
  'jobId': instance.jobId,
  'reason': _$ComplaintReasonEnumMap[instance.reason]!,
  'description': instance.description,
  'evidence': instance.evidence.map((e) => e.toJson()).toList(),
  'status': _$ComplaintStatusEnumMap[instance.status]!,
  'decision': instance.decision,
  'decisionNote': instance.decisionNote,
  'refundAmount': const NullableMoneyConverter().toJson(instance.refundAmount),
  'proAmount': const NullableMoneyConverter().toJson(instance.proAmount),
  'createdAt': instance.createdAt.toIso8601String(),
  'decidedAt': instance.decidedAt?.toIso8601String(),
  'warnPro': instance.warnPro,
  'suspendPro': instance.suspendPro,
  'job': instance.job.toJson(),
  'payment': instance.payment?.toJson(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'customer': instance.customer.toJson(),
  'pro': instance.pro.toJson(),
};

_ComplaintDecisionRequest _$ComplaintDecisionRequestFromJson(
  Map<String, dynamic> json,
) => _ComplaintDecisionRequest(
  decision: $enumDecode(_$ComplaintDecisionEnumMap, json['decision']),
  note: json['note'] as String,
  warnPro: json['warnPro'] as bool? ?? false,
  suspendPro: json['suspendPro'] as bool? ?? false,
);

Map<String, dynamic> _$ComplaintDecisionRequestToJson(
  _ComplaintDecisionRequest instance,
) => <String, dynamic>{
  'decision': _$ComplaintDecisionEnumMap[instance.decision]!,
  'note': instance.note,
  'warnPro': instance.warnPro,
  'suspendPro': instance.suspendPro,
};

const _$ComplaintDecisionEnumMap = {
  ComplaintDecision.fullRefund: 'FULL_REFUND',
  ComplaintDecision.split5050: 'SPLIT_50_50',
  ComplaintDecision.releaseToPro: 'RELEASE_TO_PRO',
};

_AdminUserPro _$AdminUserProFromJson(Map<String, dynamic> json) =>
    _AdminUserPro(
      businessName: json['businessName'] as String,
      reviewStatus: $enumDecode(_$ReviewStatusEnumMap, json['reviewStatus']),
    );

Map<String, dynamic> _$AdminUserProToJson(_AdminUserPro instance) =>
    <String, dynamic>{
      'businessName': instance.businessName,
      'reviewStatus': _$ReviewStatusEnumMap[instance.reviewStatus]!,
    };

_AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => _AdminUser(
  id: idFromJson(json['id']),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  isAdmin: json['isAdmin'] as bool? ?? false,
  status: $enumDecode(_$AccountStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  pro: json['pro'] == null
      ? null
      : AdminUserPro.fromJson(json['pro'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AdminUserToJson(_AdminUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'isAdmin': instance.isAdmin,
      'status': _$AccountStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'pro': instance.pro?.toJson(),
    };

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'ACTIVE',
  AccountStatus.suspended: 'SUSPENDED',
  AccountStatus.deleted: 'DELETED',
};

_AdminPaymentRow _$AdminPaymentRowFromJson(Map<String, dynamic> json) =>
    _AdminPaymentRow(
      ref: json['ref'] as String,
      jobPublicCode: json['jobPublicCode'] as String?,
      status: json['status'] as String,
      provider: json['provider'] as String,
      totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
      commission: json['commission'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['commission']),
      proPayout: json['proPayout'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['proPayout']),
      refundedAmount: json['refundedAmount'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['refundedAmount']),
      customerName: json['customerName'] as String?,
      proBusinessName: json['proBusinessName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lockedAt: json['lockedAt'] == null
          ? null
          : DateTime.parse(json['lockedAt'] as String),
      releasedAt: json['releasedAt'] == null
          ? null
          : DateTime.parse(json['releasedAt'] as String),
      refundedAt: json['refundedAt'] == null
          ? null
          : DateTime.parse(json['refundedAt'] as String),
      errorCode: json['errorCode'] as String?,
    );

Map<String, dynamic> _$AdminPaymentRowToJson(_AdminPaymentRow instance) =>
    <String, dynamic>{
      'ref': instance.ref,
      'jobPublicCode': instance.jobPublicCode,
      'status': instance.status,
      'provider': instance.provider,
      'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
      'commission': const MoneyConverter().toJson(instance.commission),
      'proPayout': const MoneyConverter().toJson(instance.proPayout),
      'refundedAmount': const MoneyConverter().toJson(instance.refundedAmount),
      'customerName': instance.customerName,
      'proBusinessName': instance.proBusinessName,
      'createdAt': instance.createdAt.toIso8601String(),
      'lockedAt': instance.lockedAt?.toIso8601String(),
      'releasedAt': instance.releasedAt?.toIso8601String(),
      'refundedAt': instance.refundedAt?.toIso8601String(),
      'errorCode': instance.errorCode,
    };

_AdminPaymentTotals _$AdminPaymentTotalsFromJson(Map<String, dynamic> json) =>
    _AdminPaymentTotals(
      lockedTotal: json['lockedTotal'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['lockedTotal']),
      releasedTotal: json['releasedTotal'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['releasedTotal']),
      commissionTotal: json['commissionTotal'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['commissionTotal']),
      refundedTotal: json['refundedTotal'] == null
          ? Money.zero
          : const MoneyConverter().fromJson(json['refundedTotal']),
    );

Map<String, dynamic> _$AdminPaymentTotalsToJson(
  _AdminPaymentTotals instance,
) => <String, dynamic>{
  'lockedTotal': const MoneyConverter().toJson(instance.lockedTotal),
  'releasedTotal': const MoneyConverter().toJson(instance.releasedTotal),
  'commissionTotal': const MoneyConverter().toJson(instance.commissionTotal),
  'refundedTotal': const MoneyConverter().toJson(instance.refundedTotal),
};
