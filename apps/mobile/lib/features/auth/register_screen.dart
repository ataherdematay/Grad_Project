import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/error_messages.dart';
import '../../core/forms.dart';
import '../../l10n/app_localizations.dart';
import '../common/widgets.dart';
import 'session.dart';

enum SignupRole { customer, pro }

/// Kayıt. Rol seçimi varsayılansızdır. Usta kayıt sonrası `/p/apply`,
/// müşteri `/c/home` açar (yönlendirmeyi router yapar).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.next});

  final String? next;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _fieldErrors = <String, String>{};
  SignupRole? _role;
  bool _kvkk = false;
  bool _terms = false;
  String? _generalError;
  bool _loading = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearFieldError(String key) {
    if (_fieldErrors.containsKey(key)) {
      setState(() => _fieldErrors.remove(key));
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _generalError = null;
      _fieldErrors.clear();
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ref
          .read(sessionProvider.notifier)
          .register(
            RegisterRequest(
              fullName: _name.text.trim(),
              email: _email.text.trim(),
              phone: normalizePhone(_phone.text),
              password: _password.text,
              wantsPro: _role == SignupRole.pro,
              kvkkAccepted: _kvkk,
              termsAccepted: _terms,
            ),
          );
    } on AdminAccountException {
      if (mounted) setState(() => _generalError = l.noticeAdmin);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        const known = {
          'fullName',
          'email',
          'phone',
          'password',
          'kvkkAccepted',
          'termsAccepted',
          'wantsPro',
        };
        if (e.field != null && known.contains(e.field)) {
          _fieldErrors[e.field!] = apiFieldMessage(l, e);
        } else {
          _generalError = apiErrorMessage(l, e.code);
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = Validators(l);
    return PageScaffold(
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidate,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.registerTitle, style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(l.registerIntro, style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.lg),
              Text(l.roleSectionTitle, style: AppTypography.section),
              const SizedBox(height: AppSpacing.sm),
              FormField<SignupRole>(
                validator: (_) => _role == null ? l.errRoleRequired : null,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RoleOption(
                      title: l.roleCustomer,
                      description: l.roleCustomerDesc,
                      icon: Icons.home_repair_service_outlined,
                      selected: _role == SignupRole.customer,
                      enabled: !_loading,
                      onTap: () {
                        setState(() => _role = SignupRole.customer);
                        state.didChange(SignupRole.customer);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _RoleOption(
                      title: l.rolePro,
                      description: l.roleProDesc,
                      icon: Icons.construction_outlined,
                      selected: _role == SignupRole.pro,
                      enabled: !_loading,
                      onTap: () {
                        setState(() => _role = SignupRole.pro);
                        state.didChange(SignupRole.pro);
                      },
                    ),
                    if (state.hasError || _fieldErrors['wantsPro'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          state.errorText ?? _fieldErrors['wantsPro']!,
                          style: AppTypography.label.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l.fieldFullName,
                hintText: l.hintFullName,
                controller: _name,
                enabled: !_loading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: v.fullName,
                errorText: _fieldErrors['fullName'],
                onChanged: (_) => _clearFieldError('fullName'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldEmail,
                hintText: l.hintEmail,
                controller: _email,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: v.email,
                errorText: _fieldErrors['email'],
                onChanged: (_) => _clearFieldError('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldPhone,
                hintText: l.hintPhone,
                controller: _phone,
                enabled: !_loading,
                prefixText: '+90 ',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: [TrPhoneFormatter()],
                validator: v.phone,
                errorText: _fieldErrors['phone'],
                onChanged: (_) => _clearFieldError('phone'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l.fieldPassword,
                controller: _password,
                enabled: !_loading,
                isPassword: true,
                showPasswordTooltip: l.showPassword,
                hidePasswordTooltip: l.hidePassword,
                helperText: l.helperPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: v.newPassword,
                errorText: _fieldErrors['password'],
                onChanged: (_) => _clearFieldError('password'),
              ),
              const SizedBox(height: AppSpacing.md),
              _ConsentField(
                key: const Key('consent-kvkk'),
                label: l.consentKvkk,
                readLabel: l.consentKvkkRead,
                value: _kvkk,
                enabled: !_loading,
                requiredMessage: l.errConsentRequired,
                serverError: _fieldErrors['kvkkAccepted'],
                onChanged: (v) => setState(() {
                  _kvkk = v;
                  _fieldErrors.remove('kvkkAccepted');
                }),
                onRead: () => context.push('/legal/kvkk'),
              ),
              _ConsentField(
                key: const Key('consent-terms'),
                label: l.consentTerms,
                readLabel: l.consentTermsRead,
                value: _terms,
                enabled: !_loading,
                requiredMessage: l.errConsentRequired,
                serverError: _fieldErrors['termsAccepted'],
                onChanged: (v) => setState(() {
                  _terms = v;
                  _fieldErrors.remove('termsAccepted');
                }),
                onRead: () => context.push('/legal/terms'),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_generalError != null) ...[
                MessageBanner(_generalError!),
                const SizedBox(height: AppSpacing.md),
              ],
              AppButton(
                label: l.registerTitle,
                isLoading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.registerHaveAccount,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
              AppButton(
                label: l.actionLogin,
                variant: AppButtonVariant.tertiary,
                onPressed: () =>
                    context.pushReplacement(withNext('/login', widget.next)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      label: '$title. $description',
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Material(
        color: selected ? const Color(0xFFE3EEF0) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTypography.cardTitle),
                        const SizedBox(height: 2),
                        Text(description, style: AppTypography.bodySecondary),
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

class _ConsentField extends StatelessWidget {
  const _ConsentField({
    super.key,
    required this.label,
    required this.readLabel,
    required this.value,
    required this.enabled,
    required this.requiredMessage,
    required this.onChanged,
    required this.onRead,
    this.serverError,
  });

  final String label;
  final String readLabel;
  final bool value;
  final bool enabled;
  final String requiredMessage;
  final String? serverError;
  final ValueChanged<bool> onChanged;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      validator: (_) => value ? null : requiredMessage,
      builder: (state) {
        final error = serverError ?? state.errorText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: enabled
                  ? () {
                      onChanged(!value);
                      state.didChange(!value);
                    }
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
                child: Row(
                  children: [
                    Semantics(
                      checked: value,
                      label: label,
                      excludeSemantics: true,
                      child: Checkbox(
                        value: value,
                        onChanged: enabled
                            ? (v) {
                                onChanged(v ?? false);
                                state.didChange(v ?? false);
                              }
                            : null,
                      ),
                    ),
                    Expanded(child: Text(label, style: AppTypography.body)),
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                label: readLabel,
                variant: AppButtonVariant.tertiary,
                expand: false,
                onPressed: onRead,
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  error,
                  style: AppTypography.label.copyWith(color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }
}
