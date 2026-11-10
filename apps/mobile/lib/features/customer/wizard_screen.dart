import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import 'addresses.dart';
import 'wizard_state.dart';

/// `/c/requests/new` (ve `/c/requests/:id/edit`): 4 adımlı sihirbaz, tek taslak.
class RequestWizardScreen extends ConsumerStatefulWidget {
  const RequestWizardScreen({super.key, this.editId});

  final String? editId;

  @override
  ConsumerState<RequestWizardScreen> createState() => _WizardState();
}

class _WizardState extends ConsumerState<RequestWizardScreen> {
  bool _loadingEdit = false;
  ApiException? _editError;
  String? _banner;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _textsSynced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final ctrl = ref.read(wizardProvider.notifier);
    if (widget.editId == null) {
      ctrl.enterNew();
      _syncTexts();
      // Metin alanları ilk kareden sonra doldu: sayaç ve doğrulama yeniden
      // çizilsin (yoksa geri yüklenen açıklama "0 karakter" görünür).
      if (mounted) setState(() {});
      return;
    }
    setState(() {
      _loadingEdit = true;
      _editError = null;
    });
    try {
      final d = await ref.read(requestProvider(widget.editId!).future);
      final addrs = await ref.read(addressesProvider.future);
      ctrl.startEdit(d, addrs);
      _syncTexts(force: true);
    } on ApiException catch (e) {
      _editError = e;
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  void _syncTexts({bool force = false}) {
    if (_textsSynced && !force) return;
    _textsSynced = true;
    final d = ref.read(wizardProvider).draft;
    _title.text = d.title;
    _desc.text = d.description;
  }

  List<String> _requiredKeys() {
    final cat = ref.read(wizardProvider).draft.categoryId;
    if (cat == null) return const [];
    final q = ref.read(questionsProvider(cat)).value;
    return [for (final x in q ?? const <Question>[]) x.key];
  }

  void _next() {
    final ctrl = ref.read(wizardProvider.notifier);
    ctrl.next(ref.read(nowProvider)(), _requiredKeys());
  }

  /// Sunucunun `field` adını kullanıcıya gösterilecek alan adına çevirir.
  String? _fieldLabel(AppLocalizations l, String? field) => switch (field) {
    'categoryId' => l.wizCategory,
    'urgency' => l.wizUrgency,
    'preferredFrom' || 'preferredTo' => l.wizDates,
    'addressId' => l.wizAddress,
    'answers' => l.requestAnswers,
    'title' => l.wizFieldTitle,
    'description' => l.wizFieldDescription,
    'photoIds' => l.requestPhotos,
    _ => null,
  };

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final st = ref.read(wizardProvider);
    if (st.submitting) return;
    setState(() => _banner = null);
    // Geri yüklenen taslakta tarih eskimiş ya da adım atlanmış olabilir.
    if (!ctrl.validateAll(ref.read(nowProvider)(), _requiredKeys())) return;
    final editing = st.isEditing;
    if (editing && st.editOfferCount > 0) {
      final ok = await showConfirmDialog(
        context,
        title: l.wizEditOffersTitle,
        message: l.wizEditOffersMessage(st.editOfferCount),
        confirmLabel: l.wizSaveChanges,
        cancelLabel: l.cancel,
      );
      if (!ok || !mounted) return;
    }
    final router = GoRouter.of(context);
    try {
      final d = await ctrl.submit();
      invalidateRequestData(ref);
      if (editing) {
        ctrl.finish();
        if (!mounted) return;
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/c/requests/${d.id}');
        }
      } else {
        ctrl.finish();
        // Yayından sonra form yığından çıkar (NAVIGATION_RULES §1).
        router.go('/c/requests');
        router.push('/c/requests/${d.id}/published');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      final step = e.code == ApiErrorCode.validationFailed
          ? WizardController.stepForField(e.field)
          : null;
      final label = _fieldLabel(l, e.field);
      if (step != null && label != null) {
        ctrl.showServerFieldStep(step);
        setState(() => _banner = l.wizErrServerField(label));
      } else {
        setState(() => _banner = apiErrorMessage(l, e.code));
      }
      if (isStaleStateError(e)) invalidateRequestData(ref);
    }
  }

