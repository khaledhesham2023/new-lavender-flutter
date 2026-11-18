import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/spacers.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import 'field_error.dart';

/// Phone input with the fixed `+966` prefix (port of the login phone block).
/// Owns its error state; call [PhoneFieldState.validate] (through a `GlobalKey`) on submit.
class PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const PhoneField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<PhoneField> createState() => PhoneFieldState();
}

class PhoneFieldState extends State<PhoneField> {
  static const String phoneCode = '+966';

  final FocusNode _focus = FocusNode();
  PhoneError _error = PhoneError.ok;

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

  void _onFocusChange() {
    setState(() {
      // Rules only on focus lost; `startsWith 5` is enforced while typing.
      if (!_focus.hasFocus) {
        final e = validatePhone(widget.controller.text);
        _error = e == PhoneError.mustStartWith5 ? PhoneError.ok : e;
      }
    });
  }

  void _onChanged(String text) {
    if (text.isEmpty) return;
    if (!text.startsWith('5')) {
      widget.controller.clear();
      setState(() => _error = PhoneError.mustStartWith5);
    } else {
      setState(() => _error = PhoneError.ok);
    }
  }

  /// Submit validation (phone empty, < 9, not starting with 5). Shows the error.
  bool validate() {
    final e = validatePhone(widget.controller.text);
    setState(() => _error = e);
    return e == PhoneError.ok;
  }

  String? _message(BuildContext context) {
    final l10n = context.l10n;
    return switch (_error) {
      PhoneError.ok => null,
      PhoneError.empty => l10n.pleaseEnterThePhoneNumber,
      PhoneError.tooShort => l10n.thePhoneNumberMustBeAtLeast9CharactersLong,
      PhoneError.mustStartWith5 => l10n.thePhoneNumberIsInvalidPleaseStartWith5,
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
            l10n.phone,
            style: AppTextStyles.regular(14, AppColors.primary),
          ),
        ),
        const VerticalSpacer(7),
        // The prefix + number row is always left-to-right (layoutDirection="ltr").
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    AppAssets.icArabicLanguage,
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                ),
                const HorizontalSpacer(4),
                Text(
                  phoneCode,
                  style: AppTextStyles.medium(14, AppColors.c251836),
                ),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.only(left: 6),
                  color: AppColors.c7E94B0,
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    keyboardType: TextInputType.phone,
                    textInputAction: widget.textInputAction,
                    onSubmitted: widget.onSubmitted,
                    onChanged: _onChanged,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: AppColors.c251836,
                    cursorWidth: 2,
                    style: AppTextStyles.medium(14, AppColors.c251836),
                    decoration: InputDecoration(
                      hintText: l10n.phoneExample,
                      hintStyle: AppTextStyles.medium(14, AppColors.c7E94B0),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ],
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
