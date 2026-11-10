import 'dart:async';

import 'package:bitadilat_api/bitadilat_api.dart';
import 'package:bitadilat_ui/bitadilat_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../core/error_messages.dart';
import '../../core/formatters.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/ui.dart';
import '../common/widgets.dart';
import '../jobs/job_ui.dart';
import 'card_validation.dart';
import 'threeds_logic.dart';

/// "Test kartını doldur" yalnızca debug derlemesinde görünür.
final showTestCardProvider = Provider<bool>((ref) => kDebugMode);

/// Sonuç ekranının yoklama aralıkları (saniye); toplamı 30.
const List<int> kPaymentPollSeconds = [1, 2, 3, 4, 5, 5, 5, 5];

// --- 18: Kabul onayı ---------------------------------------------------------

/// `/c/offers/:id/accept`
class AcceptOfferScreen extends ConsumerWidget {
  const AcceptOfferScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(offerProvider(id));
    return ListPage(
      title: l.acceptTitle,
      leading: AppBackButton(fallback: '/c/offers/$id'),
      body: AsyncView<OfferDetail>(
        value: async,
        onRetry: () => ref.invalidate(offerProvider(id)),
        builder: (context, o) => _AcceptBody(o: o),
      ),
    );
  }
}

class _AcceptBody extends ConsumerWidget {
  const _AcceptBody({required this.o});

  final OfferDetail o;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    String m(Money v) => formatMoney(v, l.localeName);
    final available =
        o.status == OfferStatus.pending && o.validUntil.isAfter(now);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(l.acceptIntro(o.pro.businessName), style: AppTypography.body),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.offerBreakdown, style: AppTypography.cardTitle),
              const SizedBox(height: 4),
              InfoRow(l.labor, m(o.laborAmount)),
              InfoRow(l.materials, m(o.materialsAmount)),
              const Divider(),
              InfoRow(l.totalVatIncluded, m(o.totalAmount), bold: true),
              const SizedBox(height: 4),
              Text(l.acceptVatNote, style: AppTypography.bodySecondary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l.escrowHowTitle,
                      style: AppTypography.cardTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.escrowHowBody, style: AppTypography.body),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_busy_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l.cancelPolicyTitle,
                      style: AppTypography.cardTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.cancelPolicyBody, style: AppTypography.body),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!available) ...[
          MessageBanner(l.acceptUnavailable),
          const SizedBox(height: AppSpacing.sm),
        ],
        AppButton(
          label: l.acceptContinue(m(o.totalAmount)),
          onPressed: available
              ? () => context.push('/c/offers/${o.id}/pay')
              : null,
        ),
        AppButton(
          label: l.acceptBack,
          variant: AppButtonVariant.tertiary,
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/c/offers/${o.id}'),
        ),
      ],
    );
  }
}

// --- 19: Kart bilgileri ------------------------------------------------------

String cardErrorText(AppLocalizations l, CardError e) => switch (e) {
  CardError.holderInvalid => l.cardErrHolder,
  CardError.numberInvalid => l.cardErrNumber,
  CardError.expiryInvalid => l.cardErrExpiry,
  CardError.expiryPast => l.cardErrExpiryPast,
  CardError.cvcInvalid => l.cardErrCvc,
};

/// Sunucunun `field` değeri için alan altı metni.
String cardServerFieldText(AppLocalizations l, CardField f) => switch (f) {
  CardField.holderName => l.cardErrHolder,
  CardField.number => l.cardErrNumber,
  CardField.expiry => l.cardErrExpiry,
  CardField.cvc => l.cardErrCvc,
};

/// `/c/offers/:id/pay`
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key, required this.offerId});

  final String offerId;

  @override
  ConsumerState<PayScreen> createState() => _PayState();
}

class _PayState extends ConsumerState<PayScreen> {
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  Map<CardField, String> _errors = {};
  String? _banner;
  bool _loading = false;

  @override
  void dispose() {
    _clearFields();
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvc.dispose();
    super.dispose();
  }

  /// Kart verisi ekranda kalmaz.
  void _clearFields() {
    _holder.clear();
    _number.clear();
    _expiry.clear();
    _cvc.clear();
  }

