import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

import '../models/enums.dart';
import '../models/json_helpers.dart';
import '../models/money.dart';

/// Paranın şu anki yeri (`moneyLocation`). Bilinmeyen değer `unknown`.
enum MoneyLocation {
  customerCard('CUSTOMER_CARD'),
  vault('BITADILAT_VAULT'),
  pro('PRO'),
  customerRefunded('CUSTOMER_REFUNDED'),
  split('SPLIT'),
  unknown('UNKNOWN');

  const MoneyLocation(this.wire);

  final String wire;

  static MoneyLocation parse(Object? raw) {
    for (final v in MoneyLocation.values) {
      if (v != MoneyLocation.unknown && v.wire == raw) return v;
    }
    return MoneyLocation.unknown;
  }
}

/// Ödeme sağlayıcısı (`provider`).
enum PaymentProviderKind {
  craftgate('CRAFTGATE'),
  seed('SEED'),
  demo('DEMO'),
  unknown('UNKNOWN');

  const PaymentProviderKind(this.wire);

  final String wire;

  static PaymentProviderKind parse(Object? raw) {
    for (final v in PaymentProviderKind.values) {
      if (v != PaymentProviderKind.unknown && v.wire == raw) return v;
    }
    return PaymentProviderKind.unknown;
  }
}

/// Zaman çizelgesi olay türü. Bilinmeyen tür `unknown` (genel satır).
enum PaymentEventType {
  paymentInitialized('PAYMENT_INITIALIZED'),
  threedsStarted('THREEDS_STARTED'),
  paymentLocked('PAYMENT_LOCKED'),
  workDelivered('WORK_DELIVERED'),
  autoReleaseScheduled('AUTO_RELEASE_SCHEDULED'),
  disputeOpened('DISPUTE_OPENED'),
  customerApproved('CUSTOMER_APPROVED'),
  autoApproved('AUTO_APPROVED'),
  refundRequested('REFUND_REQUESTED'),
  releasedToPro('RELEASED_TO_PRO'),
  refunded('REFUNDED'),
  splitSettled('SPLIT_SETTLED'),
  reviewRequired('REVIEW_REQUIRED'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const PaymentEventType(this.wire);

  final String wire;

  static PaymentEventType parse(Object? raw) {
    for (final v in PaymentEventType.values) {
      if (v != PaymentEventType.unknown && v.wire == raw) return v;
    }
    return PaymentEventType.unknown;
  }
}

EscrowStatus _escrow(Object? raw) {
  for (final v in EscrowStatus.values) {
    final wire = v.name
        .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}')
        .toUpperCase();
    if (wire == raw) return v;
  }
  return EscrowStatus.locked;
}

Money? _money(Object? v) => v == null ? null : Money.fromJson(v);

DateTime? _time(Object? v) => v == null ? null : DateTime.parse(v as String);

/// Maskeli kart: yalnız marka ve son hane.
@immutable
class PaymentCard {
  const PaymentCard({this.brand, required this.last4, required this.masked});

  factory PaymentCard.fromJson(Map<String, dynamic> j) => PaymentCard(
    brand: j['brand'] as String?,
    last4: (j['last4'] ?? '').toString(),
    masked: (j['masked'] ?? '').toString(),
  );

  /// `VISA`, `MASTERCARD`, `TROY`, `AMEX` ya da bilinmiyorsa `null`.
  final String? brand;
  final String last4;

  /// `**** **** **** 0001`
  final String masked;

  @override
  bool operator ==(Object other) =>
      other is PaymentCard &&
      other.brand == brand &&
      other.last4 == last4 &&
      other.masked == masked;

  @override
  int get hashCode => Object.hash(brand, last4, masked);
}

/// Tutarlar. Müşteride `commission` ve `proNet` `null`.
@immutable
class PaymentAmounts {
  const PaymentAmounts({
    required this.gross,
    this.commission,
    this.proNet,
    this.refunded = Money.zero,
  });

  factory PaymentAmounts.fromJson(Map<String, dynamic> j) => PaymentAmounts(
    gross: Money.fromJson(j['gross'] ?? 0),
    commission: _money(j['commission']),
    proNet: _money(j['proNet']),
    refunded: _money(j['refunded']) ?? Money.zero,
  );

