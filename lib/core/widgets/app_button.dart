import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Generic rounded text button with a ripple. Filled primary by default; pass
/// [borderColor] + a white [backgroundColor] for the outlined look.
/// For a button with a loading state use `ProgressButton`.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double horizontalPadding;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.radius = 16,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.white,
    this.borderColor,
    this.horizontalPadding = 12,
  });

  /// White button with a primary outline and primary text.
  const AppButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.radius = 16,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w700,
    this.backgroundColor = AppColors.white,
    this.textColor = AppColors.primary,
    this.borderColor = AppColors.primary,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              // Shrinks long labels instead of overflowing (Android autoSizeText).
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: AppTextStyles.bold(
                    fontSize,
                    textColor,
                  ).copyWith(fontWeight: fontWeight),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