  void _onBack() {
    final ctrl = ref.read(wizardProvider.notifier);
    if (!ctrl.back()) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/c/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = ref.watch(wizardProvider);
    final title = st.isEditing ? l.wizEditTitle : l.wizTitle;
    if (_loadingEdit || _editError != null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: const AppBackButton(fallback: '/c/requests'),
          title: Text(title),
        ),
        body: _editError != null
            ? ErrorState(
                title: l.genericErrorTitle,
                message: apiErrorMessage(l, _editError!.code),
                retryLabel: l.retry,
                onRetry: _init,
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
    final last = st.step == 4;
    final primary = last
        ? (st.isEditing ? l.wizSaveChanges : l.wizPublish)
        : (st.fromReview ? l.wizBackToReview : l.wizContinue);
    return PopScope(
      canPop: st.step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(wizardProvider.notifier).back();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: AppBackButton(onBack: _onBack),
          title: Text(title),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        l.wizStepOf(st.step, 4),
                        style: AppTypography.label,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: st.step / 4),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: switch (st.step) {
                        1 => _Step1(state: st),
                        2 => _Step2(state: st),
                        3 => _Step3(state: st, title: _title, desc: _desc),
                        _ => _Step4(state: st),
                      },
                    ),
                  ),
                ),
              ),
              if (_banner != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: MessageBanner(_banner!),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: primary,
                  isLoading: st.submitting,
                  onPressed: last ? _submit : _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _issueText(AppLocalizations l, WizardIssue i) => switch (i) {
  WizardIssue.category => l.wizErrCategory,
  WizardIssue.dateFrom => l.wizErrDateFrom,
  WizardIssue.dateTo => l.wizErrDateTo,
  WizardIssue.dateOrder => l.wizErrDateOrder,
  WizardIssue.datePast => l.wizErrDatePast,
  WizardIssue.dateRange => l.wizErrDateRange,
  WizardIssue.address => l.wizErrAddress,
  WizardIssue.answers => l.wizErrAnswers,
  WizardIssue.title => l.wizErrTitle(kTitleMin, kTitleMax),
  WizardIssue.description => l.wizErrDescription(kDescMin),
  WizardIssue.photosBusy => l.wizErrPhotosBusy,
  WizardIssue.photosFailed => l.wizErrPhotosFailed,
};

class _Issues extends ConsumerWidget {
  const _Issues(this.state, this.only);

  final WizardState state;
  final Set<WizardIssue> only;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.attempted) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final cat = state.draft.categoryId;
    final keys = cat == null
        ? const <String>[]
        : [
            for (final q
                in ref.watch(questionsProvider(cat)).value ??
                    const <Question>[])
              q.key,
          ];
    final bad = ctrl
        .issues(state.step, ref.read(nowProvider)(), keys)
        .where(only.contains);
    if (bad.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final i in bad)
              Text(
                _issueText(l, i),
                style: AppTypography.label.copyWith(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Adım 1 -----------------------------------------------------------------

class _Step1 extends ConsumerWidget {
  const _Step1({required this.state});

  final WizardState state;

  Future<DateTime?> _pick(
    BuildContext context,
    DateTime now,
    DateTime? initial,
  ) async {
    final first = DateTime(now.year, now.month, now.day);
    final last = now.add(const Duration(days: 30));
    // Geri yüklenen taslaktaki tarih aralık dışında kalmış olabilir; seçici
    // aralık dışı başlangıç tarihini kabul etmez.
    var start = (initial ?? now.add(const Duration(days: 1))).toLocal();
    if (start.isBefore(first)) start = first;
    if (start.isAfter(last)) start = last;
    final date = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: first,
      lastDate: last,
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime((initial ?? now).toLocal()),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final d = state.draft;
    final cats = ref.watch(categoriesProvider);
    final now = ref.read(nowProvider)();
    String fmt(DateTime? v) =>
        v == null ? l.pickerNone : formatDayTime(l, v.toUtc(), now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.wizStep1Title, style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.md),
        Text(l.wizCategory, style: AppTypography.cardTitle),
        const SizedBox(height: AppSpacing.xs),
        cats.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ErrorState(
            title: l.genericErrorTitle,
            retryLabel: l.retry,
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (list) => Column(
            children: [
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ChoiceCard(
                    title: l.localeName == 'en' ? c.nameEn : c.nameTr,
                    leading: categoryIcon(c.icon.isEmpty ? c.id : c.icon),
                    selected: d.categoryId == c.id,
                    onTap: () => ctrl.update(
                      (x) => x.categoryId == c.id
                          ? x
                          : x.copyWith(categoryId: c.id, answers: const {}),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Issues(state, const {WizardIssue.category}),
        const FieldGap(),
        Text(l.wizUrgency, style: AppTypography.cardTitle),
        const SizedBox(height: AppSpacing.xs),
        ChoiceCard(
          title: l.urgencyUrgent,
          subtitle: l.wizUrgentHint,
          leading: Icons.bolt,
          selected: d.urgency == RequestUrgency.urgent,
          onTap: () => ctrl.update(
            (x) => x.copyWith(urgency: RequestUrgency.urgent, clearDates: true),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ChoiceCard(
          title: l.urgencyPlanned,
          subtitle: l.wizPlannedHint,
          leading: Icons.event_outlined,
          selected: d.urgency == RequestUrgency.planned,
          onTap: () =>
              ctrl.update((x) => x.copyWith(urgency: RequestUrgency.planned)),
        ),
        if (d.urgency == RequestUrgency.planned) ...[
          const FieldGap(),
          PickerFieldButton(
            label: l.wizDateFrom,
            value: fmt(d.preferredFrom),
            onTap: () async {
              final v = await _pick(context, now, d.preferredFrom);
              if (v != null) ctrl.update((x) => x.copyWith(preferredFrom: v));
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          PickerFieldButton(
            label: l.wizDateTo,
            value: fmt(d.preferredTo),
            onTap: () async {
              final v = await _pick(
                context,
                now,
                d.preferredTo ?? d.preferredFrom,
              );
              if (v != null) ctrl.update((x) => x.copyWith(preferredTo: v));
            },
          ),
          _Issues(state, const {
            WizardIssue.dateFrom,
            WizardIssue.dateTo,
            WizardIssue.dateOrder,
            WizardIssue.datePast,
            WizardIssue.dateRange,
          }),
        ],
      ],
    );
  }
}

/// Etiketli, 48 px dokunma alanlı değer düğmesi.
class PickerFieldButton extends StatelessWidget {
  const PickerFieldButton({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      onTap: onTap,
      child: OutlinedButton(
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.label)),
            Flexible(child: Text(value, textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}

// --- Adım 2 -----------------------------------------------------------------

class _Step2 extends ConsumerStatefulWidget {
  const _Step2({required this.state});

  final WizardState state;

  @override
  ConsumerState<_Step2> createState() => _Step2State();
}

class _Step2State extends ConsumerState<_Step2> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final st = widget.state;
    final d = st.draft;
    final addrs = ref.watch(addressesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.wizStep2Title, style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.md),
        Text(l.wizAddress, style: AppTypography.cardTitle),
        const SizedBox(height: AppSpacing.xs),
        addrs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            title: l.genericErrorTitle,
            message: e is ApiException ? apiErrorMessage(l, e.code) : null,
            retryLabel: l.retry,
            onRetry: () => ref.invalidate(addressesProvider),
          ),
          data: (list) {
            if (list.isEmpty || _adding) {
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.wizAddAddress, style: AppTypography.cardTitle),
                    const SizedBox(height: AppSpacing.sm),
                    AddressForm(
                      forceDefault: list.isEmpty,
                      onSaved: (a) {
                        ctrl.update((x) => x.copyWith(addressId: a.id));
                        setState(() => _adding = false);
                      },
                      onCancel: list.isEmpty
                          ? null
                          : () => setState(() => _adding = false),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (final a in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: ChoiceCard(
                      title: a.label,
                      subtitle: '${a.districtName}, ${a.neighborhood}',
                      leading: Icons.place_outlined,
                      selected: d.addressId == a.id,
                      onTap: () =>
                          ctrl.update((x) => x.copyWith(addressId: a.id)),
                    ),
                  ),
                AppButton(
                  label: l.wizAddAddress,
                  icon: Icons.add,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => setState(() => _adding = true),
                ),
              ],
            );
          },
        ),
        _Issues(st, const {WizardIssue.address}),
        if (d.categoryId != null) _Questions(state: st),
      ],
    );
  }
}

class _Questions extends ConsumerWidget {
  const _Questions({required this.state});

  final WizardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final cat = state.draft.categoryId!;
    final qs = ref.watch(questionsProvider(cat));
    return qs.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => ErrorState(
        title: l.genericErrorTitle,
        message: e is ApiException ? apiErrorMessage(l, e.code) : null,
        retryLabel: l.retry,
        onRetry: () => ref.invalidate(questionsProvider(cat)),
      ),
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final q in list) ...[
            const FieldGap(),
            Text(
              l.localeName == 'en' ? q.labelEn : q.labelTr,
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final o in q.options)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: ChoiceCard(
                  title: l.localeName == 'en' ? o.labelEn : o.labelTr,
                  selected: state.draft.answers[q.key] == o.value,
                  onTap: () => ctrl.update(
                    (x) => x.copyWith(answers: {...x.answers, q.key: o.value}),
                  ),
                ),
              ),
          ],
          _Issues(state, const {WizardIssue.answers}),
        ],
      ),
    );
  }
}