  final Money gross;
  final Money? commission;
  final Money? proNet;
  final Money refunded;
}

@immutable
class PaymentEvent {
  const PaymentEvent({
    required this.type,
    required this.at,
    this.amount,
    this.actor,
    this.note,
  });

  factory PaymentEvent.fromJson(Map<String, dynamic> j) => PaymentEvent(
    type: PaymentEventType.parse(j['type']),
    at: DateTime.parse(j['at'] as String),
    amount: _money(j['amount']),
    actor: j['actor'] as String?,
    note: j['note'] as String?,
  );

  final PaymentEventType type;
  final DateTime at;
  final Money? amount;

  /// `CUSTOMER`, `PRO`, `SYSTEM`, `ADMIN` (açık uçlu).
  final String? actor;

  /// Makine kodu; metni istemci çevirir.
  final String? note;
}

/// `GET /jobs/{id}/payment/timeline` ve `GET /admin/payments/{ref}/timeline`.
@immutable
class PaymentTimeline {
  const PaymentTimeline({
    required this.paymentRef,
    this.jobId,
    this.jobPublicCode,
    this.jobTitle,
    required this.status,
    required this.moneyLocation,
    required this.provider,
    required this.sandbox,
    this.craftgatePaymentId,
    this.card,
    required this.amounts,
    this.autoReleaseAt,
    this.pendingAction,
    this.errorCode,
    this.events = const [],
  });

  factory PaymentTimeline.fromJson(Map<String, dynamic> j) => PaymentTimeline(
    paymentRef: idFromJson(j['paymentRef']),
    jobId: idFromJsonNullable(j['jobId']),
    jobPublicCode: j['jobPublicCode'] as String?,
    jobTitle: j['jobTitle'] as String?,
    status: _escrow(j['status']),
    moneyLocation: MoneyLocation.parse(j['moneyLocation']),
    provider: PaymentProviderKind.parse(j['provider']),
    sandbox: j['sandbox'] as bool? ?? true,
    craftgatePaymentId: (j['craftgatePaymentId'] as num?)?.toInt(),
    card: j['card'] == null
        ? null
        : PaymentCard.fromJson(j['card'] as Map<String, dynamic>),
    amounts: PaymentAmounts.fromJson(
      (j['amounts'] as Map<String, dynamic>?) ?? const {},
    ),
    autoReleaseAt: _time(j['autoReleaseAt']),
    pendingAction: j['pendingAction'] as String?,
    errorCode: j['errorCode'] as String?,
    events: [
      for (final e in (j['events'] as List<dynamic>? ?? const <dynamic>[]))
        PaymentEvent.fromJson(e as Map<String, dynamic>),
    ],
  );

  final String paymentRef;
  final String? jobId;
  final String? jobPublicCode;
  final String? jobTitle;
  final EscrowStatus status;
  final MoneyLocation moneyLocation;
  final PaymentProviderKind provider;
  final bool sandbox;
  final int? craftgatePaymentId;

  /// Usta görünümünde `null`.
  final PaymentCard? card;
  final PaymentAmounts amounts;

  /// Yalnız iş `WORK_FINISHED` ve emanet `LOCKED` iken dolu.
  final DateTime? autoReleaseAt;

  /// `REFUND`, `RELEASE` ya da `null`.
  final String? pendingAction;
  final String? errorCode;
  final List<PaymentEvent> events;

  bool get needsReview =>
      errorCode == 'REFUND_NEEDS_REVIEW' || errorCode == 'PAYOUT_NEEDS_REVIEW';
}

enum ReceiptItemKind { labor, material }

@immutable
class ReceiptItem {
  const ReceiptItem({
    required this.kind,
    required this.label,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> j) => ReceiptItem(
    kind: j['kind'] == 'MATERIAL'
        ? ReceiptItemKind.material
        : ReceiptItemKind.labor,
    label: (j['label'] ?? '').toString(),
    quantity: (j['quantity'] as num?)?.toDouble() ?? 1,
    unitPrice: Money.fromJson(j['unitPrice'] ?? 0),
    amount: Money.fromJson(j['amount'] ?? 0),
  );

  final ReceiptItemKind kind;
  final String label;
  final double quantity;
  final Money unitPrice;
  final Money amount;
}

/// `GET /jobs/{id}/payment/receipt` (müşteri ve yönetici).
@immutable
class PaymentReceipt {
  const PaymentReceipt({
    required this.receiptNo,
    required this.issuedAt,
    required this.paymentRef,
    this.jobId,
    this.jobPublicCode,
    this.jobTitle,
    this.proName,
    this.customerName,
    this.items = const [],
    required this.total,
    this.refundedTotal = Money.zero,
    required this.netPaid,
    this.currency = 'TRY',
    this.card,
    required this.status,
    required this.moneyLocation,
    required this.provider,
    required this.sandbox,
    this.sandboxNotice,
  });

