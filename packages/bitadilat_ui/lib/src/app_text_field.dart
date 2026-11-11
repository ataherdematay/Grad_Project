import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_icon_button.dart';
import 'tokens.dart';
import 'typography.dart';

/// Etiket üstte, en az 52 px yüksekliğinde metin alanı. `isPassword` iken
/// göster/gizle düğmesi çıkar.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.isPassword = false,
    this.showPasswordTooltip,
    this.hidePasswordTooltip,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.prefixText,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.textCapitalization = TextCapitalization.none,
  }) : assert(
         !isPassword ||
             (showPasswordTooltip != null && hidePasswordTooltip != null),
         'Şifre alanında göster/gizle tooltip metinleri verilmeli.',
       );

  final String label;
  final TextEditingController? controller;
  final String? hintText;

  /// Sunucudan gelen veya dışarıdan verilen hata; `validator`dan önce gösterilir.
  final String? errorText;
  final String? helperText;
  final bool isPassword;
  final String? showPasswordTooltip;
  final String? hidePasswordTooltip;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final String? prefixText;
  final int? maxLength;

  /// Çok satırlı alan: `minLines` verilirse alan o kadar satırla başlar ve
  /// `maxLines`a (varsayılan `minLines` + 4) kadar büyür.
  final int? minLines;
  final int? maxLines;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  bool get _multiline => widget.minLines != null || widget.maxLines != null;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: AppTypography.label.copyWith(
              color: hasError ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: widget.label,
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            obscureText: widget.isPassword && _obscured,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            maxLength: widget.maxLength,
            minLines: _multiline ? (widget.minLines ?? 1) : null,
            maxLines: widget.isPassword
                ? 1
                : (_multiline
                      ? (widget.maxLines ?? (widget.minLines ?? 1) + 4)
                      : 1),
            textCapitalization: widget.textCapitalization,
            forceErrorText: hasError ? widget.errorText : null,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: widget.hintText,
              helperText: widget.helperText,
              helperMaxLines: 3,
              // Önek (+90, ₺) her zaman görünür. `prefixText` yalnız odakta
              // çizilir ama yerini baştan tutar; boş alanda ipucu metni
              // nedensiz içeride başlıyordu.
              prefixIcon: widget.prefixText == null
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.md,
                      ),
                      child: Text(
                        widget.prefixText!.trim(),
                        style: AppTypography.body,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(),
              counterText: '',
              constraints: const BoxConstraints(
                minHeight: AppSizes.controlHeight,
              ),
              suffixIcon: widget.isPassword
                  ? AppIconButton(
                      icon: _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      tooltip: _obscured
                          ? widget.showPasswordTooltip!
                          : widget.hidePasswordTooltip!,
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
