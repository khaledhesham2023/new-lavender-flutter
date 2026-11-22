import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 4 single-digit boxes (`etOtpCode1..4` in `fragment_otp.xml`), always left to right.
///
/// Typing moves forward; backspace on an empty box clears the previous one and focuses
/// it; backspace on a filled box clears it; pasting 4 digits fills every box. A box with
/// an earlier empty box sends focus back to the first empty one (Android focus listeners).
/// Reused by the change-phone OTP (T33).
class OtpInput extends StatefulWidget {
  static const int length = 4;

  /// Called with the 4 digits as soon as every box is filled.
  final ValueChanged<String> onCompleted;

  /// Called with the digits typed so far on every change.
  final ValueChanged<String>? onChanged;

  const OtpInput({super.key, required this.onCompleted, this.onChanged});

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  /// An empty box holds this invisible character so the soft keyboard's backspace on
  /// an empty box still produces a text change we can react to.
  static const String _blank = '​';

  final _controllers = List.generate(
    OtpInput.length,
    (_) => TextEditingController(text: _blank),
  );
  final _focusNodes = List.generate(OtpInput.length, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < OtpInput.length; i++) {
      _focusNodes[i].addListener(() => _onFocusChanged(i));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map(_digitOf).join();

  String _digitOf(TextEditingController c) => c.text.replaceAll(_blank, '');

  /// Android `resetCodeInputs`: empty every box and focus the first one.
  void clear() {
    for (final c in _controllers) {
      _set(c, '');
    }
    _focusNodes.first.requestFocus();
    setState(() {});
    widget.onChanged?.call('');
  }

  void _set(TextEditingController c, String digit) {
    final text = '$_blank$digit';
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _onFocusChanged(int index) {
    if (mounted) setState(() {});
    if (!_focusNodes[index].hasFocus) return;
    for (var i = 0; i < index; i++) {
      if (_digitOf(_controllers[i]).isEmpty) {
        _focusNodes[i].requestFocus();
        return;
      }
    }
  }

  void _onChanged(int index, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    if (raw.isEmpty) {
      // Backspace over the blank character: the box was already empty.
      _set(_controllers[index], '');
      if (index > 0) {
        _set(_controllers[index - 1], '');
        _focusNodes[index - 1].requestFocus();
      }
    } else if (digits.isEmpty) {
      // Backspace on a filled box (or a non-digit): the box is cleared, focus stays.
      _set(_controllers[index], '');
    } else if (digits.length >= OtpInput.length) {
      for (var i = 0; i < OtpInput.length; i++) {
        _set(_controllers[i], digits[i]);
      }
      _focusNodes.last.requestFocus();
    } else {
      // One digit, or a digit typed over a filled box: the last one wins.
      _set(_controllers[index], digits[digits.length - 1]);
      if (index < OtpInput.length - 1) _focusNodes[index + 1].requestFocus();
    }

    setState(() {});
    final value = code;
    widget.onChanged?.call(value);
    if (value.length == OtpInput.length) widget.onCompleted(value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < OtpInput.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            _Box(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              autofocus: i == 0,
              onChanged: (v) => _onChanged(i, v),
            ),
          ],
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  const _Box({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    return Container(
      width: 60,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? AppColors.primary : AppColors.cE6E6E6,
          width: focused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        // Keep the caret after the digit even if the user taps elsewhere in the box.
        onTap: () => controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        showCursor: false,
        enableInteractiveSelection: false,
        enableSuggestions: false,
        autocorrect: false,
        inputFormatters: [LengthLimitingTextInputFormatter(8)],
        style: AppTextStyles.medium(20, AppColors.c251836),
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
