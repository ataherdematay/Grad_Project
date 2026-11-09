import 'package:bitadilat_api/bitadilat_api.dart';

import '../l10n/app_localizations.dart';

/// Her hata kodunun kullanıcı mesajı. `switch` kapsamlı olduğundan yeni bir
/// kod eklenince derleme hatası verir.
String apiErrorMessage(AppLocalizations l, ApiErrorCode code) =>
    switch (code) {
      ApiErrorCode.validationFailed => l.apiErrorValidationFailed,
      ApiErrorCode.unauthenticated => l.apiErrorUnauthenticated,
      ApiErrorCode.tokenExpired => l.apiErrorTokenExpired,
      ApiErrorCode.badCredentials => l.apiErrorBadCredentials,
      ApiErrorCode.accountSuspended => l.apiErrorAccountSuspended,
      ApiErrorCode.forbidden => l.apiErrorForbidden,
      ApiErrorCode.proNotApproved => l.apiErrorProNotApproved,
      ApiErrorCode.notFound => l.apiErrorNotFound,
      ApiErrorCode.illegalState => l.apiErrorIllegalState,
      ApiErrorCode.emailTaken => l.apiErrorEmailTaken,
      ApiErrorCode.phoneTaken => l.apiErrorPhoneTaken,
      ApiErrorCode.tooManyAttempts => l.apiErrorTooManyAttempts,
      ApiErrorCode.paymentDeclined => l.apiErrorPaymentDeclined,
      ApiErrorCode.invalidCard => l.apiErrorInvalidCard,
      ApiErrorCode.duplicateAttempt => l.apiErrorDuplicateAttempt,
      ApiErrorCode.paymentInProgress => l.apiErrorPaymentInProgress,
      ApiErrorCode.offerExpired => l.apiErrorOfferExpired,
      ApiErrorCode.alreadyOffered => l.apiErrorAlreadyOffered,
      ApiErrorCode.gatewayError => l.apiErrorGatewayError,
      ApiErrorCode.internalError => l.apiErrorInternalError,
      ApiErrorCode.networkError => l.apiErrorNetworkError,
      ApiErrorCode.unknown => l.apiErrorUnknown,
    };

/// Alan altında gösterilecek metin: `VALIDATION_FAILED` için alana özgü
/// kısa metin, diğer kodlar için kodun kendi mesajı.
String apiFieldMessage(AppLocalizations l, ApiException e) =>
    e.code == ApiErrorCode.validationFailed
    ? l.errFieldInvalid
    : apiErrorMessage(l, e.code);
