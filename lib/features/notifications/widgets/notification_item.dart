import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../data/models/responses/notification.dart';

/// Port of `recycler_item_notification.xml`: icon, title with the unread dot,
/// two lines of body, the date and a separator.
class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  /// Android keeps the font's own line spacing here (`includeFontPadding=true`),
  /// unlike the shared styles, which use a height of 1.
  static const _lineHeight = 1.5;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notification.isReaded != true;
    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppSvg(AppAssets.icNotificationImage),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 298,
                                ),
                                child: Text(
                                  notification.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: AppTextStyles.semiBold(
                                    14,
                                    AppColors.c090B0E,
                                  ).copyWith(height: _lineHeight),
                                ),
                              ),
                            ),
                            if (unread)
                              const Padding(
                                padding: EdgeInsetsDirectional.only(start: 6),
                                child: AppSvg(AppAssets.icUnreadBadge),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            notification.body ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: AppTextStyles.regular(12, AppColors.c130918).copyWith(height: _lineHeight),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            notification.dateFormated ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: AppTextStyles.medium(12, AppColors.c1D242D).copyWith(height: _lineHeight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(vertical: 16),
              color: AppColors.cE6E6E6,
            ),
          ],
        ),
      ),
    );
  }
}