  void _fillTestCard() {
    setState(() {
      _errors = {};
      _banner = null;
      _holder.text = kTestCardHolder;
      _number.text = kTestCardNumber;
      _expiry.text = kTestCardExpiry;
      _cvc.text = kTestCardCvc;
    });
  }

  void _clearError(CardField f) {
    if (_errors.containsKey(f)) {
      setState(() => _errors = {..._errors}..remove(f));
    }
  }

  Future<void> _submit(OfferDetail offer) async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    final now = ref.read(nowProvider)();
    final local = validateCard(
      holderName: _holder.text,
      number: _number.text,
      expiry: _expiry.text,
      cvc: _cvc.text,
      now: now,
    );
    if (local.isNotEmpty) {
      setState(() {
        _banner = null;
        _errors = {
          for (final e in local.entries) e.key: cardErrorText(l, e.value),
        };
      });
      return;
    }
    final exp = parseExpiry(_expiry.text)!;
    final request = CardPaymentRequest(
      offerId: offer.id,
      // Her denemede yeni anahtar: aynı anahtar sunucuda DUPLICATE_ATTEMPT olur.
      attemptKey: newIdempotencyKey(),
      cardHolderName: _holder.text.trim(),
      cardNumber: digitsOfCard(_number.text),
      expireMonth: exp.month.toString().padLeft(2, '0'),
      expireYear: exp.year.toString(),
      cvc: digitsOfCard(_cvc.text),
    );
    setState(() {
      _loading = true;
      _banner = null;
      _errors = {};
    });
    final router = GoRouter.of(context);
    try {
      final init = await ref.read(apiClientProvider).payments.init3ds(request);
      if (!mounted) return;
      _clearFields();
      // Kart formu yığından çıkar; geri tuşu forma dönmez.
      router.pushReplacement(
        '/c/payments/${init.ref}/3ds',
        extra: init.htmlContent,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == ApiErrorCode.paymentDeclined && e.ref != null) {
        _clearFields();
        router.pushReplacement('/c/payments/${e.ref}/result');
        return;
      }
      final field = e.code == ApiErrorCode.invalidCard
          ? cardFieldFromServer(e.field)
          : null;
      setState(() {
        if (field != null) {
          _errors = {field: cardServerFieldText(l, field)};
        } else {
          _banner = apiErrorMessage(l, e.code);
        }
      });
      if (isStaleStateError(e)) invalidateRequestData(ref);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(offerProvider(widget.offerId));
    final showTest = ref.watch(showTestCardProvider);
    return ListPage(
      title: l.payTitle,
      leading: AppBackButton(fallback: '/c/offers/${widget.offerId}'),
      body: AsyncView<OfferDetail>(
        value: async,
        onRetry: () => ref.invalidate(offerProvider(widget.offerId)),
        builder: (context, o) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(l.payTo, o.pro.businessName),
                    InfoRow(
                      l.payAmount,
                      formatMoney(o.totalAmount, l.localeName),
                      bold: true,
                    ),
                    Text(l.acceptVatNote, style: AppTypography.bodySecondary),
                  ],
                ),
              ),
              const FieldGap(),
              if (showTest) ...[
                AppButton(
                  label: l.payFillTestCard,
                  icon: Icons.bug_report_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: _loading ? null : _fillTestCard,
                ),
                const FieldGap(),
              ],
              AppTextField(
                label: l.cardHolder,
                controller: _holder,
                enabled: !_loading,
                errorText: _errors[CardField.holderName],
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _clearError(CardField.holderName),
              ),
              const FieldGap(),
              AppTextField(
                label: l.cardNumber,
                controller: _number,
                enabled: !_loading,
                hintText: '0000 0000 0000 0000',
                errorText: _errors[CardField.number],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [CardNumberFormatter()],
                onChanged: (_) => _clearError(CardField.number),
              ),
              const FieldGap(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l.cardExpiry,
                      controller: _expiry,
                      enabled: !_loading,
                      hintText: l.cardExpiryHint,
                      errorText: _errors[CardField.expiry],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [ExpiryFormatter()],
                      onChanged: (_) => _clearError(CardField.expiry),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      label: l.cardCvc,
                      controller: _cvc,
                      enabled: !_loading,
                      hintText: '000',
                      errorText: _errors[CardField.cvc],
                      isPassword: true,
                      showPasswordTooltip: l.showPassword,
                      hidePasswordTooltip: l.hidePassword,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [CvcFormatter()],
                      onChanged: (_) => _clearError(CardField.cvc),
                    ),
                  ),
                ],
              ),
              const FieldGap(),
              Text(l.payNoStore, style: AppTypography.bodySecondary),
              if (_banner != null) ...[
                const FieldGap(),
                MessageBanner(_banner!),
              ],
              const FieldGap(),
              AppButton(
                label: l.payButton(formatMoney(o.totalAmount, l.localeName)),
                isLoading: _loading,
                loadingLabel: l.payConnecting,
                onPressed: () => _submit(o),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yalnız rakamlar (kart numarası ve CVC gövdeye böyle gider).
String digitsOfCard(String v) => v.replaceAll(RegExp(r'\D'), '');

// --- 3-D Secure --------------------------------------------------------------

/// `/c/payments/:ref/3ds`: banka doğrulama WebView'i.
class ThreeDsScreen extends ConsumerStatefulWidget {
  const ThreeDsScreen({
    super.key,
    required this.paymentRef,
    required this.html,
  });

  final String paymentRef;

  /// Başlatma yanıtındaki `htmlContent`. Uygulama yeniden başlamışsa yoktur;
  /// bu durumda doğrudan sonuç ekranına geçilir.
  final String? html;

  @override
  ConsumerState<ThreeDsScreen> createState() => _ThreeDsState();
}

class _ThreeDsState extends ConsumerState<ThreeDsScreen> {
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.html == null || widget.html!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toResult());
    }
  }

  void _toResult() {
    if (_leaving || !mounted) return;
    _leaving = true;
    context.go('/c/payments/${widget.paymentRef}/result');
  }

  Future<void> _requestClose() async {
    if (_leaving) return;
    final l = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      title: l.threeDsCloseTitle,
      message: l.threeDsCloseBody,
      confirmLabel: l.threeDsCloseConfirm,
      cancelLabel: l.threeDsCloseStay,
      destructive: true,
    );
    if (ok) _toResult();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final html = widget.html;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestClose();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l.threeDsTitle),
          actions: [
            AppIconButton(
              icon: Icons.close,
              tooltip: l.threeDsClose,
              onPressed: _requestClose,
            ),
          ],
        ),
        body: SafeArea(
          child: html == null || html.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ref.watch(threeDsViewBuilderProvider)(context, html, _toResult),
        ),
      ),
    );
  }
}

