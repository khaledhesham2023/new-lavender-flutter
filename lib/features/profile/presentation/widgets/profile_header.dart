import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../shared/session/session_cubit.dart';
import '../../../../shared/session/user_store.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_svg.dart';

/// Logged-in header (`clHeaderAuth`): 150dp background, avatar, "Welcome, name"
/// and the "modify personal information" link.
class ProfileHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const ProfileHeader({super.key, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.select<SessionCubit, UserData?>((c) => c.state.user);
    final name = user?.name.trim() ?? '';
    final firstName = name.isEmpty ? '' : name.split(' ').first;
    final image = user?.image;

    return SizedBox(
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.icBackgroundProfile, fit: BoxFit.fill),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          AppNetworkImage(
                            url: image,
                            width: 40,
                            height: 40,
                            circle: true,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 6,
                                end: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: onEdit,
                                    behavior: HitTestBehavior.opaque,
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: Text(
                                          l10n.welcome(
                                            firstName.isEmpty
                                                ? ''
                                                : ', $firstName',
                                          ),
                                          maxLines: 1,
                                          style: AppTextStyles.semiBold(
                                            14,
                                            AppColors.c1F1926,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const VerticalSpacer(5),
                                  GestureDetector(
                                    onTap: onEdit,
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            l10n.modifyPersonalInformation,
                                            style: AppTextStyles.regular(
                                              12,
                                              AppColors.c546881,
                                            ),
                                          ),
                                        ),
                                        const VerticalSpacer(2),
                                        const AppSvg(
                                          AppAssets.icArrowLeft,
                                          width: 16,
                                          height: 16,
                                          color: AppColors.c909DAD,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const AppSvg(AppAssets.icRelatedProfile),
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

/// Guest header (`clHeaderGuest`): 262dp illustration with the login hint.
class ProfileGuestHeader extends StatelessWidget {
  const ProfileGuestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 262,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppSvg(AppAssets.icProfileHeaderGuest, fit: BoxFit.fill),
          Align(
            alignment: const Alignment(0, 0.8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context
                    .l10n
                    .youHaveToLoginFirstBodyReservationsAndTrackFavorites,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(12, AppColors.c3D4C5E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