  factory PaymentReceipt.fromJson(Map<String, dynamic> j) {
    final total = Money.fromJson(j['total'] ?? 0);
    final refunded = _money(j['refundedTotal']) ?? Money.zero;
    return PaymentReceipt(
      receiptNo: (j['receiptNo'] ?? '').toString(),
      issuedAt: DateTime.parse(j['issuedAt'] as String),
      paymentRef: idFromJson(j['paymentRef']),
      jobId: idFromJsonNullable(j['jobId']),
      jobPublicCode: j['jobPublicCode'] as String?,
      jobTitle: j['jobTitle'] as String?,
      proName: j['proName'] as String?,
      customerName: j['customerName'] as String?,
      items: [
        for (final e in (j['items'] as List<dynamic>? ?? const <dynamic>[]))
          ReceiptItem.fromJson(e as Map<String, dynamic>),
      ],
      total: total,
      refundedTotal: refunded,
      netPaid: _money(j['netPaid']) ?? (total - refunded),
      currency: (j['currency'] ?? 'TRY').toString(),
      card: j['card'] == null
          ? null
          : PaymentCard.fromJson(j['card'] as Map<String, dynamic>),
      status: _escrow(j['status']),
      moneyLocation: MoneyLocation.parse(j['moneyLocation']),
      provider: PaymentProviderKind.parse(j['provider']),
      sandbox: j['sandbox'] as bool? ?? true,
      sandboxNotice: j['sandboxNotice'] as String?,
    );
  }

  final String receiptNo;
  final DateTime issuedAt;
  final String paymentRef;
  final String? jobId;
  final String? jobPublicCode;
  final String? jobTitle;
  final String? proName;
  final String? customerName;
  final List<ReceiptItem> items;
  final Money total;
  final Money refundedTotal;
  final Money netPaid;
  final String currency;
  final PaymentCard? card;
  final EscrowStatus status;
  final MoneyLocation moneyLocation;
  final PaymentProviderKind provider;
  final bool sandbox;
  final String? sandboxNotice;
}

/// `GET /me/payments` satırı.
@immutable
class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.ref,
    this.jobId,
    this.jobPublicCode,
    this.jobTitle,
    this.proName,
    required this.totalAmount,
    this.refundedAmount = Money.zero,
    required this.status,
    required this.moneyLocation,
    required this.provider,
    required this.sandbox,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> j) =>
      PaymentHistoryItem(
        ref: idFromJson(j['ref']),
        jobId: idFromJsonNullable(j['jobId']),
        jobPublicCode: j['jobPublicCode'] as String?,
        jobTitle: j['jobTitle'] as String?,
        proName: j['proName'] as String?,
        totalAmount: Money.fromJson(j['totalAmount'] ?? 0),
        refundedAmount: _money(j['refundedAmount']) ?? Money.zero,
        status: _escrow(j['status']),
        moneyLocation: MoneyLocation.parse(j['moneyLocation']),
        provider: PaymentProviderKind.parse(j['provider']),
        sandbox: j['sandbox'] as bool? ?? true,
        paidAt: _time(j['paidAt']),
        createdAt: _time(j['createdAt']),
      );

  final String ref;

  /// Hiç iş açmamış ödemede `null`.
  final String? jobId;
  final String? jobPublicCode;
  final String? jobTitle;
  final String? proName;
  final Money totalAmount;
  final Money refundedAmount;
  final EscrowStatus status;
  final MoneyLocation moneyLocation;
  final PaymentProviderKind provider;
  final bool sandbox;
  final DateTime? paidAt;
  final DateTime? createdAt;
}
