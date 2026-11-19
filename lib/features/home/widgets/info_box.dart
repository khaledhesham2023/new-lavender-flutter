import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/spacers.dart';

/// Lavender box with a small label over a bold value (examination duration / price
/// in the doctor card).
class InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const InfoBox({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.cF8F6FA,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.medium(12, AppColors.c47586E),
          ),
          const VerticalSpacer(12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bold(14, AppColors.primary),
          ),
        ],
      ),
    );
  }
}
