import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'jobs.dart';
import 'media_ref.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

/// Sohbet mesajı. `id` uzun bir sayıdır ve yoklama imleci olarak kullanılır.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required int id,
    required PartyRole senderRole,
    required bool mine,
    required String body,
    MediaRef? photo,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

/// `GET /jobs/{id}/messages` yanıtı (artan sırada).
@freezed
abstract class MessagePage with _$MessagePage {
  const factory MessagePage({
    @Default(<Message>[]) List<Message> items,
    int? otherLastReadId,
  }) = _MessagePage;

  factory MessagePage.fromJson(Map<String, dynamic> json) =>
      _$MessagePageFromJson(json);
}

@freezed
abstract class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String body,
    @JsonKey(
      includeIfNull: false,
      fromJson: idFromJsonNullable,
      toJson: _wireIdOrNull,
    )
    String? photoId,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}

Object? _wireIdOrNull(String? id) => id == null ? null : wireId(id);

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    @JsonKey(fromJson: idFromJson) required String jobId,
    required String publicCode,
    required String title,
    required JobCounterpart counterpart,
    Message? lastMessage,
    @Default(0) int unreadCount,
    required JobStatus jobStatus,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
