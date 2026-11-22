import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/spacers.dart';

/// The bordered rounded (12) card of the booking screens: an icon, a title
/// (optionally with a trailing action) and [children] below it.
class BookingInfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const BookingInfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cE6E6E6),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 14, 10, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSvg(icon),
          const HorizontalSpacer(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(14, AppColors.c251836),
                      ),
                    ),
                    if (trailing != null) ...[
                      const HorizontalSpacer(8),
                      trailing!,
                    ],
                  ],
                ),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A grey 13sp value line under a card title.
class BookingValueText extends StatelessWidget {
  final String text;
  final double top;

  const BookingValueText(this.text, {super.key, this.top = 8});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Text(text, style: AppTextStyles.semiBold(13, AppColors.c666666)),
    );
  }
}

/// `label value` line (label dark, value grey) used by the Book screen date card.
class BookingLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final double top;

  const BookingLabelValue({
    super.key,
    required this.label,
    required this.value,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.semiBold(13, AppColors.c251836)),
          const HorizontalSpacer(3),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.semiBold(13, AppColors.c666666),
            ),
          ),
        ],
      ),
    );
  }
}
