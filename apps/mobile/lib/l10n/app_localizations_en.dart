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

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get searchLabel => 'Search';

  @override
  String get noSearchResults => 'No results';

  @override
  String get pickerNone => 'Select';

  @override
  String get photoLoadFailed => 'Photo could not be loaded';

  @override
  String get goHome => 'Go to home';

  @override
  String get goToMyRequests => 'Go to my requests';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get reasonRequired => 'Select a reason to continue.';

  @override
  String get total => 'Total';

  @override
  String get labor => 'Labour';

  @override
  String get materials => 'Materials';

  @override
  String get totalVatIncluded => 'Total (VAT incl.)';

  @override
  String get vatIncluded => 'VAT incl.';

  @override
  String get warranty => 'Workmanship warranty';

  @override
  String get warrantyNone => 'None';

  @override
  String warrantyMonths(int months) {
    return '$months months';
  }

  @override
  String get warrantyHelp =>
      'The platform gives no warranty; the warranty is yours.';

  @override
  String get arrival => 'Arrival window';

  @override
  String get urgencyUrgent => 'Urgent repair';

  @override
  String get urgencyPlanned => 'Planned job';

  @override
  String get tabActive => 'Active';

  @override
  String get tabPast => 'Past';

  @override
  String get dateToday => 'Today';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String get requestAwaitingOffers => 'Awaiting offers';

  @override
  String requestOffersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
    );
    return '$_temp0';
  }

  @override
  String get requestAssigned => 'Pro selected';

  @override
  String get requestCancelled => 'Cancelled';

  @override
  String get requestExpired => 'Expired';

  @override
  String get offerPending => 'Pending';

  @override
  String get offerAccepted => 'Accepted';

  @override
  String get offerDeclined => 'Declined';

  @override
  String get offerWithdrawn => 'Withdrawn';

  @override
  String get offerSuperseded => 'Another offer chosen';

  @override
  String get offerExpired => 'Expired';

  @override
  String get statusApproved => 'Verified';

  @override
  String get proVerified => 'Verified';

  @override
  String get photoAdd => 'Add photo';

  @override
  String get photoFromCamera => 'Take a photo';

  @override
  String get photoFromGallery => 'Choose from gallery';

  @override
  String get photoRemove => 'Remove photo';

  @override
  String get photoUploading => 'Uploading';

  @override
  String get photoUploaded => 'Uploaded';

  @override
  String photoLimitReached(int count) {
    return 'You can add up to $count photos';
  }

  @override
  String get photoTooLarge =>
      'The photo is over the 1.5 MB limit. Choose a smaller one.';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get addressAdd => 'Add address';

  @override
  String get addressDefault => 'Default';

  @override
  String get addressMakeDefault => 'Make default';

  @override
  String get addressesEmptyTitle => 'You have no saved addresses';

  @override
  String get addressesEmptyBody =>
      'Add an address to use when creating a request.';

  @override
  String get addressDeleteTitle => 'Delete this address?';

  @override
  String addressDeleteMessage(String label) {
    return 'The address \"$label\" will be deleted. This cannot be undone.';
  }

  @override
  String get addressLabelField => 'Address name';

  @override
  String get addressLabelHint => 'E.g. Home, Work';

  @override
  String get addressDistrict => 'District';

  @override
  String get addressNeighborhood => 'Neighbourhood';

  @override
  String get addressLine => 'Full address';

  @override
  String get addressLineHint => 'Street, building and flat number';

  @override
  String get addressDoorNote => 'Door note (optional)';

  @override
  String get addressDoorNoteHelp =>
      'The full address and door note are shared only after a pro is chosen.';

  @override
  String get createRequest => 'Create request';

  @override
  String homeGreeting(String name) {
    return 'Hello $name';
  }

  @override
  String get homeActiveRequest => 'Your active request';

  @override
  String get homeNoActiveTitle => 'No active request';

  @override
  String get homeNoActiveBody =>
      'Open a request for your home repair and get offers from pros.';

  @override
  String seeOffers(int count) {
    return 'See offers ($count)';
  }

  @override
  String offerRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String get requestsEmptyActiveTitle => 'No active requests';

  @override
  String get requestsEmptyActiveBody =>
      'Create a request to get offers from pros.';

  @override
  String get requestsEmptyPastTitle => 'No past requests';

  @override
  String get requestsEmptyPastBody =>
      'Cancelled or expired requests appear here.';

  @override
  String get requestDetailTitle => 'Request details';

  @override
  String get requestCode => 'Request code';

  @override
  String get requestLocation => 'Location';

  @override
  String get requestExpiresOn => 'Expires';

  @override
  String get requestAnswers => 'Answers';

  @override
  String get requestPhotos => 'Photos';

  @override
  String get requestCancel => 'Cancel request';

  @override
  String get keepRequest => 'Keep the request';

  @override
  String get cancelReasonTitle => 'Reason for cancelling';

  @override
  String get cancelReasonPlansChanged => 'My plans changed';

  @override
  String get cancelReasonSolved => 'I solved the problem';

  @override
  String get cancelReasonNoSuitableOffer => 'No suitable offer';

  @override
  String get cancelReasonOther => 'Other';

  @override
  String get cancelConfirmTitle => 'Cancel this request?';

  @override
  String get jobCancelConfirmTitle => 'Cancel this job?';

  @override
  String get cancelConfirmMessage =>
      'All pending offers will close. This cannot be undone.';

  @override
  String get publishedTitle => 'Request published';

  @override
  String publishedMatchTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pros matched',
      one: '1 pro matched',
    );
    return '$_temp0';
  }

  @override
  String get publishedMatchBody =>
      'Matching pros were notified. Offers will appear in My requests.';

  @override
  String get publishedNoMatchTitle => 'No matching pros right now';

  @override
  String get publishedNoMatchBody =>
      'If you keep the request open, new pros in your area can see it. Or edit it to change the category or location.';

  @override
  String get matchReasons => 'Why they matched';

  @override
  String get matchCategory => 'Works in your category';

  @override
  String get matchDistrict => 'Serves your district';

  @override
  String get matchAvailability => 'Currently available';

  @override
  String get keepOpen => 'Keep open';

  @override
  String get wizTitle => 'New request';

  @override
  String get wizEditTitle => 'Edit request';

  @override
  String wizStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get wizContinue => 'Continue';

  @override
  String get wizBackToReview => 'Review';

  @override
  String get wizPublish => 'Publish request';

  @override
  String get wizSaveChanges => 'Save changes';

  @override
  String get wizStep1Title => 'Category and urgency';

  @override
  String get wizStep2Title => 'Location and details';

  @override
  String get wizStep3Title => 'Photos and description';

  @override
  String get wizStep4Title => 'Review';

  @override
  String get wizCategory => 'Category';

  @override
  String get wizUrgency => 'Urgency';

  @override
  String get wizUrgentHint => 'As soon as possible';

  @override
  String get wizPlannedHint => 'Pick the dates that suit you';

  @override
  String get wizDates => 'Date range';

  @override
  String get wizDateFrom => 'Earliest';

  @override
  String get wizDateTo => 'Latest';

  @override
  String get wizAddress => 'Address';

  @override
  String get wizAddAddress => 'Add a new address';

  @override
  String get wizFieldTitle => 'Title';

  @override
  String get wizFieldTitleHint => 'E.g. Kitchen tap is dripping';

  @override
  String get wizFieldDescription => 'Description';

  @override
  String get wizFieldDescriptionHint =>
      'Describe the problem and what the pro should know';

  @override
  String wizDescriptionCount(int count, int min) {
    return '$count / at least $min characters';
  }

  @override
  String wizPhotos(int max) {
    return 'Photos (up to $max)';
  }

  @override
  String get wizPhotosHint =>
      'Clear photos of the problem help you get offers.';

  @override
  String get wizPhotosCount => 'Number of photos';

  @override
  String get wizReviewNote => 'Matching pros are notified when you publish.';

  @override
  String get wizErrCategory => 'Select a category to continue.';

  @override
  String get wizErrDateFrom => 'Select the earliest date.';

  @override
  String get wizErrDateTo => 'Select the latest date.';

  @override
  String get wizErrDateOrder => 'The end must be after the start.';

  @override
  String get wizErrDatePast => 'The start must be in the future.';

  @override
  String get wizErrDateRange => 'The date range can be at most 30 days ahead.';

  @override
  String get wizErrAddress => 'Select an address or add a new one.';

  @override
  String get wizErrAnswers => 'Answer all the questions.';

  @override
  String wizErrTitle(int min, int max) {
    return 'The title must be $min-$max characters.';
  }

  @override
  String wizErrDescription(int min) {
    return 'The description must be at least $min characters.';
  }

  @override
  String get wizErrPhotosBusy => 'Wait for the photos to finish uploading.';

  @override
  String get wizErrPhotosFailed =>
      'Retry or remove the photo that failed to upload.';

  @override
  String get offersTitle => 'Offers';

  @override
  String offersResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
    );
    return '$_temp0';
  }

  @override
  String offersDeclinedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You declined $count offers.',
      one: 'You declined 1 offer.',
    );
    return '$_temp0';
  }

  @override
  String get offersEmptyTitle => 'No offers yet';

  @override
  String get offersEmptyBody => 'Offers from pros will appear here.';

  @override
  String get offersEmptyFilteredTitle => 'No offers match your filters';

  @override
  String get offersEmptyFilteredBody => 'Loosen the filters and try again.';

  @override
  String get offersClearFilters => 'Clear filters';

  @override
  String get offersFilterTitle => 'Filter and sort';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortPrice => 'Lowest price';

  @override
  String get sortRating => 'Highest rating';

  @override
  String get sortArrival => 'Earliest arrival';

  @override
  String get filterMaxPrice => 'Maximum price';

  @override
  String get filterMaxPriceLabel => 'Up to (₺)';

  @override
  String get filterMaxPriceHelp =>
      'Labour and materials included. Leave empty for no limit.';

  @override
  String get filterMinRating => 'Pro rating';

  @override
  String get filterAnyRating => 'Any';

  @override
  String filterRatingOrMore(String rating) {
    return '$rating+';
  }

  @override
  String get applyFilters => 'Apply';

  @override
  String get compare => 'Compare';

  @override
  String get compareCancel => 'Cancel';

  @override
  String get compareHint => 'Select 2 or 3 offers.';

  @override
  String compareSelected(int count) {
    return 'Compare ($count)';
  }

  @override
  String get compareTitle => 'Comparison';

  @override
  String get compareTotal => 'Total (VAT incl.)';

  @override
  String get compareGoneTitle => 'These offers are no longer listed';

  @override
  String get compareGoneBody =>
      'The offers may have been withdrawn or expired.';

  @override
  String get compareBackToOffers => 'Back to offers';

  @override
  String get viewOffer => 'View offer';

  @override
  String get proRating => 'Rating';

  @override
  String get proCompletedJobs => 'Completed jobs';

  @override
  String get noRatingYet => 'No rating yet';

  @override
  String ratingWithCount(String avg, int count) {
    return '$avg ($count)';
  }

  @override
  String get offerDetailTitle => 'Offer';

  @override
  String get offerBreakdown => 'Offer breakdown';

  @override
  String get offerNote => 'Pro note';

  @override
  String get offerValidUntil => 'Valid until';

  @override
  String get offerAccept => 'Accept offer';

  @override
  String get offerDecline => 'Decline offer';

  @override
  String get viewProfile => 'View profile';

  @override
  String declineIntro(String pro, String amount) {
    return 'You are about to decline the $amount offer from $pro.';
  }

  @override
  String get declineIrreversible =>
      'This cannot be undone and does not affect the pro\'s profile.';

  @override
  String get declineReasonTitle => 'Reason';

  @override
  String get declineReasonPrice => 'The price is over my budget';

  @override
  String get declineReasonSchedule => 'The timing does not suit me';

  @override
  String get declineReasonOtherOffer => 'I chose another offer';

  @override
  String get declineReasonNotNeeded => 'I no longer need this service';

  @override
  String get declineReasonOther => 'Other';

  @override
  String get declineKeepOpen => 'Keep my request open';

  @override
  String get declineKeepOpenHelp => 'If off, your request is cancelled too.';

  @override
  String get declineCloseNeedsReason =>
      'To close the request, select \"I no longer need this service\" or \"Other\".';

  @override
  String get declineConfirmTitle => 'Decline this offer?';

  @override
  String get declineConfirmKeepOpen =>
      'The offer is declined and your request stays open. This cannot be undone.';

  @override
  String get declineConfirmClose =>
      'The offer is declined and your request is cancelled. This cannot be undone.';

  @override
  String get declineBack => 'Back to the offer';

  @override
  String get proProfileTitle => 'Pro profile';

  @override
  String get proReviews => 'Reviews';

  @override
  String get proAbout => 'About';

  @override
  String get proExperience => 'Experience';

  @override
  String experienceYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get proMemberSince => 'Member since';

  @override
  String get proVerifiedDocuments => 'Verified documents';

  @override
  String get proNoVerifiedDocs => 'No verified documents yet.';

  @override
  String get proCategories => 'Categories';

  @override
  String get proServiceAreas => 'Service areas';

  @override
  String get docIdentity => 'Identity';

  @override
  String get docTradeCert => 'Trade certificate';

  @override
  String get docTax => 'Tax certificate';

  @override
  String get docCriminalRecord => 'Criminal record';

  @override
  String get reviewsEmptyTitle => 'No reviews yet';

  @override
  String get reviewsEmptyBody =>
      'Reviews appear here once customers complete jobs.';

  @override
  String starsOutOf5(int rating) {
    String _temp0 = intl.Intl.pluralLogic(
      rating,
      locale: localeName,
      other: '$rating out of 5 stars',
      one: '1 out of 5 stars',
    );
    return '$_temp0';
  }

  @override
  String get anonymous => 'Anonymous';

  @override
  String get applyIntro =>
      'Send your business details and documents; our team will review them.';

  @override
  String get applyBusinessName => 'Business name';

  @override
  String get applyBusinessNameInvalid =>
      'The business name must be at least 2 characters.';

  @override
  String get applyAbout => 'About (optional)';

  @override
  String get applyExperience => 'Experience (years)';

  @override
  String get applyExperienceInvalid =>
      'Experience must be between 0 and 60 years.';

  @override
  String get applyCategories => 'Categories';

  @override
  String get applyDistricts => 'Districts you serve';

  @override
  String get applyDocuments => 'Documents';

  @override
  String get applyDocumentsHelp =>
      'Upload a photo of each document. Identity and trade certificate are required.';

  @override
  String docRequired(String doc) {
    return '$doc (required)';
  }

  @override
  String docOptional(String doc) {
    return '$doc (optional)';
  }

  @override
  String docMissing(String doc) {
    return 'Upload your $doc.';
  }

  @override
  String get applySubmit => 'Submit application';

  @override
  String get applyResubmit => 'Update documents and resubmit';

  @override
  String get applicationPendingBody =>
      'Our team is reviewing your documents and profile. Your status updates here.';

  @override
  String get applicationNeedsBody =>
      'Some documents are missing or unreadable. Open the form, update them and resubmit.';

  @override
  String get applicationRejectedBody =>
      'Your application was not accepted. Read the note, fix your documents and apply again.';

  @override
  String get applicationSuspendedBody =>
      'Your account is suspended. Contact support.';

  @override
  String get adminNote => 'Review note';

  @override
  String get docStatusPending => 'Under review';

  @override
  String get docStatusAccepted => 'Accepted';

  @override
  String get docStatusRejected => 'Rejected';

  @override
  String get filterAll => 'All';

  @override
  String get filterUrgent => 'Urgent';

  @override
  String get filterPlanned => 'Planned';

  @override
  String get feedOnBreakTitle => 'You are on a break';

  @override
  String get feedOnBreakBody =>
      'No new requests arrive during a break. Activate again when you are ready.';

  @override
  String get feedActivate => 'Go active';

  @override
  String get feedEmptyTitle => 'No matching requests right now';

  @override
  String get feedEmptyBody =>
      'New requests in your categories and districts appear here.';

  @override
  String feedPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String feedOffers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '1 offer',
    );
    return '$_temp0';
  }

  @override
  String get feedMyOffer => 'You made an offer';

  @override
  String get locationMasked =>
      'The full address is shared once your offer is accepted.';

  @override
  String get prepareOffer => 'Prepare offer';

  @override
  String get viewMyOffer => 'View your offer';

  @override
  String get jobsEmptyTitle => 'No jobs yet';

  @override
  String get jobsEmptyBody =>
      'Once an offer is accepted, the job appears here.';

  @override
  String get offerFormTitle => 'Prepare offer';

  @override
  String get laborAmountLabel => 'Labour amount';

  @override
  String get laborAmountInvalid =>
      'The labour amount must be above 0. Example: 1,200';

  @override
  String get materialsEmpty => 'Leave empty if there are no materials.';

  @override
  String get materialAdd => 'Add material item';

  @override
  String get materialRemove => 'Remove item';

  @override
  String get materialDescription => 'Material';

  @override
  String get materialQuantity => 'Quantity';

  @override
  String get materialQuantityInvalid => 'Quantity must be 1 or more.';

  @override
  String get materialUnitPrice => 'Unit price';

  @override
  String get materialPriceInvalid => 'Enter a valid amount. Example: 350';

  @override
  String get arrivalHelp =>
      'The arrival window: 1-12 hours, up to 14 days ahead.';

  @override
  String get arrivalDay => 'Day';

  @override
  String get arrivalStart => 'Start time';

  @override
  String get arrivalLength => 'Window length';

  @override
  String hoursShort(int hours) {
    return '$hours h';
  }

  @override
  String get arrivalMissing => 'Select the day and start time.';

  @override
  String get arrivalPast => 'The arrival time must be in the future.';

  @override
  String get arrivalTooShort => 'The window must be at least 1 hour.';

  @override
  String get arrivalTooLong => 'The window can be at most 12 hours.';

  @override
  String get arrivalTooFar => 'Arrival can be at most 14 days ahead.';

  @override
  String get offerSummary => 'Summary';

  @override
  String serviceFee(int percent) {
    return 'Service fee ($percent%)';
  }

  @override
  String get netEarning => 'Your net earning';

  @override
  String get offerSend => 'Send offer';

  @override
  String get offerSentTitle => 'Your offer';

  @override
  String get offerSentHeadline => 'Your offer was sent';

  @override
  String get offerSentBody =>
      'The customer will review your offer. Track it in My offers.';

  @override
  String get goToMyOffers => 'Go to my offers';

  @override
  String get backToFeed => 'Back to requests';

  @override
  String get myOffersTitle => 'My offers';

  @override
  String get myOffersEmptyTitle => 'No offers';

  @override
  String get myOffersEmptyBody => 'The offers you make appear here.';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get withdrawTitle => 'Withdraw this offer?';

  @override
  String get withdrawMessage =>
      'The customer will no longer see the offer. This cannot be undone.';

  @override
  String get availabilityActive => 'You are active';

  @override
  String get availabilityBreak => 'You are on a break';

  @override
  String get availabilityActiveHelp =>
      'Matching new requests show in your feed.';

  @override
  String get availabilityBreakHelp =>
      'No new requests match during a break; current jobs continue.';

  @override
  String get profileEditTitle => 'Edit your profile';

  @override
  String get profileBio => 'Profile text';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get workingHours => 'Working hours';

  @override
  String get hoursFrom => 'From';

  @override
  String get hoursTo => 'To';

  @override
  String get hoursAcceptsUrgent => 'I also accept urgent jobs';

  @override
  String get hoursInvalid => 'The end time must be after the start time.';

  @override
  String wizErrServerField(String field) {
    return '“$field” was not accepted. Check it and try again.';
  }

  @override
  String get wizEditOffersTitle => 'Save your changes?';

  @override
  String wizEditOffersMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your $count pending offers will expire.',
      one: 'Your pending offer will expire.',
    );
    return '$_temp0 Pros can send new offers for your updated request. This can\'t be undone.';
  }

  @override
  String get photoDuplicate => 'You already added this photo.';

  @override
  String get feedEditProfile => 'Edit your categories and districts';

  @override
  String get arrivalServerInvalid =>
      'The arrival window was not accepted. Check the day and times and try again.';

  @override
  String get offerItemsServerInvalid =>
      'The item totals don\'t add up. Check the material items and try again.';

  @override
  String get backToJob => 'Back to the job';

  @override
  String get addressTitle => 'Address';

  @override
  String get doorNote => 'Door note';

  @override
  String get timelineTitle => 'History';

  @override
  String starsCount(int count) {
    return '$count stars';
  }

  @override
  String unreadMessages(int count) {
    return '$count unread messages';
  }

  @override
  String get serviceFeeLabel => 'Service fee (10%)';

  @override
  String get netEarningLabel => 'Your net earning';

  @override
  String get photosPending =>
      'Wait for the photos to upload or remove the failed one.';

  @override
  String get homeActiveJob => 'Your active job';

  @override
  String get jobScreenTitle => 'Job';

  @override
  String get jobStatusAwaiting => 'Awaiting appointment';

  @override
  String get jobStatusAwaitingPro => 'Awaiting appointment';

  @override
  String get jobStatusScheduled => 'Appointment confirmed';

  @override
  String get jobStatusScheduledPro => 'Appointment confirmed';

  @override
  String get jobStatusArrived => 'Pro on site';

  @override
  String get jobStatusArrivedPro => 'You are on site';

  @override
  String get jobStatusInProgress => 'In progress';

  @override
  String get jobStatusWorkFinished => 'Awaiting your approval';

  @override
  String get jobStatusWorkFinishedPro => 'Awaiting customer approval';

  @override
  String get jobStatusCompleted => 'Completed';

  @override
  String get jobStatusDisputed => 'Under review';

  @override
  String get jobStatusCancelled => 'Cancelled';

  @override
  String get jobStatusResolved => 'Resolved';

  @override
  String get escrowInitialized => 'Awaiting payment';

  @override
  String get escrowLocked => 'In secure hold';

  @override
  String get escrowFailed => 'Payment failed';

  @override
  String get escrowRefunded => 'Refunded to your card';

  @override
  String get escrowRefundedPro => 'Refunded to the customer';

  @override
  String get escrowReleased => 'Paid out to the pro';

  @override
  String get escrowReleasedPro => 'Paid out to you';

  @override
  String get escrowDisputed => 'On hold during the complaint';

  @override
  String get escrowSplit => 'Split between both sides';

  @override
  String get actorYou => 'You';

  @override
  String get actorCustomer => 'Customer';

  @override
  String get actorPro => 'Pro';

  @override
  String get actorSystem => 'System';

  @override
  String get actorAdmin => 'Admin';

  @override
  String get eventStatus => 'Status updated';

  @override
  String get eventNote => 'Note added';

  @override
  String get eventPhoto => 'Photo added';

  @override
  String get eventProposed => 'Appointment proposed';

  @override
  String get eventAccepted => 'Appointment accepted';

  @override
  String get offerSummaryTitle => 'Offer summary';

  @override
  String get paymentSummaryTitle => 'Payment';

  @override
  String get paymentStatusLabel => 'Status';

  @override
  String get refundedLabel => 'Refunded';

  @override
  String get escrowExplain =>
      'Your payment is kept in secure hold. It is paid out to the pro once the job is done and you approve it.';

  @override
  String get escrowExplainPro =>
      'The payment is kept in secure hold. Your net earning is paid out once the customer approves the job, or 48 hours after delivery.';

  @override
  String get acceptTitle => 'Accept the offer';

  @override
  String acceptIntro(String pro) {
    return 'You are about to work with $pro. Check the breakdown and the terms before paying.';
  }

  @override
  String get acceptVatNote => 'The amount includes VAT.';

  @override
  String get escrowHowTitle => 'Your payment stays in secure hold';

  @override
  String get escrowHowBody =>
      'The payment is taken from your card and held securely. The pro finishes the job and you approve it; only then is the amount paid out to the pro. If you do not approve or something goes wrong, you can open a complaint.';

  @override
  String get cancelPolicyTitle => 'Cancellation policy';

  @override
  String get cancelPolicyBody =>
      'You can cancel until the pro arrives at your address; the full payment is refunded to your card. Once the work has started you can open a complaint instead of cancelling.';

  @override
  String get acceptUnavailable =>
      'This offer can no longer be accepted. It may have expired or changed.';

  @override
  String acceptContinue(String amount) {
    return 'Continue to payment, $amount';
  }

  @override
  String get acceptBack => 'Not now';

  @override
  String get payTitle => 'Payment';

  @override
  String get payTo => 'Pro';

  @override
  String get payAmount => 'Amount to pay';

  @override
  String get payFillTestCard => 'Fill the test card';

  @override
  String get cardHolder => 'Name on card';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardExpiry => 'Expiry (MM/YY)';

  @override
  String get cardExpiryHint => 'MM/YY';

  @override
  String get cardCvc => 'Security code (CVC)';

  @override
  String get cardErrHolder => 'Enter the name and surname on the card.';

  @override
  String get cardErrNumber =>
      'The card number is invalid. Check all 16 digits.';

  @override
  String get cardErrExpiry => 'The expiry date is invalid. Use MM/YY.';

  @override
  String get cardErrExpiryPast => 'The card has expired.';

  @override
  String get cardErrCvc =>
      'The security code (CVC) is invalid. Enter 3 or 4 digits.';

  @override
  String get payNoStore =>
      'Your card details are not saved. The bank verification comes next.';

  @override
  String payButton(String amount) {
    return 'Pay $amount';
  }

  @override
  String get payConnecting => 'Connecting to the bank';

  @override
  String get threeDsTitle => 'Bank verification';

  @override
  String get threeDsClose => 'Close';

  @override
  String get threeDsCloseTitle => 'Close the verification?';

  @override
  String get threeDsCloseBody =>
      'If you leave before finishing, the payment may not complete. We will check the payment status when you leave.';

  @override
  String get threeDsCloseConfirm => 'Close';

  @override
  String get threeDsCloseStay => 'Back to verification';

  @override
  String get payResultTitle => 'Payment result';

  @override
  String get payWaiting => 'Waiting for the bank result';

  @override
  String get payWaitingHint =>
      'This can take a few seconds. Please stay on this screen.';

  @override
  String get paySuccessTitle => 'Payment received';

  @override
  String paySuccessBody(String amount) {
    return '$amount is now held securely.';
  }

  @override
  String get payFailedTitle => 'Payment was not completed';

  @override
  String get payRefundedTitle => 'Your payment was refunded';

  @override
  String get payUncertainTitle => 'The result is not clear yet';

  @override
  String get payFailDeclined =>
      'Your bank did not approve the payment. Check your card details or try a different card.';

  @override
  String get payFailAssigned =>
      'Your request was assigned to another offer in the meantime. Your payment was refunded to your card.';

  @override
  String get payFailExpired =>
      'The offer expired. Your payment was refunded to your card.';

  @override
  String get payFailUncertain =>
      'We have not received a final result from the bank yet. Check again in a moment. If the payment went through, your job will appear under Requests.';

  @override
  String get payFailGeneric =>
      'The payment could not be completed. You can try again with a different card.';

  @override
  String get payTryOtherCard => 'Try a different card';

  @override
  String get payBackToOffer => 'Back to the offer';

  @override
  String get payCheckAgain => 'Check again';

  @override
  String get payToJob => 'Go to the job';

  @override
  String get payToRequests => 'Go to my requests';

  @override
  String get appointmentTitle => 'Appointment';

  @override
  String get appointmentProTitle => 'Appointment';

  @override
  String get appointmentNotChosen => 'No appointment chosen yet.';

  @override
  String get proposalMine => 'Your proposal is waiting for the other side';

  @override
  String get proposalFromPro => 'The pro proposed this window';

  @override
  String get proposalFromCustomer => 'The customer proposed this window';

  @override
  String get proposalAccept => 'Accept';

  @override
  String get proposalOther => 'Choose another window';

  @override
  String get appointmentChoose => 'Choose an appointment';

  @override
  String get appointmentChange => 'Change the appointment';

  @override
  String get appointmentIntro =>
      'Choose when you want the pro to come. The pro confirms or proposes another window.';

  @override
  String get appointmentProIntro =>
      'Accept the customer proposal or suggest a window that suits you.';

  @override
  String get appointmentPickDay => 'Day';

  @override
  String get appointmentPickSlot => 'Time window';

  @override
  String get appointmentOfferWindow => 'Arrival window from the offer';

  @override
  String get appointmentYourWindow => 'Arrival window from your offer';

  @override
  String get appointmentNoSlots => 'No windows available for this day.';

  @override
  String get appointmentSelectHint => 'Choose a window to continue.';

  @override
  String get appointmentSubmit => 'Request this appointment';

  @override
  String get appointmentProSubmit => 'Propose a new window';

  @override
  String get appointmentClosed =>
      'Appointments cannot be changed for this job right now.';

  @override
  String get cancelTitle => 'Cancel the job';

  @override
  String get cancelJobAction => 'Cancel the job';

  @override
  String get proCancelAction => 'Cancel the job';

  @override
  String cancelIntroCustomer(String amount) {
    return 'If you cancel, $amount is refunded to your card and your request is closed.';
  }

  @override
  String cancelIntroPro(String amount) {
    return 'If you cancel, $amount is refunded to the customer and the request is reopened. Cancellations are recorded on your profile.';
  }

  @override
  String get cancelReasonProUnreachable => 'The pro cannot be reached';

  @override
  String get cancelReasonOtherProvider => 'I agreed with another pro';

  @override
  String get proCancelReasonSchedule => 'My schedule does not fit';

  @override
  String get proCancelReasonCannot => 'I cannot do the job';

  @override
  String get proCancelReasonCustomer => 'I cannot reach the customer';

  @override
  String get cancelSubmit => 'Cancel';

  @override
  String get cancelRescheduleInstead => 'Ask for a new date instead';

  @override
  String get cancelNotAllowed =>
      'This job can no longer be cancelled. If something went wrong you can open a complaint.';

  @override
  String cancelConfirmCustomer(String amount) {
    return 'This cannot be undone. $amount will be refunded to your card.';
  }

  @override
  String cancelConfirmPro(String amount) {
    return 'This cannot be undone. $amount will be refunded to the customer and the request will reopen.';
  }

  @override
  String get cancelConfirmAction => 'Cancel the job';

  @override
  String get cancelConfirmKeep => 'Keep the job';

  @override
  String get completeTitle => 'Approve the work';

  @override
  String get completeIntro =>
      'The pro says the job is done. Check the note and photos and approve if all is fine.';

  @override
  String get completeProNote => 'Note from the pro';

  @override
  String get completeNoNote => 'The pro did not add a note.';

  @override
  String get completeProPhotos => 'Photos from the pro';

  @override
  String completeAutoNote(String date) {
    return 'If you do not approve, it is approved automatically on $date.';
  }

  @override
  String get completeConfirmButton => 'Approve';

  @override
  String get completeNotAvailable =>
      'This job is not waiting for your approval right now.';

  @override
  String get completeConfirmTitle => 'Approve the work?';

  @override
  String completeConfirmBody(String amount, String pro) {
    return 'If you approve, $amount is paid out from secure hold to $pro. This cannot be undone.';
  }

  @override
  String get completeConfirmAction => 'Approve and pay out';

  @override
  String get confirmCompletion => 'Approve the work';

  @override
  String get complainAction => 'Report a problem';

  @override
  String get reviewTitle => 'Rate';

  @override
  String get reviewAction => 'Leave a rating';

  @override
  String reviewIntro(String pro) {
    return 'How was your experience with $pro?';
  }

  @override
  String get reviewStarsTitle => 'Your rating';

  @override
  String get reviewStarsRequired => 'Choose a star rating to continue.';

  @override
  String get reviewTagsTitle => 'What went well?';

  @override
  String get reviewTagOnTime => 'On time';

  @override
  String get reviewTagCleanWork => 'Clean work';

  @override
  String get reviewTagFairPrice => 'Fair price';

  @override
  String get reviewTagGoodCommunication => 'Good communication';

  @override
  String get reviewTagPolite => 'Polite';

  @override
  String get reviewCommentLabel => 'Your comment (optional)';

  @override
  String get reviewAnonymous => 'Hide my name';

  @override
  String get reviewAnonymousHelp =>
      'Your review appears on the pro profile without your name.';

  @override
  String get reviewPublish => 'Publish';

  @override
  String get reviewSkip => 'Not now';

  @override
  String get reviewAlreadyTitle => 'You already rated this job';

  @override
  String get reviewAlreadyBody =>
      'A rating was already given for this job. Thank you.';

  @override
  String get reviewNotAvailableTitle => 'Cannot be rated right now';

  @override
  String get reviewNotAvailableBody =>
      'You can rate once the job is completed.';

  @override
  String get yourReview => 'Your rating';

  @override
  String get complaintTitle => 'Report a problem';

  @override
  String get complaintIntro =>
      'Tell us what went wrong. Once a complaint is opened the payment stays in secure hold while our team reviews it.';

  @override
  String get complaintReasonTitle => 'Reason';

  @override
  String get complaintReasonNoShow => 'The pro did not show up';

  @override
  String get complaintReasonIncomplete => 'The work is incomplete or faulty';

  @override
  String get complaintReasonExtraCharge => 'An extra charge was requested';

  @override
  String get complaintReasonRude => 'Rude behaviour';

  @override
  String get complaintReasonOther => 'Other';

  @override
  String get complaintDescription => 'Description';

  @override
  String complaintDescriptionHelp(int count, int min) {
    return '$count/$min characters (minimum)';
  }

  @override
  String complaintDescriptionShort(int min) {
    return 'The description needs at least $min characters. Tell us a bit more.';
  }

  @override
  String get complaintEvidenceTitle => 'Evidence photos';

  @override
  String complaintEvidenceHelp(int max) {
    return 'Optional, up to $max photos.';
  }

  @override
  String get complaintAgree =>
      'I understand the payment stays in secure hold while the complaint is reviewed.';

  @override
  String get complaintSubmit => 'Submit complaint';

  @override
  String get complaintPhotosPending =>
      'Wait for the photos to upload or remove the failed one.';

  @override
  String get complaintConfirmTitle => 'Submit the complaint?';

  @override
  String get complaintConfirmBody =>
      'Once submitted the job goes under review and the payment stays in secure hold. This cannot be undone.';

  @override
  String get complaintConfirmAction => 'Submit';

  @override
  String get complaintNotAvailableTitle => 'A complaint cannot be opened';

  @override
  String get complaintNotAvailableBody =>
      'A complaint cannot be opened for this job right now. One may already exist.';

  @override
  String get complaintStatusTitle => 'Complaint status';

  @override
  String get complaintStatusOpen => 'Received';

  @override
  String get complaintStatusInReview => 'Under review';

  @override
  String get complaintStatusResolved => 'Resolved';

  @override
  String get complaintStatusDismissed => 'Dismissed';

  @override
  String get complaintExplainOpen =>
      'Your complaint was received and is queued for review. The payment stays in secure hold meanwhile.';

  @override
  String get complaintExplainInReview =>
      'Our team is reviewing your complaint. The result will appear here.';

  @override
  String get complaintExplainResolved =>
      'Your complaint has been resolved. The decision and its reasons are below.';

  @override
  String get complaintExplainDismissed =>
      'Your complaint was reviewed and not upheld. The reasons are below.';

  @override
  String get complaintCreatedAt => 'Opened';

  @override
  String get complaintDecisionTitle => 'Decision';

  @override
  String get complaintGoChat => 'Go to the chat';

  @override
  String complaintCardTitle(String code) {
    return 'Complaint $code';
  }

  @override
  String get chatEntryTitle => 'Messages';

  @override
  String get chatOpen => 'Open the chat';

  @override
  String get chatEmptyTitle => 'No messages yet';

  @override
  String get chatEmptyBody =>
      'Write the first message. Phone numbers are not shared; all contact happens here.';

  @override
  String get chatReadOnlyBody =>
      'This chat is read-only: new messages cannot be sent 30 days after the job is closed.';

  @override
  String get chatInputLabel => 'Write a message';

  @override
  String get chatInputHint => 'Type your message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatAttachPhoto => 'Attach a photo';

  @override
  String get chatPhotoBody => 'Photo';

  @override
  String get chatSending => 'Sending';

  @override
  String get chatSendFailed => 'Not sent.';

  @override
  String get chatRetry => 'Try again';

  @override
  String get chatDiscard => 'Delete';

  @override
  String get chatRead => 'Read';

  @override
  String get chatSent => 'Sent';

  @override
  String get conversationsEmptyTitle => 'No conversations yet';

  @override
  String get conversationsEmptyBody =>
      'Once you accept an offer and pay, you can chat with the pro here.';

  @override
  String get conversationsEmptyBodyPro =>
      'Once an offer of yours is accepted, you can chat with the customer here.';

  @override
  String get conversationsGoRequests => 'Go to my requests';

  @override
  String get conversationsGoJobs => 'Go to my jobs';

  @override
  String get conversationNoMessages => 'No messages yet';

  @override
  String get jobsEmptyPastTitle => 'No past jobs';

  @override
  String get jobsEmptyPastBody => 'Completed and cancelled jobs show up here.';

  @override
  String get proArrived => 'I have arrived';

  @override
  String get proStart => 'I started the job';

  @override
  String get proFinish => 'I finished the job';

  @override
  String get proAddNote => 'Add a note or photo';

  @override
  String get proOpenMaps => 'Open in Maps';

  @override
  String get mapsOpenFailed => 'Could not open a maps app.';

  @override
  String proAutoCompleteNote(String date) {
    return 'If the customer does not approve, the job is approved automatically on $date.';
  }

  @override
  String get proNoteTitle => 'Note or photo';

  @override
  String get proNoteIntro => 'Add a note or photo that the customer will see.';

  @override
  String get proNoteLabel => 'Note';

  @override
  String get proNoteEmpty => 'Write a note or add a photo.';

  @override
  String get proNoteSubmit => 'Add';

  @override
  String get proPhotosTitle => 'Photos';

  @override
  String get proFinishTitle => 'Finish the job';

  @override
  String get proFinishIntro =>
      'Briefly describe the work you did. The customer sees your note and photos and then approves.';

  @override
  String get proFinishNoteLabel => 'Note about the work';

  @override
  String proFinishNoteHelp(int count, int min) {
    return '$count/$min characters (minimum)';
  }

  @override
  String proFinishNoteShort(int min) {
    return 'The note needs at least $min characters.';
  }

  @override
  String get proFinishPhotosHelp => 'Optional, up to 5 photos.';

  @override
  String get proFinishSubmit => 'I finished the job';

  @override
  String get proFinishConfirmTitle => 'Report the job as finished?';

  @override
  String get proFinishConfirmBody =>
      'The customer is asked to approve. This cannot be undone.';

  @override
  String get proFinishConfirmAction => 'Report';

  @override
  String get proFinishedTitle => 'Handover sent';

  @override
  String get proFinishedHeadline => 'You sent the handover';

  @override
  String get proFinishedBody =>
      'Once the customer approves, the payment is paid out to you from secure hold.';

  @override
  String get proBackToJobs => 'Back to my jobs';

  @override
  String get proCancelledTitle => 'Job cancelled';

  @override
  String get proCancelledHeadline => 'You cancelled the job';

  @override
  String get proCancelledBody =>
      'The customer was refunded and the request reopened. Cancellations are recorded on your profile.';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String get earningsReleased => 'Paid out to you';

  @override
  String get earningsPending => 'Waiting in secure hold';

  @override
  String get earningsFeeTotal => 'Total service fee';

  @override
  String get earningsPendingHelp =>
      'The waiting amount is paid out once the customer approves or a complaint is resolved.';

  @override
  String get earningsList => 'Jobs';

  @override
  String get earningsEmptyTitle => 'No earnings yet';

  @override
  String get earningsEmptyBody =>
      'Your earnings appear here once an offer is accepted and the job is done.';

  @override
  String get earningPending => 'Pending';

  @override
  String get earningReleased => 'Paid out';

  @override
  String get earningRefunded => 'Refunded';

  @override
  String get earningSplit => 'Split';

  @override
  String get offerFormRequestClosed =>
      'This request no longer accepts offers. The screen was refreshed.';

  @override
  String get homeActiveJobs => 'Your active jobs';

  @override
  String get homeOpenRequests => 'Your open requests';

  @override
  String get homeSeeAll => 'See all';
}
