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

String warrantyText(AppLocalizations l, int months) =>
    months == 0 ? l.warrantyNone : l.warrantyMonths(months);

/// Teklif kartı (liste): usta, toplam, varış, garanti.
class OfferCard extends ConsumerWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
    this.selectable = false,
    this.selected = false,
  });

  final OfferSummary offer;
  final VoidCallback onTap;
  final bool selectable;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    final pro = offer.pro;
    return Semantics(
      selected: selectable ? selected : null,
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectable)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pro.businessName, style: AppTypography.cardTitle),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      RatingText(avg: pro.ratingAvg, count: pro.ratingCount),
                      if (pro.verified)
                        StatusChip(
                          label: l.proVerified,
                          icon: Icons.verified_outlined,
                          tone: StatusTone.success,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatMoney(offer.totalAmount, l.localeName),
                    style: AppTypography.section,
                  ),
                  Text(l.vatIncluded, style: AppTypography.label),
                  const SizedBox(height: 4),
                  Text(
                    formatWindow(l, offer.arrivalFrom, offer.arrivalTo, now),
                    style: AppTypography.bodySecondary,
                  ),
                  Text(
                    '${l.warranty}: ${warrantyText(l, offer.warrantyMonths)}',
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `/c/requests/:id/offers`: liste, filtre-sıralama, karşılaştırma seçimi.
class RequestOffersScreen extends ConsumerStatefulWidget {
  const RequestOffersScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<RequestOffersScreen> createState() => _OffersState();
}

class _OffersState extends ConsumerState<RequestOffersScreen> {
  late OffersQuery _query = OffersQuery(requestId: widget.id);
  bool _comparing = false;
  final List<String> _selected = [];

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < 3) {
        _selected.add(id);
      }
    });
  }

  Future<void> _openFilter() async {
    final res = await showModalBottomSheet<OffersQuery>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => OffersFilterSheet(initial: _query),
    );
    if (res != null) setState(() => _query = res);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(requestOffersProvider(_query));
    final canCompare = _selected.length >= 2 && _selected.length <= 3;
    return ListPage(
      title: l.offersTitle,
      leading: const AppBackButton(fallback: '/c/requests'),
      actions: [
        AppIconButton(
          icon: Icons.tune,
          tooltip: l.offersFilterTitle,
          color: _query.hasFilter || _query.sort != OfferSort.recommended
              ? AppColors.primary
              : null,
          onPressed: _openFilter,
        ),
      ],
      bottom: _comparing
          ? AppButton(
              label: l.compareSelected(_selected.length),
              onPressed: canCompare
                  ? () => context.push(
                      '/c/requests/${widget.id}/compare?ids=${_selected.join(',')}',
                    )
                  : null,
            )
          : null,
      body: AsyncView<OfferList>(
        value: async,
        onRetry: () => ref.invalidate(requestOffersProvider),
        builder: (context, list) {
          return RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(requestOffersProvider(_query).future),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        l.offersResultCount(list.items.length),
                        style: AppTypography.section,
                      ),
                    ),
                    if (list.items.length >= 2)
                      AppButton(
                        label: _comparing ? l.compareCancel : l.compare,
                        expand: false,
                        variant: AppButtonVariant.tertiary,
                        onPressed: () => setState(() {
                          _comparing = !_comparing;
                          _selected.clear();
                        }),
                      ),
                  ],
                ),
                if (_comparing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      l.compareHint,
                      style: AppTypography.bodySecondary,
                    ),
                  ),
                if (list.declinedCount > 0)
                  Text(
                    l.offersDeclinedCount(list.declinedCount),
                    style: AppTypography.bodySecondary,
                  ),
                const SizedBox(height: AppSpacing.xs),
                if (list.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 56,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _query.hasFilter
                              ? l.offersEmptyFilteredTitle
                              : l.offersEmptyTitle,
                          style: AppTypography.section,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _query.hasFilter
                              ? l.offersEmptyFilteredBody
                              : l.offersEmptyBody,
                          style: AppTypography.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        if (_query.hasFilter)
                          AppButton(
                            label: l.offersClearFilters,
                            variant: AppButtonVariant.secondary,
                            onPressed: () => setState(
                              () => _query = _query.copyWith(
                                clearMaxPrice: true,
                                clearMinRating: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                for (final o in list.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: OfferCard(
                      offer: o,
                      selectable: _comparing,
                      selected: _selected.contains(o.id),
                      onTap: () async {
                        if (_comparing) {
                          _toggle(o.id);
                        } else {
                          await context.push('/c/offers/${o.id}');
                          ref.invalidate(requestOffersProvider);
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Filtre ve sıralama alt sayfası (prototip 12). "Uygula" yeni sorguyu döner.
class OffersFilterSheet extends StatefulWidget {
  const OffersFilterSheet({super.key, required this.initial});

  final OffersQuery initial;

  @override
  State<OffersFilterSheet> createState() => _FilterState();
}

class _FilterState extends State<OffersFilterSheet> {
  late OfferSort _sort = widget.initial.sort;
  late double? _rating = widget.initial.minRating;
  late final _price = TextEditingController(
    text: widget.initial.maxPrice == null
        ? ''
        : '${widget.initial.maxPrice!.lira}',
  );

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  String _sortLabel(AppLocalizations l, OfferSort s) => switch (s) {
    OfferSort.recommended => l.sortRecommended,
    OfferSort.price => l.sortPrice,
    OfferSort.rating => l.sortRating,
    OfferSort.arrival => l.sortArrival,
  };

  OffersQuery _build() {
    final digits = _price.text.replaceAll(RegExp(r'\D'), '');
    final price = digits.isEmpty ? null : int.tryParse(digits);
    return OffersQuery(
      requestId: widget.initial.requestId,
      sort: _sort,
      maxPrice: price == null || price == 0 ? null : Money.lira(price),
      minRating: _rating,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.offersFilterTitle,
                    style: AppTypography.section,
                  ),
                ),
                AppIconButton(
                  icon: Icons.close,
                  tooltip: l.close,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            sectionTitle(l.sortBy),
            for (final s in OfferSort.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: ChoiceCard(
                  title: _sortLabel(l, s),
                  selected: _sort == s,
                  onTap: () => setState(() => _sort = s),
                ),
              ),
            sectionTitle(l.filterMaxPrice),
            AppTextField(
              label: l.filterMaxPriceLabel,
              controller: _price,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixText: '₺',
              helperText: l.filterMaxPriceHelp,
            ),
            sectionTitle(l.filterMinRating),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final r in <double?>[null, 4.0, 4.5])
                  ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    label: Text(
                      r == null
                          ? l.filterAnyRating
                          : l.filterRatingOrMore(formatRating(r, l.localeName)),
                    ),
                    selected: _rating == r,
                    onSelected: (_) => setState(() => _rating = r),
                  ),
              ],
            ),
            const FieldGap(big: true),
            AppButton(
              label: l.applyFilters,
              onPressed: () => Navigator.pop(context, _build()),
            ),
            AppButton(
              label: l.offersClearFilters,
              variant: AppButtonVariant.tertiary,
              onPressed: () => Navigator.pop(
                context,
                OffersQuery(requestId: widget.initial.requestId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `/c/requests/:id/compare?ids=a,b,c`: 2-3 teklifin karşılaştırma tablosu.
class CompareOffersScreen extends ConsumerWidget {
  const CompareOffersScreen({super.key, required this.id, required this.ids});

  final String id;
  final List<String> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(requestOffersProvider(OffersQuery(requestId: id)));
    final now = ref.read(nowProvider)();
    return ListPage(
      title: l.compareTitle,
      leading: AppBackButton(fallback: '/c/requests/$id/offers'),
      body: AsyncView<OfferList>(
        value: async,
        onRetry: () => ref.invalidate(requestOffersProvider),
        builder: (context, list) {
          final offers = [
            for (final i in ids)
              for (final o in list.items)
                if (o.id == i) o,
          ];
          if (offers.length < 2) {
            return EmptyState(
              title: l.compareGoneTitle,
              message: l.compareGoneBody,
              actionLabel: l.compareBackToOffers,
              // Derin bağlantıda yığın boş olabilir; boş yığında pop yapılmaz.
              onAction: () => context.canPop()
                  ? context.pop()
                  : context.go('/c/requests/$id/offers'),
            );
          }
          String m(Money v) => formatMoney(v, l.localeName);
          final rows = <(String, List<String>)>[
            (l.compareTotal, [for (final o in offers) m(o.totalAmount)]),
            (l.labor, [for (final o in offers) m(o.laborAmount)]),
            (l.materials, [for (final o in offers) m(o.materialsAmount)]),
            (
              l.arrival,
              [
                for (final o in offers)
                  formatWindow(l, o.arrivalFrom, o.arrivalTo, now),
              ],
            ),
            (
              l.warranty,
              [for (final o in offers) warrantyText(l, o.warrantyMonths)],
            ),
            (
              l.proRating,
              [
                for (final o in offers)
                  o.pro.ratingCount == 0
                      ? l.noRatingYet
                      : l.ratingWithCount(
                          formatRating(o.pro.ratingAvg, l.localeName),
                          o.pro.ratingCount,
                        ),
              ],
            ),
            (
              l.proCompletedJobs,
              [for (final o in offers) '${o.pro.completedJobs}'],
            ),
            (
              l.proVerified,
              [for (final o in offers) o.pro.verified ? l.yes : l.no],
            ),
          ];
          // Her özellik kendi kartında, teklifler alt alta: 2-3 teklif 320 px
          // genişlikte de yatay kaydırma olmadan okunur.
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final o in offers)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: AppCard(
                    onTap: () => context.push('/c/offers/${o.id}'),
                    semanticLabel: l.viewOffer,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.pro.businessName,
                            style: AppTypography.cardTitle,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              for (final r in rows)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.$1, style: AppTypography.label),
                        const SizedBox(height: 4),
                        for (var i = 0; i < offers.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    offers[i].pro.businessName,
                                    style: AppTypography.bodySecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    r.$2[i],
                                    textAlign: TextAlign.end,
                                    style: AppTypography.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// `/c/offers/:id`: teklif detayı.
class OfferDetailScreen extends ConsumerWidget {
  const OfferDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(offerProvider(id));
    return ListPage(
      title: l.offerDetailTitle,
      leading: const AppBackButton(fallback: '/c/requests'),
      body: AsyncView<OfferDetail>(
        value: async,
        onRetry: () => ref.invalidate(offerProvider(id)),
        builder: (context, o) => _OfferBody(o: o),
      ),
    );
  }
}

class _OfferBody extends ConsumerWidget {
  const _OfferBody({required this.o});

  final OfferDetail o;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    String m(Money v) => formatMoney(v, l.localeName);
    final labor = o.items.where((i) => i.kind == OfferItemKind.labor);
    final mats = o.items.where((i) => i.kind == OfferItemKind.material);
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(offerProvider(o.id).future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            onTap: () => context.push('/c/pros/${o.pro.id}'),
            semanticLabel: l.viewProfile,
            child: Row(
              children: [
                const Icon(Icons.handyman_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.pro.businessName, style: AppTypography.cardTitle),
                      Text(o.pro.fullName, style: AppTypography.bodySecondary),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 4,
                        children: [
                          RatingText(
                            avg: o.pro.ratingAvg,
                            count: o.pro.ratingCount,
                          ),
                          if (o.pro.verified)
                            StatusChip(
                              label: l.proVerified,
                              icon: Icons.verified_outlined,
                              tone: StatusTone.success,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: offerStatusChip(l, o.status),
          ),
          sectionTitle(l.offerBreakdown),
          InfoRow(l.labor, m(o.laborAmount)),
          for (final i in labor)
            if (o.items.length > 1) _ItemLine(i, l.localeName),
          InfoRow(l.materials, m(o.materialsAmount)),
          for (final i in mats) _ItemLine(i, l.localeName),
          const Divider(),
          InfoRow(l.totalVatIncluded, m(o.totalAmount), bold: true),
          sectionTitle(l.arrival),
          Text(
            formatWindow(l, o.arrivalFrom, o.arrivalTo, now),
            style: AppTypography.body,
          ),
          sectionTitle(l.warranty),
          Text(warrantyText(l, o.warrantyMonths), style: AppTypography.body),
          if ((o.note ?? '').isNotEmpty) ...[
            sectionTitle(l.offerNote),
            Text(o.note!, style: AppTypography.body),
          ],
          sectionTitle(l.offerValidUntil),
          Text(formatDayTime(l, o.validUntil, now), style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          // Ödemeler sonraki dalgada: bayrak false iken düğme hiç yok.
          if (kPaymentsEnabled && o.status == OfferStatus.pending) ...[
            AppButton(
              label: l.offerAccept,
              onPressed: () => context.push('/c/offers/${o.id}/accept'),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          AppButton(
            label: l.viewProfile,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/c/pros/${o.pro.id}'),
          ),
          if (o.status == OfferStatus.pending)
            AppButton(
              label: l.offerDecline,
              variant: AppButtonVariant.tertiary,
              onPressed: () async {
                await context.push('/c/offers/${o.id}/decline');
                ref.invalidate(offerProvider(o.id));
              },
            ),
        ],
      ),
    );
  }
}

class _ItemLine extends StatelessWidget {
  const _ItemLine(this.item, this.locale);

  final OfferItem item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity == item.quantity.roundToDouble()
        ? '${item.quantity.round()}'
        : '${item.quantity}';
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item.description} × $qty',
              style: AppTypography.bodySecondary,
            ),
          ),
          Text(
            formatMoney(item.lineTotal, locale),
            style: AppTypography.bodySecondary,
          ),
        ],
      ),
    );
  }
}

/// `/c/offers/:id/decline`: gerekçe, not, "Talebim açık kalsın", onay.
class DeclineOfferScreen extends ConsumerStatefulWidget {
  const DeclineOfferScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DeclineOfferScreen> createState() => _DeclineState();
}

class _DeclineState extends ConsumerState<DeclineOfferScreen> {
  DeclineReason? _reason;
  bool _keepOpen = true;
  final _note = TextEditingController();
  bool _attempted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _label(AppLocalizations l, DeclineReason r) => switch (r) {
    DeclineReason.price => l.declineReasonPrice,
    DeclineReason.schedule => l.declineReasonSchedule,
    DeclineReason.otherOffer => l.declineReasonOtherOffer,
    DeclineReason.notNeeded => l.declineReasonNotNeeded,
    DeclineReason.other => l.declineReasonOther,
  };

  /// Talep açık kalmayacaksa gerekçe "ihtiyaç kalmadı" ya da "diğer" olmalı.
  bool get _reasonConflict =>
      !_keepOpen &&
      _reason != null &&
      _reason != DeclineReason.notNeeded &&
      _reason != DeclineReason.other;

  Future<void> _submit(OfferDetail o) async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    setState(() => _attempted = true);
    if (_reason == null || _reasonConflict) return;
    final ok = await showConfirmDialog(
      context,
      title: l.declineConfirmTitle,
      message: _keepOpen ? l.declineConfirmKeepOpen : l.declineConfirmClose,
      confirmLabel: l.offerDecline,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final router = GoRouter.of(context);
    final keep = _keepOpen;
    try {
      final note = _note.text.trim();
      await ref
          .read(apiClientProvider)
          .offers
          .decline(
            widget.id,
            DeclineOfferRequest(
              reason: _reason!,
              note: note.isEmpty ? null : note,
              keepRequestOpen: keep,
            ),
          );
      invalidateRequestData(ref);
      if (!keep) {
        router.go('/c/requests');
      } else if (!router.canPop()) {
        // Derin bağlantı: yığın boş, talebin teklif listesine gidilir.
        router.go('/c/requests/${o.requestId}/offers');
      } else {
        router.pop();
        if (router.canPop()) router.pop();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = apiErrorMessage(l, e.code));
      if (isStaleStateError(e)) invalidateRequestData(ref);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(offerProvider(widget.id));
    return ListPage(
      title: l.offerDecline,
      leading: const AppBackButton(fallback: '/c/requests'),
      body: AsyncView<OfferDetail>(
        value: async,
        onRetry: () => ref.invalidate(offerProvider(widget.id)),
        builder: (context, o) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.declineIntro(
                  o.pro.businessName,
                  formatMoney(o.totalAmount, l.localeName),
                ),
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(l.declineIrreversible, style: AppTypography.bodySecondary),
              sectionTitle(l.declineReasonTitle),
              for (final r in DeclineReason.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ChoiceCard(
                    title: _label(l, r),
                    selected: _reason == r,
                    onTap: _loading ? null : () => setState(() => _reason = r),
                  ),
                ),
              if (_attempted && _reason == null)
                Text(
                  l.reasonRequired,
                  style: AppTypography.label.copyWith(color: AppColors.error),
                ),
              if (_attempted && _reasonConflict)
                Text(
                  l.declineCloseNeedsReason,
                  style: AppTypography.label.copyWith(color: AppColors.error),
                ),
              const FieldGap(),
              AppTextField(
                label: l.noteOptional,
                controller: _note,
                enabled: !_loading,
                maxLength: 250,
                keyboardType: TextInputType.multiline,
                minLines: 3,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.declineKeepOpen),
                subtitle: Text(l.declineKeepOpenHelp),
                value: _keepOpen,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _keepOpen = v),
              ),
              if (_error != null) ...[const FieldGap(), MessageBanner(_error!)],
              const FieldGap(),
              AppButton(
                label: l.offerDecline,
                isLoading: _loading,
                onPressed: () => _submit(o),
              ),
              AppButton(
                label: l.declineBack,
                variant: AppButtonVariant.tertiary,
                onPressed: _loading ? null : () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