// --- Adım 3 -----------------------------------------------------------------

class _Step3 extends ConsumerWidget {
  const _Step3({required this.state, required this.title, required this.desc});

  final WizardState state;
  final TextEditingController title;
  final TextEditingController desc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final photos = ctrl.photos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.wizStep3Title, style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.md),
        Text(
          l.wizPhotos(kMaxRequestPhotosLabel),
          style: AppTypography.cardTitle,
        ),
        const SizedBox(height: 4),
        Text(l.wizPhotosHint, style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.xs),
        PhotoSetView(set: photos, enabled: !state.submitting),
        ListenableBuilder(
          listenable: photos,
          builder: (_, _) => _Issues(state, const {
            WizardIssue.photosBusy,
            WizardIssue.photosFailed,
          }),
        ),
        const FieldGap(),
        AppTextField(
          label: l.wizFieldTitle,
          hintText: l.wizFieldTitleHint,
          controller: title,
          maxLength: kTitleMax,
          textInputAction: TextInputAction.next,
          onChanged: (v) => ctrl.update((x) => x.copyWith(title: v)),
        ),
        _Issues(state, const {WizardIssue.title}),
        const FieldGap(),
        AppTextField(
          label: l.wizFieldDescription,
          hintText: l.wizFieldDescriptionHint,
          controller: desc,
          maxLength: kDescMax,
          keyboardType: TextInputType.multiline,
          minLines: 3,
          helperText: l.wizDescriptionCount(desc.text.trim().length, kDescMin),
          onChanged: (v) => ctrl.update((x) => x.copyWith(description: v)),
        ),
        _Issues(state, const {WizardIssue.description}),
      ],
    );
  }
}

