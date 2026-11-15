import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

String reviewStatusLabel(AppLocalizations l, ReviewStatus s) => switch (s) {
  ReviewStatus.pendingReview => l.reviewPending,
  ReviewStatus.needsDocuments => l.reviewNeedsDocuments,
  ReviewStatus.approved => l.reviewApproved,
  ReviewStatus.rejected => l.reviewRejected,
  ReviewStatus.suspended => l.reviewSuspended,
};

Widget reviewStatusChip(AppLocalizations l, ReviewStatus s) => StatusChip(
  label: reviewStatusLabel(l, s),
  icon: switch (s) {
    ReviewStatus.pendingReview => Icons.hourglass_top,
    ReviewStatus.needsDocuments => Icons.folder_open,
    ReviewStatus.approved => Icons.verified,
    ReviewStatus.rejected => Icons.cancel_outlined,
    ReviewStatus.suspended => Icons.pause_circle_outline,
  },
  tone: switch (s) {
    ReviewStatus.pendingReview => StatusTone.urgent,
    ReviewStatus.needsDocuments => StatusTone.info,
    ReviewStatus.approved => StatusTone.success,
    ReviewStatus.rejected => StatusTone.error,
    ReviewStatus.suspended => StatusTone.error,
  },
);

String complaintStatusLabel(AppLocalizations l, ComplaintStatus s) =>
    switch (s) {
      ComplaintStatus.open => l.complaintOpen,
      ComplaintStatus.inReview => l.complaintInReview,
      ComplaintStatus.resolved => l.complaintResolved,
      ComplaintStatus.dismissed => l.complaintDismissed,
    };

Widget complaintStatusChip(AppLocalizations l, ComplaintStatus s) => StatusChip(
  label: complaintStatusLabel(l, s),
  icon: switch (s) {
    ComplaintStatus.open => Icons.flag_outlined,
    ComplaintStatus.inReview => Icons.manage_search,
    ComplaintStatus.resolved => Icons.check_circle_outline,
    ComplaintStatus.dismissed => Icons.do_not_disturb_on_outlined,
  },
  tone: switch (s) {
    ComplaintStatus.open => StatusTone.urgent,
    ComplaintStatus.inReview => StatusTone.info,
    ComplaintStatus.resolved => StatusTone.success,
    ComplaintStatus.dismissed => StatusTone.neutral,
  },
);

String complaintReasonLabel(AppLocalizations l, ComplaintReason r) =>
    switch (r) {
      ComplaintReason.noShow => l.reasonNoShow,
      ComplaintReason.incompleteWork => l.reasonIncompleteWork,
      ComplaintReason.extraCharge => l.reasonExtraCharge,
      ComplaintReason.rudeBehaviour => l.reasonRudeBehaviour,
      ComplaintReason.other => l.reasonOther,
    };

String accountStatusLabel(AppLocalizations l, AccountStatus s) => switch (s) {
  AccountStatus.active => l.accountActive,
  AccountStatus.suspended => l.accountSuspended,
  AccountStatus.deleted => l.accountDeleted,
};

Widget accountStatusChip(AppLocalizations l, AccountStatus s) => StatusChip(
  label: accountStatusLabel(l, s),
  icon: switch (s) {
    AccountStatus.active => Icons.check_circle_outline,
    AccountStatus.suspended => Icons.block,
    AccountStatus.deleted => Icons.delete_outline,
  },
  tone: switch (s) {
    AccountStatus.active => StatusTone.success,
    AccountStatus.suspended => StatusTone.error,
    AccountStatus.deleted => StatusTone.neutral,
  },
);

String accountRoleLabel(AppLocalizations l, AccountRole r) => switch (r) {
  AccountRole.customer => l.roleCustomer,
  AccountRole.pro => l.rolePro,
  AccountRole.admin => l.roleAdmin,
};

String docTypeLabel(AppLocalizations l, ProDocumentType t) => switch (t) {
  ProDocumentType.identity => l.docIdentity,
  ProDocumentType.tradeCert => l.docTradeCert,
  ProDocumentType.tax => l.docTax,
  ProDocumentType.criminalRecord => l.docCriminalRecord,
};

String docStatusLabel(AppLocalizations l, DocumentStatus s) => switch (s) {
  DocumentStatus.pending => l.docPending,
  DocumentStatus.accepted => l.docAccepted,
  DocumentStatus.rejected => l.docRejected,
};

