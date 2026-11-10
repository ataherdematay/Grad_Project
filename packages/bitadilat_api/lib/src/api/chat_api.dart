import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/api_error.dart';
import '../models/chat.dart';
import '../models/enums.dart';

/// İş sohbeti ve konuşma listesi.
class ChatApi {
  ChatApi(this._dio);

  final Dio _dio;

  static const _jobs = '${ApiConfig.prefix}/jobs';

  /// `after`: bu kimlikten sonraki mesajlar (artan sırada).
  Future<MessagePage> messages(String jobId, {int? after, int? limit}) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_jobs/$jobId/messages',
        queryParameters: {'after': ?after, 'limit': ?limit},
      ),
    );
    return decodeApi(() => MessagePage.fromJson(res.data!));
  }

  Future<Message> send(String jobId, SendMessageRequest body) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_jobs/$jobId/messages',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => Message.fromJson(res.data!));
  }

  Future<void> markRead(String jobId, int lastReadId) async {
    await guardApi(
      () => _dio.post<void>(
        '$_jobs/$jobId/messages/read',
        data: {'lastReadId': lastReadId},
      ),
    );
  }

  Future<List<Conversation>> conversations(PartyRole role) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '${ApiConfig.prefix}/conversations',
        queryParameters: {'as': role.wire},
      ),
    );
    return decodeApi(
      () => [
        for (final e in (res.data!['items'] as List<dynamic>? ?? const []))
          Conversation.fromJson(e as Map<String, dynamic>),
      ],
    );
  }
}
