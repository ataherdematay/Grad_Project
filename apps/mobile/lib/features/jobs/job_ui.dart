import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../core/photos.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../customer/offers_screens.dart' show warrantyText;

/// Yığında geri yokken (`go` ile açılan ekran) sistem geri tuşu da ilgili
/// üst ekrana gider; uygulamayı kapatmaz (NAVIGATION_RULES §1).
class StackFallback extends StatelessWidget {
  const StackFallback({super.key, required this.fallback, required this.child});

  final String fallback;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final canPop = GoRouter.of(context).canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(fallback);
      },
      child: child,
    );
  }
}

// --- Durum etiketleri (GLOSSARY) --------------------------------------------

String jobStatusLabel(AppLocalizations l, JobStatus s, PartyRole viewer) {
  final pro = viewer == PartyRole.pro;
  return switch (s) {
    JobStatus.awaitingAppointment =>
      pro ? l.jobStatusAwaitingPro : l.jobStatusAwaiting,
    JobStatus.scheduled => pro ? l.jobStatusScheduledPro : l.jobStatusScheduled,
    JobStatus.arrived => pro ? l.jobStatusArrivedPro : l.jobStatusArrived,
    JobStatus.inProgress => l.jobStatusInProgress,
    JobStatus.workFinished =>
      pro ? l.jobStatusWorkFinishedPro : l.jobStatusWorkFinished,
    JobStatus.completed => l.jobStatusCompleted,
    JobStatus.disputed => l.jobStatusDisputed,
    JobStatus.cancelled => l.jobStatusCancelled,
    JobStatus.resolved => l.jobStatusResolved,
  };
}

Widget jobStatusChip(AppLocalizations l, JobStatus s, PartyRole viewer) {
  final (icon, tone) = switch (s) {
    JobStatus.awaitingAppointment => (Icons.hourglass_top, StatusTone.urgent),
    JobStatus.scheduled => (Icons.event_available, StatusTone.primary),
    JobStatus.arrived => (Icons.place_outlined, StatusTone.primary),
    JobStatus.inProgress => (Icons.build_outlined, StatusTone.primary),
    JobStatus.workFinished => (Icons.fact_check_outlined, StatusTone.urgent),
    JobStatus.completed => (Icons.check_circle_outline, StatusTone.success),
    JobStatus.disputed => (Icons.report_outlined, StatusTone.error),
    JobStatus.cancelled => (Icons.cancel_outlined, StatusTone.neutral),
    JobStatus.resolved => (Icons.gavel_outlined, StatusTone.neutral),
  };
  return StatusChip(
    label: jobStatusLabel(l, s, viewer),
    icon: icon,
    tone: tone,
  );
}

String escrowLabel(AppLocalizations l, EscrowStatus s, PartyRole viewer) {
  final pro = viewer == PartyRole.pro;
  return switch (s) {
    EscrowStatus.initialized => l.escrowInitialized,
    EscrowStatus.locked => l.escrowLocked,
    EscrowStatus.failed => l.escrowFailed,
    EscrowStatus.refundedToCustomer =>
      pro ? l.escrowRefundedPro : l.escrowRefunded,
    EscrowStatus.releasedToPro => pro ? l.escrowReleasedPro : l.escrowReleased,
    EscrowStatus.disputed => l.escrowDisputed,
    EscrowStatus.splitSettled => l.escrowSplit,
  };
}

String actorLabel(AppLocalizations l, ActorRole actor, PartyRole viewer) {
  if (actor == ActorRole.customer && viewer == PartyRole.customer ||
      actor == ActorRole.pro && viewer == PartyRole.pro) {
    return l.actorYou;
  }
  return switch (actor) {
    ActorRole.customer => l.actorCustomer,
    ActorRole.pro => l.actorPro,
    ActorRole.system => l.actorSystem,
    ActorRole.admin => l.actorAdmin,
  };
}

