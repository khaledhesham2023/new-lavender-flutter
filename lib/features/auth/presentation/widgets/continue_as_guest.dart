import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/spacers.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/speed_lottie.dart';

/// Underlined "continue as guest" link with the looping eyes animation at its end.
class ContinueAsGuest extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ContinueAsGuest({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Keeps the text centered while the eyes sit at its end.
          const HorizontalSpacer(27),
          Text(
            text,
            style: AppTextStyles.medium(14, AppColors.primary).copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
          ),
          const HorizontalSpacer(3),
          const SizedBox(
            width: 24,
            height: 24,
            child: SpeedLottie(
              asset: AppAssets.lottieAuthGuestEyes,
              speed: 1.5,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }
}
