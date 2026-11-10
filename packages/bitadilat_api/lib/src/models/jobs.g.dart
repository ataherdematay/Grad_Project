// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JobCounterpart _$JobCounterpartFromJson(Map<String, dynamic> json) =>
    _JobCounterpart(
      id: idFromJson(json['id']),
      displayName: json['displayName'] as String,
    );

Map<String, dynamic> _$JobCounterpartToJson(_JobCounterpart instance) =>
    <String, dynamic>{'id': instance.id, 'displayName': instance.displayName};

_JobSummary _$JobSummaryFromJson(Map<String, dynamic> json) => _JobSummary(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  requestId: idFromJson(json['requestId']),
  title: json['title'] as String,
  categoryId: idFromJson(json['categoryId']),
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  viewerRole: $enumDecode(_$PartyRoleEnumMap, json['viewerRole']),
  counterpart: JobCounterpart.fromJson(
    json['counterpart'] as Map<String, dynamic>,
  ),
  totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
  scheduledFrom: json['scheduledFrom'] == null
      ? null
      : DateTime.parse(json['scheduledFrom'] as String),
  scheduledTo: json['scheduledTo'] == null
      ? null
      : DateTime.parse(json['scheduledTo'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  unreadMessages: (json['unreadMessages'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$JobSummaryToJson(_JobSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'requestId': instance.requestId,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'status': _$JobStatusEnumMap[instance.status]!,
      'viewerRole': _$PartyRoleEnumMap[instance.viewerRole]!,
      'counterpart': instance.counterpart.toJson(),
      'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
      'scheduledFrom': instance.scheduledFrom?.toIso8601String(),
      'scheduledTo': instance.scheduledTo?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'unreadMessages': instance.unreadMessages,
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

const _$PartyRoleEnumMap = {
  PartyRole.customer: 'CUSTOMER',
  PartyRole.pro: 'PRO',
};

_JobAddress _$JobAddressFromJson(Map<String, dynamic> json) => _JobAddress(
  districtName: json['districtName'] as String,
  neighborhood: json['neighborhood'] as String,
  lineFull: json['lineFull'] as String?,
  doorNote: json['doorNote'] as String?,
);

Map<String, dynamic> _$JobAddressToJson(_JobAddress instance) =>
    <String, dynamic>{
      'districtName': instance.districtName,
      'neighborhood': instance.neighborhood,
      'lineFull': instance.lineFull,
      'doorNote': instance.doorNote,
    };

_AppointmentProposal _$AppointmentProposalFromJson(Map<String, dynamic> json) =>
    _AppointmentProposal(
      id: idFromJson(json['id']),
      proposedBy: $enumDecode(_$PartyRoleEnumMap, json['proposedBy']),
      slotFrom: DateTime.parse(json['slotFrom'] as String),
      slotTo: DateTime.parse(json['slotTo'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppointmentProposalToJson(
  _AppointmentProposal instance,
) => <String, dynamic>{
  'id': instance.id,
  'proposedBy': _$PartyRoleEnumMap[instance.proposedBy]!,
  'slotFrom': instance.slotFrom.toIso8601String(),
  'slotTo': instance.slotTo.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

_JobAppointment _$JobAppointmentFromJson(Map<String, dynamic> json) =>
    _JobAppointment(
      scheduledFrom: json['scheduledFrom'] == null
          ? null
          : DateTime.parse(json['scheduledFrom'] as String),
      scheduledTo: json['scheduledTo'] == null
          ? null
          : DateTime.parse(json['scheduledTo'] as String),
      pendingProposal: json['pendingProposal'] == null
          ? null
          : AppointmentProposal.fromJson(
              json['pendingProposal'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$JobAppointmentToJson(_JobAppointment instance) =>
    <String, dynamic>{
      'scheduledFrom': instance.scheduledFrom?.toIso8601String(),
      'scheduledTo': instance.scheduledTo?.toIso8601String(),
      'pendingProposal': instance.pendingProposal?.toJson(),
    };

_JobEvent _$JobEventFromJson(Map<String, dynamic> json) => _JobEvent(
  id: idFromJson(json['id']),
  type: $enumDecode(_$JobEventTypeEnumMap, json['type']),
  fromStatus: $enumDecodeNullable(_$JobStatusEnumMap, json['fromStatus']),
  toStatus: $enumDecodeNullable(_$JobStatusEnumMap, json['toStatus']),
  note: json['note'] as String?,
  photo: json['photo'] == null
      ? null
      : MediaRef.fromJson(json['photo'] as Map<String, dynamic>),
  actorRole: $enumDecode(_$ActorRoleEnumMap, json['actorRole']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$JobEventToJson(_JobEvent instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$JobEventTypeEnumMap[instance.type]!,
  'fromStatus': _$JobStatusEnumMap[instance.fromStatus],
  'toStatus': _$JobStatusEnumMap[instance.toStatus],
  'note': instance.note,
  'photo': instance.photo?.toJson(),
  'actorRole': _$ActorRoleEnumMap[instance.actorRole]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$JobEventTypeEnumMap = {
  JobEventType.statusChanged: 'STATUS_CHANGED',
  JobEventType.note: 'NOTE',
  JobEventType.photo: 'PHOTO',
  JobEventType.appointmentProposed: 'APPOINTMENT_PROPOSED',
  JobEventType.appointmentAccepted: 'APPOINTMENT_ACCEPTED',
};

const _$ActorRoleEnumMap = {
  ActorRole.customer: 'CUSTOMER',
  ActorRole.pro: 'PRO',
  ActorRole.system: 'SYSTEM',
  ActorRole.admin: 'ADMIN',
};

_JobPayment _$JobPaymentFromJson(Map<String, dynamic> json) => _JobPayment(
  ref: json['ref'] as String,
  status: $enumDecode(_$EscrowStatusEnumMap, json['status']),
  totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
  refundedAmount: json['refundedAmount'] == null
      ? Money.zero
      : const MoneyConverter().fromJson(json['refundedAmount']),
  serviceFee: const NullableMoneyConverter().fromJson(json['serviceFee']),
  netEarning: const NullableMoneyConverter().fromJson(json['netEarning']),
);

Map<String, dynamic> _$JobPaymentToJson(_JobPayment instance) =>
    <String, dynamic>{
      'ref': instance.ref,
      'status': _$EscrowStatusEnumMap[instance.status]!,
      'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
      'refundedAmount': const MoneyConverter().toJson(instance.refundedAmount),
      'serviceFee': const NullableMoneyConverter().toJson(instance.serviceFee),
      'netEarning': const NullableMoneyConverter().toJson(instance.netEarning),
    };

const _$EscrowStatusEnumMap = {
  EscrowStatus.initialized: 'INITIALIZED',
  EscrowStatus.locked: 'LOCKED',
  EscrowStatus.failed: 'FAILED',
  EscrowStatus.refundedToCustomer: 'REFUNDED_TO_CUSTOMER',
  EscrowStatus.releasedToPro: 'RELEASED_TO_PRO',
  EscrowStatus.disputed: 'DISPUTED',
  EscrowStatus.splitSettled: 'SPLIT_SETTLED',
};

_ComplaintRef _$ComplaintRefFromJson(Map<String, dynamic> json) =>
    _ComplaintRef(
      id: idFromJson(json['id']),
      publicCode: json['publicCode'] as String,
      status: $enumDecode(_$ComplaintStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$ComplaintRefToJson(_ComplaintRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'status': _$ComplaintStatusEnumMap[instance.status]!,
    };

const _$ComplaintStatusEnumMap = {
  ComplaintStatus.open: 'OPEN',
  ComplaintStatus.inReview: 'IN_REVIEW',
  ComplaintStatus.resolved: 'RESOLVED',
  ComplaintStatus.dismissed: 'DISMISSED',
};

_JobDetail _$JobDetailFromJson(Map<String, dynamic> json) => _JobDetail(
  id: idFromJson(json['id']),
  publicCode: json['publicCode'] as String,
  requestId: idFromJson(json['requestId']),
  title: json['title'] as String,
  categoryId: idFromJson(json['categoryId']),
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  viewerRole: $enumDecode(_$PartyRoleEnumMap, json['viewerRole']),
  counterpart: JobCounterpart.fromJson(
    json['counterpart'] as Map<String, dynamic>,
  ),
  totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
  scheduledFrom: json['scheduledFrom'] == null
      ? null
      : DateTime.parse(json['scheduledFrom'] as String),
  scheduledTo: json['scheduledTo'] == null
      ? null
      : DateTime.parse(json['scheduledTo'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  unreadMessages: (json['unreadMessages'] as num?)?.toInt() ?? 0,
  offer: OfferDetail.fromJson(json['offer'] as Map<String, dynamic>),
  address: JobAddress.fromJson(json['address'] as Map<String, dynamic>),
  appointment: JobAppointment.fromJson(
    json['appointment'] as Map<String, dynamic>,
  ),
  timeline:
      (json['timeline'] as List<dynamic>?)
          ?.map((e) => JobEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <JobEvent>[],
  payment: JobPayment.fromJson(json['payment'] as Map<String, dynamic>),
  autoCompleteAt: json['autoCompleteAt'] == null
      ? null
      : DateTime.parse(json['autoCompleteAt'] as String),
  review: json['review'] == null
      ? null
      : ReviewItem.fromJson(json['review'] as Map<String, dynamic>),
  complaint: json['complaint'] == null
      ? null
      : ComplaintRef.fromJson(json['complaint'] as Map<String, dynamic>),
  allowedActions:
      (json['allowedActions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$JobDetailToJson(_JobDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'requestId': instance.requestId,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'status': _$JobStatusEnumMap[instance.status]!,
      'viewerRole': _$PartyRoleEnumMap[instance.viewerRole]!,
      'counterpart': instance.counterpart.toJson(),
      'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
      'scheduledFrom': instance.scheduledFrom?.toIso8601String(),
      'scheduledTo': instance.scheduledTo?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'unreadMessages': instance.unreadMessages,
      'offer': instance.offer.toJson(),
      'address': instance.address.toJson(),
      'appointment': instance.appointment.toJson(),
      'timeline': instance.timeline.map((e) => e.toJson()).toList(),
      'payment': instance.payment.toJson(),
      'autoCompleteAt': instance.autoCompleteAt?.toIso8601String(),
      'review': instance.review?.toJson(),
      'complaint': instance.complaint?.toJson(),
      'allowedActions': instance.allowedActions,
    };

_ProposeSlotRequest _$ProposeSlotRequestFromJson(Map<String, dynamic> json) =>
    _ProposeSlotRequest(
      slotFrom: DateTime.parse(json['slotFrom'] as String),
      slotTo: DateTime.parse(json['slotTo'] as String),
    );

Map<String, dynamic> _$ProposeSlotRequestToJson(_ProposeSlotRequest instance) =>
    <String, dynamic>{
      'slotFrom': instance.slotFrom.toIso8601String(),
      'slotTo': instance.slotTo.toIso8601String(),
    };

_FinishJobRequest _$FinishJobRequestFromJson(Map<String, dynamic> json) =>
    _FinishJobRequest(
      note: json['note'] as String,
      photoIds: json['photoIds'] == null
          ? const <String>[]
          : idListFromJson(json['photoIds']),
    );

Map<String, dynamic> _$FinishJobRequestToJson(_FinishJobRequest instance) =>
    <String, dynamic>{
      'note': instance.note,
      'photoIds': idListToJson(instance.photoIds),
    };

_JobNoteRequest _$JobNoteRequestFromJson(Map<String, dynamic> json) =>
    _JobNoteRequest(
      note: json['note'] as String?,
      photoIds: json['photoIds'] == null
          ? const <String>[]
          : idListFromJson(json['photoIds']),
    );

Map<String, dynamic> _$JobNoteRequestToJson(_JobNoteRequest instance) =>
    <String, dynamic>{
      'note': ?instance.note,
      'photoIds': idListToJson(instance.photoIds),
    };

_CancelJobRequest _$CancelJobRequestFromJson(Map<String, dynamic> json) =>
    _CancelJobRequest(
      reason: json['reason'] as String,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$CancelJobRequestToJson(_CancelJobRequest instance) =>
    <String, dynamic>{'reason': instance.reason, 'note': ?instance.note};

_ReviewRequest _$ReviewRequestFromJson(Map<String, dynamic> json) =>
    _ReviewRequest(
      rating: (json['rating'] as num).toInt(),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ReviewTagEnumMap, e))
              .toList() ??
          const <ReviewTag>[],
      comment: json['comment'] as String? ?? '',
      anonymous: json['anonymous'] as bool? ?? false,
    );

Map<String, dynamic> _$ReviewRequestToJson(_ReviewRequest instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'tags': instance.tags.map((e) => _$ReviewTagEnumMap[e]!).toList(),
      'comment': instance.comment,
      'anonymous': instance.anonymous,
    };

const _$ReviewTagEnumMap = {
  ReviewTag.onTime: 'ON_TIME',
  ReviewTag.cleanWork: 'CLEAN_WORK',
  ReviewTag.fairPrice: 'FAIR_PRICE',
  ReviewTag.goodCommunication: 'GOOD_COMMUNICATION',
  ReviewTag.polite: 'POLITE',
};

_ComplaintRequest _$ComplaintRequestFromJson(Map<String, dynamic> json) =>
    _ComplaintRequest(
      reason: $enumDecode(_$ComplaintReasonEnumMap, json['reason']),
      description: json['description'] as String,
      evidenceIds: json['evidenceIds'] == null
          ? const <String>[]
          : idListFromJson(json['evidenceIds']),
    );

Map<String, dynamic> _$ComplaintRequestToJson(_ComplaintRequest instance) =>
    <String, dynamic>{
      'reason': _$ComplaintReasonEnumMap[instance.reason]!,
      'description': instance.description,
      'evidenceIds': idListToJson(instance.evidenceIds),
    };

const _$ComplaintReasonEnumMap = {
  ComplaintReason.noShow: 'NO_SHOW',
  ComplaintReason.incompleteWork: 'INCOMPLETE_WORK',
  ComplaintReason.extraCharge: 'EXTRA_CHARGE',
  ComplaintReason.rudeBehaviour: 'RUDE_BEHAVIOUR',
  ComplaintReason.other: 'OTHER',
};

_Complaint _$ComplaintFromJson(Map<String, dynamic> json) => _Complaint(
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
  createdAt: DateTime.parse(json['createdAt'] as String),
  decidedAt: json['decidedAt'] == null
      ? null
      : DateTime.parse(json['decidedAt'] as String),
);

Map<String, dynamic> _$ComplaintToJson(_Complaint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'publicCode': instance.publicCode,
      'jobId': instance.jobId,
      'reason': _$ComplaintReasonEnumMap[instance.reason]!,
      'description': instance.description,
      'evidence': instance.evidence.map((e) => e.toJson()).toList(),
      'status': _$ComplaintStatusEnumMap[instance.status]!,
      'decision': instance.decision,
      'decisionNote': instance.decisionNote,
      'createdAt': instance.createdAt.toIso8601String(),
      'decidedAt': instance.decidedAt?.toIso8601String(),
    };
