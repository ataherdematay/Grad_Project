// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: (json['id'] as num).toInt(),
  senderRole: $enumDecode(_$PartyRoleEnumMap, json['senderRole']),
  mine: json['mine'] as bool,
  body: json['body'] as String,
  photo: json['photo'] == null
      ? null
      : MediaRef.fromJson(json['photo'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'senderRole': _$PartyRoleEnumMap[instance.senderRole]!,
  'mine': instance.mine,
  'body': instance.body,
  'photo': instance.photo?.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$PartyRoleEnumMap = {
  PartyRole.customer: 'CUSTOMER',
  PartyRole.pro: 'PRO',
};

_MessagePage _$MessagePageFromJson(Map<String, dynamic> json) => _MessagePage(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Message>[],
  otherLastReadId: (json['otherLastReadId'] as num?)?.toInt(),
);

Map<String, dynamic> _$MessagePageToJson(_MessagePage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'otherLastReadId': instance.otherLastReadId,
    };

_SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    _SendMessageRequest(
      body: json['body'] as String,
      photoId: idFromJsonNullable(json['photoId']),
    );

Map<String, dynamic> _$SendMessageRequestToJson(_SendMessageRequest instance) =>
    <String, dynamic>{
      'body': instance.body,
      'photoId': ?_wireIdOrNull(instance.photoId),
    };

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      jobId: idFromJson(json['jobId']),
      publicCode: json['publicCode'] as String,
      title: json['title'] as String,
      counterpart: JobCounterpart.fromJson(
        json['counterpart'] as Map<String, dynamic>,
      ),
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      jobStatus: $enumDecode(_$JobStatusEnumMap, json['jobStatus']),
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'publicCode': instance.publicCode,
      'title': instance.title,
      'counterpart': instance.counterpart.toJson(),
      'lastMessage': instance.lastMessage?.toJson(),
      'unreadCount': instance.unreadCount,
      'jobStatus': _$JobStatusEnumMap[instance.jobStatus]!,
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
