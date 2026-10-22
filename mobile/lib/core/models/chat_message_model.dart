import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String jobId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  const ChatMessage({
    required this.id,
    required this.jobId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        senderId,
        senderName,
        text,
        timestamp,
        isFromMe,
      ];
}
