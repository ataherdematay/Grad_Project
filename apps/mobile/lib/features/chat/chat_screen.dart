import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/guards.dart';
import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/formatters.dart';
import '../../core/photos.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../jobs/job_ui.dart';
import 'chat_session.dart';

/// `/jobs/:id/chat`: ortak ekran. Rolü değiştirmez; geri tuşu sohbete
/// gelinen ekrana döner (NAVIGATION_RULES §2).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final ChatSession _session;
  late final AppLifecycleListener _lifecycle;
  late final PhotoSet _photo;
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _session = ChatSession(
      api: ref.read(apiClientProvider).chat,
      jobId: widget.jobId,
      pollInterval: ref.read(chatPollIntervalProvider),
    );
    _photo = newPhotoSet(ref, MediaPurpose.chat, 1);
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
    _session.addListener(_rebuild);
    _photo.addListener(_rebuild);
    _session.load().then((_) {
      if (mounted) _session.startPolling();
    });
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  /// Arka plana geçince yoklama durur, dönünce hemen yenilenip sürer.
  void _onLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_session.loading) {
          _session.poll();
          _session.startPolling();
        }
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        _session.stopPolling();
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _session
      ..removeListener(_rebuild)
      ..dispose();
    _photo
      ..removeListener(_rebuild)
      ..dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _fallback() {
    final me = ref.read(sessionProvider).me;
    final pro = me != null && isProMode(me);
    return pro ? '/p/jobs/${widget.jobId}' : '/c/jobs/${widget.jobId}';
  }

  bool get _canSend =>
      !_photo.isBusy &&
      !_photo.hasFailed &&
      (_input.text.trim().isNotEmpty || _photo.mediaIds.isNotEmpty);

  Future<void> _pickPhoto() async {
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
    if (source == null) return;
    _photo.clear();
    await _photo.add(source);
  }

  Future<void> _send() async {
    if (!_canSend) return;
    final l = AppLocalizations.of(context);
    final text = _input.text.trim();
    final photoId = _photo.mediaIds.isEmpty ? null : _photo.mediaIds.first;
    final bytes = _photo.items.isEmpty ? null : _photo.items.first.bytes;
    // Alan hemen boşalır; metin geçici baloncukta durur, hata olursa
    // "Tekrar dene" ile yeniden gönderilir.
    _input.clear();
    _photo.clear();
    setState(() {});
    final err = await _session.send(
      text.isEmpty ? l.chatPhotoBody : text,
      photoId: photoId,
      photoBytes: bytes,
    );
    if (err != null && mounted && isStaleStateError(err)) {
      // Sohbet kapanmış (30 gün): geçici baloncuk kalkar, ekran yenilenir.
      for (final p
          in _session.pending.where((p) => identical(p.error, err)).toList()) {
        _session.discard(p);
      }
      reportActionError(
        context,
        err,
        onIllegalState: () => ref.invalidate(jobProvider(widget.jobId)),
      );
    }
  }

  Future<void> _retry(PendingMessage p) async {
    final err = await _session.retry(p);
    if (err != null && mounted && isStaleStateError(err)) {
      _session.discard(p);
      reportActionError(
        context,
        err,
        onIllegalState: () => ref.invalidate(jobProvider(widget.jobId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final jobAsync = ref.watch(jobProvider(widget.jobId));
    final job = jobAsync.value;
    final readOnly = job != null && !job.can(JobAction.chat);
    final now = ref.read(nowProvider)();
    final fallback = _fallback();

    final items = <Object>[..._session.messages, ..._session.pending];
    Widget body;
    if (_session.loading) {
      body = Center(
        child: Semantics(
          label: l.loading,
          child: const CircularProgressIndicator(),
        ),
      );
    } else if (_session.error != null && _session.messages.isEmpty) {
      body = ErrorState(
        title: l.genericErrorTitle,
        message: apiErrorMessage(l, _session.error!.code),
        retryLabel: l.retry,
        onRetry: () => _session.load().then((_) {
          if (mounted) _session.startPolling();
        }),
      );
    } else if (items.isEmpty) {
      body = EmptyState(
        icon: Icons.chat_bubble_outline,
        title: l.chatEmptyTitle,
        message: readOnly ? l.chatReadOnlyBody : l.chatEmptyBody,
      );
    } else {
      final reversed = items.reversed.toList();
      body = ListView.builder(
        controller: _scroll,
        reverse: true,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: reversed.length,
        itemBuilder: (context, i) {
          final item = reversed[i];
          // `reverse` olduğundan sonraki öğe zaman olarak öncedir.
          final older = i + 1 < reversed.length ? reversed[i + 1] : null;
          final showDay =
              _dayOf(item) != (older == null ? null : _dayOf(older));
          final bubble = item is Message
              ? _Bubble(
                  message: item,
                  read:
                      item.mine &&
                      _session.otherLastReadId != null &&
                      item.id <= _session.otherLastReadId!,
                )
              : _PendingBubble(
                  pending: item as PendingMessage,
                  onRetry: () => _retry(item),
                  onDiscard: () => _session.discard(item),
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showDay)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Center(
                    child: Text(
                      formatDay(l, _timeOf(item), now),
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              bubble,
            ],
          );
        },
      );
    }

    return StackFallback(
      fallback: fallback,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: AppBackButton(fallback: fallback),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job?.counterpart.displayName ?? l.chatTitle,
                overflow: TextOverflow.ellipsis,
              ),
              if (job != null)
                Text(
                  job.title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: body),
              if (readOnly)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: MessageBanner(l.chatReadOnlyBody),
                )
              else
                _Composer(
                  controller: _input,
                  photo: _photo,
                  canSend: _canSend,
                  onChanged: () => setState(() {}),
                  onAttach: _pickPhoto,
                  onSend: _send,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static DateTime _timeOf(Object item) =>
      item is Message ? item.createdAt : DateTime.now().toUtc();

  static DateTime? _dayOf(Object item) {
    final t = _timeOf(item).toLocal();
    return DateTime(t.year, t.month, t.day);
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.photo,
    required this.canSend,
    required this.onChanged,
    required this.onAttach,
    required this.onSend,
  });

  final TextEditingController controller;
  final PhotoSet photo;
  final bool canSend;
  final VoidCallback onChanged;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: AppColors.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (photo.items.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: PhotoSetView(set: photo),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (photo.items.isEmpty)
                  AppIconButton(
                    icon: Icons.add_a_photo_outlined,
                    tooltip: l.chatAttachPhoto,
                    onPressed: onAttach,
                  ),
                Expanded(
                  child: Semantics(
                    label: l.chatInputLabel,
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => onChanged(),
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: l.chatInputHint,
                        counterText: '',
                        isDense: true,
                        constraints: const BoxConstraints(
                          minHeight: AppSizes.minTouch,
                        ),
                      ),
                    ),
                  ),
                ),
                AppIconButton(
                  icon: Icons.send,
                  tooltip: l.chatSend,
                  onPressed: canSend ? onSend : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _hm(DateTime utc) => DateFormat('HH:mm').format(utc.toLocal());

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.read});

  final Message message;
  final bool read;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mine = message.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: mine ? AppColors.selectedSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: mine ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.photo != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => Dialog(
                        child: InteractiveViewer(
                          child: MediaImage(
                            message.photo!.url,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    child: MediaImage(
                      message.photo!.url,
                      width: 200,
                      height: 150,
                    ),
                  ),
                ),
              Text(message.body, style: AppTypography.body),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _hm(message.createdAt),
                    style: AppTypography.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 4),
                    Semantics(
                      label: read ? l.chatRead : l.chatSent,
                      child: Icon(
                        read ? Icons.done_all : Icons.done,
                        size: 16,
                        color: read ? AppColors.info : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingBubble extends StatelessWidget {
  const _PendingBubble({
    required this.pending,
    required this.onRetry,
    required this.onDiscard,
  });

  final PendingMessage pending;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Opacity(
          opacity: pending.failed ? 1 : 0.6,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.selectedSurface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: pending.failed ? AppColors.error : AppColors.primary,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pending.photoBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        pending.photoBytes!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.image_outlined),
                      ),
                    ),
                  ),
                Text(pending.body, style: AppTypography.body),
                const SizedBox(height: 2),
                if (!pending.failed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 6),
                      Text(l.chatSending, style: AppTypography.label),
                    ],
                  )
                else ...[
                  Text(
                    pending.error == null
                        ? l.chatSendFailed
                        : '${l.chatSendFailed} ${apiErrorMessage(l, pending.error!.code)}',
                    style: AppTypography.label.copyWith(color: AppColors.error),
                  ),
                  Wrap(
                    children: [
                      TextButton(onPressed: onRetry, child: Text(l.chatRetry)),
                      TextButton(
                        onPressed: onDiscard,
                        child: Text(l.chatDiscard),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `/c/messages` ve `/p/messages`
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key, required this.role});

  final PartyRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(conversationsProvider(role));
    final now = ref.read(nowProvider)();
    final pro = role == PartyRole.pro;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l.tabMessages),
      ),
      body: SafeArea(
        child: AsyncView<List<Conversation>>(
          value: async,
          onRetry: () => ref.invalidate(conversationsProvider(role)),
          builder: (context, list) {
            if (list.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async =>
                    ref.refresh(conversationsProvider(role).future),
                child: LayoutBuilder(
                  builder: (context, c) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: c.maxHeight,
                        child: EmptyState(
                          icon: Icons.chat_bubble_outline,
                          title: l.conversationsEmptyTitle,
                          message: pro
                              ? l.conversationsEmptyBodyPro
                              : l.conversationsEmptyBody,
                          actionLabel: pro
                              ? l.conversationsGoJobs
                              : l.conversationsGoRequests,
                          onAction: () =>
                              context.go(pro ? '/p/jobs' : '/c/requests'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  ref.refresh(conversationsProvider(role).future),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final c = list[i];
                  final last = c.lastMessage;
                  return AppCard(
                    onTap: () async {
                      await context.push('/jobs/${c.jobId}/chat');
                      ref.invalidate(conversationsProvider);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.counterpart.displayName,
                                style: AppTypography.cardTitle,
                              ),
                              Text(
                                '${c.title} · ${c.publicCode}',
                                style: AppTypography.bodySecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                last == null
                                    ? l.conversationNoMessages
                                    : (last.mine
                                          ? '${l.actorYou}: ${last.body}'
                                          : last.body),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: c.unreadCount > 0
                                    ? AppTypography.cardTitle
                                    : AppTypography.body,
                              ),
                              if (last != null)
                                Text(
                                  formatDayTime(l, last.createdAt, now),
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.xs),
                              jobStatusChip(l, c.jobStatus, role),
                            ],
                          ),
                        ),
                        if (c.unreadCount > 0)
                          Semantics(
                            label: l.unreadMessages(c.unreadCount),
                            child: Badge(label: Text('${c.unreadCount}')),
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
    );
  }
}
