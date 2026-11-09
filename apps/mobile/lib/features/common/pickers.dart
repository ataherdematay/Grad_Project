import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import 'ui.dart';

/// Arama kutulu çoklu/tekli seçim sayfası. Seçilen kimlikleri döndürür.
Future<Set<String>?> showPickerSheet(
  BuildContext context, {
  required String title,
  required List<({String id, String label})> options,
  required Set<String> selected,
  required bool multi,
  bool searchable = true,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _PickerSheet(
      title: title,
      options: options,
      initial: selected,
      multi: multi,
      searchable: searchable,
    ),
  );
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.initial,
    required this.multi,
    required this.searchable,
  });

  final String title;
  final List<({String id, String label})> options;
  final Set<String> initial;
  final bool multi;
  final bool searchable;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late final Set<String> _sel = {...widget.initial};
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = _q.trim().toLowerCase();
    final filtered = [
      for (final o in widget.options)
        if (q.isEmpty || o.label.toLowerCase().contains(q)) o,
    ];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: AppTypography.section),
                ),
                if (widget.multi)
                  TextButton(
                    onPressed: () => Navigator.pop(context, _sel),
                    child: Text(l.done),
                  ),
              ],
            ),
          ),
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppTextField(
                label: l.searchLabel,
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(title: l.noSearchResults)
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final o = filtered[i];
                      final on = _sel.contains(o.id);
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: on,
                        title: Text(o.label),
                        onChanged: (v) {
                          if (widget.multi) {
                            setState(() {
                              if (v == true) {
                                _sel.add(o.id);
                              } else {
                                _sel.remove(o.id);
                              }
                            });
                          } else {
                            Navigator.pop(context, {o.id});
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Tıklanınca seçim sayfası açan, seçili özeti gösteren alan.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.summary,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String? summary;
  final VoidCallback? onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: errorText != null ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: '$label, ${summary ?? l.pickerNone}',
          excludeSemantics: true,
          onTap: onTap,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSizes.controlHeight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: errorText != null ? AppColors.error : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      summary ?? l.pickerNone,
                      style: summary == null
                          ? AppTypography.bodySecondary
                          : AppTypography.body,
                    ),
                  ),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// İlçe seçici (tekli veya çoklu), `/districts` verisiyle.
class DistrictPicker extends ConsumerWidget {
  const DistrictPicker({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.multi = false,
    this.errorText,
  });

  final String label;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool multi;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(districtsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => ErrorState(
        title: l.genericErrorTitle,
        retryLabel: l.retry,
        onRetry: () => ref.invalidate(districtsProvider),
      ),
      data: (districts) {
        final names = {for (final d in districts) d.id: d.name};
        final chosen = [
          for (final id in selected)
            if (names[id] != null) names[id]!,
        ];
        return PickerField(
          label: label,
          summary: chosen.isEmpty ? null : chosen.join(', '),
          errorText: errorText,
          onTap: () async {
            final res = await showPickerSheet(
              context,
              title: label,
              multi: multi,
              selected: selected,
              options: [for (final d in districts) (id: d.id, label: d.name)],
            );
            if (res != null) onChanged(res);
          },
        );
      },
    );
  }
}

/// Kategori seçici (çoklu).
class CategoryMultiPicker extends ConsumerWidget {
  const CategoryMultiPicker({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(categoriesProvider);
    final locale = l.localeName;
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => ErrorState(
        title: l.genericErrorTitle,
        retryLabel: l.retry,
        onRetry: () => ref.invalidate(categoriesProvider),
      ),
      data: (cats) {
        final chosen = [
          for (final c in cats)
            if (selected.contains(c.id)) locale == 'en' ? c.nameEn : c.nameTr,
        ];
        return PickerField(
          label: label,
          summary: chosen.isEmpty ? null : chosen.join(', '),
          errorText: errorText,
          onTap: () async {
            final res = await showPickerSheet(
              context,
              title: label,
              multi: true,
              searchable: false,
              selected: selected,
              options: [
                for (final c in cats)
                  (id: c.id, label: locale == 'en' ? c.nameEn : c.nameTr),
              ],
            );
            if (res != null) onChanged(res);
          },
        );
      },
    );
  }
}

String districtNamesOf(List<District>? all, Iterable<String> ids) {
  if (all == null) return '';
  final m = {for (final d in all) d.id: d.name};
  return ids.map((i) => m[i]).whereType<String>().join(', ');
}

String categoryNamesOf(List<Category>? all, Iterable<String> ids, String loc) {
  if (all == null) return '';
  return ids
      .map((i) => categoryNameOf(all, i, loc))
      .where((s) => s.isNotEmpty)
      .join(', ');
}
