import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/number_utils.dart';
import '../../core/widgets/app_svg.dart';

/// `bg_discount` badge (63x55) with the "Off" label and the percentage, both
/// rotated -10° in Arabic and +10° otherwise (offers list / offer details).
class DiscountBadge extends StatelessWidget {
  final double? discount;

  /// The list item uses a bold label, the details screen a medium one.
  final bool boldLabel;

  /// Horizontal bias of the value (0.4 in the list item, centered in details).
  final double valueBias;

  const DiscountBadge({
    super.key,
    required this.discount,
    this.boldLabel = false,
    this.valueBias = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final angle = (isAr ? -10 : 10) * math.pi / 180;
    final labelStyle = boldLabel
        ? AppTextStyles.bold(12, AppColors.white)
        : AppTextStyles.medium(12, AppColors.white);
    return SizedBox(
      width: 63,
      height: 55,
      child: Stack(
        children: [
          const Positioned.fill(child: AppSvg(AppAssets.bgDiscount)),
          Align(
            alignment: const Alignment(0, -0.4),
            child: Transform.rotate(
              angle: angle,
              child: Text(
                context.l10n.off,
                textAlign: TextAlign.center,
                style: labelStyle,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(valueBias * 2 - 1, 0.3),
            child: Transform.rotate(
              angle: angle,
              child: Text(
                formatPercentage(discount),
                style: AppTextStyles.discount(12, AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
