import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'core/api_config.dart';
import 'core/api_error.dart';
import 'models/json_helpers.dart';

part 'notifications.freezed.dart';
part 'notifications.g.dart';

/// Sözleşmedeki bildirim türleri. Sunucu yeni tür eklerse [unknown] olur;
/// istemci genel bir metin gösterir ve çökmez.
enum NotificationType {
  newMatchingRequest('NEW_MATCHING_REQUEST'),
  offerReceived('OFFER_RECEIVED'),
  offerDeclined('OFFER_DECLINED'),
  offerSuperseded('OFFER_SUPERSEDED'),
  offerAccepted('OFFER_ACCEPTED'),
  requestUpdated('REQUEST_UPDATED'),
  appointmentProposed('APPOINTMENT_PROPOSED'),
  appointmentConfirmed('APPOINTMENT_CONFIRMED'),
  jobStageChanged('JOB_STAGE_CHANGED'),
  workFinished('WORK_FINISHED'),
  autoCompleteReminder('AUTO_COMPLETE_REMINDER'),
  payoutReleased('PAYOUT_RELEASED'),
  jobCancelled('JOB_CANCELLED'),
  newMessage('NEW_MESSAGE'),
  complaintOpened('COMPLAINT_OPENED'),
  complaintDecided('COMPLAINT_DECIDED'),
  proApproved('PRO_APPROVED'),
  proRejected('PRO_REJECTED'),
  proNeedsDocuments('PRO_NEEDS_DOCUMENTS'),
  refundCompleted('REFUND_COMPLETED'),
  payoutCompleted('PAYOUT_COMPLETED'),
  unknown('');

  const NotificationType(this.wire);

  final String wire;

  static NotificationType fromWire(String? value) {
    for (final t in values) {
      if (t != unknown && t.wire == value) return t;
    }
    return unknown;
  }
}

/// Bildirim. Metin istemcide `type` ve `params`tan üretilir.
@freezed
abstract class Notification with _$Notification {
  const Notification._();

  const factory Notification({
    @JsonKey(fromJson: idFromJson) required String id,
    required String type,

    /// Düz nesne: metin ve sayılar. Biçim sunucuya bağlı olarak esnektir.
    @JsonKey(fromJson: _paramsFromJson)
    @Default(<String, dynamic>{})
    Map<String, dynamic> params,
    String? targetRoute,
    @Default(false) bool read,
    required DateTime createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  /// Bilinen tür; bilinmiyorsa [NotificationType.unknown].
  NotificationType get kind => NotificationType.fromWire(type);

  /// `params` içinden metin; sayı da metne çevrilir.
  String? param(String key) => params[key]?.toString();
}

Map<String, dynamic> _paramsFromJson(Object? value) => value is Map
    ? {for (final e in value.entries) e.key.toString(): e.value}
    : <String, dynamic>{};

/// `GET /notifications` yanıtı.
@immutable
class NotificationsPage {
  const NotificationsPage({
    required this.items,
    this.nextCursor,
    this.unreadCount = 0,
  });

  factory NotificationsPage.fromJson(Map<String, dynamic> json) =>
      NotificationsPage(
        items: [
          for (final e
              in (json['items'] as List<dynamic>? ?? const <dynamic>[]))
            Notification.fromJson(e as Map<String, dynamic>),
        ],
        nextCursor: json['nextCursor']?.toString(),
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      );

  final List<Notification> items;
  final String? nextCursor;
  final int unreadCount;

  bool get hasMore => nextCursor != null;
}

/// `PUT /devices` için platform.
enum DevicePlatform {
  ios('IOS'),
  android('ANDROID'),
  web('WEB');

  const DevicePlatform(this.wire);

  final String wire;
}

/// Bildirimler: `/notifications`.
class NotificationsApi {
  NotificationsApi(this._dio);

  final Dio _dio;

  static const _base = '${ApiConfig.prefix}/notifications';

  /// En yeniden eskiye. `limit` verilmezse sunucu varsayılanı uygulanır.
  Future<NotificationsPage> list({String? cursor, int? limit}) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {'cursor': ?cursor, 'limit': ?limit},
      ),
    );
    return decodeApi(() => NotificationsPage.fromJson(res.data!));
  }

  /// `ids` boşsa ya da verilmezse hepsi okundu olur (204).
  Future<void> markRead({List<String>? ids}) => guardApi(
    () => _dio.post<void>(
      '$_base/read',
      data: {if (ids != null && ids.isNotEmpty) 'ids': idListToJson(ids)},
    ),
  );

  Future<void> markAllRead() => markRead();
}

/// Cihaz kaydı: `PUT /devices`. Sunucu belirteci yalnız saklar (204).
class DevicesApi {
  DevicesApi(this._dio);

  final Dio _dio;

  Future<void> put({required DevicePlatform platform, required String token}) =>
      guardApi(
        () => _dio.put<void>(
          '${ApiConfig.prefix}/devices',
          data: {'platform': platform.wire, 'token': token},
        ),
      );
}