const int kMaxRequestPhotosLabel = 5;

// --- Adım 4 -----------------------------------------------------------------

class _Step4 extends ConsumerWidget {
  const _Step4({required this.state});

  final WizardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ctrl = ref.read(wizardProvider.notifier);
    final d = state.draft;
    final cats = ref.watch(categoriesProvider).value;
    final addrs = ref.watch(addressesProvider).value;
    final qs = d.categoryId == null
        ? null
        : ref.watch(questionsProvider(d.categoryId!)).value;
    final now = ref.read(nowProvider)();
    Address? addr;
    for (final a in addrs ?? const <Address>[]) {
      if (a.id == d.addressId) addr = a;
    }
    String answerLabel(Question q, String v) {
      for (final o in q.options) {
        if (o.value == v) return l.localeName == 'en' ? o.labelEn : o.labelTr;
      }
      return v;
    }

    Widget section(String title, int step, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.cardTitle)),
                AppButton(
                  label: l.edit,
                  expand: false,
                  variant: AppButtonVariant.tertiary,
                  onPressed: () => ctrl.goTo(step, fromReview: true),
                ),
              ],
            ),
            ...rows,
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.wizStep4Title, style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.md),
        section(l.wizStep1Title, 1, [
          InfoRow(
            l.wizCategory,
            categoryNameOf(cats, d.categoryId ?? '', l.localeName),
          ),
          InfoRow(
            l.wizUrgency,
            d.urgency == RequestUrgency.urgent
                ? l.urgencyUrgent
                : l.urgencyPlanned,
          ),
          if (d.urgency == RequestUrgency.planned &&
              d.preferredFrom != null &&
              d.preferredTo != null)
            InfoRow(
              l.wizDates,
              formatWindow(
                l,
                d.preferredFrom!.toUtc(),
                d.preferredTo!.toUtc(),
                now,
              ),
            ),
        ]),
        section(l.wizStep2Title, 2, [
          InfoRow(
            l.wizAddress,
            addr == null
                ? ''
                : '${addr.label}, ${addr.districtName}, ${addr.neighborhood}',
          ),
          for (final q in qs ?? const <Question>[])
            InfoRow(
              l.localeName == 'en' ? q.labelEn : q.labelTr,
              answerLabel(q, d.answers[q.key] ?? ''),
            ),
        ]),
        section(l.wizStep3Title, 3, [
          InfoRow(l.wizFieldTitle, d.title.trim()),
          InfoRow(l.wizFieldDescription, d.description.trim()),
          InfoRow(l.wizPhotosCount, '${ctrl.photos.mediaIds.length}'),
        ]),
        Text(l.wizReviewNote, style: AppTypography.bodySecondary),
      ],
    );
  }
}
