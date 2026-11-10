import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'json_helpers.dart';
import 'money.dart';

part 'payments.freezed.dart';
part 'payments.g.dart';

/// `POST /payments/3ds/init` yanıtı: WebView'de gösterilecek banka formu.
@freezed
abstract class PaymentInit with _$PaymentInit {
  const factory PaymentInit({
    required String ref,
    required String htmlContent,
  }) = _PaymentInit;

  factory PaymentInit.fromJson(Map<String, dynamic> json) =>
      _$PaymentInitFromJson(json);
}

@freezed
abstract class PaymentResult with _$PaymentResult {
  const factory PaymentResult({
    required String ref,
    required EscrowStatus status,
    @JsonKey(fromJson: idFromJsonNullable) String? offerId,
    @JsonKey(fromJson: idFromJsonNullable) String? requestId,
    @JsonKey(fromJson: idFromJsonNullable) String? jobId,
    @MoneyConverter() required Money totalAmount,
    String? cardLast4,
    @JsonKey(unknownEnumValue: PaymentErrorCode.unknown)
    PaymentErrorCode? errorCode,
    String? errorMessage,
    @Default(false) bool resultUncertain,
  }) = _PaymentResult;

  factory PaymentResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentResultFromJson(json);
}

/// Kart bilgisi gövdesi. Düz sınıftır: `toString` kart verisini yazmaz, hiçbir
/// yerde saklanmaz ya da loglanmaz.
class CardPaymentRequest {
  const CardPaymentRequest({
    required this.offerId,
    required this.attemptKey,
    required this.cardHolderName,
    required this.cardNumber,
    required this.expireMonth,
    required this.expireYear,
    required this.cvc,
  });

  final String offerId;
  final String attemptKey;
  final String cardHolderName;

  /// Yalnız rakamlar.
  final String cardNumber;

  /// İki haneli ay (`07`).
  final String expireMonth;

  /// Dört haneli yıl (`2044`).
  final String expireYear;
  final String cvc;

  Map<String, dynamic> toJson() => {
    'offerId': offerId,
    'attemptKey': attemptKey,
    'cardHolderName': cardHolderName,
    'cardNumber': cardNumber,
    'expireMonth': expireMonth,
    'expireYear': expireYear,
    'cvc': cvc,
  };

  @override
  String toString() =>
      'CardPaymentRequest(offerId: $offerId, attemptKey: $attemptKey, kart: gizli)';
}
