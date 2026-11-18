import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/spacers.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_svg.dart';
import 'field_error.dart';

enum _PasswordMessage { none, empty, tooShort, mustStartWithLetter }

/// Obscured password input with eye toggle (`tiLoginPassword`) and its rules.
/// Owns its error state; call [PasswordFieldState.validate] on submit.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const PasswordField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  final FocusNode _focus = FocusNode();
  _PasswordMessage _error = _PasswordMessage.none;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  _PasswordMessage _fromRule(PasswordError e) => switch (e) {
    PasswordError.ok => _PasswordMessage.none,
    PasswordError.empty => _PasswordMessage.empty,
    PasswordError.tooShort => _PasswordMessage.tooShort,
  };

  void _onFocusChange() {
    setState(() {
      if (!_focus.hasFocus) {
        _error = _fromRule(validatePassword(widget.controller.text));
      }
    });
  }

  void _onChanged(String text) {
    if (text.isNotEmpty && !startsWithLetterOrDigit(text)) {
      final cleaned = stripLeadingNonAlnum(text);
      widget.controller.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
      setState(() => _error = _PasswordMessage.mustStartWithLetter);
    } else {
      setState(() => _error = _PasswordMessage.none);
    }
  }

  /// Submit validation (empty, < 8). Android checks the trimmed text. Shows the error.
  bool validate() {
    final e = validatePassword(widget.controller.text.trim());
    setState(() => _error = _fromRule(e));
    return e == PasswordError.ok;
  }

  String? _message(BuildContext context) {
    final l10n = context.l10n;
    return switch (_error) {
      _PasswordMessage.none => null,
      _PasswordMessage.empty => l10n.pleaseEnterThePassword,
      _PasswordMessage.tooShort => l10n.passwordMustBeAtLeast8CharactersLong,
      _PasswordMessage.mustStartWithLetter => l10n.passwordMustStartWithALetter,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = _message(context);
    final hasError = message != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.passwordWithStar,
            style: AppTextStyles.regular(14, AppColors.primary),
          ),
        ),
        const VerticalSpacer(7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 24,
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: _obscure,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              onChanged: _onChanged,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppColors.c251836,
              cursorWidth: 2,
              style: AppTextStyles.medium(14, AppColors.c251836),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                suffixIconConstraints: const BoxConstraints(),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: AppSvg(
                    _obscure
                        ? AppAssets.icHidePassword
                        : AppAssets.icShowPassword,
                    width: 24,
                    height: 24,
                    color: AppColors.c292D32,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: FieldUnderline(error: hasError),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FieldErrorText(message),
          ),
      ],
    );
  }
}
