import 'package:bitadilat_api/bitadilat_api.dart';

import '../l10n/app_localizations.dart';

/// Her hata kodunun kullanıcı mesajı. `switch` kapsamlı olduğundan yeni bir
/// kod eklenince derleme hatası verir.
String apiErrorMessage(AppLocalizations l, ApiErrorCode code) => switch (code) {
  ApiErrorCode.validationFailed => l.apiErrorValidationFailed,
  ApiErrorCode.unauthenticated ||
  ApiErrorCode.tokenExpired => l.apiErrorSessionExpired,
  ApiErrorCode.badCredentials => l.apiErrorBadCredentials,
  ApiErrorCode.accountSuspended => l.apiErrorAccountSuspended,
  ApiErrorCode.forbidden => l.apiErrorForbidden,
  ApiErrorCode.notFound => l.apiErrorNotFound,
  ApiErrorCode.illegalState => l.apiErrorIllegalState,
  ApiErrorCode.tooManyAttempts => l.apiErrorTooManyAttempts,
  ApiErrorCode.gatewayError => l.apiErrorGatewayError,
  ApiErrorCode.internalError => l.apiErrorInternalError,
  ApiErrorCode.networkError => l.apiErrorNetworkError,
  ApiErrorCode.proNotApproved ||
  ApiErrorCode.emailTaken ||
  ApiErrorCode.phoneTaken ||
  ApiErrorCode.paymentDeclined ||
  ApiErrorCode.invalidCard ||
  ApiErrorCode.duplicateAttempt ||
  ApiErrorCode.paymentInProgress ||
  ApiErrorCode.offerExpired ||
  ApiErrorCode.alreadyOffered ||
  ApiErrorCode.unknown => l.apiErrorUnknown,
};

String errorText(AppLocalizations l, Object error) =>
    error is ApiException ? apiErrorMessage(l, error.code) : l.apiErrorUnknown;
