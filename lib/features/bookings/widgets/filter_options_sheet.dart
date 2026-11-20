import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';
import '../../../core/widgets/progress_button.dart';

/// What a filter sheet resolves to when the user taps Confirm. Wrapping the
/// value lets "confirmed with nothing selected" ([value] null) differ from
/// "dismissed" (the sheet resolves to a null result).
class FilterSheetResult<T> {
  final T value;

  const FilterSheetResult(this.value);
}

class FilterOption {
  final String value;
  final String label;

  const FilterOption(this.value, this.label);
}

/// Shared body of `sheet_filter_by_date.xml` / `sheet_filter_by_type.xml`: a
/// title, a "remove all" action, single-choice rows and a Confirm button.
Future<FilterSheetResult<String?>?> showFilterOptionsSheet(
  BuildContext context, {
  required String title,
  required List<FilterOption> options,
  String? current,
}) {
  return showAppBottomSheet<FilterSheetResult<String?>>(
    context,
    builder: (_) =>
        _FilterOptionsView(title: title, options: options, current: current),
  );
}

class _FilterOptionsView extends StatefulWidget {
  final String title;
  final List<FilterOption> options;
  final String? current;

  const _FilterOptionsView({
    required this.title,
    required this.options,
    required this.current,
  });

  @override
  State<_FilterOptionsView> createState() => _FilterOptionsViewState();
}

class _FilterOptionsViewState extends State<_FilterOptionsView> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    // An unknown incoming value leaves every row unchecked (Android `when`).
    _selected = widget.options.any((o) => o.value == widget.current)
        ? widget.current
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(top: 21),
            decoration: BoxDecoration(
              color: AppColors.cD9DBE9,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.bold(20, AppColors.c1A0304),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selected = null),
                child: Text(
                  l10n.removeAll,
                  style: AppTextStyles.medium(14, AppColors.c47586E),
                ),
              ),
            ],
          ),
        ),
        const VerticalSpacer(32),
        for (var i = 0; i < widget.options.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selected = widget.options[i].value),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                i == widget.options.length - 1 ? 0 : 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.options[i].label,
                      style: AppTextStyles.semiBold(14, AppColors.c1A0304),
                    ),
                  ),
                  AppSvg(
                    _selected == widget.options[i].value
                        ? AppAssets.icRadioButtonSelected
                        : AppAssets.icRadioButtonUnSelected,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: ProgressButton(
            text: l10n.confirm,
            onPressed: () =>
                Navigator.pop(context, FilterSheetResult<String?>(_selected)),
          ),
        ),
      ],
    );
  }
}
