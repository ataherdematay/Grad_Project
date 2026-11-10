import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/formatters.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../customer/offers_screens.dart' show warrantyText;
import 'offer_logic.dart';

/// `/p/requests/:id`: talep detayı (maskeli konum).
class ProRequestScreen extends ConsumerWidget {
  const ProRequestScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(proRequestProvider(id));
    return ListPage(
      title: l.requestDetailTitle,
      leading: const AppBackButton(fallback: '/p/feed'),
      body: AsyncView<ProRequestDetail>(
        value: async,
        onRetry: () => ref.invalidate(proRequestProvider(id)),
        builder: (context, r) {
          final cats = ref.watch(categoriesProvider).value;
          final qs = ref.watch(questionsProvider(r.categoryId)).value;
          final now = ref.read(nowProvider)();
          final mine = r.myOffer;
          final hasPending = mine != null && mine.status == OfferStatus.pending;
          String answerText(RequestAnswer a) {
            for (final q in qs ?? const <Question>[]) {
              if (q.key != a.questionKey) continue;
              var v = a.answer;
              for (final o in q.options) {
                if (o.value == a.answer) {
                  v = l.localeName == 'en' ? o.labelEn : o.labelTr;
                }
              }
              return '${l.localeName == 'en' ? q.labelEn : q.labelTr}: $v';
            }
            return '${a.questionKey}: ${a.answer}';
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(proRequestProvider(id).future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(r.title, style: AppTypography.screenTitle),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    urgencyChip(l, r.urgency),
                    if (hasPending)
                      StatusChip(
                        label: l.feedMyOffer,
                        icon: Icons.check_circle_outline,
                        tone: StatusTone.success,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                InfoRow(
                  l.wizCategory,
                  categoryNameOf(cats, r.categoryId, l.localeName),
                ),
                if (r.preferredFrom != null && r.preferredTo != null)
                  InfoRow(
                    l.wizDates,
                    formatWindow(l, r.preferredFrom!, r.preferredTo!, now),
                  ),
                InfoRow(
                  l.requestLocation,
                  '${r.districtName}, ${r.neighborhood}',
                ),
                Text(l.locationMasked, style: AppTypography.label),
                sectionTitle(l.wizFieldDescription),
                Text(r.description, style: AppTypography.body),
                if (r.answers.isNotEmpty) ...[
                  sectionTitle(l.requestAnswers),
                  for (final a in r.answers)
                    Text(answerText(a), style: AppTypography.body),
                ],
                if (r.photos.isNotEmpty) ...[
                  sectionTitle(l.requestPhotos),
                  PhotoStrip(photos: r.photos),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (hasPending)
                  AppButton(
                    label: l.viewMyOffer,
                    onPressed: () async {
                      await context.push('/p/offers/${mine.id}/sent');
                      ref.invalidate(proRequestProvider(id));
                    },
                  )
                else
                  AppButton(
                    label: l.prepareOffer,
                    onPressed: () async {
                      await context.push('/p/requests/${r.id}/offer');
                      ref.invalidate(proRequestProvider(id));
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MaterialDraft {
  _MaterialDraft(this.description, this.quantity, this.unitPrice);

  String description;
  int quantity;
  Money unitPrice;

  OfferLine get line => OfferLine(
    description: description,
    quantity: quantity,
    unitPrice: unitPrice,
  );
}

/// `/p/requests/:id/offer`: teklif formu.
class OfferFormScreen extends ConsumerStatefulWidget {
  const OfferFormScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<OfferFormScreen> createState() => _OfferFormState();
}

class _OfferFormState extends ConsumerState<OfferFormScreen> {
  final _labor = TextEditingController();
  final _note = TextEditingController();
  final List<_MaterialDraft> _materials = [];
  DateTime? _day;
  TimeOfDay? _time;
  int _hours = 2;
  int _warranty = 0;
  bool _attempted = false;
  bool _submitting = false;
  String? _banner;

  /// Sunucunun `VALIDATION_FAILED` ile döndürdüğü alan; ilgili bölümün
  /// altında gösterilir, form değişince temizlenir.
  String? _serverField;
  String _key = newIdempotencyKey();

  @override
  void dispose() {
    _labor.dispose();
    _note.dispose();
    super.dispose();
  }

  void _touch() {
    _key = newIdempotencyKey();
    if (_serverField != null) setState(() => _serverField = null);
  }

  Widget _fieldError(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: AppTypography.label.copyWith(color: AppColors.error),
    ),
  );

  DateTime? get _from => (_day == null || _time == null)
      ? null
      : DateTime(
          _day!.year,
          _day!.month,
          _day!.day,
          _time!.hour,
          _time!.minute,
        );

  DateTime? get _to => _from?.add(Duration(hours: _hours));

  Money? _laborAmount(AppLocalizations l) =>
      parseMoney(_labor.text, l.localeName);

  OfferTotals _totals(AppLocalizations l) => OfferTotals.of(
    _laborAmount(l) ?? Money.zero,
    _materials.map((m) => m.line),
  );

  Future<void> _pickDay() async {
    final now = ref.read(nowProvider)();
    final d = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(kMaxArrivalLead),
    );
    if (d != null) {
      setState(() => _day = d);
      _touch();
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (t != null) {
      setState(() => _time = t);
      _touch();
    }
  }

  Future<void> _editMaterial([int? index]) async {
    final res = await showModalBottomSheet<_MaterialDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _MaterialSheet(initial: index == null ? null : _materials[index]),
    );
    if (res == null) return;
    setState(() {
      if (index == null) {
        _materials.add(res);
      } else {
        _materials[index] = res;
      }
    });
    _touch();
  }

  String _arrivalText(AppLocalizations l, ArrivalIssue i) => switch (i) {
    ArrivalIssue.missing => l.arrivalMissing,
    ArrivalIssue.past => l.arrivalPast,
    ArrivalIssue.tooShort => l.arrivalTooShort,
    ArrivalIssue.tooLong => l.arrivalTooLong,
    ArrivalIssue.tooFar => l.arrivalTooFar,
  };

  Future<void> _submit() async {
    if (_submitting) return;
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    setState(() {
      _attempted = true;
      _banner = null;
      _serverField = null;
    });
    final labor = _laborAmount(l);
    if (labor == null || !labor.isPositive) return;
    if (validateArrival(_from, _to, now) != null) return;
    setState(() => _submitting = true);
    final router = GoRouter.of(context);
    try {
      final totals = _totals(l);
      final items = [
        OfferItemInput(
          kind: OfferItemKind.labor,
          description: l.labor,
          quantity: 1,
          unitPrice: labor,
        ),
        for (final m in _materials)
          OfferItemInput(
            kind: OfferItemKind.material,
            description: m.description,
            quantity: m.quantity,
            unitPrice: m.unitPrice,
          ),
      ];
      final offer = await ref
          .read(apiClientProvider)
          .pro
          .createOffer(
            widget.requestId,
            CreateOfferRequest(
              laborAmount: labor,
              materialsAmount: totals.materials,
              arrivalFrom: _from!.toUtc(),
              arrivalTo: _to!.toUtc(),
              warrantyMonths: _warranty,
              note: _note.text.trim(),
              items: items,
            ),
            idempotencyKey: _key,
          );
      invalidateRequestData(ref);
      router.go('/p/feed');
      router.push('/p/offers/${offer.id}/sent');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _banner = apiErrorMessage(l, e.code);
        _serverField = e.code == ApiErrorCode.validationFailed ? e.field : null;
      });
      if (isStaleStateError(e)) invalidateRequestData(ref);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    final totals = _totals(l);
    final labor = _laborAmount(l);
    final arrivalIssue = validateArrival(_from, _to, now);
    String m(Money v) => formatMoney(v, l.localeName);
    // Talep durumu sunucudan izlenir; durum eskiyince (ILLEGAL_STATE)
    // sağlayıcı geçersiz kılınır ve form güncel durumu gösterir.
    final status = ref.watch(proRequestProvider(widget.requestId)).value?.status;
    final closed = status != null && status != RequestStatus.open;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: AppBackButton(fallback: '/p/requests/${widget.requestId}'),
        title: Text(l.offerFormTitle),
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
                  Text(l.labor, style: AppTypography.section),
                  const SizedBox(height: AppSpacing.xs),
                  AppTextField(
                    label: l.laborAmountLabel,
                    controller: _labor,
                    enabled: !_submitting,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    prefixText: '₺',
                    errorText:
                        _attempted && (labor == null || !labor.isPositive)
                        ? l.laborAmountInvalid
                        : _serverField == 'laborAmount'
                        ? l.errFieldInvalid
                        : null,
                    onChanged: (_) {
                      _touch();
                      setState(() {});
                    },
                  ),
                  const FieldGap(big: true),
                  Text(l.materials, style: AppTypography.section),
                  const SizedBox(height: AppSpacing.xs),
                  if (_materials.isEmpty)
                    Text(l.materialsEmpty, style: AppTypography.bodySecondary),
                  for (var i = 0; i < _materials.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: AppCard(
                        onTap: _submitting ? null : () => _editMaterial(i),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _materials[i].description,
                                    style: AppTypography.cardTitle,
                                  ),
                                  Text(
                                    '${_materials[i].quantity} × ${m(_materials[i].unitPrice)}',
                                    style: AppTypography.bodySecondary,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              m(_materials[i].line.total),
                              style: AppTypography.cardTitle,
                            ),
                            AppIconButton(
                              icon: Icons.delete_outline,
                              tooltip: l.materialRemove,
                              onPressed: _submitting
                                  ? null
                                  : () {
                                      setState(() => _materials.removeAt(i));
                                      _touch();
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  AppButton(
                    label: l.materialAdd,
                    icon: Icons.add,
                    variant: AppButtonVariant.secondary,
                    onPressed: _submitting ? null : () => _editMaterial(),
                  ),
                  if (_serverField == 'items' ||
                      _serverField == 'materialsAmount')
                    _fieldError(l.offerItemsServerInvalid),
                  const FieldGap(big: true),
                  Text(l.arrival, style: AppTypography.section),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l.arrivalHelp, style: AppTypography.bodySecondary),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: _submitting ? null : _pickDay,
                    child: Row(
                      children: [
                        Expanded(child: Text(l.arrivalDay)),
                        Text(
                          _day == null
                              ? l.pickerNone
                              : formatDay(l, _day!.toUtc(), now),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: _submitting ? null : _pickTime,
                    child: Row(
                      children: [
                        Expanded(child: Text(l.arrivalStart)),
                        Text(
                          _time == null
                              ? l.pickerNone
                              : MaterialLocalizations.of(context)
                                    .formatTimeOfDay(
                                      _time!,
                                      alwaysUse24HourFormat: true,
                                    ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l.arrivalLength, style: AppTypography.label),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      for (final h in const [1, 2, 3, 4, 6, 8, 12])
                        ChoiceChip(
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          label: Text(l.hoursShort(h)),
                          selected: _hours == h,
                          onSelected: _submitting
                              ? null
                              : (_) {
                                  setState(() => _hours = h);
                                  _touch();
                                },
                        ),
                    ],
                  ),
                  if (_attempted && arrivalIssue != null)
                    _fieldError(_arrivalText(l, arrivalIssue))
                  else if (_serverField == 'arrivalFrom' ||
                      _serverField == 'arrivalTo')
                    _fieldError(l.arrivalServerInvalid),
                  const FieldGap(big: true),
                  Text(l.warranty, style: AppTypography.section),
                  const SizedBox(height: 4),
                  Text(l.warrantyHelp, style: AppTypography.bodySecondary),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      for (final w in kWarrantyChoices)
                        ChoiceChip(
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          label: Text(warrantyText(l, w)),
                          selected: _warranty == w,
                          onSelected: _submitting
                              ? null
                              : (_) {
                                  setState(() => _warranty = w);
                                  _touch();
                                },
                        ),
                    ],
                  ),
                  if (_serverField == 'warrantyMonths')
                    _fieldError(l.errFieldInvalid),
                  const FieldGap(),
                  AppTextField(
                    label: l.offerNote,
                    controller: _note,
                    enabled: !_submitting,
                    maxLength: kNoteMax,
                    keyboardType: TextInputType.multiline,
                    errorText: _serverField == 'note'
                        ? l.errFieldInvalid
                        : null,
                    onChanged: (_) => _touch(),
                  ),
                  const FieldGap(),
                  AppCard(
                    semanticLabel: l.offerSummary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.offerSummary, style: AppTypography.cardTitle),
                        const SizedBox(height: 4),
                        InfoRow(l.labor, m(totals.labor)),
                        InfoRow(l.materials, m(totals.materials)),
                        InfoRow(
                          l.totalVatIncluded,
                          m(totals.total),
                          bold: true,
                        ),
                        InfoRow(
                          l.serviceFee(kServiceFeePercent),
                          '-${m(totals.serviceFee)}',
                        ),
                        InfoRow(l.netEarning, m(totals.net), bold: true),
                      ],
                    ),
                  ),
                  if (_banner != null) ...[
                    const FieldGap(),
                    MessageBanner(_banner!),
                  ],
                  if (closed) ...[
                    const FieldGap(),
                    MessageBanner(l.offerFormRequestClosed),
                  ],
                  const FieldGap(),
                  AppButton(
                    label: l.offerSend,
                    isLoading: _submitting,
                    onPressed: closed ? null : _submit,
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

class _MaterialSheet extends StatefulWidget {
  const _MaterialSheet({this.initial});

  final _MaterialDraft? initial;

  @override
  State<_MaterialSheet> createState() => _MaterialSheetState();
}

class _MaterialSheetState extends State<_MaterialSheet> {
  late final _desc = TextEditingController(text: widget.initial?.description);
  late final _qty = TextEditingController(
    text: '${widget.initial?.quantity ?? 1}',
  );
  late final _price = TextEditingController();
  bool _attempted = false;
  bool _filled = false;

  @override
  void dispose() {
    _desc.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_filled && widget.initial != null) {
      _filled = true;
      _price.text = (widget.initial!.unitPrice.cents / 100)
          .toStringAsFixed(widget.initial!.unitPrice.isWhole ? 0 : 2)
          .replaceAll('.', l.localeName == 'tr' ? ',' : '.');
    }
    final price = parseMoney(_price.text, l.localeName);
    final qty = int.tryParse(_qty.text.trim());
    final descOk = _desc.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.materialAdd, style: AppTypography.section),
            const FieldGap(),
            AppTextField(
              label: l.materialDescription,
              controller: _desc,
              errorText: _attempted && !descOk ? l.errRequired : null,
              onChanged: (_) => setState(() {}),
            ),
            const FieldGap(),
            AppTextField(
              label: l.materialQuantity,
              controller: _qty,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: _attempted && (qty == null || qty <= 0)
                  ? l.materialQuantityInvalid
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const FieldGap(),
            AppTextField(
              label: l.materialUnitPrice,
              controller: _price,
              prefixText: '₺',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              errorText: _attempted && price == null
                  ? l.materialPriceInvalid
                  : null,
              onChanged: (_) => setState(() {}),
            ),
            const FieldGap(big: true),
            AppButton(
              label: l.save,
              onPressed: () {
                setState(() => _attempted = true);
                // Güncel metinden hesaplanır (son tuş vuruşu çizilmemiş olabilir).
                final p = parseMoney(_price.text, l.localeName);
                final q = int.tryParse(_qty.text.trim());
                if (_desc.text.trim().isEmpty ||
                    q == null ||
                    q <= 0 ||
                    p == null) {
                  return;
                }
                Navigator.pop(context, _MaterialDraft(_desc.text.trim(), q, p));
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// `/p/offers/:id/sent`: gönderilen teklifin özeti.
class OfferSentScreen extends ConsumerWidget {
  const OfferSentScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(offerProvider(id));
    final now = ref.read(nowProvider)();
    return ListPage(
      title: l.offerSentTitle,
      leading: const AppBackButton(fallback: '/p/feed'),
      body: AsyncView<OfferDetail>(
        value: async,
        onRetry: () => ref.invalidate(offerProvider(id)),
        builder: (context, o) {
          String m(Money v) => formatMoney(v, l.localeName);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (o.status == OfferStatus.pending) ...[
                const Icon(
                  Icons.check_circle_outline,
                  size: 56,
                  color: AppColors.success,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.offerSentHeadline,
                  textAlign: TextAlign.center,
                  style: AppTypography.screenTitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l.offerSentBody,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary,
                ),
              ] else
                Align(
                  alignment: Alignment.centerLeft,
                  child: offerStatusChip(l, o.status),
                ),
              sectionTitle(l.offerSummary),
              InfoRow(l.labor, m(o.laborAmount)),
              InfoRow(l.materials, m(o.materialsAmount)),
              InfoRow(l.totalVatIncluded, m(o.totalAmount), bold: true),
              if (o.serviceFee != null)
                InfoRow(
                  l.serviceFee(kServiceFeePercent),
                  '-${m(o.serviceFee!)}',
                ),
              if (o.netEarning != null)
                InfoRow(l.netEarning, m(o.netEarning!), bold: true),
              InfoRow(
                l.arrival,
                formatWindow(l, o.arrivalFrom, o.arrivalTo, now),
              ),
              InfoRow(l.warranty, warrantyText(l, o.warrantyMonths)),
              InfoRow(l.offerValidUntil, formatDayTime(l, o.validUntil, now)),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l.goToMyOffers,
                onPressed: () {
                  context.go('/p/feed');
                  context.push('/p/offers');
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: l.backToFeed,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/p/feed'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// `/p/offers`: tekliflerim, durum filtreli.
class ProOffersScreen extends ConsumerStatefulWidget {
  const ProOffersScreen({super.key});

  @override
  ConsumerState<ProOffersScreen> createState() => _ProOffersState();
}

class _ProOffersState extends ConsumerState<ProOffersScreen> {
  OfferStatus? _status;
  bool _busy = false;

  Future<void> _withdraw(ProOfferItem item) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.withdrawTitle,
      message: l.withdrawMessage,
      confirmLabel: l.withdraw,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(apiClientProvider).pro.withdraw(item.offer.id);
      invalidateRequestData(ref);
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateRequestData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _statusLabel(AppLocalizations l, OfferStatus? s) => switch (s) {
    null => l.filterAll,
    OfferStatus.pending => l.offerPending,
    OfferStatus.accepted => l.offerAccepted,
    OfferStatus.declined => l.offerDeclined,
    OfferStatus.withdrawn => l.offerWithdrawn,
    OfferStatus.superseded => l.offerSuperseded,
    OfferStatus.expired => l.offerExpired,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(proOffersProvider(_status));
    final now = ref.read(nowProvider)();
    return ListPage(
      title: l.myOffersTitle,
      leading: const AppBackButton(fallback: '/p/feed'),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 4,
              ),
              children: [
                for (final s in const <OfferStatus?>[
                  null,
                  OfferStatus.pending,
                  OfferStatus.accepted,
                  OfferStatus.declined,
                  OfferStatus.withdrawn,
                  OfferStatus.expired,
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(_statusLabel(l, s)),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView<Paged<ProOfferItem>>(
              value: async,
              onRetry: () => ref.invalidate(proOffersProvider(_status)),
              builder: (context, page) {
                if (page.items.isEmpty) {
                  return EmptyState(
                    icon: Icons.local_offer_outlined,
                    title: l.myOffersEmptyTitle,
                    message: l.myOffersEmptyBody,
                    actionLabel: l.backToFeed,
                    onAction: () => context.go('/p/feed'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(proOffersProvider(_status).future),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: page.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final it = page.items[i];
                      final o = it.offer;
                      return AppCard(
                        onTap: () async {
                          await context.push('/p/requests/${it.request.id}');
                          ref.invalidate(proOffersProvider);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.request.title,
                              style: AppTypography.cardTitle,
                            ),
                            Text(
                              '${it.request.districtName} · ${it.request.publicCode}',
                              style: AppTypography.bodySecondary,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  formatMoney(o.totalAmount, l.localeName),
                                  style: AppTypography.section,
                                ),
                                offerStatusChip(l, o.status),
                              ],
                            ),
                            Text(
                              formatWindow(l, o.arrivalFrom, o.arrivalTo, now),
                              style: AppTypography.bodySecondary,
                            ),
                            if (o.status == OfferStatus.pending)
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: AppButton(
                                  label: l.withdraw,
                                  expand: false,
                                  variant: AppButtonVariant.tertiary,
                                  onPressed: _busy ? null : () => _withdraw(it),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
