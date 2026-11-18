import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Grey 1dp line with the "or you can" label centered on it (white padding cuts the line).
class OrDivider extends StatelessWidget {
  final String label;
  const OrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 1, color: AppColors.cD9DBE9),
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: AppTextStyles.medium(14, AppColors.c7E94B0),
            ),
          ),
        ],
      ),
    );
  }
}
