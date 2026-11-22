import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/widgets/spacers.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/system_ui.dart';
import '../../app/router/routes.dart';
import 'widgets/speed_lottie.dart';
import 'widgets/continue_as_guest.dart';
import 'widgets/or_divider.dart';

class StartNowScreen extends StatelessWidget {
  const StartNowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SystemUi(
      statusBarColor: AppColors.white,
      navigationBarColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SpeedLottie(
                    asset: AppAssets.start,
                    speed: 0.5,
                    repeat: false,
                  ),
                ),
              ),
              const VerticalSpacer(40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.startABetterHealthyJourney,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(20, AppColors.black),
                ),
              ),
              const VerticalSpacer(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.bookYourAppointments,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium(
                    14,
                    AppColors.c3D4C5E,
                  ).copyWith(height: 1.4),
                ),
              ),
              const VerticalSpacer(57),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppButton(
                  text: l10n.createAccount,
                  onPressed: () => context.push(Routes.authRegister),
                ),
              ),
              const VerticalSpacer(16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppButton.outlined(
                  text: l10n.login,
                  onPressed: () => context.push(Routes.authLogin),
                ),
              ),
              const VerticalSpacer(31),
              OrDivider(label: l10n.orYouCan),
              const VerticalSpacer(24),
              // Guest: nothing is saved, just open Home.
              ContinueAsGuest(
                text: l10n.continueAsGuest,
                onTap: () => context.go(Routes.home),
              ),
              const VerticalSpacer(16),
            ],
          ),
        ),
      ),
    );
  }
}
