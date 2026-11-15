import 'dart:async';

import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../l10n/app_localizations.dart';

/// İçerik genişliği üst sınırı.
const double kContentMaxWidth = 1240;

/// Kenar boşluğu.
const double kPagePadding = 24;

/// Kaydırılabilir sayfa: başlık, açıklama, eylemler ve içerik.
class PageScroll extends StatelessWidget {
  const PageScroll({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;

  /// Başlığın solunda (örn. geri düğmesi).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.all(kPagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: AppTypography.screenTitle,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(subtitle!, style: AppTypography.bodySecondary),
                          ],
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.md),
                      Wrap(spacing: AppSpacing.xs, children: actions),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Yükleme, hata (tekrar dene) ve veri durumlarını çizer.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.onRetry,
    required this.data,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return value.when(
      skipLoadingOnReload: false,
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: Semantics(
            label: l.loading,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, _) => ErrorState(
        title: l.loadFailedTitle,
        message: errorText(l, error),
        retryLabel: l.retry,
        onRetry: onRetry,
      ),
      data: data,
    );
  }
}

/// Üstte kısa bildirim.
void showNotice(BuildContext context, String text) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Arama kutusu: yazarken 400 ms sonra, Enter'da hemen bildirir.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint,
    this.width = 360,
  });

  final String label;
  final String? hint;
  final double width;
  final ValueChanged<String> onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 400),
      () => widget.onChanged(text.trim()),
    );
  }

  void _submitted(String text) {
    _timer?.cancel();
    widget.onChanged(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width),
      child: AppTextField(
        label: widget.label,
        hintText: widget.hint,
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: _changed,
        onFieldSubmitted: _submitted,
      ),
    );
  }
}

/// Etiketli seçenek sırası (tek seçim).
class FilterRow<T> extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (value, text) in options)
              ChoiceChip(
                label: Text(text),
                selected: value == selected,
                onSelected: (_) => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

/// Tablo sütunu.
class TableColumn<T> {
  const TableColumn({
    required this.header,
    required this.cell,
    this.flex = 1,
    this.alignEnd = false,
  });

  final String header;
  final Widget Function(T row) cell;
  final int flex;
  final bool alignEnd;
}

/// Geniş alanda tablo, dar alanda (`stackBelow`) üst üste kartlar. `minWidth`
/// altında yatay kaydırılır.
class ResponsiveTable<T> extends StatelessWidget {
  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onTap,
    this.minWidth = 0,
    this.stackBelow = 0,
    this.rowKey,
  });

  final List<TableColumn<T>> columns;
  final List<T> rows;
  final void Function(T row)? onTap;
  final double minWidth;
  final double stackBelow;
  final Key Function(T row)? rowKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w < stackBelow) return _stacked(context);
        final tableWidth = w < minWidth ? minWidth : w;
        final table = SizedBox(
          width: tableWidth,
          child: Column(
            children: [_headerRow(), for (final r in rows) _row(r)],
          ),
        );
        return AppCard(
          padding: EdgeInsets.zero,
          child: tableWidth > w
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: table,
                )
              : table,
        );
      },
    );
  }

  Widget _headerRow() => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: const BoxDecoration(
      color: AppColors.neutralSurface,
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        for (final c in columns)
          Expanded(
            flex: c.flex,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Text(
                c.header,
                textAlign: c.alignEnd ? TextAlign.end : TextAlign.start,
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _row(T r) {
    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final c in columns)
            Expanded(
              flex: c.flex,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: Align(
                  alignment: c.alignEnd
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: c.cell(r),
                ),
              ),
            ),
        ],
      ),
    );
    return KeyedSubtree(
      key: rowKey?.call(r),
      child: onTap == null
          ? content
          : InkWell(onTap: () => onTap!(r), child: content),
    );
  }

  Widget _stacked(BuildContext context) => Column(
    // Kartlar tam genişlik; yoksa içerik kadar daralıp ortada kalır.
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: KeyedSubtree(
            key: rowKey?.call(r),
            child: AppCard(
              onTap: onTap == null ? null : () => onTap!(r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final c in columns)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.header,
                            style: AppTypography.label.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          c.cell(r),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

/// "Etiket: değer" satırı.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: value),
      ],
    ),
  );
}

/// Kart başlığı + içerik.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: AppTypography.cardTitle),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    ),
  );
}

/// Not alanı doğrulaması: kırpılmış uzunluk `min`-`max` arasında olmalı.
String? validateNote(AppLocalizations l, String? value, int min, int max) {
  final len = (value ?? '').trim().length;
  if (len < min) return l.noteTooShort(min);
  if (len > max) return l.noteTooLong(max);
  return null;
}
