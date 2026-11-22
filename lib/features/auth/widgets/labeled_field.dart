import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/domain/validators.dart';
import '../../../core/widgets/app_svg.dart';
import 'field_error.dart';

/// Floating-label text input of the register form (`TextInputLayout` + underline + error line).
/// Owns its error state. Rules:
/// - typing: a non-letter/digit first character is stripped and [startRuleMessage] is shown;
/// - focus lost / [validate]: [rule] returns the message (or null when valid).
class LabeledField extends StatefulWidget {
  final TextEditingController controller;

  /// Plain label (name). Ignored when [labelBuilder] is given.
  final String? label;

  /// Rich label (email).
  final InlineSpan Function()? labelBuilder;

  final String iconAsset;
  final bool iconAtEnd;
  final bool iconAlwaysLeft;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String Function(BuildContext) startRuleMessage;
  final String? Function(BuildContext, String text) rule;

  const LabeledField({
    super.key,
    required this.controller,
    this.label,
    this.labelBuilder,
    required this.iconAsset,
    this.iconAtEnd = false,
    this.iconAlwaysLeft = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    required this.startRuleMessage,
    required this.rule,
  });

  @override
  State<LabeledField> createState() => LabeledFieldState();
}

class LabeledFieldState extends State<LabeledField> {
  final FocusNode _focus = FocusNode();
  String? _error;

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
      if (!_focus.hasFocus) {
        _error = widget.rule(context, widget.controller.text);
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
      setState(() => _error = widget.startRuleMessage(context));
    } else {
      setState(() => _error = null);
    }
  }

  /// Submit validation; shows the error. True when valid.
  bool validate() {
    final message = widget.rule(context, widget.controller.text);
    setState(() => _error = message);
    return message == null;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final icon = AppSvg(widget.iconAsset, width: 20, height: 20);
    final label = widget.labelBuilder != null
        ? Text.rich(widget.labelBuilder!())
        : Text(
            widget.label ?? '',
            style: AppTextStyles.regular(14, AppColors.primary),
          );
    // Name: icon at the end of the text. Email: icon always on the left.
    final iconLeft = widget.iconAlwaysLeft || (widget.iconAtEnd == isRtl);

    final input = Expanded(
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: _onChanged,
        maxLength: 40,
        maxLines: 1,
        buildCounter: (
          _, {
          required currentLength,
          required isFocused,
          maxLength,
        }) => null,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppColors.c251836,
        cursorWidth: 2,
        style: AppTextStyles.medium(14, AppColors.c251836),
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: label,
        ),
        const VerticalSpacer(7),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 24,
            // Row is physical (ltr) so the icon side is explicit; the text keeps
            // the locale direction.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  if (iconLeft) ...[icon, const HorizontalSpacer(8)],
                  Directionality(
                    textDirection: Directionality.of(context),
                    child: input,
                  ),
                  if (!iconLeft) ...[const HorizontalSpacer(8), icon],
                ],
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
            child: FieldErrorText(_error!),
          ),
      ],
    );
  }
}
