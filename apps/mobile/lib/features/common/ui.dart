import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error_messages.dart';
import '../../core/photos.dart';
import '../../l10n/app_localizations.dart';

/// Yükleme, hata ve veri durumlarını tek yerde çizer. Veri varken yenileme
/// sürüyorsa üstte ince ilerleme çubuğu çıkar (NAVIGATION_RULES §4).
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.onRetry,
    required this.builder,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (value.hasValue && !value.hasError) {
      return Column(
        children: [
          if (value.isLoading)
            const LinearProgressIndicator(minHeight: 3)
          else
            const SizedBox(height: 3),
          Expanded(child: builder(context, value.requireValue)),
        ],
      );
    }
    if (value.hasError) {
      final e = value.error;
      return ErrorState(
        title: l.genericErrorTitle,
        message: e is ApiException ? apiErrorMessage(l, e.code) : null,
        retryLabel: l.retry,
        onRetry: onRetry,
      );
    }
    return Center(
      child: Semantics(
        label: l.loading,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

/// Ağ görseli: yükleme ve hata durumlu.
class MediaImage extends StatelessWidget {
  const MediaImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 12,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : Container(
                width: width,
                height: height,
                color: AppColors.neutralSurface,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
        errorBuilder: (context, error, stack) => Container(
          width: width,
          height: height,
          color: AppColors.neutralSurface,
          alignment: Alignment.center,
          child: Semantics(
            label: l.photoLoadFailed,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fotoğraf şeridi (salt görüntüleme).
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.photos});

  final List<MediaRef> photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (_, i) =>
            MediaImage(photos[i].url, width: 120, height: 120),
      ),
    );
  }
}

/// Hata bildirimi. `ILLEGAL_STATE` ise "ekran güncellendi" metni gösterilir ve
/// [onIllegalState] ile ekran yenilenir.
void reportActionError(
  BuildContext context,
  ApiException e, {
  VoidCallback? onIllegalState,
}) {
  final l = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(apiErrorMessage(l, e.code))));
  if (e.code == ApiErrorCode.illegalState) onIllegalState?.call();
}

Widget sectionTitle(String text) => Padding(
  padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
  child: Semantics(
    header: true,
    child: Text(text, style: AppTypography.cardTitle),
  ),
);

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? AppTypography.cardTitle : AppTypography.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: style.copyWith(
                color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

String categoryNameOf(List<Category>? cats, String id, String locale) {
  if (cats == null) return '';
  for (final c in cats) {
    if (c.id == id) return locale == 'en' ? c.nameEn : c.nameTr;
  }
  return '';
}

IconData categoryIcon(String idOrIcon) {
  final k = idOrIcon.toLowerCase();
  if (k.contains('plumb')) return Icons.plumbing;
  if (k.contains('electric')) return Icons.electrical_services;
  if (k.contains('paint')) return Icons.format_paint;
  if (k.contains('hvac') || k.contains('clima')) return Icons.ac_unit;
  if (k.contains('bath')) return Icons.bathtub_outlined;
  if (k.contains('kitchen')) return Icons.kitchen;
  if (k.contains('carpen')) return Icons.carpenter;
  return Icons.handyman_outlined;
}

/// Talep durum etiketi (GLOSSARY): ikon + metin.
Widget requestStatusChip(AppLocalizations l, RequestStatus s, int offerCount) {
  return switch (s) {
    RequestStatus.open when offerCount > 0 => StatusChip(
      label: l.requestOffersCount(offerCount),
      icon: Icons.local_offer_outlined,
      tone: StatusTone.primary,
    ),
    RequestStatus.open => StatusChip(
      label: l.requestAwaitingOffers,
      icon: Icons.hourglass_empty,
      tone: StatusTone.info,
    ),
    RequestStatus.assigned => StatusChip(
      label: l.requestAssigned,
      icon: Icons.handshake_outlined,
      tone: StatusTone.success,
    ),
    RequestStatus.cancelled => StatusChip(
      label: l.requestCancelled,
      icon: Icons.cancel_outlined,
      tone: StatusTone.neutral,
    ),
    RequestStatus.expired => StatusChip(
      label: l.requestExpired,
      icon: Icons.timer_off_outlined,
      tone: StatusTone.neutral,
    ),
  };
}

Widget offerStatusChip(AppLocalizations l, OfferStatus s) => switch (s) {
  OfferStatus.pending => StatusChip(
    label: l.offerPending,
    icon: Icons.hourglass_top,
    tone: StatusTone.info,
  ),
  OfferStatus.accepted => StatusChip(
    label: l.offerAccepted,
    icon: Icons.check_circle_outline,
    tone: StatusTone.success,
  ),
  OfferStatus.declined => StatusChip(
    label: l.offerDeclined,
    icon: Icons.cancel_outlined,
    tone: StatusTone.error,
  ),
  OfferStatus.withdrawn => StatusChip(
    label: l.offerWithdrawn,
    icon: Icons.undo,
    tone: StatusTone.neutral,
  ),
  OfferStatus.superseded => StatusChip(
    label: l.offerSuperseded,
    icon: Icons.swap_horiz,
    tone: StatusTone.neutral,
  ),
  OfferStatus.expired => StatusChip(
    label: l.offerExpired,
    icon: Icons.timer_off_outlined,
    tone: StatusTone.neutral,
  ),
};

Widget urgencyChip(AppLocalizations l, RequestUrgency u) =>
    u == RequestUrgency.urgent
    ? StatusChip(
        label: l.urgencyUrgent,
        icon: Icons.bolt,
        tone: StatusTone.urgent,
      )
    : StatusChip(
        label: l.urgencyPlanned,
        icon: Icons.event_outlined,
        tone: StatusTone.primary,
      );

/// Yıldız puanı + sayı.
class RatingText extends StatelessWidget {
  const RatingText({super.key, required this.avg, required this.count});

  final double avg;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (count == 0) {
      return Text(l.noRatingYet, style: AppTypography.label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 16, color: AppColors.urgency),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            l.ratingWithCount(avg.toStringAsFixed(1), count),
            style: AppTypography.label,
          ),
        ),
      ],
    );
  }
}

