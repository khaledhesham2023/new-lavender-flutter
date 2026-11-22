import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../core/widgets/bottom_sheet_frame.dart';
import '../../../core/enums/enums.dart';

String sortLabel(BuildContext context, SortByStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    SortByStatus.highToLowPrice => l10n.highToLowPrice,
    SortByStatus.lowToHighPrice => l10n.lowToHighPrice,
    SortByStatus.highToLowRate => l10n.highToLowRate,
    SortByStatus.lowToHighRate => l10n.lowToHighRate,
  };
}

/// Port of `SortBySheet`. Resolves to `null` when the sheet is dismissed
/// (nothing changes) and to `(value: ...)` on Confirm, where a null value means
/// the sort was cleared. (A plain `String?` could not tell those two apart.)
Future<({String? value})?> showSortSheet(
  BuildContext context, {
  String? current,
}) {
  return showAppBottomSheet<({String? value})>(
    context,
    builder: (_) => _SortSheet(current: current),
  );
}

class _SortSheet extends StatefulWidget {
  final String? current;

  const _SortSheet({this.current});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late SortByStatus? _selected = SortByStatus.fromValue(widget.current);

  /// Tapping the selected row unselects it, like Android's `setStatusSelection`.
  void _toggle(SortByStatus status) =>
      setState(() => _selected = _selected == status ? null : status);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sortBy,
                style: AppTextStyles.bold(20, AppColors.c1A0304),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            children: [
              for (final status in SortByStatus.values)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggle(status),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            sortLabel(context, status),
                            style: AppTextStyles.semiBold(
                              14,
                              AppColors.c1A0304,
                            ),
                          ),
                        ),
                        AppSvg(
                          _selected == status
                              ? AppAssets.icRadioButtonSelected
                              : AppAssets.icRadioButtonUnSelected,
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AppButton(
            text: l10n.confirm,
            onPressed: () =>
                Navigator.of(context).pop((value: _selected?.value)),
          ),
        ),
      ],
    );
  }
}
