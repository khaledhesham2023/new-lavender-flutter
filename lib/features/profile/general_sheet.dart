import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/bottom_sheet_frame.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/progress_button.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../app/router/routes.dart';
import 'general_cubit.dart';

export 'general_cubit.dart' show GeneralType;

/// Port of `GeneralSheet`: confirmation for "log out" and "delete account".
/// On success the session is cleared and the app returns to the Start screen.
Future<void> showGeneralSheet(BuildContext context, GeneralType type) {
  // The sheet closes before the app navigates, so keep the router.
  final router = GoRouter.of(context);
  return showAppBottomSheet<void>(
    context,
    builder: (_) => BlocProvider(
      create: (_) => GeneralCubit(
        type,
        sl<AuthRepository>(),
        sl<ProfileRepository>(),
        sl<SessionCubit>(),
        sl<AppPrefs>(),
      ),
      child: _GeneralSheet(type: type, router: router),
    ),
  );
}

class _GeneralSheet extends StatelessWidget {
  final GeneralType type;
  final GoRouter router;

  const _GeneralSheet({required this.type, required this.router});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLogout = type == GeneralType.logout;
    final accent = isLogout ? AppColors.primary : AppColors.cED1C24;

    return BlocConsumer<GeneralCubit, GeneralState>(
      listenWhen: (prev, curr) => curr.done || curr.failure != null,
      listener: (context, state) {
        if (state.done) {
          Navigator.of(context).pop();
          router.go(Routes.authStart);
        } else if (state.failure != null) {
          showFailureToast(context, state.failure!);
          context.read<GeneralCubit>().consumeFailure();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 37,
                height: 4,
                margin: const EdgeInsets.only(top: 6),
                color: AppColors.cD9DBE9,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AppSvg(
                  isLogout ? AppAssets.icBgLogout : AppAssets.icBgDeleteAccount,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 29),
                child: Text(
                  isLogout
                      ? l10n.doYouWantToLeaveNowTitle
                      : l10n.areYouSureAboutYourDecisionTitle,
                  style: AppTextStyles.semiBold(16, AppColors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  isLogout
                      ? l10n.doYouWantToLeaveNowBody
                      : l10n.areYouSureAboutYourDecisionBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium(14, AppColors.c707070),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 59),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 8,
                        ),
                        child: _CancelButton(
                          color: accent,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 8,
                          end: 16,
                        ),
                        child: ProgressButton(
                          text: isLogout ? l10n.logout : l10n.deleteAccount,
                          loading: state.loading,
                          background: isLogout ? null : AppColors.cE23535,
                          onPressed: context.read<GeneralCubit>().confirm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// `tvCancel`: white 56dp button with a 1dp outline in [color].
class _CancelButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _CancelButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Center(
            child: Text(
              context.l10n.cancel,
              style: AppTextStyles.semiBold(
                14,
                color == AppColors.primary ? AppColors.primary : AppColors.cE23535,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