// --- 20: Ödeme sonucu --------------------------------------------------------

/// `errorCode`'a göre kullanıcıya gösterilen açıklama.
String paymentFailureBody(AppLocalizations l, PaymentResult r) =>
    switch (r.errorCode) {
      PaymentErrorCode.paymentDeclined => l.payFailDeclined,
      PaymentErrorCode.requestAlreadyAssigned => l.payFailAssigned,
      PaymentErrorCode.offerExpired => l.payFailExpired,
      PaymentErrorCode.resultUncertain => l.payFailUncertain,
      PaymentErrorCode.unknown || null => l.payFailGeneric,
    };

String paymentFailureTitle(AppLocalizations l, PaymentResult r) =>
    r.errorCode == PaymentErrorCode.resultUncertain
    ? l.payUncertainTitle
    : (r.status == EscrowStatus.refundedToCustomer
          ? l.payRefundedTitle
          : l.payFailedTitle);

/// `/c/payments/:ref/result`
class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({super.key, required this.paymentRef});

  final String paymentRef;

  @override
  ConsumerState<PaymentResultScreen> createState() => _ResultState();
}

class _ResultState extends ConsumerState<PaymentResultScreen> {
  PaymentResult? _result;
  ApiException? _error;
  Timer? _timer;
  int _polls = 0;
  bool _gaveUp = false;
  bool _fetching = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (_fetching) return;
    _fetching = true;
    _timer?.cancel();
    try {
      final r = await ref
          .read(apiClientProvider)
          .payments
          .get(widget.paymentRef);
      if (!mounted) return;
      setState(() {
        _result = r;
        _error = null;
      });
      _handle(r);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      _fetching = false;
    }
  }

  void _handle(PaymentResult r) {
    switch (r.status) {
      case EscrowStatus.initialized:
        if (_polls < kPaymentPollSeconds.length) {
          _timer = Timer(
            Duration(seconds: kPaymentPollSeconds[_polls++]),
            _fetch,
          );
        } else {
          setState(() => _gaveUp = true);
        }
      case EscrowStatus.failed || EscrowStatus.refundedToCustomer:
        invalidateJobData(ref);
      case EscrowStatus.locked:
        invalidateJobData(ref);
        final jobId = r.jobId;
        if (jobId != null) {
          // Ödeme ekranları yığından çıkar; geri tuşu işe döner.
          context.go('/c/jobs/$jobId/appointment');
        }
      case EscrowStatus.releasedToPro ||
          EscrowStatus.disputed ||
          EscrowStatus.splitSettled:
        invalidateJobData(ref);
        final jobId = r.jobId;
        if (jobId != null) context.go('/c/jobs/$jobId');
    }
  }

  void _checkAgain() {
    setState(() {
      _gaveUp = false;
      _polls = 0;
      _result = null;
      _error = null;
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = _result;
    Widget body;
    if (r == null && _error == null) {
      body = _Waiting(label: l.payWaiting);
    } else if (r == null) {
      body = ErrorState(
        title: l.genericErrorTitle,
        message: apiErrorMessage(l, _error!.code),
        retryLabel: l.retry,
        onRetry: _checkAgain,
      );
    } else {
      body = switch (r.status) {
        EscrowStatus.initialized =>
          _gaveUp
              ? _Outcome(
                  icon: Icons.schedule,
                  color: AppColors.info,
                  title: l.payUncertainTitle,
                  message: l.payFailUncertain,
                  actions: [
                    AppButton(label: l.payCheckAgain, onPressed: _checkAgain),
                    AppButton(
                      label: l.payToRequests,
                      variant: AppButtonVariant.tertiary,
                      onPressed: () => context.go('/c/requests'),
                    ),
                  ],
                )
              : _Waiting(label: l.payWaiting),
        EscrowStatus.failed || EscrowStatus.refundedToCustomer => _Outcome(
          icon: Icons.error_outline,
          color: AppColors.error,
          title: paymentFailureTitle(l, r),
          message: paymentFailureBody(l, r),
          actions: [
            if (r.offerId != null) ...[
              AppButton(
                label: l.payTryOtherCard,
                onPressed: () => _retry(r.offerId!),
              ),
              AppButton(
                label: l.payBackToOffer,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go('/c/offers/${r.offerId}'),
              ),
            ] else
              AppButton(
                label: l.payToRequests,
                onPressed: () => context.go('/c/requests'),
              ),
          ],
        ),
        _ => _Outcome(
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          title: l.paySuccessTitle,
          message: l.paySuccessBody(formatMoney(r.totalAmount, l.localeName)),
          actions: [
            AppButton(
              label: r.jobId != null ? l.payToJob : l.payToRequests,
              onPressed: () => context.go(
                r.jobId != null ? '/c/jobs/${r.jobId}' : '/c/requests',
              ),
            ),
          ],
        ),
      };
    }
    return StackFallback(
      fallback: '/c/requests',
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(l.payResultTitle),
        ),
        body: SafeArea(child: body),
      ),
    );
  }

  /// "Farklı kartla dene": teklif ekranı yığının tabanı olur, kart formu
  /// onun üstüne açılır.
  void _retry(String offerId) {
    final router = GoRouter.of(context);
    router.go('/c/offers/$offerId/accept');
    Future<void>.delayed(Duration.zero, () {
      router.push('/c/offers/$offerId/pay');
    });
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: l.loading,
              child: const CircularProgressIndicator(),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              liveRegion: true,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.section,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l.payWaitingHint,
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.actions,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 56, color: color)),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.section,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final a in actions) ...[
              a,
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}