Widget docStatusChip(AppLocalizations l, DocumentStatus s) => StatusChip(
  label: docStatusLabel(l, s),
  icon: switch (s) {
    DocumentStatus.pending => Icons.hourglass_empty,
    DocumentStatus.accepted => Icons.check_circle_outline,
    DocumentStatus.rejected => Icons.cancel_outlined,
  },
  tone: switch (s) {
    DocumentStatus.pending => StatusTone.neutral,
    DocumentStatus.accepted => StatusTone.success,
    DocumentStatus.rejected => StatusTone.error,
  },
);

String jobStatusLabel(AppLocalizations l, JobStatus s) => switch (s) {
  JobStatus.awaitingAppointment => l.jobAwaitingAppointment,
  JobStatus.scheduled => l.jobScheduled,
  JobStatus.arrived => l.jobArrived,
  JobStatus.inProgress => l.jobInProgress,
  JobStatus.workFinished => l.jobWorkFinished,
  JobStatus.completed => l.jobCompleted,
  JobStatus.disputed => l.jobDisputed,
  JobStatus.cancelled => l.jobCancelled,
  JobStatus.resolved => l.jobResolved,
};

String actorRoleLabel(AppLocalizations l, ActorRole r) => switch (r) {
  ActorRole.customer => l.roleCustomer,
  ActorRole.pro => l.rolePro,
  ActorRole.system => l.actorSystem,
  ActorRole.admin => l.roleAdmin,
};

String partyRoleLabel(AppLocalizations l, PartyRole r) => switch (r) {
  PartyRole.customer => l.roleCustomer,
  PartyRole.pro => l.rolePro,
};

/// Sunucudaki emanet durumu (`LOCKED` vb.). Bilinmeyen değer olduğu gibi gösterilir.
String escrowLabel(AppLocalizations l, String raw) => switch (raw) {
  'INITIALIZED' => l.escrowInitialized,
  'LOCKED' => l.escrowLocked,
  'FAILED' => l.escrowFailed,
  'DISPUTED' => l.escrowDisputed,
  'RELEASED_TO_PRO' => l.escrowReleased,
  'REFUNDED_TO_CUSTOMER' => l.escrowRefunded,
  'SPLIT_SETTLED' => l.escrowSplit,
  _ => raw,
};

Widget escrowChip(AppLocalizations l, String raw) => StatusChip(
  label: escrowLabel(l, raw),
  icon: switch (raw) {
    'LOCKED' => Icons.lock_outline,
    'DISPUTED' => Icons.flag_outlined,
    'RELEASED_TO_PRO' => Icons.north_east,
    'REFUNDED_TO_CUSTOMER' => Icons.undo,
    'SPLIT_SETTLED' => Icons.call_split,
    'FAILED' => Icons.error_outline,
    _ => Icons.hourglass_empty,
  },
  tone: switch (raw) {
    'LOCKED' => StatusTone.info,
    'DISPUTED' => StatusTone.urgent,
    'RELEASED_TO_PRO' => StatusTone.success,
    'REFUNDED_TO_CUSTOMER' => StatusTone.primary,
    'SPLIT_SETTLED' => StatusTone.primary,
    'FAILED' => StatusTone.error,
    _ => StatusTone.neutral,
  },
);

String decisionLabel(AppLocalizations l, ComplaintDecision d) => switch (d) {
  ComplaintDecision.fullRefund => l.decisionFullRefund,
  ComplaintDecision.split5050 => l.decisionSplit,
  ComplaintDecision.releaseToPro => l.decisionRelease,
};

/// Sunucudaki yönetici işlem kodu; bilinmeyen kod okunur hale getirilir.
String adminActionLabel(AppLocalizations l, String raw) {
  final key = raw.toUpperCase();
  if (key.contains('APPROVE')) return l.actionApproved;
  if (key.contains('REJECT')) return l.actionRejected;
  if (key.contains('REQUEST_DOC')) return l.actionDocumentsRequested;
  if (key.contains('SUSPEND')) return l.actionSuspended;
  if (key.contains('REACTIVATE')) return l.actionReactivated;
  if (key.contains('REVIEW')) return l.actionReviewed;
  if (key.contains('DECISION') || key.contains('DECIDE')) {
    return l.actionDecided;
  }
  return raw;
}
