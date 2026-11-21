import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Lavender tile with a small [label] over a bold [value] (examination duration /
/// price in the doctor card, sessions / subscription date in My offers).
class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final double height;

  /// Space between the label and the value.
  final double labelGap;

  /// Left/right padding inside the tile.
  final double horizontalPadding;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.height = 63,
    this.labelGap = 12,
    this.horizontalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.cF8F6FA,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.medium(12, AppColors.c47586E),
          ),
          SizedBox(height: labelGap),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold(14, AppColors.primary),
          ),
        ],
      ),
    );
  }
}
