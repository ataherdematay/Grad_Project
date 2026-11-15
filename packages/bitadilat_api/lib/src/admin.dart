import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'core/api_config.dart';
import 'core/api_error.dart';
import 'models/enums.dart';
import 'models/jobs.dart';
import 'models/json_helpers.dart';
import 'models/media_ref.dart';
import 'models/money.dart';
import 'models/offers.dart';
import 'models/pro.dart';

part 'admin.freezed.dart';
part 'admin.g.dart';

// --- Enumlar -----------------------------------------------------------------

/// Hesap durumu (`users.status`, STATE_MACHINES §1).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AccountStatus { active, suspended, deleted }

/// Hesaplar listesindeki rol süzgeci.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AccountRole { customer, pro, admin }

/// Yönetici şikayet kararı (STATE_MACHINES §5).
@JsonEnum(alwaysCreate: true)
enum ComplaintDecision {
  @JsonValue('FULL_REFUND')
  fullRefund,
  @JsonValue('SPLIT_50_50')
  split5050,
  @JsonValue('RELEASE_TO_PRO')
  releaseToPro;

  /// Sunucudaki değer (`FULL_REFUND`, `SPLIT_50_50`, `RELEASE_TO_PRO`).
  String get code => switch (this) {
    ComplaintDecision.fullRefund => 'FULL_REFUND',
    ComplaintDecision.split5050 => 'SPLIT_50_50',
    ComplaintDecision.releaseToPro => 'RELEASE_TO_PRO',
  };

  static ComplaintDecision? tryParse(String? code) {
    for (final d in ComplaintDecision.values) {
      if (d.code == code) return d;
    }
    return null;
  }
}

// --- Modeller --------------------------------------------------------------------

@freezed
abstract class AdminStats with _$AdminStats {
  const factory AdminStats({
    required int pendingApplications,
    required int openComplaints,
    required int activeJobs,
    @MoneyConverter() required Money lockedEscrowTotal,
  }) = _AdminStats;

  factory AdminStats.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsFromJson(json);
}

@freezed
abstract class AdminApplicationSummary with _$AdminApplicationSummary {
  const factory AdminApplicationSummary({
    @JsonKey(fromJson: idFromJson) required String proId,
    required String fullName,
    required String businessName,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> categoryIds,
    @Default(<String>[]) List<String> districtNames,
    DateTime? submittedAt,
    required ReviewStatus reviewStatus,
    @Default(0) int documentCount,
  }) = _AdminApplicationSummary;

  factory AdminApplicationSummary.fromJson(Map<String, dynamic> json) =>
      _$AdminApplicationSummaryFromJson(json);
}

/// Yönetici işlem kaydı (`admin_actions`).
@freezed
abstract class AdminAction with _$AdminAction {
  const factory AdminAction({
    @JsonKey(fromJson: idFromJson) required String id,
    required String action,
    String? note,
    required String adminName,
    required DateTime createdAt,
  }) = _AdminAction;

  factory AdminAction.fromJson(Map<String, dynamic> json) =>
      _$AdminActionFromJson(json);
}

@freezed
abstract class AdminApplicationDetail with _$AdminApplicationDetail {
  const factory AdminApplicationDetail({
    @JsonKey(fromJson: idFromJson) required String proId,
    required String fullName,
    required String businessName,
    @JsonKey(fromJson: idListFromJson, toJson: idListToJson)
    @Default(<String>[])
    List<String> categoryIds,
    @Default(<String>[]) List<String> districtNames,
    DateTime? submittedAt,
    required ReviewStatus reviewStatus,
    @Default(0) int documentCount,
    required String email,
    String? phone,
    @Default('') String bio,
    @Default(0) int experienceYears,
    String? reviewNote,
    @Default(<ApplicationDocument>[]) List<ApplicationDocument> documents,
    @Default(<AdminAction>[]) List<AdminAction> history,
  }) = _AdminApplicationDetail;

  factory AdminApplicationDetail.fromJson(Map<String, dynamic> json) =>
      _$AdminApplicationDetailFromJson(json);
}

@freezed
abstract class ApproveApplicationRequest with _$ApproveApplicationRequest {
  const factory ApproveApplicationRequest({
    @JsonKey(includeIfNull: false) String? note,
  }) = _ApproveApplicationRequest;

  factory ApproveApplicationRequest.fromJson(Map<String, dynamic> json) =>
      _$ApproveApplicationRequestFromJson(json);
}

