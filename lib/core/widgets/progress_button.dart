import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Port of `ProgressButton` / `ProgressButtonSmall`: rounded (16) primary button.
/// While [loading] it shows a small white spinner instead of the text, takes the
/// disabled (grey) look and ignores taps. Disabled = grey `bg_deactive_progress_button`.
class ProgressButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final Color? background;
  final Color? textColor;
  final double height;

  /// Uses the `progress_button_layout_small` sizes (50 high, 10sp text).
  final bool small;

  const ProgressButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.background,
    this.textColor,
    this.height = 56,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;
    final bg = (enabled && !loading) ? (background ?? AppColors.primary) : AppColors.cBEBEBE;
    return SizedBox(
      height: small ? 50 : height,
      width: double.infinity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: active ? onPressed : null,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                : Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiBold(small ? 10 : 16, textColor ?? AppColors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