String eventTitle(AppLocalizations l, JobEvent e, PartyRole viewer) =>
    switch (e.type) {
      JobEventType.statusChanged =>
        e.toStatus == null
            ? l.eventStatus
            : jobStatusLabel(l, e.toStatus!, viewer),
      JobEventType.note => l.eventNote,
      JobEventType.photo => l.eventPhoto,
      JobEventType.appointmentProposed => l.eventProposed,
      JobEventType.appointmentAccepted => l.eventAccepted,
    };

/// Olay notu. Sunucu bazı olaylarda kod yazar; kullanıcıya okunur metin
/// gösterilir:
/// - randevu olayları: `başlangıç/bitiş` (ISO-8601) → "Yarın, 09:00-11:00"
/// - şikayet (→ DISPUTED): `INCOMPLETE_WORK` → "İş eksik ya da hatalı"
/// - iptal (→ CANCELLED): `PLANS_CHANGED` ya da `PLANS_CHANGED: not`
String eventNoteText(AppLocalizations l, JobEvent e, DateTime now) {
  final note = e.note ?? '';
  if (e.type == JobEventType.appointmentProposed ||
      e.type == JobEventType.appointmentAccepted) {
    final parts = note.split('/');
    if (parts.length == 2) {
      final from = DateTime.tryParse(parts[0]);
      final to = DateTime.tryParse(parts[1]);
      if (from != null && to != null) return formatWindow(l, from, to, now);
    }
    return note;
  }
  if (e.type != JobEventType.statusChanged) return note;
  T? byWire<T extends Enum>(List<T> values, String code) {
    for (final v in values) {
      if (v.wire == code) return v;
    }
    return null;
  }

  switch (e.toStatus) {
    case JobStatus.disputed:
      final r = byWire(ComplaintReason.values, note.trim());
      return r == null ? note : complaintReasonLabel(l, r);
    case JobStatus.cancelled:
      final i = note.indexOf(': ');
      final code = (i < 0 ? note : note.substring(0, i)).trim();
      final rest = i < 0 ? '' : note.substring(i + 2);
      final String? label;
      if (e.actorRole == ActorRole.pro) {
        final r = byWire(ProCancelReason.values, code);
        label = r == null ? null : proCancelReasonLabel(l, r);
      } else {
        final r = byWire(CustomerCancelReason.values, code);
        label = r == null ? null : customerCancelReasonLabel(l, r);
      }
      if (label == null) return note;
      return rest.isEmpty ? label : '$label: $rest';
    default:
      return note;
  }
}

String customerCancelReasonLabel(AppLocalizations l, CustomerCancelReason r) =>
    switch (r) {
      CustomerCancelReason.plansChanged => l.cancelReasonPlansChanged,
      CustomerCancelReason.solved => l.cancelReasonSolved,
      CustomerCancelReason.proUnreachable => l.cancelReasonProUnreachable,
      CustomerCancelReason.otherProvider => l.cancelReasonOtherProvider,
      CustomerCancelReason.other => l.cancelReasonOther,
    };

String proCancelReasonLabel(AppLocalizations l, ProCancelReason r) =>
    switch (r) {
      ProCancelReason.scheduleConflict => l.proCancelReasonSchedule,
      ProCancelReason.cannotDoJob => l.proCancelReasonCannot,
      ProCancelReason.customerUnreachable => l.proCancelReasonCustomer,
      ProCancelReason.other => l.cancelReasonOther,
    };

String complaintReasonLabel(AppLocalizations l, ComplaintReason r) =>
    switch (r) {
      ComplaintReason.noShow => l.complaintReasonNoShow,
      ComplaintReason.incompleteWork => l.complaintReasonIncomplete,
      ComplaintReason.extraCharge => l.complaintReasonExtraCharge,
      ComplaintReason.rudeBehaviour => l.complaintReasonRude,
      ComplaintReason.other => l.complaintReasonOther,
    };

// --- Randevu aralıkları ------------------------------------------------------

/// Gün içindeki sabit aralıklar (başlangıç, bitiş saati).
const List<(int, int)> kSlotHours = [(9, 11), (11, 13), (14, 16), (16, 18)];

