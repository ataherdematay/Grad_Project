// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentInit _$PaymentInitFromJson(Map<String, dynamic> json) => _PaymentInit(
  ref: json['ref'] as String,
  htmlContent: json['htmlContent'] as String,
);

Map<String, dynamic> _$PaymentInitToJson(_PaymentInit instance) =>
    <String, dynamic>{'ref': instance.ref, 'htmlContent': instance.htmlContent};

_PaymentResult _$PaymentResultFromJson(Map<String, dynamic> json) =>
    _PaymentResult(
      ref: json['ref'] as String,
      status: $enumDecode(_$EscrowStatusEnumMap, json['status']),
      offerId: idFromJsonNullable(json['offerId']),
      requestId: idFromJsonNullable(json['requestId']),
      jobId: idFromJsonNullable(json['jobId']),
      totalAmount: const MoneyConverter().fromJson(json['totalAmount']),
      cardLast4: json['cardLast4'] as String?,
      errorCode: $enumDecodeNullable(
        _$PaymentErrorCodeEnumMap,
        json['errorCode'],
        unknownValue: PaymentErrorCode.unknown,
      ),
      errorMessage: json['errorMessage'] as String?,
      resultUncertain: json['resultUncertain'] as bool? ?? false,
    );

Map<String, dynamic> _$PaymentResultToJson(_PaymentResult instance) =>
    <String, dynamic>{
      'ref': instance.ref,
      'status': _$EscrowStatusEnumMap[instance.status]!,
      'offerId': instance.offerId,
      'requestId': instance.requestId,
      'jobId': instance.jobId,
      'totalAmount': const MoneyConverter().toJson(instance.totalAmount),
      'cardLast4': instance.cardLast4,
      'errorCode': _$PaymentErrorCodeEnumMap[instance.errorCode],
      'errorMessage': instance.errorMessage,
      'resultUncertain': instance.resultUncertain,
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

const _$PaymentErrorCodeEnumMap = {
  PaymentErrorCode.paymentDeclined: 'PAYMENT_DECLINED',
  PaymentErrorCode.requestAlreadyAssigned: 'REQUEST_ALREADY_ASSIGNED',
  PaymentErrorCode.offerExpired: 'OFFER_EXPIRED',
  PaymentErrorCode.resultUncertain: 'RESULT_UNCERTAIN',
  PaymentErrorCode.unknown: 'UNKNOWN',
};