/// Fotoğraf ekleme alanı: küçük resimler, ilerleme, tek tek kaldırma.
class PhotoSetView extends StatelessWidget {
  const PhotoSetView({super.key, required this.set, this.enabled = true});

  final PhotoSet set;
  final bool enabled;

  Future<void> _pickSource(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              minTileHeight: AppSizes.minTouch,
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.photoFromCamera),
              onTap: () => Navigator.pop(ctx, PhotoSource.camera),
            ),
            ListTile(
              minTileHeight: AppSizes.minTouch,
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.photoFromGallery),
              onTap: () => Navigator.pop(ctx, PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await set.add(source);
  }

  String _failure(AppLocalizations l, PhotoItem i) => switch (i.failure) {
    PhotoFailure.tooLarge => l.photoTooLarge,
    PhotoFailure.upload =>
      i.error == null ? l.apiErrorUnknown : apiErrorMessage(l, i.error!.code),
    _ => l.apiErrorUnknown,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: set,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in set.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: item.bytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                item.bytes!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.image_outlined),
                              ),
                            )
                          : MediaImage(item.remote!.url, width: 64, height: 64),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: switch (item.status) {
                        PhotoStatus.uploading => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.photoUploading, style: AppTypography.label),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: item.progress > 0 ? item.progress : null,
                            ),
                          ],
                        ),
                        PhotoStatus.failed => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _failure(l, item),
                              style: AppTypography.label.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            if (item.failure == PhotoFailure.upload)
                              TextButton(
                                onPressed: () => set.retry(item),
                                child: Text(l.retry),
                              ),
                          ],
                        ),
                        PhotoStatus.done => Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Text(l.photoUploaded, style: AppTypography.label),
                          ],
                        ),
                      },
                    ),
                    AppIconButton(
                      icon: Icons.close,
                      tooltip: l.photoRemove,
                      onPressed: enabled ? () => set.remove(item) : null,
                    ),
                  ],
                ),
              ),
            AppButton(
              label: set.isFull ? l.photoLimitReached(set.max) : l.photoAdd,
              icon: Icons.add_a_photo_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: (!enabled || set.isFull)
                  ? null
                  : () => _pickSource(context),
            ),
          ],
        );
      },
    );
  }
}

/// İstek sürerken kilitli, ağ hatasında form korunur: ortak hata bandı yerine
/// kısa bir ipucu.
class FieldGap extends StatelessWidget {
  const FieldGap({super.key, this.big = false});

  final bool big;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: big ? AppSpacing.lg : AppSpacing.md);
}

/// Dokunma alanı 48 px olan seçim kartı (radyo davranışı).
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      container: true,
      excludeSemantics: true,
      label: subtitle == null ? title : '$title, $subtitle',
      onTap: onTap,
      child: Material(
        color: selected ? AppColors.selectedSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  if (leading != null) ...[
                    Icon(leading, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.cardTitle),
                        if (subtitle != null)
                          Text(subtitle!, style: AppTypography.bodySecondary),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
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

/// Sayfa iskeleti: başlık + dolgusuz gövde (liste ekranları için).
class ListPage extends StatelessWidget {
  const ListPage({
    super.key,
    required this.title,
    required this.body,
    this.bottom,
    this.leading,
    this.actions,
  });

  final String title;
  final Widget body;
  final Widget? bottom;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: leading,
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: bottom,
              ),
            ),
    );
  }
}