@immutable
class SlotWindow {
  const SlotWindow(this.from, this.to);

  /// Yerel saat.
  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) =>
      other is SlotWindow &&
      other.from.isAtSameMomentAs(from) &&
      other.to.isAtSameMomentAs(to);

  @override
  int get hashCode =>
      Object.hash(from.millisecondsSinceEpoch, to.millisecondsSinceEpoch);
}

/// Bugünden başlayarak [days] günün aralıkları. Başlangıcı geçmiş aralıklar
/// atılır; boş kalan gün listede yer almaz.
List<MapEntry<DateTime, List<SlotWindow>>> upcomingSlotDays(
  DateTime now, {
  int days = 7,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final result = <MapEntry<DateTime, List<SlotWindow>>>[];
  for (var i = 0; i < days; i++) {
    final day = DateTime(today.year, today.month, today.day + i);
    final slots = [
      for (final (a, b) in kSlotHours)
        SlotWindow(
          DateTime(day.year, day.month, day.day, a),
          DateTime(day.year, day.month, day.day, b),
        ),
    ].where((s) => s.from.isAfter(now)).toList();
    if (slots.isNotEmpty) result.add(MapEntry(day, slots));
  }
  return result;
}

String slotLabel(SlotWindow s) =>
    '${_two(s.from.hour)}:${_two(s.from.minute)}-${_two(s.to.hour)}:${_two(s.to.minute)}';

String _two(int v) => v.toString().padLeft(2, '0');

// --- Ortak bölümler ----------------------------------------------------------

/// Randevu kartı: onaylı aralık, bekleyen öneri.
class AppointmentCard extends ConsumerWidget {
  const AppointmentCard({super.key, required this.job});

  final JobDetail job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    final a = job.appointment;
    final p = a.pendingProposal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(l.appointmentTitle, style: AppTypography.cardTitle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            a.scheduledFrom != null && a.scheduledTo != null
                ? formatWindow(l, a.scheduledFrom!, a.scheduledTo!, now)
                : l.appointmentNotChosen,
            style: AppTypography.body,
          ),
          if (p != null) ...[
            const Divider(height: AppSpacing.lg),
            Text(
              p.proposedBy == job.viewerRole
                  ? l.proposalMine
                  : (job.viewerRole == PartyRole.customer
                        ? l.proposalFromPro
                        : l.proposalFromCustomer),
              style: AppTypography.label,
            ),
            const SizedBox(height: 4),
            Text(
              formatWindow(l, p.slotFrom, p.slotTo, now),
              style: AppTypography.cardTitle,
            ),
          ],
        ],
      ),
    );
  }
}

/// Zaman çizelgesi: durum değişimleri, notlar ve fotoğraflar.
class TimelineView extends ConsumerWidget {
  const TimelineView({super.key, required this.job});

  final JobDetail job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    if (job.timeline.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(l.timelineTitle),
        for (final e in job.timeline)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    switch (e.type) {
                      JobEventType.statusChanged => Icons.flag_outlined,
                      JobEventType.note => Icons.notes,
                      JobEventType.photo => Icons.photo_outlined,
                      _ => Icons.event_outlined,
                    },
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventTitle(l, e, job.viewerRole),
                        style: AppTypography.cardTitle,
                      ),
                      Text(
                        '${actorLabel(l, e.actorRole, job.viewerRole)} · ${formatDayTime(l, e.createdAt, now)}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if ((e.note ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            eventNoteText(l, e, now),
                            style: AppTypography.body,
                          ),
                        ),
                      if (e.photo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: MediaImage(
                            e.photo!.url,
                            width: 160,
                            height: 120,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address});

  final JobAddress address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(l.addressTitle, style: AppTypography.cardTitle),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${address.districtName}, ${address.neighborhood}',
            style: AppTypography.body,
          ),
          if ((address.lineFull ?? '').isNotEmpty)
            Text(address.lineFull!, style: AppTypography.body),
          if ((address.doorNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${l.doorNote}: ${address.doorNote}',
              style: AppTypography.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Teklif özeti: döküm. Usta için hizmet bedeli ve net kazanç da görünür.
class OfferSummaryCard extends StatelessWidget {
  const OfferSummaryCard({super.key, required this.job});

  final JobDetail job;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final o = job.offer;
    String m(Money v) => formatMoney(v, l.localeName);
    final pro = job.viewerRole == PartyRole.pro;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.offerSummaryTitle, style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          InfoRow(l.labor, m(o.laborAmount)),
          InfoRow(l.materials, m(o.materialsAmount)),
          const Divider(),
          InfoRow(l.totalVatIncluded, m(o.totalAmount), bold: true),
          if (pro && o.serviceFee != null)
            InfoRow(l.serviceFeeLabel, m(o.serviceFee!)),
          if (pro && o.netEarning != null)
            InfoRow(l.netEarningLabel, m(o.netEarning!)),
          InfoRow(l.warranty, warrantyText(l, o.warrantyMonths)),
        ],
      ),
    );
  }
}

