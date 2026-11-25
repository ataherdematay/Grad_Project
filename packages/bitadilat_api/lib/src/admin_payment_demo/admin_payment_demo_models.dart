import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

import '../models/money.dart';

/// Admin ödeme demosu modelleri (API_V1 "payment demo").
///
/// Bilinmeyen enum değerleri çökertmesin diye durum, konum ve sağlayıcı metin
/// olarak tutulur; null alanlar her zaman gövdede bulunur.

Money _money(Object? v) => v == null ? Money.zero : Money.fromJson(v);
Money? _moneyOrNull(Object? v) => v == null ? null : Money.fromJson(v);
int _int(Object? v) => (v as num?)?.toInt() ?? 0;

/// `counts` bloğu.
@immutable
class AdminVaultCounts {
  const AdminVaultCounts({
    this.total = 0,
    this.vault = 0,
    this.locked = 0,
    this.disputed = 0,
    this.released = 0,
    this.refunded = 0,
    this.split = 0,
    this.failed = 0,
    this.pendingAction = 0,
    this.needsReview = 0,
    this.seed = 0,
  });

  factory AdminVaultCounts.fromJson(Map<String, dynamic> json) =>
      AdminVaultCounts(
        total: _int(json['total']),
        vault: _int(json['vault']),
        locked: _int(json['locked']),
        disputed: _int(json['disputed']),
        released: _int(json['released']),
        refunded: _int(json['refunded']),
        split: _int(json['split']),
        failed: _int(json['failed']),
        pendingAction: _int(json['pendingAction']),
        needsReview: _int(json['needsReview']),
        seed: _int(json['seed']),
      );

  final int total;
  final int vault;
  final int locked;
  final int disputed;
  final int released;
  final int refunded;
  final int split;
  final int failed;
  final int pendingAction;
  final int needsReview;
  final int seed;
}

/// `GET /admin/payments/summary`: kasa özeti.
@immutable
class AdminVaultSummary {
  const AdminVaultSummary({
    this.vaultTotal = Money.zero,
    this.paidToProsTotal = Money.zero,
    this.refundedToCustomersTotal = Money.zero,
    this.commissionEarnedTotal = Money.zero,
    this.counts = const AdminVaultCounts(),
    this.generatedAt,
  });

  factory AdminVaultSummary.fromJson(Map<String, dynamic> json) =>
      AdminVaultSummary(
        vaultTotal: _money(json['vaultTotal']),
        paidToProsTotal: _money(json['paidToProsTotal']),
        refundedToCustomersTotal: _money(json['refundedToCustomersTotal']),
        commissionEarnedTotal: _money(json['commissionEarnedTotal']),
        counts: json['counts'] is Map<String, dynamic>
            ? AdminVaultCounts.fromJson(json['counts'] as Map<String, dynamic>)
            : const AdminVaultCounts(),
        generatedAt: json['generatedAt'] == null
            ? null
            : DateTime.parse(json['generatedAt'] as String),
      );

  /// LOCKED + DISPUTED toplamı (güvence kasasında bekleyen).
  final Money vaultTotal;
  final Money paidToProsTotal;
  final Money refundedToCustomersTotal;
  final Money commissionEarnedTotal;
  final AdminVaultCounts counts;
  final DateTime? generatedAt;
}

/// Maskeli kart: yalnız marka ve son dört hane.
@immutable
class AdminPaymentTimelineCard {
  const AdminPaymentTimelineCard({this.brand, this.last4, this.masked});

  factory AdminPaymentTimelineCard.fromJson(Map<String, dynamic> json) =>
      AdminPaymentTimelineCard(
        brand: json['brand'] as String?,
        last4: json['last4'] as String?,
        masked: json['masked'] as String?,
      );

  final String? brand;
  final String? last4;
  final String? masked;
}

/// Brüt, komisyon, usta net ve iade. Admin görünümünde hepsi dolu olabilir.
@immutable
class AdminPaymentTimelineAmounts {
  const AdminPaymentTimelineAmounts({
    this.gross = Money.zero,
    this.commission,
    this.proNet,
    this.refunded = Money.zero,
  });