/// Ret ve askıya alma gibi yalnız not alan gövde.
@freezed
abstract class AdminNoteRequest with _$AdminNoteRequest {
  const factory AdminNoteRequest({required String note}) = _AdminNoteRequest;

  factory AdminNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminNoteRequestFromJson(json);
}

@freezed
abstract class RequestDocumentsRequest with _$RequestDocumentsRequest {
  const factory RequestDocumentsRequest({
    required String note,
    required List<ProDocumentType> documentTypes,
  }) = _RequestDocumentsRequest;

  factory RequestDocumentsRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestDocumentsRequestFromJson(json);
}

@freezed
abstract class AdminComplaintItem with _$AdminComplaintItem {
  const factory AdminComplaintItem({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String jobId,
    required String jobPublicCode,
    required ComplaintReason reason,
    required ComplaintStatus status,
    required String customerName,
    required String proBusinessName,
    @MoneyConverter() required Money amount,
    required DateTime createdAt,
  }) = _AdminComplaintItem;

  factory AdminComplaintItem.fromJson(Map<String, dynamic> json) =>
      _$AdminComplaintItemFromJson(json);
}

/// Şikayete bağlı iş: zaman çizelgesi ve teklif dahil.
@freezed
abstract class AdminComplaintJob with _$AdminComplaintJob {
  const factory AdminComplaintJob({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    required String title,
    required JobStatus status,
    JobStatus? statusBeforeDispute,
    @Default(<JobEvent>[]) List<JobEvent> timeline,
    required OfferDetail offer,
    @Default('') String districtName,
  }) = _AdminComplaintJob;

  factory AdminComplaintJob.fromJson(Map<String, dynamic> json) =>
      _$AdminComplaintJobFromJson(json);
}

/// Şikayet ekranındaki ödeme özeti. `status` emanet durumudur; bilinmeyen
/// durumlar çökertmesin diye metin tutulur.
@freezed
abstract class AdminPaymentSummary with _$AdminPaymentSummary {
  const factory AdminPaymentSummary({
    required String ref,
    required String status,
    required String provider,
    @MoneyConverter() required Money totalAmount,
    @MoneyConverter() @Default(Money.zero) Money commission,
    @MoneyConverter() @Default(Money.zero) Money proPayout,
    @MoneyConverter() @Default(Money.zero) Money refundedAmount,
  }) = _AdminPaymentSummary;

  factory AdminPaymentSummary.fromJson(Map<String, dynamic> json) =>
      _$AdminPaymentSummaryFromJson(json);
}

@freezed
abstract class AdminMessage with _$AdminMessage {
  const factory AdminMessage({
    @JsonKey(fromJson: idFromJson) required String id,
    required PartyRole senderRole,
    @Default('') String body,
    MediaRef? photo,
    required DateTime createdAt,
  }) = _AdminMessage;

  factory AdminMessage.fromJson(Map<String, dynamic> json) =>
      _$AdminMessageFromJson(json);
}

@freezed
abstract class AdminPartyCustomer with _$AdminPartyCustomer {
  const factory AdminPartyCustomer({
    @JsonKey(fromJson: idFromJson) required String id,
    required String fullName,
  }) = _AdminPartyCustomer;

  factory AdminPartyCustomer.fromJson(Map<String, dynamic> json) =>
      _$AdminPartyCustomerFromJson(json);
}

@freezed
abstract class AdminPartyPro with _$AdminPartyPro {
  const factory AdminPartyPro({
    @JsonKey(fromJson: idFromJson) required String id,
    required String businessName,
    required String fullName,
    @Default(0) int warningCount,
    @Default(0) int cancellationCount,
  }) = _AdminPartyPro;

  factory AdminPartyPro.fromJson(Map<String, dynamic> json) =>
      _$AdminPartyProFromJson(json);
}

/// `Complaint` alanları + iş, ödeme, sohbet ve taraflar.
@freezed
abstract class AdminComplaintDetail with _$AdminComplaintDetail {
  const factory AdminComplaintDetail({
    @JsonKey(fromJson: idFromJson) required String id,
    required String publicCode,
    @JsonKey(fromJson: idFromJson) required String jobId,
    required ComplaintReason reason,
    required String description,
    @Default(<MediaRef>[]) List<MediaRef> evidence,
    required ComplaintStatus status,
    String? decision,
    String? decisionNote,
    @NullableMoneyConverter() Money? refundAmount,
    @NullableMoneyConverter() Money? proAmount,
    required DateTime createdAt,
    DateTime? decidedAt,
    /// Karar bayrakları (karar verilmeden önce `false`).
    @Default(false) bool warnPro,
    @Default(false) bool suspendPro,
    required AdminComplaintJob job,

    /// Sunucu emanet kaydı yoksa `null` döner.
    AdminPaymentSummary? payment,
    @Default(<AdminMessage>[]) List<AdminMessage> messages,
    required AdminPartyCustomer customer,
    required AdminPartyPro pro,
  }) = _AdminComplaintDetail;

