import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../core/photos.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/pickers.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../customer/pro_profile_screens.dart' show documentLabel;

/// Başvuruda zorunlu belgeler.
const Set<ProDocumentType> kRequiredDocs = {
  ProDocumentType.identity,
  ProDocumentType.tradeCert,
};

/// Eksik zorunlu belge türleri (yüklenmiş belge kimliği olmayanlar).
List<ProDocumentType> missingRequiredDocs(
  Map<ProDocumentType, PhotoSet> sets,
) => [
  for (final t in kRequiredDocs)
    if ((sets[t]?.mediaIds ?? const []).isEmpty) t,
];

/// `/p/apply`: usta başvurusu. NEEDS_DOCUMENTS / REJECTED ise dolu açılır.
class ProApplyScreen extends ConsumerStatefulWidget {
  const ProApplyScreen({super.key});

  @override
  ConsumerState<ProApplyScreen> createState() => _ProApplyState();
}

class _ProApplyState extends ConsumerState<ProApplyScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _years = TextEditingController(text: '0');
  Set<String> _cats = {};
  Set<String> _districts = {};
  late final Map<ProDocumentType, PhotoSet> _docs;
  bool _attempted = false;
  bool _submitting = false;
  bool _prefilled = false;
  String? _banner;

  @override
  void initState() {
    super.initState();
    _docs = {
      for (final t in ProDocumentType.values)
        t: PhotoSet(
          api: ref.read(apiClientProvider).media,
          picker: ref.read(photoPickerProvider),
          recompress: ref.read(recompressProvider),
          purpose: MediaPurpose.proDocument,
          max: 1,
        ),
    };
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _years.dispose();
    for (final s in _docs.values) {
      s.dispose();
    }
    super.dispose();
  }

  void _prefill(ProApplication? a) {
    if (_prefilled || a == null) return;
    _prefilled = true;
    if (a.reviewStatus != ReviewStatus.needsDocuments &&
        a.reviewStatus != ReviewStatus.rejected) {
      return;
    }
    _name.text = a.businessName;
    _bio.text = a.bio;
    _years.text = '${a.experienceYears}';
    _cats = {...a.categoryIds};
    _districts = {...a.districtIds};
    for (final d in a.documents) {
      // Reddedilen belge yeniden yüklenmeli; diğerleri korunur.
      if (d.status != DocumentStatus.rejected) {
        _docs[d.type]!.addRemote([d.media]);
      }
    }
  }

  int? get _yearsValue => int.tryParse(_years.text.trim());

  bool get _valid {
    final n = _name.text.trim().length;
    final y = _yearsValue;
    return n >= 2 &&
        n <= 100 &&
        _bio.text.length <= 1000 &&
        y != null &&
        y >= 0 &&
        y <= 60 &&
        _cats.isNotEmpty &&
        _districts.isNotEmpty &&
        missingRequiredDocs(_docs).isEmpty &&
        !_docs.values.any((s) => s.isBusy);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _attempted = true;
      _banner = null;
    });
    if (!_valid) return;
    setState(() => _submitting = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(apiClientProvider)
          .pro
          .submitApplication(
            ApplicationInput(
              businessName: _name.text.trim(),
              bio: _bio.text.trim(),
              experienceYears: _yearsValue!,
              categoryIds: _cats.toList(),
              districtIds: _districts.toList(),
              documents: [
                for (final e in _docs.entries)
                  if (e.value.mediaIds.isNotEmpty)
                    DocumentInput(type: e.key, mediaId: e.value.mediaIds.first),
              ],
            ),
          );
      invalidateProData(ref);
      await ref.read(sessionProvider.notifier).refreshMe();
      // Başvuru gönderilince form yığından çıkar (NAVIGATION_RULES §1).
      router.go('/c/profile');
      router.push('/p/application');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _banner = apiErrorMessage(l, e.code));
      if (e.code == ApiErrorCode.illegalState) {
        invalidateProData(ref);
        await ref.read(sessionProvider.notifier).refreshMe();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = ref.watch(proApplicationProvider);
    final pro = ref.watch(sessionProvider.select((s) => s.me?.pro));
    // Başvuru varsa (yeniden gönderim) alanlar dolu açılır.
    if (pro != null) {
      if (app.isLoading && !app.hasValue) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: const AppBackButton(fallback: '/p/application'),
            title: Text(l.proApplyTitle),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      _prefill(app.value);
    }
    final v = Validators(l);
    final y = _yearsValue;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const AppBackButton(fallback: '/c/profile'),
        title: Text(l.proApplyTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.applyIntro, style: AppTypography.bodySecondary),
                  const FieldGap(),
                  AppTextField(
                    label: l.applyBusinessName,
                    controller: _name,
                    enabled: !_submitting,
                    maxLength: 100,
                    textInputAction: TextInputAction.next,
                    errorText: _attempted && _name.text.trim().length < 2
                        ? l.applyBusinessNameInvalid
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const FieldGap(),
                  AppTextField(
                    label: l.applyAbout,
                    controller: _bio,
                    enabled: !_submitting,
                    maxLength: 1000,
                    keyboardType: TextInputType.multiline,
                  ),
                  const FieldGap(),
                  AppTextField(
                    label: l.applyExperience,
                    controller: _years,
                    enabled: !_submitting,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    errorText: _attempted && (y == null || y > 60)
                        ? l.applyExperienceInvalid
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const FieldGap(),
                  CategoryMultiPicker(
                    label: l.applyCategories,
                    selected: _cats,
                    errorText: _attempted && _cats.isEmpty
                        ? v.required('')
                        : null,
                    onChanged: (s) => setState(() => _cats = s),
                  ),
                  const FieldGap(),
                  DistrictPicker(
                    label: l.applyDistricts,
                    multi: true,
                    selected: _districts,
                    errorText: _attempted && _districts.isEmpty
                        ? v.required('')
                        : null,
                    onChanged: (s) => setState(() => _districts = s),
                  ),
                  const FieldGap(big: true),
                  Text(l.applyDocuments, style: AppTypography.section),
                  const SizedBox(height: 4),
                  Text(
                    l.applyDocumentsHelp,
                    style: AppTypography.bodySecondary,
                  ),
                  for (final t in ProDocumentType.values) ...[
                    const FieldGap(),
                    Text(
                      kRequiredDocs.contains(t)
                          ? l.docRequired(documentLabel(l, t))
                          : l.docOptional(documentLabel(l, t)),
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    PhotoSetView(set: _docs[t]!, enabled: !_submitting),
                    if (_attempted &&
                        kRequiredDocs.contains(t) &&
                        _docs[t]!.mediaIds.isEmpty)
                      ListenableBuilder(
                        listenable: _docs[t]!,
                        builder: (_, _) => _docs[t]!.mediaIds.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  l.docMissing(documentLabel(l, t)),
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                  if (_banner != null) ...[
                    const FieldGap(),
                    MessageBanner(_banner!),
                  ],
                  const FieldGap(big: true),
                  AppButton(
                    label: l.applySubmit,
                    isLoading: _submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `/p/application`: başvuru durumu.
class ProApplicationScreen extends ConsumerWidget {
  const ProApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(proApplicationProvider);
    final status = ref.watch(
      sessionProvider.select((s) => s.me?.pro?.reviewStatus),
    );
    Future<void> refresh() async {
      ref.invalidate(proApplicationProvider);
      await ref.read(sessionProvider.notifier).refreshMe();
    }

    (String, IconData, StatusTone) chip(ReviewStatus s) => switch (s) {
      ReviewStatus.pendingReview => (
        l.statusPendingReview,
        Icons.hourglass_top,
        StatusTone.urgent,
      ),
      ReviewStatus.needsDocuments => (
        l.statusNeedsDocuments,
        Icons.upload_file,
        StatusTone.urgent,
      ),
      ReviewStatus.rejected => (
        l.statusRejected,
        Icons.cancel_outlined,
        StatusTone.error,
      ),
      ReviewStatus.suspended => (
        l.statusSuspended,
        Icons.block,
        StatusTone.error,
      ),
      ReviewStatus.approved => (
        l.statusApproved,
        Icons.verified_outlined,
        StatusTone.success,
      ),
    };

    return ListPage(
      title: l.proApplicationTitle,
      leading: const AppBackButton(fallback: '/c/profile'),
      body: AsyncView<ProApplication?>(
        value: async,
        onRetry: () => ref.invalidate(proApplicationProvider),
        builder: (context, app) {
          final s = app?.reviewStatus ?? status;
          final c = s == null ? null : chip(s);
          final canResubmit =
              s == ReviewStatus.needsDocuments || s == ReviewStatus.rejected;
          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (c != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(label: c.$1, icon: c.$2, tone: c.$3),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(switch (s) {
                  ReviewStatus.pendingReview => l.applicationPendingBody,
                  ReviewStatus.needsDocuments => l.applicationNeedsBody,
                  ReviewStatus.rejected => l.applicationRejectedBody,
                  ReviewStatus.suspended => l.applicationSuspendedBody,
                  _ => l.applicationPendingBody,
                }, style: AppTypography.body),
                if ((app?.reviewNote ?? '').isNotEmpty) ...[
                  sectionTitle(l.adminNote),
                  AppCard(child: Text(app!.reviewNote!)),
                ],
                if (app != null && app.documents.isNotEmpty) ...[
                  sectionTitle(l.applyDocuments),
                  for (final d in app.documents)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Expanded(child: Text(documentLabel(l, d.type))),
                          StatusChip(
                            label: switch (d.status) {
                              DocumentStatus.pending => l.docStatusPending,
                              DocumentStatus.accepted => l.docStatusAccepted,
                              DocumentStatus.rejected => l.docStatusRejected,
                            },
                            icon: switch (d.status) {
                              DocumentStatus.pending => Icons.hourglass_top,
                              DocumentStatus.accepted => Icons.check,
                              DocumentStatus.rejected => Icons.close,
                            },
                            tone: switch (d.status) {
                              DocumentStatus.pending => StatusTone.urgent,
                              DocumentStatus.accepted => StatusTone.success,
                              DocumentStatus.rejected => StatusTone.error,
                            },
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (canResubmit)
                  AppButton(
                    label: l.applyResubmit,
                    onPressed: () => context.push('/p/apply'),
                  ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.backToCustomerMode,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go('/c/home'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
