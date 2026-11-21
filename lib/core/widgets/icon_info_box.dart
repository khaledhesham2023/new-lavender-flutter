import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_svg.dart';

/// Outlined box with an icon, a bold [value] and a grey [label] below
/// (`bg_stroke_grey_rounded_10_white_background`). Used by Offer details, My offer
/// details and the Doctor details stats; the per-screen spacing and text sizes are
/// arguments.
class IconInfoBox extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  /// Start padding of the label (the value always starts at 12).
  final double labelStart;

  /// Top padding of the value row is `valueTop - 1`.
  final double valueTop;

  /// Padding at the end edge, for both the value and the label.
  final double endPadding;

  final double valueSize;
  final double labelSize;
  final Color valueColor;
  final Color labelColor;

  /// Centers the value against the icon instead of aligning it to the top.
  final bool centerValue;

  /// `autoSizeTextType="uniform"`: the value shrinks to fit on one line.
  final bool shrinkValue;

  /// Limits the value (ellipsized); null lets it wrap.
  final int? valueMaxLines;

  const IconInfoBox({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.labelStart = 12,
    this.valueTop = 12,
    this.endPadding = 10,
    this.valueSize = 14,
    this.labelSize = 12,
    this.valueColor = AppColors.c251836,
    this.labelColor = AppColors.c666666,
    this.centerValue = false,
    this.shrinkValue = false,
    this.valueMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      maxLines: valueMaxLines,
      overflow: valueMaxLines == null ? null : TextOverflow.ellipsis,
      style: AppTextStyles.bold(valueSize, valueColor),
    );
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cE6E6E6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(start: 12, top: valueTop - 1),
            child: Row(
              crossAxisAlignment: centerValue
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                AppSvg(icon),
                const SizedBox(width: 6),
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(end: endPadding),
                    child: shrinkValue
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: valueText,
                          )
                        : valueText,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: labelStart,
              top: 8,
              end: endPadding,
              bottom: 12,
            ),
            child: Text(
              label,
              style: AppTextStyles.medium(labelSize, labelColor),
            ),
          ),
        ],
      ),
    );
  }
}
