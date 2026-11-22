import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lavender/core/widgets/spacers.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../shared/session/session_cubit.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_svg.dart';
import '../../core/widgets/bottom_sheet_frame.dart';
import '../../core/widgets/failure_toast.dart';
import '../../core/widgets/progress_button.dart';
import 'domain/repositories/profile_repository.dart';
import '../../app/router/routes.dart';
import 'language_cubit.dart';

/// Port of `ChangeLanguageSheet`. Confirming switches the whole app (the
/// locale flips RTL/LTR) and lands on Home, as Android restarts `MainActivity`.
Future<void> showLanguageSheet(BuildContext context) {
  final router = GoRouter.of(context);
  return showAppBottomSheet<void>(
    context,
    builder: (_) => BlocProvider(
      create: (_) =>
          LanguageCubit(sl<ProfileRepository>(), sl<SessionCubit>()),
      child: _LanguageSheet(router: router),
    ),
  );
}

class _LanguageSheet extends StatelessWidget {
  final GoRouter router;

  const _LanguageSheet({required this.router});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LanguageCubit>();

    return BlocConsumer<LanguageCubit, LanguageState>(
      listenWhen: (prev, curr) => curr.done || curr.failure != null,
      listener: (context, state) {
        if (state.done) {
          Navigator.of(context).pop();
          router.go(Routes.home);
        } else if (state.failure != null) {
          showFailureToast(context, state.failure!);
          cubit.consumeFailure();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 139,
                  height: 5,
                  margin: const EdgeInsets.only(top: 24),
                  color: AppColors.cD9DBE9,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.language,
                        style: AppTextStyles.bold(20, AppColors.black),
                      ),
                    ),
                    InkResponse(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: AppSvg(AppAssets.icCloseChangeLang),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  l10n.chooseTheLanguage,
                  style: AppTextStyles.medium(14, AppColors.c60717F),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.only(top: 16, bottom: 46),
                color: AppColors.cF8F6FA,
                child: Column(
                  children: [
                    _LanguageOption(
                      title: l10n.english,
                      selected: state.selected == 'en',
                      onTap: () => cubit.select('en'),
                    ),
                    const VerticalSpacer(16),
                    _LanguageOption(
                      title: l10n.arabic,
                      selected: state.selected == 'ar',
                      onTap: () => cubit.select('ar'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ProgressButton(
                  text: l10n.confirm,
                  loading: state.loading,
                  onPressed: cubit.confirm,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A 56dp white rounded row with a radio mark at the end.
class _LanguageOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bold(14, AppColors.black),
                    ),
                  ),
                  AppSvg(
                    selected
                        ? AppAssets.icRadioButtonSelected
                        : AppAssets.icRadioButtonUnSelected,
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
