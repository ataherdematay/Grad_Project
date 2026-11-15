// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BiTadilat Admin';

  @override
  String get language => 'Language';

  @override
  String get loading => 'Loading';

  @override
  String get retry => 'Try again';

  @override
  String get refresh => 'Refresh';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterRole => 'Role';

  @override
  String get filterAll => 'All';

  @override
  String get loadFailedTitle => 'Couldn\'t load the list';

  @override
  String get staleNotice =>
      'This record changed in the meantime, so this action is no longer possible. We refreshed the screen.';

  @override
  String get apiErrorValidationFailed =>
      'Some fields are missing or invalid. Check them and try again.';

  @override
  String get apiErrorSessionExpired => 'Your session ended. Sign in again.';

  @override
  String get apiErrorBadCredentials =>
      'Email or password is wrong. Check your details and try again.';

  @override
  String get apiErrorAccountSuspended =>
      'Your account is suspended. Contact another admin.';

  @override
  String get apiErrorForbidden => 'You don\'t have permission for this action.';

  @override
  String get apiErrorNotFound =>
      'We couldn\'t find this record. Go back to the list and try again.';

  @override
  String get apiErrorIllegalState =>
      'This action is no longer possible, the screen was refreshed.';

  @override
  String get apiErrorTooManyAttempts =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get apiErrorGatewayError =>
      'The payment system is unreachable right now. Try again in a few minutes.';

  @override
  String get apiErrorInternalError =>
      'Something unexpected happened. Try again shortly.';

  @override
  String get apiErrorNetworkError =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get apiErrorUnknown => 'Something went wrong. Try again.';

  @override
  String get loginTitle => 'Admin sign-in';

  @override
  String get loginSubtitle =>
      'Sign in to the BiTadilat admin panel with your email and password.';

  @override
  String get email => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get loginNotAdmin =>
      'This isn\'t an admin account, so you weren\'t signed in. Use your admin account.';

  @override
  String get noticeSessionExpired =>
      'Your session expired. Sign in again to continue.';

  @override
  String get noticeAccountSuspended =>
      'Your account was suspended and you were signed out.';

  @override
  String get navLabel => 'Admin menu';

  @override
  String get openMenu => 'Open menu';

  @override
  String get navHome => 'Overview';

  @override
  String get navApplications => 'Applications';

  @override
  String get navComplaints => 'Complaints';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navPayments => 'Payments';

  @override
  String get dashboardTitle => 'Overview';

  @override
  String dashboardWelcome(String name) {
    return 'Hi $name, here is what\'s waiting.';
  }

  @override
  String get statPendingApplications => 'Applications waiting for review';

  @override
  String get statOpenComplaints => 'Open complaints';

  @override
  String get statActiveJobs => 'Jobs in progress';

  @override
  String get statLockedEscrow => 'Amount in secure hold';

  @override
  String get reviewPending => 'Under review';

  @override
  String get reviewNeedsDocuments => 'Documents needed';

  @override
  String get reviewApproved => 'Verified';

  @override
  String get reviewRejected => 'Rejected';

  @override
  String get reviewSuspended => 'Suspended';

  @override
  String get complaintOpen => 'Open';

  @override
  String get complaintInReview => 'In review';

  @override
  String get complaintResolved => 'Resolved';

  @override
  String get complaintDismissed => 'Dismissed';

  @override
  String get reasonNoShow => 'Pro didn\'t show up';

  @override
  String get reasonIncompleteWork => 'Work incomplete or faulty';

  @override
  String get reasonExtraCharge => 'Extra charge asked';

  @override
  String get reasonRudeBehaviour => 'Rude behaviour';

  @override
  String get reasonOther => 'Other';

  @override
  String get accountActive => 'Active';

  @override
  String get accountSuspended => 'Suspended';

  @override
  String get accountDeleted => 'Deleted';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get rolePro => 'Pro';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get actorSystem => 'System';

  @override
  String get docIdentity => 'ID';

  @override
  String get docTradeCert => 'Trade certificate';

  @override
  String get docTax => 'Tax certificate';

  @override
  String get docCriminalRecord => 'Criminal record';

  @override
  String get docPending => 'Pending';

  @override
  String get docAccepted => 'Accepted';

  @override
  String get docRejected => 'Rejected';

  @override
  String get jobAwaitingAppointment => 'Awaiting appointment';

  @override
  String get jobScheduled => 'Appointment confirmed';

  @override
  String get jobArrived => 'Pro on site';

  @override
  String get jobInProgress => 'In progress';

  @override
  String get jobWorkFinished => 'Awaiting customer approval';

  @override
  String get jobCompleted => 'Completed';

  @override
  String get jobDisputed => 'Complaint under review';

  @override
  String get jobCancelled => 'Cancelled';

  @override
  String get jobResolved => 'Resolved';

  @override
  String get escrowInitialized => 'Started';

  @override
  String get escrowLocked => 'In secure hold';

  @override
  String get escrowFailed => 'Failed';

  @override
  String get escrowDisputed => 'Under complaint';

  @override
  String get escrowReleased => 'Paid out to pro';

  @override
  String get escrowRefunded => 'Refunded to customer';

  @override
  String get escrowSplit => 'Split';

  @override
  String get actionApproved => 'Approved';

  @override
  String get actionRejected => 'Rejected';

  @override
  String get actionDocumentsRequested => 'Requested documents';

  @override
  String get actionSuspended => 'Suspended';

  @override
  String get actionReactivated => 'Reactivated';

  @override
  String get actionReviewed => 'Took into review';

  @override
  String get actionDecided => 'Made a decision';

  @override
  String get actionWarned => 'Warned the pro';

  @override
  String get decisionResultWarned => 'A warning was recorded for the pro.';

  @override
  String get decisionResultSuspended => 'The pro profile was suspended.';

  @override
  String get paymentMissing => 'There is no secure hold record for this job.';

  @override
  String get colPro => 'Pro';

  @override
  String get colCategories => 'Categories';

  @override
  String get colDistricts => 'Districts';

  @override
  String get colSubmitted => 'Submitted';

  @override
  String get colDocuments => 'Documents';

  @override
  String get colStatus => 'Status';

  @override
  String get colComplaint => 'Complaint';

  @override
  String get colJob => 'Job';

  @override
  String get colAmount => 'Amount';

  @override
  String get colDate => 'Date';

  @override
  String get colReason => 'Reason';

  @override
  String get colAccount => 'Account';

  @override
  String get colRole => 'Role';

  @override
  String get colRegistered => 'Registered';

  @override
  String get colActions => 'Actions';

  @override
  String get colRef => 'Payment ref';

  @override
  String get colProvider => 'Provider';

  @override
  String get colParties => 'Customer / pro';

  @override
  String get colTotal => 'Total';

  @override
  String get colServiceFee => 'Service fee';

  @override
  String get colProPayout => 'Payout to pro';

  @override
  String get colRefunded => 'Refunded';

  @override
  String get applicationsTitle => 'Pro applications';

  @override
  String get applicationsSubtitle =>
      'Oldest application first; review them in order.';

  @override
  String get applicationsSearchHint => 'Name, business, email or phone';

  @override
  String get applicationsEmptyTitle => 'No applications in this status';

  @override
  String get applicationsEmptyMessage =>
      'Pick another status or change your search.';

  @override
  String get applicationDetailTitle => 'Application';

  @override
  String get personAndBusiness => 'Person and business';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone';

  @override
  String get businessName => 'Business name';

  @override
  String get experience => 'Experience';

  @override
  String yearsCount(int count) {
    return '$count yrs';
  }

  @override
  String get bio => 'About';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsEmpty => 'This application has no documents.';

  @override
  String get documentPreview => 'Document preview';

  @override
  String get previewUnavailable => 'No preview';

  @override
  String get openInNewTab => 'Open in new tab';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No action taken yet.';

  @override
  String get decisionTitle => 'Decision';

  @override
  String get reviewNoteLabel => 'Review note';

  @override
  String get noActionsForStatus =>
      'There is nothing to do for this application.';

  @override
  String get approve => 'Approve';

  @override
  String get approveTitle => 'Approve application';

  @override
  String approveMessage(String business) {
    return '$business will be approved, all documents accepted, and the pro will start seeing requests. The pro is notified.';
  }

  @override
  String get approvedNotice => 'Application approved.';

  @override
  String get reject => 'Reject';

  @override
  String get rejectTitle => 'Reject application';

  @override
  String get rejectMessage =>
      'Your reason is sent to the pro as a notification. The application closes as rejected.';

  @override
  String get rejectNoteLabel => 'Reason for rejection';

  @override
  String get rejectedNotice => 'Application rejected.';

  @override
  String get requestDocs => 'Request documents';

  @override
  String get requestDocsTitle => 'Request documents';

  @override
  String get requestDocsMessage =>
      'The documents you select are marked rejected and the pro uploads them again.';

  @override
  String get requestDocsTypes => 'Requested documents';

  @override
  String get requestDocsPickOne => 'Select at least one document type.';

  @override
  String get requestDocsNoteLabel => 'Note to the pro';

  @override
  String get requestDocsDoneNotice => 'Documents requested.';

  @override
  String noteHelper(int min, int max) {
    return '$min-$max characters';
  }

  @override
  String noteOptionalHelper(int max) {
    return 'Optional, up to $max characters';
  }

  @override
  String get approveNoteLabel => 'Approval note (optional)';

  @override
  String noteTooShort(int min) {
    return 'The note must be at least $min characters.';
  }

  @override
  String noteTooLong(int max) {
    return 'The note can be at most $max characters.';
  }

  @override
  String get complaintsTitle => 'Complaints';

  @override
  String get complaintsSubtitle => 'Oldest complaint first.';

  @override
  String get complaintsActive => 'Open and in review';

  @override
  String get complaintsEmptyTitle => 'No complaints in this status';

  @override
  String get complaintsEmptyMessage => 'Try another status.';

  @override
  String get complaintDetailTitle => 'Complaint';

  @override
  String complaintDetailHeading(String code) {
    return 'Complaint $code';
  }

  @override
  String get complaintSection => 'Complaint';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get evidenceTitle => 'Evidence';

  @override
  String get evidenceEmpty => 'No evidence attached.';

  @override
  String get timelineTitle => 'Job timeline';

  @override
  String get timelineEmpty => 'The job has no recorded events.';

  @override
  String get eventNote => 'Note added';

  @override
  String get eventPhoto => 'Photo added';

  @override
  String get eventAppointmentProposed => 'Appointment proposed';

  @override
  String get eventAppointmentAccepted => 'Appointment accepted';

  @override
  String get chatTitle => 'Chat log';

  @override
  String get chatEmpty => 'There are no messages for this job.';

  @override
  String get paymentSummaryTitle => 'Payment summary';

  @override
  String get partiesTitle => 'Parties';

  @override
  String get warningCount => 'Pro\'s warnings';

  @override
  String get cancellationCount => 'Pro\'s cancellations';

  @override
  String get reviewComplaint => 'Take into review';

  @override
  String get reviewComplaintTitle => 'Take complaint into review';

  @override
  String reviewComplaintMessage(String code) {
    return '$code moves to review. You can decide it after that.';
  }

  @override
  String get reviewComplaintDone => 'Complaint taken into review.';

  @override
  String get decide => 'Decide';

  @override
  String get decisionResultTitle => 'Decision made';

  @override
  String get decisionFullRefund => 'Full refund';

  @override
  String get decisionFullRefundDesc =>
      'The customer is refunded the full amount. The job is cancelled and no service fee is taken.';

  @override
  String get decisionSplit => '50% / 50%';

  @override
  String get decisionSplitDesc =>
      'The amount is split evenly between the customer and the pro. No service fee is taken.';

  @override
  String get decisionRelease => 'Dismiss, pay out to pro';

  @override
  String get decisionReleaseDesc =>
      'The complaint is dismissed, the amount goes to the pro and a 10% service fee is kept.';

  @override
  String get outcomeCustomerRefund => 'Refund to customer';

  @override
  String get outcomeProPayout => 'Payout to pro';

  @override
  String decisionDialogTitle(String code) {
    return 'Decision for $code';
  }

  @override
  String decisionDialogIntro(String total) {
    return 'The amount in secure hold is $total. The server calculates the refund and the pro\'s share when you decide; the result shows on the complaint page.';
  }

  @override
  String get decisionDialogIntroNoPayment =>
      'No secure hold record was found for this job. The server calculates the refund and the pro\'s share when you decide.';

  @override
  String get decisionPickOne => 'Pick a decision.';

  @override
  String get decisionNoteLabel => 'Reason for the decision';

  @override
  String get warnPro => 'Record a warning for the pro';

  @override
  String get warnProHint => 'The pro\'s warning count goes up by 1.';

  @override
  String get suspendProProfile => 'Suspend the pro profile';

  @override
  String get suspendProProfileHint =>
      'Their pending offers are withdrawn. The user account isn\'t suspended.';

  @override
  String get decisionSubmit => 'Decide';

  @override
  String get decisionConfirmTitle => 'Finalize the decision';

  @override
  String decisionConfirmMessage(String decision) {
    return 'Your decision: $decision.\n\nThe server calculates the amounts; the result shows on the complaint page.\n\nThis can\'t be undone. The money moves right away, both sides are notified and the complaint closes.';
  }

  @override
  String get decisionConfirmWarn =>
      'A warning will also be recorded for the pro.';

  @override
  String get decisionConfirmSuspend =>
      'The pro profile will also be suspended.';

  @override
  String get decisionConfirmAction => 'Finalize decision';

  @override
  String get decisionGatewayFailed =>
      'The payment system was unreachable and nothing changed. Try again shortly.';

  @override
  String get decisionDone => 'Decision made, both sides notified.';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsSubtitle => 'Customer, pro and admin accounts.';

  @override
  String get accountsSearchHint => 'Name, email or phone';

  @override
  String get accountsEmptyTitle => 'No accounts found';

  @override
  String get accountsEmptyMessage => 'Change your search or filters.';

  @override
  String proRoleLine(String business, String status) {
    return 'Pro: $business ($status)';
  }

  @override
  String get suspend => 'Suspend';

  @override
  String suspendAccountTitle(String name) {
    return 'Suspend $name\'s account';
  }

  @override
  String get suspendAccountMessage =>
      'All of this user\'s sessions end and their pending offers are withdrawn. Jobs in progress are left untouched.';

  @override
  String get suspendNoteLabel => 'Reason for suspension';

  @override
  String get suspendedNotice => 'Account suspended.';

  @override
  String suspendedWithJobsNotice(int count) {
    return 'Account suspended. $count jobs are still in progress and were left untouched.';
  }

  @override
  String get reactivate => 'Reactivate';

  @override
  String reactivateTitle(String name) {
    return 'Reactivate $name\'s account';
  }

  @override
  String get reactivateMessage => 'The user will be able to sign in again.';

  @override
  String get reactivatedNotice => 'Account reactivated.';

  @override
  String get reactivatePro => 'Restore pro profile';

  @override
  String reactivateProTitle(String business) {
    return 'Restore $business\'s pro profile';
  }

  @override
  String get reactivateProMessage =>
      'The suspended pro profile goes back to approved and the pro sees requests again.';

  @override
  String get proReactivatedNotice => 'Pro profile restored.';

  @override
  String get cannotSuspendSelf => 'You can\'t suspend your own account.';

  @override
  String get cannotSuspendAdmin => 'Admin accounts can\'t be suspended.';

  @override
  String get paymentsTitle => 'Payments ledger';

  @override
  String get paymentsSubtitle => 'Secure hold records and totals.';

  @override
  String get paymentsEmptyTitle => 'No payments in this status';

  @override
  String get paymentsEmptyMessage => 'Try another status.';

  @override
  String get totalLocked => 'In secure hold';

  @override
  String get totalReleased => 'Paid out to pros';

  @override
  String get totalCommission => 'Service fee total';

  @override
  String get totalRefunded => 'Refunded';
}
