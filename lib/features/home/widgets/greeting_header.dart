import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_svg.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Android `greetingByHours`: 0-11 morning, 12-17 afternoon, otherwise evening.
String greetingByHour(AppLocalizations l10n, int hour, String suffix) {
  if (hour <= 11) return l10n.goodMorning(suffix);
  if (hour <= 17) return l10n.goodAfternoon(suffix);
  return l10n.goodEvening(suffix);
}

/// Badge text: hidden for null/0, `+99` above 99.
String? notificationBadgeText(int? count) {
  if (count == null || count == 0) return null;
  return count > 99 ? '+99' : count.toString();
}

/// Avatar, greeting, "how are you feeling" line and the notifications bell
/// (top block of `fragment_home.xml`).
class GreetingHeader extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final String? userImage;
  final int? notificationsCount;
  final VoidCallback onNotifications;

  const GreetingHeader({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    required this.userImage,
    required this.notificationsCount,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    final String greeting;
    if (!isLoggedIn) {
      greeting = greetingByHour(l10n, hour, '');
    } else if (userName != null) {
      greeting = greetingByHour(l10n, hour, ', ${userName!.split(' ').first}');
    } else {
      greeting = '';
    }
    final badge = isLoggedIn ? notificationBadgeText(notificationsCount) : null;

    return SizedBox(
      height: 57,
      child: Stack(
        children: [
          PositionedDirectional(
            start: 16,
            top: 12,
            child: isLoggedIn
                ? AppNetworkImage(
                    url: userImage,
                    width: 45,
                    height: 45,
                    circle: true,
                  )
                : const AppSvg(AppAssets.icGuestProfile, width: 45, height: 45),
          ),
          PositionedDirectional(
            start: 16 + 45 + 12,
            top: 12,
            bottom: 0,
            end: 16 + 47 + 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold(16, AppColors.c251836),
                ),
                Text(
                  l10n.howAreYouFeelingToday,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regular(14, AppColors.c666666),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            end: 16,
            top: 10,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onNotifications,
              child: SizedBox(
                width: 47,
                height: 47,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.cFAFAFA,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cE6E6E6),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(13),
                          child: AppSvg(AppAssets.icNotification),
                        ),
                      ),
                    ),
                    if (badge != null)
                      PositionedDirectional(
                        start: 0,
                        top: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.cED1C24,
                            shape: BoxShape.circle,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              badge,
                              maxLines: 1,
                              style: AppTextStyles.semiBold(10, AppColors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
