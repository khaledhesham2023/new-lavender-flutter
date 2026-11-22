import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg.dart';

/// Entries of the Account tab. Android matched the localized text of the row to
/// decide what to open; an enum replaces that.
enum ProfileMenu {
  password(AppAssets.icChangePassword),
  myOffers(AppAssets.icDiscountShape),
  reports(AppAssets.icDiscountShape),
  notifications(AppAssets.icNotificationBing),
  language(AppAssets.icTranslate),
  contactUs(AppAssets.icCall),
  rateTheApp(AppAssets.icAppEvaluation),
  whoAreWe(AppAssets.icWhoWeAre),
  aboutApp(AppAssets.icWhoWeAre),
  logout(AppAssets.icLogout);

  const ProfileMenu(this.icon);

  final String icon;

  /// Rows of a logged-in user, in Android's order.
  static const loggedIn = [
    password,
    myOffers,
    reports,
    notifications,
    language,
    contactUs,
    rateTheApp,
    whoAreWe,
    aboutApp,
    logout,
  ];

  /// Rows of a guest.
  static const guest = [
    notifications,
    language,
    contactUs,
    rateTheApp,
    whoAreWe,
    aboutApp,
  ];

  String title(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      password => l10n.password,
      myOffers => l10n.myOffers,
      reports => l10n.radiologyAndAnalysisReports,
      notifications => l10n.notifications,
      language => l10n.language,
      contactUs => l10n.contactUs,
      rateTheApp => l10n.rateTheApp,
      whoAreWe => l10n.whoAreWe,
      aboutApp => l10n.aboutApp,
      logout => l10n.logout,
    };
  }
}

/// Port of `recycler_item_content_profile.xml`: a 52dp card with icon, title and
/// a chevron.
class ProfileMenuItem extends StatelessWidget {
  final ProfileMenu item;
  final VoidCallback onTap;

  const ProfileMenuItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppColors.cFAFAFA,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AppSvg(item.icon, width: 20, height: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 8,
                        end: 4,
                      ),
                      child: Text(
                        item.title(context),
                        textAlign: TextAlign.start,
                        style: AppTextStyles.semiBold(14, AppColors.c251836),
                      ),
                    ),
                  ),
                  const AppSvg(
                    AppAssets.icArrowLeft,
                    width: 16,
                    height: 16,
                    color: AppColors.c666666,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
