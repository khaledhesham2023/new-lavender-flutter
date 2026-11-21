import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tappable text: the app's "link" (`Terms of use`, `Back to login`, `Forgot
/// password`, ...). Optional [leading] / [trailing] icons, an underline, and a
/// [loading] state that swaps the content for a small spinner.
///
/// A null [onTap] disables the link (the text stays visible). The whole area is
/// hit-testable, not only the glyphs.
class AppLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double size;
  final FontWeight weight;
  final Color color;
  final bool underline;
  final Widget? leading;
  final Widget? trailing;
  final bool loading;
  final TextAlign? textAlign;

  /// Space between an icon and the text.
  final double iconGap;

  const AppLink({
    super.key,
    required this.text,
    this.onTap,
    this.size = 14,
    this.weight = FontWeight.w500,
    this.color = AppColors.primary,
    this.underline = false,
    this.leading,
    this.trailing,
    this.loading = false,
    this.textAlign,
    this.iconGap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.regular(size, color).copyWith(
      fontWeight: weight,
      decoration: underline ? TextDecoration.underline : null,
      decorationColor: color,
    );

    final Widget content;
    if (loading) {
      content = SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    } else {
      final label = Text(text, textAlign: textAlign, style: style);
      content = (leading == null && trailing == null)
          ? label
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, SizedBox(width: iconGap)],
                Flexible(child: label),
                if (trailing != null) ...[SizedBox(width: iconGap), trailing!],
              ],
            );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: content,
    );
  }
}
