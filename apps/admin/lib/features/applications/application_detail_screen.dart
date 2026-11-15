import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/data.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/action_dialog.dart';
import '../common/labels.dart';
import '../common/media_viewer.dart';
import '../common/widgets.dart';
import 'applications_screen.dart' show categoryNames;

/// Başvuru detayı: kişi ve işletme, belgeler, geçmiş ve karar eylemleri.
class ApplicationDetailScreen extends ConsumerStatefulWidget {
  const ApplicationDetailScreen({super.key, required this.proId});

  final String proId;

  @override
  ConsumerState<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState
    extends ConsumerState<ApplicationDetailScreen> {
  bool _busy = false;

  AdminApi get _api => ref.read(apiClientProvider).admin;

  void _reload() => ref.invalidate(applicationProvider(widget.proId));

  /// Eylem bitince: başarıda yeniler, eski durumda yenileyip açıklama gösterir.
  Future<void> _run(
    Future<DialogOutcome?> Function() action,
    String doneText,
  ) async {
    if (_busy) return;
    final outcome = await action();
    if (!mounted) return;
    switch (outcome) {
      case DialogOutcome.done:
        _reload();
        showNotice(context, doneText);
      case DialogOutcome.stale:
        _reload();
        showNotice(context, AppLocalizations.of(context).staleNotice);
      case null:
        break;
    }
  }

  /// İstek sürerken sayfadaki eylem düğmeleri kilitlenir.
  Future<T> _track<T>(Future<T> Function() call) async {
    setState(() => _busy = true);
    try {
      return await call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _approve(AdminApplicationDetail d) {
    final l = AppLocalizations.of(context);
    // Not isteğe bağlı (`{note?}`); yazılırsa başvuru geçmişine kaydedilir.
    return _run(
      () => showActionDialog(
        context,
        title: l.approveTitle,
        intro: l.approveMessage(d.businessName),
        noteLabel: l.approveNoteLabel,
        minLength: 0,
        maxLength: 1000,
        confirmLabel: l.approve,
        onSubmit: (note) => _track(
          () => _api.approve(d.proId, note: note.isEmpty ? null : note),
        ),
      ),
      l.approvedNotice,
    );
  }

  Future<void> _reject(AdminApplicationDetail d) {
    final l = AppLocalizations.of(context);
    return _run(
      () => showActionDialog(
        context,
        title: l.rejectTitle,
        intro: l.rejectMessage,
        noteLabel: l.rejectNoteLabel,
        minLength: 10,
        maxLength: 1000,
        confirmLabel: l.reject,
        destructive: true,
        onSubmit: (note) => _track(() => _api.reject(d.proId, note)),
      ),
      l.rejectedNotice,
    );
  }

  Future<void> _requestDocuments(AdminApplicationDetail d) {
    final l = AppLocalizations.of(context);
    final selected = <ProDocumentType>{};
    // Sunucu başvuruda olmayan türü 400 VALIDATION_FAILED ile reddeder; yalnız
    // başvurudaki belge türleri sunulur (belge yoksa hepsi).
    final present = {for (final doc in d.documents) doc.type};
    final types = [
      for (final t in ProDocumentType.values)
        if (present.isEmpty || present.contains(t)) t,
    ];
    return _run(
      () => showActionDialog(
        context,
        title: l.requestDocsTitle,
        intro: l.requestDocsMessage,
        noteLabel: l.requestDocsNoteLabel,
        minLength: 10,
        maxLength: 1000,
        confirmLabel: l.requestDocs,
        extraValid: () => selected.isNotEmpty,
        extraInvalidText: l.requestDocsPickOne,
        extraBuilder: (ctx, rebuild) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.requestDocsTypes, style: AppTypography.label),
            for (final t in types)
              CheckboxListTile(
                key: Key('doc-type-${t.name}'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(docTypeLabel(l, t)),
                value: selected.contains(t),
                onChanged: (v) {
                  v == true ? selected.add(t) : selected.remove(t);
                  rebuild();
                },
              ),
          ],
        ),
        onSubmit: (note) => _track(
          () => _api.requestDocuments(
            d.proId,
            note: note,
            documentTypes: selected.toList(),
          ),
        ),
      ),
      l.requestDocsDoneNotice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final value = ref.watch(applicationProvider(widget.proId));
    final detail = value.asData?.value;
    return PageScroll(
      title: detail?.businessName ?? l.applicationDetailTitle,
      subtitle: detail?.fullName,
      leading: AppIconButton(
        icon: Icons.arrow_back,
        tooltip: l.back,
        onPressed: () => context.go(Routes.applications),
      ),
      children: [
        AsyncBody(
          value: value,
          onRetry: _reload,
          data: (d) => LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final main = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PersonCard(detail: d),
                  const SizedBox(height: AppSpacing.md),
                  _DocumentsCard(detail: d),
                ],
              );
              final side = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DecisionCard(
                    detail: d,
                    busy: _busy,
                    onApprove: () => _approve(d),
                    onReject: () => _reject(d),
                    onRequestDocs: () => _requestDocuments(d),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _HistoryCard(detail: d),
                ],
              );
              if (!wide) {
                return Column(
                  children: [
                    side,
                    const SizedBox(height: AppSpacing.md),
                    main,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: main),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: side),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PersonCard extends ConsumerWidget {
  const _PersonCard({required this.detail});

  final AdminApplicationDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(categoriesProvider);
    final now = ref.watch(nowProvider)();
    return SectionCard(
      title: l.personAndBusiness,
      trailing: reviewStatusChip(l, detail.reviewStatus),
      child: Column(
        children: [
          InfoRow(label: l.fullName, value: Text(detail.fullName)),
          InfoRow(label: l.email, value: SelectableText(detail.email)),
          InfoRow(label: l.phone, value: Text(detail.phone ?? '-')),
          InfoRow(label: l.businessName, value: Text(detail.businessName)),
          InfoRow(
            label: l.experience,
            value: Text(l.yearsCount(detail.experienceYears)),
          ),
          InfoRow(
            label: l.colCategories,
            value: Text(
              categoryNames(catalog, detail.categoryIds, l.localeName),
            ),
          ),
          InfoRow(
            label: l.colDistricts,
            value: Text(detail.districtNames.join(', ')),
          ),
          InfoRow(
            label: l.bio,
            value: Text(detail.bio.isEmpty ? '-' : detail.bio),
          ),
          InfoRow(
            label: l.colSubmitted,
            value: Text(
              detail.submittedAt == null
                  ? '-'
                  : formatDateTime(detail.submittedAt!, l.localeName, now),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends ConsumerWidget {
  const _DocumentsCard({required this.detail});

  final AdminApplicationDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      title: l.documentsTitle,
      child: detail.documents.isEmpty
          ? Text(l.documentsEmpty, style: AppTypography.bodySecondary)
          : Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final doc in detail.documents)
                  SizedBox(width: 220, child: _DocumentTile(doc: doc)),
              ],
            ),
    );
  }
}

class _DocumentTile extends ConsumerWidget {
  const _DocumentTile({required this.doc});

  final ApplicationDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Container(
      key: Key('document-${doc.id}'),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(docTypeLabel(l, doc.type), style: AppTypography.cardTitle),
          const SizedBox(height: 6),
          docStatusChip(l, doc.status),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            key: Key('document-open-${doc.id}'),
            onTap: () =>
                showMediaViewer(context, doc.media, docTypeLabel(l, doc.type)),
            child: MediaThumbnail(media: doc.media, height: 120),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => ref.read(urlOpenerProvider)(doc.media.url),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l.openInNewTab),
          ),
        ],
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.detail,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onRequestDocs,
  });

  final AdminApplicationDetail detail;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onRequestDocs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pending = detail.reviewStatus == ReviewStatus.pendingReview;
    return SectionCard(
      title: l.decisionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (detail.reviewNote != null && detail.reviewNote!.isNotEmpty) ...[
            Text(l.reviewNoteLabel, style: AppTypography.label),
            const SizedBox(height: 4),
            Text(detail.reviewNote!, style: AppTypography.bodySecondary),
            const SizedBox(height: AppSpacing.md),
          ],
          if (pending) ...[
            AppButton(
              key: const Key('approve'),
              label: l.approve,
              icon: Icons.check,
              isLoading: busy,
              onPressed: onApprove,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              key: const Key('request-docs'),
              label: l.requestDocs,
              icon: Icons.folder_open,
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onRequestDocs,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              key: const Key('reject'),
              label: l.reject,
              icon: Icons.close,
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onReject,
            ),
          ] else
            Text(l.noActionsForStatus, style: AppTypography.bodySecondary),
        ],
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.detail});

  final AdminApplicationDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    return SectionCard(
      title: l.historyTitle,
      child: detail.history.isEmpty
          ? Text(l.historyEmpty, style: AppTypography.bodySecondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in detail.history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${adminActionLabel(l, a.action)} · ${a.adminName}',
                          style: AppTypography.cardTitle,
                        ),
                        Text(
                          formatDateTime(a.createdAt, l.localeName, now),
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (a.note != null && a.note!.isNotEmpty)
                          Text(a.note!, style: AppTypography.bodySecondary),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
