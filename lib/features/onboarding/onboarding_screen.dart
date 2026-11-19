import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/storage/app_prefs.dart';
import '../../core/theme/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/system_ui.dart';
import '../../core/widgets/spacers.dart';
import '../../router/routes.dart';
import 'widgets/onboarding_art.dart';
import 'widgets/page_dots.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  static const _lottiesAr = [
    AppAssets.onbaording1Ar,
    AppAssets.onbaording2Ar,
    AppAssets.onbaording3Ar,
  ];
  static const _lottiesEn = [
    AppAssets.onboarding1En,
    AppAssets.onboarding2En,
    AppAssets.onboarding3En,
  ];

  Future<void> _next() async {
    if (_index < 2) {
      setState(() => _index++);
      return;
    }
    await sl<AppPrefs>().setFirstTime(false);
    if (mounted) context.go(Routes.authStart);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = sl<AppPrefs>().languageCode == 'ar';
    final titles = [
      l10n.allYourMedicalServicesInOnePlace,
      l10n.bookEasilyAnytime,
      l10n.regularMonitoringOfYourHealth,
    ];
    final bodies = [
      l10n.noNeedToSearchInMultiplePlaces,
      l10n.browseTheListOfDoctorsAndServices,
      l10n.keepADigitalMedicalRecordThatIncludesYourPreviousAppointments,
    ];
    final lottie = (isAr ? _lottiesAr : _lottiesEn)[_index];

    return SystemUi(
      statusBarColor: AppColors.white,
      navigationBarColor: AppColors.white,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: OnboardingArt(
                        key: ValueKey(lottie),
                        asset: lottie,
                      ),
                    ),
                    // on_boarding_color: transparent -> white fade over the art.
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.c00FFFFFF, AppColors.white],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalSpacer(12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  titles[_index],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bold(
                    20,
                    AppColors.black,
                  ).copyWith(height: 1.3),
                ),
              ),
              const VerticalSpacer(18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  bodies[_index],
                  textAlign: TextAlign.center,
                  // Box shrinks to the longest line so lines look balanced.
                  textWidthBasis: TextWidthBasis.longestLine,
                  style: AppTextStyles.medium(
                    14,
                    AppColors.c666666,
                  ).copyWith(height: 1.5),
                ),
              ),
              const VerticalSpacer(36),
              PageDots(count: 3, index: _index),
              const VerticalSpacer(36),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: AppButton(
                  text: _index == 2 ? l10n.startNow : l10n.next,
                  onPressed: _next,
                  height: 52,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