/// Ödeme özeti: güvence havuzunun durumu ve tutarlar.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.job});

  final JobDetail job;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = job.payment;
    String m(Money v) => formatMoney(v, l.localeName);
    final pro = job.viewerRole == PartyRole.pro;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.paymentSummaryTitle, style: AppTypography.cardTitle),
          const SizedBox(height: 4),
          InfoRow(
            l.paymentStatusLabel,
            escrowLabel(l, p.status, job.viewerRole),
          ),
          InfoRow(l.totalVatIncluded, m(p.totalAmount), bold: true),
          if (p.refundedAmount.isPositive)
            InfoRow(l.refundedLabel, m(p.refundedAmount)),
          if (pro && p.serviceFee != null)
            InfoRow(l.serviceFeeLabel, m(p.serviceFee!)),
          if (pro && p.netEarning != null)
            InfoRow(l.netEarningLabel, m(p.netEarning!)),
          const SizedBox(height: 4),
          Text(
            pro ? l.escrowExplainPro : l.escrowExplain,
            style: AppTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}

/// İş kartı (liste ve ana sayfa).
class JobCard extends ConsumerWidget {
  const JobCard({super.key, required this.job, required this.onTap});

  final JobSummary job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(job.title, style: AppTypography.cardTitle)),
              if (job.unreadMessages > 0)
                Semantics(
                  label: l.unreadMessages(job.unreadMessages),
                  child: Badge(label: Text('${job.unreadMessages}')),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${job.counterpart.displayName} · ${job.publicCode}',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.xs),
          jobStatusChip(l, job.status, job.viewerRole),
          if (job.scheduledFrom != null && job.scheduledTo != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              formatWindow(l, job.scheduledFrom!, job.scheduledTo!, now),
              style: AppTypography.label,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            formatMoney(job.totalAmount, l.localeName),
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

/// Amaca göre yükleyen fotoğraf kümesi.
PhotoSet newPhotoSet(WidgetRef ref, MediaPurpose purpose, int max) => PhotoSet(
  api: ref.read(apiClientProvider).media,
  picker: ref.read(photoPickerProvider),
  recompress: ref.read(recompressProvider),
  purpose: purpose,
  max: max,
);

/// Sohbet girişi: okunmamış sayısıyla birlikte sohbeti açar.
class ChatEntryCard extends StatelessWidget {
  const ChatEntryCard({super.key, required this.job, required this.onReturn});

  final JobDetail job;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppCard(
      onTap: () async {
        await context.push('/jobs/${job.id}/chat');
        onReturn();
      },
      semanticLabel: l.chatOpen,
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.chatEntryTitle, style: AppTypography.cardTitle),
                Text(
                  job.counterpart.displayName,
                  style: AppTypography.bodySecondary,
                ),
              ],
            ),
          ),
          if (job.unreadMessages > 0)
            Semantics(
              label: l.unreadMessages(job.unreadMessages),
              child: Badge(label: Text('${job.unreadMessages}')),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
