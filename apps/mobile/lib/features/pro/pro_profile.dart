import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/data.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../common/pickers.dart';
import '../../core/error_messages.dart';
import '../common/ui.dart';
import '../common/widgets.dart';

class _Hours {
  _Hours({
    this.on = false,
    this.start = const TimeOfDay(hour: 9, minute: 0),
    this.end = const TimeOfDay(hour: 18, minute: 0),
    this.urgent = false,
  });

  bool on;
  TimeOfDay start;
  TimeOfDay end;
  bool urgent;

  bool get valid =>
      !on || end.hour * 60 + end.minute > start.hour * 60 + start.minute;
}

String _fmt(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay _parse(String s) {
  final p = s.split(':');
  return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
}

/// `/p/profile`: Aktif / Mola, kategoriler, ilçeler, çalışma saatleri, yazı.
class ProProfileScreen extends ConsumerStatefulWidget {
  const ProProfileScreen({super.key});

  @override
  ConsumerState<ProProfileScreen> createState() => _ProProfileState();
}

class _ProProfileState extends ConsumerState<ProProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _years = TextEditingController();
  Set<String> _cats = {};
  Set<String> _districts = {};
  final Map<int, _Hours> _hours = {for (var d = 1; d <= 7; d++) d: _Hours()};
  bool _loaded = false;
  bool _saving = false;
  bool _togglingAvail = false;
  bool _switching = false;
  bool _attempted = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _years.dispose();
    super.dispose();
  }

  void _fill(ProProfile p) {
    if (_loaded) return;
    _loaded = true;
    _name.text = p.businessName;
    _bio.text = p.bio;
    _years.text = '${p.experienceYears}';
    _cats = {...p.categoryIds};
    _districts = {...p.districtIds};
    for (final w in p.workingHours) {
      _hours[w.weekday] = _Hours(
        on: true,
        start: _parse(w.start),
        end: _parse(w.end),
        urgent: w.acceptsUrgent,
      );
    }
  }

  Future<void> _setAvailability(bool active) async {
    if (_togglingAvail) return;
    setState(() => _togglingAvail = true);
    try {
      await ref
          .read(apiClientProvider)
          .pro
          .setAvailability(
            active ? ProAvailability.active : ProAvailability.onBreak,
          );
      invalidateProData(ref);
      await ref.read(sessionProvider.notifier).refreshMe();
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateProData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingAvail = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final l = AppLocalizations.of(context);
    setState(() => _attempted = true);
    final years = int.tryParse(_years.text.trim());
    final nameLen = _name.text.trim().length;
    if (nameLen < 2 ||
        years == null ||
        years > 60 ||
        _cats.isEmpty ||
        _districts.isEmpty ||
        _hours.values.any((h) => !h.valid)) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(apiClientProvider)
          .pro
          .updateProfile(
            ProProfileInput(
              businessName: _name.text.trim(),
              bio: _bio.text.trim(),
              experienceYears: years,
              categoryIds: _cats.toList(),
              districtIds: _districts.toList(),
              workingHours: [
                for (final e in _hours.entries)
                  if (e.value.on)
                    WorkingHours(
                      weekday: e.key,
                      start: _fmt(e.value.start),
                      end: _fmt(e.value.end),
                      acceptsUrgent: e.value.urgent,
                    ),
              ],
            ),
          );
      invalidateProData(ref);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l.profileSaved)));
      }
    } on ApiException catch (e) {
      if (mounted) {
        reportActionError(
          context,
          e,
          onIllegalState: () => invalidateProData(ref),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toCustomer() async {
    if (_switching) return;
    final router = GoRouter.of(context);
    setState(() => _switching = true);
    try {
      await ref.read(sessionProvider.notifier).switchMode(UserMode.customer);
      router.go('/c/home');
    } on ApiException catch (e) {
      if (mounted) reportActionError(context, e);
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  Future<void> _pickTime(_Hours h, bool start) async {
    final t = await showTimePicker(
      context: context,
      initialTime: start ? h.start : h.end,
    );
    if (t != null) {
      setState(() {
        if (start) {
          h.start = t;
        } else {
          h.end = t;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(proProfileProvider);
    final me = ref.watch(sessionProvider.select((s) => s.me));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l.tabProfile),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (me != null)
                  Text(me.fullName, style: AppTypography.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                ..._editor(l, async),
                const SizedBox(height: AppSpacing.md),
                // Profil yüklenemese bile çıkış yolları açık kalır.
                AppButton(
                  label: l.profileSettings,
                  icon: Icons.settings_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/settings'),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.earningsTitle,
                  icon: Icons.payments_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/p/earnings'),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.myOffersTitle,
                  icon: Icons.local_offer_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/p/offers'),
                ),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: l.switchToCustomer,
                  icon: Icons.swap_horiz,
                  variant: AppButtonVariant.secondary,
                  isLoading: _switching,
                  onPressed: _toCustomer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _editor(AppLocalizations l, AsyncValue<ProProfile> async) {
    if (!async.hasValue) {
      if (async.hasError) {
        final e = async.error;
        return [
          MessageBanner(
            e is ApiException ? apiErrorMessage(l, e.code) : l.apiErrorUnknown,
          ),
          AppButton(
            label: l.retry,
            variant: AppButtonVariant.tertiary,
            onPressed: () => ref.invalidate(proProfileProvider),
          ),
        ];
      }
      return [const Center(child: CircularProgressIndicator())];
    }
    final p = async.requireValue;
    _fill(p);
    final active = p.availability == ProAvailability.active;
    final years = int.tryParse(_years.text.trim());
    return [
      AppCard(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            active ? l.availabilityActive : l.availabilityBreak,
            style: AppTypography.cardTitle,
          ),
          subtitle: Text(
            active ? l.availabilityActiveHelp : l.availabilityBreakHelp,
          ),
          value: active,
          onChanged: _togglingAvail ? null : _setAvailability,
        ),
      ),
      sectionTitle(l.profileEditTitle),
      AppTextField(
        label: l.applyBusinessName,
        controller: _name,
        enabled: !_saving,
        maxLength: 100,
        errorText: _attempted && _name.text.trim().length < 2
            ? l.applyBusinessNameInvalid
            : null,
        onChanged: (_) => setState(() {}),
      ),
      const FieldGap(),
      AppTextField(
        label: l.profileBio,
        controller: _bio,
        enabled: !_saving,
        maxLength: 1000,
        keyboardType: TextInputType.multiline,
        minLines: 3,
      ),
      const FieldGap(),
      AppTextField(
        label: l.applyExperience,
        controller: _years,
        enabled: !_saving,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        errorText: _attempted && (years == null || years > 60)
            ? l.applyExperienceInvalid
            : null,
        onChanged: (_) => setState(() {}),
      ),
      const FieldGap(),
      CategoryMultiPicker(
        label: l.applyCategories,
        selected: _cats,
        errorText: _attempted && _cats.isEmpty ? l.errRequired : null,
        onChanged: (s) => setState(() => _cats = s),
      ),
      const FieldGap(),
      DistrictPicker(
        label: l.applyDistricts,
        multi: true,
        selected: _districts,
        errorText: _attempted && _districts.isEmpty ? l.errRequired : null,
        onChanged: (s) => setState(() => _districts = s),
      ),
      sectionTitle(l.workingHours),
      for (var d = 1; d <= 7; d++) _dayRow(l, d),
      const FieldGap(big: true),
      AppButton(label: l.save, isLoading: _saving, onPressed: _save),
    ];
  }

  Widget _dayRow(AppLocalizations l, int d) {
    final h = _hours[d]!;
    final name = DateFormat.EEEE(l.localeName).format(DateTime(2024, 1, d));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(name),
          value: h.on,
          onChanged: _saving ? null : (v) => setState(() => h.on = v),
        ),
        if (h.on)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => _pickTime(h, true),
                        child: Text('${l.hoursFrom} ${_fmt(h.start)}'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => _pickTime(h, false),
                        child: Text('${l.hoursTo} ${_fmt(h.end)}'),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l.hoursAcceptsUrgent),
                  value: h.urgent,
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => h.urgent = v ?? false),
                ),
                if (_attempted && !h.valid)
                  Text(
                    l.hoursInvalid,
                    style: AppTypography.label.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