  factory AdminComplaintDetail.fromJson(Map<String, dynamic> json) =>
      _$AdminComplaintDetailFromJson(json);
}

@freezed
abstract class ComplaintDecisionRequest with _$ComplaintDecisionRequest {
  const factory ComplaintDecisionRequest({
    required ComplaintDecision decision,
    required String note,
    @Default(false) bool warnPro,
    @Default(false) bool suspendPro,
  }) = _ComplaintDecisionRequest;

  factory ComplaintDecisionRequest.fromJson(Map<String, dynamic> json) =>
      _$ComplaintDecisionRequestFromJson(json);
}

@freezed
abstract class AdminUserPro with _$AdminUserPro {
  const factory AdminUserPro({
    required String businessName,
    required ReviewStatus reviewStatus,
  }) = _AdminUserPro;

  factory AdminUserPro.fromJson(Map<String, dynamic> json) =>
      _$AdminUserProFromJson(json);
}

@freezed
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    @JsonKey(fromJson: idFromJson) required String id,
    required String fullName,
    required String email,
    String? phone,
    @Default(false) bool isAdmin,
    required AccountStatus status,
    required DateTime createdAt,
    AdminUserPro? pro,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}

/// `POST /admin/users/{id}/suspend` yanıtı: açık işler ayrıca uyarılır.
@immutable
class SuspendResult {
  const SuspendResult({this.activeJobCount = 0});

  /// Askıya alınan hesabın hâlâ süren işlerinin sayısı (işlere dokunulmaz).
  final int activeJobCount;
}

@freezed
abstract class AdminPaymentRow with _$AdminPaymentRow {
  const factory AdminPaymentRow({
    required String ref,
    String? jobPublicCode,
    required String status,
    required String provider,
    @MoneyConverter() required Money totalAmount,
    @MoneyConverter() @Default(Money.zero) Money commission,
    @MoneyConverter() @Default(Money.zero) Money proPayout,
    @MoneyConverter() @Default(Money.zero) Money refundedAmount,
    String? customerName,
    String? proBusinessName,
    required DateTime createdAt,
    DateTime? lockedAt,
    DateTime? releasedAt,
    DateTime? refundedAt,
    String? errorCode,
  }) = _AdminPaymentRow;

  factory AdminPaymentRow.fromJson(Map<String, dynamic> json) =>
      _$AdminPaymentRowFromJson(json);
}

@freezed
abstract class AdminPaymentTotals with _$AdminPaymentTotals {
  const factory AdminPaymentTotals({
    @MoneyConverter() @Default(Money.zero) Money lockedTotal,
    @MoneyConverter() @Default(Money.zero) Money releasedTotal,
    @MoneyConverter() @Default(Money.zero) Money commissionTotal,
    @MoneyConverter() @Default(Money.zero) Money refundedTotal,
  }) = _AdminPaymentTotals;

  factory AdminPaymentTotals.fromJson(Map<String, dynamic> json) =>
      _$AdminPaymentTotalsFromJson(json);
}

/// `GET /admin/payments` yanıtı: `{items, totals}`.
@immutable
class AdminPayments {
  const AdminPayments({required this.items, required this.totals});

  factory AdminPayments.fromJson(Map<String, dynamic> json) => AdminPayments(
    items: [
      for (final e in (json['items'] as List<dynamic>? ?? const <dynamic>[]))
        AdminPaymentRow.fromJson(e as Map<String, dynamic>),
    ],
    totals: json['totals'] == null
        ? const AdminPaymentTotals()
        : AdminPaymentTotals.fromJson(json['totals'] as Map<String, dynamic>),
  );

  final List<AdminPaymentRow> items;
  final AdminPaymentTotals totals;
}

// --- API ---------------------------------------------------------------------------

/// `/admin/**` uç noktaları (yalnız `isAdmin = true`).
class AdminApi {
  AdminApi(this._dio);

  final Dio _dio;

  static const _p = '${ApiConfig.prefix}/admin';

