import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/spacers.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';

/// 1dp underline under an auth field: grey, red on error.
class FieldUnderline extends StatelessWidget {
  final bool error;
  const FieldUnderline({super.key, required this.error});

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    color: error ? AppColors.cED1C24 : AppColors.cD9DBE9,
  );
}

/// Red error line (`tvPhoneError` / `tvPasswordError`): icon + 12sp text, 10dp below the underline.
class FieldErrorText extends StatelessWidget {
  final String message;
  const FieldErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      // Like drawableStart: icon vertically centered against the text.
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppSvg(AppAssets.icErrorIcon, width: 16, height: 16),
        const HorizontalSpacer(6),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.medium(12, AppColors.cED1C24),
          ),
        ),
      ],
    ),
  );
}
