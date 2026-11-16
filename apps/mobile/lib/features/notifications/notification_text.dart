import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:flutter/material.dart' show IconData, Icons;

import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../jobs/job_ui.dart';

const String _dash = '–';

/// Bildirim metni `type` ve `params`tan üretilir (sözleşme: "Notifications").
/// Eksik parametre `–` olur; bilinmeyen tür genel bir metin verir.
String notificationText(AppLocalizations l, Notification n, DateTime now) {
  String p(String key) {
    final v = n.param(key);
    return v == null || v.isEmpty ? _dash : v;
  }

  String money(String key) {
    final raw = n.params[key];
    if (raw == null) return _dash;
    try {
      return formatMoney(Money.fromJson(raw), l.localeName);
    } catch (_) {
      // Bozuk tutar (metin, `NaN`, nesne) listeyi düşürmesin.
      return _dash;
    }
  }

  /// Tutar yoksa, bozuksa ya da 0 ise satır hiç yazılmaz ("Tutar: ₺0" olmaz).
  bool hasPositiveAmount(String key) {
    final raw = n.params[key];
    if (raw == null) return false;
    try {
      return Money.fromJson(raw).isPositive;
    } catch (_) {
      return false;
    }
  }

  String slot() {
    final from = DateTime.tryParse(n.param('slotFrom') ?? '');
    final to = DateTime.tryParse(n.param('slotTo') ?? '');
    if (from == null || to == null) return _dash;
    return formatWindow(l, from, to, now);
  }

  String deadline() {
    final at = DateTime.tryParse(n.param('autoCompleteAt') ?? '');
    return at == null ? _dash : formatDayTime(l, at, now);
  }

  String status() {
    final raw = n.param('status');
    for (final s in JobStatus.values) {
      if (s.wire == raw) {
        final viewer = (n.targetRoute ?? '').startsWith('/p/')
            ? PartyRole.pro
            : PartyRole.customer;
        return jobStatusLabel(l, s, viewer);
      }
    }
    return p('status');
  }

  String decision() {
    final raw = n.param('decision');
    return complaintDecisionLabel(l, raw) ?? p('decision');
  }

  return switch (n.kind) {
    NotificationType.newMatchingRequest => l.notifNewMatchingRequest(
      p('title'),
      p('districtName'),
    ),
    NotificationType.offerReceived => l.notifOfferReceived(
      p('proBusinessName'),
      p('title'),
      money('amount'),
    ),
    NotificationType.offerDeclined => l.notifOfferDeclined(
      p('title'),
      p('publicCode'),
    ),
    NotificationType.offerSuperseded => l.notifOfferSuperseded(
      p('title'),
      p('publicCode'),
    ),
    NotificationType.offerAccepted => l.notifOfferAccepted(
      p('title'),
      p('publicCode'),
      money('amount'),
    ),
    NotificationType.requestUpdated => l.notifRequestUpdated(
      p('title'),
      p('publicCode'),
    ),
    NotificationType.appointmentProposed => l.notifAppointmentProposed(
      p('publicCode'),
      slot(),
    ),
    NotificationType.appointmentConfirmed => l.notifAppointmentConfirmed(
      p('publicCode'),
      slot(),
    ),
    NotificationType.jobStageChanged => l.notifJobStageChanged(
      p('publicCode'),
      status(),
    ),
    NotificationType.workFinished => l.notifWorkFinished(
      p('publicCode'),
      deadline(),
    ),
    NotificationType.autoCompleteReminder => l.notifAutoCompleteReminder(
      p('publicCode'),
      deadline(),
    ),
    NotificationType.payoutReleased => l.notifPayoutReleased(
      p('publicCode'),
      money('amount'),
    ),
    NotificationType.jobCancelled => switch ((n.param('byRole') ?? '')
        .toUpperCase()) {
      'CUSTOMER' => l.notifJobCancelledByCustomer(
        p('publicCode'),
        money('refundAmount'),
      ),
      'PRO' => l.notifJobCancelledByPro(p('publicCode'), money('refundAmount')),
      _ => l.notifJobCancelledOther(p('publicCode'), money('refundAmount')),
    },
    NotificationType.newMessage => l.notifNewMessage(
      p('senderName'),
      p('publicCode'),
    ),
    NotificationType.complaintOpened => l.notifComplaintOpened(
      p('publicCode'),
      p('complaintCode'),
    ),
    NotificationType.complaintDecided =>
      !hasPositiveAmount('amount')
          ? l.notifComplaintDecided(p('complaintCode'), decision())
          : l.notifComplaintDecidedAmount(
              p('complaintCode'),
              decision(),
              money('amount'),
            ),
    NotificationType.proApproved => l.notifProApproved,
    NotificationType.proRejected => l.notifProRejected(p('note')),
    NotificationType.proNeedsDocuments => l.notifProNeedsDocuments(p('note')),
    NotificationType.unknown => l.notifUnknown,
  };
}

IconData notificationIcon(NotificationType t) => switch (t) {
  NotificationType.newMatchingRequest => Icons.search,
  NotificationType.offerReceived => Icons.local_offer_outlined,
  NotificationType.offerDeclined ||
  NotificationType.offerSuperseded => Icons.local_offer_outlined,
  NotificationType.offerAccepted => Icons.check_circle_outline,
  NotificationType.requestUpdated => Icons.edit_note,
  NotificationType.appointmentProposed ||
  NotificationType.appointmentConfirmed => Icons.event_available,
  NotificationType.jobStageChanged => Icons.handyman_outlined,
  NotificationType.workFinished ||
  NotificationType.autoCompleteReminder => Icons.fact_check_outlined,
  NotificationType.payoutReleased => Icons.payments_outlined,
  NotificationType.jobCancelled => Icons.cancel_outlined,
  NotificationType.newMessage => Icons.chat_bubble_outline,
  NotificationType.complaintOpened ||
  NotificationType.complaintDecided => Icons.report_outlined,
  NotificationType.proApproved => Icons.verified_outlined,
  NotificationType.proRejected => Icons.cancel_outlined,
  NotificationType.proNeedsDocuments => Icons.upload_file,
  NotificationType.unknown => Icons.notifications_none,
};
