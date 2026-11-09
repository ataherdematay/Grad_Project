import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/pickers.dart';
import '../common/ui.dart';
import '../common/widgets.dart';

/// Adres ekleme/düzenleme formu. Kaydedince oluşan/güncellenen adresi
/// [onSaved] ile verir. Ağ hatasında alanlar korunur.
class AddressForm extends ConsumerStatefulWidget {
  const AddressForm({
    super.key,
    this.initial,
    required this.onSaved,
    this.onCancel,
    this.forceDefault = false,
  });

  final Address? initial;
  final ValueChanged<Address> onSaved;
  final VoidCallback? onCancel;
  final bool forceDefault;

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.initial?.label);
  late final _neighborhood = TextEditingController(
    text: widget.initial?.neighborhood,
  );
  late final _line = TextEditingController(text: widget.initial?.lineFull);
  late final _door = TextEditingController(text: widget.initial?.doorNote);
  late String? _districtId = widget.initial?.districtId;
  late bool _default = widget.initial?.isDefault ?? false;
  bool _districtError = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    _neighborhood.dispose();
    _line.dispose();
    _door.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_loading) return;
    final valid = _formKey.currentState!.validate();
    setState(() => _districtError = _districtId == null);
    if (!valid || _districtId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    final api = ref.read(apiClientProvider).me;
    final body = AddressInput(
      label: _label.text.trim(),
      districtId: _districtId!,
      neighborhood: _neighborhood.text.trim(),
      lineFull: _line.text.trim(),
      // Düzenlemede boş metin notu temizler.
      doorNote: widget.initial == null
          ? (_door.text.trim().isEmpty ? null : _door.text.trim())
          : _door.text.trim(),
      isDefault: (_default || widget.forceDefault) ? true : null,
    );
    try {
      final saved = widget.initial == null
          ? await api.createAddress(body)
          : await api.updateAddress(widget.initial!.id, body);
      ref.invalidate(addressesProvider);
      if (mounted) widget.onSaved(saved);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(l, e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = Validators(l);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l.addressLabelField,
            hintText: l.addressLabelHint,
            controller: _label,
            enabled: !_loading,
            maxLength: 40,
            textInputAction: TextInputAction.next,
            validator: v.required,
          ),
          const FieldGap(),
          DistrictPicker(
            label: l.addressDistrict,
            selected: {?_districtId},
            errorText: _districtError ? l.errRequired : null,
            onChanged: (s) => setState(() {
              _districtId = s.isEmpty ? null : s.first;
              _districtError = false;
            }),
          ),
          const FieldGap(),
          AppTextField(
            label: l.addressNeighborhood,
            controller: _neighborhood,
            enabled: !_loading,
            maxLength: 120,
            textInputAction: TextInputAction.next,
            validator: v.required,
          ),
          const FieldGap(),
          AppTextField(
            label: l.addressLine,
            hintText: l.addressLineHint,
            controller: _line,
            enabled: !_loading,
            maxLength: 500,
            textInputAction: TextInputAction.next,
            validator: v.required,
          ),
          const FieldGap(),
          AppTextField(
            label: l.addressDoorNote,
            controller: _door,
            enabled: !_loading,
            maxLength: 300,
            helperText: l.addressDoorNoteHelp,
          ),
          if (!widget.forceDefault)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.addressMakeDefault),
              value: _default,
              onChanged: _loading ? null : (x) => setState(() => _default = x),
            ),
          if (_error != null) ...[const FieldGap(), MessageBanner(_error!)],
          const FieldGap(),
          AppButton(label: l.save, isLoading: _loading, onPressed: _save),
          if (widget.onCancel != null)
            AppButton(
              label: l.cancel,
              variant: AppButtonVariant.tertiary,
              onPressed: _loading ? null : widget.onCancel,
            ),
        ],
      ),
    );
  }
}

/// `/c/addresses`: liste, ekle, düzenle, sil, varsayılan yap.
class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  bool _busy = false;

  Future<void> _edit([Address? a]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AddressForm(
            initial: a,
            onSaved: (_) => Navigator.pop(ctx),
            onCancel: () => Navigator.pop(ctx),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(Address a) async {
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.addressDeleteTitle,
      message: l.addressDeleteMessage(a.label),
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _run(() => ref.read(apiClientProvider).me.deleteAddress(a.id));
  }

  Future<void> _makeDefault(Address a) => _run(
    () => ref
        .read(apiClientProvider)
        .me
        .updateAddress(
          a.id,
          AddressInput(
            label: a.label,
            districtId: a.districtId,
            neighborhood: a.neighborhood,
            lineFull: a.lineFull,
            isDefault: true,
          ),
        ),
  );

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(addressesProvider);
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => ref.invalidate(addressesProvider),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(addressesProvider);
    return ListPage(
      title: l.addressesTitle,
      leading: const AppBackButton(fallback: '/c/profile'),
      bottom: AppButton(
        label: l.addressAdd,
        icon: Icons.add,
        onPressed: _busy ? null : () => _edit(),
      ),
      body: AsyncView<List<Address>>(
        value: async,
        onRetry: () => ref.invalidate(addressesProvider),
        builder: (context, list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.home_outlined,
              title: l.addressesEmptyTitle,
              message: l.addressesEmptyBody,
              actionLabel: l.addressAdd,
              onAction: () => _edit(),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(addressesProvider.future),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final a = list[i];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(a.label, style: AppTypography.cardTitle),
                          if (a.isDefault)
                            StatusChip(
                              label: l.addressDefault,
                              icon: Icons.check,
                              tone: StatusTone.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${a.districtName}, ${a.neighborhood}',
                        style: AppTypography.bodySecondary,
                      ),
                      Text(a.lineFull, style: AppTypography.body),
                      if ((a.doorNote ?? '').isNotEmpty)
                        Text(a.doorNote!, style: AppTypography.bodySecondary),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: [
                          AppButton(
                            label: l.edit,
                            expand: false,
                            variant: AppButtonVariant.tertiary,
                            onPressed: _busy ? null : () => _edit(a),
                          ),
                          if (!a.isDefault)
                            AppButton(
                              label: l.addressMakeDefault,
                              expand: false,
                              variant: AppButtonVariant.tertiary,
                              onPressed: _busy ? null : () => _makeDefault(a),
                            ),
                          AppButton(
                            label: l.delete,
                            expand: false,
                            variant: AppButtonVariant.tertiary,
                            onPressed: _busy ? null : () => _delete(a),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
