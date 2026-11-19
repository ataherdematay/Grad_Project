import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/action_dialog.dart';
import '../common/labels.dart';
import '../common/widgets.dart';

/// Hesaplar: arama, rol ve durum süzgeci; askıya alma ve yeniden aktifleştirme.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  UsersQuery _query = const UsersQuery();
  bool _busy = false;
  int _activeJobCount = 0;

  AdminApi get _api => ref.read(apiClientProvider).admin;

  void _reload() => ref.invalidate(usersProvider(_query));

  Future<void> _run(
    Future<DialogOutcome?> Function() action,
    String Function() doneText,
  ) async {
    if (_busy) return;
    final outcome = await action();
    if (!mounted) return;
    switch (outcome) {
      case DialogOutcome.done:
        _reload();
        showNotice(context, doneText());
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

  Future<void> _suspend(AdminUser u) {
    final l = AppLocalizations.of(context);
    _activeJobCount = 0;
    return _run(
      () => showActionDialog(
        context,
        title: l.suspendAccountTitle(u.fullName),
        intro: l.suspendAccountMessage,
        noteLabel: l.suspendNoteLabel,
        minLength: 10,
        maxLength: 1000,
        confirmLabel: l.suspend,
        destructive: true,
        onSubmit: (note) => _track(() async {
          final result = await _api.suspendUser(u.id, note);
          _activeJobCount = result.activeJobCount;
        }),
      ),
      () => _activeJobCount > 0
          ? l.suspendedWithJobsNotice(_activeJobCount)
          : l.suspendedNotice,
    );
  }

  Future<void> _reactivate(AdminUser u) {
    final l = AppLocalizations.of(context);
    // Hesap etkin, yalnız usta profili askıda (şikayet kararı): aynı uç nokta
    // profili yeniden doğrulanmış duruma döndürür.
    final proOnly =
        u.status == AccountStatus.active &&
        u.pro?.reviewStatus == ReviewStatus.suspended;
    return _run(
      () => confirmAndRun(
        context,
        title: proOnly
            ? l.reactivateProTitle(u.pro!.businessName)
            : l.reactivateTitle(u.fullName),
        message: proOnly ? l.reactivateProMessage : l.reactivateMessage,
        confirmLabel: l.reactivate,
        run: () => _track(() => _api.reactivateUser(u.id)),
      ),
      () => proOnly ? l.proReactivatedNotice : l.reactivatedNotice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nowProvider)();
    final myId = ref.watch(sessionProvider.select((s) => s.me?.id));
    final value = ref.watch(usersProvider(_query));
    return PageScroll(
      title: l.accountsTitle,
      subtitle: l.accountsSubtitle,
      children: [
        SearchField(
          label: l.search,
          hint: l.accountsSearchHint,
          onChanged: (q) => setState(() => _query = _query.copyWith(q: q)),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          children: [
            FilterRow<AccountRole?>(
              label: l.filterRole,
              selected: _query.role,
              options: [
                (null, l.filterAll),
                for (final r in AccountRole.values) (r, accountRoleLabel(l, r)),
              ],
              onSelected: (r) =>
                  setState(() => _query = _query.copyWith(role: () => r)),
            ),
            FilterRow<AccountStatus?>(
              label: l.filterStatus,
              selected: _query.status,
              options: [
                (null, l.filterAll),
                for (final s in AccountStatus.values)
                  (s, accountStatusLabel(l, s)),
              ],
              onSelected: (s) =>
                  setState(() => _query = _query.copyWith(status: () => s)),
            ),
            _DistrictFilter(
              selected: _query.districtId,
              onSelected: (d) =>
                  setState(() => _query = _query.copyWith(districtId: () => d)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AsyncBody(
          value: value,
          onRetry: _reload,
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                title: l.accountsEmptyTitle,
                message: l.accountsEmptyMessage,
                icon: Icons.people_outline,
              );
            }
            return ResponsiveTable<AdminUser>(
              // 880 altında kartlar: işlem sütunu hiç kırpılmaz.
              stackBelow: 880,
              rowKey: (u) => Key('user-${u.id}'),
              columns: [
                TableColumn(
                  header: l.colAccount,
                  flex: 4,
                  cell: (u) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.fullName, style: AppTypography.cardTitle),
                      Text(u.email, style: AppTypography.bodySecondary),
                      if (u.phone != null)
                        Text(u.phone!, style: AppTypography.bodySecondary),
                    ],
                  ),
                ),
                TableColumn(
                  header: l.colRole,
                  flex: 3,
                  cell: (u) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.isAdmin
                            ? l.roleAdmin
                            : u.pro != null
                            ? l.rolePro
                            : l.roleCustomer,
                        style: AppTypography.body,
                      ),
                      if (u.pro != null)
                        Text(
                          l.proRoleLine(
                            u.pro!.businessName,
                            reviewStatusLabel(l, u.pro!.reviewStatus),
                          ),
                          style: AppTypography.bodySecondary,
                        ),
                    ],
                  ),
                ),
                TableColumn(
                  header: l.colStatus,
                  flex: 2,
                  cell: (u) => accountStatusChip(l, u.status),
                ),
                TableColumn(
                  header: l.colRegistered,
                  flex: 2,
                  cell: (u) => Text(formatDate(u.createdAt, l.localeName, now)),
                ),
                TableColumn(
                  header: l.colActions,
                  flex: 3,
                  cell: (u) => _ActionCell(
                    user: u,
                    isSelf: u.id == myId,
                    busy: _busy,
                    onSuspend: () => _suspend(u),
                    onReactivate: () => _reactivate(u),
                  ),
                ),
              ],
              rows: items,
            );
          },
        ),
      ],
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({
    required this.user,
    required this.isSelf,
    required this.busy,
    required this.onSuspend,
    required this.onReactivate,
  });

  final AdminUser user;
  final bool isSelf;
  final bool busy;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (user.status) {
      case AccountStatus.deleted:
        return const Text('-');
      case AccountStatus.suspended:
        return AppButton(
          key: Key('reactivate-${user.id}'),
          label: l.reactivate,
          variant: AppButtonVariant.secondary,
          expand: false,
          onPressed: busy ? null : onReactivate,
        );
      case AccountStatus.active:
        // Kendi hesabın ve yönetici hesapları askıya alınamaz.
        final blocked = isSelf || user.isAdmin;
        final button = AppButton(
          key: Key('suspend-${user.id}'),
          label: l.suspend,
          variant: AppButtonVariant.secondary,
          expand: false,
          onPressed: busy || blocked ? null : onSuspend,
        );
        // Yalnız usta profili askıda: profil buradan geri açılabilir.
        if (!blocked && user.pro?.reviewStatus == ReviewStatus.suspended) {
          return Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                key: Key('reactivate-pro-${user.id}'),
                label: l.reactivatePro,
                variant: AppButtonVariant.secondary,
                expand: false,
                onPressed: busy ? null : onReactivate,
              ),
              button,
            ],
          );
        }
        if (!blocked) return button;
        return Tooltip(
          message: isSelf ? l.cannotSuspendSelf : l.cannotSuspendAdmin,
          child: button,
        );
    }
  }
}

/// İlçe süzgeci (açılır liste). İlçeler yüklenemezse süzgeç gösterilmez.
class _DistrictFilter extends ConsumerWidget {
  const _DistrictFilter({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final districts = ref.watch(districtsProvider).asData?.value;
    if (districts == null || districts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: 240,
      child: DropdownButtonFormField<String?>(
        key: const Key('district-filter'),
        initialValue: selected,
        decoration: InputDecoration(labelText: l.filterDistrict),
        items: [
          DropdownMenuItem<String?>(child: Text(l.filterAll)),
          for (final d in districts)
            DropdownMenuItem<String?>(value: d.id, child: Text(d.name)),
        ],
        onChanged: onSelected,
      ),
    );
  }
}