  factory AdminPaymentTimelineAmounts.fromJson(Map<String, dynamic> json) =>
      AdminPaymentTimelineAmounts(
        gross: _money(json['gross']),
        commission: _moneyOrNull(json['commission']),
        proNet: _moneyOrNull(json['proNet']),
        refunded: _money(json['refunded']),
      );

  final Money gross;
  final Money? commission;
  final Money? proNet;
  final Money refunded;
}

/// Zaman çizelgesi olayı. `type` bilinmeyen olabilir; `note` makine kodudur.
@immutable
class AdminPaymentTimelineEvent {
  const AdminPaymentTimelineEvent({
    required this.type,
    required this.at,
    this.amount,
    this.actor,
    this.note,
  });

  factory AdminPaymentTimelineEvent.fromJson(Map<String, dynamic> json) =>
      AdminPaymentTimelineEvent(
        type: json['type'] as String,
        at: DateTime.parse(json['at'] as String),
        amount: _moneyOrNull(json['amount']),
        actor: json['actor'] as String?,
        note: json['note'] as String?,
      );

  final String type;
  final DateTime at;
  final Money? amount;
  final String? actor;
  final String? note;
}

/// `GET /admin/payments/{ref}/timeline`.
@immutable
class AdminPaymentTimeline {
  const AdminPaymentTimeline({
    required this.paymentRef,
    this.jobId,
    this.jobPublicCode,
    this.jobTitle,
    required this.status,
    required this.moneyLocation,
    required this.provider,
    this.sandbox = true,
    this.craftgatePaymentId,
    this.card,
    this.amounts = const AdminPaymentTimelineAmounts(),
    this.autoReleaseAt,
    this.pendingAction,
    this.errorCode,
    this.events = const [],
  });

  factory AdminPaymentTimeline.fromJson(Map<String, dynamic> json) =>
      AdminPaymentTimeline(
        paymentRef: json['paymentRef'] as String,
        jobId: json['jobId']?.toString(),
        jobPublicCode: json['jobPublicCode'] as String?,
        jobTitle: json['jobTitle'] as String?,
        status: json['status'] as String,
        moneyLocation: json['moneyLocation'] as String,
        provider: json['provider'] as String,
        sandbox: json['sandbox'] as bool? ?? true,
        craftgatePaymentId: (json['craftgatePaymentId'] as num?)?.toInt(),
        card: json['card'] is Map<String, dynamic>
            ? AdminPaymentTimelineCard.fromJson(
                json['card'] as Map<String, dynamic>,
              )
            : null,
        amounts: json['amounts'] is Map<String, dynamic>
            ? AdminPaymentTimelineAmounts.fromJson(
                json['amounts'] as Map<String, dynamic>,
              )
            : const AdminPaymentTimelineAmounts(),
        autoReleaseAt: json['autoReleaseAt'] == null
            ? null
            : DateTime.parse(json['autoReleaseAt'] as String),
        pendingAction: json['pendingAction'] as String?,
        errorCode: json['errorCode'] as String?,
        events: [
          for (final e in (json['events'] as List<dynamic>? ?? const []))
            AdminPaymentTimelineEvent.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String paymentRef;
  final String? jobId;
  final String? jobPublicCode;
  final String? jobTitle;

  /// `LOCKED`, `DISPUTED`, `RELEASED_TO_PRO`, ... (bilinmeyen değer korunur).
  final String status;

  /// `CUSTOMER_CARD`, `BITADILAT_VAULT`, `PRO`, `CUSTOMER_REFUNDED`, `SPLIT`.
  final String moneyLocation;

  /// `CRAFTGATE`, `SEED`, `DEMO`.
  final String provider;
  final bool sandbox;
  final int? craftgatePaymentId;
  final AdminPaymentTimelineCard? card;
  final AdminPaymentTimelineAmounts amounts;
  final DateTime? autoReleaseAt;
  final String? pendingAction;
  final String? errorCode;
  final List<AdminPaymentTimelineEvent> events;
}
