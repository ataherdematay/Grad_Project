// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BiTadilat';

  @override
  String get welcomeTagline =>
      'Get offers for your home repair and pick your pro.';

  @override
  String get welcomeBody =>
      'Post a request and pros send offers. Keep your payment in secure hold and approve it when the job is done.';

  @override
  String get actionLogin => 'Log in';

  @override
  String get actionRegister => 'Create account';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwitchHint => 'Choose the app language';

  @override
  String get back => 'Back';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loading => 'Loading';

  @override
  String get genericErrorTitle => 'Something went wrong';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginIntro => 'Continue with your account.';

  @override
  String get fieldIdentifier => 'Email or phone';

  @override
  String get hintIdentifier => 'name@example.com or 5XX XXX XX XX';

  @override
  String get fieldPassword => 'Password';

  @override
  String get hintPassword => 'Enter your password';

  @override
  String get forgotPasswordLink => 'Forgot my password';

  @override
  String get loginNoAccount => 'No account yet?';

  @override
  String get errRequired => 'Fill in this field.';

  @override
  String get errEmailInvalid =>
      'The email address looks wrong. Example: name@example.com';

  @override
  String get errPhoneInvalid =>
      'The phone number is incomplete. Enter 10 digits as 5XX XXX XX XX.';

  @override
  String get errIdentifierInvalid =>
      'Enter your email address or a phone number as 5XX XXX XX XX.';

  @override
  String get errPasswordShort => 'Your password must be at least 8 characters.';

  @override
  String get errPasswordWeak =>
      'Your password needs at least one letter and one digit.';

  @override
  String get errNameInvalid => 'Enter your first and last name.';

  @override
  String get errCodeInvalid => 'The code has 6 digits. Check your email.';

  @override
  String get errRoleRequired => 'Choose an option to continue.';

  @override
  String get errConsentRequired => 'You need to accept this to continue.';

  @override
  String get errFieldInvalid =>
      'This field is invalid. Check it and try again.';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerIntro => 'Get started with a few details.';

  @override
  String get roleSectionTitle => 'How will you use your account?';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleCustomerDesc =>
      'I post repair requests and get offers from pros.';

  @override
  String get rolePro => 'Pro';

  @override
  String get roleProDesc => 'I send offers on customers\' requests.';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get hintFullName => 'e.g. Jane Smith';

  @override
  String get fieldEmail => 'Email';

  @override
  String get hintEmail => 'name@example.com';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get hintPhone => '5XX XXX XX XX';

  @override
  String get helperPassword =>
      'At least 8 characters with a letter and a digit.';

  @override
  String get consentKvkk => 'I have read the KVKK privacy notice.';

  @override
  String get consentKvkkRead => 'Read the KVKK notice';

  @override
  String get consentTerms => 'I accept the terms of use.';

  @override
  String get consentTermsRead => 'Read the terms';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotIntro =>
      'Enter the email address on your account. We will send you a 6-digit code.';

  @override
  String get forgotSubmit => 'Send code';

  @override
  String get forgotSent =>
      'If the email address is registered, a code has been sent. Check your inbox.';

  @override
  String get resetTitle => 'Set a new password';

  @override
  String get resetIntro =>
      'Enter the 6-digit code from your email and your new password.';

  @override
  String get fieldCode => '6-digit code';

  @override
  String get hintCode => '123456';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get resetSubmit => 'Change password';

  @override
  String get resetDone =>
      'Your password has changed. Log in with your new password.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmBody =>
      'You will be signed out on this device. You can log in again any time.';

  @override
  String get tabHome => 'Home';

  @override
  String get tabRequests => 'My requests';

  @override
  String get tabMessages => 'Messages';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabFeed => 'Requests';

  @override
  String get tabJobs => 'My jobs';

  @override
  String get comingSoonTitle => 'This section is being prepared';

  @override
  String get comingSoonBody => 'You will see it here when it is ready.';

  @override
  String get profileSettings => 'Settings';

  @override
  String get switchToPro => 'Switch to pro mode';

  @override
  String get applyAsPro => 'Apply as a pro';

  @override
  String get switchToCustomer => 'Switch to customer mode';

  @override
  String get proApplyTitle => 'Pro application';

  @override
  String get proApplicationTitle => 'Application status';

  @override
  String get backToCustomerMode => 'Back to customer mode';

  @override
  String get statusPendingReview => 'Under review';

  @override
  String get statusNeedsDocuments => 'Documents needed';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get chatTitle => 'Chat';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody =>
      'The page you are looking for may have moved or never existed.';

  @override
  String get notFoundAction => 'Go to home';

  @override
  String get legalKvkkTitle => 'KVKK privacy notice';

  @override
  String get legalTermsTitle => 'Terms of use';

  @override
  String get legalPrivacyTitle => 'Privacy policy';

  @override
  String get legalPlaceholder => 'This text will be prepared before launch.';

  @override
  String get splashErrorTitle => 'Could not open your session';

  @override
  String get noticeAdmin => 'Log in with an admin account from the web panel.';

  @override
  String get noticeSessionExpired => 'Your session has expired. Log in again.';

  @override
  String get apiErrorValidationFailed =>
      'Some details are missing or wrong. Check the fields and try again.';

  @override
  String get apiErrorUnauthenticated =>
      'Your session is not valid. Log in again.';

  @override
  String get apiErrorTokenExpired => 'Your session has expired. Log in again.';

  @override
  String get apiErrorBadCredentials =>
      'Email, phone or password is wrong. Check your details and try again.';

  @override
  String get apiErrorAccountSuspended =>
      'Your account is suspended. Contact the support team.';

  @override
  String get apiErrorForbidden => 'You are not allowed to do this.';

  @override
  String get apiErrorProNotApproved =>
      'Your pro application is not approved yet. Check its status.';

  @override
  String get apiErrorNotFound =>
      'We could not find what you were looking for. Go back home and try again.';

  @override
  String get apiErrorIllegalState =>
      'This action is no longer possible, the screen was refreshed.';

  @override
  String get apiErrorEmailTaken =>
      'This email address is already registered. Log in or use another email.';

  @override
  String get apiErrorPhoneTaken =>
      'This phone number is already registered. Log in or use another number.';

  @override
  String get apiErrorTooManyAttempts =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get apiErrorPaymentDeclined =>
      'Your bank declined the payment. Try another card.';

  @override
  String get apiErrorInvalidCard =>
      'The card details are wrong. Check the number, expiry date and security code.';

  @override
  String get apiErrorDuplicateAttempt =>
      'This was already submitted. Wait a few seconds.';

  @override
  String get apiErrorPaymentInProgress =>
      'Your payment is being processed. Wait for the result.';

  @override
  String get apiErrorOfferExpired =>
      'This offer has expired. Go back to the offers list.';

  @override
  String get apiErrorAlreadyOffered =>
      'You have already sent an offer on this request.';

  @override
  String get apiErrorGatewayError =>
      'The payment system is unavailable. Try again in a few minutes.';

  @override
  String get apiErrorInternalError =>
      'Something unexpected happened. Try again shortly.';

  @override
  String get apiErrorNetworkError =>
      'We cannot reach the network. Check your connection and try again. Your details are kept.';

  @override
  String get apiErrorUnknown => 'Something went wrong. Try again.';
}
