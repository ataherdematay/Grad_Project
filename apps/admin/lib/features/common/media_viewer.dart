import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// Küçük önizleme. Sunucu medya türünü bildirmediğinden görsel olarak
/// çözülemeyen dosya (PDF) için dosya simgesi çizilir.
class MediaThumbnail extends StatelessWidget {
  const MediaThumbnail({super.key, required this.media, this.height = 120});

  final MediaRef media;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.neutralSurface,
        child: Image.network(
          media.url,
          fit: BoxFit.cover,
          semanticLabel: l.documentPreview,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorBuilder: (context, error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.previewUnavailable,
                      textAlign: TextAlign.center,
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Görseli büyütür; PDF gibi görselleştirilemeyenler için yeni sekmede açma.
Future<void> showMediaViewer(
  BuildContext context,
  MediaRef media,
  String title,
) => showDialog<void>(
  context: context,
  builder: (_) => _MediaViewerDialog(media: media, title: title),
);

class _MediaViewerDialog extends ConsumerWidget {
  const _MediaViewerDialog({required this.media, required this.title});

  final MediaRef media;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Dialog(
      key: const Key('media-viewer'),
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: AppTypography.section)),
                  AppIconButton(
                    icon: Icons.close,
                    tooltip: l.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Flexible(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Image.network(
                    media.url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          l.previewUnavailable,
                          style: AppTypography.bodySecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => ref.read(urlOpenerProvider)(media.url),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.openInNewTab),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
