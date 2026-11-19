import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/bottom_sheet_frame.dart';
import '../../data/models/responses/speciality.dart';

/// Port of `SubSpecialtiesSheet`. Resolves to the checked subspecialties (in the
/// order of [all]) on Confirm and to `null` when dismissed.
Future<List<SubSpecialtyModel>?> showSubSpecialtiesSheet(
  BuildContext context, {
  required List<SubSpecialtyModel> all,
  required List<SubSpecialtyModel> selected,
}) {
  return showAppBottomSheet<List<SubSpecialtyModel>>(
    context,
    builder: (_) => _SubSpecialtiesSheet(all: all, selected: selected),
  );
}

class _SubSpecialtiesSheet extends StatefulWidget {
  final List<SubSpecialtyModel> all;
  final List<SubSpecialtyModel> selected;

  const _SubSpecialtiesSheet({required this.all, required this.selected});

  @override
  State<_SubSpecialtiesSheet> createState() => _SubSpecialtiesSheetState();
}

class _SubSpecialtiesSheetState extends State<_SubSpecialtiesSheet> {
  late final Set<int?> _checked = {for (final s in widget.selected) s.id};

  void _toggle(SubSpecialtyModel item) => setState(() {
    if (!_checked.remove(item.id)) _checked.add(item.id);
  });

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
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            l10n.subSpecialties,
            textAlign: TextAlign.center,
            style: AppTextStyles.bold(20, AppColors.c1A0304),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            children: [
              for (final item in widget.all)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _toggle(item),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiBold(
                              14,
                              AppColors.c1A0304,
                            ),
                          ),
                        ),
                        const HorizontalSpacer(4),
                        AppSvg(
                          _checked.contains(item.id)
                              ? AppAssets.icCheckBoxTrue
                              : AppAssets.icCheckBoxFalse,
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
            onPressed: () => Navigator.of(context).pop([
              for (final item in widget.all)
                if (_checked.contains(item.id)) item,
            ]),
          ),
        ),
      ],
    );
  }
}
