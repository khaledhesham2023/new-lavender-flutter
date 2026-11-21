import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_back_button.dart';

/// Plain action bar: bold centered [title], back arrow at the start, optional
/// [trailing] at the end, and a 1dp divider below.
///
/// The bar always spans the full width, so it is safe inside a `Column` that
/// centers its children (otherwise the back arrow would sit on top of the title).
class AppTopBar extends StatelessWidget {
  final String title;

  /// Widget shown at the end edge (e.g. an action icon).
  final Widget? trailing;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;

  /// Hides the back arrow (e.g. for a root screen).
  final bool showBack;

  final bool showDivider;
  final double height;
  final double titleSize;
  final Color titleColor;
  final Color dividerColor;

  const AppTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
    this.showBack = true,
    this.showDivider = true,
    this.height = 56,
    this.titleSize = 16,
    this.titleColor = AppColors.c0F0102,
    this.dividerColor = AppColors.cE6E6E6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(title, style: AppTextStyles.bold(titleSize, titleColor)),
              if (showBack)
                PositionedDirectional(
                  start: 16,
                  child: AppBackButton(onTap: onBack ?? () => context.pop()),
                ),
              if (trailing != null)
                PositionedDirectional(end: 16, child: trailing!),
            ],
          ),
        ),
        if (showDivider) Container(height: 1, color: dividerColor),
      ],
    );
  }
}
