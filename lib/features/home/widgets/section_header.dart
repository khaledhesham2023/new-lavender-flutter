import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';

/// Title row of a Home section (label at 16sp, optional "Show all" with an arrow).
/// [titleIcon] is drawn right after the label (the gift of the offers section).
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onShowAll;
  final Widget? titleIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.onShowAll,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: AppTextStyles.semiBold(16, AppColors.c251836),
                    ),
                  ),
                  if (titleIcon != null) ...[
                    const SizedBox(width: 4),
                    titleIcon!,
                  ],
                ],
              ),
            ),
          ),
          if (onShowAll != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onShowAll,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, top: 33),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.showAll,
                      style: AppTextStyles.semiBold(12, AppColors.c251836),
                    ),
                    const SizedBox(width: 2),
                    const AppSvg(AppAssets.icArrowEnd, width: 16, height: 17),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
