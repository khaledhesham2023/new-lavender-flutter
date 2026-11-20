import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_svg.dart';

/// Search box styled like `etSearch` (50 high, grey fill, 16 radius, search icon).
/// [onChanged] fires only after the user stops typing for [debounce].
class DebouncedSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final Duration debounce;
  final TextEditingController? controller;

  const DebouncedSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 500),
    this.controller,
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  Timer? _timer;

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Line height 1.0 clips descenders (the "p" of "specialty") inside a text
    // field, so use a slightly taller line split evenly above and below: no
    // extra font padding, hint and text stay centered, nothing is cut off.
    TextStyle tight(TextStyle s) => s.copyWith(
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
    );
    final text = tight(AppTextStyles.medium(12, AppColors.c251836));
    return SizedBox(
      height: 50,
      child: TextField(
        controller: widget.controller,
        onChanged: _onChanged,
        style: text,
        cursorColor: AppColors.c251836,
        cursorWidth: 2,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: tight(AppTextStyles.medium(12, AppColors.c666666)),
          filled: true,
          fillColor: AppColors.cFAFAFA,
          contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 10),
            child: AppSvg(AppAssets.icSearch),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.cE6E6E6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.cE6E6E6),
          ),
        ),
      ),
    );
  }
}