  Map<String, dynamic> _query(Map<String, String?> raw) => {
    for (final e in raw.entries)
      if (e.value != null && e.value!.trim().isNotEmpty) e.key: e.value!.trim(),
  };

  List<T> _items<T>(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) from,
  ) => [
    for (final e in (body['items'] as List<dynamic>? ?? const <dynamic>[]))
      from(e as Map<String, dynamic>),
  ];

  Future<AdminStats> stats() async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_p/stats'),
    );
    return decodeApi(() => AdminStats.fromJson(res.data!));
  }

  // Başvurular

  Future<List<AdminApplicationSummary>> applications({
    ReviewStatus? status,
    String? q,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_p/applications',
        queryParameters: _query({'status': status?.wire, 'q': q}),
      ),
    );
    return decodeApi(() => _items(res.data!, AdminApplicationSummary.fromJson));
  }

  Future<AdminApplicationDetail> application(String proId) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_p/applications/$proId'),
    );
    return decodeApi(() => AdminApplicationDetail.fromJson(res.data!));
  }

  Future<AdminApplicationDetail> _applicationAction(
    String proId,
    String action,
    Map<String, dynamic> body,
  ) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_p/applications/$proId/$action',
        data: body,
      ),
    );
    return decodeApi(() => AdminApplicationDetail.fromJson(res.data!));
  }

  Future<AdminApplicationDetail> approve(String proId, {String? note}) =>
      _applicationAction(
        proId,
        'approve',
        ApproveApplicationRequest(note: note).toJson(),
      );

  /// `note`: 10-1000 karakter.
  Future<AdminApplicationDetail> reject(String proId, String note) =>
      _applicationAction(proId, 'reject', AdminNoteRequest(note: note).toJson());

  /// `note`: 10-1000 karakter; en az bir belge türü.
  Future<AdminApplicationDetail> requestDocuments(
    String proId, {
    required String note,
    required List<ProDocumentType> documentTypes,
  }) => _applicationAction(
    proId,
    'request-documents',
    RequestDocumentsRequest(note: note, documentTypes: documentTypes).toJson(),
  );

  // Şikayetler

  Future<List<AdminComplaintItem>> complaints({ComplaintStatus? status}) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_p/complaints',
        queryParameters: _query({'status': status?.wire}),
      ),
    );
    return decodeApi(() => _items(res.data!, AdminComplaintItem.fromJson));
  }

  Future<AdminComplaintDetail> complaint(String id) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>('$_p/complaints/$id'),
    );
    return decodeApi(() => AdminComplaintDetail.fromJson(res.data!));
  }

  Future<AdminComplaintDetail> reviewComplaint(String id) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>('$_p/complaints/$id/review'),
    );
    return decodeApi(() => AdminComplaintDetail.fromJson(res.data!));
  }

  Future<AdminComplaintDetail> decideComplaint(
    String id,
    ComplaintDecisionRequest body,
  ) async {
    final res = await guardApi(
      () => _dio.post<Map<String, dynamic>>(
        '$_p/complaints/$id/decision',
        data: body.toJson(),
      ),
    );
    return decodeApi(() => AdminComplaintDetail.fromJson(res.data!));
  }

  // Hesaplar

  Future<List<AdminUser>> users({
    String? q,
    AccountRole? role,
    AccountStatus? status,
  }) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_p/users',
        queryParameters: _query({
          'q': q,
          'role': role?.wire,
          'status': status?.wire,
        }),
      ),
    );
    return decodeApi(() => _items(res.data!, AdminUser.fromJson));
  }

  /// `note`: 10-1000 karakter.
  Future<SuspendResult> suspendUser(String id, String note) async {
    final res = await guardApi(
      () => _dio.post<dynamic>(
        '$_p/users/$id/suspend',
        data: AdminNoteRequest(note: note).toJson(),
      ),
    );
    final data = res.data;
    final count = data is Map ? data['activeJobCount'] : null;
    return SuspendResult(activeJobCount: count is num ? count.toInt() : 0);
  }

  Future<void> reactivateUser(String id) =>
      guardApi(() => _dio.post<dynamic>('$_p/users/$id/reactivate'));

  // Ödemeler

  Future<AdminPayments> payments({String? status}) async {
    final res = await guardApi(
      () => _dio.get<Map<String, dynamic>>(
        '$_p/payments',
        queryParameters: _query({'status': status}),
      ),
    );
    return decodeApi(() => AdminPayments.fromJson(res.data!));
  }
}
